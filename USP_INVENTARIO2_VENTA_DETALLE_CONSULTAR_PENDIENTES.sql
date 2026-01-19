USE [ERP_ECHA]
GO
/****** Object:  StoredProcedure [dbo].[USP_INVENTARIO2_VENTA_DETALLE_CONSULTAR_PENDIENTES]    Script Date: 14/01/2026 07:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
ALTER PROCEDURE [dbo].[USP_INVENTARIO2_VENTA_DETALLE_CONSULTAR_PENDIENTES]
(      
@RucE nvarchar(11),        
@Codigo nvarchar(20),        
@UsuActual nvarchar(10),        
@Columna varchar(50),        
@Dato varchar(50),        
@Param varchar(4000),    
@Param5 VARCHAR(4000)    
)      
      
AS        
      
--DECLARE            
--@RucE  NVARCHAR(11) = '20604791899',            
--@Codigo  NVARCHAR(20)= 'VT00007626',            
--@UsuActual  NVARCHAR(10)= '',            
--@Columna VARCHAR(50)= '',            
--@Dato  VARCHAR(50) = '',            
--@Param  VARCHAR(4000) = '',      
--@Param5 VARCHAR(4000) = '' --'INV000000001'  
  
DECLARE            
@L_RucE NVARCHAR(11) = @RucE,  
@L_Codigo NVARCHAR(20) = @Codigo,  
@L_UsuActual NVARCHAR(10) = @UsuActual,  
@L_Columna VARCHAR(50) = @Columna,  
@L_Dato VARCHAR(50) = @Dato,  
@L_Param VARCHAR(4000) = @Param,  
@L_Param5 VARCHAR(4000) = @Param5      
        
DECLARE @IC_CodComer char(1), @IC_Descrip char(1)        
Select  @IC_CodComer = IC_CodComerProd, @IC_Descrip = IC_DescripProd from Cfg_Inv_General where RucE = @L_RucE        
declare @Cd_TD nvarchar(4) = (Select Cd_TD from Venta WITH (NOLOCK) where RucE = @L_RucE and Cd_Vta = @L_Codigo)        
        
DECLARE @L_TABLA_MOVIMIENTO TABLE           
(          
RucE VARCHAR(11),    
FechaDoc DATETIME,  
Cd_Doc VARCHAR(20) INDEX IDX1 CLUSTERED,    
Item INT,    
CantidadUsada NUMERIC(20,10)    
)    
     
IF ISNULL(@L_Param5,'') = ''    
BEGIN    
 INSERT INTO @L_TABLA_MOVIMIENTO        
 SELECT   
  *   
 FROM   
  VW_INVENTARIO2_CANTIDAD_UTILIZADA_DOCUMENTOS_2   
 WHERE   
  RucE = @L_RucE   
  AND SUBSTRING(ISNULL(Cd_Doc,''), 1, 2) IN ('OP','VT','GR')  
  
 --SELECT * FROM VW_INVENTARIO2_CANTIDAD_UTILIZADA_DOCUMENTOS WHERE RucE = @L_RucE    
END    
ELSE    
BEGIN    
 INSERT INTO @L_TABLA_MOVIMIENTO            
 SELECT   
  *   
 FROM   
  INVENTARIO.FS_MOVIMIENTOINVENTARIO_CANTIDAD_UTILIZADA_DOCUMENTOS_2 (@L_RucE, @L_Param5, NULL, NULL, NULL/*@L_FecDesde, @L_FecHasta*/)   
 WHERE   
  SUBSTRING(ISNULL(Cd_Doc,''), 1, 2) IN ('OP','VT','GR')  
  
 --SELECT * FROM INVENTARIO.FS_MOVIMIENTOINVENTARIO_CANTIDAD_UTILIZADA_DOCUMENTOS2 (@L_RucE, @L_Param5, NULL /*@L_Param*/)    
END     
        
