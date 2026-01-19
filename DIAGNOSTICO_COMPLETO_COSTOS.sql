-- =============================================
-- DIAGNÓSTICO COMPLETO: ¿Dónde están los costos?
-- =============================================

USE [ERP_TEST]
GO

SET NOCOUNT ON;

PRINT '========================================================================';
PRINT 'DIAGNÓSTICO 1: ¿Existen los movimientos en Inventario2?';
PRINT '========================================================================';
PRINT '';

SELECT
    'Inventario2' AS Tabla,
    i2.Cd_Inv,
    i2.FechaMovimiento,
    i2.IC_DocTipo,
    i2.IC_TipoMov
FROM Inventario2 i2
WHERE i2.RucE = '20102351038'
  AND i2.Cd_Inv IN ('INV000297367', 'INV000297372')
ORDER BY i2.FechaMovimiento;

PRINT '';
PRINT '========================================================================';
PRINT 'DIAGNÓSTICO 2: ¿Existen detalles en InventarioDet2?';
PRINT '========================================================================';
PRINT '';

SELECT
    'InventarioDet2' AS Tabla,
    id2.Cd_Inv,
    id2.Item,
    id2.Cd_Prod,
    id2.Cd_Alm,
    id2.IC_ES,
    id2.Cantidad
FROM InventarioDet2 id2
WHERE id2.RucE = '20102351038'
  AND id2.Cd_Inv IN ('INV000297367', 'INV000297372')
ORDER BY id2.Cd_Inv, id2.Item;

PRINT '';
PRINT '========================================================================';
PRINT 'DIAGNÓSTICO 3: ¿Existen costos en CostoInventario?';
PRINT '========================================================================';
PRINT '';

SELECT
    'CostoInventario' AS Tabla,
    ci.Cd_Inv,
    ci.Item,
    ci.Cd_Prod,
    ci.Costo_MN,
    ci.Costo_ME
FROM CostoInventario ci
WHERE ci.RucE = '20102351038'
  AND ci.Cd_Inv IN ('INV000297367', 'INV000297372')
ORDER BY ci.Cd_Inv, ci.Item;

PRINT '';
PRINT '========================================================================';
PRINT 'DIAGNÓSTICO 4: ¿Hay ALGÚN costo para PD00534 después del 28-04?';
PRINT '========================================================================';
PRINT '';

SELECT TOP 10
    'CostoInventario PD00534' AS Tabla,
    i2.FechaMovimiento,
    ci.Cd_Inv,
    ci.Item,
    ci.Cd_Prod,
    id2.IC_ES,
    id2.Cantidad,
    ci.Costo_MN
FROM CostoInventario ci
INNER JOIN InventarioDet2 id2 ON id2.RucE = ci.RucE AND id2.Cd_Inv = ci.Cd_Inv AND id2.Item = ci.Item
INNER JOIN Inventario2 i2 ON i2.RucE = id2.RucE AND i2.Cd_Inv = id2.Cd_Inv
WHERE ci.RucE = '20102351038'
  AND ci.Cd_Prod = 'PD00534'
  AND i2.FechaMovimiento >= '2025-04-28'
ORDER BY i2.FechaMovimiento;

PRINT '';
PRINT '========================================================================';
PRINT 'DIAGNÓSTICO 5: ¿Qué dice Cfg_Inv_General sobre el cálculo?';
PRINT '========================================================================';
PRINT '';

SELECT
    C_IB_VARIAS_UMP_PRINCIPAL,
    CASE
        WHEN C_IB_VARIAS_UMP_PRINCIPAL = 0 THEN 'USA: dbo.Inv_CalculoCostoPromedio3'
        WHEN C_IB_VARIAS_UMP_PRINCIPAL = 1 THEN 'USA: Cálculo inline en PEPS_2'
        ELSE 'DESCONOCIDO'
    END AS Funcion_Usada
FROM Cfg_Inv_General
WHERE RucE = '20102351038';

PRINT '';
PRINT '========================================================================';
PRINT 'DIAGNÓSTICO 6: Verificar función Inv_CalculoCostoPromedio3';
PRINT '========================================================================';
PRINT '';

-- Verificar que la función tiene el operador correcto
DECLARE @FuncionDef NVARCHAR(MAX);
DECLARE @TieneOperadorCorrecto BIT = 0;
DECLARE @TieneOperadorIncorrecto BIT = 0;

SELECT @FuncionDef = OBJECT_DEFINITION(OBJECT_ID('dbo.Inv_CalculoCostoPromedio3'));

IF @FuncionDef IS NOT NULL
BEGIN
    IF CHARINDEX('a.FechaMovimiento <= @FecMov', @FuncionDef) > 0
        SET @TieneOperadorCorrecto = 1;

    IF CHARINDEX('a.FechaMovimiento < @FecMov', @FuncionDef) > 0
        SET @TieneOperadorIncorrecto = 1;

    SELECT
        'dbo.Inv_CalculoCostoPromedio3' AS Funcion,
        CASE
            WHEN @TieneOperadorCorrecto = 1 AND @TieneOperadorIncorrecto = 0 THEN '✓ CORREGIDO (<= encontrado)'
            WHEN @TieneOperadorIncorrecto = 1 THEN '✗ BUG PRESENTE (< encontrado)'
            ELSE '? NO ENCONTRADO'
        END AS Estado,
        OBJECT_SCHEMA_NAME(OBJECT_ID('dbo.Inv_CalculoCostoPromedio3')) AS Esquema,
        (SELECT modify_date FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Inv_CalculoCostoPromedio3')) AS FechaModificacion
END
ELSE
BEGIN
    SELECT '✗ FUNCIÓN NO EXISTE' AS Estado;
END

PRINT '';
PRINT '========================================================================';
PRINT 'INTERPRETACIÓN DE RESULTADOS:';
PRINT '========================================================================';
PRINT '';
PRINT '• Si DIAGNÓSTICO 1 y 2 muestran datos → Los movimientos existen';
PRINT '• Si DIAGNÓSTICO 3 NO muestra datos → El DELETE funcionó pero recálculo NO';
PRINT '• Si DIAGNÓSTICO 4 muestra otros movimientos → El recálculo está funcionando';
PRINT '• Si DIAGNÓSTICO 5 = 0 → Usa Inv_CalculoCostoPromedio3';
PRINT '• Si DIAGNÓSTICO 6 = BUG PRESENTE → La función NO se actualizó';
PRINT '';
PRINT '========================================================================';
