USE [ERP_ECHA]
GO
/****** Object:  StoredProcedure [inventario].[USP_COSTO_INVENTARIO_RECALCULAR_INDIVIDUAL_3]    Script Date: 15/01/2026 13:15:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [inventario].[USP_COSTO_INVENTARIO_RECALCULAR_INDIVIDUAL_3]
@RucE VARCHAR(11),
@Cd_Prod VARCHAR(7),
@FechaMovimiento DATETIME,
@P_USUARIO_RECALCULO NVARCHAR(10),
@P_FECHA_RECALCULO DATETIME
AS
--declare
--@RucE char(11) = '20609475529',
--@Cd_Prod varchar(7) = 'PD00006',
--@FechaMovimiento datetime = '31/05/2024 00:00:00'

declare
@IC_TipoCostoInventario varchar(10),
@IB_KardexAlm bit,  
@IB_KardexUM bit

set @IC_TipoCostoInventario = ISNULL((select IC_TipoCostoInventario from CfgGeneral where RucE=@RucE),'PROMEDIO')

select top 1
	@IB_KardexAlm = ISNULL(IB_KardexAlm,0),
	@IB_KardexUM = ISNULL(IB_KardexUM,0)
from
	CfgGeneral
where
	RucE=@RucE

if (@IC_TipoCostoInventario = 'PROMEDIO')
begin
	begin /* RECALCULO COSTO PROMEDIO */
		exec [inventario].[USP_COSTO_INVENTARIO_RECALCULAR_INDIVIDUAL_PROMEDIO] @RucE,@Cd_Prod,@FechaMovimiento,0

		/*** ANTIGUO ***/
		--declare
		--@ci2_RucE nvarchar(11),
		--@ci2_Correlativo int,
		--@ci2_Cd_Inv char(12),
		--@ci2_Item int,
		--@ci2_Cantidad numeric(20,10),
		--@ci2_Costo_MN numeric(20,10),
		--@ci2_Costo_ME numeric(20,10),
		--@ci2_IC_TipoCostoInventario char(1),
		--@id2_Cd_Prod char(7),
		--@id2_ID_UMP int,
		--@id2_IC_ES char(1),
		--@id2_Cd_Alm varchar(20),
		--@id2_Codigo char(4),
		--@i2_FechaMovimiento datetime,
		--@ti_IC_ES char(1),
		--@tipoMov_TipoMovimientoInventario char(1),
		--@pum_FactorCalculado numeric(13,7),
		--@mo_Cd_OF_Origen char(10),
		--@fof_Item int,
		--@vNC_Cd_TD nvarchar(2),
		--@IB_PT bit,
		--@ciNC_Costo_MN numeric(20,10),
		--@ciNC_Costo_ME numeric(20,10),
		--@Costo_MN_R numeric(20,10),
		--@Costo_ME_R numeric(20,10),
		--@Gasto_MN numeric(15,7),
		--@Gasto_ME numeric(15,7),
		--@CostoEE_MN numeric(15,7),
		--@CostoEE_ME numeric(15,7),
		--@CamMda_Compra numeric(7,4),
		--@Cd_TD_Compra VARCHAR(2),
		--@Costo_MN_Compra NUMERIC(20,10),
		--@Costo_ME_Compra NUMERIC(20,10)

		--declare @CostoPromedioSalida table
		--(
		--	Cd_Prod char(7),
		--	ID_UMP int,
		--	Cd_Alm varchar(20),
		--	FechaMovimiento datetime ,
		--	Costo_MN numeric(20,10),
		--	Costo_ME numeric(20,10)
		--)
		
		--declare inventario_cursor_M cursor for
		--	select top 100 percent
		--		ci2.RucE,
		--		ci2.Correlativo,
		--		ci2.Cd_Inv,
		--		ci2.Item,
		--		ci2.Cantidad,
		--		ci2.Costo_MN,
		--		ci2.Costo_ME,
		--		ISNULL(ci2.IC_TipoCostoInventario,''),
		--		id2.Cd_Prod,
		--		id2.ID_UMP,
		--		id2.IC_ES,
		--		id2.Cd_Alm,
		--		id2.Codigo,
		--		i2.FechaMovimiento,
		--		ti.IC_ES,
		--		tipoMov.TipoMovimientoInventario,
		--		ISNULL(pum.FactorCalculado,0),
		--		ISNULL(mo.Cd_OF_Origen,''),
		--		fof.Item as FrmlaOF_Item,
		--		case when ofab.Cd_Prod = id2.Cd_Prod then 1 else 0 end as IB_PT, --> PRODUCTO TERMINADO
		--		vNC.Cd_TD,
		--		ciNC.Costo_MN,
		--		ciNC.Costo_ME,
		--		g.Gasto_MN,
		--		g.Gasto_ME,
		--		ee.CostoEE_MN,
		--		ee.CostoEE_ME,
		--		c2.CamMda as 'CamMda_Compra',
		--		c2.Cd_TD as 'Cd_TD_Compra',
		--		CASE WHEN c2.Cd_TD = '07' THEN (CASE WHEN c2.Cd_Mda = '01' THEN cd2.BimUni ELSE cd2.BimUni * c2.CamMda END) ELSE 0 END AS 'Costo_MN_Compra',
		--		CASE WHEN c2.Cd_TD = '07' THEN (CASE WHEN c2.Cd_Mda = '01' THEN ISNULL(cd2.BimUni / NULLIF(c2.CamMda,0), 0.00) ELSE cd2.BimUni END) ELSE 0 END AS 'Costo_ME_Compra'
		--	from
		--		Inventario2 as i2
		--		inner join InventarioDet2 as id2 on id2.RucE=@RucE and i2.Cd_Inv=id2.Cd_Inv
		--		inner join CostoInventario as ci2 on ci2.RucE=@RucE and id2.Cd_Inv=ci2.Cd_Inv and id2.Item=ci2.Item
		--		inner join TipoOperacion as ti on i2.Cd_TO=ti.Cd_TO
		--		left join MovimientoInventario as mo on mo.RucE=@RucE and id2.Cd_Inv=mo.Cd_Inv_Destino and id2.Item = mo.Item_Destino
		--		/* TIPO DE MOVIMIENTO */
		--		left join
		--		(
		--			select
		--				Cd_Inv,
		--				(case when CantidadE=0 then 'S' when CantidadS=0 then 'E' else 'M' end) as TipoMovimientoInventario
		--			from
		--				(
		--					select
		--						Cd_Inv,
		--						COUNT(case when IC_ES='E' then 1 else 0 end) as CantidadE,
		--						COUNT(case when IC_ES='S' then 1 else 0 end) as CantidadS
		--					from
		--						InventarioDet2
		--					where
		--						RucE=@RucE
		--					group by
		--						Cd_Inv
		--				) as tm
		--		) as tipoMov on tipoMov.Cd_Inv=i2.Cd_Inv
		--		/**********************/
		--		/*ÚNICAMENTE PARA TRAER EL COSTO DE LA NC DE LA VENTA ORIGINAL*/
		--		left join MovimientoInventario as miOrgNC on miOrgNC.RucE=@RucE and miOrgNC.Cd_Inv_Destino=i2.Cd_Inv and miOrgNC.Item_Destino=id2.Item
		--		left join MovimientosDetalleVenta as mdvNC on mdvNC.RucE=@RucE and mdvNC.Cd_Vta_Destino=miOrgNC.Cd_Vta_Origen and mdvNC.Nro_RegVdt_Destino=miOrgNC.Item_Origen --mdvNC.Cd_Vta_Origen y mdvNC.Nro_RegVdt_Origen
		--		left join Venta vNC WITH(NOLOCK) on vNC.RucE=@RucE and vNC.Cd_Vta=miOrgNC.Cd_Vta_Origen --vNC.DR_CdVta
		--		left join VentaDet vdNC WITH(NOLOCK) on vdNC.RucE=@RucE and vdNC.Cd_Vta=vNC.DR_CdVta and vdNC.Cd_Prod=id2.Cd_Prod and vdNC.ID_UMP=id2.ID_UMP --vdNC.Nro_RegVdt
		--		left join
		--		(
		--			select
		--				mi.Cd_Vta_Origen,
		--				mi.Item_Origen,
		--				id.Cd_Inv,
		--				id.Item
		--			from
		--				MovimientoInventario mi
		--				inner join InventarioDet2 id on id.RucE=mi.RucE and id.Cd_Inv=mi.Cd_Inv_Destino and id.Item=mi.Item_Destino and id.Cd_Prod=@Cd_Prod
		--			where
		--				mi.RucE=@RucE
		--		) miDstNC on miDstNC.Cd_Vta_Origen=ISNULL(mdvNC.Cd_Vta_Origen,vNC.DR_CdVta) and miDstNC.Item_Origen=ISNULL(mdvNC.Nro_RegVdt_Origen,vdNC.Nro_RegVdt)
		--		left join CostoInventario ciNC on ciNC.RucE=@RucE and ciNC.Cd_Inv=miDstNC.Cd_Inv and ciNC.Item=miDstNC.Item and ciNC.IC_TipoCostoInventario='M'
		--		--left join MovimientoInventario miDstNC on miDstNC.RucE=@RucE and miDstNC.Cd_Vta_Origen=ISNULL(mdvNC.Cd_Vta_Origen,vNC.DR_CdVta) and miDstNC.Item_Origen=ISNULL(mdvNC.Nro_RegVdt_Origen,vdNC.Nro_RegVdt)
		--		--left join CostoInventario ciNC on ciNC.RucE=@RucE and ciNC.Cd_Inv=miDstNC.Cd_Inv_Destino and ciNC.Item=miDstNC.Item_Destino and ciNC.IC_TipoCostoInventario='M'
		--		/**************************************************************/
		--		/**************************************************************/
		--		/* NC DE LA COMPRA */
		--		left join CompraDet2 cd2 on cd2.RucE = @RucE and cd2.Cd_Com = miOrgNC.Cd_Com_Origen and cd2.Item = miOrgNC.Item_Origen and cd2.Cd_Prod = @Cd_Prod
		--		left join Compra2 c2 on cd2.RucE = c2.RucE and cd2.Cd_Com = c2.Cd_Com
		--		/* ************************ */
		--		left join
		--		(
		--			select
		--				Cd_Prod,
		--				ID_UMP,
		--				case when IC_CL='M' then Factor when IC_CL='D' then (CASE WHEN Factor=0 THEN 1 ELSE 1/Factor END) else 1 end as FactorCalculado
		--			from
		--				Prod_UM
		--			where
		--				RucE=@RucE
		--		) as pum on pum.Cd_Prod=id2.Cd_Prod and pum.ID_UMP=id2.ID_UMP
		--		left join OrdFabricacion ofab on ofab.RucE=@RucE and ofab.Cd_OF=mo.Cd_OF_Origen
		--		left join
		--		(
		--			select
		--				Cd_OF,
		--				SUM(ISNULL(Costo,0)) as Gasto_MN,
		--				SUM(ISNULL(Costo_ME,0)) as Gasto_ME
		--			from
		--				CptoCostoOF
		--			where
		--				RucE=@RucE and ISNULL(IB_Eliminado,0)=0
		--			group by
		--				Cd_OF
		--		) as g on g.Cd_OF=mo.Cd_OF_Origen
		--		left join
		--		(
		--			select
		--				Cd_OF,
		--				SUM(ISNULL(Costo,0)) as CostoEE_MN,
		--				SUM(ISNULL(Costo_ME,0)) as CostoEE_ME
		--			from
		--				EnvEmbOF
		--			where
		--				RucE=@RucE and ISNULL(IB_Eliminado,0)=0
		--			group by
		--				Cd_OF
		--		) as ee on ee.Cd_OF=mo.Cd_OF_Origen
		--		left join
		--		(
		--			select
		--				Cd_OF,
		--				Item,
		--				Cd_Prod,
		--				ID_UMP
		--			from
		--				FrmlaOF
		--			where
		--				RucE=@RucE
		--				and ISNULL(IB_Eliminado,0)=0
		--		) as fof on fof.Cd_OF=mo.Cd_OF_Origen and fof.Cd_Prod=id2.Cd_Prod and fof.ID_UMP=id2.ID_UMP
		--	where 
		--		i2.RucE=@RucE
		--		and id2.Cd_Prod=@Cd_Prod
		--		and ISNULL(CI2.IC_TipoCostoInventario,'M')='M'
		--		and i2.FechaMovimiento>=@FechaMovimiento
		--		and (ISNULL(I2.C_IB_INTEGRACION_EXTERNA, 0) = 0 OR (ISNULL(I2.C_IB_INTEGRACION_EXTERNA,0) = 1 AND ISNULL(I2.C_IB_RECALCULAR_COSTOS,0) = 1))
		--	order by
		--		i2.FechaMovimiento asc,
		--		id2.IC_ES asc,
		--		ci2.Item asc				
		--open inventario_cursor_M
		--fetch next from inventario_cursor_M into 
		--	@ci2_RucE, @ci2_Correlativo, @ci2_Cd_Inv, @ci2_Item, @ci2_Cantidad, @ci2_Costo_MN, @ci2_Costo_ME, @ci2_IC_TipoCostoInventario, @id2_Cd_Prod, @id2_ID_UMP, @id2_IC_ES,
		--	@id2_Cd_Alm, @id2_Codigo, @i2_FechaMovimiento, @ti_IC_ES, @tipoMov_TipoMovimientoInventario, @pum_FactorCalculado, @mo_Cd_OF_Origen, @fof_Item, @IB_PT, @vNC_Cd_TD,
		--	@ciNC_Costo_MN, @ciNC_Costo_ME, @Gasto_MN, @Gasto_ME, @CostoEE_MN, @CostoEE_ME, @CamMda_Compra,@Cd_TD_Compra,@Costo_MN_Compra,@Costo_ME_Compra
		--while @@FETCH_STATUS = 0
		--begin
		--	declare
		--	@FechaDesdeCostoPromedio datetime = ISNULL((select MAX(FechaMovimiento) from @CostoPromedioSalida where FechaMovimiento<=@i2_FechaMovimiento and ID_UMP=@id2_ID_UMP and Cd_Alm=@id2_Cd_Alm),@FechaMovimiento),
		--	@FechaHastaCostoPromedio datetime = @i2_FechaMovimiento
			
		--	if exists
		--	(
		--		select top 1
		--			id.RucE
		--		from
		--			InventarioDet2 id
		--			left join Inventario2 i on i.RucE=@RucE and i.Cd_Inv=id.Cd_Inv
		--		where
		--			id.RucE=@RucE
		--			and id.Cd_Prod=@id2_Cd_Prod
		--			and CASE WHEN @IB_KardexUM=1 THEN id.ID_UMP ELSE '' END = CASE WHEN @IB_KardexUM=1 THEN @id2_ID_UMP ELSE '' END
		--			and CASE WHEN @IB_KardexAlm=1 THEN id.Cd_Alm ELSE '' END = CASE WHEN @IB_KardexAlm=1 THEN @id2_Cd_Alm ELSE '' END
		--			and id.IC_ES='E'
		--			and i.FechaMovimiento>=@FechaDesdeCostoPromedio
		--			and i.FechaMovimiento<@FechaHastaCostoPromedio --Se usó 'Menor que' porque la función 'Inv_CalculoCostoPromedio2' considera todos los movimientos menores a la fecha de consulta
		--	) or not exists (select top 1 * from @CostoPromedioSalida)
		--	begin
		--		insert into
		--			@CostoPromedioSalida
		--		values
		--			(@id2_Cd_Prod,@id2_ID_UMP,@id2_Cd_Alm,@i2_FechaMovimiento,
		--			 [inventario].[USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS_2](@RucE,@i2_FechaMovimiento,'01',@id2_Cd_Prod,@id2_ID_UMP,@id2_Cd_Alm),
		--			 [inventario].[USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS_2](@RucE,@i2_FechaMovimiento,'02',@id2_Cd_Prod,@id2_ID_UMP,@id2_Cd_Alm))
		--	end
			
		--	if (@ci2_IC_TipoCostoInventario!='' and @mo_Cd_OF_Origen!='')
		--	begin
		--		if (@id2_IC_ES='E')
		--		begin
		--			if (@tipoMov_TipoMovimientoInventario='M')
		--			begin
		--				if (@IB_PT = 1)
		--				begin
		--					/* GASTOS PRODUCCION */
		--					set @Gasto_MN = ISNULL(@Gasto_MN,0) / (case when ISNULL(@ci2_Cantidad,0) = 0 then 1 else @ci2_Cantidad end)
		--					set @Gasto_ME = ISNULL(@Gasto_ME,0) / (case when ISNULL(@ci2_Cantidad,0) = 0 then 1 else @ci2_Cantidad end)

		--					/* ENVASES Y EMBALAJES PRODUCCION */
		--					set @CostoEE_MN = ISNULL(@CostoEE_MN,0) / (case when ISNULL(@ci2_Cantidad,0) = 0 then 1 else @ci2_Cantidad end)
		--					set @CostoEE_ME = ISNULL(@CostoEE_ME,0) / (case when ISNULL(@ci2_Cantidad,0) = 0 then 1 else @ci2_Cantidad end)

		--					/* COSTO PRODUCTO TERMINADO */
		--					select
		--						@Costo_MN_R = ISNULL(SUM(Costo_MN * Cantidad) / @ci2_Cantidad,0),
		--						@Costo_ME_R = ISNULL(SUM(Costo_ME * Cantidad) / @ci2_Cantidad,0)
		--					from
		--						CostoInventario
		--					where
		--						RucE=@RucE
		--						and Cd_Inv=@ci2_Cd_Inv
		--						and IC_TipoCostoInventario='M'
		--						and Item<>@ci2_Item

		--					set @Costo_MN_R = @Costo_MN_R + @Gasto_MN + @CostoEE_MN
		--					set @Costo_ME_R = @Costo_ME_R + @Gasto_ME + @CostoEE_ME

		--					--> ACTUALIZAR EN OrdFabricacion
		--					if exists (select top 1 * from OrdFabricacion where RucE=@RucE and Cd_OF=@mo_Cd_OF_Origen)
		--					begin
		--						update
		--							OrdFabricacion
		--						set
		--							CU = @Costo_MN_R,
		--							CU_ME = @Costo_ME_R,
		--							CosTot = @Costo_MN_R * @ci2_Cantidad,
		--							CosTot_ME = @Costo_ME_R * @ci2_Cantidad
		--						where
		--							RucE=@RucE
		--							and Cd_OF=@mo_Cd_OF_Origen
		--					 end
		--				end
		--				else
		--				begin
		--					/* COSTO EN PRODUCCIÓN */
		--					select top 1
		--						@Costo_MN_R = Costo_MN,
		--						@Costo_ME_R = Costo_ME
		--					from
		--						InventarioDet2 id
		--						left join Costoinventario ci on ci.RucE=@RucE and ci.Cd_Inv=@ci2_Cd_Inv and ci.Item=id.Item
		--					where
		--						id.RucE=@RucE
		--						and id.Cd_Inv=@ci2_Cd_Inv
		--						and id.Cd_Prod=@id2_Cd_Prod
		--						and id.IC_ES='S'
		--						and ci.IC_TipoCostoInventario='M'

		--					--> ACTUALIZAR EN FrmlaOF
		--					if exists (select top 1 * from FrmlaOF where RucE=@RucE and Cd_OF=@mo_Cd_OF_Origen and Item=@fof_Item)
		--					begin
		--						update
		--							FrmlaOF
		--						set
		--							CU = @Costo_MN_R,
		--							CU_ME = @Costo_ME_R,
		--							Costo = @Costo_MN_R * @ci2_Cantidad,
		--							Costo_ME = @Costo_ME_R * @ci2_Cantidad
		--						where
		--							RucE=@RucE
		--							and Cd_OF=@mo_Cd_OF_Origen
		--							and Item=@fof_Item
		--					end
		--				end
		--			end
		--		end
		--		else
		--		begin
		--			select top 1
		--				@Costo_MN_R = Costo_MN,
		--				@Costo_ME_R = Costo_ME
		--			from
		--				@CostoPromedioSalida
		--			where
		--				Cd_Prod=@id2_Cd_Prod
		--				and ID_UMP=@id2_ID_UMP
		--				and Cd_Alm=@id2_Cd_Alm
		--				and FechaMovimiento<=@i2_FechaMovimiento
		--			order by
		--				FechaMovimiento desc

		--			--select @i2_FechaMovimiento,@Costo_MN_R,@Costo_ME_R

		--			----set @Costo_MN_R = [inventario].[USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS](@RucE,@i2_FechaMovimiento,'01',@id2_Cd_Prod,@id2_ID_UMP,@id2_Cd_Alm) * ISNULL(@pum_FactorCalculado,0)
		--			----set @Costo_ME_R = [inventario].[USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS](@RucE,@i2_FechaMovimiento,'02',@id2_Cd_Prod,@id2_ID_UMP,@id2_Cd_Alm) * ISNULL(@pum_FactorCalculado,0)
		--			--set @Costo_MN_R = [inventario].[USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS](@RucE,@i2_FechaMovimiento,'01',@id2_Cd_Prod,@id2_ID_UMP,@id2_Cd_Alm)
		--			--set @Costo_ME_R = [inventario].[USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS](@RucE,@i2_FechaMovimiento,'02',@id2_Cd_Prod,@id2_ID_UMP,@id2_Cd_Alm)
		--		end
		--	end
		--	else
		--	begin
		--		if (@ti_IC_ES='A')
		--		begin
		--			if (@id2_IC_ES='E')
		--			begin
		--				select
		--					@Costo_MN_R = Costo_MN * @pum_FactorCalculado,
		--					@Costo_ME_R = Costo_ME * @pum_FactorCalculado
		--				from
		--					CostoInventario c
		--					inner join InventarioDet2 i on c.RucE=i.RucE and c.Cd_Inv=i.Cd_Inv and c.Item=i.Item
		--				where
		--					c.RucE=@RucE
		--					and c.Cd_Inv=@ci2_Cd_Inv
		--					and c.item=@ci2_Item-1
		--					and IC_TipoCostoInventario='M'
		--					and IC_ES='S'
		--			end
		--			else
		--			begin
		--				select top 1
		--					@Costo_MN_R = Costo_MN,
		--					@Costo_ME_R = Costo_ME
		--				from
		--					@CostoPromedioSalida
		--				where
		--					Cd_Prod=@id2_Cd_Prod
		--					and ID_UMP=@id2_ID_UMP
		--					and Cd_Alm=@id2_Cd_Alm
		--					and FechaMovimiento<=@i2_FechaMovimiento
		--				order by
		--					FechaMovimiento desc

		--				--select @i2_FechaMovimiento,@Costo_MN_R,@Costo_ME_R

		--				----set @Costo_MN_R = [inventario].[USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS](@RucE,@i2_FechaMovimiento,'01',@id2_Cd_Prod,@id2_ID_UMP,@id2_Cd_Alm) * @pum_FactorCalculado
		--				----set @Costo_ME_R = [inventario].[USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS](@RucE,@i2_FechaMovimiento,'02',@id2_Cd_Prod,@id2_ID_UMP,@id2_Cd_Alm) * @pum_FactorCalculado
		--				--set @Costo_MN_R = [inventario].[USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS](@RucE,@i2_FechaMovimiento,'01',@id2_Cd_Prod,@id2_ID_UMP,@id2_Cd_Alm)
		--				--set @Costo_ME_R = [inventario].[USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS](@RucE,@i2_FechaMovimiento,'02',@id2_Cd_Prod,@id2_ID_UMP,@id2_Cd_Alm)
		--			end
		--		end
		--		else if (@ti_IC_ES='S')
		--		begin 
		--			--set @Costo_MN_R = [inventario].[USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS](@RucE,@i2_FechaMovimiento,'01',@id2_Cd_Prod,@id2_ID_UMP,@id2_Cd_Alm) * @pum_FactorCalculado
		--			--set @Costo_ME_R = [inventario].[USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS](@RucE,@i2_FechaMovimiento,'02',@id2_Cd_Prod,@id2_ID_UMP,@id2_Cd_Alm) * @pum_FactorCalculado

		--			/* Cuando la salida es por NC de Compra */
		--			IF @Cd_TD_Compra = '07'
		--			BEGIN
		--				set @Costo_MN_R = CASE WHEN ISNULL(@Costo_MN_Compra,0) != 0 THEN @Costo_MN_Compra ELSE [inventario].[USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS](@RucE,@i2_FechaMovimiento,'01',@id2_Cd_Prod,@id2_ID_UMP,@id2_Cd_Alm) END
		--				set @Costo_ME_R = CASE WHEN ISNULL(@Costo_ME_Compra,0) != 0 THEN @Costo_ME_Compra ELSE [inventario].[USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS](@RucE,@i2_FechaMovimiento,'02',@id2_Cd_Prod,@id2_ID_UMP,@id2_Cd_Alm) END
		--			END
		--			ELSE
		--			BEGIN
		--				select top 1
		--					@Costo_MN_R = Costo_MN,
		--					@Costo_ME_R = Costo_ME
		--				from
		--					@CostoPromedioSalida
		--				where
		--					Cd_Prod=@id2_Cd_Prod
		--					and ID_UMP=@id2_ID_UMP
		--					and Cd_Alm=@id2_Cd_Alm
		--					and FechaMovimiento<=@i2_FechaMovimiento
		--				order by
		--					FechaMovimiento desc

		--				--select @i2_FechaMovimiento,@Costo_MN_R,@Costo_ME_R

		--				--set @Costo_MN_R = [inventario].[USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS](@RucE,@i2_FechaMovimiento,'01',@id2_Cd_Prod,@id2_ID_UMP,@id2_Cd_Alm)
		--				--set @Costo_ME_R = [inventario].[USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS](@RucE,@i2_FechaMovimiento,'02',@id2_Cd_Prod,@id2_ID_UMP,@id2_Cd_Alm)
		--			END

		--			--set @Costo_MN_R = [inventario].[USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS](@RucE,@i2_FechaMovimiento,'01',@id2_Cd_Prod,@id2_ID_UMP,@id2_Cd_Alm)
		--			--set @Costo_ME_R = [inventario].[USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS](@RucE,@i2_FechaMovimiento,'02',@id2_Cd_Prod,@id2_ID_UMP,@id2_Cd_Alm) 
		--		end
		--		else
		--		begin
		--			/* CUANDO ES ENTRADA POR NOTA DE CRÉDITO */
		--			set @Costo_MN_R = (case when @vNC_Cd_TD='07' then @ciNC_Costo_MN else @ci2_Costo_MN end)
		--			set @Costo_ME_R = (case when @vNC_Cd_TD='07' then @ciNC_Costo_ME else @ci2_Costo_ME end)
		--		end
		--	end

		--	if (@Costo_MN_R is not null and @Costo_ME_R is not null)
		--	begin
		--		if @Cd_TD_Compra = '07'
		--		begin
		--			update 
		--				Inventario2 
		--			set 
		--				CambioMoneda = CASE WHEN ISNULL(@CamMda_Compra,0) != 0 THEN @CamMda_Compra ELSE CambioMoneda END
		--			where
		--				RucE = @RucE
		--				AND Cd_Inv = @ci2_Cd_Inv
		--		end

		--		update
		--			CostoInventario
		--		set
		--			Costo_MN = ISNULL(@Costo_MN_R,Costo_MN),
		--			Costo_ME = ISNULL(@Costo_ME_R,Costo_ME)
		--		where
		--			RucE=@RucE
		--			and Cd_Inv=@ci2_Cd_Inv
		--			and Correlativo=@ci2_Correlativo

		--		set @Costo_MN_R = null
		--		set @Costo_ME_R = null
		--		set @Gasto_MN = 0
		--		set @Gasto_ME = 0
		--		set @CostoEE_MN = 0
		--		set @CostoEE_ME = 0
		--	end

		--	fetch next from inventario_cursor_M into
		--		@ci2_RucE, @ci2_Correlativo, @ci2_Cd_Inv, @ci2_Item, @ci2_Cantidad, @ci2_Costo_MN, @ci2_Costo_ME, @ci2_IC_TipoCostoInventario, @id2_Cd_Prod,@id2_ID_UMP, @id2_IC_ES,
		--		@id2_Cd_Alm, @id2_Codigo, @i2_FechaMovimiento, @ti_IC_ES, @tipoMov_TipoMovimientoInventario, @pum_FactorCalculado, @mo_Cd_OF_Origen, @fof_Item, @IB_PT, @vNC_Cd_TD,
		--		@ciNC_Costo_MN, @ciNC_Costo_ME, @Gasto_MN, @Gasto_ME, @CostoEE_MN,@CostoEE_ME, @CamMda_Compra,@Cd_TD_Compra,@Costo_MN_Compra,@Costo_ME_Compra
		--end
		--close inventario_cursor_M
		--deallocate inventario_cursor_M;
	end
