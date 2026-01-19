-- =============================================
-- DIAGNÓSTICO: Verificar estado de la función en BD
-- =============================================

USE [ERP_TEST]
GO

SET NOCOUNT ON;

PRINT '========================================================================';
PRINT 'DIAGNÓSTICO: Estado de la función USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS_2';
PRINT '========================================================================';
PRINT '';

-- Obtener la definición actual de la función en la BD
DECLARE @FuncionDef NVARCHAR(MAX);
DECLARE @LineaProblematica NVARCHAR(500);
DECLARE @PosicionOperador INT;

SELECT @FuncionDef = OBJECT_DEFINITION(OBJECT_ID('inventario.USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS_2'));

IF @FuncionDef IS NULL
BEGIN
    PRINT '✗ ERROR: La función NO existe en la base de datos';
    PRINT '  Esquema: inventario';
    PRINT '  Función: USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS_2';
    PRINT '';
    PRINT 'Posibles causas:';
    PRINT '  1. La función está en otro esquema (ej: dbo)';
    PRINT '  2. La función no ha sido creada aún';
    PRINT '  3. No tienes permisos para ver la definición';
END
ELSE
BEGIN
    -- Buscar la línea problemática
    SET @PosicionOperador = CHARINDEX('id.FechaMovimiento <', @FuncionDef);

    IF @PosicionOperador > 0
    BEGIN
        -- Extraer un fragmento alrededor del operador
        SET @LineaProblematica = SUBSTRING(@FuncionDef, @PosicionOperador - 50, 150);

        PRINT '✗ BUG DETECTADO: La función tiene el operador < (incorrecto)';
        PRINT '';
        PRINT 'Fragmento encontrado:';
        PRINT @LineaProblematica;
        PRINT '';
        PRINT 'ACCIÓN REQUERIDA:';
        PRINT '  Ejecutar el script USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS_2.sql';
        PRINT '  para aplicar la corrección (cambiar < por <=)';
    END
    ELSE
    BEGIN
        -- Verificar si tiene el operador correcto
        SET @PosicionOperador = CHARINDEX('id.FechaMovimiento <=', @FuncionDef);

        IF @PosicionOperador > 0
        BEGIN
            SET @LineaProblematica = SUBSTRING(@FuncionDef, @PosicionOperador - 50, 150);

            PRINT '✓ CORRECCIÓN APLICADA: La función tiene el operador <= (correcto)';
            PRINT '';
            PRINT 'Fragmento encontrado:';
            PRINT @LineaProblematica;
            PRINT '';
            PRINT 'La función está correcta. Si el recálculo sigue mostrando';
            PRINT 'costos incorrectos, el problema puede estar en:';
            PRINT '  1. Caché del plan de ejecución (limpiar con DBCC FREEPROCCACHE)';
            PRINT '  2. Otra función que también calcula costos';
            PRINT '  3. Datos ya guardados en CostoInventario que no se actualizaron';
        END
        ELSE
        BEGIN
            PRINT '? NO SE ENCONTRÓ la línea id.FechaMovimiento en la función';
            PRINT '  Esto puede indicar que la función tiene una estructura diferente';
            PRINT '  o que la condición está escrita de otra forma';
        END
    END
END

PRINT '';
PRINT '========================================================================';
PRINT 'Información adicional de la función';
PRINT '========================================================================';

SELECT
    OBJECT_SCHEMA_NAME(object_id) AS Esquema,
    OBJECT_NAME(object_id) AS Funcion,
    type_desc AS Tipo,
    create_date AS FechaCreacion,
    modify_date AS FechaModificacion
FROM
    sys.objects
WHERE
    name = 'USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS_2'
    AND type IN ('FN', 'IF', 'TF');

PRINT '';
PRINT '========================================================================';
PRINT 'DIAGNÓSTICO COMPLETADO';
PRINT '========================================================================';
