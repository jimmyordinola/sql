USE [ERP_ECHA]
GO

-- Eliminar tabla temporal si existe
IF OBJECT_ID('tempdb..#KardexPD00026') IS NOT NULL
    DROP TABLE #KardexPD00026
GO

-- Crear tabla temporal para almacenar los resultados del kardex
CREATE TABLE #KardexPD00026
(
    CodigoInventario VARCHAR(50),
    RegistroContable VARCHAR(50),
    FechaMovimiento DATETIME,
    CodAlmacen VARCHAR(20),
    NomAlmacen VARCHAR(100),
    CodProducto VARCHAR(20),
    NombreProducto VARCHAR(200),
    CodComercial VARCHAR(50),
    CodigoUnidadMedida VARCHAR(10),
    NombreUnidadMedida VARCHAR(50),
    Clase VARCHAR(100),
    SubClase VARCHAR(100),
    SubSubClase VARCHAR(100),
    Marca VARCHAR(100),
    Temporada VARCHAR(100),
    TipoOperacion VARCHAR(10),
    NombreTipoOperacion VARCHAR(100),
    CodRef VARCHAR(50),
    CodTipoDocumento VARCHAR(10),
    TipoDocumento VARCHAR(100),
    NroSerie VARCHAR(20),
    NroDocumento VARCHAR(50),
    CodDocFinal VARCHAR(10),
    NroSerieDocFinal VARCHAR(20),
    NroDocFinal VARCHAR(50),
    Movimiento VARCHAR(20),
    UnidMedidaRegistro VARCHAR(10),
    Cantidad NUMERIC(18,6),
    Factor NUMERIC(18,6),
    UnidadMedidaBase VARCHAR(50),
    CantidadEntrada NUMERIC(18,6),
    CostoEntrada NUMERIC(18,10),
    TotalEntrada NUMERIC(18,6),
    CantidadSalida NUMERIC(18,6),
    CostoSalida NUMERIC(18,10),
    TotalSalida NUMERIC(18,6),
    SaldoCantidad NUMERIC(18,6),
    SaldoCosto NUMERIC(18,10),
    SaldoTotal NUMERIC(18,6),
    UMSinConvertir VARCHAR(10),
    CantidadSinConvertir NUMERIC(18,6),
    CantidadSecundariaEntrada NUMERIC(18,6),
    CantidadSecundariaSalida NUMERIC(18,6),
    SaldoCantidadSecundaria NUMERIC(18,6),
    TipoExistencia VARCHAR(10),
    NombreExistencia VARCHAR(100),
    CodCentroCostos VARCHAR(20),
    NombreCentroCostos VARCHAR(100),
    CodSubCentroCostos VARCHAR(20),
    NombreSubCentroCostos VARCHAR(100),
    CodSubSubCentroCostos VARCHAR(20),
    NombreSubSubCentroCostos VARCHAR(100),
    MargenVenta NUMERIC(18,6),
    NumeroDocumentoAuxiliar VARCHAR(50),
    NombreAuxiliar VARCHAR(200)
)
GO

-- Insertar resultados del SP en la tabla temporal
INSERT INTO #KardexPD00026
EXEC inventario.USP_INVENTARIO2_BUSCAR_KARDEX_DETALLE_6
    @P_RUC_EMPRESA = N'20102351038',
    @P_EJERCICIO = N'2025',
    @P_CODIGO_MONEDA = '01',
    @P_FECHA_HASTA = '2025-10-31',
    @P_CODIGO_PRODUCTO = 'PD00026',
    @P_FECHA_DESDE = '2025-10-01',
    @P_IB_MOSTRAR_DOCUMENTOS_RELACIONADOS = 0,
    @P_USUARIO = N'PROJECT01'
GO

-- Mostrar total de registros
SELECT
    'Total de movimientos' as Descripcion,
    COUNT(*) as Cantidad
FROM #KardexPD00026
GO

-- Mostrar resumen de movimientos
SELECT
    Movimiento,
    COUNT(*) as TotalMovimientos,
    SUM(ISNULL(CantidadEntrada, 0)) as TotalEntradas,
    SUM(ISNULL(CantidadSalida, 0)) as TotalSalidas
