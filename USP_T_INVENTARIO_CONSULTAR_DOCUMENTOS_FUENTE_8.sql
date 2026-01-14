USE [ERP_ECHA]
GO
/****** Object:  StoredProcedure [inventario].[USP_T_INVENTARIO_CONSULTAR_DOCUMENTOS_FUENTE_8]    Script Date: 14/01/2026 06:57:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [inventario].[USP_T_INVENTARIO_CONSULTAR_DOCUMENTOS_FUENTE_8]  
(            
@RucE NVARCHAR(11),    
@Ejer VARCHAR(4),    
@UsuActual NVARCHAR(10),    
@FecDesde SMALLDATETIME,    
@FecHasta SMALLDATETIME,    
@Columna VARCHAR(50),    
@Dato VARCHAR(50),    
@CantDesde INT,    
@CantHasta INT,    
@Param VARCHAR(4000),    
@Param2 VARCHAR(4000),    
@CodigoConsulta VARCHAR(4000),    
@Param3 VARCHAR(4000),    
@Param4 VARCHAR(4000),    
@Param5 VARCHAR(4000)    
)          
            
AS            
            
IF(@Param2 = 'Compra2')              
BEGIN          
 EXEC DBO.USP_INVENTARIO2_COMPRA2_CABECERA_CONSULTAR_PENDIENTES_2 @RucE, @FecDesde, @FecHasta, @Columna, @Dato,  @Param, @CodigoConsulta, @Param4, @Param5, @UsuActual    
END          
ELSE IF(@Param2 = 'OrdCompra2')              
BEGIN          
 EXEC DBO.USP_INVENTARIO2_ORDENCOMPRA2_CABECERA_CONSULTAR_PENDIENTES_2 @RucE, @FecDesde, @FecHasta, @Columna, @Dato,  @Param, @CodigoConsulta, @Param4, @Param5, @UsuActual    
END          
ELSE IF(@Param2 = 'SolicitudReq2')             
BEGIN          
 EXEC DBO.USP_INVENTARIO2_SOLICITUDREQUERIMIENTO2_CABECERA_CONSULTAR_PENDIENTES @RucE, @FecDesde, @FecHasta, @Columna, @Dato,  @Param, @CodigoConsulta, @Param4, @Param5      
END          
ELSE IF(@Param2 = 'OrdenPedido')              
BEGIN          
 EXEC DBO.USP_INVENTARIO2_ORDENPEDIDO_CABECERA_CONSULTAR_PENDIENTES_2 @RucE, @FecDesde, @FecHasta, @Columna, @Dato,  @Param, @CodigoConsulta, @Param4, @Param5, @UsuActual    
END          
ELSE IF(@Param2 = 'Venta')             
BEGIN      
 EXEC DBO.USP_INVENTARIO2_VENTA_CABECERA_CONSULTAR_PENDIENTES_3 @RucE, @FecDesde, @FecHasta, @Columna, @Dato,  @Param, @CodigoConsulta, @Param4, @Param5, @UsuActual    
 --EXEC DBO.USP_INVENTARIO2_VENTA_CABECERA_CONSULTAR_PENDIENTES_2 @RucE, @FecDesde, @FecHasta, @Columna, @Dato,  @Param, @CodigoConsulta, @Param4, @Param5, @UsuActual    
END          
ELSE IF(@Param2 = 'GRSalida')             
BEGIN          
 EXEC DBO.USP_INVENTARIO2_GUIAREMISION_CABECERA_CONSULTAR_PENDIENTES_2 @RucE, @FecDesde, @FecHasta, @Columna, @Dato,  @Param, @CodigoConsulta, @Param4, @Param5, @UsuActual    
END          
ELSE IF(@Param2 = 'Importacion')             
BEGIN            
 EXEC DBO.USP_INVENTARIO2_IMPORTACION_CABECERA_CONSULTAR_PENDIENTES_2 @RucE, @FecDesde, @FecHasta, @Columna, @Dato,  @Param, @CodigoConsulta, @Param4, @Param5, @UsuActual    
END          
ELSE IF(@Param2 = 'OrdFabricacion')             
BEGIN            
 EXEC DBO.USP_INVENTARIO2_ORDENFABRICACION_CABECERA_CONSULTAR_PENDIENTES @RucE, @FecDesde, @FecHasta, @Columna, @Dato,  @Param, @CodigoConsulta, @Param4, @Param5             
END          
ELSE IF(@Param2 = 'GuiaEntrada')            
BEGIN          
 EXEC DBO.USP_INVENTARIO2_GUIAENTRADA_CABECERA_CONSULTAR_PENDIENTES @RucE, @FecDesde, @FecHasta, @Columna, @Dato,  @Param, @CodigoConsulta, @Param4, @Param5                
END          
ELSE IF(@Param2 = 'VentaDevolucion')            
BEGIN              
 EXEC DBO.USP_INVENTARIO2_VENTA_DEVOLUCION_CABECERA_CONSULTAR_PENDIENTES @RucE, @FecDesde, @FecHasta, @Columna, @Dato, @CodigoConsulta, @Param4, @Param5               
END          
ELSE IF(@Param2 = 'CompraDevolucion')            
BEGIN            
 EXEC DBO.USP_INVENTARIO2_COMPRA2_DEVOLUCION_CABECERA_CONSULTAR_PENDIENTES @RucE, @FecDesde, @FecHasta, @Columna, @Dato, @CodigoConsulta, @Param4, @Param5                
END  
ELSE IF(@Param2 = 'NotaCreditoVenta')            
BEGIN            
 EXEC DBO.USP_INVENTARIO2_NOTA_CREDITO_VENTA_CABECERA_CONSULTAR_PENDIENTES @RucE, @FecDesde, @FecHasta, @Columna, @Dato, @CodigoConsulta, @Param4, @Param5                
END   
            
/************************** LEYENDA            
            
| USUARIO       | | FECHA      | | DESCRIPCIÓN                
| Andrés Santos | | 26/09/2023 | | (89375) Creación del Query. Se agrega @Param2 = NotaCreditoVenta  
    
***************************/