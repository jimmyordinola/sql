-- =============================================
-- Verificación rápida después del recálculo desde 01-01-2025
-- =============================================

USE [ERP_TEST]
GO

SET NOCOUNT ON;

PRINT '========================================================================';
PRINT 'VERIFICACIÓN: Costos de INV000297367 e INV000297372';
PRINT '========================================================================';
PRINT '';

-- Verificar si los costos se crearon y si son correctos
SELECT
    i2.FechaMovimiento,
    ci.Cd_Inv,
    id2.Cantidad AS Kg_Salida,
    ci.Costo_MN AS Costo_Unitario,
    (id2.Cantidad * ci.Costo_MN) AS Total_Salida,
    CASE
        -- Verificar si tiene costo cero (no se calculó)
        WHEN ci.Costo_MN = 0 OR ci.Costo_MN IS NULL THEN '✗ NO CALCULADO (costo 0 o NULL)'

        -- Verificar si tiene los costos incorrectos (bug persiste)
        WHEN ABS(ci.Costo_MN - 3.991195) < 0.01 THEN '✗ BUG PERSISTE (3.991195)'
        WHEN ABS(ci.Costo_MN - 3.991134) < 0.01 THEN '✗ BUG PERSISTE (3.991134)'

        -- Verificar si tiene los costos correctos
        WHEN ci.Cd_Inv = 'INV000297367' AND ABS(ci.Costo_MN - 3.102090) < 0.01 THEN '✓ CORREGIDO (3.102)'
        WHEN ci.Cd_Inv = 'INV000297372' AND ABS(ci.Costo_MN - 2.665417) < 0.01 THEN '✓ CORREGIDO (2.665)'

        -- Revisar cualquier otro costo
        ELSE '? REVISAR: ' + CAST(ci.Costo_MN AS VARCHAR(20))
    END AS Estado,
    CASE
        WHEN ci.Cd_Inv = 'INV000297367' THEN 34.123  -- 11.000 × 3.102090
        WHEN ci.Cd_Inv = 'INV000297372' THEN 59.698  -- 22.397 × 2.665417
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
PRINT 'INTERPRETACIÓN:';
PRINT '========================================================================';
PRINT '';
PRINT '✓ CORREGIDO       → El bug se solucionó, los costos son correctos';
PRINT '✗ BUG PERSISTE    → La función Inv_CalculoCostoPromedio3 NO se actualizó';
PRINT '✗ NO CALCULADO    → El recálculo no procesó estos movimientos';
PRINT '? REVISAR         → Costo diferente al esperado (verificar manualmente)';
PRINT '';
PRINT '========================================================================';
PRINT 'VERIFICAR FUNCIÓN: ¿Tiene el operador corregido?';
PRINT '========================================================================';
PRINT '';

-- Verificar que la función Inv_CalculoCostoPromedio3 tenga el fix
DECLARE @FuncionDef NVARCHAR(MAX);
DECLARE @TieneFixCorrecto BIT = 0;
DECLARE @TieneBug BIT = 0;

SELECT @FuncionDef = OBJECT_DEFINITION(OBJECT_ID('dbo.Inv_CalculoCostoPromedio3'));

IF @FuncionDef IS NOT NULL
BEGIN
    IF CHARINDEX('a.FechaMovimiento <= @FecMov', @FuncionDef) > 0
        SET @TieneFixCorrecto = 1;

    IF CHARINDEX('a.FechaMovimiento < @FecMov', @FuncionDef) > 0
        SET @TieneBug = 1;

    SELECT
        'dbo.Inv_CalculoCostoPromedio3' AS Funcion,
        CASE
            WHEN @TieneFixCorrecto = 1 AND @TieneBug = 0 THEN '✓ CORREGIDO (usa <=)'
            WHEN @TieneBug = 1 THEN '✗ BUG PRESENTE (usa <)'
            ELSE '? OPERADOR NO ENCONTRADO'
        END AS Estado_Funcion,
        (SELECT modify_date FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Inv_CalculoCostoPromedio3')) AS Ultima_Modificacion;
END
ELSE
BEGIN
    SELECT '✗ FUNCIÓN NO EXISTE' AS Estado_Funcion;
END

PRINT '';
PRINT '========================================================================';
PRINT 'SI EL BUG PERSISTE:';
PRINT '========================================================================';
PRINT '';
PRINT '1. Verificar que el archivo Inv_CalculoCostoPromedio3.sql tenga <= en línea 60';
PRINT '2. Ejecutar ese script en SQL Server para actualizar la función';
PRINT '3. Limpiar caché: DBCC FREEPROCCACHE';
PRINT '4. Volver a recalcular';
PRINT '';
PRINT '========================================================================';
