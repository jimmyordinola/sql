-- =============================================
-- RECALCULAR LIMÓN DESDE ENERO 2025
-- =============================================
-- Este script recalcula desde ENERO 2025 para capturar
-- el origen del costo incorrecto 3.99119
-- =============================================

USE [ERP_ECHA]
GO

DECLARE
    @P_FECHA_RECALCULO_REAL DATETIME,
    @Inicio DATETIME = GETDATE(),
    @Fin DATETIME,
    @TiempoTotal INT;

PRINT '========================================';
PRINT 'RECÁLCULO LIMÓN - DESDE ENERO 2025';
PRINT '========================================';
PRINT 'Producto: PD00534 (LIMON X KG)';
PRINT 'Fecha desde: 01/01/2025 (para capturar origen del costo 3.99)';
PRINT 'Fecha hasta: 31/05/2025 (límite en el SP)';
PRINT '';
PRINT 'Inicio: ' + CONVERT(VARCHAR(20), @Inicio, 120);
PRINT '';

-- Ejecutar recálculo DESDE ENERO
EXEC inventario.USP_COSTO_INVENTARIO_RECALCULAR_4
    @RucE = '20102351038',                    -- TU RUC
    @Cd_Prod_cadena = 'PD00534',              -- LIMON
    @FechaMovimiento = '2025-01-01',          -- DESDE ENERO 2025
    @P_FECHA_RECALCULO_REAL = @P_FECHA_RECALCULO_REAL OUT,
    @P_USUARIO_RECALCULO = 'PROJECT01',       -- Tu usuario
    @P_FECHA_RECALCULO = GETDATE();

SET @Fin = GETDATE();
SET @TiempoTotal = DATEDIFF(SECOND, @Inicio, @Fin);

PRINT '';
PRINT '========================================';
PRINT 'RECÁLCULO COMPLETADO';
PRINT '========================================';
PRINT 'Fecha real procesada: ' + CONVERT(VARCHAR(20), @P_FECHA_RECALCULO_REAL, 120);
PRINT 'Tiempo total: ' + CAST(@TiempoTotal AS VARCHAR(10)) + ' segundos';
PRINT '';

-- Verificar si se corrigió el movimiento problemático
PRINT '========================================';
PRINT 'VERIFICANDO MOVIMIENTOS PROBLEMÁTICOS';
PRINT '========================================';
PRINT '';

SELECT
    'Movimiento corregido' AS Estado,
    ci.Cd_Inv,
    i2.FechaMovimiento,
    id2.Cd_Alm,
    id2.Cantidad,
    ci.Costo_MN AS CostoActual,
    CASE
        WHEN ABS(ci.Costo_MN - 3.99119) < 0.01 THEN 'SIGUE CON COSTO INCORRECTO 3.99'
        ELSE 'COSTO CORREGIDO'
    END AS Resultado
FROM
    CostoInventario ci
    INNER JOIN InventarioDet2 id2 ON id2.RucE = ci.RucE AND id2.Cd_Inv = ci.Cd_Inv AND id2.Item = ci.Item
    INNER JOIN Inventario2 i2 ON i2.RucE = id2.RucE AND i2.Cd_Inv = id2.Cd_Inv
WHERE
    ci.RucE = '20102351038'
    AND ci.Cd_Inv IN ('INV000297367', 'INV000297372')  -- Movimientos problemáticos
    AND id2.IC_ES = 'S'
ORDER BY
    i2.FechaMovimiento;

PRINT '';
PRINT '========================================';
