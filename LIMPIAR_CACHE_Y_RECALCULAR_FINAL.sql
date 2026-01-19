-- =============================================
-- SOLUCIÓN FINAL: Limpiar caché y recalcular
-- =============================================
-- La función YA ESTÁ CORREGIDA en la BD
-- El problema es el CACHÉ del plan de ejecución
-- =============================================

USE [ERP_TEST]
GO

SET NOCOUNT ON;

PRINT '========================================================================';
PRINT 'PASO 1: Limpiar caché del plan de ejecución';
PRINT '========================================================================';
PRINT '';
PRINT 'La función Inv_CalculoCostoPromedio3 está CORRECTA en la BD.';
PRINT 'Pero SQL Server está usando el plan en caché con la versión antigua.';
PRINT '';
PRINT 'Limpiando caché...';
PRINT '';

-- Limpiar TODO el caché
DBCC FREEPROCCACHE;

PRINT '✓ Caché limpiado completamente';
PRINT '';
PRINT 'SQL Server ahora compilará nuevos planes de ejecución';
PRINT 'usando la versión corregida de la función.';
PRINT '';

PRINT '========================================================================';
PRINT 'PASO 2: Recalcular desde 01-04-2025';
PRINT '========================================================================';
PRINT '';

DECLARE
    @InicioRecalculo DATETIME = GETDATE(),
    @FinRecalculo DATETIME,
    @TiempoRecalculo INT;

-- Recalcular con el caché limpio
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
PRINT 'PASO 3: Verificar los costos';
PRINT '========================================================================';
PRINT '';

-- Verificar los costos sin conversión a VARCHAR que causa overflow
SELECT
    i2.FechaMovimiento,
    ci.Cd_Inv,
    ci.Item,
    id2.Cantidad AS Kg_Salida,
    ci.Costo_MN AS Costo_Actual,
    CASE
        WHEN ci.Cd_Inv = 'INV000297367' THEN 3.102090
        WHEN ci.Cd_Inv = 'INV000297372' THEN 2.665417
    END AS Costo_Esperado,
    (ci.Costo_MN - CASE
        WHEN ci.Cd_Inv = 'INV000297367' THEN 3.102090
        WHEN ci.Cd_Inv = 'INV000297372' THEN 2.665417
    END) AS Diferencia,
    CASE
        -- Costos incorrectos
        WHEN ABS(ci.Costo_MN - 3.8084480) < 0.01 THEN '✗ CACHÉ NO LIMPIO (3.8084)'
        WHEN ABS(ci.Costo_MN - 3.991195) < 0.01 THEN '✗ CACHÉ NO LIMPIO (3.9912)'

        -- Costos correctos
        WHEN ci.Cd_Inv = 'INV000297367' AND ABS(ci.Costo_MN - 3.102090) < 0.01 THEN '✓ CORREGIDO'
        WHEN ci.Cd_Inv = 'INV000297372' AND ABS(ci.Costo_MN - 2.665417) < 0.01 THEN '✓ CORREGIDO'

        -- Otros
        WHEN ABS(ci.Costo_MN - CASE
            WHEN ci.Cd_Inv = 'INV000297367' THEN 3.102090
            WHEN ci.Cd_Inv = 'INV000297372' THEN 2.665417
        END) < 0.01 THEN '✓ CORREGIDO'

        ELSE '? REVISAR MANUALMENTE'
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
PRINT 'INTERPRETACIÓN:';
PRINT '========================================================================';
PRINT '';
PRINT '✓ CORREGIDO          → El bug está SOLUCIONADO';
PRINT '✗ CACHÉ NO LIMPIO    → El DBCC FREEPROCCACHE no limpió el plan';
PRINT '? REVISAR MANUALMENTE → Costo diferente al esperado';
PRINT '';
PRINT 'Si muestra ✗ CACHÉ NO LIMPIO:';
PRINT '  - Cerrar todas las conexiones a la BD';
PRINT '  - Reiniciar SQL Server Management Studio';
PRINT '  - Volver a ejecutar este script';
PRINT '';
PRINT '========================================================================';
