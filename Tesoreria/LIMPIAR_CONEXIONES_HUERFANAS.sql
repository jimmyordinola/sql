-- ============================================
-- Script para LIMPIAR CONEXIONES HUERFANAS
-- ============================================
-- EJECUTAR CON CUIDADO - Revisar antes de ejecutar los KILL
-- ============================================

USE master
GO

-- ============================================
-- 1. VER RESUMEN ACTUAL
-- ============================================
PRINT '=== RESUMEN DE CONEXIONES HUERFANAS ==='
SELECT
    host_name,
    COUNT(*) AS conexiones,
    MIN(DATEDIFF(MINUTE, last_request_end_time, GETDATE())) AS min_inactivo,
    MAX(DATEDIFF(MINUTE, last_request_end_time, GETDATE())) AS max_inactivo
FROM sys.dm_exec_sessions
WHERE is_user_process = 1
  AND status = 'sleeping'
  AND DATEDIFF(MINUTE, last_request_end_time, GETDATE()) > 60
GROUP BY host_name
ORDER BY conexiones DESC
GO

-- ============================================
-- 2. GENERAR COMANDOS KILL (NO EJECUTA, SOLO GENERA)
-- ============================================
PRINT ''
PRINT '=== COMANDOS KILL GENERADOS ==='
PRINT '-- Copia y ejecuta los que necesites:'
PRINT ''

-- Conexiones MUY viejas (> 1 dia) - PRIORIDAD ALTA
PRINT '-- CONEXIONES > 1 DIA (CRITICAS):'
SELECT 'KILL ' + CAST(session_id AS VARCHAR) + '; -- ' + host_name + ' (' + CAST(DATEDIFF(HOUR, last_request_end_time, GETDATE()) AS VARCHAR) + ' horas)'
FROM sys.dm_exec_sessions
WHERE is_user_process = 1
  AND status = 'sleeping'
  AND program_name LIKE '.Net SqlClient%'
  AND DATEDIFF(HOUR, last_request_end_time, GETDATE()) > 24

-- Conexiones de DESKTOP-A00Q38J (107 conexiones!)
PRINT ''
PRINT '-- CONEXIONES DE DESKTOP-A00Q38J (> 1 hora):'
SELECT 'KILL ' + CAST(session_id AS VARCHAR) + ';'
FROM sys.dm_exec_sessions
WHERE is_user_process = 1
  AND status = 'sleeping'
  AND host_name = 'DESKTOP-A00Q38J'
  AND DATEDIFF(MINUTE, last_request_end_time, GETDATE()) > 60

-- Conexiones de CHPIUTIEL01 (73 conexiones!)
PRINT ''
PRINT '-- CONEXIONES DE CHPIUTIEL01 (> 1 hora):'
SELECT 'KILL ' + CAST(session_id AS VARCHAR) + ';'
FROM sys.dm_exec_sessions
WHERE is_user_process = 1
  AND status = 'sleeping'
  AND host_name = 'CHPIUTIEL01'
  AND DATEDIFF(MINUTE, last_request_end_time, GETDATE()) > 60
GO

-- ============================================
-- 3. MATAR TODAS LAS CONEXIONES > 2 HORAS (DESCOMENTAPR PARA EJECUTAR)
-- ============================================
/*
PRINT ''
PRINT '=== EJECUTANDO KILL MASIVO (> 2 horas) ==='

DECLARE @sql NVARCHAR(MAX) = ''

SELECT @sql = @sql + 'KILL ' + CAST(session_id AS VARCHAR) + '; '
FROM sys.dm_exec_sessions
WHERE is_user_process = 1
  AND status = 'sleeping'
  AND program_name LIKE '.Net SqlClient%'
  AND DATEDIFF(MINUTE, last_request_end_time, GETDATE()) > 120
  AND host_name NOT IN ('BDSERVER') -- No matar conexiones del servidor

PRINT @sql
EXEC sp_executesql @sql

PRINT 'Conexiones eliminadas!'
*/
GO

-- ============================================
-- 4. VERIFICAR RESULTADO
-- ============================================
PRINT ''
PRINT '=== CONEXIONES ACTUALES DESPUES DE LIMPIEZA ==='
SELECT
    host_name,
    COUNT(*) AS conexiones
FROM sys.dm_exec_sessions
WHERE is_user_process = 1
GROUP BY host_name
ORDER BY conexiones DESC
GO
