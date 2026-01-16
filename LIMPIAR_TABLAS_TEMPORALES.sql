-- =============================================
-- LIMPIAR TABLAS TEMPORALES DEL RECÁLCULO
-- =============================================
-- Ejecuta esto si el SP falló y dejó tablas temporales
-- =============================================

USE [ERP_ECHA]
GO

PRINT 'Limpiando tablas temporales del recálculo...';
PRINT '';

-- Limpiar todas las tablas temporales del SP
IF OBJECT_ID('tempdb..#BaseMov') IS NOT NULL
BEGIN
    DROP TABLE #BaseMov;
    PRINT 'Eliminada: #BaseMov';
END

IF OBJECT_ID('tempdb..#TipoMov') IS NOT NULL
BEGIN
    DROP TABLE #TipoMov;
    PRINT 'Eliminada: #TipoMov';
END

IF OBJECT_ID('tempdb..#Pum') IS NOT NULL
BEGIN
    DROP TABLE #Pum;
    PRINT 'Eliminada: #Pum';
END

IF OBJECT_ID('tempdb..#OF') IS NOT NULL
BEGIN
    DROP TABLE #OF;
    PRINT 'Eliminada: #OF';
END

IF OBJECT_ID('tempdb..#Gastos') IS NOT NULL
BEGIN
    DROP TABLE #Gastos;
    PRINT 'Eliminada: #Gastos';
END

IF OBJECT_ID('tempdb..#EnvEmb') IS NOT NULL
BEGIN
    DROP TABLE #EnvEmb;
    PRINT 'Eliminada: #EnvEmb';
END

IF OBJECT_ID('tempdb..#Frmla') IS NOT NULL
BEGIN
    DROP TABLE #Frmla;
    PRINT 'Eliminada: #Frmla';
END

IF OBJECT_ID('tempdb..#CostoPromedioSalida') IS NOT NULL
BEGIN
    DROP TABLE #CostoPromedioSalida;
    PRINT 'Eliminada: #CostoPromedioSalida';
END

IF OBJECT_ID('tempdb..#NC_Venta') IS NOT NULL
BEGIN
    DROP TABLE #NC_Venta;
    PRINT 'Eliminada: #NC_Venta';
END

IF OBJECT_ID('tempdb..#NC_Compra') IS NOT NULL
BEGIN
    DROP TABLE #NC_Compra;
    PRINT 'Eliminada: #NC_Compra';
END

IF OBJECT_ID('tempdb..#CursorData') IS NOT NULL
BEGIN
    DROP TABLE #CursorData;
    PRINT 'Eliminada: #CursorData';
END

PRINT '';
PRINT '========================================';
PRINT 'LIMPIEZA COMPLETADA';
PRINT '========================================';
PRINT 'Ahora puedes ejecutar el recálculo nuevamente.';
PRINT '';
