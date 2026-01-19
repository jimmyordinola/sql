-- =====================================================
-- JOB DE MANTENIMIENTO AUTOMATICO - ERP_ECHA
-- Solo desfragmentacion y estadisticas (seguro)
-- Ejecuta cada domingo a las 2:00 AM
-- =====================================================

USE [msdb]
GO

-- =====================================================
-- PASO 1: Eliminar job si ya existe
-- =====================================================
IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs WHERE name = N'MANTENIMIENTO_ERP_ECHA')
BEGIN
    EXEC msdb.dbo.sp_delete_job @job_name = N'MANTENIMIENTO_ERP_ECHA', @delete_unused_schedule = 1
    PRINT 'Job anterior eliminado'
END
GO

-- =====================================================
-- PASO 2: Crear el Job
-- =====================================================
DECLARE @jobId BINARY(16)

EXEC msdb.dbo.sp_add_job
    @job_name = N'MANTENIMIENTO_ERP_ECHA',
    @enabled = 1,
    @description = N'Mantenimiento automatico seguro: desfragmentacion de indices y actualizacion de estadisticas. NO elimina ni crea indices.',
    @category_name = N'Database Maintenance',
    @owner_login_name = N'sa',
    @job_id = @jobId OUTPUT

PRINT 'Job creado: MANTENIMIENTO_ERP_ECHA'
GO

-- =====================================================
-- PASO 3: Step 1 - Desfragmentar indices (REORGANIZE o REBUILD)
-- REORGANIZE: <30% fragmentacion (online, rapido)
-- REBUILD: >30% fragmentacion (mas completo)
-- =====================================================
EXEC msdb.dbo.sp_add_jobstep
    @job_name = N'MANTENIMIENTO_ERP_ECHA',
    @step_name = N'Desfragmentar indices',
    @step_id = 1,
    @subsystem = N'TSQL',
    @command = N'
USE [ERP_ECHA]
SET NOCOUNT ON

DECLARE @tableName NVARCHAR(255)
DECLARE @schemaName NVARCHAR(255)
DECLARE @indexName NVARCHAR(255)
DECLARE @fragmentation FLOAT
DECLARE @pageCount INT
DECLARE @sql NVARCHAR(MAX)
DECLARE @startTime DATETIME = GETDATE()
DECLARE @indexCount INT = 0

PRINT ''===== INICIO DESFRAGMENTACION: '' + CONVERT(VARCHAR, @startTime, 120) + '' =====''
PRINT ''''

-- Cursor para indices fragmentados
DECLARE index_cursor CURSOR FOR
SELECT
    SCHEMA_NAME(t.schema_id) AS SchemaName,
    OBJECT_NAME(ips.object_id) AS TableName,
    i.name AS IndexName,
    ips.avg_fragmentation_in_percent,
    ips.page_count
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, ''LIMITED'') ips
INNER JOIN sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
INNER JOIN sys.tables t ON ips.object_id = t.object_id
WHERE ips.avg_fragmentation_in_percent > 10  -- Solo indices con >10% fragmentacion
    AND ips.page_count > 500                  -- Solo indices con >500 paginas
    AND i.name IS NOT NULL                    -- Excluir HEAPs
    AND i.type > 0                            -- Solo indices (no heaps)
ORDER BY ips.avg_fragmentation_in_percent DESC

OPEN index_cursor
FETCH NEXT FROM index_cursor INTO @schemaName, @tableName, @indexName, @fragmentation, @pageCount

WHILE @@FETCH_STATUS = 0
BEGIN
    BEGIN TRY
        IF @fragmentation > 30
        BEGIN
            -- REBUILD para fragmentacion alta (>30%)
            SET @sql = ''ALTER INDEX ['' + @indexName + ''] ON ['' + @schemaName + ''].['' + @tableName + ''] REBUILD WITH (ONLINE = OFF, SORT_IN_TEMPDB = ON)''
            EXEC sp_executesql @sql
            PRINT ''[REBUILD] '' + @schemaName + ''.'' + @tableName + ''.'' + @indexName + '' ('' + CAST(CAST(@fragmentation AS DECIMAL(5,1)) AS VARCHAR) + ''% -> 0%)''
        END
        ELSE IF @fragmentation > 10
        BEGIN
            -- REORGANIZE para fragmentacion media (10-30%)
            SET @sql = ''ALTER INDEX ['' + @indexName + ''] ON ['' + @schemaName + ''].['' + @tableName + ''] REORGANIZE''
            EXEC sp_executesql @sql
            PRINT ''[REORGANIZE] '' + @schemaName + ''.'' + @tableName + ''.'' + @indexName + '' ('' + CAST(CAST(@fragmentation AS DECIMAL(5,1)) AS VARCHAR) + ''%)''
        END
        SET @indexCount = @indexCount + 1
    END TRY
    BEGIN CATCH
        PRINT ''[ERROR] '' + @indexName + '': '' + ERROR_MESSAGE()
    END CATCH

    FETCH NEXT FROM index_cursor INTO @schemaName, @tableName, @indexName, @fragmentation, @pageCount
END

CLOSE index_cursor
DEALLOCATE index_cursor

-- Rebuild HEAPs fragmentados (tablas sin clustered index)
PRINT ''''
PRINT ''-- Verificando HEAPs --''

