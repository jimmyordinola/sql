USE [ERP_ECHA]
GO

-- Eliminar tabla si existe
IF OBJECT_ID('tempdb..#KardexTemp') IS NOT NULL
    DROP TABLE #KardexTemp
GO

-- Crear tabla temporal capturando la estructura automáticamente del SP
SELECT *
INTO #KardexTemp
FROM OPENROWSET('SQLNCLI',
    'Server=localhost;Trusted_Connection=yes;',
    'EXEC ERP_ECHA.inventario.USP_INVENTARIO2_BUSCAR_KARDEX_DETALLE_6
        @P_RUC_EMPRESA=''20102351038'',
        @P_EJERCICIO=''2025'',
        @P_CODIGO_MONEDA=''01'',
        @P_FECHA_HASTA=''2025-10-31'',
        @P_CODIGO_PRODUCTO=''PD00026'',
        @P_FECHA_DESDE=''2025-10-01'',
        @P_IB_MOSTRAR_DOCUMENTOS_RELACIONADOS=0,
        @P_USUARIO=''PROJECT01''')
GO

-- Mostrar información de las columnas
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    NUMERIC_PRECISION,
    NUMERIC_SCALE
FROM tempdb.INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME LIKE '#KardexTemp%'
ORDER BY ORDINAL_POSITION
GO

-- Mostrar datos
SELECT TOP 10 * FROM #KardexTemp
GO
