-- ============================================
-- VERIFICAR FRAGMENTACION DE INDICES
-- Reglas:
--   < 10%  = OK (no hacer nada)
--   10-30% = REORGANIZE
--   > 30%  = REBUILD
-- ============================================

USE [ERP_ECHA]
GO

SET NOCOUNT ON

PRINT '=============================================='
PRINT 'ANALISIS DE FRAGMENTACION DE INDICES'
PRINT 'Fecha: ' + CONVERT(VARCHAR, GETDATE(), 120)
PRINT '=============================================='
PRINT ''

-- ============================================
-- Analizar todas las tablas involucradas
-- ============================================

SELECT
    OBJECT_SCHEMA_NAME(ips.object_id) AS Esquema,
    OBJECT_NAME(ips.object_id) AS Tabla,
    i.name AS NombreIndice,
    i.type_desc AS TipoIndice,
    ips.index_type_desc AS DescripcionTipo,
    ips.avg_fragmentation_in_percent AS Fragmentacion_Pct,
    ips.page_count AS Paginas,
    ips.record_count AS Registros,
    CASE
        WHEN ips.avg_fragmentation_in_percent < 10 THEN 'OK - No requiere accion'
        WHEN ips.avg_fragmentation_in_percent BETWEEN 10 AND 30 THEN 'REORGANIZE'
        WHEN ips.avg_fragmentation_in_percent > 30 THEN 'REBUILD'
    END AS Accion_Recomendada
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
INNER JOIN sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE ips.object_id IN (
    OBJECT_ID('dbo.MOVIMIENTOSDETALLEVENTA'),
    OBJECT_ID('dbo.Cliente2'),
    OBJECT_ID('SPV.T_MOVIMIENTO_CAJA'),
    OBJECT_ID('dbo.ORDPEDIDO'),
    OBJECT_ID('dbo.VendedorxCliente'),
    OBJECT_ID('dbo.Voucher'),
    OBJECT_ID('dbo.PlanCtas'),
    OBJECT_ID('dbo.Proveedor2')
)
AND ips.index_id > 0  -- Excluir heaps
AND ips.page_count > 100  -- Solo indices con suficientes paginas
ORDER BY ips.avg_fragmentation_in_percent DESC

PRINT ''
PRINT '=============================================='
PRINT 'INDICES QUE REQUIEREN MANTENIMIENTO'
PRINT '=============================================='
PRINT ''

-- ============================================
-- Generar scripts de mantenimiento
-- ============================================

DECLARE @sql NVARCHAR(MAX) = ''

SELECT @sql = @sql +
    CASE
        WHEN ips.avg_fragmentation_in_percent BETWEEN 10 AND 30 THEN
            'ALTER INDEX [' + i.name + '] ON [' + OBJECT_SCHEMA_NAME(ips.object_id) + '].[' + OBJECT_NAME(ips.object_id) + '] REORGANIZE;' + CHAR(13) + CHAR(10)
        WHEN ips.avg_fragmentation_in_percent > 30 THEN
            'ALTER INDEX [' + i.name + '] ON [' + OBJECT_SCHEMA_NAME(ips.object_id) + '].[' + OBJECT_NAME(ips.object_id) + '] REBUILD WITH (ONLINE = ON);' + CHAR(13) + CHAR(10)
        ELSE ''
    END
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
INNER JOIN sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE ips.object_id IN (
    OBJECT_ID('dbo.MOVIMIENTOSDETALLEVENTA'),
    OBJECT_ID('dbo.Cliente2'),
    OBJECT_ID('SPV.T_MOVIMIENTO_CAJA'),
    OBJECT_ID('dbo.ORDPEDIDO'),
    OBJECT_ID('dbo.VendedorxCliente'),
    OBJECT_ID('dbo.Voucher'),
    OBJECT_ID('dbo.PlanCtas'),
    OBJECT_ID('dbo.Proveedor2')
)
AND ips.index_id > 0
AND ips.page_count > 100
AND ips.avg_fragmentation_in_percent >= 10
ORDER BY ips.avg_fragmentation_in_percent DESC

IF @sql = ''
    PRINT '-- No hay indices que requieran mantenimiento en estas tablas'
ELSE
BEGIN
    PRINT '-- EJECUTAR LOS SIGUIENTES COMANDOS:'
    PRINT @sql
END

PRINT ''
PRINT '=============================================='
PRINT 'ESTADISTICAS DESACTUALIZADAS'
PRINT '=============================================='
PRINT ''

-- Verificar estadisticas desactualizadas
SELECT
    OBJECT_SCHEMA_NAME(s.object_id) AS Esquema,
    OBJECT_NAME(s.object_id) AS Tabla,
    s.name AS NombreEstadistica,
    sp.last_updated AS UltimaActualizacion,
    sp.rows AS Filas,
    sp.rows_sampled AS FilasMuestreadas,
    sp.modification_counter AS ModificacionesPendientes,
    CASE
        WHEN sp.modification_counter > sp.rows * 0.20 THEN 'ACTUALIZAR ESTADISTICAS'
        ELSE 'OK'
    END AS Accion
FROM sys.stats s
CROSS APPLY sys.dm_db_stats_properties(s.object_id, s.stats_id) sp
WHERE s.object_id IN (
    OBJECT_ID('dbo.MOVIMIENTOSDETALLEVENTA'),
    OBJECT_ID('dbo.Cliente2'),
    OBJECT_ID('SPV.T_MOVIMIENTO_CAJA'),
    OBJECT_ID('dbo.ORDPEDIDO'),
    OBJECT_ID('dbo.VendedorxCliente')
)
AND sp.modification_counter > 0
ORDER BY sp.modification_counter DESC

PRINT ''
PRINT '=============================================='
PRINT 'SCRIPTS PARA ACTUALIZAR ESTADISTICAS'
PRINT '=============================================='
PRINT ''

DECLARE @sqlStats NVARCHAR(MAX) = ''

SELECT @sqlStats = @sqlStats +
    'UPDATE STATISTICS [' + OBJECT_SCHEMA_NAME(s.object_id) + '].[' + OBJECT_NAME(s.object_id) + '] [' + s.name + '] WITH FULLSCAN;' + CHAR(13) + CHAR(10)
FROM sys.stats s
CROSS APPLY sys.dm_db_stats_properties(s.object_id, s.stats_id) sp
WHERE s.object_id IN (
    OBJECT_ID('dbo.MOVIMIENTOSDETALLEVENTA'),
    OBJECT_ID('dbo.Cliente2'),
    OBJECT_ID('SPV.T_MOVIMIENTO_CAJA'),
    OBJECT_ID('dbo.ORDPEDIDO'),
    OBJECT_ID('dbo.VendedorxCliente')
)
AND sp.modification_counter > sp.rows * 0.20

IF @sqlStats = ''
    PRINT '-- No hay estadisticas que requieran actualizacion urgente'
ELSE
BEGIN
    PRINT '-- EJECUTAR PARA ACTUALIZAR ESTADISTICAS:'
    PRINT @sqlStats
END

GO