IF(@Cd_TD = '07')        
BEGIN           
 SELECT            
  ROW_NUMBER() OVER(ORDER BY(vd.RucE)) NumOrden,        
  vd.RucE,        
  vd.Cd_Vta Codigo,        
  vd.Nro_RegVdt Item_INV,        
  vd.Cd_Prod Prod_INV,        
  Isnull(CASE WHEN @IC_CodComer = '1' THEN p2.CodCo1_ ELSE CASE WHEN @IC_CodComer = '2' THEN p2.CodCo2_ ELSE p2.CodCo3_ END END,vd.Cd_Prod) CodComer,        
  CASE WHEN  @IC_Descrip = '1' THEN p2.Nombre1 ELSE p2.Nombre2 END Descrip,        
  vd.ID_UMP UMP_INV,        
  pum.DescripAlt UnidadMedida_INV,        
  pum.DescripAlt_Secundaria as DescripUM2_INV,        
  vd.Cantidad_UM_Secundario as CantUMSec_INV,        
  ISNULL(p2.IB_Lote,0) Lote_INV,        
  ISNULL(p2.IB_Srs,0) Serial_INV,        
  ISNULL(vp.Codigo,'') CodigoGDP_INV,        
  case when v.Cd_TD='07' then ISNULL(CostoInventario.Valor,0.00) else ISNULL([inventario].[USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS](vd.RucE,(CASE WHEN v.Cd_TD = '07' THEN ISNULL(i2.FechaMovimiento,getdate()) ELSE GETDATE() END),    
  (Select Cd_Mda from Venta v WITH (NOLOCK) where v.RucE = vd.RucE and v.Cd_Vta = vd.Cd_Vta),vd.Cd_Prod,vd.ID_UMP,@L_Param),0.00) end CostoUnitario_INV,        
  (ISNULL(vd.Cant,0) - ISNULL(rs.CantidadUsada,0)) Cantidad,        
  v.CamMda CamMda_INV,        
  v.Cd_Mda CdMda_INV,        
  i2.FechaMovimiento,        
  vd.Cd_CC as CodCentroCosto_INV,        
  vd.Cd_SC as CodSubCentroCosto_INV,        
  vd.Cd_SS as CodSubSubCentroCosto_INV,        
  vd.Cd_Alm as CodAlmacen_INV,        
  p2.IB_Conv as IBConv_INV,        
  pum.IC_CL as ICCL_INV,        
  pum.Factor,        
  p2.IB_EsGrupo as EsGrupo,        
  alm.Nombre as Almacen,  
  CASE WHEN ISNULL(vd.C_CODIGO_LOTE,'') = '' THEN NULL ELSE vd.C_CODIGO_LOTE END as CdLote,  
  CASE WHEN ISNULL(vd.C_NUMERO_LOTE,'') = '' THEN NULL ELSE vd.C_NUMERO_LOTE END as NroLote, 
  vd.C_ID_SERIAL as IdSerial,  
  vd.C_SERIAL as NroSerial  
 FROM         
  VentaDet vd WITH (NOLOCK)        
  left join Venta v WITH (NOLOCK) on v.RucE = @L_RucE and v.Cd_Vta = vd.Cd_Vta        
  left join Producto2 p2 on p2.RucE = @L_RucE and vd.Cd_Prod = p2.Cd_Prod        
  left join GrupoDinamicoProductoVersiones vp on vp.RucE = @L_RucE and vp.Cd_Prod = p2.Cd_Prod        
  left join Prod_UM pum on pum.RucE = @L_RucE and pum.Cd_Prod = p2.Cd_Prod and vd.ID_UMP = pum.ID_UMP        
  left join UnidadMedida um on pum.Cd_UM = um.Cd_UM        
  left join         
  (        
  select        
   y.RucE, y.Cd_Vta, y.Item, ISNULL(SUM(CantidadUsada),0) CantidadUsada        
  from        
   (        
   select        
    RucE, Cd_Doc as Cd_Vta, Item, CantidadUsada        
   from        
    @L_TABLA_MOVIMIENTO        
   where        
    ISNULL(Cd_Doc,'') <> ''        
    and Cd_Doc=@L_Codigo        
        
   UNION ALL        
        
   select        
    mi.RucE, mdv.Cd_Vta_Destino, mdv.Nro_RegVdt_Destino, mi.CantidadUsada        
   from        
    @L_TABLA_MOVIMIENTO mi        
    inner join MovimientosDetalleVenta mdv on mdv.RucE = @L_RucE and mdv.Cd_OP_Origen=mi.Cd_Doc and mdv.Item_OP_Origen=mi.Item        
   where        
    ISNULL(mi.Cd_Doc,'')<>''        
        
   UNION ALL        
        
   select        
    mi.RucE, mdv.Cd_Vta_Origen, mdv.Nro_RegVdt_Origen, mi.CantidadUsada        
   from        
    @L_TABLA_MOVIMIENTO mi        
    inner join MovimientosDetalleVenta mdv on mdv.RucE = @L_RucE and mdv.Cd_GR_Destino=mi.Cd_Doc and mdv.Item_GR_Destino=mi.Item        
   where        
    ISNULL(mi.Cd_Doc,'')<>''        
    and mi.Cd_Doc=@L_Codigo        
              
   UNION ALL        
               
   select        
    mi.RucE, mdv.Cd_Vta_Destino, mdv.Nro_RegVdt_Destino, mi.CantidadUsada        
   from        
    @L_TABLA_MOVIMIENTO mi        
    inner join MovimientosDetalleVenta mdv on mdv.RucE = @L_RucE and mdv.Cd_GR_Origen=mi.Cd_Doc and mdv.Item_GR_Origen=mi.Item        
   where        
    ISNULL(mi.Cd_Doc,'')<>''        
    and mdv.Cd_Vta_Destino=@L_Codigo        
   ) y        
  group by         
   y.RucE, y.Cd_Vta, y.Item        
  ) rs on rs.RucE = @L_RucE and rs.Cd_Vta = vd.Cd_Vta and rs.Item = vd.Nro_RegVdt        
  left join MovimientoInventario mi on mi.RucE = @L_RucE and mi.Cd_Vta_Origen = v.DR_CdVta        
  left join InventarioDet2 id2 on id2.RucE = @L_RucE and id2.Cd_Inv = mi.Cd_Inv_Destino and id2.Item = mi.Item_Destino        
  left join Inventario2 i2 on i2.RucE = @L_RucE and i2.Cd_Inv = id2.Cd_Inv        
  left join        
  (        
  select   
   mdv.Cd_Vta_Destino as Cd_Vta, mdv.Nro_RegVdt_Destino as Nro_RegVdt, ci.Costo_MN as Valor        
  from   
   VentaDet vd WITH (NOLOCK)         
   left join CfgGeneral cfg on cfg.RucE = @L_RucE        
   left join MovimientoInventario mi on mi.RucE = @L_RucE and mi.Cd_Vta_Origen=vd.Cd_Vta and mi.Item_Origen=vd.Nro_RegVdt        
   left join Costoinventario ci on ci.RucE = @L_RucE and ci.Cd_Inv=mi.Cd_Inv_Destino and ci.Item=mi.Item_Destino and ci.IC_TipoCostoInventario=case cfg.IC_TipoCostoInventario when 'PROMEDIO' then 'M' when 'PEPS' then 'P' else '' end        
   left join MovimientosDetalleVenta mdv on mdv.RucE = @L_RucE and mdv.Cd_Vta_Origen=vd.Cd_Vta and mdv.Nro_RegVdt_Origen=vd.Nro_RegVdt        
  where   
   vd.RucE=@L_RucE and mi.Cd_Inv_Destino is not null        
  ) as CostoInventario on CostoInventario.Cd_Vta = vd.Cd_Vta and CostoInventario.Nro_RegVdt=vd.Nro_RegVdt        
  left join Almacen alm on alm.RucE = @L_RucE and alm.Cd_Alm=vd.Cd_Alm        
 WHERE         
  vd.RucE = @L_RucE        
  and vd.Cd_Vta = @L_Codigo        
  and ISNULL(v.TipoNC,'') <> 'DS'        
  and ISNULL(vd.Cd_Prod,'') <> ''        
  and (ISNULL(vd.Cant,0) - ISNULL(rs.CantidadUsada,0)) > 0        
  and CASE WHEN @L_Columna = 'Codigo' THEN Isnull(vd.Cd_Vta,'') ELSE '' END like CASE WHEN 'Codigo'=@L_Columna THEN '%'+@L_Dato+'%' ELSE '' END        
  and CASE WHEN @L_Columna = 'NumOrden' THEN Isnull(Convert(varchar,vd.Nro_RegVdt),'') ELSE '' END like CASE WHEN 'NumOrden'=@L_Columna THEN '%'+@L_Dato+'%' ELSE '' END       
  and CASE WHEN @L_Columna = 'Cantidad' THEN Isnull(Convert(varchar,vd.Cant),'') ELSE '' END like CASE WHEN 'Cantidad'=@L_Columna THEN '%'+@L_Dato+'%' ELSE '' END        
 GROUP BY        
  vd.RucE,        
  vd.Cd_Vta,        
  vd.Nro_RegVdt,        
  vd.Cd_Prod,        
  p2.CodCo1_,        
  p2.CodCo2_ ,        
  p2.CodCo3_ ,        
  p2.Nombre1,        
  p2.Nombre2,        
  vd.ID_UMP ,        
  pum.DescripAlt,    
  pum.DescripAlt_Secundaria,  
  vd.Cantidad_UM_Secundario,  
  p2.IB_Lote,        
  p2.IB_Srs,        
  vp.Codigo,        
  v.Cd_TD,        
  vd.Cant,        
  rs.CantidadUsada,             
  v.CamMda,        
  v.Cd_Mda,        
  i2.FechaMovimiento,        
  vd.Cd_CC ,        
  vd.Cd_SC ,        
  vd.Cd_SS ,        
  vd.Cd_Alm,        
  p2.IB_Conv,        
  pum.IC_CL,        
  pum.Factor,        
  CostoInventario.Valor,        
  p2.IB_EsGrupo,        
  alm.Nombre,  
  vd.C_CODIGO_LOTE,  
  vd.C_NUMERO_LOTE,  
  vd.C_ID_SERIAL,  
  vd.C_SERIAL  
    
 OPTION (RECOMPILE)  
