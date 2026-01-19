USE [ERP_ECHA]
GO
/****** Object:  StoredProcedure [dbo].[Gfm_ConsultaDetDocAuxiliares_8]    Script Date: 14/01/2026 06:48:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Gfm_ConsultaDetDocAuxiliares_8]    
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
            
--DECLARE               
--@RucE nvarchar(11) = '11111111111',              
--@Codigo nvarchar(20) = '14',              
--@UsuActual nvarchar(10) = 'dnapan',              
--@Columna varchar(50),              
--@Dato varchar(50),              
--@TipMov varchar(100) = 'PreOrden',              
--@Param varchar(4000),              
--@CodigoConsulta varchar(4000),          
--@Param2 VARCHAR(4000),          
--@Param3 VARCHAR(4000),        
--@Param5 VARCHAR(4000)              
              
IF(@TipMov = 'OrdenTrabajo')              
    BEGIN              
        EXEC [activo_fijo].[USP_T_UNIDAD_PRODUCIBLE_X_T_ACTIVO_FIJO_CONSULTA] @RucE, @Codigo, @UsuActual, @Columna ,@Dato, @Param              
    END          
ELSE IF (@TipMov = 'ActivosFijos')              
    BEGIN              
        EXEC [activo_fijo].[USP_T_ACTIVO_FIJO_CONSULTA_DOCUMENTO_DETALLE] @RucE, @Codigo, @UsuActual, @Columna ,@Dato, @Param              
    END          
ELSE IF (@TipMov = 'GuiaEntrada')              
    BEGIN              
        IF (@Param = 'SoloFAC')              
            BEGIN              
                EXEC Com_ConsDetDocParaGuiaEntrada @RucE, @Codigo, @UsuActual, @Columna ,@Dato              
            END              
        ELSE IF (@Param = 'SoloOC')              
            BEGIN              
                EXEC Com_ConsDetOCParaGuiaEntrada @RucE, @Codigo, @UsuActual, @Columna ,@Dato              
            END              
        ELSE IF (@Param = 'SoloPL')              
            BEGIN              
                EXEC inventario.USP_T_PACKING_LIST_DETALLE_BUSCAR_PARA_GUIA @RucE,@Codigo,@Columna,@Dato              
            END              
        ELSE              
            BEGIN              
                EXEC dbo.Com_ConsDocGEDetPendientes @RucE, @Codigo, @UsuActual, @Columna ,@Dato, @Param              
            END              
    END              
ELSE IF (@TipMov = 'GuiaRemision')              
    BEGIN              
        IF (@Param = 'SoloPL')              
            BEGIN              
                EXEC inventario.USP_T_PACKING_LIST_DETALLE_BUSCAR_PARA_GUIA @RucE,@Codigo,@Columna,@Dato              
            END    
		ELSE IF (@Param2 = 'SolicitudReq2')
			BEGIN
				EXEC [inventario].[USP_T_SR_DETALLE_BUSCAR_PARA_GUIA] @RucE,@Codigo,@Columna,@Dato
			END
    END
ELSE IF (@TipMov = 'Inventario2')               
    BEGIN              
        EXEC inventario.USP_T_INVENTARIO_CONSULTAR_DETALLE_DOCUMENTOS_FUENTE_5 @RucE, @Codigo, @UsuActual, @Columna, @Dato, @TipMov, @Param, @CodigoConsulta, @Param2, @Param3, @Param5        
    END             
ELSE IF (@TipMov = 'Inventario2Plantilla')               
    BEGIN              
        EXEC DBO.USP_T_MOVIMIENTO_INVENTARIO_PLANTILLA_CONSULTAR_DOCUMENTOS_DETALLE @RucE, @Param2, @Codigo, @Columna, @Dato          
    END      
ELSE IF (@TipMov='PreOrden')      
 BEGIN      
  EXEC [venta].[USP_T_PREORDEN_DETALLE_BUSCAR_DOCUMENTO_1] @RucE,@Codigo,@UsuActual,@Columna,@Dato,@Param ,@Param2    
 END      
              
/************************** LEYENDA                
                
| USUARIO       | | FECHA      | | DESCRIPCIÓN                    
| Andrés Santos | | 20/07/2022 | | Creación del Query. Se agrega parametro @Param5       
| Andrés Santos | | 09/09/2022 | | Se agrega inventario.USP_T_INVENTARIO_CONSULTAR_DETALLE_DOCUMENTOS_FUENTE_4      
| David Jove    | | 24/11/2022 | | Se agrega el sector PreOrden ([venta].[USP_T_PREORDEN_DETALLE_BUSCAR_DOCUMENTO])     
| Andrés Santos | | 26/09/2023 | | (89375) Se versionó el sp inventario.USP_T_INVENTARIO_CONSULTAR_DETALLE_DOCUMENTOS_FUENTE_5     
| David Napán   | | 04/11/2024 | |  Se versionó el sp [venta].[USP_T_PREORDEN_DETALLE_BUSCAR_DOCUMENTO_1]     
| Jesus Chavez  | | 12/08/2024 | | (114516)Se agrega el sector GuiaRemision - SolicitudReq2 ([inventario].[USP_T_SR_DETALLE_BUSCAR_PARA_GUIA])               
***************************/  
  