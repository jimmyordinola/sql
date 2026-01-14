USE [ERP_ECHA]
GO
/****** Object:  StoredProcedure [inventario].[USP_T_INVENTARIO_CONSULTAR_DETALLE_DOCUMENTOS_FUENTE_5]    Script Date: 14/01/2026 06:58:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [inventario].[USP_T_INVENTARIO_CONSULTAR_DETALLE_DOCUMENTOS_FUENTE_5]    
(          
@RucE NVARCHAR(11),    
@Codigo NVARCHAR(20),    
@UsuActual NVARCHAR(10),    
@Columna VARCHAR(50),    
@Dato VARCHAR(50),    
@TipMov VARCHAR(100),    
@Param VARCHAR(4000),    
@CodigoConsulta VARCHAR(4000),    
@Param2 VARCHAR(4000),    
@Param3 VARCHAR(4000),    
@Param5 VARCHAR(4000)    
)          
            
AS            
            
IF (@Param2 = 'Compra2')            
BEGIN            
 EXEC DBO.USP_INVENTARIO2_COMPRA2_DETALLE_CONSULTAR_PENDIENTES @RucE, @Codigo, @UsuActual, @Columna ,@Dato, @Param, @Param5              
END            
            
IF (@Param2 = 'OrdCompra2')            
BEGIN            
 EXEC DBO.USP_INVENTARIO2_ORDENCOMPRA2_DETALLE_CONSULTAR_PENDIENTES @RucE, @Codigo, @UsuActual, @Columna ,@Dato, @Param, @Param5             
END            
            
IF (@Param2 = 'SolicitudReq2')            
BEGIN            
 EXEC DBO.USP_INVENTARIO2_SOLICITUDREQUERIMIENTO2_DETALLE_CONSULTAR_PENDIENTES @RucE, @Codigo, @UsuActual, @Columna ,@Dato, @Param, @Param5             
END            
            
IF (@Param2 = 'OrdenPedido')            
BEGIN            
 EXEC DBO.USP_INVENTARIO2_ORDENPEDIDO_DETALLE_CONSULTAR_PENDIENTES @RucE, @Codigo, @UsuActual, @Columna ,@Dato, @Param, @Param5            
END            
            
IF (@Param2 = 'Venta')            
BEGIN            
 EXEC DBO.USP_INVENTARIO2_VENTA_DETALLE_CONSULTAR_PENDIENTES @RucE, @Codigo, @UsuActual, @Columna ,@Dato, @Param, @Param5            
END            
            
IF (@Param2 = 'GRSalida')            
BEGIN            
 EXEC DBO.USP_INVENTARIO2_GUIAREMISION_DETALLE_CONSULTAR_PENDIENTES @RucE, @Codigo, @UsuActual, @Columna ,@Dato, @Param, @Param5            
END            
            
IF (@Param2 = 'Importacion')            
BEGIN            
 EXEC DBO.USP_INVENTARIO2_IMPORTACION_DETALLE_CONSULTAR_PENDIENTES @RucE, @Codigo, @UsuActual, @Columna ,@Dato, @Param, @Param5            
END            
            
IF (@Param2 = 'GuiaEntrada')            
BEGIN            
 EXEC DBO.USP_INVENTARIO2_GUIAENTRADA_DETALLE_CONSULTAR_PENDIENTES @RucE, @Codigo, @UsuActual, @Columna ,@Dato, @Param, @Param5            
END            
            
IF(@Param2 = 'VentaDevolucion')            
BEGIN            
 EXEC DBO.USP_INVENTARIO2_VENTA_DEVOLUCION_DETALLE_CONSULTAR_PENDIENTES @RucE, @Codigo, @UsuActual, @Columna ,@Dato, @Param, @Param5             
END            
            
IF(@Param2 = 'CompraDevolucion')            
BEGIN            
 EXEC DBO.USP_INVENTARIO2_COMPRA2_DEVOLUCION_DETALLE_CONSULTAR_PENDIENTES @RucE, @Codigo, @UsuActual, @Columna ,@Dato, @Param, @Param5            
END  
  
IF(@Param2 = 'NotaCreditoVenta')            
BEGIN            
 EXEC DBO.USP_INVENTARIO2_NOTA_CREDITO_VENTA_DETALLE_CONSULTAR_PENDIENTES @RucE, @Codigo, @UsuActual, @Columna ,@Dato, @Param, @Param5                
END 
IF(@Param2 = 'NotaCreditoNoDomicilio')            
BEGIN            
 EXEC DBO.USP_INVENTARIO2_NOTA_CREDITO_NO_DOMICILIO_DETALLE_CONSULTAR_PENDIENTES @RucE, @Codigo, @UsuActual, @Columna ,@Dato, @Param, @Param5                
END   
            
/************************** LEYENDA          
          
| USUARIO       | | FECHA      | | DESCRIPCIÓN              
| Andrés Santos | | 26/09/2023 | | (89375) Creación del Query. Se agrega @Param2 = NotaCreditoVenta
| David Napán   | | 23/11/2023 | | (90656) se agregó NotaCreditoNoDomicilio.   
          
***************************/