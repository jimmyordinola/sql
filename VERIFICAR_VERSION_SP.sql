-- =============================================
-- VERIFICAR SI EL SP SE ACTUALIZÓ EN LA BD
-- =============================================
USE [ERP_ECHA]
GO

PRINT '========================================';
PRINT 'VERIFICACIÓN DE VERSIÓN DEL SP';
PRINT '========================================';
PRINT '';

-- Ver fecha de modificación del SP
SELECT
    OBJECT_NAME(object_id) AS StoredProcedure,
    create_date AS FechaCreacion,
    modify_date AS UltimaModificacion,
    DATEDIFF(MINUTE, modify_date, GETDATE()) AS MinutosDesdeUltimaModificacion
FROM sys.sql_modules sm
INNER JOIN sys.objects o ON o.object_id = sm.object_id
WHERE OBJECT_NAME(sm.object_id) = 'USP_COSTO_INVENTARIO_RECALCULAR_INDIVIDUAL_PROMEDIO';

PRINT '';
PRINT 'Si MinutosDesdeUltimaModificacion es grande (ej: más de 30 min),';
PRINT 'significa que el SP NO se ha actualizado recientemente.';
PRINT '';

-- Buscar en el código del SP si tiene la optimización
PRINT '========================================';
PRINT 'BUSCANDO LÍNEA DE OPTIMIZACIÓN EN EL SP';
PRINT '========================================';
PRINT '';

DECLARE @Definition NVARCHAR(MAX);

SELECT @Definition = OBJECT_DEFINITION(OBJECT_ID('inventario.USP_COSTO_INVENTARIO_RECALCULAR_INDIVIDUAL_PROMEDIO'));

IF @Definition LIKE '%@P_FECHA_HASTA%'
BEGIN
    PRINT 'ENCONTRADO: El SP contiene la variable @P_FECHA_HASTA';

    IF @Definition LIKE '%SET @P_FECHA_HASTA = ''2025-05-01%'
    BEGIN
        PRINT 'ENCONTRADO: El SP tiene el límite fijo 2025-05-01';
        PRINT '';
        PRINT 'RESULTADO: La optimización ESTÁ aplicada en la BD';
    END
    ELSE IF @Definition LIKE '%SET @P_FECHA_HASTA = DATEADD%'
    BEGIN
        PRINT 'ENCONTRADO: El SP tiene cálculo automático de fecha';
        PRINT '';
        PRINT 'RESULTADO: Versión ANTIGUA (calcula fecha automáticamente)';
    END
    ELSE
    BEGIN
        PRINT 'ADVERTENCIA: La variable existe pero no tiene el SET esperado';
        PRINT '';
        PRINT 'RESULTADO: Versión DESCONOCIDA';
    END
END
ELSE
BEGIN
    PRINT 'NO ENCONTRADO: El SP NO contiene @P_FECHA_HASTA';
    PRINT '';
    PRINT 'RESULTADO: La optimización NO está aplicada';
    PRINT '';
    PRINT 'SOLUCIÓN: Ejecutar el archivo USP_COSTO_INVENTARIO_RECALCULAR_INDIVIDUAL_PROMEDIO.sql';
    PRINT 'desde SQL Server Management Studio (abrir el archivo y presionar F5)';
END

PRINT '';
PRINT '========================================';
