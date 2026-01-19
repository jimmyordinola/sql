-- =============================================
-- SOLUCIÓN DEFINITIVA: Eliminar duplicados y recalcular
-- =============================================
-- ANÁLISIS:
-- - Hay DUPLICADOS en CostoInventario (mismo Cd_Inv + Item)
-- - Estos duplicados se crearon por el script de recrear registros
-- - El SP NO puede procesar duplicados (índice UNIQUE)
-- - Solución: ELIMINAR todos y recalcular desde ANTES de abril
-- =============================================

USE [ERP_TEST]
GO

SET NOCOUNT ON;

PRINT '========================================================================';
PRINT 'DIAGNÓSTICO: Estado actual de CostoInventario';
PRINT '========================================================================';
PRINT '';

-- Contar duplicados
SELECT
    'Duplicados en CostoInventario' AS Info,
    ci.Cd_Inv,
    ci.Item,
    COUNT(*) AS Cantidad_Registros
FROM
    CostoInventario ci
WHERE
    ci.RucE = '20102351038'
    AND ci.Cd_Inv IN ('INV000297367', 'INV000297372')
GROUP BY
    ci.Cd_Inv, ci.Item
HAVING COUNT(*) > 1
ORDER BY
    ci.Cd_Inv, ci.Item;

PRINT '';
PRINT '========================================================================';
PRINT 'PASO 1: Eliminar TODOS los registros de CostoInventario';
PRINT '========================================================================';
PRINT '';

DECLARE @RegistrosEliminados INT;

-- Eliminar TODOS los registros (incluyendo duplicados)
DELETE FROM CostoInventario
WHERE RucE = '20102351038'
  AND Cd_Inv IN ('INV000297367', 'INV000297372');

SET @RegistrosEliminados = @@ROWCOUNT;

PRINT '✓ Registros eliminados: ' + CAST(@RegistrosEliminados AS VARCHAR(10));
PRINT '';
PRINT 'Estos registros se recrearán automáticamente en el recálculo.';
PRINT '';

PRINT '========================================================================';
PRINT 'PASO 2: Verificar InventarioDet2 (NO debe tener duplicados)';
PRINT '========================================================================';
PRINT '';

-- Verificar que InventarioDet2 NO tiene duplicados de Item
SELECT
    'Verificación InventarioDet2' AS Info,
    id2.Cd_Inv,
    id2.Item,
    COUNT(*) AS Cantidad_Registros
FROM
    InventarioDet2 id2
WHERE
    id2.RucE = '20102351038'
    AND id2.Cd_Inv IN ('INV000297367', 'INV000297372')
GROUP BY
    id2.Cd_Inv, id2.Item
HAVING COUNT(*) > 1;

-- Si la consulta anterior no devuelve filas, está OK
DECLARE @DuplicadosInventarioDet2 INT = @@ROWCOUNT;

IF @DuplicadosInventarioDet2 = 0
BEGIN
    PRINT '✓ InventarioDet2 NO tiene duplicados';
    PRINT '  Cada Cd_Inv + Item es único';
END
ELSE
BEGIN
    PRINT '✗ ERROR: InventarioDet2 tiene duplicados';
    PRINT '  Esto NO debería ocurrir. Hay un problema en la BD.';
END

PRINT '';
PRINT '========================================================================';
PRINT 'PASO 3: Recalcular desde MARZO 2025';
PRINT '========================================================================';
PRINT '';
PRINT 'Recalculando desde 01-03-2025 para garantizar que los registros';
PRINT 'de abril se creen correctamente desde cero...';
PRINT '';

DECLARE
    @InicioRecalculo DATETIME = GETDATE(),
    @FinRecalculo DATETIME,
    @TiempoRecalculo INT;

-- Recalcular desde MARZO para que procese abril completo
EXEC inventario.USP_COSTO_INVENTARIO_RECALCULAR_INDIVIDUAL_3
    @RucE = '20102351038',
    @Cd_Prod = 'PD00534',
    @FechaMovimiento = '2025-03-01',
    @P_USUARIO_RECALCULO = 'PROJECT01',
    @P_FECHA_RECALCULO = GETDATE();

