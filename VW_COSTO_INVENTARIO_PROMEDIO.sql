USE [ERP_TEST]
GO

/****** Object:  View [dbo].[VW_COSTO_INVENTARIO_PROMEDIO]    Script Date: 16/01/2026 17:18:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[VW_COSTO_INVENTARIO_PROMEDIO]
AS
--declare
--@ruc varchar(11) = '20609475529',
--@codigoProducto varchar(20) = 'PD00006'

SELECT
	a.RucE
	,a.Correlativo
	,a.Cd_Inv
	,a.FechaMovimiento
	,a.Item
	,a.Cd_Prod
	,a.ID_UMP
	,a.Cd_UM
	,a.IC_ES
	,a.Cd_Alm
	,a.Cd_Mda
	,a.Cantidad_UM_Registro
	,a.Cantidad_UM_Principal AS Cantidad_UM_Principal
	,a.Costo_MN
	,CONVERT(NUMERIC(38,20),((a.Cantidad_UM_Registro * a.Costo_MN)) / NULLIF(a.Cantidad_UM_Principal, 0)) as 'Costo_MN_UM_Principal'
	,CONVERT(NUMERIC(38,20),(((a.Cantidad_UM_Registro * a.Costo_MN)) / NULLIF(a.Cantidad_UM_Principal, 0)) * a.Cantidad_UM_Principal) as 'Costo_MN_UM_Total'
	,a.Costo_MN*a.Cantidad_UM_Registro AS TOTAL_REGISTRO_MN
	,a.Costo_ME
	,CONVERT(NUMERIC(38,20),((a.Cantidad_UM_Registro * a.Costo_ME)) / NULLIF(a.Cantidad_UM_Principal, 0)) as 'Costo_ME_UM_Principal'
	,CONVERT(NUMERIC(38,20),(((a.Cantidad_UM_Registro * a.Costo_ME)) / NULLIF(a.Cantidad_UM_Principal, 0)) * a.Cantidad_UM_Principal) as 'Costo_ME_UM_Total'
	,a.Costo_ME*a.Cantidad_UM_Registro AS TOTAL_REGISTRO_ME
FROM
	(
		SELECT
			a.RucE
			,a.Correlativo
			,a.Cd_Inv
			,c.FechaMovimiento
			,a.Item
			,d.Cd_Prod
			,e.ID_UMP
			,e.Cd_UM
			,b.Cd_Alm
			,b.IC_ES
			,a.Cantidad as 'Cantidad_UM_Registro'
			,CASE WHEN ISNULL(d.IB_Conv,0)=0 and b.IC_ES='S' THEN ISNULL(a.Costo_MN,0) * e.FactorRealCalculado ELSE ISNULL(a.Costo_MN,0) END AS Costo_MN
			,CASE WHEN ISNULL(d.IB_Conv,0)=0 and b.IC_ES='S' THEN ISNULL(a.Costo_ME,0) * e.FactorRealCalculado ELSE ISNULL(a.Costo_ME,0) END AS Costo_ME
			,CASE WHEN ISNULL(d.IB_Conv,0)=0 and b.IC_ES='S' THEN ISNULL(a.Costo_MN,0) * e.FactorRealCalculado ELSE ISNULL(a.Costo_MN,0) END * CASE WHEN ISNULL(E.IC_CL,'M') = 'M' THEN a.Cantidad * e.Factor else a.Cantidad / NULLIF(e.Factor,0) END AS TOTAL_REGISTRO
			--,CASE WHEN b.IC_ES='S' THEN ISNULL(a.Costo_MN,0) * ISNULL((CASE WHEN ISNULL(e.IC_CL,'') = '' or e.IC_CL = 'M' THEN e.Factor ELSE (CASE WHEN e.Factor = 0 THEN 0 ELSE 1.0 / e.Factor END) END),0) ELSE ISNULL(a.Costo_MN,0) END as Costo_MN
			--,CASE WHEN b.IC_ES='S' THEN ISNULL(a.Costo_ME,0) * ISNULL((CASE WHEN ISNULL(e.IC_CL,'') = '' or e.IC_CL = 'M' THEN e.Factor ELSE (CASE WHEN e.Factor = 0 THEN 0 ELSE 1.0 / e.Factor END) END),0) ELSE ISNULL(a.Costo_ME,0) END as Costo_ME
			,c.Cd_Mda as Cd_Mda
			,CASE WHEN ISNULL(d.IB_Conv,0)=0 and b.IC_ES='S' THEN CONVERT(NUMERIC(38,20), CASE WHEN ISNULL(E.IC_CL,'M') = 'M' THEN a.Cantidad * e.Factor else a.Cantidad / NULLIF(e.Factor,0) END) ELSE a.Cantidad END AS 'Cantidad_UM_Principal'
			,d.IB_Conv
			,CASE WHEN ISNULL(d.IB_Conv,0)=0 and b.IC_ES='S' THEN ISNULL(a.Costo_MN,0) * e.FactorRealCalculado ELSE ISNULL(a.Costo_MN,0) END *
			CASE WHEN ISNULL(d.IB_Conv,0)=1 THEN e.FactorRealCalculado ELSE e.FactorCalculado END as Costo_RealMN
			,CASE WHEN ISNULL(d.IB_Conv,0)=0 and b.IC_ES='S' THEN ISNULL(a.Costo_ME,0) * e.FactorRealCalculado ELSE ISNULL(a.Costo_ME,0) END *
			CASE WHEN ISNULL(d.IB_Conv,0)=1 THEN e.FactorRealCalculado ELSE e.FactorCalculado END as Costo_RealME
		FROM
			CostoInventario a
			left join InventarioDet2 b on a.RucE = b.RucE and a.Cd_Inv = b.Cd_Inv and a.Item = b.Item
			left join Inventario2 c on a.RucE = c.RucE and a.Cd_Inv = c.Cd_Inv
			left join Producto2 d on a.RucE =  d.RucE and b.Cd_Prod = d.Cd_Prod
			LEFT JOIN
					(
						select
							RucE, Cd_Prod, ID_UMP, IC_CL, Cd_UM, Factor,
							CONVERT(DECIMAL(25,15),case IC_CL when 'M' then 1.0 / (CASE WHEN ISNULL(Factor,0) = 0 THEN 0 ELSE ISNULL(Factor,0) END) when 'D' then ISNULL(Factor,0) else 1 end) as FactorCalculado,
							CONVERT(DECIMAL(25,15),case IC_CL when 'D' then 1.0 / (CASE WHEN ISNULL(Factor,0) = 0 THEN 0 ELSE ISNULL(Factor,0) END) when 'M' then ISNULL(Factor,0) else 1 end) as FactorRealCalculado
						from
							Prod_UM
					) as e on a.RucE = e.RucE AND b.Cd_Prod = e.Cd_Prod AND CASE WHEN ISNULL(d.IB_Conv,0)=1 THEN b.C_ID_UMP_REGISTRO ELSE b.ID_UMP END = e.ID_UMP
			--left join Prod_UM e on a.RucE = e.RucE and b.Cd_Prod = e.Cd_Prod and b.ID_UMP = e.ID_UMP
			left join Almacen f on a.RucE = f.RucE and b.Cd_Alm = f.Cd_Alm
		WHERE
			--ISNULL(a.IC_TipoCostoInventario,'M') = 'M'
			(a.IC_TipoCostoInventario = 'M' or ISNULL(a.IC_TipoCostoInventario,'') = '')
			and ISNULL(f.IB_EsVi,0) = 0
			--and a.RucE = @ruc
			--and b.Cd_Prod = @codigoProducto
		
	)a
	--order by FechaMovimiento

/************************** LEYENDA

| USUARIO				| | FECHA		| | DESCRIPCIÓN
| Andrés Santos			| | 26/10/2021	| | Creación del query
| Rafael Linares		| | 20/10/2022	| | Uso de funcion convert a float para minimizar la perdida de decimales
| Rafael Linares		| | 27/10/2022	| | Se hicieron correcciones con respecto a la precision de los calculos para evitar la perdida de decimales por valores provenientes de Fabricacion Caso 72940
| Rafael Linares		| | 22/11/2022	| | Estandarizacion de registro y variables a precision 30,20
| Williams Gutierrez	| | 22/11/2022	| | Se quito el convert a float por problemas con decimales
| David Jove			| | 04/02/2023	| | Se agregó la validación ISNULL(a.IC_TipoCostoInventario,'') = '')
| Andrés Santos			| | 18/09/2023	| | (87011) Se cambia a NUMERIC(38,20)
| David Jove			| | 09/09/2024	| | (100780) Se modificaron los campos Costo_MN y Costo_ME, para que sea afectado por el factor cuando es una salida. Además, se modificaron los campos Costo_MN_UM_Principal, Costo_ME_UM_Principal, Costo_MN_UM_Total y Costo_ME_UM_Total.
| Pedro Espinoza		| | 10/04/2025	| | (112608) Se reguló el costo como al del explorador de Inventario
| David Jove			| | 20/06/2025	| | (114333) Se agregó la condicional ISNULL(d.IB_Conv,0)=0 and b.IC_ES='S' al campo 'Cantidad_UM_Principal'
| David Jove			| | 26/06/2025	| | (114314) Se sube la corrección del caso 114333 que se encuentra en observación

***************************/
GO


