-- =============================================
-- SOLUCIÓN FINAL: Resetear costos a NULL y recalcular
-- =============================================
-- El problema: El SP hace INNER JOIN con CostoInventario
-- Si eliminamos los registros, el INNER JOIN no encuentra nada
-- Solución: Poner el costo en NULL en lugar de eliminar
-- =============================================

USE [ERP_TEST]
GO

SET NOCOUNT ON;

PRINT '========================================================================';
PRINT 'PASO 1: Verificar que los registros existen en CostoInventario';
PRINT '========================================================================';
PRINT '';

-- Primero verificar si los registros existen
SELECT
    'ANTES del reset' AS Momento,
    ci.Cd_Inv,
    ci.Item,
    ci.Costo_MN,
    ci.Costo_ME
FROM CostoInventario ci
WHERE ci.RucE = '20102351038'
  AND ci.Cd_Inv IN ('INV000297367', 'INV000297372');

-- Si no hay registros, hay que recrearlos primero
DECLARE @Count INT = (
    SELECT COUNT(*)
    FROM CostoInventario
    WHERE RucE = '20102351038'
      AND Cd_Inv IN ('INV000297367', 'INV000297372')
);

IF @Count = 0
BEGIN
    PRINT '✗ ERROR: Los registros NO EXISTEN en CostoInventario';
    PRINT '   No se pueden actualizar porque fueron eliminados.';
    PRINT '';
    PRINT 'SOLUCIÓN: Hay que RECREAR los registros antes de recalcular.';
    PRINT '';
    PRINT 'Ejecutando INSERT para recrear registros...';
    PRINT '';

    -- Recrear los registros en CostoInventario desde InventarioDet2
    INSERT INTO CostoInventario (
        RucE,
        Correlativo,
        Cd_Inv,
        Item,
        Cd_Prod,
        Cantidad,
        Costo_MN,
        Costo_ME,
        IC_TipoCostoInventario
    )
    SELECT
        id2.RucE,
        0 AS Correlativo,  -- Se actualizará en el recálculo
        id2.Cd_Inv,
        id2.Item,
        id2.Cd_Prod,
        id2.Cantidad,
        NULL AS Costo_MN,  -- NULL para forzar recálculo
        NULL AS Costo_ME,
        'M' AS IC_TipoCostoInventario
    FROM
        InventarioDet2 id2
        INNER JOIN Inventario2 i2 ON i2.RucE = id2.RucE AND i2.Cd_Inv = id2.Cd_Inv
    WHERE
        id2.RucE = '20102351038'
        AND id2.Cd_Inv IN ('INV000297367', 'INV000297372')
        AND NOT EXISTS (
            SELECT 1
            FROM CostoInventario ci
            WHERE ci.RucE = id2.RucE
              AND ci.Cd_Inv = id2.Cd_Inv
              AND ci.Item = id2.Item
        );

    PRINT '✓ Registros recreados con Costo = NULL';
    PRINT '';
END
ELSE
BEGIN
    PRINT '✓ Los registros existen. Reseteando costos a NULL...';
    PRINT '';

    -- Resetear los costos a NULL (en lugar de eliminar)
    UPDATE CostoInventario
    SET
        Costo_MN = NULL,
        Costo_ME = NULL,
        Correlativo = 0
    WHERE
        RucE = '20102351038'
        AND Cd_Inv IN ('INV000297367', 'INV000297372');

    PRINT '✓ Costos reseteados a NULL';
    PRINT '';
END

PRINT '========================================================================';
PRINT 'PASO 2: Recalcular desde 01-04-2025';
PRINT '========================================================================';
PRINT '';

DECLARE
    @InicioRecalculo DATETIME = GETDATE(),
    @FinRecalculo DATETIME,
    @TiempoRecalculo INT;

-- Recalcular
EXEC inventario.USP_COSTO_INVENTARIO_RECALCULAR_INDIVIDUAL_3
    @RucE = '20102351038',
    @Cd_Prod = 'PD00534',
    @FechaMovimiento = '2025-04-01',
    @P_USUARIO_RECALCULO = 'PROJECT01',
    @P_FECHA_RECALCULO = GETDATE();

SET @FinRecalculo = GETDATE();
SET @TiempoRecalculo = DATEDIFF(SECOND, @InicioRecalculo, @FinRecalculo);

PRINT '';
PRINT '✓ Recálculo completado en ' + CAST(@TiempoRecalculo AS VARCHAR(10)) + ' segundos';
PRINT '';

PRINT '========================================================================';
PRINT 'PASO 3: Verificar los costos recalculados';
PRINT '========================================================================';
PRINT '';

-- Verificar resultados
SELECT
    'DESPUÉS del recálculo' AS Momento,
    i2.FechaMovimiento,
    ci.Cd_Inv,
    ci.Item,
    id2.Cantidad AS Kg_Salida,
    ci.Costo_MN AS Costo_Unitario,
    (id2.Cantidad * ISNULL(ci.Costo_MN, 0)) AS Total_Salida,
    CASE
        WHEN ci.Costo_MN IS NULL THEN '✗ NO CALCULADO (NULL)'
        WHEN ci.Costo_MN = 0 THEN '✗ NO CALCULADO (cero)'
        WHEN ABS(ci.Costo_MN - 3.991195) < 0.01 THEN '✗ BUG PERSISTE (3.991195)'
        WHEN ABS(ci.Costo_MN - 3.991134) < 0.01 THEN '✗ BUG PERSISTE (3.991134)'
        WHEN ci.Cd_Inv = 'INV000297367' AND ABS(ci.Costo_MN - 3.102090) < 0.01 THEN '✓ CORREGIDO (3.102)'
        WHEN ci.Cd_Inv = 'INV000297372' AND ABS(ci.Costo_MN - 2.665417) < 0.01 THEN '✓ CORREGIDO (2.665)'
        ELSE '? REVISAR: ' + CAST(ci.Costo_MN AS VARCHAR(20))
    END AS Estado
FROM
    CostoInventario ci
    INNER JOIN InventarioDet2 id2 ON id2.RucE = ci.RucE AND id2.Cd_Inv = ci.Cd_Inv AND id2.Item = ci.Item
    INNER JOIN Inventario2 i2 ON i2.RucE = id2.RucE AND i2.Cd_Inv = id2.Cd_Inv
WHERE
    ci.RucE = '20102351038'
    AND ci.Cd_Inv IN ('INV000297367', 'INV000297372')
    AND id2.IC_ES = 'S'
ORDER BY
    i2.FechaMovimiento;

PRINT '';
PRINT '========================================================================';
PRINT 'RESULTADOS ESPERADOS:';
PRINT '========================================================================';
PRINT 'INV000297367 (29-04 08:05): ✓ CORREGIDO (3.102)';
PRINT 'INV000297372 (29-04 08:50): ✓ CORREGIDO (2.665)';
PRINT '';
PRINT 'Si muestra ✗ BUG PERSISTE, significa que la función Inv_CalculoCostoPromedio3';
PRINT 'NO tiene el operador <= en la línea 60.';
PRINT '';
PRINT '========================================================================';
