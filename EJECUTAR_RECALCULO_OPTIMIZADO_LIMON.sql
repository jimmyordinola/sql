-- =============================================
-- EJECUTAR RECÁLCULO OPTIMIZADO PARA LIMÓN
-- =============================================
-- Este script ejecuta el recálculo del producto PD00534 (LIMON X KG)
-- usando la versión optimizada del SP
-- =============================================

USE [ERP_ECHA]
GO

DECLARE
    @P_FECHA_RECALCULO_REAL DATETIME,
    @Inicio DATETIME = GETDATE(),
    @Fin DATETIME,
    @TiempoTotal INT;

PRINT '========================================';
PRINT 'INICIO RECÁLCULO - PD00534 (LIMON)';
PRINT '========================================';
PRINT 'Fecha inicio: ' + CONVERT(VARCHAR(20), @Inicio, 120);
PRINT 'IMPORTANTE: El SP procesará movimientos';
PRINT 'desde 01/04/2025 hasta 01/05/2025 SOLAMENTE';
PRINT '';

-- Ejecutar recálculo
EXEC inventario.USP_COSTO_INVENTARIO_RECALCULAR_4
    @RucE = '20513423307',                    -- Reemplaza con tu RUC
    @Cd_Prod_cadena = 'PD00534',              -- SOLO limón
    @FechaMovimiento = '2025-04-01',          -- Desde abril 2025
    @P_FECHA_RECALCULO_REAL = @P_FECHA_RECALCULO_REAL OUT,
    @P_USUARIO_RECALCULO = 'ADMIN',           -- Tu usuario
    @P_FECHA_RECALCULO = GETDATE();

SET @Fin = GETDATE();
SET @TiempoTotal = DATEDIFF(SECOND, @Inicio, @Fin);

PRINT '';
PRINT '========================================';
PRINT 'RECÁLCULO COMPLETADO';
PRINT '========================================';
PRINT 'Fecha fin: ' + CONVERT(VARCHAR(20), @Fin, 120);
PRINT 'Tiempo total: ' + CAST(@TiempoTotal AS VARCHAR(10)) + ' segundos';
PRINT 'Fecha real procesada: ' + CONVERT(VARCHAR(20), @P_FECHA_RECALCULO_REAL, 120);
PRINT '========================================';
GO

-- Verificar resultado
SELECT TOP 5
    ci.Cd_Inv,
    i2.FechaMovimiento,
    id2.IC_ES,
    id2.Cd_Alm,
    id2.Cantidad,
    ci.Costo_MN,
    ci.Costo_ME
FROM
    CostoInventario ci
    INNER JOIN InventarioDet2 id2 ON id2.RucE = ci.RucE AND id2.Cd_Inv = ci.Cd_Inv AND id2.Item = ci.Item
    INNER JOIN Inventario2 i2 ON i2.RucE = id2.RucE AND i2.Cd_Inv = id2.Cd_Inv
WHERE
    ci.RucE = '20513423307'
    AND id2.Cd_Prod = 'PD00534'
    AND i2.FechaMovimiento >= '2025-04-01'
ORDER BY
    i2.FechaMovimiento DESC;

PRINT '';
PRINT 'Mostrando últimos 5 movimientos recalculados';