DECLARE heap_cursor CURSOR FOR
SELECT
    SCHEMA_NAME(t.schema_id) AS SchemaName,
    t.name AS TableName,
    ips.avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, ''LIMITED'') ips
INNER JOIN sys.tables t ON ips.object_id = t.object_id
WHERE ips.index_id = 0  -- HEAP
    AND ips.avg_fragmentation_in_percent > 30
    AND ips.page_count > 500

OPEN heap_cursor
FETCH NEXT FROM heap_cursor INTO @schemaName, @tableName, @fragmentation

WHILE @@FETCH_STATUS = 0
BEGIN
    BEGIN TRY
        SET @sql = ''ALTER TABLE ['' + @schemaName + ''].['' + @tableName + ''] REBUILD''
        EXEC sp_executesql @sql
        PRINT ''[HEAP REBUILD] '' + @schemaName + ''.'' + @tableName + '' ('' + CAST(CAST(@fragmentation AS DECIMAL(5,1)) AS VARCHAR) + ''%)''
        SET @indexCount = @indexCount + 1
    END TRY
    BEGIN CATCH
        PRINT ''[ERROR HEAP] '' + @tableName + '': '' + ERROR_MESSAGE()
    END CATCH

    FETCH NEXT FROM heap_cursor INTO @schemaName, @tableName, @fragmentation
END

CLOSE heap_cursor
DEALLOCATE heap_cursor

PRINT ''''
PRINT ''Indices procesados: '' + CAST(@indexCount AS VARCHAR)
PRINT ''Duracion: '' + CAST(DATEDIFF(SECOND, @startTime, GETDATE()) AS VARCHAR) + '' segundos''
',
    @database_name = N'ERP_ECHA',
    @on_success_action = 3,  -- Go to next step
    @on_fail_action = 3      -- Continue on failure
GO

-- =====================================================
-- PASO 4: Step 2 - Actualizar estadisticas
-- =====================================================
EXEC msdb.dbo.sp_add_jobstep
    @job_name = N'MANTENIMIENTO_ERP_ECHA',
    @step_name = N'Actualizar estadisticas',
    @step_id = 2,
    @subsystem = N'TSQL',
    @command = N'
USE [ERP_ECHA]
SET NOCOUNT ON

DECLARE @startTime DATETIME = GETDATE()
DECLARE @tableName NVARCHAR(255)
DECLARE @schemaName NVARCHAR(255)
DECLARE @rowCount BIGINT
DECLARE @sql NVARCHAR(MAX)
DECLARE @tableCount INT = 0

PRINT ''===== INICIO ACTUALIZACION ESTADISTICAS: '' + CONVERT(VARCHAR, @startTime, 120) + '' =====''
PRINT ''''

-- Actualizar estadisticas de tablas con mas de 1000 filas
DECLARE stats_cursor CURSOR FOR
SELECT
    SCHEMA_NAME(t.schema_id) AS SchemaName,
    t.name AS TableName,
    SUM(p.rows) AS RowCount
FROM sys.tables t
INNER JOIN sys.partitions p ON t.object_id = p.object_id
WHERE p.index_id IN (0, 1)  -- HEAP o Clustered
GROUP BY t.schema_id, t.name
HAVING SUM(p.rows) > 1000
ORDER BY SUM(p.rows) DESC

OPEN stats_cursor
FETCH NEXT FROM stats_cursor INTO @schemaName, @tableName, @rowCount

WHILE @@FETCH_STATUS = 0
BEGIN
    BEGIN TRY
        -- FULLSCAN para tablas pequeñas (<100K), SAMPLE para grandes
        IF @rowCount < 100000
            SET @sql = ''UPDATE STATISTICS ['' + @schemaName + ''].['' + @tableName + ''] WITH FULLSCAN''
        ELSE IF @rowCount < 1000000
            SET @sql = ''UPDATE STATISTICS ['' + @schemaName + ''].['' + @tableName + ''] WITH SAMPLE 50 PERCENT''
        ELSE
            SET @sql = ''UPDATE STATISTICS ['' + @schemaName + ''].['' + @tableName + ''] WITH SAMPLE 25 PERCENT''

        EXEC sp_executesql @sql
        PRINT ''[STATS] '' + @schemaName + ''.'' + @tableName + '' ('' + FORMAT(@rowCount, ''N0'') + '' filas)''
        SET @tableCount = @tableCount + 1
    END TRY
    BEGIN CATCH
        PRINT ''[ERROR] '' + @tableName + '': '' + ERROR_MESSAGE()
    END CATCH

    FETCH NEXT FROM stats_cursor INTO @schemaName, @tableName, @rowCount