SET @FinRecalculo = GETDATE();
SET @TiempoRecalculo = DATEDIFF(SECOND, @InicioRecalculo, @FinRecalculo);

PRINT '';
PRINT '✓ Recálculo completado en ' + CAST(@TiempoRecalculo AS VARCHAR(10)) + ' segundos';
PRINT '';

PRINT '========================================================================';
PRINT 'PASO 4: Verificar que NO hay duplicados después del recálculo';
PRINT '========================================================================';
PRINT '';

-- Verificar duplicados nuevamente
SELECT
    'Duplicados después del recálculo' AS Info,
    ci.Cd_Inv,
    ci.Item,
    COUNT(*) AS Cantidad_Registros
FROM
    CostoInventario ci
WHERE
    ci.RucE = '20102351038'
    AND ci.Cd_Inv IN ('INV000297367', 'INV000297372')
GROUP BY
    ci.Cd_Inv, ci.Item
HAVING COUNT(*) > 1;

DECLARE @DuplicadosDespues INT = @@ROWCOUNT;

IF @DuplicadosDespues = 0
BEGIN
    PRINT '✓ No hay duplicados después del recálculo';
END
ELSE
BEGIN
    PRINT '✗ ADVERTENCIA: Aún hay duplicados';
    PRINT '  El SP está creando registros duplicados (bug en el SP)';
END

PRINT '';
PRINT '========================================================================';
PRINT 'PASO 5: Verificar los costos finales';
PRINT '========================================================================';
PRINT '';

-- Ver costos finales (solo si no hay duplicados)
IF @DuplicadosDespues = 0
BEGIN
    SELECT
        i2.FechaMovimiento,
        ci.Cd_Inv,
        ci.Item,
        id2.IC_ES,
        id2.Cantidad,
        ci.Costo_MN,
        CASE
            WHEN ci.Cd_Inv = 'INV000297367' AND id2.Cd_Prod = 'PD00534' AND id2.IC_ES = 'S' THEN 3.102090
            WHEN ci.Cd_Inv = 'INV000297372' AND id2.Cd_Prod = 'PD00534' AND id2.IC_ES = 'S' THEN 2.665417
        END AS Costo_Esperado,
        CASE
            WHEN id2.Cd_Prod != 'PD00534' THEN 'Otro producto'
            WHEN id2.IC_ES != 'S' THEN 'Entrada'
            WHEN ABS(ci.Costo_MN - 3.102090) < 0.01 THEN '✓ CORRECTO'
            WHEN ABS(ci.Costo_MN - 2.665417) < 0.01 THEN '✓ CORRECTO'
            ELSE '✗ INCORRECTO: ' + CAST(ci.Costo_MN AS VARCHAR(20))
        END AS Estado
    FROM
        CostoInventario ci
        INNER JOIN InventarioDet2 id2 ON id2.RucE = ci.RucE AND ci.Cd_Inv = id2.Cd_Inv AND ci.Item = id2.Item
        INNER JOIN Inventario2 i2 ON i2.RucE = id2.RucE AND i2.Cd_Inv = id2.Cd_Inv
    WHERE
        ci.RucE = '20102351038'
        AND ci.Cd_Inv IN ('INV000297367', 'INV000297372')
    ORDER BY
        i2.FechaMovimiento, ci.Item;
END
ELSE
BEGIN
    PRINT 'No se puede verificar costos porque hay duplicados.';
END

PRINT '';
PRINT '========================================================================';
PRINT 'RESUMEN:';
PRINT '========================================================================';
PRINT '';
PRINT 'Si todos los costos muestran ✓ CORRECTO:';
PRINT '  → El problema está SOLUCIONADO';
PRINT '';
PRINT 'Si muestra ✗ INCORRECTO:';
PRINT '  → La función Inv_CalculoCostoPromedio3 aún tiene el bug';
PRINT '  → O hay otro problema en el cálculo del costo';
PRINT '';
PRINT '========================================================================';
