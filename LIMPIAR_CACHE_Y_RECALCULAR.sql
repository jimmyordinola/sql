-- =============================================
-- Limpiar caché y recalcular con función corregida
-- =============================================

USE [ERP_TEST]
GO

SET NOCOUNT ON;

PRINT '========================================================================';
PRINT 'PASO 1: Limpiando caché del plan de ejecución';
PRINT '========================================================================';
PRINT '';
PRINT 'Esto forzará a SQL Server a usar la versión actualizada de la función';
PRINT '';

-- Limpiar caché específico de la función
DBCC FREEPROCCACHE;

PRINT '✓ Caché limpiado';
PRINT '';

PRINT '========================================================================';
PRINT 'PASO 2: Recalculando PD00534 (LIMON X KG) con función corregida';
PRINT '========================================================================';
PRINT '';

DECLARE
    @InicioRecalculo DATETIME = GETDATE(),
    @FinRecalculo DATETIME,
    @TiempoRecalculo INT,
    @P_FECHA_RECALCULO_REAL DATETIME;

-- Recalcular desde abril 2025
EXEC inventario.USP_COSTO_INVENTARIO_RECALCULAR_4
    @RucE = '20102351038',
    @Cd_Prod_cadena = 'PD00534',
    @FechaMovimiento = '2025-04-01',
    @P_FECHA_RECALCULO_REAL = @P_FECHA_RECALCULO_REAL OUT,
    @P_USUARIO_RECALCULO = 'PROJECT01',
    @P_FECHA_RECALCULO = GETDATE();

SET @FinRecalculo = GETDATE();
SET @TiempoRecalculo = DATEDIFF(SECOND, @InicioRecalculo, @FinRecalculo);

PRINT '';
PRINT '✓ Recálculo completado en ' + CAST(@TiempoRecalculo AS VARCHAR(10)) + ' segundos';
PRINT '';

PRINT '========================================================================';
PRINT 'PASO 3: Verificando corrección de costos';
PRINT '========================================================================';
PRINT '';

-- Verificar los movimientos problemáticos
SELECT
    'Verificación Post-Corrección' AS Resultado,
    i2.FechaMovimiento,
    ci.Cd_Inv,
    id2.Cd_Alm,
    id2.Cantidad,
    ci.Costo_MN AS CostoActual,
    CASE
        -- Costos esperados después de la corrección
        WHEN ci.Cd_Inv = 'INV000297367' AND ABS(ci.Costo_MN - 3.102090) < 0.01 THEN '✓ CORREGIDO (era 3.99, ahora 3.10)'
        WHEN ci.Cd_Inv = 'INV000297372' AND ABS(ci.Costo_MN - 2.665417) < 0.01 THEN '✓ CORREGIDO (era 3.99, ahora 2.67)'

        -- Si aún tiene los costos incorrectos
        WHEN ABS(ci.Costo_MN - 3.991195) < 0.01 THEN '✗ ERROR - BUG PERSISTE (3.99)'

        -- Otros costos
        ELSE '? REVISAR: ' + CAST(ci.Costo_MN AS VARCHAR(20))
    END AS Estado,
    CASE
        WHEN ABS(ci.Costo_MN - 3.991195) < 0.01 THEN 'El bug persiste. Posibles causas: 1) Función no actualizada 2) Otra función calculando costo'
        ELSE 'OK'
    END AS Observacion
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
PRINT 'INV000297367 (29-04 08:05): ✓ CORREGIDO - Costo 3.102090';
PRINT 'INV000297372 (29-04 08:50): ✓ CORREGIDO - Costo 2.665417';
PRINT '';
PRINT 'Si muestra ✗ ERROR, significa que la función corregida NO se está usando.';
PRINT 'En ese caso, verifica:';
PRINT '  1. Que la función tenga el operador <= (ejecutar DIAGNOSTICO_FUNCION_EN_BD.sql)';
PRINT '  2. Que no haya otra función dbo.Inv_CalculoCostoPromedio3 calculando el costo';
PRINT '  3. Los permisos de ejecución de la función';
PRINT '';
PRINT '========================================================================';
PRINT 'PROCESO COMPLETADO';
PRINT '========================================================================';