end
else
begin
	begin /* RECALCULO COSTO PEPS */
		-- ELIMINA TODOS LOS MOVIMIENTOS DE SALIDA DE UN PRODUCTO
		-- NO FILTRA EL ID_UMP PORQUE EL RECÁLCULO ES POR PRODUCTO
		-- NO FILTRA IC_ES='S' PORQUE EN LA TABLA DE 'CostoInventario' LAS ENTRADAS QUE NO SEAN DE TRANSFERENCIA NO REGISTRA CON 'P' (PEPS) NI 'M' (PROMEDIO)
		delete
			ci
		from
			Inventario2 i
			inner join InventarioDet2 id on id.RucE=@RucE and id.Cd_Inv=i.Cd_Inv
			inner join CostoInventario ci on ci.RucE=@RucE and ci.Cd_Inv=id.Cd_Inv and ci.Item=id.Item
		where
			id.RucE=@RucE
			and id.Cd_Prod=@Cd_Prod
			and ci.IC_TipoCostoInventario='P'
			and i.FechaMovimiento>=@FechaMovimiento
			and (ISNULL(I.C_IB_INTEGRACION_EXTERNA, 0) = 0 OR (ISNULL(I.C_IB_INTEGRACION_EXTERNA,0) = 1 AND ISNULL(I.C_IB_RECALCULAR_COSTOS,0) = 1))

		-- RECORRE LOS MOVIMIENTOS DE INVENTARIO DE SALIDA Y TRANSFERENCIAS (SIN LAS ENTRADAS)
		declare
		@NroCaso_ int,
		@Cd_Inv_ char(12),
		@ItemSalida_ int,
		@ItemEntrada_ int,
		@Cd_Prod_ char(7),
		@Cantidad_ numeric(20,10),
		@CantidadSecundaria_ numeric(20,10),
		@FechaMovimiento_ datetime,
		@Cd_Alm_ varchar(20),
		@ID_UMP_ int

		declare inventario_cursor_P cursor for
			-- CASO 1:
			-- ABARCA LAS SALIDAS Y TRANSFERENCIAS (NO INCLUYE EL MOVIMIENTO DE 'TERMINAR PRODUCCIÓN')
			select
				1,
				i.Cd_Inv,
				id.Item,
				idE.Item,
				id.Cd_Prod,
				id.Cantidad,
				id.CantidadSecundaria,
				i.FechaMovimiento,
				id.Cd_Alm,
				id.ID_UMP
			from
				Inventario2 i
				left join InventarioDet2 id on id.RucE=@RucE and id.Cd_Inv=i.Cd_Inv
				left join InventarioDet2 idE on idE.RucE=@RucE and idE.Cd_Inv=id.Cd_Inv and idE.Cd_Prod=id.Cd_Prod and idE.ID_UMP=id.ID_UMP and idE.IC_ES='E'
			where
				i.RucE=@RucE
				and id.Cd_Prod=@Cd_Prod
				and i.FechaMovimiento>=@FechaMovimiento
				and id.IC_ES='S'
				and (ISNULL(I.C_IB_INTEGRACION_EXTERNA, 0) = 0 OR (ISNULL(I.C_IB_INTEGRACION_EXTERNA,0) = 1 AND ISNULL(I.C_IB_RECALCULAR_COSTOS,0) = 1))

			union all

			-- CASO 2:
			-- ABARCA LA ENTRADA DEL MOVIMIENTO DE 'TERMINAR PRODUCCIÓN'
			select
				2,
				i.Cd_Inv,
				null, -- Item Salida
				id.Item, -- Item Entrada
				id.Cd_Prod,
				id.Cantidad,
				id.CantidadSecundaria,
				i.FechaMovimiento,
				id.Cd_Alm,
				id.ID_UMP
			from
				Inventario2 i
				left join InventarioDet2 id on id.RucE=@RucE and id.Cd_Inv=i.Cd_Inv
				inner join MovimientoInventario mi on mi.RucE=@RucE and mi.Cd_Inv_Destino=id.Cd_Inv and mi.Item_Destino=id.Item
				left join TipoOperacion ti on ti.Cd_TO=i.Cd_TO
				inner join
				(
					select
						produccionTerminada.*
					from
						(
							select
								Cd_Inv,
								SUM(case when IC_ES='S' then 1 else 0 end) as CantidadSalidas,
								SUM(case when IC_ES='E' then 1 else 0 end) as CantidadEntradas
							from
								InventarioDet2
							where
								RucE=@RucE
							group by
								RucE, Cd_Inv
						) as produccionTerminada
					where
						CantidadSalidas>CantidadEntradas
						and CantidadEntradas>0
				) as pt on pt.Cd_Inv=i.Cd_Inv
			where
				i.RucE=@RucE
				and ti.IC_ES='A'
				and id.IC_ES='E'
				and id.Cd_Prod=@Cd_Prod
				and i.FechaMovimiento>=@FechaMovimiento
				--and (ISNULL(I.C_IB_INTEGRACION_EXTERNA, 0) = 0 OR (ISNULL(I.C_IB_INTEGRACION_EXTERNA,0) = 1 AND ISNULL(I.C_IB_RECALCULAR_COSTOS,0) = 1)) //No es necesario ya que no hay API Inventario con Producción
			order by
				i.FechaMovimiento
		open inventario_cursor_P
		fetch next from inventario_cursor_P into @NroCaso_,@Cd_Inv_,@ItemSalida_,@ItemEntrada_,@Cd_Prod_,@Cantidad_,@CantidadSecundaria_,@FechaMovimiento_,@Cd_Alm_,@ID_UMP_
		while @@FETCH_STATUS = 0
		begin
			if (@NroCaso_ = 1)
			begin
				insert into
					CostoInventario (RucE,Cd_Inv,Item,Costo_MN,Costo_ME,Cantidad,IC_TipoCostoInventario,Cd_Inv_Entrada,Item_Entrada,CantidadSecundaria)
				select
					@RucE,
					@Cd_Inv_,
					case when id.IC_ES='S' then @ItemSalida_ else @ItemEntrada_ end,
					CostoUnitario_MN,
					CostoUnitario_ME,
					CantidadRetirada,
					'P',
					case when id.IC_ES='S' then Cd_Inv_Entrada else NULL end,
					case when id.IC_ES='S' then Item_Entrada else NULL end,
					CantidadSecundariaRetirada
				from
					dbo.Inv_FN_CalculoGeneralCostoPEPS_Inv2(@RucE,@Cd_Prod_,@Cantidad_,@CantidadSecundaria_,@FechaMovimiento_,@Cd_Alm_,@ID_UMP_,'')
					left join InventarioDet2 id on id.RucE=@RucE and id.Cd_Inv=@Cd_Inv_
												   and id.Item=(case when id.IC_ES='S' then @ItemSalida_ else @ItemEntrada_ end)
												   and id.Cd_Prod=@Cd_Prod_ and id.ID_UMP=@ID_UMP_ -- PARA QUE TRAIGA LA ENTRADA DE LA TRANSFERENCIA POR PRODUCTO Y ID_UMP
			end
			else if (@NroCaso_ = 2)
			begin
				insert into
					CostoInventario (RucE,Cd_Inv,Item,Costo_MN,Costo_ME,Cantidad,IC_TipoCostoInventario,Cd_Inv_Entrada,Item_Entrada,CantidadSecundaria)
				select
					@RucE,
					@Cd_Inv_,
					@ItemEntrada_,
					SUM(ci.Costo_MN * ci.Cantidad) / @Cantidad_,
					SUM(ci.Costo_ME * ci.Cantidad) / @Cantidad_,
					@Cantidad_,
					'P',
					NULL,
					NULL,
					@CantidadSecundaria_
				from
					InventarioDet2 id
					left join CostoInventario ci on ci.RucE=@RucE and ci.Cd_Inv=id.Cd_Inv and ci.Item=id.Item and ci.IC_TipoCostoInventario='P'
				where
					id.RucE=@RucE and id.Cd_Inv=@Cd_Inv_ and id.IC_ES='S'
			end

			fetch next from inventario_cursor_P into @NroCaso_,@Cd_Inv_,@ItemSalida_,@ItemEntrada_,@Cd_Prod_,@Cantidad_,@CantidadSecundaria_,@FechaMovimiento_,@Cd_Alm_,@ID_UMP_
		end
		close inventario_cursor_P
		deallocate inventario_cursor_P
	end
