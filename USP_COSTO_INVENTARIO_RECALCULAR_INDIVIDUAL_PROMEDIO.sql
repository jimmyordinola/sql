USE [ERP_ECHA]
GO
/****** Object:  StoredProcedure [inventario].[USP_COSTO_INVENTARIO_RECALCULAR_INDIVIDUAL_PROMEDIO]    Script Date: 15/01/2026 13:18:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [inventario].[USP_COSTO_INVENTARIO_RECALCULAR_INDIVIDUAL_PROMEDIO]
@P_RUC_EMPRESA VARCHAR(11),
@P_CODIGO_PRODUCTO VARCHAR(7),
@P_FECHA_MOVIMIENTO DATETIME,
@P_DEBUG BIT = 1
AS
--DECLARE
--@P_RUC_EMPRESA VARCHAR(11) = '20513423307',
--@P_CODIGO_PRODUCTO VARCHAR(7) = 'PD00117',
--@P_FECHA_MOVIMIENTO DATETIME = '20000101',
--@P_DEBUG BIT = 1;

DECLARE
@P_CODIGO_INVENTARIO CHAR(12) = NULL

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE
@IB_KardexAlm BIT,
@IB_KardexUM BIT,
@TipoCosto CHAR(10),
@P_FECHA_HASTA DATETIME; -- Límite superior calculado internamente

SELECT TOP (1)
    @IB_KardexAlm = ISNULL(IB_KardexAlm,0),
    @IB_KardexUM  = ISNULL(IB_KardexUM,0),
    @TipoCosto    = IC_TipoCostoInventario
FROM
	CfgGeneral
WHERE
	RucE = @P_RUC_EMPRESA;

IF (@TipoCosto <> 'PROMEDIO')
	RETURN;

-- Fecha límite FIJA para evitar procesar millones de movimientos innecesarios
-- Solo procesa movimientos hasta el 31 de mayo 2025 23:59:59
-- (incluye TODO mayo para asegurar que capture movimientos de abril)
SET @P_FECHA_HASTA = CAST('2025-05-31T23:59:59' AS DATETIME);

-- Mostrar rango de fechas a procesar (solo si DEBUG activado)
IF (@P_DEBUG = 1)
BEGIN
	PRINT '========================================';
	PRINT 'RECALCULO OPTIMIZADO - RANGO DE FECHAS';
	PRINT '========================================';
	PRINT 'Producto: ' + @P_CODIGO_PRODUCTO;
	PRINT 'Fecha Desde: ' + CONVERT(VARCHAR(20), @P_FECHA_MOVIMIENTO, 120);
	PRINT 'Fecha Hasta: ' + CONVERT(VARCHAR(20), @P_FECHA_HASTA, 120);
	PRINT 'Días a procesar: ' + CAST(DATEDIFF(DAY, @P_FECHA_MOVIMIENTO, @P_FECHA_HASTA) AS VARCHAR(10));
	PRINT '========================================';
	PRINT '';
END

---------------------------------------------------------------------
-- Precalcular piezas reutilizables en #temps con índices
---------------------------------------------------------------------
IF OBJECT_ID('tempdb..#BaseMov') IS NOT NULL
	DROP TABLE #BaseMov;

SELECT
	i2.RucE,
	i2.Cd_Inv,
	id2.Item,
	id2.Cd_Prod,
	id2.ID_UMP,
	id2.IC_ES,
	id2.Cd_Alm,
	id2.Codigo,
	i2.Cd_TO,
	i2.FechaMovimiento,
	ci2.Correlativo,
	ci2.Cantidad,
	ci2.Costo_MN,
	ci2.Costo_ME,
	IC_TipoCostoInventario = ISNULL(ci2.IC_TipoCostoInventario,'M')
INTO
	#BaseMov
FROM
	Inventario2 i2
	INNER JOIN InventarioDet2 id2 ON id2.RucE = i2.RucE AND id2.Cd_Inv = i2.Cd_Inv
	INNER JOIN CostoInventario ci2 ON ci2.RucE = id2.RucE AND ci2.Cd_Inv = id2.Cd_Inv AND ci2.Item  = id2.Item
WHERE
	i2.RucE = @P_RUC_EMPRESA
	--AND i2.Cd_Inv=isnull(@P_CODIGO_INVENTARIO,i2.Cd_Inv)
	AND id2.Cd_Prod = @P_CODIGO_PRODUCTO
	AND ISNULL(ci2.IC_TipoCostoInventario,'M') = 'M'
	AND i2.FechaMovimiento >= @P_FECHA_MOVIMIENTO
	AND i2.FechaMovimiento <= @P_FECHA_HASTA  -- LÍMITE SUPERIOR: Última fecha + 1 mes
	AND (ISNULL(i2.C_IB_INTEGRACION_EXTERNA,0) = 0 OR (ISNULL(i2.C_IB_INTEGRACION_EXTERNA,0)=1 AND ISNULL(i2.C_IB_RECALCULAR_COSTOS,0)=1));

CREATE UNIQUE CLUSTERED INDEX
	IX_BaseMov
ON
	#BaseMov (RucE, Cd_Inv, Item);

CREATE NONCLUSTERED INDEX
	IX_BaseMov_Prod
ON
	#BaseMov (RucE, Cd_Prod, ID_UMP);

CREATE NONCLUSTERED INDEX
	IX_BaseMov_Fecha
ON
	#BaseMov (RucE, FechaMovimiento, Cd_Inv, Item);

-- Tipo de movimiento por Cd_Inv
IF OBJECT_ID('tempdb..#TipoMov') IS NOT NULL
	DROP TABLE #TipoMov;

SELECT
	bm.RucE,
	bm.Cd_Inv,
	TipoMovimientoInventario =
		CASE WHEN SUM(CASE WHEN bm.IC_ES='E' THEN 1 ELSE 0 END) = 0 THEN 'S'
			 WHEN SUM(CASE WHEN bm.IC_ES='S' THEN 1 ELSE 0 END) = 0 THEN 'E'
			 ELSE 'M'
		END
INTO
	#TipoMov
FROM
	#BaseMov bm
GROUP BY
	bm.RucE,
	bm.Cd_Inv;

CREATE UNIQUE CLUSTERED INDEX
	IX_TipoMov
ON
	#TipoMov (RucE, Cd_Inv);

-- Factor de conversión UM
IF OBJECT_ID('tempdb..#Pum') IS NOT NULL
	DROP TABLE #Pum;

SELECT
	p.RucE,
	p.Cd_Prod,
	p.ID_UMP,
	FactorCalculado =
		CASE WHEN p.IC_CL='M' THEN p.Factor
			 WHEN p.IC_CL='D' THEN (CASE WHEN p.Factor=0 THEN 1 ELSE 1/p.Factor END)
			 ELSE 1
		END
INTO
	#Pum
FROM
	Prod_UM p
	INNER JOIN
	(
		SELECT DISTINCT
			RucE,
			Cd_Prod,
			ID_UMP
		FROM
			#BaseMov
	) x ON x.RucE = p.RucE AND x.Cd_Prod = p.Cd_Prod AND x.ID_UMP = p.ID_UMP
WHERE
	p.RucE = @P_RUC_EMPRESA;

CREATE UNIQUE CLUSTERED INDEX
	IX_Pum
ON
	#Pum (RucE, Cd_Prod, ID_UMP);

-- OF
IF OBJECT_ID('tempdb..#OF') IS NOT NULL
	DROP TABLE #OF;

SELECT DISTINCT
	mo.RucE, mo.Cd_OF_Origen
INTO
	#OF
FROM
	#BaseMov bm
	INNER JOIN MovimientoInventario mo ON mo.RucE = bm.RucE AND mo.Cd_Inv_Destino = bm.Cd_Inv AND mo.Item_Destino = bm.Item
WHERE
	mo.RucE = @P_RUC_EMPRESA
	AND mo.Cd_OF_Origen IS NOT NULL;

CREATE UNIQUE CLUSTERED INDEX
	IX_OF
ON
	#OF (RucE, Cd_OF_Origen);

-- Gastos producción por OF
IF OBJECT_ID('tempdb..#Gastos') IS NOT NULL
	DROP TABLE #Gastos;

SELECT
	o.RucE,
	o.Cd_OF_Origen AS Cd_OF,
	Gasto_MN = SUM(ISNULL(c.Costo,0)),
	Gasto_ME = SUM(ISNULL(c.Costo_ME,0))
INTO
	#Gastos
FROM
	#OF o
	JOIN CptoCostoOF c ON c.RucE = o.RucE AND c.Cd_OF = o.Cd_OF_Origen
WHERE
	c.RucE=@P_RUC_EMPRESA
	AND ISNULL(c.IB_Eliminado,0)=0
GROUP BY
	o.RucE, o.Cd_OF_Origen;

CREATE UNIQUE CLUSTERED INDEX
	IX_Gastos
ON
	#Gastos (RucE, Cd_OF);

-- Envases/Embalajes por OF
IF OBJECT_ID('tempdb..#EnvEmb') IS NOT NULL
	DROP TABLE #EnvEmb;

SELECT
	o.RucE,
	o.Cd_OF_Origen AS Cd_OF,
	CostoEE_MN = SUM(ISNULL(e.Costo,0)),
	CostoEE_ME = SUM(ISNULL(e.Costo_ME,0))
INTO
	#EnvEmb
FROM
	#OF o
	INNER JOIN EnvEmbOF e ON e.RucE = o.RucE AND e.Cd_OF = o.Cd_OF_Origen
WHERE
	e.RucE=@P_RUC_EMPRESA AND ISNULL(e.IB_Eliminado,0)=0
GROUP BY
	o.RucE,
	o.Cd_OF_Origen;

CREATE UNIQUE CLUSTERED INDEX
	IX_EnvEmb
ON
	#EnvEmb (RucE, Cd_OF);

-- Fórmula OF (para localizar ítem de componente)
IF OBJECT_ID('tempdb..#Frmla') IS NOT NULL
	DROP TABLE #Frmla;

SELECT
	f.RucE,
	f.Cd_OF,
	f.Item,
	f.Cd_Prod,
	f.ID_UMP
INTO
	#Frmla
FROM
	FrmlaOF f
	INNER JOIN #OF o ON o.RucE = f.RucE AND o.Cd_OF_Origen = f.Cd_OF
WHERE
	f.RucE=@P_RUC_EMPRESA
	AND ISNULL(f.IB_Eliminado,0)=0;

CREATE NONCLUSTERED INDEX
	IX_Frmla
ON
	#Frmla (RucE, Cd_OF, Cd_Prod, ID_UMP) INCLUDE (Item);

-- Tabla de costos promedio en ventana
IF OBJECT_ID('tempdb..#CostoPromedioSalida') IS NOT NULL
	DROP TABLE #CostoPromedioSalida;

CREATE TABLE #CostoPromedioSalida
(
    Cd_Prod         CHAR(7)       NOT NULL,
    ID_UMP          INT           NOT NULL,
    Cd_Alm          VARCHAR(20)   NOT NULL,
    FechaMovimiento DATETIME      NOT NULL,
    Costo_MN        NUMERIC(20,10)    NULL,
    Costo_ME        NUMERIC(20,10)    NULL,
    CONSTRAINT PK_CPS_PROMEDIO PRIMARY KEY CLUSTERED
    (
        Cd_Prod, ID_UMP, Cd_Alm, FechaMovimiento
    )
);

-- Índice “busca el último <= fecha”
CREATE NONCLUSTERED INDEX
	IX_CPS_BUSQUEDA
ON
	#CostoPromedioSalida(Cd_Prod, ID_UMP, Cd_Alm, FechaMovimiento DESC)
INCLUDE
	(Costo_MN, Costo_ME);

-- NC de VENTA: recupera Cd_TD y costo de la venta original
IF OBJECT_ID('tempdb..#NC_Venta') IS NOT NULL
	DROP TABLE #NC_Venta;

SELECT
	bm.RucE,
	bm.Cd_Inv AS Cd_Inv_Destino,
	bm.Item AS Item_Destino,
	vNC.Cd_TD AS vNC_Cd_TD,
	ciNC.Costo_MN AS ciNC_Costo_MN,
	ciNC.Costo_ME AS ciNC_Costo_ME
INTO
	#NC_Venta
FROM
	#BaseMov bm
	INNER JOIN MovimientoInventario miOrgNC ON miOrgNC.RucE = bm.RucE AND miOrgNC.Cd_Inv_Destino = bm.Cd_Inv AND miOrgNC.Item_Destino   = bm.Item
	LEFT JOIN MovimientosDetalleVenta mdvNC ON mdvNC.RucE = bm.RucE AND mdvNC.Cd_Vta_Destino = miOrgNC.Cd_Vta_Origen AND mdvNC.Nro_RegVdt_Destino = miOrgNC.Item_Origen
	LEFT JOIN Venta vNC ON vNC.RucE = bm.RucE AND vNC.Cd_Vta = miOrgNC.Cd_Vta_Origen
	LEFT JOIN VentaDet vdNC ON vdNC.RucE = bm.RucE AND vdNC.Cd_Vta = vNC.DR_CdVta AND vdNC.Cd_Prod = bm.Cd_Prod
	LEFT JOIN
	(
		SELECT
			mi.RucE,
			mi.Cd_Vta_Origen,
			mi.Item_Origen,
			id.Cd_Inv,
			id.Item
		FROM
			MovimientoInventario mi
			INNER JOIN InventarioDet2 id ON id.RucE=mi.RucE AND id.Cd_Inv=mi.Cd_Inv_Destino AND id.Item=mi.Item_Destino AND id.Cd_Prod=@P_CODIGO_PRODUCTO
		WHERE
			mi.RucE=@P_RUC_EMPRESA
	) miDstNC ON miDstNC.RucE = bm.RucE AND miDstNC.Cd_Vta_Origen = ISNULL(mdvNC.Cd_Vta_Origen, vNC.DR_CdVta) AND miDstNC.Item_Origen   = ISNULL(mdvNC.Nro_RegVdt_Origen, vdNC.Nro_RegVdt)
	LEFT JOIN CostoInventario ciNC ON ciNC.RucE = miDstNC.RucE AND ciNC.Cd_Inv = miDstNC.Cd_Inv AND ciNC.Item   = miDstNC.Item AND ciNC.IC_TipoCostoInventario='M';

CREATE UNIQUE CLUSTERED INDEX
	IX_NC_Venta
ON
	#NC_Venta (RucE, Cd_Inv_Destino, Item_Destino);

-- NC de COMPRA: recupera TC y costos convertidos
IF OBJECT_ID('tempdb..#NC_Compra') IS NOT NULL DROP TABLE #NC_Compra;

SELECT
	bm.RucE,
	bm.Cd_Inv  AS Cd_Inv_Destino,
	bm.Item    AS Item_Destino,
	c2.CamMda  AS CamMda_Compra,
	c2.Cd_TD   AS Cd_TD_Compra,
	Costo_MN_Compra = CASE WHEN c2.Cd_TD='07' THEN
							CASE WHEN c2.Cd_Mda = '01' THEN cd2.BimUni ELSE cd2.BimUni * c2.CamMda END
							ELSE 0 END,
	Costo_ME_Compra = CASE WHEN c2.Cd_TD='07'
							THEN CASE WHEN c2.Cd_Mda = '01' THEN ISNULL(cd2.BimUni/NULLIF(c2.CamMda,0),0.00) ELSE cd2.BimUni END
							ELSE 0 END
INTO
	#NC_Compra
FROM
	#BaseMov bm
	JOIN MovimientoInventario miOrgNC ON miOrgNC.RucE = bm.RucE AND miOrgNC.Cd_Inv_Destino = bm.Cd_Inv AND miOrgNC.Item_Destino   = bm.Item
	LEFT JOIN CompraDet2 cd2 ON cd2.RucE = bm.RucE AND cd2.Cd_Com = miOrgNC.Cd_Com_Origen AND cd2.Item   = miOrgNC.Item_Origen AND cd2.Cd_Prod= bm.Cd_Prod
	LEFT JOIN Compra2 c2 ON c2.RucE = cd2.RucE AND c2.Cd_Com = cd2.Cd_Com;

CREATE UNIQUE CLUSTERED INDEX
	IX_NC_Compra
ON
	#NC_Compra (RucE, Cd_Inv_Destino, Item_Destino);

--CURSOR (CONSULTAE PRINCIPAL)
IF OBJECT_ID('tempdb..#CursorData') IS NOT NULL
	DROP TABLE #CursorData;

SELECT
	bm.RucE,
	bm.Correlativo,
	bm.Cd_Inv,
	bm.Item,
	bm.Cantidad,
	bm.Costo_MN,
	bm.Costo_ME,
	bm.IC_TipoCostoInventario,
	bm.Cd_Prod,
	bm.ID_UMP,
	bm.IC_ES,
	bm.Cd_Alm,
	bm.Codigo,
	bm.FechaMovimiento,
	TI_IC_ES = ti.IC_ES,
	tm.TipoMovimientoInventario,
	FactorCalculado = ISNULL(pum.FactorCalculado,0),
	Cd_OF_Origen    = ISNULL(mo.Cd_OF_Origen,''),
	FOF_Item        = fof.Item,
	IB_PT           = CASE WHEN ofab.Cd_Prod = bm.Cd_Prod THEN 1 ELSE 0 END,

	-- NC Venta
	vNC_Cd_TD     = vta.vNC_Cd_TD,
	ciNC_Costo_MN = vta.ciNC_Costo_MN,
	ciNC_Costo_ME = vta.ciNC_Costo_ME,

	-- Gastos / Envases
	g.Gasto_MN,
	g.Gasto_ME,
	ee.CostoEE_MN,
	ee.CostoEE_ME,

	-- NC Compra
	CamMda_Compra   = cmp.CamMda_Compra,
	Cd_TD_Compra    = cmp.Cd_TD_Compra,
	Costo_MN_Compra = cmp.Costo_MN_Compra,
	Costo_ME_Compra = cmp.Costo_ME_Compra,

	ProcOrder = CASE WHEN tm.TipoMovimientoInventario='M'
						THEN CASE WHEN bm.IC_ES='S' THEN 2 ELSE 3 END
						ELSE CASE WHEN bm.IC_ES='E' THEN 1 ELSE 4 END
				END
INTO
	#CursorData
FROM
	#BaseMov bm
	INNER JOIN TipoOperacion ti ON ti.Cd_TO = bm.Cd_TO
	LEFT JOIN #TipoMov tm ON tm.RucE = bm.RucE AND tm.Cd_Inv = bm.Cd_Inv
	LEFT JOIN MovimientoInventario mo ON mo.RucE = bm.RucE AND mo.Cd_Inv_Destino = bm.Cd_Inv AND mo.Item_Destino   = bm.Item
	LEFT JOIN #Pum pum ON pum.RucE = bm.RucE AND pum.Cd_Prod = bm.Cd_Prod AND pum.ID_UMP = bm.ID_UMP
	LEFT JOIN OrdFabricacion ofab ON ofab.RucE = bm.RucE AND ofab.Cd_OF = mo.Cd_OF_Origen
	LEFT JOIN #Gastos g ON g.RucE = bm.RucE AND g.Cd_OF = mo.Cd_OF_Origen
	LEFT JOIN #EnvEmb ee ON ee.RucE = bm.RucE AND ee.Cd_OF = mo.Cd_OF_Origen
	LEFT JOIN #Frmla fof ON fof.RucE = bm.RucE AND fof.Cd_OF = mo.Cd_OF_Origen AND fof.Cd_Prod = bm.Cd_Prod AND fof.ID_UMP = bm.ID_UMP
	LEFT JOIN #NC_Venta vta ON vta.RucE = bm.RucE AND vta.Cd_Inv_Destino = bm.Cd_Inv AND vta.Item_Destino = bm.Item
	LEFT JOIN #NC_Compra cmp ON cmp.RucE = bm.RucE AND cmp.Cd_Inv_Destino = bm.Cd_Inv AND cmp.Item_Destino = bm.Item;

/* Índices de proceso */
CREATE CLUSTERED INDEX
	IX_CursorData_Order