END        
ELSE        
BEGIN        
 SELECT         
  vd.RucE,        
  vd.Cd_Vta Codigo,        
  vd.Nro_RegVdt NumOrden,        
  vd.Cd_Prod Prod_INV,        
  Isnull(CASE WHEN @IC_CodComer = '1' THEN p2.CodCo1_ ELSE CASE WHEN @IC_CodComer = '2' THEN p2.CodCo2_ ELSE p2.CodCo3_ END END,vd.Cd_Prod) CodComer_INV,        
  CASE WHEN  @IC_Descrip = '1' THEN p2.Nombre1 ELSE p2.Nombre2 END Descrip_INV,        
  vd.ID_UMP UMP_INV,        
  pum.DescripAlt UnidadMedida_INV,        
  pum.Cd_UM_Secundaria as UM2_INV,        
  pum.DescripAlt_Secundaria as DescripUM2_INV,        
  vd.Cantidad_UM_Secundario as CantUMSec_INV,        
  ISNULL(p2.IB_Lote,0) Lote_INV,        
  ISNULL(p2.IB_Srs,0) Serial_INV,        
  case when v.Cd_TD='07' then ISNULL(CostoInventario.Valor,0.00) else ISNULL([inventario].[USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS](vd.RucE,GETDATE(),V.Cd_Mda,vd.Cd_Prod ,vd.ID_UMP,@L_Param),0.00) end CostoUnitario_INV,        
  (ISNULL(vd.Cant,0) - ISNULL(rs.CantidadUsada,0)) Cantidad,        
  v.CamMda CamMda_INV,        
  v.Cd_Mda CdMda_INV,        
  ISNULL(vp.Codigo,'') CodigoGDP_INV,        
  p2.IB_Conv as IBConv_IN,        
  pum.IC_CL as ICCL_INV,        
  pum.Factor,        
  vd.Cd_Alm as CdAlm,        
  p2.IB_EsGrupo as EsGrupo,        
  alm.Nombre as Almacen,        
  vd.Cd_CC as CodCentroCosto_INV,        
  vd.Cd_SC as CodSubCentroCosto_INV,        
  vd.Cd_SS as CodSubSubCentroCosto_INV,  
  CASE WHEN ISNULL(vd.C_CODIGO_LOTE,'') = '' THEN NULL ELSE vd.C_CODIGO_LOTE END as CdLote,  
  CASE WHEN ISNULL(vd.C_NUMERO_LOTE,'') = '' THEN NULL ELSE vd.C_NUMERO_LOTE END as NroLote,  
  vd.C_ID_SERIAL as IdSerial,  
  vd.C_SERIAL as NroSerial  
 from         
  VentaDet vd WITH (NOLOCK)         
  left join Venta v WITH (NOLOCK) on v.RucE = @L_RucE and v.Cd_Vta = vd.Cd_Vta        
  left join Producto2 p2 on p2.RucE = @L_RucE and vd.Cd_Prod = p2.Cd_Prod        
  left join Prod_UM pum on pum.RucE = @L_RucE and pum.Cd_Prod = p2.Cd_Prod and vd.ID_UMP = pum.ID_UMP        
  left join GrupoDinamicoProductoVersiones vp on vp.RucE = @L_RucE and vp.Cd_Prod = p2.Cd_Prod        
  left join UnidadMedida um on pum.Cd_UM = um.Cd_UM        
  left join         
  (        
  select        
   RucE, Cd_Doc as Cd_Vta, Item, CantidadUsada        
  from        
   @L_TABLA_MOVIMIENTO        
  where        
   ISNULL(Cd_Doc,'') <> ''        
   and Cd_Doc=@L_Codigo        
        
  UNION ALL        
        
  select        
   mi.RucE, mdv.Cd_Vta_Destino, mdv.Nro_RegVdt_Destino, mi.CantidadUsada        
  from        
   @L_TABLA_MOVIMIENTO mi        
   inner join MovimientosDetalleVenta mdv on mdv.RucE = @L_RucE and mdv.Cd_OP_Origen=mi.Cd_Doc and mdv.Item_OP_Origen=mi.Item        
  where        
   ISNULL(mi.Cd_Doc,'')<>''        
        
  UNION ALL        
        
  select        
   mi.RucE, mdv.Cd_Vta_Origen, mdv.Nro_RegVdt_Origen, mi.CantidadUsada        
  from        
   @L_TABLA_MOVIMIENTO mi        
   inner join MovimientosDetalleVenta mdv on mdv.RucE = @L_RucE and mdv.Cd_GR_Destino=mi.Cd_Doc and mdv.Item_GR_Destino=mi.Item        
  where        
   ISNULL(mi.Cd_Doc,'')<>''        
   and mi.Cd_Doc=@L_Codigo     
              
  UNION ALL        
               
  select        
   mi.RucE, mdv.Cd_Vta_Destino, mdv.Nro_RegVdt_Destino, mi.CantidadUsada        
  from        
   @L_TABLA_MOVIMIENTO mi        
   inner join MovimientosDetalleVenta mdv on mdv.RucE = @L_RucE and mdv.Cd_GR_Origen=mi.Cd_Doc and mdv.Item_GR_Origen=mi.Item        
  where        
   ISNULL(mi.Cd_Doc,'')<>''        
   and mdv.Cd_Vta_Destino=@L_Codigo        
  ) rs on rs.RucE = @L_RucE and rs.Cd_Vta = vd.Cd_Vta and rs.Item = vd.Nro_RegVdt        
  left join        
  (        
  select   
   mdv.Cd_Vta_Destino as Cd_Vta, mdv.Nro_RegVdt_Destino as Nro_RegVdt, ci.Costo_MN as Valor        
  from   
   VentaDet vd WITH (NOLOCK)        
   left join CfgGeneral cfg on cfg.RucE = @L_RucE        
   left join MovimientoInventario mi on mi.RucE = @L_RucE and mi.Cd_Vta_Origen=vd.Cd_Vta and mi.Item_Origen=vd.Nro_RegVdt        
   left join Costoinventario ci on ci.RucE = @L_RucE and ci.Cd_Inv=mi.Cd_Inv_Destino and ci.Item=mi.Item_Destino and ci.IC_TipoCostoInventario=case cfg.IC_TipoCostoInventario when 'PROMEDIO' then 'M' when 'PEPS' then 'P' else '' end        
   left join MovimientosDetalleVenta mdv on mdv.RucE = @L_RucE and mdv.Cd_Vta_Origen=vd.Cd_Vta and mdv.Nro_RegVdt_Origen=vd.Nro_RegVdt        
  where   
   vd.RucE=@L_RucE   
   and mi.Cd_Inv_Destino is not null        
  ) as CostoInventario on CostoInventario.Cd_Vta=vd.Cd_Vta and CostoInventario.Nro_RegVdt=vd.Nro_RegVdt        
  left join Almacen alm on alm.RucE = @L_RucE and alm.Cd_Alm=vd.Cd_Alm        
 WHERE        
  vd.RucE = @L_RucE        
  and vd.Cd_Vta = @L_Codigo        
  and ISNULL(v.TipoNC,'') <> 'DS'        
  and ISNULL(vd.Cd_Prod,'') <> ''        
  and (ISNULL(vd.Cant,0) - ISNULL(rs.CantidadUsada,0)) > 0        
  and CASE WHEN @L_Columna = 'Codigo' THEN Isnull(vd.Cd_Vta,'') ELSE '' END like CASE WHEN 'Codigo'=@L_Columna THEN '%'+@L_Dato+'%' ELSE '' END        
  and CASE WHEN @L_Columna = 'NumOrden' THEN Isnull(Convert(varchar,vd.Nro_RegVdt),'') ELSE '' END like CASE WHEN 'NumOrden'=@L_Columna THEN '%'+@L_Dato+'%' ELSE '' END        
  and CASE WHEN @L_Columna = 'Cantidad' THEN Isnull(Convert(varchar,vd.Cant),'') ELSE '' END like CASE WHEN 'Cantidad'=@L_Columna THEN '%'+@L_Dato+'%' ELSE '' END       
    
 OPTION (RECOMPILE)  
END        
        
/************************** LEYENDA        
        
| USUARIO       | | FECHA      | | DESCRIPCIÓN            
| Andrés Santos | | 08/09/2022 | | Creación del Query      
| David Jove    | | 24/10/2022 | | Se agregaron los campos DescripUM2_INV, CantUMSec_INV, CdLote, NroLote, IdSerial y NroSerial  
| Andrés Santos | | 20/01/2022 | | Se valida el isnull para CdLote y NroLote. Caso 77328
        
***************************/