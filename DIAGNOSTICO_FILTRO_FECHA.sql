-- =============================================
-- DIAGNOSTICAR POR QUÉ EL FILTRO DE FECHA NO FUNCIONA
-- =============================================
USE [ERP_ECHA]
GO

DECLARE
    @RucE VARCHAR(11) = '20102351038',
    @Cd_Prod VARCHAR(7) = 'PD00534',
    @P_FECHA_MOVIMIENTO DATETIME = '2025-04-01 00:00:00',
    @P_FECHA_HASTA DATETIME = '2025-05-01 00:00:00';

PRINT '========================================';
PRINT 'DIAGNÓSTICO DE FILTRO DE FECHA';
PRINT '========================================';
PRINT '';

-- 1. Ver todas las fechas sin filtro
PRINT 'PASO 1: Fechas de movimientos SIN filtro de fecha hasta';
PRINT '';

SELECT
    i2.FechaMovimiento,
    i2.Cd_Inv,
    id2.IC_ES,
    id2.Cd_Alm,
    id2.Cantidad,
    CASE
        WHEN i2.FechaMovimiento <= @P_FECHA_HASTA THEN 'DENTRO RANGO'
        ELSE 'FUERA RANGO'
    END AS Estado_Filtro
FROM
    Inventario2 i2
    INNER JOIN InventarioDet2 id2 ON id2.RucE = i2.RucE AND id2.Cd_Inv = i2.Cd_Inv
    INNER JOIN CostoInventario ci2 ON ci2.RucE = id2.RucE AND ci2.Cd_Inv = id2.Cd_Inv AND ci2.Item = id2.Item
WHERE
    i2.RucE = @RucE
    AND id2.Cd_Prod = @Cd_Prod
    AND ISNULL(ci2.IC_TipoCostoInventario,'M') = 'M'
    AND i2.FechaMovimiento >= @P_FECHA_MOVIMIENTO
ORDER BY
    i2.FechaMovimiento;

DECLARE @TotalSinFiltro INT = @@ROWCOUNT;

PRINT '';
PRINT 'Total movimientos SIN filtro de fecha hasta: ' + CAST(@TotalSinFiltro AS VARCHAR(10));
PRINT '';

-- 2. Ver con filtro de fecha hasta
PRINT '========================================';
PRINT 'PASO 2: Fechas de movimientos CON filtro <= 2025-05-01';
PRINT '';

SELECT
    i2.FechaMovimiento,
    i2.Cd_Inv,
    id2.IC_ES,
    id2.Cd_Alm,
    id2.Cantidad
FROM
    Inventario2 i2
    INNER JOIN InventarioDet2 id2 ON id2.RucE = i2.RucE AND id2.Cd_Inv = i2.Cd_Inv
    INNER JOIN CostoInventario ci2 ON ci2.RucE = id2.RucE AND ci2.Cd_Inv = id2.Cd_Inv AND ci2.Item = id2.Item
WHERE
    i2.RucE = @RucE
    AND id2.Cd_Prod = @Cd_Prod
    AND ISNULL(ci2.IC_TipoCostoInventario,'M') = 'M'
    AND i2.FechaMovimiento >= @P_FECHA_MOVIMIENTO
    AND i2.FechaMovimiento <= @P_FECHA_HASTA  -- FILTRO QUE BLOQUEA
ORDER BY
    i2.FechaMovimiento;

DECLARE @TotalConFiltro INT = @@ROWCOUNT;

PRINT '';
PRINT 'Total movimientos CON filtro de fecha hasta: ' + CAST(@TotalConFiltro AS VARCHAR(10));
PRINT '';

-- 3. Análisis
PRINT '========================================';
PRINT 'ANÁLISIS';
PRINT '========================================';
PRINT '';

IF @TotalConFiltro = 0 AND @TotalSinFiltro > 0
BEGIN
    PRINT 'PROBLEMA DETECTADO:';
    PRINT '  - Sin filtro: ' + CAST(@TotalSinFiltro AS VARCHAR(10)) + ' movimientos';
    PRINT '  - Con filtro: 0 movimientos';
    PRINT '';
    PRINT 'CAUSA PROBABLE:';
    PRINT '  Todas las fechas son POSTERIORES a 2025-05-01';
    PRINT '';

    -- Ver la fecha mínima y máxima
    SELECT
        'Rango de fechas real' AS Info,
        MIN(i2.FechaMovimiento) AS FechaMinima,
        MAX(i2.FechaMovimiento) AS FechaMaxima
    FROM
        Inventario2 i2
        INNER JOIN InventarioDet2 id2 ON id2.RucE = i2.RucE AND id2.Cd_Inv = i2.Cd_Inv
        INNER JOIN CostoInventario ci2 ON ci2.RucE = id2.RucE AND ci2.Cd_Inv = id2.Cd_Inv AND ci2.Item = id2.Item
    WHERE
        i2.RucE = @RucE
        AND id2.Cd_Prod = @Cd_Prod
        AND ISNULL(ci2.IC_TipoCostoInventario,'M') = 'M'
        AND i2.FechaMovimiento >= @P_FECHA_MOVIMIENTO;

    PRINT '';
    PRINT 'SOLUCIÓN:';
    PRINT '  Cambiar @P_FECHA_HASTA a una fecha POSTERIOR';
    PRINT '  Por ejemplo: ''2025-06-01'' o ''2025-12-31''';
END
ELSE IF @TotalConFiltro = @TotalSinFiltro
BEGIN
    PRINT 'CORRECTO: El filtro funciona bien';
    PRINT '  Total movimientos: ' + CAST(@TotalConFiltro AS VARCHAR(10));
END
ELSE
BEGIN
    PRINT 'FILTRO PARCIAL:';
    PRINT '  - Sin filtro: ' + CAST(@TotalSinFiltro AS VARCHAR(10)) + ' movimientos';
    PRINT '  - Con filtro: ' + CAST(@TotalConFiltro AS VARCHAR(10)) + ' movimientos';
    PRINT '  - Bloqueados: ' + CAST(@TotalSinFiltro - @TotalConFiltro AS VARCHAR(10)) + ' movimientos';
END

PRINT '';
PRINT '========================================';
