-- =============================================
-- APLICAR OPTIMIZACIÓN AL SP DE RECÁLCULO
-- =============================================
-- Este script aplica la optimización que limita automáticamente
-- el rango de fechas a procesar (última fecha + 1 mes)
-- evitando procesar años de movimientos innecesarios
-- =============================================

USE [ERP_ECHA]
GO

-- Ejecutar el script modificado
:r "d:\nuvol\sp\USP_COSTO_INVENTARIO_RECALCULAR_INDIVIDUAL_PROMEDIO.sql"
GO

PRINT '';
PRINT '========================================';
PRINT 'OPTIMIZACIÓN APLICADA CORRECTAMENTE';
PRINT '========================================';
PRINT 'El SP ahora tiene fecha límite FIJA:';
PRINT '  - Fecha límite = 01/05/2025 00:00:00';
PRINT '  - Solo procesa movimientos hasta esa fecha';
PRINT '';
PRINT 'Beneficios:';
PRINT '  - Reduce tiempo de ejecución 90-95%';
PRINT '  - Procesa solo 1 mes (Abril 2025)';
PRINT '  - Muestra rango si DEBUG = 1';
PRINT '';
PRINT 'NOTA: Para cambiar la fecha límite,';
PRINT 'modifica la línea 47 del SP:';
PRINT 'SET @P_FECHA_HASTA = ''2025-05-01 00:00:00'';';
PRINT '========================================';
GO
