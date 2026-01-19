USE [ERP_ECHA]
GO
/****** Object:  StoredProcedure [dbo].[Gfm_ConsultarDocAuxiliares_12]    Script Date: 14/01/2026 06:47:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Gfm_ConsultarDocAuxiliares_12]    
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
@TipMov VARCHAR(100),            
@Param VARCHAR(4000),            
@Param2 VARCHAR(4000),            
@CodigoConsulta VARCHAR(4000),            
@Param3 VARCHAR(4000),        
@Param4 VARCHAR(4000),        
@Param5 VARCHAR(4000)        
)              
              
AS                
              
--Declare                
--@RucE nvarchar(11) = '11111111111',                
--@Ejer varchar(4) = '2024',                
--@UsuActual nvarchar(10) = 'dnapan',                
--@FecDesde SmallDateTime = '01/10/2024',                
--@FecHasta SmallDateTime = '30/11/2024',                
--@Columna varchar(50) = '',                
--@Dato varchar(50) = '',                
--@CantDesde int = 0,                
--@CantHasta int = 100,                
--@TipMov varchar(100) = 'GuiaEntrada',                
--@Param varchar(4000) = 'SoloPL',                
--@Param2 varchar(4000) = 'E',                
--@CodigoConsulta varchar(4000) = null,                
--@Param3 varchar(4000) = null                
                
/*------------------------------------------------------------------------------------------------------------------------*/                
/*--------------------------------------------------------- REGLAS -------------------------------------------------------*/                
/*------------------------------------------------------------------------------------------------------------------------*/                
/*-------------------|1|- _INV : SE UTILIZA PARA OCULTAR EL CAMPO QUE SE MUESTRA EN LA GRIDVIEW -----------------------*/                
/*-------------------|2|- _CC :  SE UTILIZA PARA CENTRAR CABEZERA EN LA GRIDVIEW --------------------------------------*/                
/*-------------------|3|- _CD :  SE UTILIZA PARA CENTRAR DETALLE EN LA GRIDVIEW ---------------------------------------*/                
/*-------------------|4|- _N :  SE UTILIZA PARA PARA NUMEROS DECIMALES, SE ESPECIFICA --------------------------------*/                
/*------------------------------ CUANTOS DECIMALES SE QUIERE A LA DERECHA DEL N, --------------------------------------*/                
/*------------------------------ POR DEFECTO ES 2. --------------------------------------------------------------------*/                
/*-------------------|5|- DECLARACION DE ALIAS : DEBE SER CON MAYUSCULA AL COMENZAR UNA PALABRA --------------------------*/                 
/*-----------------------------------------------EJEMPLO: CodigoProveedor ------------------------------------------------*/                
/*------------------------------------------------------------------------------------------------------------------------*/                
                
-- NOTA: Para utilizar este query, tienes que agregar el tipo de movimiento en una sentencia 'IF';                 
--       además, se debe regresar la cantidad total de registros en un parametro en OUTPUT.                
--       Por otro lado, la consulta debe traer cada columna con el nombre que aparece en la grilla, por defecto todo estará en 'Visible=False',                 
--   pero si el proceso encuentra el nombre de la columna de tu query en el control de la grilla, entonces cambiará a 'Visible=True'                
--   ES OBLIGATORIO DEVOLVER UN CÓDIGO IDENTIFICADOR  CON EL ALIAS 'Codigo'                
                
IF (@TipMov = 'OrdenTrabajo')                
    BEGIN                
        EXEC [activo_fijo].[USP_T_ACTIVO_FIJO_CONSULTA_DOCUMENTO] @RucE, @FecDesde, @FecHasta,@CantDesde, @CantHasta, @Columna, @Dato,  'ActivoProducible', @CodigoConsulta                
    END            
ELSE IF (@TipMov = 'ActivosFijos')          
    BEGIN                
        EXEC [activo_fijo].[USP_T_ACTIVO_FIJO_CONSULTA_DOCUMENTO] @RucE, @FecDesde, @FecHasta,@CantDesde, @CantHasta, @Columna, @Dato,  @Param, @CodigoConsulta                
    END             
