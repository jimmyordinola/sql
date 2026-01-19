-- =============================================
-- Ver Items en InventarioDet2
-- =============================================

USE [ERP_TEST]
GO

SELECT
    'InventarioDet2' AS Fuente,
    i2.FechaMovimiento,
    id2.Cd_Inv,
    id2.Item,
    id2.Cd_Prod,
    id2.IC_ES,
    id2.Cantidad,
    id2.Cd_Alm
FROM
    InventarioDet2 id2
    INNER JOIN Inventario2 i2 ON i2.RucE = id2.RucE AND i2.Cd_Inv = id2.Cd_Inv
WHERE
    id2.RucE = '20102351038'
    AND id2.Cd_Inv IN ('INV000297367', 'INV000297372')
ORDER BY
    i2.FechaMovimiento, id2.Item;

PRINT '';
PRINT '========================================================================';

SELECT
    'Resumen' AS Info,
    id2.Cd_Inv,
    COUNT(*) AS Total_Items,
    SUM(CASE WHEN id2.IC_ES = 'E' THEN 1 ELSE 0 END) AS Items_Entrada,
    SUM(CASE WHEN id2.IC_ES = 'S' THEN 1 ELSE 0 END) AS Items_Salida
FROM
    InventarioDet2 id2
WHERE
    id2.RucE = '20102351038'
    AND id2.Cd_Inv IN ('INV000297367', 'INV000297372')
GROUP BY
    id2.Cd_Inv;
