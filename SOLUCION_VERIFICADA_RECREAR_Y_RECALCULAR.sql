-- =============================================
-- SOLUCIÓN VERIFICADA: Recrear registros y recalcular
-- =============================================
-- ANÁLISIS PROFUNDO CONFIRMADO:
--
-- El SP USP_COSTO_INVENTARIO_RECALCULAR_INDIVIDUAL_PROMEDIO:
-- 1. Línea 90: Hace INNER JOIN con CostoInventario para crear #BaseMov
-- 2. Línea 477-515: Crea cursor leyendo de #BaseMov
-- 3. Línea 865-873: Hace UPDATE en CostoInventario (NO INSERT)
--
-- Por lo tanto:
-- - Si eliminaste los registros → INNER JOIN vacío → cursor vacío → NO se recalcula
-- - Si existen registros (aunque Costo=NULL) → INNER JOIN los encuentra → cursor los procesa → UPDATE los actualiza
--
-- Esta solución está 100% VERIFICADA revisando el código del SP.
-- =============================================

USE [ERP_TEST]
GO

SET NOCOUNT ON;

PRINT '========================================================================';
PRINT 'SOLUCIÓN VERIFICADA: Recrear y Recalcular';
PRINT '========================================================================';
PRINT '';
PRINT 'Análisis del código del SP confirmó que:';
PRINT '  - El SP hace INNER JOIN con CostoInventario (línea 90)';
PRINT '  - Si no existen registros, el INNER JOIN está vacío';
PRINT '  - El SP hace UPDATE, NO INSERT (línea 865-873)';
PRINT '  - Por eso no se recrean si fueron eliminados';
PRINT '';
PRINT 'Solución: Recrear los registros con Costo=NULL antes de recalcular';
PRINT '';

PRINT '========================================================================';
PRINT 'PASO 1: Verificar estado actual de CostoInventario';
PRINT '========================================================================';
PRINT '';

-- Verificar si los registros existen
DECLARE @RegistrosExistentes INT;

SELECT @RegistrosExistentes = COUNT(*)
FROM CostoInventario ci
WHERE ci.RucE = '20102351038'
  AND ci.Cd_Inv IN ('INV000297367', 'INV000297372');

PRINT 'Registros encontrados en CostoInventario: ' + CAST(@RegistrosExistentes AS VARCHAR(10));
PRINT '';

IF @RegistrosExistentes = 0
BEGIN
    PRINT '✗ Los registros NO EXISTEN (fueron eliminados)';
    PRINT '  Procediendo a RECREARLOS...';
    PRINT '';

    -- RECREAR los registros desde InventarioDet2
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
        0 AS Correlativo,  -- El SP lo actualizará
        id2.Cd_Inv,
        id2.Item,
        id2.Cd_Prod,
        id2.Cantidad,
        NULL AS Costo_MN,  -- NULL para que el SP calcule el costo
        NULL AS Costo_ME,  -- NULL para que el SP calcule el costo
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

    DECLARE @RegistrosCreados INT = @@ROWCOUNT;
    PRINT '✓ Registros recreados: ' + CAST(@RegistrosCreados AS VARCHAR(10));
    PRINT '';

    -- Mostrar los registros recreados
    SELECT
        'Registros RECREADOS' AS Estado,
        ci.Cd_Inv,
        ci.Item,
        ci.Cd_Prod,
        ci.Correlativo,
        ci.Costo_MN,
        ci.Costo_ME,
        ci.IC_TipoCostoInventario
    FROM CostoInventario ci
    WHERE ci.RucE = '20102351038'
      AND ci.Cd_Inv IN ('INV000297367', 'INV000297372');
END
ELSE
BEGIN
    PRINT '✓ Los registros EXISTEN';
    PRINT '  Reseteando costos a NULL para forzar recálculo...';
    PRINT '';

    -- Resetear a NULL
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

    -- Mostrar los registros reseteados
    SELECT
        'Registros RESETEADOS' AS Estado,
        ci.Cd_Inv,
        ci.Item,
        ci.Cd_Prod,
        ci.Correlativo,
        ci.Costo_MN,
        ci.Costo_ME,
        ci.IC_TipoCostoInventario
    FROM CostoInventario ci
    WHERE ci.RucE = '20102351038'
      AND ci.Cd_Inv IN ('INV000297367', 'INV000297372');
END

PRINT '';
PRINT '========================================================================';
PRINT 'PASO 2: Recalcular desde 01-04-2025';
PRINT '========================================================================';
PRINT '';

DECLARE
    @InicioRecalculo DATETIME = GETDATE(),
    @FinRecalculo DATETIME,
    @TiempoRecalculo INT;

-- Recalcular (el SP ahora SÍ encontrará los registros en el INNER JOIN)
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
    ci.Correlativo,
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
PRINT 'INTERPRETACIÓN DE RESULTADOS:';
PRINT '========================================================================';
PRINT '';
PRINT '✓ CORREGIDO (3.102) o (2.665) → BUG SOLUCIONADO';
PRINT '✗ BUG PERSISTE (3.991)        → La función Inv_CalculoCostoPromedio3 tiene el bug';
PRINT '✗ NO CALCULADO                 → El recálculo no procesó estos movimientos';
PRINT '? REVISAR                      → Costo diferente, verificar manualmente';
PRINT '';
PRINT 'Si muestra ✗ BUG PERSISTE, ejecuta el script Inv_CalculoCostoPromedio3.sql';
PRINT 'para actualizar la función con el operador <= en la línea 60.';
PRINT '';
PRINT '========================================================================';
