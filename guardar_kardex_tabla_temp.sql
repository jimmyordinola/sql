USE [ERP_ECHA]
GO

PRINT '=========================================='
PRINT 'Obteniendo estructura del SP Kardex...'
PRINT '=========================================='
GO

-- Definir el SP a ejecutar
DECLARE @sp NVARCHAR(MAX) = N'EXEC inventario.USP_INVENTARIO2_BUSCAR_KARDEX_DETALLE_6
    @P_RUC_EMPRESA=N''20102351038'',
    @P_EJERCICIO=N''2025'',
    @P_CODIGO_MONEDA=''01'',
    @P_FECHA_HASTA=''2025-10-31'',
    @P_CODIGO_PRODUCTO=''PD00026'',
    @P_FECHA_DESDE=''2025-10-01'',
    @P_IB_MOSTRAR_DOCUMENTOS_RELACIONADOS=0,
    @P_USUARIO=N''PROJECT01'''

-- Obtener las columnas del resultado del SP
DECLARE @columns NVARCHAR(MAX) = ''

SELECT @columns = STRING_AGG(
    QUOTENAME(name) + ' ' + system_type_name + CASE WHEN is_nullable = 1 THEN ' NULL' ELSE '' END,
    ', '
)
FROM sys.dm_exec_describe_first_result_set(@sp, NULL, 0)

PRINT 'Columnas detectadas:'
PRINT @columns
PRINT ''
GO

-- Ahora crear la tabla temporal global con los resultados
DECLARE @sp NVARCHAR(MAX) = N'EXEC inventario.USP_INVENTARIO2_BUSCAR_KARDEX_DETALLE_6
    @P_RUC_EMPRESA=N''20102351038'',
    @P_EJERCICIO=N''2025'',
    @P_CODIGO_MONEDA=''01'',
    @P_FECHA_HASTA=''2025-10-31'',
    @P_CODIGO_PRODUCTO=''PD00026'',
    @P_FECHA_DESDE=''2025-10-01'',
    @P_IB_MOSTRAR_DOCUMENTOS_RELACIONADOS=0,
    @P_USUARIO=N''PROJECT01'''

DECLARE @columns NVARCHAR(MAX) = ''

SELECT @columns = STRING_AGG(
    QUOTENAME(name) + ' ' + system_type_name + CASE WHEN is_nullable = 1 THEN ' NULL' ELSE '' END,
    ', '
)
FROM sys.dm_exec_describe_first_result_set(@sp, NULL, 0)

-- Eliminar tabla si existe
IF OBJECT_ID('tempdb..##Kardex_PD00026') IS NOT NULL
    DROP TABLE ##Kardex_PD00026

-- Crear la tabla temporal global
EXEC('CREATE TABLE ##Kardex_PD00026 (' + @columns + ')')

PRINT 'Tabla ##Kardex_PD00026 creada exitosamente'
PRINT ''
PRINT 'Insertando datos del kardex...'

-- Insertar los datos
EXEC('INSERT INTO ##Kardex_PD00026 ' + @sp)

PRINT 'Datos insertados exitosamente'
PRINT ''
GO

-- Mostrar resumen
PRINT '=========================================='
PRINT 'RESUMEN DE DATOS'
PRINT '=========================================='
GO

SELECT
    'Total de movimientos' as Descripcion,
    COUNT(*) as Cantidad
FROM ##Kardex_PD00026
GO

-- Mostrar resumen por tipo de movimiento
SELECT
    'Resumen por Movimiento' as Titulo
GO

SELECT
    Movimiento,
    COUNT(*) as TotalMovimientos,
    SUM(ISNULL(CantidadEntrada, 0)) as TotalEntradas,
    SUM(ISNULL(CantidadSalida, 0)) as TotalSalidas
FROM ##Kardex_PD00026
GROUP BY Movimiento
ORDER BY Movimiento
GO