ELSE IF(@TipMov = 'GuiaEntrada')                
    BEGIN              
        IF (@Param = 'SoloFAC')                 
            BEGIN                
                EXEC dbo.Com_ConsDocParaGuiaEntrada_2 @RucE,  @FecDesde, @FecHasta,@Columna,@Dato, @CodigoConsulta                
            END                
        ELSE IF (@Param = 'SoloOC')                 
            BEGIN                
                EXEC dbo.Com_ConsOCParaGuiaEntrada_3 @RucE,  @FecDesde, @FecHasta,@Columna,@Dato, @CodigoConsulta                
    END                
        ELSE IF (@Param = 'SoloPL')                 
            BEGIN                
                EXEC inventario.USP_T_PACKING_LIST_CABECERA_BUSCAR_PARA_GUIA @RucE,@FecDesde,@FecHasta,@Columna,@Dato,@CodigoConsulta,'E'                
            END                
        ELSE                 
            BEGIN                  
                EXEC dbo.Com_ConsDocGEPendientes_2 @RucE, @FecDesde, @FecHasta, @Columna, @Dato,  @Param, @CodigoConsulta                
            END                
    END            
ELSE IF(@TipMov = 'GuiaRemision')                
    BEGIN              
        IF (@Param = 'SoloPL')                 
            BEGIN                
                EXEC inventario.USP_T_PACKING_LIST_CABECERA_BUSCAR_PARA_GUIA @RucE,@FecDesde,@FecHasta,@Columna,@Dato,@CodigoConsulta,'S'                
            END
		ELSE IF (@Param2 = 'SolicitudReq2')
			BEGIN
				EXEC [inventario].[USP_T_SR_CABECERA_BUSCAR_PARA_GUIA] @RucE,@FecDesde,@FecHasta,@Columna,@Dato,@CodigoConsulta,@UsuActual
			END
    END 
ELSE IF (@TipMov = 'Inventario2')                 
    BEGIN                
        EXEC inventario.USP_T_INVENTARIO_CONSULTAR_DOCUMENTOS_FUENTE_8 @RucE, @Ejer, @UsuActual, @FecDesde, @FecHasta, @Columna, @Dato, @CantDesde, @CantHasta, @Param, @Param2, @CodigoConsulta, @Param3, @Param4, @Param5                
    END              
ELSE IF (@TipMov = 'Venta')                 
    BEGIN                
        EXEC dbo.Cons_Venta_Doc @RucE, @Ejer, @UsuActual, @FecDesde, @FecHasta, @Columna, @Dato, @Param, @Param2, @CodigoConsulta, @Param3                
    END                
ELSE IF (@TipMov = 'OrdenFabricacion')            
    BEGIN                
        EXEC dbo.Cons_OrdFabricacion_Pendientes @RucE, @Ejer, @FecDesde, @FecHasta, @Columna, @Dato                
    END            
ELSE IF (@TipMov = 'Inventario2Plantilla')               
 BEGIN            
  EXEC dbo.USP_T_MOVIMIENTO_INVENTARIO_PLANTILLA_CONSULTAR_DOCUMENTOS_CABECERA @RucE, @FecDesde, @FecHasta, @Columna, @Dato, @Param2            
 END            
ELSE IF (@TipMov='PreOrden')      
 BEGIN      
  EXEC [venta].[USP_T_PREORDEN_CABECERA_BUSCAR_DOCUMENTO_1] @RucE,@FecDesde,@FecHasta,@Columna,@Dato,@Param      
 END      
      
/************************** LEYENDA                
                
| USUARIO        | | FECHA      | | DESCRIPCIÓN                    
| Andrés Santos  | | 20/07/2022 | | Creación del Query. Se agrega parametro @Param5      
| Andrés Santos  | | 08/09/2022 | | Se agrega inventario.USP_T_INVENTARIO_CONSULTAR_DOCUMENTOS_FUENTE_5      
| David Jove     | | 24/11/2022 | | Se agrega el sector PreOrden ([venta].[USP_T_PREORDEN_DETALLE_BUSCAR_DOCUMENTO])      
| David Jove     | | 16/02/2023 | | Se versionó el sp USP_T_INVENTARIO_CONSULTAR_DOCUMENTOS_FUENTE_6      
| Rafael Linares | | 16/02/2023 | | Se versionó el sp USP_T_INVENTARIO_CONSULTAR_DOCUMENTOS_FUENTE_7      
| Andrés Santos  | | 26/09/2023 | | (89375) Se versionó el sp inventario.USP_T_INVENTARIO_CONSULTAR_DOCUMENTOS_FUENTE_8   
| David Napán    | | 04/11/2024 | | Se versionó el sp [venta].[USP_T_PREORDEN_CABECERA_BUSCAR_DOCUMENTO_1] 
| Jesus Chavez   | | 12/08/2024 | | (114516)Se agrega el sector GuiaRemision - SolicitudReq2 ([inventario].[USP_T_SR_CABECERA_BUSCAR_PARA_GUIA])      
                
***************************/