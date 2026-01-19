-- =============================================
-- Ver costos actuales de INV000297367 e INV000297372
-- =============================================

USE [ERP_TEST]
GO

SELECT
    i2.FechaMovimiento,
    ci.Cd_Inv,
    ci.Item,
    ci.Correlativo,
    id2.IC_ES,
    id2.Cantidad,
    ci.Costo_MN,
    ci.Cantidad AS Cantidad_CI
FROM
    CostoInventario ci
    INNER JOIN InventarioDet2 id2 ON id2.RucE = ci.RucE AND ci.Cd_Inv = id2.Cd_Inv AND ci.Item = id2.Item
    INNER JOIN Inventario2 i2 ON i2.RucE = id2.RucE AND i2.Cd_Inv = id2.Cd_Inv
WHERE
    ci.RucE = '20102351038'
    AND ci.Cd_Inv IN ('INV000297367', 'INV000297372')
ORDER BY
    i2.FechaMovimiento, ci.Item;