END

CLOSE stats_cursor
DEALLOCATE stats_cursor

PRINT ''''
PRINT ''Tablas procesadas: '' + CAST(@tableCount AS VARCHAR)
PRINT ''Duracion: '' + CAST(DATEDIFF(SECOND, @startTime, GETDATE()) AS VARCHAR) + '' segundos''
',
    @database_name = N'ERP_ECHA',
    @on_success_action = 3,
    @on_fail_action = 3
GO

-- =====================================================
-- PASO 5: Step 3 - Limpiar cache de planes obsoletos
-- =====================================================
EXEC msdb.dbo.sp_add_jobstep
    @job_name = N'MANTENIMIENTO_ERP_ECHA',
    @step_name = N'Limpiar cache de planes',
    @step_id = 3,
    @subsystem = N'TSQL',
    @command = N'
USE [ERP_ECHA]

PRINT ''===== LIMPIEZA DE CACHE =====''

-- Limpiar planes de ejecucion para que SQL Server regenere con estadisticas nuevas
-- Esto es seguro y recomendado despues de actualizar estadisticas
DBCC FREEPROCCACHE WITH NO_INFOMSGS
PRINT ''Cache de planes limpiado''

-- Limpiar buffers (opcional, comentado por defecto)
-- DBCC DROPCLEANBUFFERS WITH NO_INFOMSGS
-- PRINT ''Buffers limpiados''

PRINT ''''
PRINT ''===== MANTENIMIENTO COMPLETADO: '' + CONVERT(VARCHAR, GETDATE(), 120) + '' =====''
',
    @database_name = N'ERP_ECHA',
    @on_success_action = 1,  -- Quit with success
    @on_fail_action = 2      -- Quit with failure
GO

-- =====================================================
-- PASO 6: Crear Schedule - Domingo a las 2:00 AM
-- =====================================================
EXEC msdb.dbo.sp_add_jobschedule
    @job_name = N'MANTENIMIENTO_ERP_ECHA',
    @name = N'Semanal_Domingo_2AM',
    @enabled = 1,
    @freq_type = 8,              -- Semanal
    @freq_interval = 1,          -- Domingo (1=Domingo)
    @freq_recurrence_factor = 1, -- Cada semana
    @active_start_time = 020000  -- 02:00:00 AM

PRINT 'Schedule creado: Domingos a las 2:00 AM'
GO

-- =====================================================
-- PASO 7: Asignar el Job al servidor local
-- =====================================================
EXEC msdb.dbo.sp_add_jobserver
    @job_name = N'MANTENIMIENTO_ERP_ECHA',
    @server_name = N'(LOCAL)'

PRINT 'Job asignado al servidor local'
GO

-- =====================================================
-- RESUMEN
-- =====================================================
PRINT ''
PRINT '======================================'
PRINT 'JOB CREADO EXITOSAMENTE (VERSION SEGURA)'
PRINT '======================================'
PRINT ''
PRINT 'Nombre: MANTENIMIENTO_ERP_ECHA'
PRINT ''
PRINT 'Schedule: Domingos a las 2:00 AM'
PRINT ''
PRINT 'Steps (solo operaciones seguras):'
PRINT '  1. Desfragmentar indices (REBUILD >30%, REORGANIZE 10-30%)'
PRINT '  2. Actualizar estadisticas (FULLSCAN o SAMPLE segun tamano)'
PRINT '  3. Limpiar cache de planes obsoletos'
PRINT ''
PRINT 'NOTA: Este job NO elimina ni crea indices.'
PRINT '      Para cambios de indices, usar el script manual:'
PRINT '      SCRIPT_MANTENIMIENTO_BD_ERP_ECHA.sql'
PRINT ''
PRINT 'Comandos utiles:'
PRINT '  -- Ejecutar manualmente:'
PRINT '  EXEC msdb.dbo.sp_start_job @job_name = N''MANTENIMIENTO_ERP_ECHA'''
PRINT ''
PRINT '  -- Ver historial:'
PRINT '  SELECT j.name, h.step_name, h.run_date, h.run_time,'
PRINT '         h.run_duration, h.message'
PRINT '  FROM msdb.dbo.sysjobhistory h'
PRINT '  INNER JOIN msdb.dbo.sysjobs j ON h.job_id = j.job_id'
PRINT '  WHERE j.name = N''MANTENIMIENTO_ERP_ECHA'''
PRINT '  ORDER BY h.run_date DESC, h.run_time DESC'
PRINT '======================================'
GO
