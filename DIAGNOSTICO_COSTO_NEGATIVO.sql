-- =============================================
-- DIAGNÓSTICO: ¿Por qué el costo es -7367?
-- =============================================

USE [ERP_TEST]
GO

SET NOCOUNT ON;

-- Parámetros del movimiento INV000297367
DECLARE @RucE NVARCHAR(11) = '20102351038';
DECLARE @Cd_Prod CHAR(7) = 'PD00534';
DECLARE @ID_UMP INT;
DECLARE @Cd_Alm VARCHAR(20);
DECLARE @FecMov DATETIME = '2025-04-29 08:05:00';

-- Obtener ID_UMP y Cd_Alm del movimiento
SELECT TOP 1
    @ID_UMP = id2.ID_UMP,
    @Cd_Alm = id2.Cd_Alm
FROM InventarioDet2 id2
WHERE id2.RucE = @RucE
  AND id2.Cd_Inv = 'INV000297367'
  AND id2.Cd_Prod = @Cd_Prod;

PRINT '========================================================================';
PRINT 'Parámetros:';
PRINT '  Cd_Prod: ' + @Cd_Prod;
PRINT '  Cd_Alm: ' + @Cd_Alm;
PRINT '  FecMov: ' + CONVERT(VARCHAR(20), @FecMov, 120);
PRINT '========================================================================';
PRINT '';

-- Llamar a la función directamente
DECLARE @CostoFuncion DECIMAL(38,20);
SET @CostoFuncion = dbo.Inv_CalculoCostoPromedio3(@RucE, @Cd_Prod, @ID_UMP, @Cd_Alm, @FecMov, '01', NULL);

PRINT 'Resultado de Inv_CalculoCostoPromedio3: ' + CAST(@CostoFuncion AS VARCHAR(30));
PRINT '';

PRINT '========================================================================';
PRINT 'Ver datos de VW_COSTO_INVENTARIO_PROMEDIO hasta esa fecha:';
PRINT '========================================================================';
PRINT '';

-- Ver qué datos usa la función
SELECT
    a.FechaMovimiento,
    a.Cd_Inv,
    a.IC_ES,
    a.Cantidad_UM_Principal AS Cantidad,
    a.Costo_MN_UM_Principal AS CostoUnitario,
    (a.Cantidad_UM_Principal * a.Costo_MN_UM_Principal) AS ImporteTotal
FROM VW_COSTO_INVENTARIO_PROMEDIO a
WHERE a.RucE = @RucE
  AND a.Cd_Prod = @Cd_Prod
  AND a.Cd_Alm = @Cd_Alm
  AND a.FechaMovimiento <= @FecMov
ORDER BY a.FechaMovimiento DESC;

PRINT '';
PRINT '========================================================================';
PRINT 'Cálculo manual del costo promedio:';
PRINT '========================================================================';
PRINT '';

SELECT
    SUM(CASE WHEN a.IC_ES = 'E' THEN a.Cantidad_UM_Principal ELSE 0 END) AS Total_Entradas_Kg,
    SUM(CASE WHEN a.IC_ES = 'S' THEN a.Cantidad_UM_Principal ELSE 0 END) AS Total_Salidas_Kg,
    SUM(CASE WHEN a.IC_ES = 'E' THEN a.Cantidad_UM_Principal ELSE -a.Cantidad_UM_Principal END) AS Saldo_Cantidad,
    SUM(CASE WHEN a.IC_ES = 'E' THEN (a.Cantidad_UM_Principal * a.Costo_MN_UM_Principal) ELSE 0 END) AS Total_Entradas_Soles,
    SUM(CASE WHEN a.IC_ES = 'S' THEN (a.Cantidad_UM_Principal * a.Costo_MN_UM_Principal) ELSE 0 END) AS Total_Salidas_Soles,
    SUM(CASE WHEN a.IC_ES = 'E'
        THEN (a.Cantidad_UM_Principal * a.Costo_MN_UM_Principal)
        ELSE -(a.Cantidad_UM_Principal * a.Costo_MN_UM_Principal)
    END) AS Saldo_Soles
FROM VW_COSTO_INVENTARIO_PROMEDIO a
WHERE a.RucE = @RucE
  AND a.Cd_Prod = @Cd_Prod
  AND a.Cd_Alm = @Cd_Alm
  AND a.FechaMovimiento <= @FecMov;

PRINT '';
PRINT '========================================================================';
PRINT 'Si Saldo_Cantidad es muy pequeño o negativo, el costo será ABSURDO.';
PRINT '========================================================================';