ON
	#CursorData (FechaMovimiento, ProcOrder, Item);

CREATE NONCLUSTERED INDEX
	IX_CursorData_Key
ON
	#CursorData (RucE, Cd_Inv, Item);

-- Cursor 
DECLARE
@ci2_RucE nvarchar(11),
@ci2_Correlativo int,
@ci2_Cd_Inv char(12),
@ci2_Item int,
@ci2_Cantidad numeric(20,10),
@ci2_Costo_MN numeric(20,10),
@ci2_Costo_ME numeric(20,10),
@ci2_IC_TipoCostoInventario char(1),
@id2_Cd_Prod char(7),
@id2_ID_UMP int,
@id2_IC_ES char(1),
@id2_Cd_Alm varchar(20),
@id2_Codigo char(4),
@i2_FechaMovimiento datetime,
@ti_IC_ES char(1),
@tipoMov_TipoMovimientoInventario char(1),
@pum_FactorCalculado numeric(13,7),
@mo_Cd_OF_Origen char(10),
@fof_Item int,
@vNC_Cd_TD nvarchar(2),
@IB_PT bit,
@ciNC_Costo_MN numeric(20,10),
@ciNC_Costo_ME numeric(20,10),
@Costo_MN_R numeric(20,10),
@Costo_ME_R numeric(20,10),
@Gasto_MN numeric(15,7),
@Gasto_ME numeric(15,7),
@CostoEE_MN numeric(15,7),
@CostoEE_ME numeric(15,7),
@CamMda_Compra numeric(7,4),
@Cd_TD_Compra VARCHAR(2),
@Costo_MN_Compra NUMERIC(20,10),
@Costo_ME_Compra NUMERIC(20,10);

