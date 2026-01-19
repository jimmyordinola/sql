-- =============================================
-- Limpiar caché SOLO de la función específica
-- =============================================

USE [ERP_TEST]
GO

SET NOCOUNT ON;

PRINT '========================================================================';
PRINT 'Limpiando caché de la función USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS_2';
PRINT '========================================================================';
PRINT '';

-- Limpiar solo los planes que usan esta función específica
DECLARE @FunctionName NVARCHAR(128) = 'USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS_2';
DECLARE @PlansCleaned INT = 0;

-- Obtener y limpiar planes que referencian esta función
DECLARE @plan_handle VARBINARY(64);

DECLARE plan_cursor CURSOR FOR
SELECT cp.plan_handle
FROM sys.dm_exec_cached_plans cp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) qp
WHERE st.text LIKE '%' + @FunctionName + '%'
   OR CAST(qp.query_plan AS NVARCHAR(MAX)) LIKE '%' + @FunctionName + '%';

OPEN plan_cursor;
FETCH NEXT FROM plan_cursor INTO @plan_handle;

WHILE @@FETCH_STATUS = 0
BEGIN
    DBCC FREEPROCCACHE(@plan_handle);
    SET @PlansCleaned = @PlansCleaned + 1;
    FETCH NEXT FROM plan_cursor INTO @plan_handle;
END

CLOSE plan_cursor;
DEALLOCATE plan_cursor;

PRINT '✓ Planes de ejecución limpiados: ' + CAST(@PlansCleaned AS VARCHAR(10));
PRINT '';
PRINT 'La próxima vez que se ejecute la función, SQL Server';
PRINT 'compilará un nuevo plan usando la versión actualizada.';
PRINT '';
PRINT '========================================================================';
PRINT 'PROCESO COMPLETADO';
PRINT '========================================================================';
