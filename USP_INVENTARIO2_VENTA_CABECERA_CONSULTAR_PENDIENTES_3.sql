USE [ERP_ECHA]
GO
/****** Object:  StoredProcedure [dbo].[USP_INVENTARIO2_VENTA_CABECERA_CONSULTAR_PENDIENTES_3]    Script Date: 14/01/2026 07:01:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_INVENTARIO2_VENTA_CABECERA_CONSULTAR_PENDIENTES_3]  
(            
@RucE NVARCHAR(11),    
@FecDesde SMALLDATETIME,    
@FecHasta SMALLDATETIME,    
@Columna NVARCHAR(50),    
@Dato NVARCHAR(50),    
@Param VARCHAR(4000),    
@CodigoConsulta VARCHAR(4000),    
@Param4 VARCHAR(4000),    
@Param5 VARCHAR(4000),  
@P_USUARIO NVARCHAR(10)  
)            
            
AS              
            
SET DATEFORMAT dmy        
  
--DECLARE            
--@RucE NVARCHAR(11) = '99999999999',          
--@FecDesde SMALLDATETIME =  '1/02/2024',         
--@FecHasta SMALLDATETIME = '29/02/2024',          
--@Columna NVARCHAR(50) = '',          
--@Dato NVARCHAR(50) = '',          
--@Param VARCHAR(4000) = '',          
--@CodigoConsulta VARCHAR(4000) = '',      
--@Param4 VARCHAR(4000) = '',      
--@Param5 VARCHAR(4000) = '',  --INV000000001  
--@P_USUARIO NVARCHAR(10)  = 'admin'
    
DECLARE    
@L_RucE NVARCHAR(11) = @RucE,    
@L_FecDesde SMALLDATETIME = @FecDesde,    
@L_FecHasta SMALLDATETIME = @FecHasta,    
@L_Columna NVARCHAR(50) = @Columna,    
@L_Dato NVARCHAR(50) = @Dato,    
@L_Param VARCHAR(4000) = @Param,    
@L_CodigoConsulta VARCHAR(4000) = @CodigoConsulta,    
@L_Param4 VARCHAR(4000) = @Param4,    
@L_Param5 VARCHAR(4000) = @Param5     
  
declare  
@CodigosAreas varchar(MAX) = '',  
@IB_Habilita_AreaxUsuario BIT  
  
SELECT @IB_Habilita_AreaxUsuario = ISNULL(C_IB_HABILITAR_FILTRO_DE_AREA_X_USUARIO_DOCUMENTOS_MOVIMIENTO_INVENTARIO, 0) from Cfg_Inv_General where RucE = @L_RucE  
  
select  
 @CodigosAreas += '[' + Cd_Area + ']'  
from  
 AreaXUsuario axu  
where  
 RucE=@L_RucE  
 and NomUsu=@P_USUARIO  
 and Estado=1  
  
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
  VW_INVENTARIO2_CANTIDAD_UTILIZADA_DOCUMENTOS_2_VT     
 WHERE     
  RucE = @L_RucE     
  AND SUBSTRING(ISNULL(Cd_Doc,''), 1, 2) IN ('VT')    
  AND FechaDoc BETWEEN CONVERT(DATETIME, @L_FecDesde) + ' 00:00:00' AND CONVERT(DATETIME,@L_FecHasta) + ' 23:59:29'    
    
 --SELECT * FROM VW_INVENTARIO2_CANTIDAD_UTILIZADA_DOCUMENTOS WHERE RucE = @L_RucE      
END      
ELSE      
BEGIN      
 INSERT INTO @L_TABLA_MOVIMIENTO              
 SELECT     
  *     
 FROM     
  INVENTARIO.FS_MOVIMIENTOINVENTARIO_CANTIDAD_UTILIZADA_DOCUMENTOS_2 (@L_RucE, @L_Param5, NULL, @L_FecDesde, @L_FecHasta)     
 WHERE     
  SUBSTRING(ISNULL(Cd_Doc,''), 1, 2) IN ('VT')    
    
 --SELECT * FROM INVENTARIO.FS_MOVIMIENTOINVENTARIO_CANTIDAD_UTILIZADA_DOCUMENTOS2 (@L_RucE, @L_Param5, NULL /*@L_Param*/)      
END    
              
