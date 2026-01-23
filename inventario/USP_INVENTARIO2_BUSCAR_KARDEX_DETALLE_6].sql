USE [ERP_ECHA]
GO
/****** Object:  StoredProcedure [inventario].[USP_INVENTARIO2_BUSCAR_KARDEX_DETALLE_6]    Script Date: 23/01/2026 10:13:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [inventario].[USP_INVENTARIO2_BUSCAR_KARDEX_DETALLE_6]
@P_RUC_EMPRESA VARCHAR(11),  
@P_EJERCICIO CHAR(4),  
@P_CODIGO_MONEDA CHAR(2),  
@P_FECHA_HASTA DATE, 
@P_CODIGO_PRODUCTO CHAR(7),  
@P_FECHA_DESDE DATE,  
@P_IB_MOSTRAR_DOCUMENTOS_RELACIONADOS BIT,  
@P_USUARIO NVARCHAR(10)  
AS
--DECLARE  
--@P_RUC_EMPRESA VARCHAR(11) = '20725252035',  
--@P_EJERCICIO CHAR(4) = '2025',  
--@P_CODIGO_MONEDA CHAR(2) = '01',  
--@P_FECHA_HASTA DATE = '30/06/2025',  
--@P_CODIGO_PRODUCTO CHAR(7) = 'PD00239',  
--@P_FECHA_DESDE DATE = '01/06/2025',  
--@P_IB_MOSTRAR_DOCUMENTOS_RELACIONADOS BIT = 0,  
--@P_USUARIO NVARCHAR(10) = 'lenny'

DECLARE       
@L_ESTADO CHAR(1), --^[ 'B' => 'TODO EN BASE A UNIDAD DE MEDIDA BASE', 'R' => 'TODO EN BASE A UNIDAD DE MEDIDA DE REGISTRO'      
@L_TIPO_COSTO VARCHAR(1),      
@L_IC_NOMBRE CHAR(1),      
@L_IC_CODIGO CHAR(1),      
@IB_KardexAlm BIT,      
@IB_KardexUM BIT,      
@IB_VARIAS_UMP_PRINCIPAL BIT = ISNULL((select C_IB_VARIAS_UMP_PRINCIPAL from Cfg_Inv_General where RucE=@P_RUC_EMPRESA),0),      
@CANTIDAD_DECIMALES_COSTO INT = 10, --> ES LA CANTIDAD MÁXIMA DE DECIMALES CON LA QUE SE PUEDE CONFIGURAR EL COSTO EN PROCESO DE INVENTARIO    
@CANTIDAD_DECIMALES_MOSTRAR_CANTIDAD INT,  
@CANTIDAD_DECIMALES_MOSTRAR_COSTO INT  
      
SELECT TOP 1 @L_IC_NOMBRE = IC_DescripProd,@L_IC_CODIGO = IC_CodComerProd,@CANTIDAD_DECIMALES_MOSTRAR_CANTIDAD = CantDec_Cantidad,@CANTIDAD_DECIMALES_MOSTRAR_COSTO = CantDec_CostoUnitario  
FROM Cfg_Inv_General  
WHERE RucE = @P_RUC_EMPRESA  
  
SELECT @L_ESTADO = CASE isnull(C_IB_CONVERTIR_UMP, 0) WHEN 0 THEN 'R' ELSE 'B' END  
FROM Config_Inventario2   
WHERE RucE = @P_RUC_EMPRESA AND Ejer = @P_EJERCICIO AND Usuario = @P_USUARIO  
  
SELECT TOP 1 @L_TIPO_COSTO = CASE IC_TipoCostoInventario WHEN 'PROMEDIO' THEN 'M' WHEN 'PEPS' THEN 'P' END,      
@IB_KardexAlm = IB_KardexAlm,      
@IB_KardexUM = IB_KardexUM      
FROM CfgGeneral      
WHERE RucE = @P_RUC_EMPRESA      
      
PRINT 'TIPO COSTO: ' + @L_TIPO_COSTO --PROMEDIO(M) | PEPS(P)      
PRINT 'N° DE CODIGO: ' + @L_IC_CODIGO      
       
IF (@P_CODIGO_PRODUCTO = '')      
 SET @P_CODIGO_PRODUCTO = NULL  
     
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------    
  
declare @TablaDocumentoRelacionado table    
(    
 CodigoInventario char(12),    
 ItemInventario int,    
 TipoDocumento char(2),    
 NumeroSerie varchar(50),    
 NumeroDocumento varchar(50),    
 PrecioVenta numeric(30,15),    
 EsVenta bit,    
 CodigoInterno varchar(12),    
 CodigoProveedor char(7),    
 CodigoCliente char(10),    
 NombreAuxiliar varchar(200),    
 TipoDocumentoAuxiliar varchar(100),    
 NumeroDocumentoAuxiliar varchar(200),    
 DocumentoFinal varchar(100),    
 SerieDocumentoFinal varchar(100),    
 NumeroDocumentoFinal varchar(100),    
 INDEX IDX1 CLUSTERED (CodigoInventario,ItemInventario)    
)    
  
DECLARE @L_TABLA_DOCUMENTO_RELACIONADO_FINAL TABLE  
(  
RucE VARCHAR(11),  
Cd_Inv_Destino VARCHAR(12),  
Item_Destino INT,  
DocumentoFinal VARCHAR(12),  
SerieDocumentoFinal VARCHAR(20),  
NumeroDocumentoFinal VARCHAR(20)  
--,INDEX IDX69 CLUSTERED (RucE, Cd_Inv_Destino, Item_Destino)   
)  
    
if (@P_IB_MOSTRAR_DOCUMENTOS_RELACIONADOS = 1)    
begin    
 -- Insertamos la información de documentos relacionados finales  
 INSERT INTO @L_TABLA_DOCUMENTO_RELACIONADO_FINAL  
  SELECT  
   mi.RucE,  
   mi.Cd_Inv_Destino,  
   mi.Item_Destino,  
   comRel.Cd_Com_Destino AS 'DocumentoFinal',  
   com.NroSre AS 'SerieDocumentoFinal',    
   com.NroDoc AS 'NumeroDocumentoFinal'  
  FROM  
   MovimientoInventario MI  
   INNER JOIN InventarioDet2 id on id.RucE=mi.RucE and id.Cd_Inv=mi.Cd_Inv_Destino and id.Item=mi.Item_Destino and id.Cd_Prod=@P_CODIGO_PRODUCTO    
   INNER JOIN GExCOxOCxSCo comRel on comRel.RucE = @P_RUC_EMPRESA and comRel.Cd_OC_Origen = mi.Cd_OC_Origen and comRel.Item_Origen = mi.Item_Origen      
   INNER JOIN Compra2 com on com.RucE = @P_RUC_EMPRESA and com.Cd_Com = comRel.Cd_Com_Destino       
  WHERE  
   mi.RucE = @P_RUC_EMPRESA  
   AND mi.Cd_Inv_Destino IS NOT NULL  
   AND mi.Item_Destino IS NOT NULL  
  UNION ALL  
  SELECT  
   mi.RucE,  
   mi.Cd_Inv_Destino,  
   mi.Item_Destino,  
   vtaRel.Cd_Vta_Destino AS 'DocumentoFinal',  
   vta.NroSre AS 'SerieDocumentoFinal',    
   vta.NroDoc AS 'NumeroDocumentoFinal'  
  FROM  
   MovimientoInventario MI  
   INNER JOIN InventarioDet2 id on id.RucE=mi.RucE and id.Cd_Inv=mi.Cd_Inv_Destino and id.Item=mi.Item_Destino and id.Cd_Prod=@P_CODIGO_PRODUCTO       
   INNER JOIN MovimientosDetalleVenta vtaRel on vtaRel.RucE = @P_RUC_EMPRESA and vtaRel.Cd_OP_Origen = mi.Cd_OP_Origen and vtaRel.Item_OP_Origen = mi.Item_Origen      
   INNER JOIN Venta vta WITH(NOLOCK) on vta.RucE = @P_RUC_EMPRESA and vta.Cd_Vta = vtaRel.Cd_Vta_Destino    
  WHERE  
   mi.RucE = @P_RUC_EMPRESA  
   AND mi.Cd_Inv_Destino IS NOT NULL  
   AND mi.Item_Destino IS NOT NULL  
  
 -- Registramos en la tabla documentos relacionados    
 insert into    
  @TablaDocumentoRelacionado    
 SELECT    
 core.CodigoInventario,      
 core.ItemInventario,    
 ISNULL(td.C_CODIGO_SUNAT, '00') as TipoDocumento,      
 core.NumeroSerie,      
 core.NumeroDocumento,      
 core.PrecioVenta,      
 core.EsVenta,      
 core.CodigoInterno,      
 --core.ItemInterno,      
 core.CodigoProveedor,      
 core.CodigoCliente,      
 CASE WHEN core.CodigoCliente is not null THEN ISNULL(ci.RSocial, ci.Nom + ' ' + ci.ApPat + ' ' + ci.ApMat)      
 WHEN core.CodigoProveedor is not null THEN ISNULL(pv.RSocial, pv.Nom + ' ' + pv.ApPat + ' ' +pv.ApMat)      
 END AS NombreAuxiliar,      
 CASE WHEN core.CodigoCliente is not null THEN ci.Cd_TDI      
 WHEN core.CodigoProveedor is not null THEN pv.Cd_TDI      
 END AS TipoDocumentoAuxiliar,      
 CASE WHEN core.CodigoCliente is not null THEN ci.NDoc      
 WHEN core.CodigoProveedor is not null THEN pv.NDoc      
 END AS NumeroDocumentoAuxiliar,      
 core.DocumentoFinal,      
 core.SerieDocumentoFinal,      
 core.NumeroDocumentoFinal      
 /*INICIO CORE*/      
 FROM      
 (      
 select      
 _miv.RucE,      
 _miv.CodigoInventario,      
 _miv.ItemInventario,    
 COALESCE(CASE WHEN mi.Cd_GE_Origen IS NOT NULL THEN '09' ELSE NULL END,gr.Cd_TD,vt.Cd_TD,cp.Cd_TD,cpip.Cd_TD,'')  AS 'TipoDocumento',    
 COALESCE(ge.NumSerie,gr.NroSre,vt.NroSre,cp.NroSre,cpip.NroSre)  AS 'NumeroSerie',    
 COALESCE(ge.NumDocumento,gr.NroGR,vt.NroDoc,op.NroOp,cp.NroDoc,oc.NroOC,sr.NroSR,fb.NroOF,cpip.NroDoc)  AS 'NumeroDocumento',    
 COALESCE(ge.Cd_GE,gr.Cd_GR,vt.Cd_Vta,op.Cd_OP,cp.Cd_Com,oc.Cd_OC,sr.Cd_SR,fb.Cd_OF,ipd.Cd_Com)  as 'CodigoInterno',    
 COALESCE(gr.Cd_Clt,vt.Cd_Clt,op.Cd_Clt,fb.Cd_Clt) as 'CodigoCliente',    
 COALESCE(ge.Cd_Prv,gr.Cd_Prv,cp.Cd_Prv,oc.Cd_Prv)  AS 'CodigoProveedor',      
 --COALESCE(comRel.Cd_Com_Destino,vtaRel.Cd_Vta_Destino) AS 'DocumentoFinal',    
 --COALESCE(com.NroSre,vta.NroSre) as 'SerieDocumentoFinal',    
 --COALESCE(com.NroDoc,vta.NroDoc) AS 'NumeroDocumentoFinal',    
 DocFinal.DocumentoFinal,  
 DocFinal.SerieDocumentoFinal,  
 DocFinal.NumeroDocumentoFinal,  
 _miv.PrecioVenta,      
 _miv.EsVenta      
 from      
 (      
  select      
  miv.RucE,      
  miv.CodigoInventario,      
  miv.ItemInventario,      
  SUM(ISNULL(miv.PrecioVenta,0)) as PrecioVenta,      
  case when SUM(ISNULL(miv.EsVenta,0)) > 0 then 1 else 0 end as EsVenta      
  from      
  (      
  SELECT      
  mi.RucE,      
  mi.Cd_Inv_Destino as CodigoInventario,      
  mi.Item_Destino as ItemInventario,      
  --CASE WHEN vd.Cantidad = 0 THEN 0 ELSE (mi.CantidadUsada / CONVERT(float,vd.Cantidad)) * PrecioVenta END as PrecioVenta,      
  CASE WHEN vd.Cantidad = 0 THEN 0 ELSE (mi.CantidadUsada / vd.Cantidad) * PrecioVenta END as PrecioVenta,      
  CASE WHEN mi.Cd_Vta_Origen IS NOT NULL THEN 1 ELSE 0 END as EsVenta      
  FROM      
  MovimientoInventario mi    
  INNER JOIN InventarioDet2 id on id.RucE=mi.RucE and id.Cd_Inv=mi.Cd_Inv_Destino and id.Item=mi.Item_Destino and id.Cd_Prod=@P_CODIGO_PRODUCTO    
  LEFT JOIN Venta vt WITH(NOLOCK) on vt.RucE = mi.RucE AND vt.Cd_Vta = mi.Cd_Vta_Origen       
  LEFT JOIN      
  (      
   SELECT       
   vd.RucE,      
   vd.Cd_Vta as CodigoVenta,      
   vd.Nro_RegVdt as ItemVenta,      
   vd.Cant as Cantidad,      
   CASE WHEN vd.TransferenciaGratuita = 1 THEN 0 ELSE vd.TotalNeto END AS PrecioVenta      
   FROM      
   VentaDet vd WITH(NOLOCK)      
   WHERE      
   vd.RucE=@P_RUC_EMPRESA and vd.Cd_Prod=@P_CODIGO_PRODUCTO      
  ) AS vd on vd.RucE = vt.RucE AND vt.Cd_Vta = vd.CodigoVenta AND vd.ItemVenta = mi.Item_Origen      
  WHERE      
  mi.RucE = @P_RUC_EMPRESA      
  AND Cd_Inv_Destino IS NOT NULL      
  AND Item_Destino IS NOT NULL      
  AND Cd_Inv_Origen IS NULL      
  ) as miv      
  group by      
  miv.RucE,      
  miv.CodigoInventario,      
  miv.ItemInventario      
 ) as _miv    
 /* INICIO SUB CORE */    
 LEFT JOIN MovimientoInventario mi on mi.RucE = _miv.RucE and mi.Cd_Inv_Destino = _miv.CodigoInventario and mi.Item_Destino = _miv.ItemInventario    
 LEFT JOIN GuiaRemision gr on gr.RucE = mi.RucE AND gr.Cd_GR = mi.Cd_GR_Origen    
 LEFT JOIN Venta vt WITH(NOLOCK) on vt.RucE = mi.RucE AND vt.Cd_Vta = mi.Cd_Vta_Origen    
 LEFT JOIN Compra2 cp on cp.RucE = mi.RucE AND cp.Cd_Com = mi.Cd_Com_Origen    
 LEFT JOIN ImportacionDet ipd on ipd.RucE = mi.RucE AND ipd.Cd_IP = mi.Cd_IP_Origen and ipd.Item = mi.Item_Origen    
 LEFT JOIN Compra2 cpip on cpip.RucE = mi.RucE AND cpip.Cd_Com = ipd.Cd_Com    
 LEFT JOIN GuiaEntrada ge on ge.RucE=@P_RUC_EMPRESA AND ge.Cd_GE=mi.Cd_GE_Origen    
 LEFT JOIN OrdPedido op on op.RucE=@P_RUC_EMPRESA AND op.Cd_OP=mi.Cd_OP_Origen    
 LEFT JOIN OrdCompra2 oc on oc.RucE=@P_RUC_EMPRESA AND oc.Cd_OC=mi.Cd_OC_Origen    
 LEFT JOIN SolicitudReq2 sr on sr.RucE=@P_RUC_EMPRESA AND sr.Cd_SR=mi.Cd_SR_Origen    
 LEFT JOIN OrdFabricacion fb on fb.RucE=@P_RUC_EMPRESA AND fb.Cd_OF=mi.Cd_OF_Origen    
    
 ----DocumentoFinal  (Antiguo)  
 --LEFT JOIN GExCOxOCxSCo comRel on comRel.RucE=@P_RUC_EMPRESA and comRel.Cd_OC_Origen=mi.Cd_OC_Origen and comRel.Item_Origen=mi.Item_Origen      
 --LEFT JOIN Compra2 com on com.RucE=@P_RUC_EMPRESA and com.Cd_Com=comRel.Cd_Com_Destino      
 --LEFT JOIN MovimientosDetalleVenta vtaRel on vtaRel.RucE=@P_RUC_EMPRESA and vtaRel.Cd_OP_Origen=mi.Cd_OP_Origen and vtaRel.Item_OP_Origen=mi.Item_Origen      
 --LEFT JOIN Venta vta WITH(NOLOCK) on vta.RucE=@P_RUC_EMPRESA and vta.Cd_Vta=vtaRel.Cd_Vta_Destino    
  
 LEFT JOIN --DocumentoFinal  
 (  
 SELECT  
 RucE,  
 Cd_Inv_Destino,  
 Item_Destino,  
 DocumentoFinal = STUFF((  
  SELECT  
  ', ' + DocumentoFinal  
  FROM  
  @L_TABLA_DOCUMENTO_RELACIONADO_FINAL A  
  WHERE  
  A.RUCE = B.RUCE  
  AND A.Cd_Inv_Destino = B.Cd_Inv_Destino  
  AND A.Item_Destino = B.Item_Destino  
  FOR XML PATH ('')),1,1,''),  
 SerieDocumentoFinal = STUFF((  
  SELECT  
  ', ' + SerieDocumentoFinal  
  FROM  
  @L_TABLA_DOCUMENTO_RELACIONADO_FINAL A  
  WHERE  
  A.RUCE = B.RUCE  
  AND A.Cd_Inv_Destino = B.Cd_Inv_Destino  
  AND A.Item_Destino = B.Item_Destino  
  FOR XML PATH ('')),1,1,''),  
 NumeroDocumentoFinal = STUFF((  
  SELECT  
  ', ' + NumeroDocumentoFinal  
  FROM  
  @L_TABLA_DOCUMENTO_RELACIONADO_FINAL A  
  WHERE  
  A.RUCE = B.RUCE  
  AND A.Cd_Inv_Destino = B.Cd_Inv_Destino  
  AND A.Item_Destino = B.Item_Destino  
  FOR XML PATH ('')),1,1,'')  
 FROM  
 @L_TABLA_DOCUMENTO_RELACIONADO_FINAL B  
 GROUP BY  
 RucE, Cd_Inv_Destino, Item_Destino  
 )DocFinal on mi.RucE = DocFinal.RucE and mi.Cd_Inv_Destino = DocFinal.Cd_Inv_Destino and mi.Item_Destino = DocFinal.Item_Destino  
  
 /* FIN SUB CORE */      
 ) as core      
 /*FIN DE CORE*/      
 LEFT JOIN Cliente2 ci on ci.RucE = core.RucE and ci.Cd_Clt = core.CodigoCliente      
 LEFT JOIN Proveedor2 pv on pv.RucE = core.RucE and pv.Cd_Prv = core.CodigoProveedor      
 LEFT JOIN TipDoc td on td.Cd_TD = core.TipoDocumento     