-- Verificar si hay valores negativos
DECLARE @negativos INT
SELECT @negativos = COUNT(*) FROM ##Kardex_PD00026 WHERE SaldoCosto < 0 OR SaldoTotal < 0

IF @negativos > 0
BEGIN
    PRINT ''
    PRINT '¡¡¡ ALERTA: Se encontraron ' + CAST(@negativos AS VARCHAR) + ' movimientos con SALDO NEGATIVO !!!'
    PRINT ''

    SELECT
        CONVERT(VARCHAR(19), FechaMovimiento, 120) as Fecha,
        Movimiento,
        CantidadEntrada,
        CostoEntrada,
        TotalEntrada,
        CantidadSalida,
        CostoSalida,
        TotalSalida,
        SaldoCantidad,
        SaldoCosto,
        SaldoTotal,
        TipoOperacion,
        NombreTipoOperacion
    FROM ##Kardex_PD00026
    WHERE SaldoCosto < 0 OR SaldoTotal < 0
    ORDER BY FechaMovimiento
END
ELSE
BEGIN
    PRINT ''
    PRINT 'OK: No se encontraron valores negativos'
    PRINT ''
END
GO

-- Verificar entradas con costo bajo
DECLARE @costoBajo INT
SELECT @costoBajo = COUNT(*) FROM ##Kardex_PD00026 WHERE CantidadEntrada > 0 AND CostoEntrada < 5 AND CostoEntrada > 0

IF @costoBajo > 0
BEGIN
    PRINT ''
    PRINT '¡¡¡ ALERTA: Se encontraron ' + CAST(@costoBajo AS VARCHAR) + ' entradas con COSTO ANORMALMENTE BAJO !!!'
    PRINT ''

    SELECT
        CONVERT(VARCHAR(19), FechaMovimiento, 120) as Fecha,
        CantidadEntrada,
        CostoEntrada,
        TotalEntrada,
        SaldoCantidad,
        SaldoCosto,
        SaldoTotal,
        TipoOperacion,
        NombreTipoOperacion,
        RegistroContable
    FROM ##Kardex_PD00026
    WHERE CantidadEntrada > 0 AND CostoEntrada < 5 AND CostoEntrada > 0
    ORDER BY FechaMovimiento
END
ELSE
BEGIN
    PRINT ''
    PRINT 'OK: No se encontraron entradas con costo anormalmente bajo'
    PRINT ''
END
GO

-- Mostrar primeros 30 movimientos
PRINT ''
PRINT '=========================================='
PRINT 'PRIMEROS 30 MOVIMIENTOS'
PRINT '=========================================='
GO

SELECT TOP 30
    ROW_NUMBER() OVER (ORDER BY FechaMovimiento) as Nro,
    CONVERT(VARCHAR(19), FechaMovimiento, 120) as Fecha,
    Movimiento,
    ISNULL(CantidadEntrada, 0) as Cant_E,
    CAST(ISNULL(CostoEntrada, 0) AS DECIMAL(18,5)) as Costo_E,
    CAST(ISNULL(TotalEntrada, 0) AS DECIMAL(18,2)) as Total_E,
    ISNULL(CantidadSalida, 0) as Cant_S,
    CAST(ISNULL(CostoSalida, 0) AS DECIMAL(18,5)) as Costo_S,
    CAST(ISNULL(TotalSalida, 0) AS DECIMAL(18,2)) as Total_S,
    CAST(SaldoCantidad AS DECIMAL(18,2)) as Saldo_Q,
    CAST(SaldoCosto AS DECIMAL(18,5)) as Saldo_Costo,
    CAST(SaldoTotal AS DECIMAL(18,2)) as Saldo_Total,
    LEFT(NombreTipoOperacion, 20) as TipoOp
FROM ##Kardex_PD00026
ORDER BY FechaMovimiento
GO

PRINT ''
PRINT '=========================================='
PRINT 'La tabla ##Kardex_PD00026 está disponible'
PRINT 'Puedes consultarla con: SELECT * FROM ##Kardex_PD00026'
PRINT '=========================================='
GO