FROM #KardexPD00026
GROUP BY Movimiento
GO

-- Mostrar movimientos con valores negativos
SELECT
    'Movimientos con SALDO NEGATIVO' as Alerta,
    COUNT(*) as Cantidad
FROM #KardexPD00026
WHERE SaldoCosto < 0 OR SaldoTotal < 0
GO

-- Si hay negativos, mostrarlos
IF EXISTS (SELECT 1 FROM #KardexPD00026 WHERE SaldoCosto < 0 OR SaldoTotal < 0)
BEGIN
    SELECT
        FechaMovimiento,
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
    FROM #KardexPD00026
    WHERE SaldoCosto < 0 OR SaldoTotal < 0
    ORDER BY FechaMovimiento
END
GO

-- Mostrar entradas con costo anormalmente bajo (menor a 5)
SELECT
    'Entradas con COSTO ANORMALMENTE BAJO' as Alerta,
    COUNT(*) as Cantidad
FROM #KardexPD00026
WHERE CantidadEntrada > 0 AND CostoEntrada < 5 AND CostoEntrada > 0
GO

-- Si hay entradas con costo bajo, mostrarlas
IF EXISTS (SELECT 1 FROM #KardexPD00026 WHERE CantidadEntrada > 0 AND CostoEntrada < 5 AND CostoEntrada > 0)
BEGIN
    SELECT
        FechaMovimiento,
        CantidadEntrada,
        CostoEntrada,
        TotalEntrada,
        SaldoCantidad,
        SaldoCosto,
        SaldoTotal,
        TipoOperacion,
        NombreTipoOperacion,
        RegistroContable
    FROM #KardexPD00026
    WHERE CantidadEntrada > 0 AND CostoEntrada < 5 AND CostoEntrada > 0
    ORDER BY FechaMovimiento
END
GO

-- Mostrar todos los movimientos en orden cronológico
SELECT
    ROW_NUMBER() OVER (ORDER BY FechaMovimiento) as Nro,
    CONVERT(VARCHAR(19), FechaMovimiento, 120) as Fecha,
    Movimiento,
    ISNULL(CantidadEntrada, 0) as Cant_E,
    ISNULL(CostoEntrada, 0) as Costo_E,
    ISNULL(TotalEntrada, 0) as Total_E,
    ISNULL(CantidadSalida, 0) as Cant_S,
    ISNULL(CostoSalida, 0) as Costo_S,
    ISNULL(TotalSalida, 0) as Total_S,
    SaldoCantidad as Saldo_Q,
    SaldoCosto as Saldo_Costo,
    SaldoTotal as Saldo_Total,
    TipoOperacion,
    NombreTipoOperacion,
    CodigoInventario,
    RegistroContable
FROM #KardexPD00026
ORDER BY FechaMovimiento
GO

-- Análisis de costo promedio calculado vs esperado
SELECT
    ROW_NUMBER() OVER (ORDER BY FechaMovimiento) as Nro,
    CONVERT(VARCHAR(19), FechaMovimiento, 120) as Fecha,
    Movimiento,
    SaldoCantidad as Saldo_Q,
    SaldoTotal as Saldo_Total,
    SaldoCosto as Costo_DB,
    CASE
        WHEN SaldoCantidad <> 0 THEN SaldoTotal / SaldoCantidad
        ELSE 0
    END as Costo_Esperado,
    CASE
        WHEN SaldoCantidad <> 0 AND ABS(SaldoCosto - (SaldoTotal / SaldoCantidad)) > 0.01
        THEN 'ERROR'
        ELSE 'OK'
    END as Validacion
FROM #KardexPD00026
WHERE SaldoCantidad <> 0
ORDER BY FechaMovimiento
GO

-- Guardar en tabla permanente para análisis posterior (opcional)
/*
IF OBJECT_ID('dbo.Kardex_PD00026_Analisis') IS NOT NULL
    DROP TABLE dbo.Kardex_PD00026_Analisis
GO

SELECT *
INTO dbo.Kardex_PD00026_Analisis
FROM #KardexPD00026
GO

SELECT 'Datos guardados en tabla dbo.Kardex_PD00026_Analisis' as Mensaje
GO
*/