end    
    
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------    
    
--select * from @TablaDocumentoRelacionado    
--return    
    
SELECT       
 core.FechaMovimiento,     
 ISNULL(core.Cd_Inv,'') as C_CODIGO_INVENTARIO,      
 ISNULL(core.Item,0) as C_ITEM_INVENTARIO,      
 ISNULL(core.RegistroContable,'') as C_REGISTRO_CONTABLE,      
 ISNULL(core.FechaMovimiento, cast(-53690 as datetime)) as C_FECHA_MOVIMIENTO,      
 ISNULL(core.Cd_Alm,'') as C_CODIGO_ALMACEN,      
 ISNULL(alm.Nombre,'') as C_NOMBRE_ALMACEN,      
 ISNULL(core.Cd_Prod,'') as C_CODIGO_PRODUCTO,    
 ISNULL(p.CodCo1_,'') as C_CODIGO_COMERCIAL,    
 ISNULL(CASE @L_IC_NOMBRE WHEN '2' THEN p.Nombre2 ELSE p.Nombre1 END,'') AS C_NOMBRE_PRODUCTO,      
 ISNULL(core.Cd_UM,'') as C_CODIGO_UNIDAD_MEDIDA,      
 ISNULL(um.Nombre,'') as C_NOMBRE_UNIDAD_MEDIDA,      
 ISNULL(core.Cd_UM_Base,'') as C_CODIGO_UNIDAD_MEDIDA_BASE,      
 ISNULL(umb.Nombre,'') as C_NOMBRE_UNIDAD_MEDIDA_BASE,      
 ISNULL(core.Factor,0) as C_FACTOR,          
 ISNULL(MCA.Nombre,0) as C_MARCA,       
 ISNULL(CLA.Nombre,0) as C_CLASE,       
 ISNULL(CLAB.Nombre,0) as C_SUB_CLASE,       
 ISNULL(CLABB.Nombre,0) as C_SUB_SUB_CLASE,      
 ISNULL(CASE core.IC_ES WHEN 'E' THEN 'Entrada' WHEN 'S' THEN 'Salida' END,'') as C_MOVIMIENTO,      
 ISNULL(core.DescripAlt,'') as C_UMP_REG,      
 ISNULL(core.Cantidad,0) as C_CANTIDAD,      
 ISNULL(core.Cd_TO,'') as C_CODIGO_TIPO_OPERACION,      
 ISNULL(CASE WHEN core.Cd_TO = 'SALDO_INICIAL' THEN '**Saldo Inicial**' ELSE core.Nombre END,'') as C_NOMBRE_TIPO_OPERACION,      
 ISNULL(core.CodigoInterno,'') as C_CODIGO_REFERENCIA,      
 ISNULL(td.C_CODIGO_SUNAT,'') as C_CODIGO_TIPO_DOCUMENTO,      
 ISNULL(td.Descrip,'') as C_NOMBRE_TIPO_DOCUMENTO,      
 ISNULL(core.NumeroSerie,'') as C_NUMERO_SERIE,      
 ISNULL(core.NumeroDocumento,'') as C_NUMERO_DOCUMENTO,      
 ISNULL(core.DocumentoFinal,'') as C_DOCUMENTO_FINAL,      
 ISNULL(core.SerieDocumentoFinal,'') as C_SERIE_DOCUMENTO_FINAL,      
 ISNULL(core.NumeroDocumentoFinal,'') as C_NUMERO_DOCUMENTO_FINAL,      
 ISNULL(core.CantidadEntradas,0) as C_ENTRADA_CANTIDAD,      
 ISNULL(core.CostoEntradas,0) as C_ENTRADA_COSTO,      
 ISNULL(core.TotalEntradas,0) as C_ENTRADA_TOTAL,      
 ISNULL(core.CantidadSalidas,0) as C_SALIDA_CANTIDAD,      
 ISNULL(core.CostoSalidas,0) as C_SALIDA_COSTO,      
 ISNULL(core.TotalSalidas,0) as C_SALIDA_TOTAL,      
 ISNULL(core.SaldoCantidad,0) as C_SALDO_CANTIDAD,      
 ISNULL(core.SaldoCosto,0) as C_SALDO_COSTO,      
 ISNULL(core.SaldoTotal,0) as C_SALDO_TOTAL,      
 ISNULL(te.CodSNT_,'') as C_CODIGO_TIPO_EXISTENCIA,      
 ISNULL(te.Nombre,'') as C_NOMBRE_TIPO_EXISTENCIA,      
 ISNULL(core.Cd_CC,'') as C_CODIGO_CENTRO_COSTO,      
 ISNULL(core.Cd_SC,'') as C_CODIGO_SUB_CENTRO_COSTO,      
 ISNULL(core.Cd_SS,'') as C_CODIGO_SUB_SUB_CENTRO_COSTO,  
 ISNULL(c.Descrip,'') as C_NOMBRE_CENTRO_COSTO,      
 ISNULL(s.Descrip,'') as C_NOMBRE_SUB_CENTRO_COSTO,      
 ISNULL(ss.Descrip,'') as C_NOMBRE_SUB_SUB_CENTRO_COSTO,  
 ISNULL(CASE WHEN core.EsVenta = 1 THEN core.PrecioVenta - core.TotalSalidas ELSE 0 END,0) as C_MARGEN_VENTA,      
 ISNULL(core.SegundaUnidadCantidadEntrada,0) as C_SEGUNDA_UNIDAD_ENTRADA_CANTIDAD,      
 ISNULL(core.SegundaUnidadCantidadSalida,0) as C_SEGUNDA_UNIDAD_SALIDA_CANTIDAD,      
 ISNULL(core.SegundaUnidadSaldoCantidad,0) as C_SEGUNDA_UNIDAD_SALDO_CANTIDAD,      
 ISNULL(tdi.CodSNT_,'') as C_CODIGO_TIPO_DOCUMENTO_AUXILIAR,      
 ISNULL(tdi.Descrip,'') as C_NOMBRE_TIPO_DOCUMENTO_AUXILIAR,      
 ISNULL(tdi.NCorto,'') as C_NOMBRE_CORTO_TIPO_DOCUMENTO_AUXILIAR,      
 ISNULL(core.NumeroDocumentoAuxiliar,'') as C_NUMERO_DOCUMENTO_AUXILIAR,      
 ISNULL(core.NombreAuxiliar,'') as C_NOMBRE_AUXILIAR,      
 CASE @L_TIPO_COSTO WHEN 'M' THEN 'PROMEDIO' WHEN 'P' THEN 'PEPS' ELSE '' END as C_METODOLOGIA,  
 core.Cd_MIS as C_CODIGO_MIS,
 pumsm.DescripAlt as C_UMP_SIN_CONVERTIR,
 csm.Cantidad as C_CANTIDAD_SIN_CONVERTIR
 --core.C_ID_UMP_REGISTRO
 --core.ID_UMP_PRINCIPAL,
 --core.ID_UMP
