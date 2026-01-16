-- =============================================
-- VERIFICAR SI EL RECÁLCULO ACTUALIZA ALGO
-- =============================================
USE [ERP_ECHA]
GO

DECLARE @RucE VARCHAR(11) = '20102351038';  -- Tu RUC
DECLARE @Cd_Prod VARCHAR(7) = 'PD00534';     -- LIMON

PRINT '========================================';
PRINT 'PASO 1: ESTADO ACTUAL DE LOS COSTOS';
PRINT '========================================';
PRINT '';

-- Guardar estado ANTES del recálculo
IF OBJECT_ID('tempdb..#CostosANTES') IS NOT NULL DROP TABLE #CostosANTES;

SELECT
    ci.Cd_Inv,
    ci.Item,
    ci.Correlativo,
    i2.FechaMovimiento,
    id2.IC_ES,
    id2.Cd_Alm,
    id2.Cantidad,
    ci.Costo_MN AS Costo_MN_ANTES,
    ci.Costo_ME AS Costo_ME_ANTES
INTO #CostosANTES
FROM
    CostoInventario ci
    INNER JOIN InventarioDet2 id2 ON id2.RucE = ci.RucE AND id2.Cd_Inv = ci.Cd_Inv AND id2.Item = ci.Item
    INNER JOIN Inventario2 i2 ON i2.RucE = id2.RucE AND i2.Cd_Inv = id2.Cd_Inv
WHERE
    ci.RucE = @RucE
    AND id2.Cd_Prod = @Cd_Prod
    AND i2.FechaMovimiento >= '2025-04-01'
    AND i2.FechaMovimiento <= '2025-05-01'
    AND ISNULL(ci.IC_TipoCostoInventario,'M') = 'M'
ORDER BY
    i2.FechaMovimiento;

PRINT 'Se encontraron ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' movimientos entre 01/04/2025 y 01/05/2025';
PRINT '';

-- Mostrar primeros 5 costos actuales
PRINT 'PRIMEROS 5 COSTOS ACTUALES:';
PRINT '';
SELECT TOP 5
    FechaMovimiento,
    Cd_Inv,
    IC_ES,
    Cd_Alm,
    Cantidad,
    Costo_MN_ANTES,
    Costo_ME_ANTES
FROM #CostosANTES
ORDER BY FechaMovimiento;

PRINT '';
PRINT '========================================';
PRINT 'PASO 2: EJECUTANDO RECÁLCULO CON DEBUG';
PRINT '========================================';
PRINT '';

-- Ejecutar recálculo con DEBUG activado
DECLARE @P_FECHA_RECALCULO_REAL DATETIME;

EXEC inventario.USP_COSTO_INVENTARIO_RECALCULAR_INDIVIDUAL_PROMEDIO
    @P_RUC_EMPRESA = @RucE,
    @P_CODIGO_PRODUCTO = @Cd_Prod,
    @P_FECHA_MOVIMIENTO = '2025-04-01 00:00:00',
    @P_DEBUG = 1;  -- DEBUG ACTIVADO para ver mensajes

PRINT '';
PRINT '========================================';
PRINT 'PASO 3: COMPARANDO ANTES vs DESPUÉS';
PRINT '========================================';
PRINT '';

-- Comparar ANTES vs DESPUÉS
SELECT
    'CAMBIOS DETECTADOS' AS Resultado,
    a.FechaMovimiento,
    a.Cd_Inv,
    a.IC_ES,
    a.Cd_Alm,
    a.Costo_MN_ANTES,
    ci.Costo_MN AS Costo_MN_DESPUES,
    CASE
        WHEN ABS(a.Costo_MN_ANTES - ci.Costo_MN) > 0.00001 THEN 'CAMBIO'
        ELSE 'SIN CAMBIO'
    END AS Estado_MN,
    (ci.Costo_MN - a.Costo_MN_ANTES) AS Diferencia_MN
FROM
    #CostosANTES a
    INNER JOIN CostoInventario ci ON ci.Cd_Inv = a.Cd_Inv AND ci.Item = a.Item
WHERE
    ci.RucE = @RucE
    AND ABS(a.Costo_MN_ANTES - ci.Costo_MN) > 0.00001  -- Solo mostrar los que cambiaron
ORDER BY
    a.FechaMovimiento;

DECLARE @Cambios INT = @@ROWCOUNT;

PRINT '';
PRINT '========================================';
PRINT 'RESUMEN';
PRINT '========================================';
PRINT 'Total de costos que CAMBIARON: ' + CAST(@Cambios AS VARCHAR(10));

IF @Cambios = 0
BEGIN
    PRINT '';
    PRINT 'ADVERTENCIA: NO SE DETECTARON CAMBIOS';
    PRINT '';
    PRINT 'Posibles causas:';
    PRINT '  1. El SP no se actualizó en la base de datos';
    PRINT '  2. Los costos ya estaban correctos';
    PRINT '  3. El filtro de fecha está bloqueando los movimientos';
    PRINT '';
    PRINT 'Verificar versión del SP:';

    -- Ver si el SP tiene la optimización
    SELECT
        OBJECT_NAME(object_id) AS StoredProcedure,
        create_date AS FechaCreacion,
        modify_date AS UltimaModificacion
    FROM sys.sql_modules sm
    INNER JOIN sys.objects o ON o.object_id = sm.object_id
    WHERE OBJECT_NAME(sm.object_id) = 'USP_COSTO_INVENTARIO_RECALCULAR_INDIVIDUAL_PROMEDIO';

    PRINT '';
    PRINT 'Si UltimaModificacion < ' + CONVERT(VARCHAR(20), GETDATE(), 120);
    PRINT 'entonces el SP NO se actualizó.';
END
ELSE
BEGIN
    PRINT '';
    PRINT 'EXITO: El SP actualizó ' + CAST(@Cambios AS VARCHAR(10)) + ' costos correctamente';
END

PRINT '========================================';

-- Limpiar
DROP TABLE #CostosANTES;