--SELECT Ruce,FechaMovimiento,ProcOrder,IC_ES,Item,Cd_Inv,TipoMovimientoInventario,Cd_Alm,Cantidad,Costo_MN,Costo_MN,IB_PT,Cd_OF_Origen FROM #CursorData ORDER BY FechaMovimiento ASC, IC_ES ASC, Item ASC;
--SELECT Ruce,FechaMovimiento,ProcOrder,IC_ES,Item,Cd_Inv,TipoMovimientoInventario,Cd_Alm,Cantidad,Costo_MN,Costo_MN,IB_PT,Cd_OF_Origen FROM #CursorData ORDER BY FechaMovimiento ASC, ProcOrder ASC, Cd_inv ASC, Item ASC;
	
--RETURN

DECLARE inventario_cursor_M CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
SELECT
	RucE,
	Correlativo,
	Cd_Inv,
	Item,
	Cantidad,
	Costo_MN,
	Costo_ME,
	IC_TipoCostoInventario,
	Cd_Prod,
	ID_UMP,
	IC_ES,
	Cd_Alm,
	Codigo,
	FechaMovimiento,
	TI_IC_ES,
	TipoMovimientoInventario,
	FactorCalculado,
	Cd_OF_Origen,
	FOF_Item,
	IB_PT,
	vNC_Cd_TD,
	ciNC_Costo_MN,
	ciNC_Costo_ME,
	Gasto_MN,
	Gasto_ME,
	CostoEE_MN,
	CostoEE_ME,
	CamMda_Compra,
	Cd_TD_Compra,
	Costo_MN_Compra,
	Costo_ME_Compra
