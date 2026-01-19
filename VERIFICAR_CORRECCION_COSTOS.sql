-- =============================================
-- Verificar si la corrección funcionó
-- =============================================

USE [ERP_TEST]
GO

SET NOCOUNT ON;

PRINT '========================================================================';
PRINT 'VERIFICACIÓN: Costos después de DELETE + Recálculo';
PRINT '========================================================================';
PRINT '';

-- Verificar los costos de los movimientos problemáticos
SELECT
    i2.FechaMovimiento,
    ci.Cd_Inv,
    id2.Cd_Alm,
    id2.Cantidad AS Cantidad_Salida,
    ci.Costo_MN AS Costo_Actual,
    CASE
        -- Verificar si tiene los costos incorrectos (bug persiste)
        WHEN ABS(ci.Costo_MN - 3.991195) < 0.01 THEN '✗ BUG PERSISTE (3.991195)'
        WHEN ABS(ci.Costo_MN - 3.991134) < 0.01 THEN '✗ BUG PERSISTE (3.991134)'

        -- Verificar si tiene los costos correctos
        WHEN ci.Cd_Inv = 'INV000297367' AND ABS(ci.Costo_MN - 3.102090) < 0.01 THEN '✓ CORREGIDO (3.102090)'
        WHEN ci.Cd_Inv = 'INV000297372' AND ABS(ci.Costo_MN - 2.665417) < 0.01 THEN '✓ CORREGIDO (2.665417)'

        -- Otros costos
        ELSE '? REVISAR: ' + CAST(ci.Costo_MN AS VARCHAR(20))
    END AS Estado,
    (id2.Cantidad * ci.Costo_MN) AS Total_Salida,
    CASE
        WHEN ci.Cd_Inv = 'INV000297367' THEN (id2.Cantidad * 3.102090)
        WHEN ci.Cd_Inv = 'INV000297372' THEN (id2.Cantidad * 2.665417)
    END AS Total_Esperado
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
PRINT 'VALORES ESPERADOS:';
PRINT '========================================================================';
PRINT 'INV000297367 (29-04 08:05): 11.000 kg × 3.102090 = 34.123 soles';
PRINT 'INV000297372 (29-04 08:50): 22.397 kg × 2.665417 = 59.698 soles';
PRINT '';
PRINT 'Si el Estado muestra ✓ CORREGIDO, el problema está RESUELTO.';
PRINT 'Si muestra ✗ BUG PERSISTE, el problema de dependencia circular continúa.';
PRINT '';

-- Verificar el saldo final en el kardex
PRINT '========================================================================';
PRINT 'VERIFICACIÓN: Saldo Final en Kardex';
PRINT '========================================================================';
PRINT '';
PRINT 'Ejecutar kardex para verificar que el Saldo Total sea 0.00:';
PRINT '';
PRINT 'EXEC sp_kardexAlmacenPM';
PRINT '    @RucE = ''20102351038'',';
PRINT '    @Cd_Prod = ''PD00534'',';
PRINT '    @FechaDesde = ''2025-04-01'',';
PRINT '    @FechaHasta = ''2025-04-30'',';
PRINT '    @Cd_Alm = ''ALMACEN FABRICA(INSUMOS)''';
PRINT '';
PRINT 'Resultado esperado en última fila:';
PRINT '  Saldo Cantidad: 0.000 kg ✓';
PRINT '  Saldo Total: 0.00 soles ✓ (en lugar de -29.69)';
PRINT '';
PRINT '========================================================================';