;WITH CTE AS               
(              
SELECT             
 miv.RucE,             
 mdv.Cd_Vta_Destino Cd_Vta,             
 mdv.Nro_RegVdt_Destino Item ,             
 miv.CantidadUsada               
FROM             
 MovimientoInventario miv              
 INNER JOIN MovimientosDetalleVenta mdv on mdv.RucE = @L_RucE and mdv.Cd_OP_Origen = miv.Cd_OP_Origen and mdv.Item_OP_Origen = miv.Item_Origen        
 LEFT JOIN inventariodet2 A ON a.ruce = @L_RucE and miv.cd_inv_destino = a.Cd_Inv and miv.Item_Destino = a.Item        
 LEFT JOIN Inventario2 B ON B.RUCE = @L_RucE AND A.CD_INV = B.CD_INV        
 LEFT JOIN TipoOperacion C ON B.CD_TO = C.Cd_TO        
WHERE             
 MIV.RUCE = @L_RucE             
 --AND ISNULL(miv.Cd_OP_Origen,'') <> ''        
 AND (ISNULL(miv.Cd_OP_Origen,'') <> '' AND C.IC_ES != 'A')        
 --AND CASE WHEN ISNULL(@L_CodigoConsulta,'') = '' THEN '1' ELSE Cd_Inv_Destino END <> ISNULL(@L_CodigoConsulta,'')      
 AND CASE WHEN ISNULL(@L_Param5,'') = '' THEN '1' ELSE Cd_Inv_Destino END <> ISNULL(@L_Param5,'')      
            
UNION ALL               
            
SELECT             
 miv.RucE,             
 mdv.Cd_Vta_Origen Cd_Vta,             
 mdv.Nro_RegVdt_Origen Item ,             
 miv.CantidadUsada               
FROM             
 MovimientoInventario miv              
 INNER JOIN MovimientosDetalleVenta mdv on mdv.RucE = @L_RucE and mdv.Cd_GR_Destino = miv.Cd_GR_Origen and mdv.Item_GR_Destino = miv.Item_Origen        
 LEFT JOIN inventariodet2 A ON a.ruce = @L_RucE and miv.cd_inv_destino = a.Cd_Inv and miv.Item_Destino = a.Item        
 LEFT JOIN Inventario2 B ON B.RUCE = @L_RucE AND A.CD_INV = B.CD_INV        
 LEFT JOIN TipoOperacion C ON B.CD_TO = C.Cd_TO        
WHERE             
 MIV.RUCE = @L_RucE             
 --AND ISNULL(miv.Cd_GR_Origen,'') <> ''        
 AND (ISNULL(miv.Cd_GR_Origen,'') <> '' AND C.IC_ES != 'A')        
 --AND CASE WHEN ISNULL(@L_CodigoConsulta,'') = '' THEN '1' ELSE Cd_Inv_Destino END <> ISNULL(@L_CodigoConsulta,'')      
 AND CASE WHEN ISNULL(@L_Param5,'') = '' THEN '1' ELSE Cd_Inv_Destino END <> ISNULL(@L_Param5,'')      
            
UNION ALL              
            
SELECT             
 miv.RucE,             
 mdv.Cd_Vta_Destino Cd_Vta,             
 mdv.Nro_RegVdt_Destino Item ,             
 miv.CantidadUsada               
FROM             
 MovimientoInventario miv              
 INNER JOIN MovimientosDetalleVenta mdv on mdv.RucE = @L_RucE and mdv.Cd_GR_Origen = miv.Cd_GR_Origen and mdv.Item_GR_Origen = miv.Item_Origen         
 LEFT JOIN inventariodet2 A ON a.ruce = @L_RucE and miv.cd_inv_destino = a.Cd_Inv and miv.Item_Destino = a.Item        
 LEFT JOIN Inventario2 B ON B.RUCE = @L_RucE AND A.CD_INV = B.CD_INV        
 LEFT JOIN TipoOperacion C ON B.CD_TO = C.Cd_TO        
WHERE             
 MIV.RUCE = @L_RucE             
 --AND ISNULL(miv.Cd_GR_Origen,'') <> ''         
 AND (ISNULL(miv.Cd_GR_Origen,'') <> '' AND C.IC_ES != 'A')        
 --AND CASE WHEN ISNULL(@L_CodigoConsulta,'') = '' THEN '1' ELSE Cd_Inv_Destino END <> ISNULL(@L_CodigoConsulta,'')      
 AND CASE WHEN ISNULL(@L_Param5,'') = '' THEN '1' ELSE Cd_Inv_Destino END <> ISNULL(@L_Param5,'')      
)              
              
SELECT               
 *              