end

exec [seguridad].[USP_T_RECALCULO_COSTOS_INVENTARIO_LOG_INSERTAR] @RucE,@Cd_Prod,@FechaMovimiento,@IB_KardexAlm,@IB_KardexUM,@IC_TipoCostoInventario,@P_USUARIO_RECALCULO,@P_FECHA_RECALCULO

/*++++++++++++++++++++++++++++ Leyenda ++++++++++++++++++++++++++++++
- DJ: 02/11/2019 <Se modificó el recálculo PROMEDIO para que afecte a los insumos y al producto terminado. También actualiza los costos en OrdFabricacion (CABECERA) y FrmlaOF (DETALLE)>
- DJ: 20/11/2019 <Se agregó la validación IB_Eliminado=0 en las tablas CptoCostoOF y EnvEmbOF>
- Andrés Santos: 21/09/2020 <Se agregó validación para Integración externa (API) asociado a Recálculos>
- DJ: 03/03/2021 <Se agregó la función [inventario].[USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS]>
- Andrés Santos: 26/10/2021 <Se modifica el cálculo del costo con el @pum_FactorCalculado en la funcion [inventario].[USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS]>
- Andrés Santos: 20/05/2022 - El costo de la NC de la compra (Mov. Salida en Inv.) no será recalculado. Tambien se actualizara el tipo de cambio en Inv según el Doc origen (Nc Compra)
- Andrés Santos: 22/07/2022 - Se corrigío un inner join entre inventariodet y costounitario el cual producia un error al obtener costos de entrada en Movs. Mixtos
- David Jove: 14/03/2023 - Se optimizó el tiempo de recálculo. Se agregó la nueva región de código 'Asignamos costo salida agrupado por fecha', donde se encuentra el core de la solución se encuentra en el grupo
- David Jove: 04/07/2023 - Se replanteó la optimización del recálculo. Debido a que las salidas también repercuten en el cálculo del costo promedio salida, ahora dicho costo se generará (USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS) durante el recálculo y no previo a este
- David Jove: 10/07/2023 - Se corrigió la última optimización del recálculo agregando el filtro por ID_UMP y Cd_Alm en la asignación de @FechaDesdeCostoPromedio
- Pedro Espinoza: 21/12/2023 - Se valida de la configuración general sobre IB_KardexAlm - IB_KardexUM en el filtro de nuevos ingresos para obtener el costo de salida.
- David Jove: 05/09/2024 - (100762) Se modificaron los join miDstNC y ciNC para que no traiga duplicado cuando la NC sea de un producto pack
- Pedro Espinoza: 09/04/2025 - (112608) Se actualizó la función  USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS_2
- Pedro Espinoza: 01/07/2025 - (114403) Actualización ZOWI
- David Jove: 30/10/2025 - (121139) Se agregó el sp [inventario].[USP_COSTO_INVENTARIO_RECALCULAR_INDIVIDUAL_PROMEDIO] en vez del script antiguo
- David Jove: 04/10/2025 - (122181) Se versionó el sp. Se agregaron los parámetros @P_USUARIO_RECALCULO y @P_FECHA_RECALCULO. Se agregó el sp [seguridad].[USP_T_RECALCULO_COSTOS_INVENTARIO_LOG_INSERTAR] para realizar el registro del LOG del recálculo de costos de inventario
*/