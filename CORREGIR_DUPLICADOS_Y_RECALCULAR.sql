-- =============================================
-- SOLUCIÓN CORRECTA: Eliminar SOLO duplicados y recalcular
-- =============================================
-- El SP hace INNER JOIN con CostoInventario y solo UPDATE
-- Por lo tanto: NO eliminar todos, solo los DUPLICADOS
-- Dejar UN registro por cada (Cd_Inv, Item)
-- =============================================

USE [ERP_TEST]
GO

SET NOCOUNT ON;

PRINT '========================================================================';
PRINT 'DIAGNÓSTICO: Duplicados actuales';
PRINT '========================================================================';
PRINT '';

-- Mostrar duplicados
SELECT
    ci.Cd_Inv,
    ci.Item,
    COUNT(*) AS Cantidad_Duplicados
FROM
    CostoInventario ci
WHERE
    ci.RucE = '20102351038'
    AND ci.Cd_Inv IN ('INV000297367', 'INV000297372')
GROUP BY
    ci.Cd_Inv, ci.Item
HAVING COUNT(*) > 1
ORDER BY
    ci.Cd_Inv, ci.Item;

PRINT '';
PRINT '========================================================================';
PRINT 'PASO 1: Eliminar duplicados (dejar solo 1 por cada Cd_Inv + Item)';
PRINT '========================================================================';
PRINT '';

-- Eliminar duplicados usando CTE con ROW_NUMBER
-- Mantener el que tiene el Correlativo más bajo (el original)
;WITH DuplicadosCTE AS (
    SELECT
        RucE,
        Cd_Inv,
        Item,
        Correlativo,
        ROW_NUMBER() OVER (PARTITION BY RucE, Cd_Inv, Item ORDER BY Correlativo) AS rn
    FROM
        CostoInventario
    WHERE
        RucE = '20102351038'
        AND Cd_Inv IN ('INV000297367', 'INV000297372')
)
DELETE FROM CostoInventario
WHERE Correlativo IN (
    SELECT Correlativo FROM DuplicadosCTE WHERE rn > 1
);

DECLARE @EliminadosDuplicados INT = @@ROWCOUNT;
PRINT '✓ Duplicados eliminados: ' + CAST(@EliminadosDuplicados AS VARCHAR(10));
PRINT '';

-- Verificar que ya no hay duplicados
SELECT
    'Después de eliminar duplicados' AS Info,
    ci.Cd_Inv,
    ci.Item,
    COUNT(*) AS Cantidad
FROM
    CostoInventario ci
WHERE
    ci.RucE = '20102351038'
    AND ci.Cd_Inv IN ('INV000297367', 'INV000297372')
GROUP BY
    ci.Cd_Inv, ci.Item
ORDER BY
    ci.Cd_Inv, ci.Item;

PRINT '';
PRINT '========================================================================';
PRINT 'PASO 2: Resetear costos a NULL para forzar recálculo';
PRINT '========================================================================';
PRINT '';

UPDATE CostoInventario
SET
    Costo_MN = NULL,
    Costo_ME = NULL
WHERE
    RucE = '20102351038'
    AND Cd_Inv IN ('INV000297367', 'INV000297372');

DECLARE @Reseteados INT = @@ROWCOUNT;
PRINT '✓ Registros reseteados a NULL: ' + CAST(@Reseteados AS VARCHAR(10));
PRINT '';

PRINT '========================================================================';
PRINT 'PASO 3: Limpiar caché y recalcular';
PRINT '========================================================================';
PRINT '';

-- Limpiar caché de los SPs relacionados
DECLARE @plan_handle VARBINARY(64);
DECLARE plan_cursor CURSOR FOR
SELECT cp.plan_handle
FROM sys.dm_exec_cached_plans cp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
WHERE st.text LIKE '%USP_COSTO_INVENTARIO_RECALCULAR%'
   OR st.text LIKE '%Inv_CalculoCostoPromedio3%'
   OR st.text LIKE '%USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS%';

OPEN plan_cursor;
FETCH NEXT FROM plan_cursor INTO @plan_handle;
WHILE @@FETCH_STATUS = 0
BEGIN
    DBCC FREEPROCCACHE(@plan_handle);
    FETCH NEXT FROM plan_cursor INTO @plan_handle;
END
CLOSE plan_cursor;
DEALLOCATE plan_cursor;

PRINT '✓ Caché limpiado';
PRINT '';

-- Recalcular
PRINT 'Recalculando desde 01-04-2025...';
PRINT '';

EXEC inventario.USP_COSTO_INVENTARIO_RECALCULAR_INDIVIDUAL_3
    @RucE = '20102351038',
    @Cd_Prod = 'PD00534',
    @FechaMovimiento = '2025-04-01',
    @P_USUARIO_RECALCULO = 'PROJECT01',
    @P_FECHA_RECALCULO = GETDATE();

PRINT '';
PRINT '✓ Recálculo completado';
PRINT '';

PRINT '========================================================================';
PRINT 'PASO 4: Verificar costos finales';
PRINT '========================================================================';
PRINT '';

SELECT
    i2.FechaMovimiento,
    ci.Cd_Inv,
    ci.Item,
    id2.Cd_Prod,
    id2.IC_ES,
    id2.Cantidad,
    ci.Costo_MN,
    CASE
        WHEN id2.Cd_Prod != 'PD00534' THEN '-'
        WHEN id2.IC_ES != 'S' THEN '-'
        WHEN ci.Costo_MN IS NULL THEN '✗ NULL'
        WHEN ABS(ci.Costo_MN - 3.102090) < 0.5 THEN '✓ OK (~3.10)'
        WHEN ABS(ci.Costo_MN - 2.665417) < 0.5 THEN '✓ OK (~2.67)'
        WHEN ci.Costo_MN > 10 THEN '✗ MUY ALTO'
        ELSE '? ' + CAST(ROUND(ci.Costo_MN, 2) AS VARCHAR(10))
    END AS Estado
FROM
    CostoInventario ci
    INNER JOIN InventarioDet2 id2 ON id2.RucE = ci.RucE AND ci.Cd_Inv = id2.Cd_Inv AND ci.Item = id2.Item
    INNER JOIN Inventario2 i2 ON i2.RucE = id2.RucE AND i2.Cd_Inv = id2.Cd_Inv
WHERE
    ci.RucE = '20102351038'
    AND ci.Cd_Inv IN ('INV000297367', 'INV000297372')
ORDER BY
    i2.FechaMovimiento, ci.Item;

PRINT '';
PRINT '========================================================================';
PRINT 'Si el costo de PD00534 muestra ✓ OK, el problema está RESUELTO.';
PRINT 'Si muestra ✗ MUY ALTO o ✗ NULL, hay otro problema.';
PRINT '========================================================================';
