-- =============================================
-- Limpiar caché SOLO del SP de recálculo
-- =============================================
-- En lugar de limpiar TODO el caché, limpiamos solo los planes
-- que usan el SP de recálculo (que es el que llama a la función)
-- =============================================

USE [ERP_TEST]
GO

SET NOCOUNT ON;

PRINT '========================================================================';
PRINT 'Limpiando caché SOLO del SP de recálculo';
PRINT '========================================================================';
PRINT '';

DECLARE @PlanesLimpiados INT = 0;
DECLARE @plan_handle VARBINARY(64);

-- Cursor para limpiar solo planes que usan el SP de recálculo
DECLARE plan_cursor CURSOR FOR
SELECT cp.plan_handle
FROM sys.dm_exec_cached_plans cp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
WHERE st.text LIKE '%USP_COSTO_INVENTARIO_RECALCULAR_INDIVIDUAL%'
   OR st.text LIKE '%Inv_CalculoCostoPromedio3%';

OPEN plan_cursor;
FETCH NEXT FROM plan_cursor INTO @plan_handle;

WHILE @@FETCH_STATUS = 0
BEGIN
    DBCC FREEPROCCACHE(@plan_handle);
    SET @PlanesLimpiados = @PlanesLimpiados + 1;
    FETCH NEXT FROM plan_cursor INTO @plan_handle;
END

CLOSE plan_cursor;
DEALLOCATE plan_cursor;

PRINT '✓ Planes de ejecución limpiados: ' + CAST(@PlanesLimpiados AS VARCHAR(10));
PRINT '';
PRINT 'Solo se limpiaron los planes que usan:';
PRINT '  - USP_COSTO_INVENTARIO_RECALCULAR_INDIVIDUAL';
PRINT '  - Inv_CalculoCostoPromedio3';
PRINT '';
PRINT 'Los demás planes de ejecución NO fueron afectados.';
PRINT '';

PRINT '========================================================================';
PRINT 'Recalculando con caché limpio';
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
PRINT 'Verificando costos';
PRINT '========================================================================';
PRINT '';

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
    CASE
        WHEN ABS(ci.Costo_MN - 3.8084480) < 0.01 THEN '✗ CACHÉ NO LIMPIO'
        WHEN ABS(ci.Costo_MN - 3.991195) < 0.01 THEN '✗ CACHÉ NO LIMPIO'
        WHEN ABS(ci.Costo_MN - CASE
            WHEN ci.Cd_Inv = 'INV000297367' THEN 3.102090
            WHEN ci.Cd_Inv = 'INV000297372' THEN 2.665417
        END) < 0.01 THEN '✓ CORREGIDO'
        ELSE '? REVISAR'
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
