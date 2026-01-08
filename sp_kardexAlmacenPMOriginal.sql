/****** Object:  StoredProcedure [dbo].[sp_kardexAlmacenPM]    Script Date: 7/01/2026 23:24:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[sp_kardexAlmacenPM] 
@FechaDesde VARCHAR(50) = '202412010000',
@FechaHasta VARCHAR(50) = '202412050000',
@ListaArticulos VARCHAR(8000) = '',
@idsucursal int=1,
@iddeposito int =1,
@tipo int =4,
@idinventario int =0
as
set fmtonly off

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

declare @FechaDesdeInicio VARCHAR(50) = '202001010000'
CREATE TABLE #TemporalKardexArticulo1 (
	[item1] [bigint] NOT NULL,
	[idproducto] [int] NOT NULL,
	[CodigoArticulo] [varchar](200) NULL,
	[DescArticulo] [varchar](255) NULL,
	[NombreSucursal] [varchar](100) NOT NULL,
	[NombreDeposito] [varchar](100) NOT NULL,
	[fecha] [datetime] NOT NULL,
	[NombreComprobante] [varchar](50) NOT NULL,
	[numerocomprobante] [int] NULL,
	[ccosto] [nvarchar](500) NULL,
	[ubicacion] [nvarchar](50) NULL,
	[numreqinterno] [int] NULL,
	[saldoinicial] [float] NULL,
	[entrada] [float] NULL,
	[salida] [float] NULL,
	[saldo] [float] NULL,
	[PrecioUnitario] [float] NOT NULL,
	[saldoinicialvalor] [float] NULL,
	[entradavalor] [float] NULL,
	[salidavalor] [float] NULL,
	[saldovalor] [float] NULL,
	[PrecioPromedio] [float] NULL,
	[ppa] [float] NULL,
	[fechaclave] [nvarchar](4000) NULL,
	[PrecioUnitarioMoneda] [float] NULL,
	[saldoinicialvalorMoneda] [float] NULL,
	[entradavalorMoneda] [float] NULL,
	[salidavalorMoneda] [float] NULL,
	[saldovalormoneda] [float] NULL,
	[PrecioPromediomoneda] [float] NULL,
	[ppamoneda] [float] NULL,
	[idcomprobante] [int] NULL
)
CREATE CLUSTERED INDEX IX_TemporalKardexArticulo1_idp_fecha ON #TemporalKardexArticulo1(idproducto, fecha);

CREATE TABLE #TemporalKardexArticulo2 (
	[item1] [bigint] NOT NULL,
	[idproducto] [int] NOT NULL,
	[CodigoArticulo] [varchar](200) NULL,
	[DescArticulo] [varchar](255) NULL,
	[NombreSucursal] [varchar](100) NOT NULL,
	[NombreDeposito] [varchar](100) NOT NULL,
	[fecha] [datetime] NOT NULL,
	[NombreComprobante] [varchar](50) NOT NULL,
	[numerocomprobante] [int] NULL,
	[ccosto] [nvarchar](500) NULL,
	[ubicacion] [nvarchar](50) NULL,
	[numreqinterno] [int] NULL,
	[saldoinicial] [float] NULL,
	[entrada] [float] NULL,
	[salida] [float] NULL,
	[saldo] [float] NULL,
	[PrecioUnitario] [float] NOT NULL,
	[saldoinicialvalor] [float] NULL,
	[entradavalor] [float] NULL,
	[salidavalor] [float] NULL,
	[saldovalor] [float] NULL,
	[PrecioPromedio] [float] NULL,
	[ppa] [float] NULL,
	[fechaclave] [nvarchar](4000) NULL,
	[PrecioUnitarioMoneda] [float] NULL,
	[saldoinicialvalorMoneda] [float] NULL,
	[entradavalorMoneda] [float] NULL,
	[salidavalorMoneda] [float] NULL,
	[saldovalormoneda] [float] NULL,
	[PrecioPromediomoneda] [float] NULL,
	[ppamoneda] [float] NULL,
	[idcomprobante] [int] NULL
)

CREATE CLUSTERED INDEX IX_TemporalKardexArticulo2_idp_fecha ON #TemporalKardexArticulo2(idproducto, fecha);

CREATE TABLE #TemporalExistencias1(
	[idproducto] [int] NOT NULL,
	[Codigoarticulo] [varchar](200) NULL,
	[descarticulo] [varchar](255) NULL,
	[NombreSucursal] [varchar](100) NOT NULL,
	[NombreDeposito] [varchar](100) NOT NULL,
	[SaldoInicial] [float] NULL,
	[pminicial] [float] NULL,
	[SaldoInicialvalor] [float] NULL,
	[entrada] [float] NULL,
	[pmentrada] [float] NULL,
	[entradavalor] [float] NULL,
	[entradaTransferencia] [float] NULL,
	[pmentradaTransferencia] [float] NULL,
	[entradavalorTransferencia] [float] NULL,
	[salida] [float] NULL,
	[pmsalida] [float] NULL,
	[salidavalor] [float] NULL,
	[salidaTransferencia] [float] NULL,
	[pmsalidaTransferencia] [float] NULL,
	[salidavalorTransferencia] [float] NULL,
	[saldo] [float] NULL,
	[pmsaldo] [float] NULL,
	[saldovalor] [float] NULL,
	[pminicialMoneda] [float] NULL,
	[SaldoInicialvalorMoneda] [float] NULL,
	[pmentradaMoneda] [float] NULL,
	[pmentradaMonedaTransferencia] [float] NULL,
	[entradavalorMoneda] [float] NULL,
	[entradavalorMonedaTransferencia] [float] NULL,
	[pmsalidaMoneda] [float] NULL,
	[pmsalidaMonedaTransferencia] [float] NULL,
	[salidavalorMoneda] [float] NULL,
	[salidavalorMonedaTransferencia] [float] NULL,
	[pmsaldoMoneda] [float] NULL,
	[saldovalorMoneda] [float] NULL
) 

CREATE NONCLUSTERED INDEX IX_TemporalExistencias1_idp ON #TemporalExistencias1(idproducto);

CREATE TABLE #TemporalExistencias2(
	[idproducto] [int] NOT NULL,
	[Codigoarticulo] [varchar](200) NULL,
	[descarticulo] [varchar](255) NULL,
	[NombreSucursal] [varchar](100) NOT NULL,
	[NombreDeposito] [varchar](100) NOT NULL,
	[SaldoInicial] [float] NULL,
	[pminicial] [float] NULL,
	[SaldoInicialvalor] [float] NULL,
	[entrada] [float] NULL,
	[pmentrada] [float] NULL,
	[entradavalor] [float] NULL,
	[entradaTransferencia] [float] NULL,
	[pmentradaTransferencia] [float] NULL,
	[entradavalorTransferencia] [float] NULL,
	[salida] [float] NULL,
	[pmsalida] [float] NULL,
	[salidavalor] [float] NULL,
	[salidaTransferencia] [float] NULL,
	[pmsalidaTransferencia] [float] NULL,
	[salidavalorTransferencia] [float] NULL,
	[saldo] [float] NULL,
	[pmsaldo] [float] NULL,
	[saldovalor] [float] NULL,
	[pminicialMoneda] [float] NULL,
	[SaldoInicialvalorMoneda] [float] NULL,
	[pmentradaMoneda] [float] NULL,
	[pmentradaMonedaTransferencia] [float] NULL,
	[entradavalorMoneda] [float] NULL,
	[entradavalorMonedaTransferencia] [float] NULL,
	[pmsalidaMoneda] [float] NULL,
	[pmsalidaMonedaTransferencia] [float] NULL,
	[salidavalorMoneda] [float] NULL,
	[salidavalorMonedaTransferencia] [float] NULL,
	[pmsaldoMoneda] [float] NULL,
	[saldovalorMoneda] [float] NULL
) 

CREATE NONCLUSTERED INDEX IX_TemporalExistencias2_idp ON #TemporalExistencias2(idproducto);

CREATE TABLE #TemporalExistencias3(
	[idproducto] [int] NOT NULL,
	[Codigoarticulo] [varchar](200) NULL,
	[descarticulo] [varchar](255) NULL,
	[NombreSucursal] [varchar](100) NOT NULL,
	[NombreDeposito] [varchar](100) NOT NULL,
	[SaldoInicial] [float] NULL,
	[pminicial] [float] NULL,
	[SaldoInicialvalor] [float] NULL,
	[entrada] [float] NULL,
	[pmentrada] [float] NULL,
	[entradavalor] [float] NULL,
	[salida] [float] NULL,
	[pmsalida] [float] NULL,
	[salidavalor] [float] NULL,
	[saldo] [float] NULL,
	[pmsaldo] [float] NULL,
	[saldovalor] [float] NULL,
	[pminicialMoneda] [float] NULL,
	[SaldoInicialvalorMoneda] [float] NULL,
	[pmentradaMoneda] [float] NULL,
	[entradavalorMoneda] [float] NULL,
	[pmsalidaMoneda] [float] NULL,
	[salidavalorMoneda] [float] NULL,
	[pmsaldoMoneda] [float] NULL,
	[saldovalorMoneda] [float] NULL
) 

CREATE NONCLUSTERED INDEX IX_TemporalExistencias3_idp ON #TemporalExistencias3(idproducto);

CREATE TABLE #TemporalKardexContable(
	[idproducto] [int] NOT NULL,
	[CodigoArticulo] [varchar](200) NULL,
	[DescArticulo] [varchar](255) NULL,
	[NombreSucursal] [varchar](100) NOT NULL,
	[NombreDeposito] [varchar](100) NOT NULL,
	[SaldoInicial] [float] NULL,
	[pminicial] [float] NULL,
	[SaldoInicialvalor] [float] NULL,
	[entrada] [float] NULL,
	[pmentrada] [float] NULL,
	[entradavalor] [float] NULL,
	[entradaTransferencia] [float] NULL,
	[pmentradaTransferencia] [float] NULL,
	[entradavalorTransferencia] [float] NULL,
	[salida] [float] NULL,
	[pmsalida] [float] NULL,
	[salidavalor] [float] NULL,
	[salidaTransferencia] [float] NULL,
	[pmsalidaTransferencia] [float] NULL,
	[salidavalorTransferencia] [float] NULL,
	[saldo] [float] NULL,
	[pmsaldo] [float] NULL,
	[saldovalor] [float] NULL,
	[pminicialMoneda] [float] NULL,
	[SaldoInicialvalorMoneda] [float] NULL,
	[pmentradaMoneda] [float] NULL,
	[entradavalorMoneda] [float] NULL,
	[pmentradaMonedaTransferencia] [float] NULL,
	[entradavalorMonedaTransferencia] [float] NULL,
	[pmsalidaMoneda] [float] NULL,
	[salidavalorMoneda] [float] NULL,
	[pmsalidaMonedaTransferencia] [float] NULL,
	[salidavalorMonedaTransferencia] [float] NULL,
	[pmsaldoMoneda] [float] NULL,
	[saldovalorMoneda] [float] NULL
) 

CREATE NONCLUSTERED INDEX IX_TemporalKardexContable_idp ON #TemporalKardexContable(idproducto);

create table  #existenciasfinal (
	[codigoarticulo] [varchar](200) NULL,
	[descarticulo] [varchar](255) NULL,
	[NombreSucursal] [varchar](100) NOT NULL,
	[NombreDeposito] [varchar](100) NOT NULL,
	[saldo] [float] NULL,
	[pmsaldo] [float] NULL,
	[saldovalor] [float] NULL,
	[CodigoFabrica] [varchar](1) NOT NULL,
	[marca] [varchar](200) NOT NULL,
	[modelo] [varchar](200) NOT NULL,
	[Ubica] [nvarchar](50) NOT NULL,
	[categoria] [varchar](200) NOT NULL,
	[StockMinimo] [varchar](20) NULL,
	[diferencia] [float] NULL,
	[observacion] [varchar](31) NULL,
	[IdArticulo] [int] NOT NULL,
	[UnidadDeMedida] [varchar](10) NOT NULL,
	pmsaldoMoneda float,
	saldovalorMoneda float
)
CREATE NONCLUSTERED INDEX IX_#existenciasfinal_idp ON #existenciasfinal(codigoarticulo);

create table #codigosConRotacion (CodigoArticulo varchar(20))

create table #codigosSinRotacion (CodigoArticulo varchar(20), Descripcion varchar(max), UnidadDeMedida varchar(20), Ubica varchar(50), NombreComprobante
varchar(100),fecha datetime,PrecioUnitario float, PrecioUnitarioMoneda float,FechaAsNumber BIGINT)

create table #CodigosSinRotacionFechaMaxima(CodigoArticulo varchar(20),Descripcion varchar(max),MaxFechaStockInicial datetime,MaxFechaGuiaRecepcion datetime,MaxFechaSalidaStock datetime,
MaxFechaStockInicialNumber BIGINT,MaxFechaGuiaRecepcionNumber BIGINT)

create table #FechasAjustadas (CodigoArticulo varchar(20),Descripcion varchar(max),FechaUltimoIngreso datetime,FechaUltimaSalida datetime,MaxFechaStockInicialNumber BIGINT,MaxFechaGuiaRecepcionNumber BIGINT, PrecioUnitarioSoles float,PrecioUnitarioDolares float)

IF @tipo = 1
BEGIN
    INSERT #TemporalKardexArticulo1
    EXEC sp_kardexAlmacenPM_Optimizado1 @FechaDesde, @FechaHasta, @ListaArticulos, @idsucursal, @iddeposito, @tipo
    
    -- Si el depósito es 4, incluir proyectos de activo fijo
    IF @iddeposito = 4
    BEGIN
        SELECT 
            K.CodigoArticulo,
            K.DescArticulo,
            K.NombreSucursal,
            K.NombreDeposito,
            K.fecha,
            K.NombreComprobante,
            K.numerocomprobante,
            K.ccosto,
            K.ubicacion, 
            K.entrada,
            K.salida,
            K.saldo,
            K.PrecioUnitario,
            K.entradavalor,
            K.salidavalor,
            K.saldovalor,
            K.PrecioPromedio,
            K.numreqinterno,
            K.PrecioUnitarioMoneda,
            K.entradavalorMoneda,
            K.salidavalorMoneda,
            K.saldovalormoneda,
            K.PrecioPromedioMoneda,
            -- Concatenar proyectos con STRING_AGG
            STRING_AGG(P.Proyecto, ' / ') AS Proyecto,
            STRING_AGG(P.codActivo, ' / ') AS CodActivo,
            STRING_AGG(P.Activo, ' / ') AS Activo,
            STRING_AGG(CONVERT(VARCHAR(10), P.FechaApertura, 103), ' / ') AS FechaApertura,
            STRING_AGG(CONVERT(VARCHAR(10), P.FechaCierre, 103), ' / ') AS FechaCierre,
            STRING_AGG(P.Ubicacion, ' / ') AS UbicacionActivo
        FROM #TemporalKardexArticulo1 K
        OUTER APPLY dbo.fn_ObtenerProyectosActivoFijo(
            K.idproducto,
            K.idComprobante,
            @iddeposito,
            K.numerocomprobante,
            CONVERT(INT, CONVERT(VARCHAR(8), K.fecha, 112))
        ) P
        GROUP BY 
            K.item1,
            K.CodigoArticulo,
            K.DescArticulo,
            K.NombreSucursal,
            K.NombreDeposito,
            K.fecha,
            K.NombreComprobante,
            K.numerocomprobante,
            K.ccosto,
            K.ubicacion, 
            K.entrada,
            K.salida,
            K.saldo,
            K.PrecioUnitario,
            K.entradavalor,
            K.salidavalor,
            K.saldovalor,
            K.PrecioPromedio,
            K.numreqinterno,
            K.PrecioUnitarioMoneda,
            K.entradavalorMoneda,
            K.salidavalorMoneda,
            K.saldovalormoneda,
            K.PrecioPromedioMoneda
        ORDER BY K.item1, K.DescArticulo, K.fecha
    END
    ELSE
    BEGIN
        -- Para otros depósitos, consulta normal sin proyectos
        SELECT 
            CodigoArticulo,
            DescArticulo,
            NombreSucursal,
            NombreDeposito,
            fecha,
            NombreComprobante,
            numerocomprobante,
            ccosto,
            ubicacion, 
            entrada,
            salida,
            saldo,
            PrecioUnitario,
            entradavalor,
            salidavalor,
            saldovalor,
            PrecioPromedio,
            numreqinterno,
            PrecioUnitarioMoneda,
            entradavalorMoneda,
            salidavalorMoneda,
            saldovalormoneda,
            PrecioPromedioMoneda
        FROM #TemporalKardexArticulo1 
        ORDER BY item1, DescArticulo, fecha
    END
END

IF @tipo = 2 OR @tipo = 3
BEGIN
        -- Variables
        DECLARE @MaxMes INT = 0
        DECLARE @MaxAnio INT = 0
        DECLARE @FechaReferenciaDate DATETIME
        DECLARE @MesReferencia INT
        DECLARE @AnioReferencia INT
        DECLARE @MesAnterior INT
        DECLARE @AnioAnterior INT
        DECLARE @Mes INT
        DECLARE @Anio INT
        DECLARE @ExisteHistorico BIT = 0
        DECLARE @FechaDesdeOriginal VARCHAR(20)
        DECLARE @PrimerDiaMes DATETIME
        DECLARE @FechaMesAnterior DATETIME
        DECLARE @EsUltimoDiaMes BIT = 0
        DECLARE @UltimoDiaMes INT
        DECLARE @FechaMesProximo DATETIME
        DECLARE @MesProximo INT
        DECLARE @AnioProximo INT

        SET @FechaDesdeOriginal = @FechaDesde

        PRINT '=========================================='
        PRINT 'PASO 1: PARÁMETROS INICIALES'
        PRINT '=========================================='
        PRINT 'Tipo: ' + CAST(@tipo AS VARCHAR)
        PRINT 'FechaDesde Original: ' + @FechaDesde
        PRINT 'FechaHasta Original: ' + @FechaHasta
        PRINT 'IdSucursal: ' + CAST(@idsucursal AS VARCHAR)
        PRINT 'IdDeposito: ' + CAST(@iddeposito AS VARCHAR)
        PRINT 'ListaArticulos: ' + ISNULL(@ListaArticulos, '(vacío)')
        PRINT ''

        -- Obtener último histórico
        SELECT TOP 1 
            @MaxMes = mes, 
            @MaxAnio = anio 
        FROM KardexContableHistorico
        WHERE IdSucursal = @idsucursal 
          AND IdDeposito = @iddeposito
        ORDER BY anio DESC, mes DESC

        PRINT '=========================================='
        PRINT 'PASO 2: ÚLTIMO HISTÓRICO DISPONIBLE'
        PRINT '=========================================='
        PRINT 'Mes Último Histórico: ' + CAST(@MaxMes AS VARCHAR)
        PRINT 'Año Último Histórico: ' + CAST(@MaxAnio AS VARCHAR)
        PRINT 'Periodo: ' + CAST(@MaxAnio AS VARCHAR) + '-' + RIGHT('0' + CAST(@MaxMes AS VARCHAR), 2)
        PRINT ''

        -- Determinar fecha de referencia según tipo
        PRINT '=========================================='
        PRINT 'PASO 3: FECHA DE REFERENCIA'
        PRINT '=========================================='
        
        IF @tipo = 2
        BEGIN
            PRINT 'Tipo 2 detectado: Se usará FechaDesde como referencia'
            PRINT 'String Original: ' + @FechaDesde
            
            SET @FechaReferenciaDate = CAST(
                SUBSTRING(@FechaDesde, 1, 4) + '-' +
                SUBSTRING(@FechaDesde, 5, 2) + '-' +
                SUBSTRING(@FechaDesde, 7, 2) + ' ' +
                SUBSTRING(@FechaDesde, 9, 2) + ':' +
                SUBSTRING(@FechaDesde, 11, 2) + ':00'
                AS DATETIME
            )
        END
        ELSE IF @tipo = 3
        BEGIN
            PRINT 'Tipo 3 detectado: Se usará FechaHasta como referencia'
            PRINT 'String Original: ' + @FechaHasta
            
            SET @FechaReferenciaDate = CAST(
                SUBSTRING(@FechaHasta, 1, 4) + '-' +
                SUBSTRING(@FechaHasta, 5, 2) + '-' +
                SUBSTRING(@FechaHasta, 7, 2) + ' ' +
                SUBSTRING(@FechaHasta, 9, 2) + ':' +
                SUBSTRING(@FechaHasta, 11, 2) + ':00'
                AS DATETIME
            )
        END
        
        PRINT 'Convertido a DateTime: ' + CONVERT(VARCHAR(20), @FechaReferenciaDate, 120)
        PRINT ''

        -- Extraer mes y año de referencia
        SET @MesReferencia = MONTH(@FechaReferenciaDate)
        SET @AnioReferencia = YEAR(@FechaReferenciaDate)
        
        PRINT '=========================================='
        PRINT 'PASO 4: EXTRAER MES Y AÑO DE REFERENCIA'
        PRINT '=========================================='
        PRINT 'Mes Referencia: ' + CAST(@MesReferencia AS VARCHAR)
        PRINT 'Año Referencia: ' + CAST(@AnioReferencia AS VARCHAR)
        PRINT 'Periodo: ' + CAST(@AnioReferencia AS VARCHAR) + '-' + RIGHT('0' + CAST(@MesReferencia AS VARCHAR), 2)
        PRINT ''

        -- Verificar si es último día del mes (solo para TIPO 2)
        IF @tipo = 2
        BEGIN
            PRINT '=========================================='
            PRINT 'PASO 4.1: VERIFICAR SI ES ÚLTIMO DÍA DEL MES'
            PRINT '=========================================='
            
            SET @UltimoDiaMes = DAY(EOMONTH(@FechaReferenciaDate))
            
            IF DAY(@FechaReferenciaDate) = @UltimoDiaMes
            BEGIN
                SET @EsUltimoDiaMes = 1
                PRINT 'Día de FechaDesde: ' + CAST(DAY(@FechaReferenciaDate) AS VARCHAR)
                PRINT 'Último día del mes: ' + CAST(@UltimoDiaMes AS VARCHAR)
                PRINT 'Resultado: ES EL ÚLTIMO DÍA DEL MES'
            END
            ELSE
            BEGIN
                SET @EsUltimoDiaMes = 0
                PRINT 'Día de FechaDesde: ' + CAST(DAY(@FechaReferenciaDate) AS VARCHAR)
                PRINT 'Último día del mes: ' + CAST(@UltimoDiaMes AS VARCHAR)
                PRINT 'Resultado: NO es el último día del mes'
            END
            PRINT ''
        END

        -- Calcular mes para búsqueda
        PRINT '=========================================='
        PRINT 'PASO 5: CALCULAR MES PARA BÚSQUEDA'
        PRINT '=========================================='
        
        IF @tipo = 2
        BEGIN
            IF @EsUltimoDiaMes = 1
            BEGIN
                -- Si es último día del mes: sumar 1 mes, luego restar 1 para histórico
                SET @FechaMesProximo = DATEADD(MONTH, 1, @FechaReferenciaDate)
                SET @MesProximo = MONTH(@FechaMesProximo)
                SET @AnioProximo = YEAR(@FechaMesProximo)
                
                PRINT 'TIPO 2 - ÚLTIMO DÍA DEL MES:'
                PRINT 'Paso 1: Sumar 1 mes a la fecha'
                PRINT 'Fecha Referencia: ' + CONVERT(VARCHAR(20), @FechaReferenciaDate, 120)
                PRINT 'Sumando 1 mes...'
                PRINT 'Fecha Mes Próximo: ' + CONVERT(VARCHAR(20), @FechaMesProximo, 120)
                PRINT 'Mes Próximo: ' + CAST(@MesProximo AS VARCHAR)
                PRINT 'Año Próximo: ' + CAST(@AnioProximo AS VARCHAR)
                PRINT ''
                PRINT 'Paso 2: Restar 1 al mes próximo para búsqueda en histórico'
                
                -- Restar 1 mes al mes próximo para histórico
                SET @FechaMesAnterior = DATEADD(MONTH, -1, @FechaMesProximo)
                SET @MesAnterior = MONTH(@FechaMesAnterior)
                SET @AnioAnterior = YEAR(@FechaMesAnterior)
                
                PRINT 'Mes para búsqueda en histórico: ' + CAST(@MesAnterior AS VARCHAR)
                PRINT 'Año para búsqueda en histórico: ' + CAST(@AnioAnterior AS VARCHAR)
                PRINT 'Periodo a buscar: ' + CAST(@AnioAnterior AS VARCHAR) + '-' + RIGHT('0' + CAST(@MesAnterior AS VARCHAR), 2)
            END
            ELSE
            BEGIN
                -- Si NO es último día del mes, restar 1 mes
                SET @FechaMesAnterior = DATEADD(MONTH, -1, @FechaReferenciaDate)
                SET @MesAnterior = MONTH(@FechaMesAnterior)
                SET @AnioAnterior = YEAR(@FechaMesAnterior)
                
                PRINT 'TIPO 2 - NO es último día: Se RESTARÁ 1 MES'
                PRINT 'Fecha Referencia: ' + CONVERT(VARCHAR(20), @FechaReferenciaDate, 120)
                PRINT 'Restando 1 mes...'
                PRINT 'Fecha Mes Anterior: ' + CONVERT(VARCHAR(20), @FechaMesAnterior, 120)
                PRINT 'Mes para búsqueda en histórico: ' + CAST(@MesAnterior AS VARCHAR)
                PRINT 'Año para búsqueda en histórico: ' + CAST(@AnioAnterior AS VARCHAR)
                PRINT 'Periodo a buscar: ' + CAST(@AnioAnterior AS VARCHAR) + '-' + RIGHT('0' + CAST(@MesAnterior AS VARCHAR), 2)
            END
        END
        ELSE IF @tipo = 3
        BEGIN
            -- TIPO 3 siempre resta 1 mes
            SET @FechaMesAnterior = DATEADD(MONTH, -1, @FechaReferenciaDate)
            SET @MesAnterior = MONTH(@FechaMesAnterior)
            SET @AnioAnterior = YEAR(@FechaMesAnterior)
            
            PRINT 'TIPO 3: Se RESTARÁ 1 MES a la fecha de referencia'
            PRINT 'Fecha Referencia: ' + CONVERT(VARCHAR(20), @FechaReferenciaDate, 120)
            PRINT 'Restando 1 mes...'
            PRINT 'Fecha Mes Anterior: ' + CONVERT(VARCHAR(20), @FechaMesAnterior, 120)
            PRINT 'Mes para búsqueda: ' + CAST(@MesAnterior AS VARCHAR)
            PRINT 'Año para búsqueda: ' + CAST(@AnioAnterior AS VARCHAR)
            PRINT 'Periodo: ' + CAST(@AnioAnterior AS VARCHAR) + '-' + RIGHT('0' + CAST(@MesAnterior AS VARCHAR), 2)
        END
        PRINT ''

        -- Verificar existencia en histórico
        PRINT '=========================================='
        PRINT 'PASO 6: VERIFICAR EXISTENCIA EN HISTÓRICO'
        PRINT '=========================================='
        PRINT 'Buscando en KardexContableHistorico:'
        PRINT '  Mes: ' + CAST(@MesAnterior AS VARCHAR)
        PRINT '  Año: ' + CAST(@AnioAnterior AS VARCHAR)
        PRINT '  Sucursal: ' + CAST(@idsucursal AS VARCHAR)
        PRINT '  Depósito: ' + CAST(@iddeposito AS VARCHAR)
        PRINT ''
        
        IF EXISTS (
            SELECT 1 
            FROM KardexContableHistorico 
            WHERE mes = @MesAnterior 
              AND anio = @AnioAnterior
              AND IdSucursal = @idsucursal 
              AND IdDeposito = @iddeposito
        )
        BEGIN
            SET @Mes = @MesAnterior
            SET @Anio = @AnioAnterior
            SET @ExisteHistorico = 1

            IF @tipo = 2
            BEGIN
                PRINT '>>> RESULTADO: SÍ EXISTE <<<'
                PRINT 'Se encontró el periodo ' + CAST(@AnioAnterior AS VARCHAR) + '-' + RIGHT('0' + CAST(@MesAnterior AS VARCHAR), 2)
                PRINT 'DECISIÓN TIPO 2: Se usará este mes/año para histórico'
                PRINT '  Mes Seleccionado: ' + CAST(@Mes AS VARCHAR)
                PRINT '  Año Seleccionado: ' + CAST(@Anio AS VARCHAR)
            END
            ELSE IF @tipo = 3
            BEGIN
                SET @PrimerDiaMes = CAST(
                    CAST(@AnioReferencia AS VARCHAR(4)) + '-' + 
                    RIGHT('0' + CAST(@MesReferencia AS VARCHAR(2)), 2) + '-01 00:00:00' 
                    AS DATETIME
                )
            
                SET @FechaDesde = 
                    CONVERT(VARCHAR(4), YEAR(@PrimerDiaMes)) +
                    RIGHT('0' + CONVERT(VARCHAR(2), MONTH(@PrimerDiaMes)), 2) +
                    '010000'
                
                PRINT '>>> RESULTADO: SÍ EXISTE <<<'
                PRINT 'Se encontró el periodo ' + CAST(@AnioAnterior AS VARCHAR) + '-' + RIGHT('0' + CAST(@MesAnterior AS VARCHAR), 2)
                PRINT 'DECISIÓN TIPO 3: Se usará el mes anterior'
                PRINT '  Mes Seleccionado: ' + CAST(@Mes AS VARCHAR)
                PRINT '  Año Seleccionado: ' + CAST(@Anio AS VARCHAR)
                PRINT '  FechaDesde: AJUSTADA al día 1 del mes de referencia'
            END
        END
        ELSE
        BEGIN
            SET @Mes = @MaxMes
            SET @Anio = @MaxAnio
            SET @ExisteHistorico = 0

            SET @PrimerDiaMes = CAST(
                CAST(@Anio AS VARCHAR(4)) + '-' + 
                RIGHT('0' + CAST(@Mes AS VARCHAR(2)), 2) + '-01 00:00:00' 
                AS DATETIME
            )
            
            SET @FechaDesde = 
                CONVERT(VARCHAR(4), YEAR(@PrimerDiaMes)) +
                RIGHT('0' + CONVERT(VARCHAR(2), MONTH(@PrimerDiaMes)), 2) +
                '010000'
            
            PRINT '>>> RESULTADO: NO EXISTE <<<'
            PRINT 'No se encontró el periodo ' + CAST(@AnioAnterior AS VARCHAR) + '-' + RIGHT('0' + CAST(@MesAnterior AS VARCHAR), 2)
            PRINT 'DECISIÓN: Se usará el último mes del histórico'
            PRINT '  Mes Seleccionado: ' + CAST(@Mes AS VARCHAR)
            PRINT '  Año Seleccionado: ' + CAST(@Anio AS VARCHAR)
            PRINT '  FechaDesde: AJUSTADA al día 1 del último mes disponible'
        END
        PRINT ''

        PRINT '=========================================='
        PRINT 'PASO 7: RESUMEN PRIMER DÍA DEL MES'
        PRINT '=========================================='
        PRINT 'Mes Seleccionado: ' + CAST(@Mes AS VARCHAR)
        PRINT 'Año Seleccionado: ' + CAST(@Anio AS VARCHAR)
        IF @PrimerDiaMes IS NOT NULL
        BEGIN
            PRINT 'Primer Día del Mes: ' + CONVERT(VARCHAR(20), @PrimerDiaMes, 120)
        END
        ELSE
        BEGIN
            PRINT 'Primer Día del Mes: Será calculado antes de ejecutar SP (TIPO 2)'
        END
        PRINT ''

        PRINT '=========================================='
        PRINT 'PASO 8: RESUMEN DE FECHAS FINALES'
        PRINT '=========================================='
        PRINT 'FechaDesde actual: ' + @FechaDesde
        PRINT 'FechaHasta para SP: ' + @FechaHasta
        PRINT ''

        PRINT '=========================================='
        PRINT 'PASO 9: RESUMEN FINAL'
        PRINT '=========================================='
        PRINT 'TIPO DE CONSULTA: ' + CAST(@tipo AS VARCHAR)
        PRINT ''
        PRINT '--- FECHAS ---'
        PRINT 'FechaDesde Original:  ' + @FechaDesdeOriginal
        PRINT 'FechaHasta Final:     ' + @FechaHasta
        PRINT ''
        PRINT '--- REFERENCIA USADA ---'
        IF @tipo = 2
            PRINT 'Se usó como referencia: FechaDesde (TIPO 2)'
        ELSE
            PRINT 'Se usó como referencia: FechaHasta (TIPO 3)'
        PRINT 'Mes Referencia: ' + CAST(@MesReferencia AS VARCHAR)
        PRINT 'Año Referencia: ' + CAST(@AnioReferencia AS VARCHAR)
        PRINT ''
        PRINT '--- CÁLCULO MES PARA CONSULTA ---'
        IF @tipo = 2
        BEGIN
            IF @EsUltimoDiaMes = 1
                PRINT 'TIPO 2: Es último día - Se sumó 1 mes y luego se restó 1 para histórico'
            ELSE
                PRINT 'TIPO 2: NO es último día - Se RESTÓ 1 mes'
            PRINT 'Mes Calculado: ' + CAST(@MesAnterior AS VARCHAR)
            PRINT 'Año Calculado: ' + CAST(@AnioAnterior AS VARCHAR)
        END
        ELSE
        BEGIN
            PRINT 'TIPO 3: Se RESTÓ 1 mes a FechaHasta'
            PRINT 'Mes Anterior Calculado: ' + CAST(@MesAnterior AS VARCHAR)
            PRINT 'Año Anterior Calculado: ' + CAST(@AnioAnterior AS VARCHAR)
        END
        PRINT 'Existe en Histórico: ' + CASE WHEN @ExisteHistorico = 1 THEN 'SÍ' ELSE 'NO' END
        PRINT ''
        PRINT '--- MES/AÑO USADO PARA CONSULTA ---'
        PRINT 'Mes: ' + CAST(@Mes AS VARCHAR)
        PRINT 'Año: ' + CAST(@Anio AS VARCHAR)
        PRINT 'Observación: ' + CASE 
            WHEN @ExisteHistorico = 1 THEN 'Periodo encontrado en histórico'
            ELSE 'Usando último histórico disponible (' + CAST(@MaxAnio AS VARCHAR) + '-' + RIGHT('0' + CAST(@MaxMes AS VARCHAR), 2) + ')'
        END
        PRINT ''
        
        -- *** AJUSTE DE FECHADESDE PARA TIPO 2 ANTES DE EJECUTAR SP ***
        IF @tipo = 2
        BEGIN
            PRINT '=========================================='
            PRINT 'AJUSTE ESPECIAL TIPO 2: FECHA PARA SP'
            PRINT '=========================================='
            
            IF @EsUltimoDiaMes = 1
            BEGIN
                -- Si es último día del mes, MANTENER fecha original
                PRINT 'Es último día del mes: Se MANTIENE la FechaDesde ORIGINAL'
                PRINT 'FechaDesde para SP: ' + @FechaDesde + ' (SIN CAMBIOS)'
            END
            ELSE
            BEGIN
                -- Si NO es último día del mes, usar primer día del mes ACTUAL
                PRINT 'NO es último día del mes: Se usará el PRIMER DÍA del MES ACTUAL'
                
                SET @PrimerDiaMes = CAST(
                    CAST(@AnioReferencia AS VARCHAR(4)) + '-' + 
                    RIGHT('0' + CAST(@MesReferencia AS VARCHAR(2)), 2) + '-01 00:00:00' 
                    AS DATETIME
                )
                
                SET @FechaDesde = 
                    CONVERT(VARCHAR(4), YEAR(@PrimerDiaMes)) +
                    RIGHT('0' + CONVERT(VARCHAR(2), MONTH(@PrimerDiaMes)), 2) +
                    '010000'
                
                PRINT 'Mes actual: ' + CAST(@MesReferencia AS VARCHAR)
                PRINT 'Año actual: ' + CAST(@AnioReferencia AS VARCHAR)
                PRINT 'FechaDesde ajustada para SP: ' + @FechaDesde
                PRINT 'Corresponde a: ' + CONVERT(VARCHAR(20), @PrimerDiaMes, 120)
            END
            PRINT ''
        END
        
        PRINT '>>> EJECUTANDO PROCEDIMIENTO ALMACENADO <<<'
        PRINT '=========================================='
        PRINT 'Parámetros:'
        PRINT '  @FechaDesde: ' + @FechaDesde
        PRINT '  @FechaHasta: ' + @FechaHasta
        PRINT '  @tipo: ' + CAST(@tipo AS VARCHAR)
        PRINT ''

        -- Cargar datos
        INSERT INTO #TemporalKardexArticulo1
        EXEC sp_kardexAlmacenPM_Optimizado1 
            @FechaDesde,
            @FechaHasta,
            @ListaArticulos,
            @idsucursal,
            @iddeposito,
            @tipo

        -- Consolidar existencias
        INSERT INTO #TemporalExistencias1
        SELECT
            idproducto,
            Codigoarticulo,
            descarticulo, 
            NombreSucursal,
            NombreDeposito,
            SUM(saldoinicial) AS SaldoInicial,
            CASE 
                WHEN SUM(saldoInicial) > 0 
                THEN SUM(saldoInicialvalor) / SUM(saldoInicial) 
                ELSE 0 
            END AS pminicial,
            SUM(saldoInicialvalor) AS SaldoInicialvalor,
            SUM(CASE WHEN idcomprobante != 18 THEN entrada ELSE 0 END) AS entrada,
            CASE 
                WHEN SUM(CASE WHEN idcomprobante != 18 THEN entrada ELSE 0 END) > 0 
                THEN SUM(CASE WHEN idcomprobante != 18 THEN entradavalor ELSE 0 END) / 
                     SUM(CASE WHEN idcomprobante != 18 THEN entrada ELSE 0 END) 
                ELSE 0 
            END AS pmentrada,
            SUM(CASE WHEN idcomprobante != 18 THEN entradavalor ELSE 0 END) AS entradavalor,
            SUM(CASE WHEN idcomprobante = 18 THEN entrada ELSE 0 END) AS entradaTransferencia,
            CASE 
                WHEN SUM(CASE WHEN idcomprobante = 18 THEN entrada ELSE 0 END) > 0 
                THEN SUM(CASE WHEN idcomprobante = 18 THEN entradavalor ELSE 0 END) / 
                     SUM(CASE WHEN idcomprobante = 18 THEN entrada ELSE 0 END) 
                ELSE 0 
            END AS pmentradaTransferencia,
            SUM(CASE WHEN idcomprobante = 18 THEN entradavalor ELSE 0 END) AS entradavalorTransferencia,
            SUM(CASE WHEN idcomprobante != 19 THEN salida ELSE 0 END) AS salida,
            CASE 
                WHEN SUM(CASE WHEN idcomprobante != 19 THEN salida ELSE 0 END) > 0 
                THEN SUM(CASE WHEN idcomprobante != 19 THEN salidavalor ELSE 0 END) / 
                     SUM(CASE WHEN idcomprobante != 19 THEN salida ELSE 0 END) 
                ELSE 0 
            END AS pmsalida,
            SUM(CASE WHEN idcomprobante != 19 THEN salidavalor ELSE 0 END) AS salidavalor,
            SUM(CASE WHEN idcomprobante = 19 THEN salida ELSE 0 END) AS salidaTransferencia,
            CASE 
                WHEN SUM(CASE WHEN idcomprobante = 19 THEN salida ELSE 0 END) > 0 
                THEN SUM(CASE WHEN idcomprobante = 19 THEN salidavalor ELSE 0 END) / 
                     SUM(CASE WHEN idcomprobante = 19 THEN salida ELSE 0 END) 
                ELSE 0 
            END AS pmsalidaTransferencia,
            SUM(CASE WHEN idcomprobante = 19 THEN salidavalor ELSE 0 END) AS salidavalorTransferencia,
            SUM(saldoInicial) + SUM(entrada) - SUM(salida) AS saldo, 
            CASE 
                WHEN (SUM(saldoInicial) + SUM(entrada) - SUM(salida)) > 0 
                THEN (SUM(saldoInicialvalor) + SUM(entradavalor) - SUM(salidavalor)) / 
                     (SUM(saldoInicial) + SUM(entrada) - SUM(salida)) 
                ELSE 0 
            END AS pmsaldo,
            SUM(saldoInicialvalor) + SUM(entradavalor) - SUM(salidavalor) AS saldovalor,
            CASE 
                WHEN SUM(saldoInicial) > 0 
                THEN SUM(saldoinicialvalorMoneda) / SUM(saldoInicial) 
                ELSE 0 
            END AS pminicialMoneda,
            SUM(saldoinicialvalorMoneda) AS SaldoInicialvalorMoneda, 
            CASE 
                WHEN SUM(CASE WHEN idcomprobante != 18 THEN entrada ELSE 0 END) > 0 
                THEN SUM(CASE WHEN idcomprobante != 18 THEN entradavalorMoneda ELSE 0 END) / 
                     SUM(CASE WHEN idcomprobante != 18 THEN entrada ELSE 0 END) 
                ELSE 0 
            END AS pmentradaMoneda,
            CASE 
                WHEN SUM(CASE WHEN idcomprobante = 18 THEN entrada ELSE 0 END) > 0 
                THEN SUM(CASE WHEN idcomprobante = 18 THEN entradavalorMoneda ELSE 0 END) / 
                     SUM(CASE WHEN idcomprobante = 18 THEN entrada ELSE 0 END) 
                ELSE 0 
            END AS pmentradaMonedaTransferencia,
            SUM(CASE WHEN idcomprobante != 18 THEN entradavalorMoneda ELSE 0 END) AS entradavalorMoneda,
            SUM(CASE WHEN idcomprobante = 18 THEN entradavalorMoneda ELSE 0 END) AS entradavalorMonedaTransferencia,
            CASE 
                WHEN SUM(CASE WHEN idcomprobante != 19 THEN salida ELSE 0 END) > 0 
                THEN SUM(CASE WHEN idcomprobante != 19 THEN salidavalorMoneda ELSE 0 END) / 
                     SUM(CASE WHEN idcomprobante != 19 THEN salida ELSE 0 END) 
                ELSE 0 
            END AS pmsalidaMoneda,
            CASE 
                WHEN SUM(CASE WHEN idcomprobante = 19 THEN salida ELSE 0 END) > 0 
                THEN SUM(CASE WHEN idcomprobante = 19 THEN salidavalorMoneda ELSE 0 END) / 
                     SUM(CASE WHEN idcomprobante = 19 THEN salida ELSE 0 END) 
                ELSE 0 
            END AS pmsalidaMonedaTransferencia,
            SUM(CASE WHEN idcomprobante != 19 THEN salidavalorMoneda ELSE 0 END) AS salidavalorMoneda,
            SUM(CASE WHEN idcomprobante = 19 THEN salidavalorMoneda ELSE 0 END) AS salidavalorMonedaTransferencia,
            CASE 
                WHEN (SUM(saldoInicial) + SUM(entrada) - SUM(salida)) > 0 
                THEN (SUM(saldoinicialvalorMoneda) + SUM(entradavalorMoneda) - SUM(salidavalorMoneda)) / 
                     (SUM(saldoInicial) + SUM(entrada) - SUM(salida)) 
                ELSE 0 
            END AS pmsaldoMoneda,
            SUM(saldoInicialvalorMoneda) + SUM(entradavalorMoneda) - SUM(salidavalorMoneda) AS saldovalorMoneda
        FROM #TemporalKardexArticulo1
        GROUP BY 
            Codigoarticulo,
            descarticulo,
            NombreSucursal,
            NombreDeposito,
            idproducto

        -- Insertar en Kardex Contable
        INSERT INTO #TemporalKardexContable
        SELECT * 
        FROM (
            SELECT 
                idproducto,
                CodigoArticulo,
                DescArticulo,
                NombreSucursal,
                NombreDeposito,
                saldo AS SaldoInicial,
                pmsaldo AS pminicial,
                saldovalor AS SaldoInicialvalor,
                0 AS entrada,
                0 AS pmentrada,
                0 AS entradavalor,
                0 AS entradaTransferencia,
                0 AS pmentradaTransferencia,
                0 AS entradavalorTransferencia,
                0 AS salida,
                0 AS pmsalida,
                0 AS salidavalor,
                0 AS salidaTransferencia,
                0 AS pmsalidaTransferencia,
                0 AS salidavalorTransferencia,
                saldo,
                pmsaldo,
                saldovalor,
                pmsaldoMoneda AS pminicialMoneda,
                saldovalorMoneda AS SaldoInicialvalorMoneda,
                0 AS pmentradaMoneda,
                0 AS entradavalorMoneda,
                0 AS pmentradaMonedaTransferencia,
                0 AS entradavalorMonedaTransferencia,
                0 AS pmsalidaMoneda,
                0 AS salidavalorMoneda,
                0 AS pmsalidaMonedaTransferencia,
                0 AS salidavalorMonedaTransferencia,
                pmsaldoMoneda,
                saldovalorMoneda 
            FROM KardexContableHistorico 
            WHERE idproducto NOT IN (SELECT idproducto FROM #TemporalExistencias1)  
                AND IdSucursal = @idsucursal 
                AND IdDeposito = @iddeposito 
                AND mes = @Mes
                AND anio = @Anio
                AND (@ListaArticulos = '' OR @ListaArticulos IS NULL OR CodigoArticulo = @ListaArticulos)

            UNION ALL 

            SELECT 
                idproducto,
                CodigoArticulo COLLATE Modern_Spanish_CI_AS,
                DescArticulo COLLATE Modern_Spanish_CI_AS,
                NombreSucursal COLLATE Modern_Spanish_CI_AS,
                NombreDeposito COLLATE Modern_Spanish_CI_AS,
                SaldoInicial,
                pminicial,
                SaldoInicialvalor,
                entrada,
                pmentrada,
                entradavalor,
                entradaTransferencia,
                pmentradaTransferencia,
                entradavalorTransferencia,
                salida,
                pmsalida,
                salidavalor,
                salidaTransferencia,
                pmsalidaTransferencia,
                salidavalorTransferencia,
                saldo,
                pmsaldo,
                saldovalor,
                pminicialMoneda,
                SaldoInicialvalorMoneda,
                pmentradaMoneda,
                entradavalorMoneda,
                pmentradaMonedaTransferencia,
                entradavalorMonedaTransferencia,
                pmsalidaMoneda,
                salidavalorMoneda,
                pmsalidaMonedaTransferencia,
                salidavalorMonedaTransferencia,
                pmsaldoMoneda,
                saldovalorMoneda 
            FROM #TemporalExistencias1
        ) AS x

        -- Limpiar registros en cero
        DELETE FROM #TemporalKardexContable  
        WHERE dbo.EsCeroContable((
            SaldoInicial + pminicial + SaldoInicialvalor + 
            entrada + pmentrada + entradavalor + 
            salida + pmsalida + salidavalor + 
            saldo + pmsaldo + saldovalor +
            pminicialMoneda + SaldoInicialvalorMoneda + 
            pmentradaMoneda + entradavalorMoneda + 
            pmsalidaMoneda + salidavalorMoneda + 
            pmsaldoMoneda + saldovalorMoneda +
            entradaTransferencia + pmentradaTransferencia + entradavalorTransferencia +
            salidaTransferencia + pmsalidaTransferencia + salidavalorTransferencia +
            pmentradaMonedaTransferencia + entradavalorMonedaTransferencia +
            pmsalidaMonedaTransferencia + salidavalorMonedaTransferencia
        )) = 1

        -- Resultados según tipo
        IF @tipo = 2
        BEGIN 
            SELECT * 
            FROM #TemporalKardexContable 
            ORDER BY descarticulo
        END
        
        IF @tipo = 3
        BEGIN
            INSERT INTO #existenciasfinal
            SELECT 
                e.codigoarticulo,
                e.descarticulo, 
                e.NombreSucursal,
                e.NombreDeposito,
                e.saldo,
                e.pmsaldo,
                e.saldovalor,
                '' AS CodigoFabrica,
                ISNULL(m.Descripcion, '') AS marca,
                ISNULL(mo.Descripcion, '') AS modelo,
                ISNULL(a.Ubica, '') AS Ubica,
                ISNULL(g.Descripcion, '') AS categoria,
                CONVERT(VARCHAR(20), a.StockMinimo) AS StockMinimo,
                CASE WHEN e.saldo IS NOT NULL THEN e.saldo ELSE 0 END - ISNULL(a.StockMinimo, 0) AS diferencia,
                CASE 
                    WHEN a.AplicaStockMinimo = 0 THEN 'No requiere reposición de stock'
                    WHEN ISNULL(a.StockMinimo, 0) > 0 THEN 
                        CASE 
                            WHEN (CASE WHEN e.saldo IS NOT NULL THEN e.saldo ELSE 0 END) - ISNULL(a.StockMinimo, 0) > 0 
                            THEN 'Stock Suficiente' 
                            WHEN (CASE WHEN e.saldo IS NOT NULL THEN e.saldo ELSE 0 END) - ISNULL(a.StockMinimo, 0) <= 0 
                            THEN 'Requerir material' 
                        END
                    ELSE 'Sin datos mínimos'
                END AS observacion,
                a.IdArticulo,
                ISNULL(a.UnidadDeMedida, '') AS UnidadDeMedida,
                e.pmsaldoMoneda,
                e.saldovalorMoneda
            FROM #TemporalKardexContable e 
            INNER JOIN Articulo a ON e.idproducto = a.IdArticulo
            LEFT JOIN Marca m ON m.IdMarca = a.IdMarca
            LEFT JOIN Modelo mo ON mo.IdModelo = a.IdModelo
            LEFT JOIN GrupoArticulo g ON g.IdGrupoArticulo = a.IdGrupoArticulo 	
            
            UNION ALL 
            
            SELECT 
                a.codigoarticulo COLLATE SQL_Latin1_General_CP1_CI_AS,
                a.Descripcion COLLATE SQL_Latin1_General_CP1_CI_AS, 
                '',
                '',
                0,
                0,
                0,
                '' AS CodigoFabrica,
                ISNULL(m.Descripcion, '') COLLATE SQL_Latin1_General_CP1_CI_AS AS marca,
                ISNULL(mo.Descripcion, '') COLLATE SQL_Latin1_General_CP1_CI_AS AS modelo,
                ISNULL(a.Ubica, '') COLLATE SQL_Latin1_General_CP1_CI_AS AS Ubica,
                ISNULL(g.Descripcion, '') COLLATE SQL_Latin1_General_CP1_CI_AS AS categoria,
                CONVERT(VARCHAR(20), a.StockMinimo) COLLATE SQL_Latin1_General_CP1_CI_AS AS StockMinimo,
                0 - ISNULL(a.StockMinimo, 0) AS diferencia,
                CASE 
                    WHEN a.AplicaStockMinimo = 0 THEN 'No requiere reposición de stock'
                    WHEN ISNULL(a.StockMinimo, 0) > 0 THEN
                        CASE 
                            WHEN 0 - ISNULL(a.StockMinimo, 0) > 0 THEN 'Stock Suficiente'
                            WHEN 0 - ISNULL(a.StockMinimo, 0) <= 0 THEN 'Requerir material'
                        END
                    ELSE 'Sin datos mínimos'
                END COLLATE SQL_Latin1_General_CP1_CI_AS AS observacion,
                a.IdArticulo,
                ISNULL(a.UnidadDeMedida, '') COLLATE SQL_Latin1_General_CP1_CI_AS AS UnidadDeMedida,
                0 AS pmsaldoMoneda,
                0 AS saldovalorMoneda
            FROM articulo a
            LEFT JOIN Marca m ON m.IdMarca = a.IdMarca
            LEFT JOIN Modelo mo ON mo.IdModelo = a.IdModelo
            LEFT JOIN GrupoArticulo g ON g.IdGrupoArticulo = a.IdGrupoArticulo 
            WHERE a.IsServicio = 0 
                AND a.idEstado = 1 
                AND a.idarticulo NOT IN (SELECT e.idproducto FROM #TemporalKardexContable e)
                AND (@ListaArticulos = '' OR @ListaArticulos IS NULL OR a.codigoarticulo = @ListaArticulos)

            SELECT * FROM #existenciasfinal
        END
    END

drop table #TemporalKardexArticulo1
drop table #TemporalKardexArticulo2
drop table #TemporalExistencias1
drop table #TemporalExistencias2
drop table #TemporalKardexContable
drop table #TemporalExistencias3
drop table #codigosConRotacion
drop table #codigosSinRotacion
drop table #CodigosSinRotacionFechaMaxima
drop table #FechasAjustadas
drop table #existenciasfinal

set fmtonly on