FROM     
 (      
  SELECT       
  *,      
  CASE @L_TIPO_COSTO      
   WHEN 'M' THEN      
      CASE WHEN core.SaldoCantidad = 0 THEN 0 ELSE core.SaldoTotal / core.SaldoCantidad END      
   WHEN 'P' THEN      
      CASE core.IC_ES WHEN 'E' THEN core.CostoEntradas WHEN 'S' THEN (case when core.SaldoCantidad<=0 then 0 else core.CostoSalidas end) ELSE 0 END      
   ELSE 0      
  END as SaldoCosto      
  FROM (      
	   SELECT *,      
	   ROUND(core.CantidadEntradas * CONVERT(float,core.CostoEntradas),6) as TotalEntradas,      
	   ROUND(core.CantidadSalidas * CONVERT(float,core.CostoSalidas),6) as TotalSalidas,      
	   ROUND(  
   CASE @L_ESTADO WHEN 'B' THEN      
		SUM (ROUND(CASE core.IC_ES WHEN 'E' THEN core.CantidadEntradas * CONVERT(float,core.CostoEntradas) ELSE 0 END,@CANTIDAD_DECIMALES_COSTO))       
		  OVER(PARTITION BY       
		  core.Cd_Prod,      
		  CASE WHEN @IB_KardexAlm = 1 THEN core.Cd_Alm ELSE '1' END,      
		  CASE WHEN @IB_KardexUM = 1 THEN core.Cd_UM ELSE '1' END,     
	   CASE @L_TIPO_COSTO WHEN 'P' THEN (CASE core.IC_ES WHEN 'E' THEN ROUND(core.CostoEntradas,@CANTIDAD_DECIMALES_COSTO) WHEN 'S' THEN ROUND(core.CostoSalidas,@CANTIDAD_DECIMALES_COSTO) ELSE 0 END) ELSE 1 END,      
		  core.ID_UMP_PRINCIPAL  
		  ORDER BY core.FechaMovimiento, core.Correlativo, core.Cd_INV, core.Item/*, core.Cd_Inv_Entrada, core.Item_Entrada */ASC)      
   ELSE      
		SUM (ROUND(CASE core.IC_ES WHEN 'E' THEN core.CantidadEntradas * CONVERT(float,core.CostoEntradas) ELSE 0 END,@CANTIDAD_DECIMALES_COSTO))       
  OVER(PARTITION BY  
	  core.Cd_Prod,  
	  CASE WHEN @IB_KardexAlm = 1 THEN core.Cd_Alm ELSE '1' END,      
	  CASE WHEN @IB_KardexUM = 1 THEN core.Cd_UM ELSE '1' END,  
	  CASE @L_TIPO_COSTO WHEN 'P' THEN (CASE core.IC_ES WHEN 'E' THEN ROUND(core.CostoEntradas,@CANTIDAD_DECIMALES_COSTO) WHEN 'S' THEN ROUND(core.CostoSalidas,@CANTIDAD_DECIMALES_COSTO) ELSE 0 END) ELSE 1 END,      
	  core.ID_UMP_PRINCIPAL  
	  ORDER BY core.FechaMovimiento, core.Correlativo, core.Cd_INV, core.Item/*, core.Cd_Inv_Entrada, core.Item_Entrada */ASC)          
	   END  
	   +  
	   CASE @L_ESTADO WHEN 'B' THEN      
		SUM (ROUND(CASE core.IC_ES WHEN 'S' THEN -1 * ABS(core.CantidadSalidas * CONVERT(float,core.CostoSalidas)) ELSE 0 END,@CANTIDAD_DECIMALES_COSTO))       
		  OVER(PARTITION BY       
		  core.Cd_Prod,      
		  CASE WHEN @IB_KardexAlm = 1 THEN core.Cd_Alm ELSE '1' END,      
		  CASE WHEN @IB_KardexUM = 1 THEN core.Cd_UM ELSE '1' END,     
	   CASE @L_TIPO_COSTO WHEN 'P' THEN (CASE core.IC_ES WHEN 'E' THEN ROUND(core.CostoEntradas,@CANTIDAD_DECIMALES_COSTO) WHEN 'S' THEN ROUND(core.CostoSalidas,@CANTIDAD_DECIMALES_COSTO) ELSE 0 END) ELSE 1 END,      
		  core.ID_UMP_PRINCIPAL  
		  ORDER BY core.FechaMovimiento, core.Correlativo, core.Cd_INV, core.Item/*, core.Cd_Inv_Entrada, core.Item_Entrada */ASC)      
   ELSE      
    SUM (ROUND(CASE core.IC_ES WHEN 'S' THEN -1 * ABS(core.CantidadSalidas * CONVERT(float,core.CostoSalidas)) ELSE 0 END,@CANTIDAD_DECIMALES_COSTO))       
  OVER(PARTITION BY  
  core.Cd_Prod,  
  CASE WHEN @IB_KardexAlm = 1 THEN core.Cd_Alm ELSE '1' END,      
  CASE WHEN @IB_KardexUM = 1 THEN core.Cd_UM ELSE '1' END,  
  CASE @L_TIPO_COSTO WHEN 'P' THEN (CASE core.IC_ES WHEN 'E' THEN ROUND(core.CostoEntradas,@CANTIDAD_DECIMALES_COSTO) WHEN 'S' THEN ROUND(core.CostoSalidas,@CANTIDAD_DECIMALES_COSTO) ELSE 0 END) ELSE 1 END,      
  core.ID_UMP_PRINCIPAL  
  ORDER BY core.FechaMovimiento, core.Correlativo, core.Cd_INV, core.Item/*, core.Cd_Inv_Entrada, core.Item_Entrada */ASC)          
   END,6)  
   as SaldoTotal      
   FROM (      
     SELECT       
     MONTH(id.FechaMovimiento) as Periodo,      
     YEAR(id.FechaMovimiento) as Ejercicio,      
     id.RucE,      
     id.Cd_Alm,      
     id.Cantidad,      
     id.Cd_TO,      
     id.Cd_CC,      
     id.Cd_SC,      
     id.Cd_SS,      
     id.RegistroContable,     
  ci.Correlativo,  
     id.Cd_Inv,      
     id.Item,      
     id.Cd_Prod,      
     pum.Cd_UM,      
     pum.Factor,      
     pum.DescripAlt,      
     pumBase.Cd_UM AS Cd_UM_Base,      
     pumBase.ID_UMP_PRINCIPAL,      
     id.IC_ES,      
     id.FechaMovimiento,      
     rel.TipoDocumento,      
     rel.NumeroSerie,      
     rel.NumeroDocumento,      
     tpo.Nombre,      
     --ci.Cd_Inv_Entrada,       
     --ci.Item_Entrada,           
     CASE id.IC_ES WHEN 'E' THEN CASE @L_ESTADO WHEN 'B' THEN ISNULL(ci.Cantidad,0) * pum.FactorCalculado ELSE ISNULL(ci.Cantidad,0) END ELSE 0 END as CantidadEntradas,      
     CASE id.IC_ES WHEN 'S' THEN CASE @L_ESTADO WHEN 'B' THEN ISNULL(ci.Cantidad,0) * pum.FactorCalculado ELSE ISNULL(ci.Cantidad,0) END ELSE 0 END as CantidadSalidas,      
     CASE id.IC_ES WHEN 'E' THEN CASE @L_ESTADO WHEN 'B' THEN ISNULL(ci.Costo, 0) * (CASE ISNULL(pum.FactorCalculado,0) WHEN 0 THEN 0 ELSE 1.0/pum.FactorCalculado END) ELSE ISNULL(ci.Costo, 0) END ELSE 0 END as CostoEntradas, --CASE id.IC_ES WHEN 'E' THEN ISNULL(ci.Costo, 0) ELSE 0 END as CostoEntradas,      
     CASE id.IC_ES WHEN 'S' THEN CASE @L_ESTADO WHEN 'B' THEN ISNULL(ci.Costo, 0) ELSE ISNULL(ci.Costo, 0) * CONVERT(float,(CASE ISNULL(pum.FactorCalculado,0) WHEN 0 THEN 0 ELSE pum.FactorCalculado END)) END END as CostoSalidas,--* (CASE ISNULL(pum.FactorCalculado,0) WHEN 0 THEN 0 ELSE 1.0/pum.FactorCalculado END) ELSE 0 END as CostoSalidas,  --CASE id.IC_ES WHEN 'S' THEN ISNULL(ci.Costo, 0) ELSE 0 END as CostoSalidas,      
     CASE @L_ESTADO WHEN 'B'       
      THEN       
       SUM (CASE id.IC_ES WHEN 'E' THEN ISNULL(ci.Cantidad,0) * pum.FactorCalculado WHEN 'S' THEN -1 * ABS(ISNULL(ci.Cantidad,0) * pum.FactorCalculado) ELSE 0 END)       
        OVER(PARTITION BY       
          id.Cd_Prod,      
          case when @L_TIPO_COSTO='P' then id.Cd_Alm else (CASE WHEN @IB_KardexAlm = 1 THEN id.Cd_Alm ELSE '1' END) end,      
          case when @L_TIPO_COSTO='P' then pum.Cd_UM else (CASE WHEN @IB_KardexUM = 1 THEN pum.Cd_UM ELSE '1' END) end,      
          CASE @L_TIPO_COSTO WHEN 'P' THEN (CASE id.IC_ES WHEN 'E' THEN ROUND(ISNULL(ci.Costo, 0) * (CASE ISNULL(pum.FactorCalculado,0) WHEN 0 THEN 0 ELSE 1.0/pum.FactorCalculado END),@CANTIDAD_DECIMALES_COSTO) ELSE ROUND(ISNULL(ci.Costo, 0),@CANTIDAD_DECIMALES_COSTO) END) ELSE 1 END,      
          pumBase.ID_UMP_PRINCIPAL  
          ORDER BY id.FechaMovimiento, ci.Correlativo, id.Cd_INV, id.Item/*, ci.Cd_Inv_Entrada, ci.Item_Entrada*/ ASC)      
      ELSE       
       SUM (CASE id.IC_ES WHEN 'E' THEN ISNULL(ci.Cantidad,0) WHEN 'S' THEN -1 * ABS(ISNULL(ci.Cantidad,0)) ELSE 0 END)       
        OVER(PARTITION BY       
          id.Cd_Prod,       
          case when @L_TIPO_COSTO='P' then id.Cd_Alm else (CASE WHEN @IB_KardexAlm = 1 THEN id.Cd_Alm ELSE '1' END) end,      
          case when @L_TIPO_COSTO='P' then pum.Cd_UM else (CASE WHEN @IB_KardexUM = 1 THEN pum.Cd_UM ELSE '1' END) end,      
          CASE @L_TIPO_COSTO WHEN 'P' THEN (CASE id.IC_ES WHEN 'E' THEN ROUND(ISNULL(ci.Costo, 0),@CANTIDAD_DECIMALES_COSTO) ELSE ROUND(ISNULL(ci.Costo, 0) * (CASE ISNULL(pum.FactorCalculado,0) WHEN 0 THEN 0 ELSE pum.FactorCalculado END),@CANTIDAD_DECIMALES_COSTO) END) ELSE 1 END,      
          pumBase.ID_UMP_PRINCIPAL  
          ORDER BY id.FechaMovimiento, ci.Correlativo, id.Cd_INV, id.Item/*, ci.Cd_Inv_Entrada, ci.Item_Entrada */ASC)      
     END AS SaldoCantidad,       
     rel.PrecioVenta,      
     rel.EsVenta,      
     rel.CodigoInterno,      
     CASE id.IC_ES WHEN 'E' THEN CASE @L_ESTADO WHEN 'B' THEN ISNULL(ci.CantidadSecundaria,0) * pum.FactorCalculado ELSE ISNULL(ci.CantidadSecundaria,0) END ELSE 0 END as SegundaUnidadCantidadEntrada,      
     CASE id.IC_ES WHEN 'S' THEN CASE @L_ESTADO WHEN 'B' THEN ISNULL(ci.CantidadSecundaria,0) * pum.FactorCalculado ELSE ISNULL(ci.CantidadSecundaria,0) END ELSE 0 END as SegundaUnidadCantidadSalida,      
     CASE @L_ESTADO WHEN 'B'       
      THEN      
       SUM (CASE id.IC_ES WHEN 'E' THEN ISNULL(ci.CantidadSecundaria,0) WHEN 'S' THEN -1 * ABS(ISNULL(ci.CantidadSecundaria,0)) ELSE 0 END)       
        OVER(PARTITION BY       
          id.Cd_Prod,      
          CASE WHEN @IB_KardexAlm = 1 THEN id.Cd_Alm ELSE '1' END,      
          CASE WHEN @IB_KardexUM = 1 THEN pum.Cd_UM ELSE '1' END,       
          CASE @L_TIPO_COSTO WHEN 'P' THEN (CASE id.IC_ES WHEN 'E' THEN ROUND(ISNULL(ci.Costo, 0) * (CASE ISNULL(pum.FactorCalculado,0) WHEN 0 THEN 0 ELSE 1.0/pum.FactorCalculado END),@CANTIDAD_DECIMALES_COSTO) ELSE ROUND(ISNULL(ci.Costo, 0),@CANTIDAD_DECIMALES_COSTO) END) ELSE 1 END       
        ORDER BY id.FechaMovimiento, ci.Correlativo, id.Cd_INV, id.Item/*, ci.Cd_Inv_Entrada, ci.Item_Entrada*/ ASC)      
      ELSE      
       SUM (CASE id.IC_ES WHEN 'E' THEN ISNULL(ci.CantidadSecundaria,0) * pum.FactorCalculado WHEN 'S' THEN -1 * ABS(ISNULL(ci.CantidadSecundaria,0) * pum.FactorCalculado) ELSE 0 END)       
        OVER(PARTITION BY id.Cd_Prod, pum.Cd_UM, CASE @L_TIPO_COSTO WHEN 'P' THEN (CASE id.IC_ES WHEN 'E' THEN ROUND(ISNULL(ci.Costo, 0) * (CASE ISNULL(pum.FactorCalculado,0) WHEN 0 THEN 0 ELSE 1.0/pum.FactorCalculado END),@CANTIDAD_DECIMALES_COSTO) ELSE 
ROUND(ISNULL(ci.Costo, 0),@CANTIDAD_DECIMALES_COSTO) END) ELSE 1 END ORDER BY id.FechaMovimiento, id.Cd_INV, id.Item/*, ci.Cd_Inv_Entrada, ci.Item_Entrada */ASC)      
     END as SegundaUnidadSaldoCantidad,      
           
     CASE WHEN rel.NumeroDocumentoAuxiliar IS NOT NULL THEN rel.NumeroDocumentoAuxiliar ELSE ci.NumeroDocumentoAuxiliar END AS NumeroDocumentoAuxiliar,      
     CASE WHEN rel.TipoDocumentoAuxiliar IS NOT NULL THEN rel.TipoDocumentoAuxiliar ELSE ci.TipoDocumentoAuxiliar END AS TipoDocumentoAuxiliar,      
     CASE WHEN rel.NombreAuxiliar IS NOT NULL THEN rel.NombreAuxiliar ELSE ci.NombreAuxiliar END AS NombreAuxiliar,      
     rel.DocumentoFinal,--CASE WHEN id.IC_ES='E' THEN comRel.Cd_Com_Destino ELSE vtaRel.Cd_Vta_Destino END as DocumentoFinal,      
     rel.SerieDocumentoFinal,--CASE WHEN id.IC_ES='E' THEN com.NroSre ELSE vta.NroSre END as SerieDocumentoFinal,      
     rel.NumeroDocumentoFinal,--CASE WHEN id.IC_ES='E' THEN com.NroDoc ELSE vta.NroDoc END as NumeroDocumentoFinal      
	 id.Cd_MIS,
	 --id.Id_Serial
	 id.ID_UMP,
	 id.C_ID_UMP_REGISTRO
     FROM (      
      
      SELECT       
      'SALDO_INICIAL' AS Cd_TO,      
      --DATEADD( DAY, -1,CONVERT(smalldatetime,  '01/' + @P_PERIODO_DESDE + '/' + @P_EJERCICIO)) AS FechaMovimiento,      
      '' AS FechaMovimiento,      
      '-' AS RegistroContable,      
      id.RucE,      
      id.Cd_Prod AS Cd_Inv,      
      id.Cd_Prod,      
      Convert(varchar,CASE WHEN @IB_KardexUM = 1 THEN id.ID_UMP ELSE 0 END) +       
      CASE WHEN @IB_KardexAlm = 1 THEN id.Cd_Alm ELSE 'ALM' END AS Item,      
      CASE WHEN @IB_KardexUM = 1 THEN id.ID_UMP ELSE 0 END AS ID_UMP,      
      CASE WHEN @IB_KardexAlm = 1 THEN id.Cd_Alm ELSE 'ALM' END AS Cd_Alm,      
      SUM(id.Cantidad) AS Cantidad,      
      '-' AS Cd_CC,      
      '-' AS Cd_SC,      
      '-' AS Cd_SS,      
      'E' AS IC_ES,  
	  i.Cd_MIS,
	  --sm.Id_Serial  
	  id.C_ID_UMP_REGISTRO
      FROM InventarioDet2 id      
      INNER  JOIN Inventario2 i on i.RucE = id.RucE AND i.Cd_Inv = id.Cd_Inv      
      LEFT JOIN Almacen alm on alm.RucE = id.RucE AND alm.Cd_Alm = id.Cd_Alm      
   --left join Serial2Movimiento sm on sm.RucE=id.RucE and sm.Cd_Inv=id.Cd_Inv and sm.Item=id.Item  
      WHERE id.RucE = @P_RUC_EMPRESA and id.Cd_Prod = @P_CODIGO_PRODUCTO      
      AND ISNULL(alm.IB_EsVi, 0) = 0      
      AND CASE @L_ESTADO WHEN 'P' THEN 1 ELSE 0 END = 1            
      GROUP BY id.RucE, id.Cd_Prod, CASE WHEN @IB_KardexAlm = 1 THEN id.Cd_Alm ELSE 'ALM' END, CASE WHEN @IB_KardexUM = 1 THEN id.ID_UMP ELSE 0 END,i.Cd_MIS,id.C_ID_UMP_REGISTRO--,sm.Id_Serial  
      
      UNION ALL      
      
      SELECT      
      i.Cd_TO,      
      i.FechaMovimiento,      
      i.RegistroContable,      
      id.RucE,      
      id.Cd_Inv,      
      id.Cd_Prod,      
      Convert(varchar,id.Item) as Item,      
      id.ID_UMP,      
      id.Cd_Alm,      
      id.Cantidad,      
      id.Cd_CC,      
      id.Cd_SC,      
      id.Cd_SS,      
      id.IC_ES,  
	  i.Cd_MIS,
	  --sm.Id_Serial
	  id.C_ID_UMP_REGISTRO
      FROM InventarioDet2 id      
      INNER  JOIN Inventario2 i on i.RucE = id.RucE AND i.Cd_Inv = id.Cd_Inv      
      LEFT JOIN Almacen alm on alm.RucE = id.RucE and alm.Cd_Alm = id.Cd_Alm      
   --left join Serial2Movimiento sm on sm.RucE=id.RucE and sm.Cd_Inv=id.Cd_Inv and sm.Item=id.Item  
      WHERE id.RucE = @P_RUC_EMPRESA and id.Cd_Prod = @P_CODIGO_PRODUCTO      
      AND ISNULL(alm.IB_EsVi, 0) = 0      
      --FILTRO HASTA      
      AND i.FechaMovimiento <= CASE WHEN @P_FECHA_HASTA IS NULL THEN i.FechaMovimiento ELSE CONVERT(datetime, @P_FECHA_HASTA) + ' 23:59:29' END      
     ) as  id      
     LEFT JOIN (      
      --SELECT      
      --pum.RucE,      
      --pum.Cd_Prod,      
      --pum.Cd_UM,      
      --pum.Factor,      
      --pum.IC_CL      
      --FROM Prod_UM pum      
      --WHERE       
      --pum.RucE = @P_RUC_EMPRESA and pum.Cd_Prod = @P_CODIGO_PRODUCTO      
      --AND pum.IB_UMPPrin = 1      
      --AND pum.Factor = 1      
      
      SELECT      
      pum.RucE,      
      pum.Cd_Prod,      
      pum.Cd_UM,      
      NULL as ID_UMP,      
      pum.Factor,      
      pum.IC_CL,      
      pum.ID_UMP as ID_UMP_PRINCIPAL      
      FROM Prod_UM pum      
      WHERE       
      @IB_VARIAS_UMP_PRINCIPAL = 0      
      AND pum.RucE = @P_RUC_EMPRESA      
      AND pum.Cd_Prod = @P_CODIGO_PRODUCTO      
      AND pum.IB_UMPPrin = 1      
      AND pum.Factor = 1      
      
      UNION ALL      
      
      SELECT      
      ISNULL(pumB.RucE,pum.RucE) as RucE,      
      ISNULL(pumB.Cd_Prod,pum.Cd_Prod) as Cd_Prod,      
      ISNULL(pumB.Cd_UM,pum.Cd_UM) as Cd_UM,      
      ISNULL(pum.ID_UMP,0) as ID_UMP,      
      ISNULL(pumB.Factor,pum.Factor) as Factor,      
      ISNULL(pumB.IC_CL,pum.IC_CL) as IC_CL,      
      ISNULL(pumB.ID_UMP,pum.ID_UMP) as ID_UMP_PRINCIPAL      
      FROM      
      Prod_UM pum      
      left join Prod_UM pumB on pumB.RucE=pum.RucE and pumB.Cd_Prod=pum.Cd_Prod and pumB.ID_UMP=pum.C_ID_UMP_PRINCIPAL      
      WHERE       
      @IB_VARIAS_UMP_PRINCIPAL = 1      
      AND pum.RucE = @P_RUC_EMPRESA      
      AND pum.Cd_Prod = @P_CODIGO_PRODUCTO      
     ) AS pumBase ON pumBase.RucE = id.RucE and pumBase.Cd_Prod = id.Cd_Prod and ISNULL(pumBase.ID_UMP,id.ID_UMP)=id.ID_UMP    
  left join @TablaDocumentoRelacionado as rel on rel.CodigoInventario = id.Cd_Inv AND convert(varchar,rel.ItemInventario) = convert(varchar,id.Item)      
     LEFT JOIN TipoOperacion tpo on tpo.Cd_TO = id.Cd_TO      
     LEFT JOIN      
     (      
      SELECT       
       pum.RucE,      
       pum.Cd_Prod,      
       pum.ID_UMP,      
       pum.Factor,      
       pum.DescripAlt,          
       CASE WHEN ISNULL(pum.IC_CL,'') = '' OR pum.IC_CL = 'M' THEN pum.Factor ELSE (CASE WHEN pum.Factor = 0 THEN 0 ELSE 1.0 / pum.Factor END) END as FactorCalculado,      
       pum.Cd_UM       
      FROM      
       Prod_UM pum      
      WHERE      
       pum.RucE = @P_RUC_EMPRESA and pum.cd_prod = @P_CODIGO_PRODUCTO      
     ) as  pum on pum.RucE = id.RucE AND pum.Cd_Prod = id.Cd_Prod AND pum.ID_UMP = id.ID_UMP      
     LEFT JOIN      
     (      
      
      --SELECT       
      --ci.RucE,       
      --'E' AS IC_ES,      
      --id.Cd_Prod AS Cd_Inv,       
      --Convert(varchar,CASE WHEN @IB_KardexUM = 1 THEN id.ID_UMP ELSE 0 END) +       
      --CASE WHEN @IB_KardexAlm = 1 THEN id.Cd_Alm ELSE 'ALM' END AS Item,      
      --CASE WHEN SUM(CASE id.IC_ES WHEN 'E' THEN ci.Cantidad WHEN 'S' THEN -1 * ABS(ci.Cantidad) END) = 0       
      --  THEN 0       
      --  ELSE       
      --  SUM(CASE @P_CODIGO_MONEDA WHEN '01' THEN ci.Costo_MN WHEN '02' THEN ci.Costo_ME ELSE 0 END *       
      --   CASE id.IC_ES WHEN 'E' THEN ci.Cantidad WHEN 'S' THEN -1 * ABS(ci.Cantidad) END)       
      --  / SUM(CASE id.IC_ES WHEN 'E' THEN ci.Cantidad WHEN 'S' THEN -1 * ABS(ci.Cantidad) END)       
      --  END AS Costo,      
      --SUM(CASE id.IC_ES WHEN 'E' THEN ci.Cantidad WHEN 'S' THEN -1 * ABS(ci.Cantidad) END) AS Cantidad,      
      --@L_TIPO_COSTO AS TipoCosto,      
      --NULL AS Cd_Inv_Entrada,      
      --NULL AS Item_Entrada,      
      --SUM(CASE id.IC_ES WHEN 'E' THEN ci.CantidadSecundaria WHEN 'S' THEN -1 * ABS(ci.CantidadSecundaria) END) AS CantidadSecundaria      
      --,'' AS TipoDocumentoAuxiliar      
      --,'' AS NumeroDocumentoAuxiliar      
  --,'' AS NombreAuxiliar      
      --,'' as Cd_prod      
      --FROM CostoInventario ci      
      --INNER JOIN InventarioDet2 id on ci.RucE = id.RucE and ci.Cd_Inv = id.Cd_Inv and ci.Item = id.Item      
      --INNER JOIN Inventario2 i on i.RucE = id.RucE and i.cd_inv = id.Cd_INV      
      --LEFT JOIN Almacen alm on alm.RucE = ci.RucE and alm.Cd_Alm = id.Cd_Alm      
      --WHERE ci.RucE = @P_RUC_EMPRESA AND ISNULL(ci.IC_TipoCostoInventario, @L_TIPO_COSTO) = @L_TIPO_COSTO and id.cd_prod = @P_CODIGO_PRODUCTO      
      --AND ISNULL(alm.IB_EsVi, 0) = 0            
      --GROUP BY ci.RucE, id.Cd_Prod, CASE WHEN @IB_KardexAlm = 1 THEN id.Cd_Alm ELSE 'ALM' END, CASE WHEN @IB_KardexUM = 1 THEN id.ID_UMP ELSE 0 END,       
      --CASE @L_TIPO_COSTO WHEN 'P' THEN (CASE @P_CODIGO_MONEDA WHEN '01' THEN ci.Costo_MN WHEN '02' THEN ci.Costo_ME ELSE 0 END) ELSE 0 END --quizas id.cd_prod      
      
      --UNION ALL      
            
      --SELECT      
      --*       
      --FROM (      
      -- SELECT       
      -- ci.RucE,      
      -- id.IC_ES,      
      -- ci.Cd_Inv,      
      -- Convert(varchar,ci.Item) as Item,      
      -- CASE @P_CODIGO_MONEDA WHEN '01' THEN ci.Costo_MN WHEN '02' THEN ci.Costo_ME ELSE 0 END AS Costo,      
      -- ci.Cantidad,      
      -- ci.IC_TipoCostoInventario as TipoCosto,      
      -- ci.Cd_Inv_Entrada,      
      -- ci.Item_Entrada,      
      -- ci.CantidadSecundaria      
      -- ,CASE WHEN i.C_CODIGO_PROVEEDOR is not null THEN p2.Cd_TDI      
      --       WHEN i.C_CODIGO_CLIENTE is not null THEN c2.Cd_TDI      
      -- END AS TipoDocumentoAuxiliar      
      
      -- ,CASE WHEN i.C_CODIGO_PROVEEDOR is not null THEN p2.Ndoc      
      --       WHEN i.C_CODIGO_CLIENTE is not null THEN c2.Ndoc      
      -- END AS NumeroDocumentoAuxiliar      
      
      -- ,CASE WHEN i.C_CODIGO_PROVEEDOR is not null THEN ISNULL(p2.RSocial, p2.Nom + ' ' + p2.ApPat + ' ' + p2.ApMat)      
      --    WHEN i.C_CODIGO_CLIENTE is not null THEN ISNULL(c2.RSocial, c2.Nom + ' ' + c2.ApPat + ' ' + c2.ApMat)      
      -- END AS NombreAuxiliar      
      -- ,id.cd_prod      
      -- FROM CostoInventario ci      
      -- INNER JOIN InventarioDet2 id on ci.RucE = id.RucE and ci.Cd_Inv = id.Cd_Inv and ci.Item = id.Item      
      -- INNER JOIN Inventario2 i     on i.RucE = ci.RucE and i.cd_inv = id.cd_inv      
      -- LEFT JOIN Almacen alm on alm.RucE = id.RucE and alm.Cd_Alm = id.Cd_Alm      
      -- LEFT JOIN Cliente2 c2   on c2.RucE = i.RucE and c2.Cd_Clt = i.C_CODIGO_CLIENTE      
      -- LEFT JOIN Proveedor2 p2   on p2.RucE = i.RucE and p2.Cd_Prv = i.C_CODIGO_PROVEEDOR      
      -- WHERE ci.RucE = @P_RUC_EMPRESA and id.cd_prod = @P_CODIGO_PRODUCTO      
      -- AND ISNULL(alm.IB_EsVi, 0) = 0             
      --) as core      
      --WHERE ISNULL(core.TipoCosto, @L_TIPO_COSTO) = @L_TIPO_COSTO /*agregado -->*/ and core.ruce = @P_RUC_EMPRESA and core.cd_prod = @P_CODIGO_PRODUCTO      
      
      SELECT      
       core.RucE,      
       core.IC_ES,     
    core.Correlativo,  
       core.Cd_Inv,      
       core.Item,      
       core.Costo,      
       --CONVERT(FLOAT,SUM(core.Cantidad)) as Cantidad,      
    SUM(core.Cantidad) as Cantidad,      
       core.TipoCosto,      
       SUM(core.CantidadSecundaria) as CantidadSecundaria,      
       core.TipoDocumentoAuxiliar,      
       core.NumeroDocumentoAuxiliar,      
       core.NombreAuxiliar,Cd_prod      
      FROM      
      (      
       --> SE COMENTÓ PORQUE ESTABA MALOGRANDO EL C_SALDO_TOTAL CUANDO SE HACÍA UNA SALIDA DE PRODUCTO CON FACTOR > 1      
      
       --SELECT       
       --ci.RucE,       
       --'E' AS IC_ES,      
       --id.Cd_Prod AS Cd_Inv,       
       --Convert(varchar,CASE WHEN @IB_KardexUM = 1 THEN id.ID_UMP ELSE 0 END) +       
       --CASE WHEN @IB_KardexAlm = 1 THEN id.Cd_Alm ELSE 'ALM' END AS Item,      
       --CASE WHEN SUM(CASE id.IC_ES WHEN 'E' THEN ci.Cantidad WHEN 'S' THEN -1 * ABS(ci.Cantidad) END) = 0       
       --  THEN 0       
       --  ELSE       
       --  SUM(CASE @P_CODIGO_MONEDA WHEN '01' THEN ci.Costo_MN WHEN '02' THEN ci.Costo_ME ELSE 0 END *       
       --   CASE id.IC_ES WHEN 'E' THEN ci.Cantidad WHEN 'S' THEN -1 * ABS(ci.Cantidad) END)       
       --  / CONVERT(float,SUM(CASE id.IC_ES WHEN 'E' THEN ci.Cantidad WHEN 'S' THEN -1 * ABS(ci.Cantidad) END))      
       --  END AS Costo,      
       --SUM(CASE id.IC_ES WHEN 'E' THEN ci.Cantidad WHEN 'S' THEN -1 * ABS(ci.Cantidad) END) AS Cantidad,      
     --@L_TIPO_COSTO AS TipoCosto,      
       --NULL AS Cd_Inv_Entrada,      
       --NULL AS Item_Entrada,      
       --SUM(CASE id.IC_ES WHEN 'E' THEN ci.CantidadSecundaria WHEN 'S' THEN -1 * ABS(ci.CantidadSecundaria) END) AS CantidadSecundaria      
       --,'' AS TipoDocumentoAuxiliar      
       --,'' AS NumeroDocumentoAuxiliar      
       --,'' AS NombreAuxiliar      
       --,'' as Cd_prod      
       --FROM CostoInventario ci      
       --INNER JOIN InventarioDet2 id on ci.RucE = id.RucE and ci.Cd_Inv = id.Cd_Inv and ci.Item = id.Item      
       --INNER JOIN Inventario2 i on i.RucE = id.RucE and i.cd_inv = id.Cd_INV      
       --LEFT JOIN Almacen alm on alm.RucE = ci.RucE and alm.Cd_Alm = id.Cd_Alm      
       --WHERE ci.RucE = @P_RUC_EMPRESA AND ISNULL(ci.IC_TipoCostoInventario, @L_TIPO_COSTO) = @L_TIPO_COSTO and id.cd_prod = @P_CODIGO_PRODUCTO      
       --AND ISNULL(alm.IB_EsVi, 0) = 0            
       --GROUP BY ci.RucE, id.Cd_Prod, CASE WHEN @IB_KardexAlm = 1 THEN id.Cd_Alm ELSE 'ALM' END, CASE WHEN @IB_KardexUM = 1 THEN id.ID_UMP ELSE 0 END,       
       --CASE @L_TIPO_COSTO WHEN 'P' THEN (CASE @P_CODIGO_MONEDA WHEN '01' THEN ci.Costo_MN WHEN '02' THEN ci.Costo_ME ELSE 0 END) ELSE 0 END --quizas id.cd_prod      
      
       --UNION ALL      
            
       SELECT      
       *       
       FROM      
       (      
        SELECT       
         ci.RucE,      
         id.IC_ES,     
   ci.Correlativo,  
         ci.Cd_Inv,      
         Convert(varchar,ci.Item) as Item,      
         --CONVERT(float,CASE @P_CODIGO_MONEDA WHEN '01' THEN ci.Costo_MN WHEN '02' THEN ci.Costo_ME ELSE 0 END) AS Costo,      
   CASE @P_CODIGO_MONEDA WHEN '01' THEN ci.Costo_MN WHEN '02' THEN ci.Costo_ME ELSE 0 END AS Costo,      
         ci.Cantidad,      
         ci.IC_TipoCostoInventario as TipoCosto,      
         ci.Cd_Inv_Entrada,      
         ci.Item_Entrada,      
         ci.CantidadSecundaria      
         ,CASE WHEN i.C_CODIGO_PROVEEDOR is not null THEN p2.Cd_TDI      
           WHEN i.C_CODIGO_CLIENTE is not null THEN c2.Cd_TDI      
         END AS TipoDocumentoAuxiliar      
      
         ,CASE WHEN i.C_CODIGO_PROVEEDOR is not null THEN p2.Ndoc      
           WHEN i.C_CODIGO_CLIENTE is not null THEN c2.Ndoc      
         END AS NumeroDocumentoAuxiliar      
      
         ,CASE WHEN i.C_CODIGO_PROVEEDOR is not null THEN ISNULL(p2.RSocial, p2.Nom + ' ' + p2.ApPat + ' ' + p2.ApMat)      
           WHEN i.C_CODIGO_CLIENTE is not null THEN ISNULL(c2.RSocial, c2.Nom + ' ' + c2.ApPat + ' ' + c2.ApMat)      
         END AS NombreAuxiliar      
         ,id.cd_prod      
        FROM      
         CostoInventario ci      
         INNER JOIN InventarioDet2 id on ci.RucE = id.RucE and ci.Cd_Inv = id.Cd_Inv and ci.Item = id.Item      
         INNER JOIN Inventario2 i     on i.RucE = ci.RucE and i.cd_inv = id.cd_inv      
         LEFT JOIN Almacen alm on alm.RucE = id.RucE and alm.Cd_Alm = id.Cd_Alm      
         LEFT JOIN Cliente2 c2   on c2.RucE = i.RucE and c2.Cd_Clt = i.C_CODIGO_CLIENTE      
         LEFT JOIN Proveedor2 p2   on p2.RucE = i.RucE and p2.Cd_Prv = i.C_CODIGO_PROVEEDOR      
        WHERE      
         ci.RucE = @P_RUC_EMPRESA      
         and id.cd_prod = @P_CODIGO_PRODUCTO      
         AND ISNULL(alm.IB_EsVi, 0) = 0             
       ) as core      
       WHERE ISNULL(core.TipoCosto, @L_TIPO_COSTO) = @L_TIPO_COSTO /*agregado -->*/ and core.ruce = @P_RUC_EMPRESA and core.cd_prod = @P_CODIGO_PRODUCTO      
      ) AS core       
      group by      
      core.RucE, core.IC_ES, core.Correlativo, core.Cd_Inv, core.Item, core.Costo, core.TipoCosto, core.TipoDocumentoAuxiliar, core.NumeroDocumentoAuxiliar, core.NombreAuxiliar,Cd_prod      
      
     ) as ci on ci.RucE = id.RucE AND ci.Cd_Inv = id.Cd_Inv AND convert(varchar,ci.Item) = convert(varchar,id.Item)      
     --left join GExCOxOCxSCo comRel on comRel.RucE=id.RucE and comRel.Cd_OC_Origen=rel.CodigoInterno and comRel.Item_Origen=rel.ItemInterno      
     --left join Compra2 com on com.RucE=id.RucE and com.Cd_Com=comRel.Cd_Com_Destino      
     --left join MovimientosDetalleVenta vtaRel on vtaRel.RucE=id.RucE and vtaRel.Cd_OP_Origen=rel.CodigoInterno and vtaRel.Item_OP_Origen=rel.ItemInterno      
     --left join Venta vta on vta.RucE=id.RucE and vta.Cd_Vta=vtaRel.Cd_Vta_Destino      
           
     WHERE id.RucE = @P_RUC_EMPRESA and id.Cd_Prod = @P_CODIGO_PRODUCTO      
   ) as core      
  ) as core      
) AS core      
LEFT JOIN Almacen alm on alm.RucE = core.RucE and alm.Cd_Alm = core.Cd_Alm      
LEFT JOIN Producto2 p on p.RucE = core.RucE and  p.Cd_prod = core.Cd_Prod    
LEFT JOIN CLASE CLA on p.ruce = CLA.ruce  and  p.Cd_CL = CLA.Cd_CL  
LEFT JOIN CLASESUB CLAB on p.ruce = CLAB.ruce and  p.Cd_CLS = CLAB.Cd_CLS   and  CLA.Cd_CL = CLAB.Cd_CL  
LEFT JOIN CLASESUBSUB CLABB on p.ruce = CLABB.ruce and  p.Cd_CLSS = CLABB.Cd_CLSS and  CLA.Cd_CL = CLABB.Cd_CL  and  CLAB.Cd_CLS = CLABB.Cd_CLS 
LEFT JOIN MARCA MCA on p.ruce = MCA.ruce and  p.Cd_Mca = MCA.Cd_Mca
LEFT JOIN UnidadMedida umb on umb.Cd_UM = core.Cd_UM_Base      
LEFT JOIN UnidadMedida um on um.Cd_UM = core.Cd_UM      
LEFT JOIN TipDoc td on td.Cd_TD = core.TipoDocumento      
LEFT JOIN TipoExistencia te on te.Cd_TE = p.Cd_TE      
LEFT JOIN TipDocIdn tdi on tdi.Cd_TDI = core.TipoDocumentoAuxiliar  
LEFT JOIN CCostos c on c.RucE =core.RucE and c.Cd_CC = core.Cd_CC  
LEFT JOIN CCSub s on c.RucE = s.RucE and c.Cd_CC = s.Cd_CC and s.Cd_SC = core.Cd_SC  
LEFT JOIN CCSubSub ss on c.RucE = ss.RucE and c.Cd_CC = ss.Cd_CC and s.Cd_SC = ss.Cd_SC and ss.Cd_SS = core.Cd_SS
LEFT JOIN Prod_UM pumsm on pumsm.RucE=core.RucE and pumsm.Cd_Prod=core.Cd_Prod and pumsm.ID_UMP=core.C_ID_UMP_REGISTRO
LEFT JOIN
(
	SELECT
		id.Cd_Inv,
		id.Item,
		CASE WHEN ISNULL(p.IB_Conv,0)=0 and id.IC_ES='S' THEN ISNULL(id.Cantidad,0) ELSE ISNULL(id.Cantidad,0) * e.FactorCalculado END AS Cantidad
	FROM
		InventarioDet2 id
		left join Producto2 p on p.RucE=id.RucE and p.Cd_Prod=id.Cd_Prod
		left join
		(
			select
				RucE, Cd_Prod, ID_UMP, IC_CL, Cd_UM, Factor,
				CONVERT(DECIMAL(25,15),case IC_CL when 'M' then 1.0 / (CASE WHEN ISNULL(Factor,0) = 0 THEN 0 ELSE ISNULL(Factor,0) END) when 'D' then ISNULL(Factor,0) else 1 end) as FactorCalculado
			from
				Prod_UM
		) as e on e.RucE=id.RucE and e.Cd_Prod=id.Cd_Prod and e.ID_UMP=CASE WHEN ISNULL(p.IB_Conv,0)=1 THEN id.C_ID_UMP_REGISTRO ELSE id.ID_UMP END
	WHERE
		id.RucE=@P_RUC_EMPRESA
) csm on csm.Cd_Inv=core.Cd_Inv and csm.Item=core.Item
WHERE      
 core.Cd_Prod = @P_CODIGO_PRODUCTO      
 AND core.FechaMovimiento >= CONVERT(datetime, @P_FECHA_DESDE) + ' 00:00:00'    
