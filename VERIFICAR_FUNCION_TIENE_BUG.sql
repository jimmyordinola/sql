-- =============================================
-- Verificar si la función tiene el bug
-- =============================================

USE [ERP_TEST]
GO

SET NOCOUNT ON;

PRINT '========================================================================';
PRINT 'VERIFICACIÓN: Estado de la función Inv_CalculoCostoPromedio3';
PRINT '========================================================================';
PRINT '';

-- Obtener la definición de la función
DECLARE @FuncionDef NVARCHAR(MAX);
DECLARE @TieneBug BIT = 0;
DECLARE @TieneCorreccion BIT = 0;
DECLARE @LineaProblematica NVARCHAR(500);

SELECT @FuncionDef = OBJECT_DEFINITION(OBJECT_ID('dbo.Inv_CalculoCostoPromedio3'));

IF @FuncionDef IS NULL
BEGIN
    PRINT '✗ ERROR: La función NO existe en la base de datos';
END
ELSE
BEGIN
    -- Buscar el operador incorrecto
    IF CHARINDEX('a.FechaMovimiento < @FecMov', @FuncionDef) > 0
    BEGIN
        SET @TieneBug = 1;
        SET @LineaProblematica = SUBSTRING(
            @FuncionDef,
            CHARINDEX('a.FechaMovimiento < @FecMov', @FuncionDef) - 50,
            150
        );
    END

    -- Buscar el operador correcto
    IF CHARINDEX('a.FechaMovimiento <= @FecMov', @FuncionDef) > 0
    BEGIN
        SET @TieneCorreccion = 1;
        SET @LineaProblematica = SUBSTRING(
            @FuncionDef,
            CHARINDEX('a.FechaMovimiento <= @FecMov', @FuncionDef) - 50,
            150
        );
    END

    -- Mostrar resultado
    IF @TieneBug = 1
    BEGIN
        PRINT '✗ BUG DETECTADO: La función tiene el operador < (incorrecto)';
        PRINT '';
        PRINT 'Fragmento encontrado:';
        PRINT @LineaProblematica;
        PRINT '';
        PRINT 'ESTO EXPLICA POR QUÉ EL COSTO ES INCORRECTO.';
        PRINT '';
        PRINT 'ACCIÓN REQUERIDA:';
        PRINT '  1. Ejecutar el script: Inv_CalculoCostoPromedio3.sql';
        PRINT '  2. Limpiar caché: DBCC FREEPROCCACHE';
        PRINT '  3. Volver a recalcular';
    END
    ELSE IF @TieneCorreccion = 1
    BEGIN
        PRINT '✓ CORREGIDO: La función tiene el operador <= (correcto)';
        PRINT '';
        PRINT 'Fragmento encontrado:';
        PRINT @LineaProblematica;
        PRINT '';
        PRINT 'La función está correcta en la BD.';
        PRINT 'Si el recálculo sigue dando costos incorrectos,';
        PRINT 'el problema puede estar en el caché del plan de ejecución.';
    END
    ELSE
    BEGIN
        PRINT '? NO SE ENCONTRÓ el operador en la función';
        PRINT 'La función puede tener una estructura diferente.';
    END
END

PRINT '';
PRINT '========================================================================';
PRINT 'Información de la función';
PRINT '========================================================================';
PRINT '';

SELECT
    OBJECT_SCHEMA_NAME(object_id) AS Esquema,
    OBJECT_NAME(object_id) AS Funcion,
    type_desc AS Tipo,
    create_date AS FechaCreacion,
    modify_date AS FechaModificacion
FROM sys.objects
WHERE object_id = OBJECT_ID('dbo.Inv_CalculoCostoPromedio3');

PRINT '';
PRINT '========================================================================';
PRINT 'COSTOS ACTUALES DESPUÉS DEL RECÁLCULO:';
PRINT '========================================================================';
PRINT '';

SELECT
    i2.FechaMovimiento,
    ci.Cd_Inv,
    ci.Item,
    id2.Cantidad AS Kg_Salida,
    ci.Costo_MN AS Costo_Actual,
    CASE
        WHEN ci.Cd_Inv = 'INV000297367' THEN 3.102090
        WHEN ci.Cd_Inv = 'INV000297372' THEN 2.665417
    END AS Costo_Esperado,
    CASE
        WHEN ABS(ci.Costo_MN - 3.8084480) < 0.01 THEN '✗ BUG PERSISTE (3.8084480)'
        WHEN ABS(ci.Costo_MN - 3.991195) < 0.01 THEN '✗ BUG PERSISTE (3.991195)'
        WHEN ci.Cd_Inv = 'INV000297367' AND ABS(ci.Costo_MN - 3.102090) < 0.01 THEN '✓ CORREGIDO'
        WHEN ci.Cd_Inv = 'INV000297372' AND ABS(ci.Costo_MN - 2.665417) < 0.01 THEN '✓ CORREGIDO'
        ELSE 'OTRO: ' + CAST(ci.Costo_MN AS VARCHAR(20))
    END AS Estado
FROM
    CostoInventario ci
    INNER JOIN InventarioDet2 id2 ON id2.RucE = ci.RucE AND id2.Cd_Inv = ci.Cd_Inv AND id2.Item = ci.Item
    INNER JOIN Inventario2 i2 ON i2.RucE = id2.RucE AND i2.Cd_Inv = id2.Cd_Inv
WHERE
    ci.RucE = '20102351038'
    AND ci.Cd_Inv IN ('INV000297367', 'INV000297372')
    AND id2.IC_ES = 'S';

PRINT '';
PRINT '========================================================================';
