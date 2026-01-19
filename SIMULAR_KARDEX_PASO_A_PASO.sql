-- =============================================
-- SIMULACIÓN: Reproducir el kardex paso a paso
-- =============================================
-- Este script simula lo que hace el SP de recálculo
-- para ver exactamente dónde se distorsiona el costo
-- =============================================

USE [ERP_TEST]
GO

SET NOCOUNT ON;

-- Parámetros
DECLARE @RucE VARCHAR(11) = '20102351038';
DECLARE @Cd_Prod CHAR(7) = 'PD00534';
DECLARE @Cd_Alm VARCHAR(20) = 'ALMACEN FABRICA(INSUMOS)';
DECLARE @FechaDesde DATETIME = '2025-04-01';
DECLARE @FechaHasta DATETIME = '2025-04-30';

-- Crear tabla temporal para simular el kardex
IF OBJECT_ID('tempdb..#KardexSimulado') IS NOT NULL
    DROP TABLE #KardexSimulado;

CREATE TABLE #KardexSimulado (
    Fila INT IDENTITY(1,1),
    FechaMovimiento DATETIME,
    Cd_Inv CHAR(12),
    Item INT,
    IC_ES CHAR(1),
    Cantidad DECIMAL(20,6),
    Costo_Unitario_Actual DECIMAL(20,6),  -- Costo actual en CostoInventario
    Costo_Unitario_Vista DECIMAL(20,6),   -- Costo de VW_COSTO_INVENTARIO_PROMEDIO
    Importe DECIMAL(20,6),
    Saldo_Cantidad DECIMAL(20,6),
    Saldo_Importe DECIMAL(20,6),
    Costo_Promedio_Calculado DECIMAL(20,6)
);

-- Insertar movimientos ordenados por fecha
INSERT INTO #KardexSimulado (
    FechaMovimiento, Cd_Inv, Item, IC_ES, Cantidad,
    Costo_Unitario_Actual, Costo_Unitario_Vista
)
SELECT
    i2.FechaMovimiento,
    id2.Cd_Inv,
    id2.Item,
    id2.IC_ES,
    id2.Cantidad,
    ci.Costo_MN AS Costo_Actual,
    v.Costo_MN_UM_Principal AS Costo_Vista
FROM
    InventarioDet2 id2
    INNER JOIN Inventario2 i2 ON i2.RucE = id2.RucE AND i2.Cd_Inv = id2.Cd_Inv
    LEFT JOIN CostoInventario ci ON ci.RucE = id2.RucE AND ci.Cd_Inv = id2.Cd_Inv AND ci.Item = id2.Item
    LEFT JOIN VW_COSTO_INVENTARIO_PROMEDIO v ON v.RucE = id2.RucE AND v.Cd_Inv = id2.Cd_Inv AND v.Correlativo = ci.Correlativo
WHERE
    id2.RucE = @RucE
    AND id2.Cd_Prod = @Cd_Prod
    AND id2.Cd_Alm = @Cd_Alm
    AND i2.FechaMovimiento >= @FechaDesde
    AND i2.FechaMovimiento <= @FechaHasta
ORDER BY
    i2.FechaMovimiento, id2.Item;

-- Mostrar resultado
SELECT
    Fila,
    CONVERT(VARCHAR(16), FechaMovimiento, 120) AS Fecha,
    Cd_Inv,
    Item,
    IC_ES,
    Cantidad,
    Costo_Unitario_Actual,
    Costo_Unitario_Vista,
    CASE
        WHEN Costo_Unitario_Actual IS NULL THEN 'NULL'
        WHEN ABS(Costo_Unitario_Actual) > 100 THEN '✗ ABSURDO'
        WHEN Costo_Unitario_Actual < 0 THEN '✗ NEGATIVO'
        ELSE '✓ OK'
    END AS Estado_Costo
FROM #KardexSimulado
ORDER BY Fila;

-- Limpiar
DROP TABLE #KardexSimulado;