FROM              
 (              
 SELECT               
  ROW_NUMBER() OVER (ORDER BY y.Codigo ASC) - 1 as Fila,            
  *              
 FROM              
  (              
  SELECT               
   DISTINCT              
   vt.Cd_Clt Auxiliar_INV,              
   vt.RucE,              
   vt.Cd_Vta Codigo,              
   vt.Cd_Area as 'CdArea',  
   NroSre NumSerie,              
   NroDoc NumDocumento,              
   vt.Cd_TD as CodigoTipoDocumento,              
   tid.NCorto NomCortoTD,              
   CONCAT(cli.RSocial,' ',cli.ApPat,' ',cli.ApMat,' ',cli.Nom) NombreCliente_CC_CD,              
   vt.FecMov as FechaMovimiento_INV,  
   vt.Obs  
  FROM               
   Venta vt WITH (NOLOCK)              
   LEFT JOIN TipDoc tid on vt.Cd_TD = tid.Cd_TD              
   LEFT JOIN VentaDet vd WITH (NOLOCK) on vd.RucE = @L_RucE and vd.Cd_Vta = vt.Cd_Vta  and vd.cd_vta is not null           
   INNER JOIN Producto2 p2 on p2.RucE = @L_RucE and p2.Cd_Prod = vd.Cd_Prod      
   INNER JOIN Cliente2 cli on  cli.RucE = @L_RucE and cli.Cd_Clt = vt.Cd_Clt
   LEFT JOIN               
   (              
	   SELECT              
		y.RucE,             
		y.Cd_Vta,             
		y.Item,             
		ISNULL(SUM(CantidadUsada),0) CantidadUsada              
	   FROM              
		(              
			SELECT              
			 RucE,             
			 Cd_Doc as Cd_Vta,             
			 Item,             
			 CantidadUsada              
			FROM              
			 @L_TABLA_MOVIMIENTO              
			WHERE              
			 RucE = @L_RucE AND            
			 ISNULL(Cd_Doc,'') <> ''              
		) y              
	   GROUP BY             
		y.RucE,             
		y.Cd_Vta,             
		y.Item              
   ) rs on rs.RucE = @L_RucE and rs.Cd_Vta = vt.Cd_Vta and rs.Item = vd.Nro_RegVdt  and vd.Cd_Prod is not null              
  WHERE              
   vt.RucE = @L_RucE              
   AND CASE WHEN @IB_Habilita_AreaxUsuario = 0 THEN 1 WHEN @IB_Habilita_AreaxUsuario = 1 AND CHARINDEX('[' + vt.Cd_Area + ']',@CodigosAreas)>0 THEN 1 ELSE 0 END = 1  
   AND VT.IB_Anulado = 0              
AND vt.Cd_TD <> '07'              
   AND CONVERT(DATE,vt.FecMov) between convert(date,@L_FecDesde) and Convert(date, @L_FecHasta) --and  vt.Cd_Clt = @L_CodigoConsulta              
   AND vt.Cd_Clt = (CASE WHEN ISNULL(@L_CodigoConsulta,'') = '' THEN vt.Cd_Clt ELSE @L_CodigoConsulta END)              
   AND ISNULL(vt.TipoNC,'') <> 'DS'              
   --AND ((Select COUNT(1) from VentaDet codsl WITH (NOLOCK) where codsl.RucE = vt.RucE and codsl.Cd_Vta = vt.Cd_Vta and ISNULL(codsl.Cd_Prod,'') <> '') > 0)              
   AND (ISNULL(vd.Cant,0) - ISNULL(rs.CantidadUsada,0)) > 0            
   AND vt.CD_MDA = CASE WHEN ISNULL(@L_Param4,'') != '' THEN @L_Param4 ELSE vt.CD_MDA END          
   AND CASE WHEN @L_Columna = 'Codigo' THEN Isnull(vt.Cd_Vta,'') ELSE '' END like CASE WHEN 'Codigo'=@L_Columna THEN '%'+@L_Dato+'%' ELSE '' END              
   AND CASE WHEN @L_Columna = 'NumSerie' THEN Isnull(vt.NroSre,'') ELSE '' END like CASE WHEN 'NumSerie'=@L_Columna THEN '%'+@L_Dato+'%' ELSE '' END              
   AND CASE WHEN @L_Columna = 'NumDocumento' THEN Isnull(vt.NroDoc,'') ELSE '' END like CASE WHEN 'NumDocumento'=@L_Columna THEN '%'+@L_Dato+'%' ELSE '' END              
   AND CASE WHEN @L_Columna = 'CodigoTipoDocumento' THEN Isnull(vt.Cd_TD,'') ELSE '' END like CASE WHEN 'CodigoTipoDocumento'=@L_Columna THEN '%'+@L_Dato+'%' ELSE '' END              
   AND CASE WHEN @L_Columna = 'NomCortoTD' THEN Isnull(tid.NCorto,'') ELSE '' END like CASE WHEN 'NCorto'=@L_Columna THEN '%'+@L_Dato+'%' ELSE '' END              
  ) y              
 ) x              
WHERE              
 RucE=@L_RucE              
 AND Codigo NOT IN (SELECT ISNULL(Cd_Vta,'') FROM CTE)            
    
OPTION (RECOMPILE)    
     
/************************** LEYENDA              
              
| USUARIO       | | FECHA      | | DESCRIPCIÓN                  
| Andrés Santos | | 08/09/2022 | | Creación del Query       
| Andrés Santos | | 29/10/2022 | | Se agrega Obs  
| David Jove    | | 16/02/2023 | | Se agregó el parámetro @P_USUARIO para filtrar las áreas asociadas a este y se agregó el campo 'CdArea'  
| Rafael Linares| | 02/05/2023 | | Se agrego una validacion sobre el cambio de AreasXUsuario, considerando una nueva configuracion que se agrego en inventario (C_IB_HABILITAR_FILTRO_DE_AREA_X_USUARIO_DOCUMENTOS_MOVIMIENTO_INVENTARIO)  
| David Napán   | | 01/03/2024 | | Se corrigieron algunos select mal implementados.
***************************/