FROM
	#CursorData
ORDER BY
	FechaMovimiento ASC,
	ProcOrder ASC,
	Item ASC;
OPEN inventario_cursor_M;
FETCH NEXT FROM inventario_cursor_M INTO
    @ci2_RucE, @ci2_Correlativo, @ci2_Cd_Inv, @ci2_Item, @ci2_Cantidad, @ci2_Costo_MN, @ci2_Costo_ME, @ci2_IC_TipoCostoInventario,
    @id2_Cd_Prod, @id2_ID_UMP, @id2_IC_ES, @id2_Cd_Alm, @id2_Codigo, @i2_FechaMovimiento, @ti_IC_ES,
    @tipoMov_TipoMovimientoInventario, @pum_FactorCalculado, @mo_Cd_OF_Origen, @fof_Item, @IB_PT, @vNC_Cd_TD,
    @ciNC_Costo_MN, @ciNC_Costo_ME, @Gasto_MN, @Gasto_ME, @CostoEE_MN, @CostoEE_ME, @CamMda_Compra, @Cd_TD_Compra,
    @Costo_MN_Compra, @Costo_ME_Compra;
WHILE @@FETCH_STATUS = 0
BEGIN
	declare
	@FechaDesdeCostoPromedio datetime = ISNULL((select MAX(FechaMovimiento) from #CostoPromedioSalida where FechaMovimiento<=@i2_FechaMovimiento and ID_UMP=@id2_ID_UMP and Cd_Alm=@id2_Cd_Alm),@P_FECHA_MOVIMIENTO),
	@FechaHastaCostoPromedio datetime = @i2_FechaMovimiento
			
	if exists
	(
		select top 1
			id.RucE
		from
			InventarioDet2 id
			left join Inventario2 i on i.RucE=@P_RUC_EMPRESA and i.Cd_Inv=id.Cd_Inv
		where
			id.RucE=@P_RUC_EMPRESA
			and id.Cd_Prod=@id2_Cd_Prod
			and CASE WHEN @IB_KardexUM=1 THEN id.ID_UMP ELSE '' END = CASE WHEN @IB_KardexUM=1 THEN @id2_ID_UMP ELSE '' END
			and CASE WHEN @IB_KardexAlm=1 THEN id.Cd_Alm ELSE '' END = CASE WHEN @IB_KardexAlm=1 THEN @id2_Cd_Alm ELSE '' END
			and id.IC_ES='E'
			and i.FechaMovimiento>=@FechaDesdeCostoPromedio
			and i.FechaMovimiento<@FechaHastaCostoPromedio --Se usó 'Menor que' porque la función 'Inv_CalculoCostoPromedio2' considera todos los movimientos menores a la fecha de consulta
	) or not exists (select top 1 * from #CostoPromedioSalida)
	begin
		insert into
			#CostoPromedioSalida
		values
			(@id2_Cd_Prod,@id2_ID_UMP,@id2_Cd_Alm,@i2_FechaMovimiento,
			 [inventario].[USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS_2](@P_RUC_EMPRESA,@i2_FechaMovimiento,'01',@id2_Cd_Prod,@id2_ID_UMP,@id2_Cd_Alm),
			 [inventario].[USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS_2](@P_RUC_EMPRESA,@i2_FechaMovimiento,'02',@id2_Cd_Prod,@id2_ID_UMP,@id2_Cd_Alm))
	end
			
	if (@ci2_IC_TipoCostoInventario!='' and @mo_Cd_OF_Origen!='')
	begin
		if (@id2_IC_ES='E')
		begin
			if (@tipoMov_TipoMovimientoInventario='M')
			begin
				if (@IB_PT = 1)
				begin
					/* GASTOS PRODUCCION */
					set @Gasto_MN = ISNULL(@Gasto_MN,0) / (case when ISNULL(@ci2_Cantidad,0) = 0 then 1 else @ci2_Cantidad end)
					set @Gasto_ME = ISNULL(@Gasto_ME,0) / (case when ISNULL(@ci2_Cantidad,0) = 0 then 1 else @ci2_Cantidad end)

					/* ENVASES Y EMBALAJES PRODUCCION */
					set @CostoEE_MN = ISNULL(@CostoEE_MN,0) / (case when ISNULL(@ci2_Cantidad,0) = 0 then 1 else @ci2_Cantidad end)
					set @CostoEE_ME = ISNULL(@CostoEE_ME,0) / (case when ISNULL(@ci2_Cantidad,0) = 0 then 1 else @ci2_Cantidad end)

					/* COSTO PRODUCTO TERMINADO */
					select
						@Costo_MN_R = ISNULL(SUM(Costo_MN * Cantidad) / @ci2_Cantidad,0),
						@Costo_ME_R = ISNULL(SUM(Costo_ME * Cantidad) / @ci2_Cantidad,0)
					from
						CostoInventario
					where
						RucE=@P_RUC_EMPRESA
						and Cd_Inv=@ci2_Cd_Inv
						and IC_TipoCostoInventario='M'
						and Item<>@ci2_Item

					set @Costo_MN_R = @Costo_MN_R + @Gasto_MN + @CostoEE_MN
					set @Costo_ME_R = @Costo_ME_R + @Gasto_ME + @CostoEE_ME

					--> ACTUALIZAR EN OrdFabricacion
					if exists (select top 1 * from OrdFabricacion where RucE=@P_RUC_EMPRESA and Cd_OF=@mo_Cd_OF_Origen)
					begin
						update
							OrdFabricacion
						set
							CU = @Costo_MN_R,
							CU_ME = @Costo_ME_R,
							CosTot = @Costo_MN_R * @ci2_Cantidad,
							CosTot_ME = @Costo_ME_R * @ci2_Cantidad
						where
							RucE=@P_RUC_EMPRESA
							and Cd_OF=@mo_Cd_OF_Origen
					end
				end
				else
				begin
					/* COSTO EN PRODUCCIÓN */
					select top 1
						@Costo_MN_R = Costo_MN,
						@Costo_ME_R = Costo_ME
					from
						InventarioDet2 id
						left join Costoinventario ci on ci.RucE=@P_RUC_EMPRESA and ci.Cd_Inv=@ci2_Cd_Inv and ci.Item=id.Item
					where
						id.RucE=@P_RUC_EMPRESA
						and id.Cd_Inv=@ci2_Cd_Inv
						and id.Cd_Prod=@id2_Cd_Prod
						and id.IC_ES='S'
						and ci.IC_TipoCostoInventario='M'

					--> ACTUALIZAR EN FrmlaOF
					if exists (select top 1 * from FrmlaOF where RucE=@P_RUC_EMPRESA and Cd_OF=@mo_Cd_OF_Origen and Item=@fof_Item)
					begin
						update
							FrmlaOF
						set
							CU = @Costo_MN_R,
							CU_ME = @Costo_ME_R,
							Costo = @Costo_MN_R * @ci2_Cantidad,
							Costo_ME = @Costo_ME_R * @ci2_Cantidad
						where
							RucE=@P_RUC_EMPRESA
							and Cd_OF=@mo_Cd_OF_Origen
							and Item=@fof_Item
					end
				end
			end
		end
		else
		begin
			select top 1
				@Costo_MN_R = Costo_MN,
				@Costo_ME_R = Costo_ME
			from
				#CostoPromedioSalida
			where
				Cd_Prod=@id2_Cd_Prod
				and ID_UMP=@id2_ID_UMP
				and Cd_Alm=@id2_Cd_Alm
				and FechaMovimiento<=@i2_FechaMovimiento
			order by
				FechaMovimiento desc

			--select @i2_FechaMovimiento,@Costo_MN_R,@Costo_ME_R

			----set @Costo_MN_R = [inventario].[USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS](@P_RUC_EMPRESA,@i2_FechaMovimiento,'01',@id2_Cd_Prod,@id2_ID_UMP,@id2_Cd_Alm) * ISNULL(@pum_FactorCalculado,0)
			----set @Costo_ME_R = [inventario].[USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS](@P_RUC_EMPRESA,@i2_FechaMovimiento,'02',@id2_Cd_Prod,@id2_ID_UMP,@id2_Cd_Alm) * ISNULL(@pum_FactorCalculado,0)
			--set @Costo_MN_R = [inventario].[USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS](@P_RUC_EMPRESA,@i2_FechaMovimiento,'01',@id2_Cd_Prod,@id2_ID_UMP,@id2_Cd_Alm)
			--set @Costo_ME_R = [inventario].[USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS](@P_RUC_EMPRESA,@i2_FechaMovimiento,'02',@id2_Cd_Prod,@id2_ID_UMP,@id2_Cd_Alm)
		end
	end
	else
	begin
		if (@ti_IC_ES='A')
		begin
			if (@id2_IC_ES='E')
			begin
				if exists
				(
					select
						1
					from
						CostoInventario c
						inner join InventarioDet2 i on c.RucE=i.RucE and c.Cd_Inv=i.Cd_Inv and c.Item=i.Item
					where
						c.RucE=@P_RUC_EMPRESA
						and c.Cd_Inv=@ci2_Cd_Inv
						and c.item=@ci2_Item-1
						AND i.Cd_Prod = @id2_Cd_Prod
						AND i.ID_UMP = @id2_ID_UMP
						and IC_TipoCostoInventario='M'
						and IC_ES='S'
				)
				BEGIN	
					IF (@P_DEBUG=1)
						PRINT 'Mixto(E) item -1'

					select
						@Costo_MN_R = Costo_MN * @pum_FactorCalculado,
						@Costo_ME_R = Costo_ME * @pum_FactorCalculado
					from
						CostoInventario c
						inner join InventarioDet2 i on c.RucE=i.RucE and c.Cd_Inv=i.Cd_Inv and c.Item=i.Item
					where
						c.RucE=@P_RUC_EMPRESA
						and c.Cd_Inv=@ci2_Cd_Inv
						and c.item=@ci2_Item-1
						and IC_TipoCostoInventario='M'
						and IC_ES='S'
				END
				ELSE
				BEGIN
					IF(@P_DEBUG=1)
						PRINT 'Mixto(E) item calculado'
					
					;WITH BaseMov AS
					(
						SELECT
							id2.RucE AS Ruc,
							id2.Cd_Prod AS CodigoProducto,
							id2.ID_UMP,
							i.Cd_Inv AS CodigoInventario,
							id2.Item,
							id2.Cantidad,
							ci.Costo_MN AS CostoUnitarioSoles,
							ci.Costo_ME AS CostoUnitarioDolares,
							id2.IC_ES AS CodigoTipo,
							ROW_NUMBER() OVER (PARTITION BY id2.RucE, i.Cd_Inv, id2.Cd_Prod, id2.Id_ump, id2.IC_ES ORDER BY id2.Item) AS rn
						FROM
							dbo.InventarioDet2 id2
							INNER JOIN dbo.Inventario2 i ON id2.RucE = i.RucE AND id2.Cd_Inv = i.Cd_Inv
							INNER JOIN dbo.CostoInventario ci ON id2.RucE = ci.RucE AND id2.Cd_Inv = ci.Cd_Inv AND id2.Item = ci.Item
						WHERE
							id2.RucE = @P_RUC_EMPRESA
							AND id2.Cd_Inv = @ci2_Cd_Inv
							AND id2.Cd_Prod = @id2_Cd_Prod
							AND id2.ID_UMP = @id2_ID_UMP
							AND ISNULL(ci.IC_TipoCostoInventario,'M')='M'
					),
					E AS
					(
						SELECT * FROM BaseMov WHERE CodigoTipo = 'E'
					),
					S AS
					(
						SELECT * FROM BaseMov WHERE CodigoTipo = 'S'
					)

					select
						@Costo_MN_R = S.CostoUnitarioSoles * @pum_FactorCalculado,
						@Costo_ME_R = S.CostoUnitarioDolares * @pum_FactorCalculado
					FROM
						E
						INNER JOIN S ON S.Ruc = E.Ruc AND S.CodigoInventario = E.CodigoInventario AND S.CodigoProducto = E.CodigoProducto AND S.ID_UMP = E.ID_UMP AND S.rn = E.rn
					WHERE
						E.Item = @ci2_Item

					--SELECT
					--	E.Ruc,
					--	E.CodigoInventario,
					--	E.CodigoProducto,
					--	E.Id_ump,
					--	-- Items pareados
					--	E.Item                AS ItemEntrada,
					--	S.Item                AS ItemSalida,
					--	-- Cantidades
					--	E.Cantidad            AS CantidadEntrada,
					--	S.Cantidad            AS CantidadSalida,
					--	-- Costos por par E/S
					--	E.CostoUnitarioSoles  AS CostoEntrada_Soles,
					--	S.CostoUnitarioSoles  AS CostoSalida_Soles,

					--	E.CostoUnitarioDolares AS CostoEntrada_Dolares,
					--	S.CostoUnitarioDolares AS CostoSalida_Dolares
					--FROM E
					--JOIN S
					--	ON  S.Ruc              = E.Ruc
					--	AND S.CodigoInventario = E.CodigoInventario
					--	AND S.CodigoProducto   = E.CodigoProducto
					--	AND S.Id_ump           = E.Id_ump
					--	AND S.rn               = E.rn
					--WHERE
					--	  E.Item = @ci2_Item
					--ORDER BY
					--	E.Ruc,E.CodigoInventario, E.Item;
				END

				IF(@P_DEBUG=1)
				BEGIN
					PRINT CONCAT('MIXTO(E) CostoMN: ',ISNULL(@Costo_MN_R,0))
					PRINT CONCAT('MIXTO(E) CostoME: ',ISNULL(@Costo_ME_R,0))
				END	
			end
			else
			begin
				select top 1
					@Costo_MN_R = Costo_MN,
					@Costo_ME_R = Costo_ME
				from
					#CostoPromedioSalida
				where
					Cd_Prod=@id2_Cd_Prod
					and ID_UMP=@id2_ID_UMP
					and Cd_Alm=@id2_Cd_Alm
					and FechaMovimiento<=@i2_FechaMovimiento
				order by
					FechaMovimiento desc

				--select @i2_FechaMovimiento,@Costo_MN_R,@Costo_ME_R

				----set @Costo_MN_R = [inventario].[USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS](@P_RUC_EMPRESA,@i2_FechaMovimiento,'01',@id2_Cd_Prod,@id2_ID_UMP,@id2_Cd_Alm) * @pum_FactorCalculado
				----set @Costo_ME_R = [inventario].[USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS](@P_RUC_EMPRESA,@i2_FechaMovimiento,'02',@id2_Cd_Prod,@id2_ID_UMP,@id2_Cd_Alm) * @pum_FactorCalculado
				--set @Costo_MN_R = [inventario].[USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS](@P_RUC_EMPRESA,@i2_FechaMovimiento,'01',@id2_Cd_Prod,@id2_ID_UMP,@id2_Cd_Alm)
				--set @Costo_ME_R = [inventario].[USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS](@P_RUC_EMPRESA,@i2_FechaMovimiento,'02',@id2_Cd_Prod,@id2_ID_UMP,@id2_Cd_Alm)
			end
		end
		else if (@ti_IC_ES='S')
		begin 
			--set @Costo_MN_R = [inventario].[USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS](@P_RUC_EMPRESA,@i2_FechaMovimiento,'01',@id2_Cd_Prod,@id2_ID_UMP,@id2_Cd_Alm) * @pum_FactorCalculado
			--set @Costo_ME_R = [inventario].[USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS](@P_RUC_EMPRESA,@i2_FechaMovimiento,'02',@id2_Cd_Prod,@id2_ID_UMP,@id2_Cd_Alm) * @pum_FactorCalculado

			/* Cuando la salida es por NC de Compra */
			IF @Cd_TD_Compra = '07'
			BEGIN
				set @Costo_MN_R = CASE WHEN ISNULL(@Costo_MN_Compra,0) != 0 THEN @Costo_MN_Compra ELSE [inventario].[USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS](@P_RUC_EMPRESA,@i2_FechaMovimiento,'01',@id2_Cd_Prod,@id2_ID_UMP,@id2_Cd_Alm) END
				set @Costo_ME_R = CASE WHEN ISNULL(@Costo_ME_Compra,0) != 0 THEN @Costo_ME_Compra ELSE [inventario].[USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS](@P_RUC_EMPRESA,@i2_FechaMovimiento,'02',@id2_Cd_Prod,@id2_ID_UMP,@id2_Cd_Alm) END
			END
			ELSE
			BEGIN
				select top 1
					@Costo_MN_R = Costo_MN,
					@Costo_ME_R = Costo_ME
				from
					#CostoPromedioSalida
				where
					Cd_Prod=@id2_Cd_Prod
					and ID_UMP=@id2_ID_UMP
					and Cd_Alm=@id2_Cd_Alm
					and FechaMovimiento<=@i2_FechaMovimiento
				order by
					FechaMovimiento desc

				--select @i2_FechaMovimiento,@Costo_MN_R,@Costo_ME_R

				--set @Costo_MN_R = [inventario].[USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS](@P_RUC_EMPRESA,@i2_FechaMovimiento,'01',@id2_Cd_Prod,@id2_ID_UMP,@id2_Cd_Alm)
				--set @Costo_ME_R = [inventario].[USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS](@P_RUC_EMPRESA,@i2_FechaMovimiento,'02',@id2_Cd_Prod,@id2_ID_UMP,@id2_Cd_Alm)
			END

			--set @Costo_MN_R = [inventario].[USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS](@P_RUC_EMPRESA,@i2_FechaMovimiento,'01',@id2_Cd_Prod,@id2_ID_UMP,@id2_Cd_Alm)
			--set @Costo_ME_R = [inventario].[USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS](@P_RUC_EMPRESA,@i2_FechaMovimiento,'02',@id2_Cd_Prod,@id2_ID_UMP,@id2_Cd_Alm) 
		end
		else
		begin
			/* CUANDO ES ENTRADA POR NOTA DE CRÉDITO */
			set @Costo_MN_R = (case when @vNC_Cd_TD='07' then @ciNC_Costo_MN else @ci2_Costo_MN end)
			set @Costo_ME_R = (case when @vNC_Cd_TD='07' then @ciNC_Costo_ME else @ci2_Costo_ME end)
		end
	end

	IF(@P_DEBUG=1)
	BEGIN
		PRINT CONCAT('Mov: ',@ci2_Cd_Inv, ' Item: ',@ci2_Item, ' Tipo: ',@id2_IC_ES, ' Corr.: ',@ci2_Correlativo)
		PRINT CONCAT('CostoMN: ',ISNULL(@Costo_MN_R,0))
		PRINT CONCAT('CostoME: ',ISNULL(@Costo_ME_R,0))
	END	
				
	if (@Costo_MN_R is not null and @Costo_ME_R is not null)
	begin
		if @Cd_TD_Compra = '07'
		begin
			update 
				Inventario2 
			set 
				CambioMoneda = CASE WHEN ISNULL(@CamMda_Compra,0) != 0 THEN @CamMda_Compra ELSE CambioMoneda END
			where
				RucE = @P_RUC_EMPRESA
				AND Cd_Inv = @ci2_Cd_Inv
		end

		update
			CostoInventario
		set
			Costo_MN = ISNULL(@Costo_MN_R,Costo_MN),
			Costo_ME = ISNULL(@Costo_ME_R,Costo_ME)
		where
			RucE=@P_RUC_EMPRESA
			and Cd_Inv=@ci2_Cd_Inv
			and Correlativo=@ci2_Correlativo

		set @Costo_MN_R = null
		set @Costo_ME_R = null
		set @Gasto_MN = 0
		set @Gasto_ME = 0
		set @CostoEE_MN = 0
		set @CostoEE_ME = 0
	end   

	FETCH NEXT FROM inventario_cursor_M INTO
		@ci2_RucE, @ci2_Correlativo, @ci2_Cd_Inv, @ci2_Item, @ci2_Cantidad, @ci2_Costo_MN, @ci2_Costo_ME, @ci2_IC_TipoCostoInventario,
		@id2_Cd_Prod, @id2_ID_UMP, @id2_IC_ES, @id2_Cd_Alm, @id2_Codigo, @i2_FechaMovimiento, @ti_IC_ES,
		@tipoMov_TipoMovimientoInventario, @pum_FactorCalculado, @mo_Cd_OF_Origen, @fof_Item, @IB_PT, @vNC_Cd_TD,
		@ciNC_Costo_MN, @ciNC_Costo_ME, @Gasto_MN, @Gasto_ME, @CostoEE_MN, @CostoEE_ME, @CamMda_Compra, @Cd_TD_Compra,
		@Costo_MN_Compra, @Costo_ME_Compra;
END
CLOSE inventario_cursor_M;
DEALLOCATE inventario_cursor_M;

--Leyenda
--Williams Gutierrez: 30/10/2025 <(121139) Se creó el sp a partir del [inventario].[USP_COSTO_INVENTARIO_RECALCULAR_INDIVIDUAL_1], optimizando los tiempos y corrigiendo el recálculo de costos cuando son transferencias>
--Claude Code: 16/01/2026 <Optimización: Se agregó límite superior FIJO (@P_FECHA_HASTA = '2025-05-31 23:59:59') para evitar procesar años de movimientos innecesarios. Solo procesa movimientos desde @P_FECHA_MOVIMIENTO hasta el 31 de mayo 2025 23:59:59. Se usa fin del día para incluir movimientos con hora.>