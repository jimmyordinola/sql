-- ============================================
-- Script de medición de rendimiento
-- USP_VOUCHER_DOCS_CONTABLE_SIN_ANEXO_4
-- ============================================

USE [ERP_ECHA]
GO

-- Limpiar caché para prueba real (SOLO EN DESARROLLO/TEST)
-- DBCC DROPCLEANBUFFERS
-- DBCC FREEPROCCACHE

-- Habilitar estadísticas de tiempo y I/O
SET STATISTICS TIME ON
SET STATISTICS IO ON

-- Variables para medir tiempo total
DECLARE @StartTime DATETIME2 = SYSDATETIME()
DECLARE @EndTime DATETIME2

PRINT '=========================================='
PRINT 'INICIO DE EJECUCIÓN: ' + CONVERT(VARCHAR(30), @StartTime, 121)
PRINT '=========================================='

-- Ejecutar el SP
EXEC contabilidad.USP_VOUCHER_DOCS_CONTABLE_SIN_ANEXO_4
    @P_RUCE = '20102351038',
    @P_EJER = N'2025',
    @P_CD_CLT = '',
    @P_CD_PRV = '       ',
    @P_CD_TRAB = '        ',
    @P_IC_ES = 'I',
    @P_NUMERACION = NULL

SET @EndTime = SYSDATETIME()

PRINT '=========================================='
PRINT 'FIN DE EJECUCIÓN: ' + CONVERT(VARCHAR(30), @EndTime, 121)
PRINT 'TIEMPO TOTAL: ' + CAST(DATEDIFF(MILLISECOND, @StartTime, @EndTime) AS VARCHAR(20)) + ' ms'
PRINT '           = ' + CAST(DATEDIFF(MILLISECOND, @StartTime, @EndTime) / 1000.0 AS VARCHAR(20)) + ' segundos'
PRINT '=========================================='

-- Deshabilitar estadísticas
SET STATISTICS TIME OFF
SET STATISTICS IO OFF
GO

-- ============================================
-- Consulta para ver plan de ejecución en caché
-- ============================================
SELECT
    qs.execution_count,
    qs.total_elapsed_time / 1000 AS total_elapsed_ms,
    qs.total_elapsed_time / qs.execution_count / 1000 AS avg_elapsed_ms,
    qs.total_worker_time / 1000 AS total_cpu_ms,
    qs.total_worker_time / qs.execution_count / 1000 AS avg_cpu_ms,
    qs.total_logical_reads,
    qs.total_logical_reads / qs.execution_count AS avg_logical_reads,
    qs.total_physical_reads,
    qs.last_execution_time,
    SUBSTRING(st.text, 1, 500) AS query_text
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
WHERE st.text LIKE '%USP_VOUCHER_DOCS_CONTABLE_SIN_ANEXO_4%'
    AND st.text NOT LIKE '%dm_exec_query_stats%'
ORDER BY qs.last_execution_time DESC

-- ============================================
-- Ver estadísticas de espera durante ejecución
-- (Ejecutar en otra sesión mientras corre el SP)
-- ============================================
/*
SELECT
    r.session_id,
    r.status,
    r.wait_type,
    r.wait_time,
    r.blocking_session_id,
    r.cpu_time,
    r.total_elapsed_time / 1000 AS elapsed_seconds,
    r.logical_reads,
    r.reads,
    r.writes,
    SUBSTRING(st.text, 1, 200) AS query_text
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) st
WHERE r.session_id > 50
    AND st.text LIKE '%Voucher%'
*/
