-- =============================================
-- SOLUCIÓN: Recalcular FORZANDO la fecha correcta
-- =============================================
-- Este script llama directamente a USP_COSTO_INVENTARIO_RECALCULAR_INDIVIDUAL_3
-- para bypasear el cálculo automático de fecha que hace _4
-- =============================================

USE [ERP_TEST]
GO

SET NOCOUNT ON;

PRINT '========================================================================';
PRINT 'RECÁLCULO CORREGIDO: Forzando fecha desde 01-04-2025';
PRINT '========================================================================';
PRINT '';

DECLARE
    @RucE VARCHAR(11) = '20102351038',
    @Cd_Prod CHAR(7) = 'PD00534',
    @FechaRecalculo DATETIME = '2025-04-01 00:00:00',  -- FORZAR desde abril
    @UsuarioRecalculo NVARCHAR(10) = 'PROJECT01',
    @FechaActual DATETIME = GETDATE();

PRINT 'Parámetros de recálculo:';
PRINT '  RUC: ' + @RucE;
PRINT '  Producto: ' + @Cd_Prod;
PRINT '  Fecha inicio: ' + CONVERT(VARCHAR(20), @FechaRecalculo, 120);
PRINT '  Usuario: ' + @UsuarioRecalculo;
PRINT '';

-- Llamar DIRECTAMENTE al SP individual sin pasar por _4
-- que es el que calcula la fecha automáticamente
EXEC inventario.USP_COSTO_INVENTARIO_RECALCULAR_INDIVIDUAL_3
    @RucE = @RucE,
    @Cd_Prod = @Cd_Prod,
    @FechaMovimiento = @FechaRecalculo,
    @P_USUARIO_RECALCULO = @UsuarioRecalculo,
    @P_FECHA_RECALCULO = @FechaActual;

PRINT '';
PRINT '========================================================================';
PRINT 'VERIFICACIÓN: Costos después del recálculo';
PRINT '========================================================================';
PRINT '';

-- Verificar los costos recalculados
SELECT
    i2.FechaMovimiento,
    ci.Cd_Inv,
    id2.Cd_Alm,
    id2.Cantidad AS Cantidad_Salida,
    ci.Costo_MN AS Costo_Actual,
    CASE
        -- Verificar si tiene los costos incorrectos
        WHEN ABS(ci.Costo_MN - 3.991195) < 0.01 THEN '✗ BUG PERSISTE (3.991195)'
        WHEN ABS(ci.Costo_MN - 3.991134) < 0.01 THEN '✗ BUG PERSISTE (3.991134)'
        WHEN ci.Costo_MN = 0 THEN '✗ COSTO EN CERO (no se calculó)'

        -- Verificar si tiene los costos correctos
        WHEN ci.Cd_Inv = 'INV000297367' AND ABS(ci.Costo_MN - 3.102090) < 0.01 THEN '✓ CORREGIDO (3.102090)'
        WHEN ci.Cd_Inv = 'INV000297372' AND ABS(ci.Costo_MN - 2.665417) < 0.01 THEN '✓ CORREGIDO (2.665417)'

        -- Otros costos
        ELSE '? REVISAR: ' + CAST(ci.Costo_MN AS VARCHAR(20))
    END AS Estado,
    (id2.Cantidad * ci.Costo_MN) AS Total_Salida_Actual,
    CASE
        WHEN ci.Cd_Inv = 'INV000297367' THEN (id2.Cantidad * 3.102090)
        WHEN ci.Cd_Inv = 'INV000297372' THEN (id2.Cantidad * 2.665417)
    END AS Total_Esperado
FROM
    CostoInventario ci
    INNER JOIN InventarioDet2 id2 ON id2.RucE = ci.RucE AND id2.Cd_Inv = ci.Cd_Inv AND id2.Item = ci.Item
    INNER JOIN Inventario2 i2 ON i2.RucE = id2.RucE AND i2.Cd_Inv = id2.Cd_Inv
WHERE
    ci.RucE = @RucE
    AND ci.Cd_Inv IN ('INV000297367', 'INV000297372')
    AND id2.IC_ES = 'S'
ORDER BY
    i2.FechaMovimiento;

PRINT '';
PRINT '========================================================================';
PRINT 'RESULTADOS ESPERADOS:';
PRINT '========================================================================';
PRINT 'INV000297367 (29-04 08:05): Costo 3.102090 → Total 34.123 soles';
PRINT 'INV000297372 (29-04 08:50): Costo 2.665417 → Total 59.698 soles';
PRINT '';
PRINT 'Si muestra ✓ CORREGIDO en ambos, el problema está RESUELTO.';
PRINT '';
PRINT '========================================================================';