ORDER BY     
 core.FechaMovimiento,  
 --core.Correlativo,  
 core.Cd_INV,     
 CONVERT(int,core.Item)  
 /*, core.Cd_Inv_Entrada, core.Item_Entrada */  


/************************** LEYENDA

| USUARIO				| | FECHA		| | DESCRIPCIÓN
| Andrés Santos			| | 28/06/2021	| | Creación del query
| David Jove			| | 24/08/2021	| | Se reemplazó el JOIN de documentos relacionados por la variable tabla indexada @TablaDocumentoRelacionado. También, se agregó el parámetro @P_IB_MOSTRAR_DOCUMENTOS_RELACIONADOS
| David Jove			| | 26/08/2021	| | Se agregó el filtro por producto en la tabla @TablaDocumentoRelacionado, mediante un INNER JOIN InventarioDet2
| Ayrthon Bergamino		| | 26/08/2021	| | Se agregó las columna Código Comercial
| Andrés Santos			| | 04/05/2022	| | Se agregó la tabla @L_TABLA_DOCUMENTO_RELACIONADO_FINAL que permite agrupar los docs relacionados finales en 1 sola línea
| David Jove			| | 24/06/2022	| | Se agregó el campo Correlativo en las subconsulta ci y core, para ordenar de manera correcta las salidas en PEPS (Cabe resaltar que en la función Inv_FN_CalculoGeneralCostoPEPS_Inv2 ya se encuentra ordenado por Fecha de Movimiento, por lo tanto el Correlativo de CostoInventario PEPS está ordenado por Fecha de Movimiento)
| David Jove			| | 16/07/2022	| | Se aplicó el FactorCalculado al Costo en los campos SaldoCantidad y SaldoTotal, en la región PARTITION BY, CUANDO ES PEPS. Se agregaron los parámetros @P_EJERCICIO y @P_USUARIO para obtener @L_ESTADO y validar si se convierte o no a UM principal
| David Jove			| | 08/08/2022	| | Se agregó el campo C_CODIGO_MIS para poder generar el asiento contable desde Kardex
| Pedro Espinoza		| | 31/08/2022	| | Se agregó el nombre de los centros de costos
| Rafael Linares		| | 27/10/2022	| | Se hicieron correcciones con respecto a la precision de los calculos para evitar la perdida de decimales por valores provenientes de Fabricacion Caso 72940
| David Jove			| | 22/11/2022	| | Se quitó el join a Serial2Movimiento
| Williams Gutierrez	| | 22/11/2022	| | Se optimizo la consulta de la tabla temporal @L_TABLA_DOCUMENTO_RELACIONADO_FINAL
| Williams Gutierrez	| | 02/01/2023	| | Se quito el convert a float por problemas con decimales
| David Jove			| | 23/01/2023	| | Se agregaron las conversiones a float en los campos 'TotalEntradas', 'TotalSalidas', 'SaldoTotal' y 'CostoSalidas', por problemas de pérdidas de decimales. Se agregaron redondeo de 4 decimales a los campmos 'TotalEntradas', 'TotalSalidas' y 'SaldoTotal'. Se separaron las entradas y salidas del cálculo del 'SaldoTotal'
| David Jove			| | 18/03/2023	| | Se agregaron los redondeos a los campos de COSTO y CANTIDAD en el último nivel de select (NO EN LAS SUBCONSULTAS). Porque COMEX considera que hay descuadre cuando exporta el Kardex, hace foco a la celda y ve todos los decmiales que visualmente estan siendo redondeados.
| David Jove			| | 30/05/2023	| | Se quitaron los redondeos de los montos en el último nivel de select (NO EN LAS SUBCONSULTAS), porque ocasionaban diferencias de céntimos entre el totalizado del detalle y la cabecera
| Rafael Linares		| | 27/11/2023	| | Se cambio de 4 a 6 decimales el redondeo de los totales debido a que en las empresas con muchos movimientos generaba descuadre de 0.01
| David Jove			| | 11/12/2023	| | Se validó el campo SaldoCosto para PEPS: Cuando una salida salda totalmente el stock de un costo especifico, el SaldoCosto resulta en cero.
| David Jove			| | 02/05/2024	| | (96151) Se descomentó el ordenamiento por 'core.FechaMovimiento' y se agregó la conversión a entero el ordenamiento de 'core.Item'.
| David Jove			| | 21/06/2025	| | (114333) Se agregaron los campos C_UMP_SIN_CONVERTIR y C_CANTIDAD_SIN_CONVERTIR

***************************/