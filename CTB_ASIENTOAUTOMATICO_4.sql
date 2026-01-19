USE [ERP_ECHA]
GO
/****** Object:  StoredProcedure [contabilidad].[CTB_ASIENTOAUTOMATICO_4]    Script Date: 16/01/2026 12:10:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [contabilidad].[CTB_ASIENTOAUTOMATICO_4]
(                      
@RucE NVARCHAR(11),                        
@Ejer NVARCHAR(4),                        
@RegCtb NVARCHAR(15),                        
@Cd_MIS CHAR(3),                        
@Cod VARCHAR(MAX),                        
@Msj VARCHAR(4000) OUTPUT,                        
@CambioMda  NUMERIC(6,3),                        
/*PARAMETROS DE AYUDA*/                        
@ParametroAux1 VARCHAR(MAX) = null,                        
@ParametroAux2 VARCHAR(MAX) = null,                        
@ParametroAux3 VARCHAR(MAX) = null                        
)      
    
AS          
  
--DECLARE          
--@RucE   NVARCHAR(11)= '20102351038',          
--@Ejer   NVARCHAR(4) = '2025',          
--@RegCtb NVARCHAR(15) = 'INS6_LD04-28662',          
--@Cd_MIS CHAR(3) = '019',          
--@Cod VARCHAR(MAX) = 'INV000295789',          
--@Msj VARCHAR(4000) = '',          
--@CambioMda  NUMERIC(6,3) = 0,          
--/*PARAMETROS DE AYUDA*/          
--@ParametroAux1 VARCHAR(MAX)=NULL,          
--@ParametroAux2 VARCHAR(MAX)=NULL,          
--@ParametroAux3 VARCHAR(MAX)=NULL       
        
DECLARE                                       
@RucE_P  NVARCHAR(11) = @RucE,                                      
@Ejer_P  NVARCHAR(4) = @Ejer,                                      
@RegCtb_P NVARCHAR(15) = @RegCtb,                                      
@Cd_MIS_P CHAR(3) = @Cd_MIS,                                      
@Cod_P  VARCHAR(MAX) = @Cod,                                      
@CambioMda_P  NUMERIC(6,3) = @CambioMda,                        
                        
/*PARAMETROS DE AYUDA*/                                      
@ParametroAux1_P VARCHAR(MAX) = @ParametroAux1,                                      
@ParametroAux2_P VARCHAR(MAX) = @ParametroAux2,                                      
@ParametroAux3_P VARCHAR(MAX) = @ParametroAux3,                                
@ParametroAux4_P VARCHAR(MAX)                               
                          
          
/*----------------------------------------------------------------------------------*/                                      
/*----------------------------------------------------------------------------------*/                                      
DECLARE @L_HABILITAR_MODO_PRUEBAS BIT = 0   -- PONER EN 0 CUANDO EL QUERY ESTA LISTO                                      
-- ESTO VALIDA LA EXISTENCIA DEL TEMPORAL                                      
/*----------------------------------------------------------------------------------*/  
--drop table #tmp_TVoucher  
--drop table #T_NO_DOMICILIADO_VOUCHER_TEMP  
--drop table #T_MOVIMIENTO_RELACION  
--drop table #tmp_TVoucher_Dist  
--drop table #tmp_DISTRIBUCION_MOV_CC_X_GASTO  
/*----------------------------------------------------------------------------------*/                                      
                                      
/*CREAMOS TABLAS TEMPORALES PARA INSERCIÓN FINAL*/                                      
                                      
if(@L_HABILITAR_MODO_PRUEBAS = 1)                                      
 if exists(select 1 from tempdb.sys.objects where name like N'#tmp_TVoucher%')          
  drop table #tmp_TVoucher  
                                       
CREATE TABLE #tmp_TVoucher                                      
(                                      
RucE        NVARCHAR(11) COLLATE DATABASE_DEFAULT NOT NULL,                                      
Cd_Vou      INT NOT NULL,               
C_CD_REF_DESTINO     INT NULL,                                      
Ejer        NVARCHAR(4) COLLATE DATABASE_DEFAULT NOT NULL,                                      
Prdo        NVARCHAR(2) NOT NULL,                                      
RegCtb      NVARCHAR(15) NOT NULL,                                      
Cd_Fte      VARCHAR(2) COLLATE DATABASE_DEFAULT NOT NULL,                                     
FecMov      SMALLDATETIME NOT NULL,                                      
FecCbr      SMALLDATETIME NULL,                                      
NroCta      VARCHAR(50) COLLATE DATABASE_DEFAULT NOT NULL,                                      
Cd_Aux      NVARCHAR(7) NULL,                                      
Cd_TD       NVARCHAR(2) NULL,                                      
NroSre      VARCHAR(20) COLLATE DATABASE_DEFAULT NULL,                                      
NroDoc      VARCHAR(20) COLLATE DATABASE_DEFAULT NULL,                       
FecED       SMALLDATETIME NULL,                                      
FecVD       SMALLDATETIME NULL,                                      
Glosa       VARCHAR(500) COLLATE DATABASE_DEFAULT NULL,                                      
MtoOr       NUMERIC(20,2) NULL,                                      
MtoD        NUMERIC(20,2) NOT NULL,                                      
MtoH        NUMERIC(20,2) NOT NULL,                                      
MtoD_ME     NUMERIC(20,2) NULL,                                      
MtoH_ME     NUMERIC(20,2) NULL,                                      
Cd_MdOr     NVARCHAR(2) NOT NULL,                                      
Cd_MdRg     NVARCHAR(2) NOT NULL,                                      
CamMda      NUMERIC(10,3) NULL,                                      
Cd_CC       NVARCHAR(8) NOT NULL,                                      
Cd_SC       NVARCHAR(8) NOT NULL,                                      
Cd_SS       NVARCHAR(8) NOT NULL,                                      
Cd_Area     NVARCHAR(6) NOT NULL,                                      
Cd_MR       NVARCHAR(2) NOT NULL,                                      
Cd_TG       NVARCHAR(2) NOT NULL,                                      
IC_CtrMd    VARCHAR(1) COLLATE DATABASE_DEFAULT NULL,                                      
IC_TipAfec  VARCHAR(1) COLLATE DATABASE_DEFAULT NULL,                               
TipOper     VARCHAR(4) COLLATE DATABASE_DEFAULT NULL,                                      
NroChke     VARCHAR(30) COLLATE DATABASE_DEFAULT NULL,                                      
Grdo        VARCHAR(100) COLLATE DATABASE_DEFAULT NULL,                                     
IB_Cndo     BIT NULL,                                      
IB_Conc     BIT NULL,                                      
IB_EsProv   BIT NULL,                                       
FecReg      DATETIME NOT NULL,                                      
FecMdf      DATETIME NULL,                                      
UsuCrea     NVARCHAR(10) NOT NULL,                                      
UsuModf     NVARCHAR(10) NULL,                                      
IB_Anulado  BIT NOT NULL,                                      
DR_CdVou    INT NULL,                                      
DR_FecED    SMALLDATETIME NULL,                                      
DR_CdTD     NVARCHAR(2) NULL,                                      
DR_NSre     VARCHAR(20) COLLATE DATABASE_DEFAULT NULL,                                      
DR_NDoc     VARCHAR(20) COLLATE DATABASE_DEFAULT NULL,                                      
IC_Gen      VARCHAR(1) COLLATE DATABASE_DEFAULT NULL,                                      
FecConc     SMALLDATETIME NULL,                                      
IB_EsDes    BIT NULL,                                      
DR_NCND     VARCHAR(15) COLLATE DATABASE_DEFAULT NULL,                                      
DR_NroDet   VARCHAR(15) COLLATE DATABASE_DEFAULT NULL,                                      
DR_FecDet   SMALLDATETIME NULL,                                      
Cd_Clt      CHAR(10) NULL,                                      
Cd_Prv      CHAR(7) NULL,                                      
IB_Imdo     BIT NULL,                                      
Cd_TMP      CHAR(3) NULL,                                      
CA01        VARCHAR(100) COLLATE DATABASE_DEFAULT NULL,                                      
CA02        VARCHAR(100) COLLATE DATABASE_DEFAULT NULL,                                      
CA03        VARCHAR(8000) COLLATE DATABASE_DEFAULT NULL,     
CA04        VARCHAR(8000) COLLATE DATABASE_DEFAULT NULL,                                      
CA05        VARCHAR(8000) COLLATE DATABASE_DEFAULT NULL,                                      
CA06        VARCHAR(8000) COLLATE DATABASE_DEFAULT NULL,                         
CA07        VARCHAR(8000) COLLATE DATABASE_DEFAULT NULL,                                      
CA08        VARCHAR(8000) COLLATE DATABASE_DEFAULT NULL,                                      
CA09        VARCHAR(8000) COLLATE DATABASE_DEFAULT NULL,                                      
CA10        VARCHAR(8000) COLLATE DATABASE_DEFAULT NULL,                                      
CA11        VARCHAR(8000) COLLATE DATABASE_DEFAULT NULL,                     
CA12        VARCHAR(8000) COLLATE DATABASE_DEFAULT NULL,                                      
CA13        VARCHAR(8000) COLLATE DATABASE_DEFAULT NULL,                                      
CA14        VARCHAR(8000) COLLATE DATABASE_DEFAULT NULL,                                      
CA15        VARCHAR(8000) COLLATE DATABASE_DEFAULT NULL,                                      
CodT        CHAR(4) NULL,                                      
Cd_Trab     CHAR(8) NULL,                                      
Cd_FPC      NVARCHAR(2) NULL,                                      
Cd_FCP      NVARCHAR(2) NULL,                                      
Id_TMP      INT NULL,                                      
FecDif      DATETIME NULL,                            
C_CORRELATIVO  CHAR(10) NULL,                                      
C_REGCTB_REF  NVARCHAR(15) NULL,                                      
C_CANTIDAD_TITULO   INT NULL,                                      
C_CODIGO_PATRIMONIO VARCHAR(6) COLLATE DATABASE_DEFAULT NULL,                                      
C_CODIGO_TITULO     CHAR(2) NULL,                                      
C_CODIGO_DETALLE_PATRIMONIO_SBS  CHAR(6) NULL,                                      
C_ID_CONCEPTO_FEC   INT    ,                                  
C_IB_DEVOLUCION_IGV BIT  ,                                
C_IB_AGRUPADO  BIT,                        
C_CD_VOU_TEMP INT NULL,          
C_IGV_TASA DECIMAL(6,2) NULL          
)                                      
                                      
if(@L_HABILITAR_MODO_PRUEBAS = 1)                                      
 if exists(select 1 from tempdb.sys.objects where name like N'#T_NO_DOMICILIADO_VOUCHER_TEMP%')                                       
  drop table #T_NO_DOMICILIADO_VOUCHER_TEMP          
                                      
CREATE TABLE #T_NO_DOMICILIADO_VOUCHER_TEMP                                      
(                                      
C_RUC_EMPRESA    CHAR(11) NULL,                                      
C_CODIGO_VOUCHER   INT NULL,                                      
C_CD_BENEFICIARIO   CHAR(7) NULL,                                      
C_NRO_TV     CHAR(2) NULL,                                      
C_RENTA_BRUTA    DECIMAL(20,2) NULL,                                      
C_DEDUCCION_COSTO_CAPITAL DECIMAL(20,2) NULL,                                      
C_RENTA_NETA    DECIMAL(20,2) NULL,                                      
C_TASA_RET     DECIMAL(16,2) NULL,                                      
C_IMPUESTO_RET    DECIMAL(20,2) NULL,                                      
C_IGV_RET     DECIMAL(20,2) NULL,                                      
C_NRO_CEDT     CHAR(2) NULL,                                      
C_NRO_EOND     CHAR(2) NULL,                                      
C_NRO_TR     CHAR(2) NULL,                                      
C_NRO_MS     CHAR(2) NULL,                                      
C_APLICACION_ART   VARCHAR(100) COLLATE DATABASE_DEFAULT NULL                                      
)                                      
                                      
if(@L_HABILITAR_MODO_PRUEBAS = 1)                                      
 if exists(select 1 from tempdb.sys.objects where name like N'#T_MOVIMIENTO_RELACION%')            
  drop table #T_MOVIMIENTO_RELACION          
                                      
CREATE TABLE #T_MOVIMIENTO_RELACION                                      
(                                      
C_RUCE   NVARCHAR(11) NOT NULL,                                      
C_CD_VOU  INT   NOT NULL,                                      
C_CD_VOU_REF INT                                          
)                                      
                                      
if(@L_HABILITAR_MODO_PRUEBAS = 1)              
 if exists(select 1 from tempdb.sys.objects where name like N'#tmp_TVoucher_Dist%')                                       
  drop table #tmp_TVoucher_Dist          
                                      
CREATE TABLE #tmp_TVoucher_Dist                                   
(                                      
RucE NVARCHAR(11) COLLATE DATABASE_DEFAULT NOT NULL,                               
Cd_Vou INT NOT NULL,                                      
Ejer NVARCHAR(4) COLLATE DATABASE_DEFAULT NOT NULL,                                      
Prdo NVARCHAR(2) COLLATE DATABASE_DEFAULT NOT NULL,               
RegCtb NVARCHAR(15) COLLATE DATABASE_DEFAULT NOT NULL,                                      
Cd_Fte VARCHAR(2) COLLATE DATABASE_DEFAULT NOT NULL,                     
FecMov SMALLDATETIME NOT NULL,                                      
FecCbr SMALLDATETIME NULL,                                      
NroCta VARCHAR(50) COLLATE DATABASE_DEFAULT NOT NULL,                                      
Cd_TD NVARCHAR(2) COLLATE DATABASE_DEFAULT NULL,            
NroSre VARCHAR(20) COLLATE DATABASE_DEFAULT NULL,                                      
NroDoc VARCHAR(20) COLLATE DATABASE_DEFAULT NULL,                                      
MtoD NUMERIC(20,2) NOT NULL,                                      
MtoH NUMERIC(20,2) NOT NULL,                                      
MtoD_ME NUMERIC(20,2) NULL,                                      
MtoH_ME NUMERIC(20,2) NULL,                                      
Cd_MdOr NVARCHAR(2) NOT NULL,                                      
Cd_MdRg NVARCHAR(2) NOT NULL,                              
CamMda NUMERIC(10,3) NULL,                                      
Cd_CC NVARCHAR(8) COLLATE DATABASE_DEFAULT NOT NULL,                                      
Cd_SC NVARCHAR(8) COLLATE DATABASE_DEFAULT NOT NULL,                                      
Cd_SS NVARCHAR(8) COLLATE DATABASE_DEFAULT NOT NULL,                                      
C_PORC DECIMAL(18,7) NULL                                      
)                                      
                                      
if(@L_HABILITAR_MODO_PRUEBAS = 1)                                      
 if exists(select 1 from tempdb.sys.objects where name like N'#tmp_DISTRIBUCION_MOV_CC_X_GASTO%')                                       
  drop table #tmp_DISTRIBUCION_MOV_CC_X_GASTO          
                                      
CREATE TABLE #tmp_DISTRIBUCION_MOV_CC_X_GASTO                                      
(                                      
C_RUC_E  NVARCHAR(11)                                      
,C_CD_VOU INT                                      
,C_NRO_CTA VARCHAR(50)                                      
,C_PORC  DECIMAL(18,7)                                      
,C_MTOD  DECIMAL(20,2)                                      
,C_MTOH  DECIMAL(20,2)                                   
,C_MTOD_ME DECIMAL(20,2)                                      
,C_MTOH_ME DECIMAL(20,2)                                      
,C_CD_CC NVARCHAR(8)                                      
,C_CD_SC NVARCHAR(8)                                      
,C_CD_SS NVARCHAR(8)                                      
)                                      
/*--------------------------------------------------------------------------*/                                      
                                      
DECLARE                                      
@Cd_TM   CHAR(2)   ,                                       
@Val_Cal  NUMERIC(20,2),                                  
@Val_Cal_ME  NUMERIC(20,2),          
@IC_DetCab  CHAR(1)   ,                                       
@NomCol   VARCHAR(8000) ,                                       
@NomCol_ME   VARCHAR(8000) ,           
@Glosa_Fmla  VARCHAR(8000) ,                                       
@NomTabla  VARCHAR(8000) ,                                       
@NomTablaDet VARCHAR(8000) ,                                       
@colCodTab  VARCHAR(8000) ,                                       
@colCodTabDet VARCHAR(8000) ,                                      
@DH_R   CHAR(1),                                      
@C_CODIGO_VOUCHER_DIST_AJUST INT = -1,            
@L_IB_PERMITIR_GENERAR_ASIENTO_MONTO_CERO BIT = (SELECT TOP 1 ISNULL(C_IB_PERMITIR_GENERAR_ASIENTO_MONTO_CERO,0) FROM ACCESOS_ADMINISTRATIVOS.T_CONFIGURACION_CONTABILIDAD WHERE C_RUC_EMPRESA = @RucE_P)          
--@P_IB_AJUSTAR_POR_CONVERSION BIT = 0                
                                      
SELECT                 
 @Cd_TM = Cd_TM                
 --@P_IB_AJUSTAR_POR_CONVERSION = ISNULL(C_IB_AJUSTAR_POR_CONVERSION,0)                
FROM                 
 MtvoIngSal                 
WHERE                 
 RucE = @RucE_P                 
 and Cd_MIS=@Cd_MIS_P                                      
             
IF (@Cd_TM='01')                                      
 IF NOT EXISTS (SELECT 1 FROM VW_VENTAS_CAB WHERE RucE=@RucE_P and Cd_Vta=@Cod_P)                                      
  SET @msj = 'Venta no existe. No se pudo generar voucher contable'                                      
IF (@Cd_TM='02')                                      
 IF NOT EXISTS (SELECT 1 FROM VW_COMPRAS_CAB WHERE RucE=@RucE_P and Cd_Com=@Cod_P)                                      
  SET @msj = 'Compra no existe. No se pudo generar voucher contable'                                      
IF (@Cd_TM='05')                                      
 IF NOT EXISTS (SELECT 1 FROM Inventario WHERE RucE=@RucE_P and Ejer=@Ejer_P and RegCtb=@Cod_P)                                      
  SET @msj = 'Movimiento de inventario no existe. No se pudo generar voucher contable'                                      
IF (@Cd_TM='08')                          
 IF NOT EXISTS (SELECT 1 FROM CanjePago WHERE RucE=@RucE_P and Cd_Cnj=@Cod_P)                                      
  SET @msj = 'Movimiento de Canje de letra de Pago no existe. No se pudo generar voucher contable'                                      
IF (@Cd_TM='09')                                      
 IF NOT EXISTS (SELECT 1 FROM Canje WHERE RucE=@RucE_P and Cd_Cnj=LEFT(@Cod_P,10))                                      
  SET @msj = 'Movimiento de Canje de letra no existe. No se pudo generar voucher contable'                                      
IF (@Cd_TM='10')                                      
 IF NOT EXISTS (SELECT 1 FROM ComprobantePercep WHERE RucE=@RucE_P and Cd_CPercep=@Cod_P)                                      
  SET @msj = 'Comprobante de Percepcion no existe. No se pudo generar voucher contable'                                      
IF (@Cd_TM='12')                                      
 IF NOT EXISTS (SELECT 1 FROM Compra2_Resumen WHERE RucE=@RucE_P and Cd_Com=@Cod_P)                                      
  SET @msj = 'Compra no existe. No se pudo generar voucher contable'                                      
IF (@Cd_TM='13')                                      
 IF NOT EXISTS (SELECT 1 FROM FabEtapa WHERE RucE=@RucE_P and Cd_Fab=LEFT(@Cod_P,10) and ID_Eta=RIGHT(@Cod_P,1) )                                       
  SET @msj = 'Movimiento de Etapa no existe. No se pudo generar voucher contable'                                      
IF (@Cd_TM='14')                                      
 IF NOT EXISTS (SELECT 1 FROM Liquidacion WHERE RucE=@RucE_P and Cd_Liq = SUBSTRING(@Cod_P, 1, 10))                                      
  SET @msj = 'Movimiento de Liquidacion no existe. No se pudo generar voucher contable'                                      
IF (@Cd_TM='15')                                     
 IF NOT EXISTS(SELECT 1 FROM contabilidad.FS_BUSCAR_DEPRECIACION_AGRUPADA(@RucE_P, @Ejer_P, @Cod_P, @ParametroAux1_P))                                      
  SET @msj = 'No existen Movimiento(s) de Depreciación en el Periodo asignado, no se pudo generar Asiento.'                        
IF (@Cd_TM='17')                                      
 IF NOT EXISTS (SELECT 1 FROM Inventario2 WHERE RucE =@RucE_P and RegistroContable= @RegCtb_P)                                      
  SET @msj = 'Movimiento de Inventario no existe. No se pudo generar voucher contable.'                                      
IF (@Cd_TM='18')                                      
 BEGIN                                      IF NOT EXISTS (SELECT 1 FROM activo_fijo.VW_T_BAJA_ACTIVO WHERE C_RUC_EMPRESA = @RucE_P and                                       
  CHARINDEX('[' + CONVERT(VARCHAR,C_ID_ACTIVO_BAJA) + ']', @Cod_P) > 0)                                       
   BEGIN                                      
   SET @msj = 'Movimiento de Baja de Activo no existe. No se pudo generar Voucher Contable.'                                      
   RETURN                                      
   END                                             
 END                                      
IF (@Cd_TM = '21')                
 IF NOT EXISTS(SELECT 1 FROM OrdCompra where RucE = @RucE_P and Cd_OC = SUBSTRING(@Cod_P,1,10))      SET @msj = 'Orden de Compra no existe. No se pudo generar voucher contable.'                                      
IF (@CD_TM = '22')                                      
 IF NOT EXISTS(SELECT 1 FROM Letra_Pago WHERE RucE = @RucE_P and Cd_Cnj = @Cod_P and Cd_Ltr = @ParametroAux1_P)                                      
  SET @msj = 'Letra de Pago no existe. No se pudo generar voucher contable'                           
IF (@CD_TM = '23')                                      
 IF NOT EXISTS(SELECT 1 FROM [DBO].[VW_RETENCION_VENTA] WHERE C_RUC_COMPROBANTE_RETENCION = @RucE_P and  C_REGISTRO_CONTABLE = @RegCtb_P)                                      
  SET @msj = 'Movimiento de retencion en venta no existe. No se pudo generar voucher contable'                                      
IF (@CD_TM = '25')                                      
 IF NOT EXISTS(SELECT 1 FROM integracion.VW_RECEPCION_INFORMACION_RESERVA WHERE RUC_EMPRESA = @RucE_P and ID_RESERVA_CABECERA = @Cod_P)                                      
  SET @msj = 'Movimiento de recepción de información - Reserva no existe. No se pudo generar voucher contable'                                      
IF (@CD_TM = '26')                                      
 IF NOT EXISTS(SELECT 1 FROM integracion.VW_RECEPCION_INFORMACION_PROVISION WHERE RUC_EMPRESA = @RucE_P and ID_PROVISION = @Cod_P)                                      
  SET @msj = 'Movimiento de recepción de información - Provisión no existe. No se pudo generar voucher contable'                                      
IF (@CD_TM = '27')                                      
 IF NOT EXISTS(SELECT 1 FROM integracion.VW_RECEPCION_INFORMACION_COBRANZA WHERE RUC_EMPRESA = @RucE_P and ITEM_CABECERA = @Cod_P)                                      
  SET @msj = 'Movimiento de recepción de información - Cobranza no existe. No se pudo generar voucher contable'                                      
IF (@CD_TM = '28')                                      
 IF NOT EXISTS(SELECT 1 FROM integracion.VW_RECEPCION_INFORMACION_PAGO_DIRECTO WHERE RUC_EMPRESA = @RucE_P and ID_PAGO_DIRECTO_CABECERA = @Cod_P)                                      
  SET @msj = 'Movimiento de recepción de información - Pago Directo no existe. No se pudo generar voucher contable'                            
IF (@CD_TM = '29')                                      
 IF NOT EXISTS(SELECT 1 FROM CASINO.VW_LIQUIDACION_MENSUAL WHERE C_RUC_EMPRESA = @RucE_P and C_ID_LIQUIDACION_MENSUAL_CONTABILIDAD = @Cod_P)                                      
  SET @msj = 'Registro de Liquidación mensual asociado no existe. No se pudo generar voucher contable'                                  
IF (@CD_TM = '30')                                    
 IF NOT EXISTS(SELECT 1 FROM CONTAAPI.VW_PRE_AFILIACION WHERE RUC_EMPRESA = @RucE_P and ID_PRE_AFILIACION = @Cod_P)                               
  SET @msj = 'Registro de Pre Afiliación no existe. No se pudo generar voucher contable'                                     
IF (@CD_TM = '32')                        
 IF NOT EXISTS(SELECT 1 FROM activo_fijo.VW_ACTIVO_REVALUADO WHERE C_RUC_EMPRESA = @RucE_P and C_ID_REVALUACION = @ParametroAux1_P)                        
  SET @msj = 'No existen Movimiento(s) de Revaluación en el Periodo asignado, no se pudo generar Asiento.'                        
IF (@CD_TM = '33')                        
 IF NOT EXISTS(SELECT 1 FROM activo_fijo.VW_ACTIVO_DEPRECIACION_REVALUADO WHERE C_RUC_EMPRESA = @RucE_P and C_ID_DEPRECIACION_REVALUACION = @ParametroAux1_P)                        
  SET @msj = 'No existen Movimiento(s) de Depreciación de Revaluación en el Periodo asignado, no se pudo generar Asiento.'                        
                             
IF EXISTS (SELECT 1 FROM Voucher WHERE RucE=@RucE_P and Ejer=@Ejer_P and RegCtb=@RegCtb_P)                                      
BEGIN                                      
 SET @msj = 'IMPOSIBLE MAYORIZAR. Ya existe voucher con este Reg. Contable, elimine asiento y vuelva a registrar'         
 RETURN                                      
END                            
                        
DECLARE @CORRECTO BIT = 0                                      
 EXEC CONTABILIDAD.PR_VALIDACION_RESERVA_REGISTRO_CONTABLE @RucE_P,@RegCtb_P,@Ejer_P,@CORRECTO OUTPUT,@msj OUTPUT                                          
          
print '0: Correcto, 1: Incorrecto -> ' + Convert(varchar, @CORRECTO)          
          
IF @CORRECTO = 0                                      
BEGIN                                      
 RETURN                                      
END                                      
                                      
DECLARE                                     
@Cta  VARCHAR(50)  ,                                      
@CtaME  VARCHAR(50)  ,                                      
@IC_JDCtaPA CHAR(1)   ,                                      
@IC_CaAb CHAR(1)   ,                      
@IN_TipoCta INT    ,                                      
@Cd_IV  CHAR(3)   ,                                      
@Porc  NUMERIC(5,2) ,                                      
@Fmla  VARCHAR(200) ,                                      
@IC_PFI  CHAR(1)   ,                                      
@Glosa  VARCHAR(500) ,                                      
@IC_VFG  CHAR(1)   ,                                      
@Cd_CC  NVARCHAR(8)  ,                                      
@Cd_SC  NVARCHAR(8)  ,                                      
@Cd_SS  NVARCHAR(8)  ,                                      
@IC_JDCC CHAR(1)   ,                                      
@IB_Aux  BIT    ,                                      
@IB_EsDes BIT    ,                                      
@Cd_IA  CHAR(1)   ,                                      
@IC_ES  CHAR(1)   ,                @Prdo  NVARCHAR(2)  ,                                      
@Cd_Fte  VARCHAR(2) = RIGHT(LEFT(@RegCtb_P,7),2),                                      
@FecMov  SMALLDATETIME ,                                      
@FecCbr  SMALLDATETIME ,                                      
@NroCta  VARCHAR(50)  ,                                      
@CtaAsoc VARCHAR(50)  ,                                      
@Cd_Clt  CHAR(10)  ,                                      
@Cd_Prv  CHAR(7)   ,                                      
@Cd_TD  NVARCHAR(2)  ,    
@NroSre  VARCHAR(20)  ,   
@NroDoc  VARCHAR(20)  ,    
@FecED  SMALLDATETIME ,   
@FecVD  SMALLDATETIME ,   
@MtoOr  NUMERIC(20,2) = 0,  
@MtoD  NUMERIC(20,2) ,                                      
@MtoH  NUMERIC(20,2) ,          
@MtoD_ME  NUMERIC(20,2) ,   --SE CREAN SOLO PARA INVENTARIO 2                                
@MtoH_ME  NUMERIC(20,2) ,  --SE CREAN SOLO PARA INVENTARIO 2                                 
@Cd_MdOr NVARCHAR(2) = '01',                                      
@Cd_MdRg NVARCHAR(2)  ,                                      
@CamMda  NUMERIC(10,3) ,                                      
@Cd_Area NVARCHAR(6)  ,                                      
@Cd_MR  NVARCHAR(2)  ,                                      
@NroChke VARCHAR(30)  ,                                      
@Cd_TG  NVARCHAR(2) = '01',                                      
@IC_CtrMd VARCHAR(1) = 'a',                                      
@UsuCrea NVARCHAR(10) ,                                      
@IB_Anulado BIT    ,                     
@SaldoMN DECIMAL(20,2) ,                                      
@SaldoME DECIMAL(20,2) ,                                      
@TipMov  VARCHAR(1) = 'M',                                      
@IC_TipAfec VARCHAR(1)  ,                                      
@TipOper VARCHAR(4)  ,                                      
@Grdo  VARCHAR(100) ,                                      
@RegOrg  NVARCHAR(15) ,                                      
@IC_Crea VARCHAR(1) = 'I',                                       
@IB_PgTot BIT = (CASE WHEN @Cd_TM = '17' THEN 0 ELSE 1 END),                                      
@DR_FecED SMALLDATETIME ,                                      
@DR_CdTD NVARCHAR(2)  ,                                      
@DR_NSre VARCHAR(20)  ,                           
@DR_NDoc VARCHAR(20)  ,                                      
@DR_NCND VARCHAR(15)  ,                                      
@DR_NroDet  VARCHAR(15)  ,                                      
@DR_FecDet  SMALLDATETIME ,                                      
@NroCta_Temp VARCHAR(50)  ,                                      
@IC_Tipo CHAR(1) = (SELECT IC_Tipo FROM MtvoIngSal WHERE RucE = @RucE_P and Cd_MIS = @Cd_MIS_P),                                      
--@Item_Det_Inv int,      
@Cod_P_Item VARCHAR(100) ,                                      
@Cod_P_Item_Peps INT    ,                                      
@Cod_P_Det  VARCHAR(15),  
@Id_CCOF VARCHAR(20),
@Cd_Vou_CCOF VARCHAR(20),  
@IC_TipCamCD CHAR(1),                        
@Cd_FPC  NVARCHAR(2),                                      
@Cd_FCP  NVARCHAR(2) = NULL,                           
@IC_Inv  CHAR(1)   ,          
@L_REGCTB_REF NVARCHAR(15) = NULL,                                      
@ITEM_ASIENTO INT,                                      
@L_IB_PROV  BIT,        
@L_USO_COMPRAS2 BIT = (SELECT ISNULL(UsoCompras2,0) FROM CfgGeneral WHERE RUCE = @RucE_P),       
      
--Campos Adicionales      
@CA01 NVARCHAR(MAX) = NULL,      
@CA02 NVARCHAR(MAX) = NULL,      
@CA03 NVARCHAR(MAX) = NULL,      
@CA04 NVARCHAR(MAX) = NULL,      
@CA05 NVARCHAR(MAX) = NULL,      
@CA06 NVARCHAR(MAX) = NULL,      
@CA07 NVARCHAR(MAX) = NULL,      
@CA08 NVARCHAR(MAX) = NULL,      
@CA09 NVARCHAR(MAX) = NULL,      
@CA10 NVARCHAR(MAX) = NULL,      
@CA11 NVARCHAR(MAX) = NULL,      
@CA12 NVARCHAR(MAX) = NULL,      
@CA13 NVARCHAR(MAX) = NULL,      
@CA14 NVARCHAR(MAX) = NULL,      
@CA15 NVARCHAR(MAX) = NULL,      
--Fin Campos Adicionales      
      
--NO DOMICILIADO                                      
@L_CD_BENEFICIARIO  CHAR(7),                                      
@L_NRO_TV   CHAR(2),                                      
@L_RENTA_BRUTA  DECIMAL(20,2),                                      
@L_DEDUCCION_COSTO_CAPITAL DECIMAL(20,2),                                      
@L_RENTA_NETA  DECIMAL(20,2),                                      
@L_TASA_RET   DECIMAL(20,2),                             
@L_IMPUESTO_RET  DECIMAL(20,2),                                      
@L_IGV_RET   DECIMAL(20,2),                                      
@L_NRO_CEDT   CHAR(2),                                      
@L_NRO_EOND   CHAR(2),                                      
@L_NRO_TR   CHAR(2),                                      
@L_NRO_MS   CHAR(2),                                      
@L_APLICACION_ART   VARCHAR(100),                                      
                                      
@L_ID_CONCEPTO_FEC   INT,                                  
@L_IB_DEVOLUCION_IGV BIT,            
@L_IGV_TASA DECIMAL(6,2),          
          
--AGRUPACION DE CUENTAS                                      
@Ib_Agrup  BIT,                                
@Cd_Trab CHAR(8) = NULL,          
@L_IB_TransferenciaGratuita BIT          
          
/* Indicador para obtener los gastos de fabricación */          
DECLARE @CD_Fabricacion char(10)          
DECLARE @ID_Etapa int          
DECLARE @ID_FabItem int          
         
/* Indicador para obtener los gastos de producción */          
DECLARE @CD_Produccion char(10)        
DECLARE @ID_ProdItem int        
        
IF (@Cd_TM = '01' or @Cd_TM = '20')                                      
BEGIN                                      
 SET @Cd_MR = '01'                                       
 SET @NomTabla = 'VW_VENTAS_CAB'                                      
 SET @NomTablaDet = 'VW_VENTAS_DET'                                      
 SET @colCodTab = 'Cd_Vta'                                       
 SET @colCodTabDet = 'Nro_RegVdt'                                      
                                      
 SELECT                                      
 @Prdo = CASE WHEN @Cd_TM = '20' THEN RIGHT('0' + CONVERT(VARCHAR, MONTH(C_FECMOVDTR)),2) ELSE Prdo END,                                      
 @FecMov = FecMov, @FecCbr = FecCbr, @Cd_TD = Cd_TD, @NroSre = NroSre,                                      
 @FecED = FecED, @FecVD = FecVD, @Cd_MdRg = Cd_Mda, @CamMda = CamMda, @Cd_Area = Cd_Area,@UsuCrea = UsuCrea, @NroDoc = NroDoc,@Cd_MdOr = @Cd_MdRg,                                      
 @DR_FecED = DR_FecED, @DR_CdTD = DR_CdTD, @DR_NSre = DR_NSre, @DR_NDoc = DR_NDoc, @IB_Anulado = IB_Anulado, @L_IGV_TASA = C_IGV_TASA          
 FROM VW_VENTAS_CAB                                       
 WHERE RucE = @RucE_P and Cd_Vta = @Cod_P                                      
                                        
 PRINT 'sacamos valor de venta'                                      
                      
 /*Se captura el Reg. Contable de la compra referenciada*/                                      
 IF (SUBSTRING(@RegCtb_P,1,2) ='VT' AND SUBSTRING(@RegCtb_P,6,2) ='LD')                                      
  BEGIN                                      
   SET @L_REGCTB_REF = (SELECT REGCTB FROM VENTA WITH(NOLOCK) WHERE RUCE = @RucE_P AND EJE = @Ejer_P AND CD_VTA = @Cod_P)                                      
  END                                      
                                      
END                                      
ELSE IF (@Cd_TM = '02')                                       
BEGIN                                      
 SET @Cd_MR = '02'                                       
 SET @NomTabla = 'VW_COMPRAS_CAB'                                      
 SET @NomTablaDet = 'VW_COMPRAS_DET'                                       
 SET @colCodTab = 'Cd_Com'                                       
 SET @colCodTabDet = 'Item'                                      
                                       
 SELECT @Prdo = CASE WHEN @Cd_TM = '16' THEN RIGHT('0' + CONVERT(VARCHAR, MONTH(FecMovDTR)),2) ELSE Prdo END,                                       
 @FecMov = FecMov, @FecCbr = FecAPag, @Cd_TD = Cd_TD, @NroSre = NroSre, @NroDoc = NroDoc, @FecED = FecED,                     
          
 @FecVD = FecVD, @Cd_MdRg = Cd_Mda, @CamMda = CamMda, @Cd_Area = Cd_Area, @UsuCrea = UsuCrea, @DR_NCND = DR_NCND, @DR_NroDet = NroDocDet, @DR_FecDet = FecPagDtr, @Cd_MdOr = @Cd_MdRg,                                    
 @DR_FecED = DR_FecED, @DR_CdTD = DR_CdTD, @DR_NSre = DR_NSre, @DR_NDoc = DR_NDoc, @IB_Anulado = IB_Anulado, @L_IGV_TASA = C_IGV_TASA,          
 --CAMPOS NO DOMICILIADO                                      
 @L_CD_BENEFICIARIO = C_CD_BENEFICIARIO, @L_NRO_TV = C_NRO_TV, @L_RENTA_BRUTA = C_RENTA_BRUTA, @L_DEDUCCION_COSTO_CAPITAL = C_DEDUCCION_COSTO_CAPITAL, @L_RENTA_NETA = C_RENTA_NETA, @L_TASA_RET = C_TASA_RET,                                      
 @L_IMPUESTO_RET = C_IMPUESTO_RET, @L_IGV_RET = C_IGV_RET, @L_NRO_CEDT = C_NRO_CEDT, @L_NRO_EOND = C_NRO_EOND, @L_NRO_TR = C_NRO_TR, @L_NRO_MS = C_NRO_MS, @L_APLICACION_ART = C_APLICACION_ART                          
                                       
 FROM VW_COMPRAS_CAB                                       
 WHERE RucE = @RucE_P and Cd_Com = @Cod_P                                      
                              
 PRINT 'sacamos valor de compra'                                      
                                      
 /*Se captura el Reg. Contable de la compra referenciada*/                                      
 IF (SUBSTRING(@RegCtb_P,1,2) ='CP' AND SUBSTRING(@RegCtb_P,6,2) ='LD')                                      
  BEGIN                                      
   SET @L_REGCTB_REF = (SELECT REGCTB FROM Compra WHERE RUCE = @RucE_P AND EJER = @Ejer_P AND CD_COM = @Cod_P)                                      
  END                                      
END                                      
ELSE IF (@Cd_TM = '05')                                       
BEGIN                                      
 SET @Cd_MR ='05'                                       
 SET @NomTabla = 'Inventario'                                      
 SET @NomTablaDet = 'Inventario'                                       
 SET @colCodTab = 'Ejer = '''+@Ejer_P+''' and RegCtb'                                       
 SET @colCodTabDet = 'Cd_Inv'                                      
                                      
 SELECT TOP 1 @Prdo = LEFT(CONVERT(VARCHAR,FecMov,1),2), @FecMov = FecMov, @Cd_Area = Cd_Area, @Cd_MdRg = Cd_Mda, @UsuCrea = UsuCrea                                       
 FROM Inventario                                       
 WHERE RucE = @RucE_P and Ejer = @Ejer_P and RegCtb = @Cod_P                                      
                                        
 PRINT 'sacamos valor de Inventario'                       
                                      
 /*Establecemos una variable que determinará qué configuración está usando el Cliente, PEPS | Promedio*/                                      
 SET @IC_Inv = (SELECT CASE WHEN ISNULL(IC_TipoCostoInventario,'PROMEDIO') = 'PROMEDIO' THEN 'M' ELSE 'P' END FROM CfgGeneral WHERE RucE = @RucE_P)                                      
END                                      
ELSE IF (@Cd_TM ='08')                                       
BEGIN                                      
 SET @Cd_MR = '08'                                      
 SET @NomTabla = 'CanjePago'                                      
 SET @colCodTab = 'Cd_Cnj'                                      
                                         
 SELECT TOP 1 @Prdo = Prdo, @FecMov = FecMov, @Cd_Area = Cd_Area, @Cd_MdRg = Cd_Mda, @UsuCrea = UsuReg, @L_IGV_TASA = C_IGV_TASA          
 FROM CanjePago WHERE RucE = @RucE_P and Cd_Cnj = @Cod_P                                      
                                      
 PRINT 'sacamos valor de Letras de Pago'                                      
END                                      
ELSE IF (@Cd_TM ='09')                                       
BEGIN                                      
 SET @Cd_MR = '09'                                       
 SET @NomTabla = 'Canje'                                      
 SET @colCodTab = 'Cd_Cnj'                                        
 SET @Cod_P_Item = RIGHT(@Cod_P,len(@Cod_P)-10)                                      
 SET @Cod_P = LEFT(@Cod_P,10)                                       
            
 SELECT TOP 1 @Prdo = Prdo, @FecMov = FecMov, @Cd_Area = Cd_Area, @Cd_MdRg = Cd_Mda, @UsuCrea = UsuReg, @L_IGV_TASA = C_IGV_TASA          
 FROM Canje WHERE RucE = @RucE_P and Cd_Cnj = @Cod_P                     
                                      
 PRINT 'sacamos valor de Letras'                                      
                                      
END                                       
ELSE IF (@Cd_TM = '10')                                      
BEGIN                                      
 SET @Cd_MR = '10'                                       
 SET @NomTabla = 'ComprobantePercep'                                      
 SET @NomTablaDet = 'ComprobantePercepDet'                                      
 SET @colCodTab = 'Cd_CPercep'                                       
 SET @colCodTabDet = 'Cd_Vta'                                      
                                      
 SELECT @Prdo = Prdo, @FecMov = FecCbr, @FecCbr = FecCbr, @Cd_Area = '010101',@Cd_TD = Cd_TD, @NroSre = NroSre, @NroDoc = @NroDoc, @CamMda = TipoCambio,                                      
 @Cd_MdRg = Cd_Mda, @Cd_Area=Cd_Area,@UsuCrea=UsuCrea, @NroDoc=NroDoc                                      
 FROM ComprobantePercep                                       
 WHERE RucE=@RucE_P and Cd_CPercep = @Cod_P                                      
                                      
 PRINT 'sacamos valor de Comprobante de Percepcion'                                      
END      
ELSE IF (@Cd_TM = '12')                                       
BEGIN                                      
 SET @Cd_MR = '12'                                       
 SET @NomTabla = 'Compra2_Resumen'                                      
 SET @NomTablaDet = 'CompraDet2_Resumen'                                      
 SET @colCodTab = 'Cd_Com'                                       
 SET @colCodTabDet = 'Item'                                      
                                      
 SELECT @Prdo = Prdo, @FecMov = FecMov, @FecCbr = FecPag, @Cd_TD = Cd_TD, @NroSre = NroSre, @NroDoc = NroDoc,@FecED = FecED,                                       
 @FecVD = FecVD, @Cd_MdRg = Cd_Mda, @CamMda = CamMda, @Cd_Area = Cd_Area, @UsuCrea = UsuCrea, @Cd_MdOr = @Cd_MdRg,                                      
 @DR_FecED = DR_FecED, @DR_CdTD = DR_Cd_TD, @DR_NSre = DR_NroSre, @DR_NDoc = DR_NroDoc, @IB_Anulado = IB_Anulado, @DR_NroDet = NroDocDet, @DR_FecDet = FecPagDtr,                                     
 --CAMPOS NO DOMICILIADO                                      
 @L_CD_BENEFICIARIO = C_CD_BENEFICIARIO, @L_NRO_TV = C_NRO_TV, @L_RENTA_BRUTA = C_RENTA_BRUTA, @L_DEDUCCION_COSTO_CAPITAL = C_DEDUCCION_COSTO_CAPITAL,                               
 @L_RENTA_NETA = C_RENTA_NETA, @L_TASA_RET = C_TASA_RET,                                      
 @L_IMPUESTO_RET = C_IMPUESTO_RET, @L_IGV_RET = C_IGV_RET, @L_NRO_CEDT = C_NRO_CEDT, @L_NRO_EOND = C_NRO_EOND, @L_NRO_TR = C_NRO_TR, @L_NRO_MS = C_NRO_MS, @L_APLICACION_ART = C_APLICACION_ART, @L_IGV_TASA = C_IGV_TASA          
                                      
 FROM Compra2_Resumen                                       
 WHERE RucE = @RucE_P /*and ejer = @Ejer*/ and Cd_Com = @Cod_P                
         
 PRINT 'Prdo : ' + @Ejer                            
 PRINT 'sacamos valor de compra2'                                      
END                                      
ELSE IF (@Cd_TM = '13')                                      
BEGIN                                      
 SET @Cd_MR = '13'                                      
 SET @NomTabla = 'FabEtapa'                                      
 SET @colCodTab = 'Cd_Fab'                                       
                                      
 SELECT TOP 1 @Prdo = LEFT(CONVERT(VARCHAR,FecIni,1),2), @FecMov=FecIni, @Cd_Area = (SELECT TOP 1 Cd_Area FROM Area WHERE RucE = @RucE_P), @Cd_MdRg='01', @UsuCrea=UsuCrea /*------TO DO (Prdo,Cd_Area,Cd_MdRg)------*/                                      
 FROM FabEtapa                                       
 WHERE RucE=@RucE_P and Cd_Fab = LEFT(@Cod_P,10) and ID_Eta = RIGHT(@Cod_P,len(@Cod_P)-10)                                      
                                      
 PRINT 'sacamos valor de Etapa de la Fabricacion'                                      
END             
ELSE IF (@Cd_TM = '14')                                    
BEGIN                                      
 SET @Cd_MR = '14'                 
 SET @NomTabla = 'Liquidacion'                                      
 SET @NomTablaDet = 'LiquidacionDet'                                      
 SET @colCodTab = 'Cd_Liq'                                    
 SET @colCodTabDet = 'Item'                                      
 SET @Cod_P_Item = RIGHT(@Cod_P,len(@Cod_P)-10)                                      
 SET @Cod_P = LEFT(@Cod_P,10)                                      
                            
 SELECT @L_IGV_TASA = C_IGV_TASA          
 FROM Liquidacion                              
 WHERE RucE = @RucE_P and Cd_Liq = @Cod_P          
          
 SELECT @Prdo = LEFT(RIGHT(RegCtb,8),2), @FecMov = FeCMov, @Cd_MdRg = Cd_Mda, @CamMda = CamMda,                                      
 @Cd_Area = Cd_Area,@UsuCrea = UsuCrea, @FecED = FecED, @Cd_MdOr = @Cd_MdRg, @Cd_FPC = '01', @DR_NroDet = DR_NroDet, @DR_FecDet = DR_FecDet          
 FROM LiquidacionDet                              
 WHERE RucE=@RucE_P and Cd_Liq = @Cod_P and Item = @Cod_P_Item                                      
                                      
 PRINT 'sacamos valor de Liquidacion'          
 PRINT @Prdo                                      
END                                      
ELSE IF (@Cd_TM = '15')                                      
BEGIN                                      
 SET @Cd_MR = '16'                                       
 SET @NomTabla = 'contabilidad.FS_BUSCAR_DEPRECIACION_AGRUPADA(''' + @RucE_P + ''', ''' + @Ejer_P + ''', ''' + @Cod_P + ''', ''' +@ParametroAux1_P + ''')'                                      
 SET @colCodTab = 'C_ID_ACTIVO'                                       
                                       
  SELECT                                       
  TOP(1)                                      
  @Prdo =  SUBSTRING(@RegCtb_P,8,2),                                      
  @FecMov = @ParametroAux2_P,                                      
  @Cd_Area = @ParametroAux3_P,                                  
  @UsuCrea = C_USUARIO_REGISTRO,                                      
  @Cd_MdRg = C_CODIGO_MONEDA,                                      
  @CamMda = C_TIPO_CAMBIO                                      
  FROM                                      
  contabilidad.FS_BUSCAR_DEPRECIACION_AGRUPADA(@RucE_P, @Ejer_P, @Cod_P, @ParametroAux1_P)                                      
                                      PRINT 'Sacamos el Valor de Depreciación Histórica'                                      
END                                      
ELSE IF (@CD_TM = '16')                                      
BEGIN                                      
                                      
 IF (@ParametroAux1_P = '02') --VIENE DESDE COMPRAS 2                                      
  BEGIN                                      
   SET @Cd_MR = '17'                                       
   SET @NomTabla = 'Compra2_Resumen'                                      
   SET @NomTablaDet = 'CompraDet2_Resumen'                                      
   SET @colCodTab = 'Cd_Com'                                       
 SET @colCodTabDet = 'Item'                                      
                                      
   SELECT @Prdo = SUBSTRING(@RegCtb_P,8,2), @FecMov = FecMov, @FecCbr = FecPag, @Cd_TD = Cd_TD, @NroSre = NroSre, @NroDoc = NroDoc,@FecED = FecED,                                      
   @FecVD = FecVD, @Cd_MdRg = Cd_Mda, @CamMda = CamMda, @Cd_Area = Cd_Area, @UsuCrea = UsuCrea,                                       
   @DR_FecED = DR_FecED, @DR_CdTD = DR_Cd_TD, @DR_NSre = DR_NroSre, @DR_NDoc = DR_NroDoc, @IB_Anulado = IB_Anulado, @L_IGV_TASA = C_IGV_TASA          
   FROM Compra2_Resumen                                       
   WHERE RucE = @RucE_P and Cd_Com = @Cod_P                                      
  END                                      
 ELSE                                      
  BEGIN                                      
   SET @Cd_MR = '02'                                       
   SET @NomTabla = 'VW_COMPRAS_CAB'                                      
   SET @NomTablaDet = 'VW_COMPRAS_DET'                                       
   SET @colCodTab = 'Cd_Com'                                       
 SET @colCodTabDet = 'Item'                                      
                                       
   SELECT @Prdo = CASE WHEN @Cd_TM = '16' THEN RIGHT('0' + CONVERT(VARCHAR, MONTH(FecMovDTR)),2) ELSE Prdo END,                                       
   @FecMov = FecMov, @FecCbr = FecAPag, @Cd_TD = Cd_TD, @NroSre = NroSre, @NroDoc = NroDoc, @FecED = FecED,                                      
                                       
   @FecVD = FecVD, @Cd_MdRg = Cd_Mda, @CamMda = CamMda, @Cd_Area = Cd_Area, @UsuCrea = UsuCrea, @DR_NCND = DR_NCND, @DR_NroDet = NroDocDet, @DR_FecDet = FecPagDtr, @Cd_MdOr = @Cd_MdRg,                                      
   @DR_FecED = DR_FecED, @DR_CdTD = DR_CdTD, @DR_NSre = DR_NSre, @DR_NDoc = DR_NDoc, @IB_Anulado = IB_Anulado,                                      
   --CAMPOS NO DOMICILIADO                                      
   @L_CD_BENEFICIARIO = C_CD_BENEFICIARIO, @L_NRO_TV = C_NRO_TV, @L_RENTA_BRUTA = C_RENTA_BRUTA, @L_DEDUCCION_COSTO_CAPITAL = C_DEDUCCION_COSTO_CAPITAL, @L_RENTA_NETA = C_RENTA_NETA, @L_TASA_RET = C_TASA_RET,                                      
   @L_IMPUESTO_RET = C_IMPUESTO_RET, @L_IGV_RET = C_IGV_RET, @L_NRO_CEDT = C_NRO_CEDT, @L_NRO_EOND = C_NRO_EOND, @L_NRO_TR = C_NRO_TR, @L_NRO_MS = C_NRO_MS, @L_APLICACION_ART = C_APLICACION_ART, @L_IGV_TASA = C_IGV_TASA          
   FROM VW_COMPRAS_CAB                                       
   WHERE RucE = @RucE_P and Cd_Com = @Cod_P                                      
  END                                      
                                      
 PRINT 'SACAMOS VALOR DE DETRACCIÓN DE ' + CASE WHEN @ParametroAux1_P = '02' THEN 'COMPRAS 2' ELSE 'COMPRA' END                                      
                                      
END                                      
ELSE IF (@Cd_TM = '17')                                      
BEGIN                                      
                                      
 /*Establecemos una variable que determinará qué configuración está usando el Cliente, PEPS | Promedio*/                                      
 SET @IC_Inv = (SELECT CASE WHEN ISNULL(IC_TipoCostoInventario,'PROMEDIO') = 'PROMEDIO' THEN 'M' ELSE 'P' END FROM CfgGeneral WHERE RucE = @RucE_P)                                      
                                      
 SET @Cd_MR = '19'                                       
 SET @NomTabla = 'Inventario2_Cabecera'                                      
 SET @NomTablaDet = 'Inventario2_Detalle'                                      
 SET @colCodTab = 'Cd_Inv'                                       
 SET @colCodTabDet = 'Item'                                      
                                      
 SELECT                                       
 @Prdo = LEFT(RIGHT(RegistroContable,8),2), @FecMov = Inv.FechaMovimiento , @Cd_Area = Inv.Cd_Area,@UsuCrea = Inv.UsuCrea, @Cd_MdRg = Inv.Cd_Mda,                                       
 @CamMda = CASE WHEN @IC_Inv = 'P' THEN CambioMonedaPeps ELSE CambioMoneda END                                      
 FROM Inventario2_Cabecera Inv                                       
 WHERE RucE = @RucE_P and RegistroContable = @RegCtb_P and Cd_Inv = @Cod_P                                      
      
 --Se comenta debido a lo conversado con Piero en el caso 68146            
 --if exists (select 1 from MovimientoInventario where RucE=@RucE_P and Cd_Inv_Destino=@Cod_P and Cd_IP_Origen is not null)                          
 --begin                          
 -- select                          
 --  @CamMda = SUM(CM.CamMda) / COUNT(*)                          
 -- from                          
 --  (                          
 --   select                          
 --    Cd_IP,                          
 --  SUM(Total) / SUM(Total_ME) as CamMda                          
 --   from                          
 --    ImportacionDet                          
 --   where                          
 --    RucE=@RucE_P and Cd_IP in (select distinct Cd_IP_Origen from MovimientoInventario where RucE=@RucE_P and Cd_Inv_Destino=@Cod_P and Cd_IP_Origen is not null)                          
 --   group by                          
 --    Cd_IP                          
 --  ) as CM                          
 --end                          
                                      
 PRINT 'Sacamos el Valor de Inventario 2'                                       
END                                      
ELSE IF (@Cd_TM = '18')                                      
BEGIN                                      
                                      
 SET @Cd_MR = '16'                                       
 SET @NomTabla = 'activo_fijo.VW_T_BAJA_ACTIVO'                                      
 SET @NomTablaDet = 'activo_fijo.VW_T_BAJA_ACTIVO'                                      
 SET @colCodTab = 'C_ID_ACTIVO_BAJA'                                       
 SET @colCodTabDet = 'C_ID_ACTIVO_BAJA'                                      
                                 
 SELECT                                       
 TOP (1)                                      
 @Prdo = C_PERIODO_BAJA,                                       
 @FecMov = C_FECHA_BAJA ,                                   
 @Cd_Area = @ParametroAux1_P,                                       
 @UsuCrea = C_USUARIO_REGISTRO,                                       
 @Cd_MdRg = C_CODIGO_MONEDA,                                      
 @CamMda = C_TIPO_CAMBIO                                      
 FROM activo_fijo.VW_T_BAJA_ACTIVO BA                                      
 WHERE C_RUC_EMPRESA = @RucE_P and CHARINDEX('[' + CONVERT(VARCHAR,C_ID_ACTIVO_BAJA) + ']', @Cod_P) > 0                                      
                                      
 PRINT 'Sacamos el Valor en la Vista para generar el Asiento de Baja'                                       
END                                      
ELSE IF (@Cd_TM = '21')                                      
BEGIN                                      
 SET @Cd_MR = '02'                                       
 SET @NomTabla = 'DBO.F_ORDCOMPRA_COMPRA'                                      
 SET @NomTablaDet = 'DBO.F_ORDCOMPRADET_COMPRA'                                 
 SET @colCodTab = 'Cd_OC'                                       
 SET @colCodTabDet = 'Item'                                      
 SET @Cod_P_Item = RIGHT(@Cod_P,len(@Cod_P)-10)                                      
 SET @Cod_P = @Cod_P                                      
                                      
 SELECT                                       
  @Prdo = RIGHT('00' + CONVERT(VARCHAR(2),MONTH(FECE)),2),                                      
  @FecMov = GETDATE(),                                 
  @FecED = FECE,                                      
  @Cd_TD = C_NROTIPODOC,                                      
  @NroSre = NULL,                                      
  @NroDoc = C_NRODOC,                                      
  @Cd_MdRg = CD_MDA,                                      
  @CamMda = CAMMDA,                                      
  @Cd_Area = CD_AREA,                                      
  @UsuCrea = USUCREA,          
  @L_IGV_TASA = C_IGV_TASA          
 FROM DBO.F_ORDCOMPRA_COMPRA(@RucE_P,@Ejer_P,@Cod_P)                                      
                                      
                                      
 PRINT 'SACAMOS EL VALOR DE ORDEN COMPRA'                                      
END                                      
ELSE IF (@Cd_TM ='22')                                       
 BEGIN                                      
  --SET @Cd_MR = '08'                                       
  --SET @NomTabla = 'CanjePagoDet'                                      
  --SET @colCodTab = 'Cd_Mda'                                        
  --SET @Cod_P_Item = @ParametroAux1_P              
                                      
  --SELECT TOP 1 @Prdo = Prdo, @FecMov = FecMov, @Cd_Area = Cd_Area, @Cd_MdRg = Cd_Mda, @UsuCrea = UsuReg                                       
  --FROM CanjePago WHERE RucE = @RucE_P and Cd_Cnj = @Cod_P                                      
                                      
  SET @Cd_MR = '08'                                       
  SET @NomTabla = 'dbo.VW_LETRA_PAGO_RETENCIONES'                                      
  SET @colCodTab = 'Codigo_Letra'                                        
  SET @Cod_P_Item = @ParametroAux1_P                                
                                      
  SELECT TOP 1 @Prdo = Prdo, @FecMov = FecMov, @Cd_Area = Cd_Area,                                       
      @Cd_MdRg = Cd_Mda, @UsuCrea = UsuReg, @L_IGV_TASA = C_IGV_TASA          
   FROM CanjePago                     
   WHERE RucE = @RucE_P and Cd_Cnj = @Cod_P                                    
                                      
  PRINT 'SACAMOS VALOR DEL DETALLE DE LA LETRA POR PAGAR'                                      
 END                                      
ELSE IF (@Cd_TM = '23')                                      
BEGIN                                      
 SET @Cd_MR = '02'                                       
 SET @NomTabla = '[DBO].[VW_RETENCION_VENTA]'                                      
 SET @colCodTab = 'C_REGISTRO_CONTABLE'                                      
                
 SELECT TOP 1                                    
  @Prdo = C_PERIODO,                                       
  @FecED = C_FECHA_EMISION_COMPROBANTE_RETENCION,                                      
  @FecMov = C_FECHA_MOVIMIENTO_COMPROBANTE_RETENCION,                                       
  @Cd_Area = C_CODIGO_AREA,                                       
  @CamMda = C_CAMBIO_MONEDA,                                      
  @Cd_MdOr = C_CODIGO_MONEDA,                                      
  @Cd_MdRg = C_CODIGO_MONEDA, --'01', -- SIEMPRE REGISTRA EN SOLES                                       
  @UsuCrea = UsuCrea                                       
 FROM                                       
  [DBO].[VW_RETENCION_VENTA]                                       
 WHERE                                       
  C_RUC_COMPROBANTE_RETENCION = @RucE_P                                       
  and C_EJERCICIO_COMPROBANTE = @Ejer_P                                       
  and C_REGISTRO_CONTABLE = @RegCtb_P                                      
                                      
 /* Tipo de Cambio con la fecha de Emisión de la Retención */                                      
 --SET @CamMda = (SELECT TOP 1 ISNULL(TCVta, 1) FROM TipCam WHERE CONVERT(VARCHAR,FecTC,103) = CONVERT(VARCHAR,@FecED,103) and Cd_Mda='02')                          
 /*El tipo de cambio se registrará con el valor ingresado manualmente en Retenciones*/                                      
  SET @CamMda = @CambioMda_P                        
END                                      
ELSE IF (@Cd_TM = '25')                                      
 BEGIN                             
  SET @Cd_MR = '03'                                       
  SET @NomTabla = 'integracion.VW_RECEPCION_INFORMACION_RESERVA'                                      
  SET @colCodTab = 'ID_RESERVA_CABECERA'                                        
  SET @NomTablaDet = 'integracion.VW_RECEPCION_INFORMACION_RESERVA'                     
  SET @colCodTabDet = 'ITEM_RESERVA_DETALLE'                                      
                                        
  SELECT                                       
   @Prdo = PERIODO                                      
   ,@FecMov = FECHA_MOVIMIENTO                                      
   ,@FecCbr = FECHA_MOVIMIENTO                                      
   ,@Cd_TD = CODIGO_TIPO_DOCUMENTO                                      
   ,@NroSre = SERIE_DOCUMENTO                                     
   ,@NroDoc = NUMERO_DOCUMENTO                         
   ,@FecED = FECHA_MOVIMIENTO                                      
   ,@FecVD = FECHA_MOVIMIENTO                                      
   ,@Cd_MdRg = CODIGO_MONEDA                                      
   ,@Cd_MdOr = CODIGO_MONEDA                                      
   ,@CamMda = TIPO_CAMBIO                                      
   ,@Cd_Area = CODIGO_AREA                                      
   ,@UsuCrea = USUARIO_REGISTRO                                      
  FROM                                 
   integracion.VW_RECEPCION_INFORMACION_RESERVA                                      
  WHERE                                      
   RUC_EMPRESA = @RucE_P AND ID_RESERVA_CABECERA = @Cod_P                                        
                                      
  PRINT 'Sacamos el valor del Documento de recepción de información - Reserva'                                      
                                      
 END                                                 
ELSE IF (@Cd_TM = '26')                                      
 BEGIN                                      
  SET @Cd_MR = '03'                                       
  SET @NomTabla = 'integracion.VW_RECEPCION_INFORMACION_PROVISION'                              
  SET @colCodTab = 'ID_PROVISION'                              
  SET @NomTablaDet = 'integracion.VW_RECEPCION_INFORMACION_PROVISION'                              
  SET @colCodTabDet = 'ID_PROVISION'                                      
                                        
  SELECT                                       
   @Prdo = PERIODO                     
   ,@FecMov = FECHA_MOVIMIENTO                                      
   ,@FecCbr = FECHA_MOVIMIENTO                                      
   ,@Cd_TD = CODIGO_TIPO_DOCUMENTO                                      
   ,@NroSre = SERIE_DOCUMENTO                                      
   ,@NroDoc = NUMERO_DOCUMENTO                                      
   ,@FecED = FECHA_MOVIMIENTO                                      
   ,@FecVD = FECHA_MOVIMIENTO                                      
   ,@Cd_MdRg = CODIGO_MONEDA                                      
   ,@Cd_MdOr = CODIGO_MONEDA                                      
   ,@CamMda = TIPO_CAMBIO                                      
   ,@Cd_Area = CODIGO_AREA                                      
   ,@UsuCrea = USUARIO_REGISTRO                                      
  FROM                                      
   integracion.VW_RECEPCION_INFORMACION_PROVISION                                      
  WHERE                                      
   RUC_EMPRESA = @RucE_P AND ID_PROVISION = @Cod_P                                        
                                      
  PRINT 'Sacamos el valor del Documento de recepción de información - Provisión'                                      
                                      
 END                                      
ELSE IF (@Cd_TM = '27')                                      
 BEGIN                                      
  SET @Cd_MR = '03'                                       
  SET @NomTabla = 'integracion.VW_RECEPCION_INFORMACION_COBRANZA'                                      
  SET @colCodTab = 'ITEM_CABECERA'                                        
  --SET @NomTablaDet = 'integracion.VW_RECEPCION_INFORMACION_COBRANZA'                       
  --SET @colCodTabDet = 'ITEM_DETALLE'                                      
                                        
  SELECT                                       
   @Prdo = PERIODO                                      
   ,@FecMov = FECHA_MOVIMIENTO                                      
   ,@FecCbr = FECHA_MOVIMIENTO                                      
   ,@Cd_TD = CODIGO_TIPO_DOCUMENTO                                      
   ,@NroSre = SERIE_DOCUMENTO                                 
   ,@NroDoc = NUMERO_DOCUMENTO                                 
   ,@FecED = FECHA_MOVIMIENTO                                      
   ,@FecVD = FECHA_MOVIMIENTO                     
   ,@Cd_MdRg = CODIGO_MONEDA                                      
   ,@Cd_MdOr = CODIGO_MONEDA                               
   ,@CamMda = TIPO_CAMBIO                                      
   ,@Cd_Area = CODIGO_AREA                                      
   ,@UsuCrea = USUARIO_REGISTRO                                      
  FROM                                      
   integracion.VW_RECEPCION_INFORMACION_COBRANZA                                      
  WHERE                                      
   RUC_EMPRESA = @RucE_P AND ITEM_CABECERA = @Cod_P                                        
                                      
  PRINT 'Sacamos el valor del Documento de recepción de información - Cobranza'                                      
                                      
 END                                      
ELSE IF (@Cd_TM = '28')                                      
 BEGIN                                      
  SET @Cd_MR = '03'                                       
  SET @NomTabla = 'integracion.VW_RECEPCION_INFORMACION_PAGO_DIRECTO'                            
  SET @colCodTab = 'ID_PAGO_DIRECTO_CABECERA'                                        
  SET @NomTablaDet = 'integracion.VW_RECEPCION_INFORMACION_PAGO_DIRECTO'                            
  SET @colCodTabDet = 'ITEM_PAGO_DIRECTO_DETALLE'                                      
                                        
  SELECT                                       
   @Prdo = PERIODO                                      
   ,@FecMov = FECHA_MOVIMIENTO                                      
   ,@FecCbr = FECHA_MOVIMIENTO                                      
   ,@Cd_TD = CODIGO_TIPO_DOCUMENTO                        
   ,@NroSre = SERIE_DOCUMENTO                                      
   ,@NroDoc = NUMERO_DOCUMENTO                                      
   ,@FecED = FECHA_MOVIMIENTO                                      
   ,@FecVD = FECHA_MOVIMIENTO                                      
   ,@Cd_MdRg = CODIGO_MONEDA                                      
   ,@Cd_MdOr = CODIGO_MONEDA                                      
   ,@CamMda = TIPO_CAMBIO                                      
   ,@Cd_Area = CODIGO_AREA                                      
   ,@UsuCrea = USUARIO_REGISTRO                                      
  FROM                                      
   integracion.VW_RECEPCION_INFORMACION_PAGO_DIRECTO                            
  WHERE                                      
   RUC_EMPRESA = @RucE_P AND ID_PAGO_DIRECTO_CABECERA = @Cod_P                                        
                                      
  PRINT 'Sacamos el valor del Documento de recepción de información - Pago Directo'                
                                      
 END                                  
ELSE IF (@Cd_TM = '29')                                      
 BEGIN                                      
  SET @Cd_MR = '27'                                       
  SET @NomTabla = 'CASINO.VW_LIQUIDACION_MENSUAL'                                      
  SET @colCodTab = 'C_ID_LIQUIDACION_MENSUAL_CONTABILIDAD'                                  
  SET @NomTablaDet = 'CASINO.VW_LIQUIDACION_MENSUAL'                                  
  SET @colCodTabDet = 'C_ID_LIQUIDACION_MENSUAL_CONTABILIDAD'                                  
                                  
 DECLARE                                
 @TIPO_CAMBIO_VENTA NUMERIC(13,10),                                
 @TIPO_CAMBIO_COMPRA NUMERIC (13,10)                                 
                                
 SELECT                                  
  @Prdo = C_PERIODO                                
  ,@FecMov = GETDATE()--dbo.FN_DEVUELVE_FECHA_X_PERIODO (C_EJERCICIO,C_PERIODO)                                
  ,@FecCbr = GETDATE()                                
  ,@Cd_TD = C_CODIGO_TIPO_DOCUMENTO                                
  ,@NroSre = C_SERIE_DOCUMENTO                                
  ,@NroDoc = C_NUMERO_DOCUMENTO       
  ,@FecED = C_FECHA_REGISTRO                                
  ,@FecVD = GETDATE()                                
  ,@Cd_MdRg = (SELECT Valor1 FROM dbo.FN_OBTENER_VALORES_DE_TABLA_SPLIT(@ParametroAux2_P,'|'))                                
  ,@Cd_MdOr = '01'                                
  ,@CamMda = CONVERT(NUMERIC(6,3),(SELECT Valor2 FROM dbo.FN_OBTENER_VALORES_DE_TABLA_SPLIT(@ParametroAux2_P,'|')))                                
  ,@Cd_Area = (SELECT Valor1 FROM dbo.FN_OBTENER_VALORES_DE_TABLA_SPLIT(@ParametroAux1_P,'|'))                                
  ,@UsuCrea = (SELECT Valor3 FROM dbo.FN_OBTENER_VALORES_DE_TABLA_SPLIT(@ParametroAux1_P,'|'))                                
 FROM                                    
  CASINO.VW_LIQUIDACION_MENSUAL                  WHERE                                    
  C_RUC_EMPRESA = @RucE_P                                 
  AND C_ID_LIQUIDACION_MENSUAL_CONTABILIDAD = CONVERT(INT,@Cod_P)                                
                                
 /*CC-SC-SS*/                                
 SET @ParametroAux4_P = (SELECT Valor2 FROM dbo.FN_OBTENER_VALORES_DE_TABLA_SPLIT(@ParametroAux1_P,'|'))                                
                                
 --/*CC*/                                
 --SET @ParametroAux4_P = (SELECT Valor1 FROM dbo.FN_OBTENER_VALORES_DE_TABLA_SPLIT(@ParametroAux4_P,'-'))                                
                                  
 PRINT 'Sacamos el valor del Registro de Liquidación Mensual Contabilidad'                                
 END                                                    
 ELSE IF (@Cd_TM = '30')                                    
 BEGIN                                    
  SET @Cd_MR = '28'                                     
  SET @NomTabla = 'CONTAAPI.VW_PRE_AFILIACION'                       
  SET @colCodTab = 'ID_PRE_AFILIACION'                                
                                      
  SELECT                                     
   @Prdo = PERIODO                                    
   ,@FecMov = FECHA_MOVIMIENTO                                    
   ,@FecCbr = FECHA_MOVIMIENTO                                    
   ,@Cd_TD = CODIGO_TIPO_DOCUMENTO                                    
   ,@NroSre = SERIE_DOCUMENTO                                    
   ,@NroDoc = NUMERO_DOCUMENTO                                    
   ,@FecED = FECHA_MOVIMIENTO                                    
   ,@FecVD = FECHA_MOVIMIENTO                                    
   ,@Cd_MdRg = CODIGO_MONEDA                                    
   ,@Cd_MdOr = CODIGO_MONEDA                                    
   ,@CamMda = TIPO_CAMBIO                                    
   ,@Cd_Area = CODIGO_AREA                                    
   ,@UsuCrea = USUARIO_REGISTRO                        
  FROM                                    
   CONTAAPI.VW_PRE_AFILIACION                          
  WHERE                                    
   RUC_EMPRESA = @RucE_P AND ID_PRE_AFILIACION = @Cod_P                                      
                                    
  PRINT 'Sacamos el valor del Documento de Pre Afiliación'                        
                                    
 END                        
ELSE IF (@Cd_TM = '31')                         
 BEGIN                                      
  SET @Cd_MR = '03'                                       
  SET @NomTabla = 'CONTAAPI.VW_SERVICIO_DEVENGADO'                        
  SET @colCodTab = 'CODIGO_CONCATENADO'                                        
  SET @NomTablaDet = 'CONTAAPI.VW_SERVICIO_DEVENGADO'                        
  SET @colCodTabDet = 'CODIGO_CONCATENADO'                                      
                                        
  SELECT                                       
   @Prdo = PERIODO                        
   ,@FecMov = FECHA_MOVIMIENTO                        
   ,@FecCbr = FECHA_MOVIMIENTO                        
   ,@Cd_TD = CODIGO_TIPO_DOCUMENTO_CABECERA                        
   ,@NroSre = SERIE_DOCUMENTO_CABECERA                        
   ,@NroDoc = NUMERO_DOCUMENTO_CABECERA                        
   ,@FecED = FECHA_MOVIMIENTO                        
   ,@FecVD = FECHA_MOVIMIENTO                        
   ,@Cd_MdRg = CODIGO_MONEDA_DETALLE                        
   ,@Cd_MdOr = CODIGO_MONEDA_CABECERA                        
   ,@CamMda = TIPO_CAMBIO_DETALLE                                      
   ,@Cd_Area = CODIGO_AREA                                      
   ,@UsuCrea = USUARIO_REGISTRO_DETALLE                                      
  FROM                                      
   CONTAAPI.VW_SERVICIO_DEVENGADO                        
  WHERE                                      
   RUC_EMPRESA = @RucE_P AND CODIGO_CONCATENADO = @Cod_P                                        
                                      
  PRINT 'Sacamos el valor del Documento de Servicio Devengado'                                      
                                      
 END                        
ELSE IF (@Cd_TM = '32')                        
BEGIN                                      
 SET @Cd_MR = '16'                                       
 SET @NomTabla = 'activo_fijo.VW_ACTIVO_REVALUADO'                                      
 SET @colCodTab = 'C_ID_REVALUACION'                        
                                       
  SELECT                                       
  TOP(1)                                      
  @Prdo =  SUBSTRING(@RegCtb_P,8,2),                                      
  @FecMov = @ParametroAux2_P,                  
  @Cd_Area = @ParametroAux3_P,                                  
  @UsuCrea = C_USUARIO_REGISTRO,                                      
  @Cd_MdRg = C_CODIGO_MONEDA,                        
  @CamMda = C_TIPO_CAMBIO                        
  FROM                                      
 activo_fijo.VW_ACTIVO_REVALUADO                         
  WHERE C_RUC_EMPRESA=@RucE_P AND C_EJERCICIO= @Ejer_P AND C_ID_REVALUACION=@ParametroAux1_P                        
                                      
  PRINT 'Sacamos el Valor de Revaluación'                                      
END                        
ELSE IF (@Cd_TM = '33')                        
BEGIN                                      
 SET @Cd_MR = '16'                                       
 SET @NomTabla = 'activo_fijo.VW_ACTIVO_DEPRECIACION_REVALUADO'                                      
 SET @colCodTab = 'C_ID_DEPRECIACION_REVALUACION'                        
                                       
  SELECT                                       
  TOP(1)                                      
  @Prdo =  SUBSTRING(@RegCtb_P,8,2),                                      
  @FecMov = @ParametroAux2_P,                                      
  @Cd_Area = @ParametroAux3_P,                                  
  @UsuCrea = C_USUARIO_REGISTRO,                                      
  @Cd_MdRg = C_CODIGO_MONEDA,                        
  @CamMda = C_TIPO_CAMBIO                        
  FROM                                      
 activo_fijo.VW_ACTIVO_DEPRECIACION_REVALUADO                         
  WHERE C_RUC_EMPRESA=@RucE_P AND C_EJERCICIO= @Ejer_P AND C_ID_DEPRECIACION_REVALUACION=@ParametroAux1_P                        
                                      
  PRINT 'Sacamos el Valor de Revaluación'                                      
END                        
IF @FecED IS NULL                                      
 SET @FecED = @FecMov                                      
                                      
IF ISNULL(@CamMda,0)<= 0                                       
 SET @CamMda = (SELECT TOP 1 ISNULL(TCVta, 1) FROM TipCam WHERE CONVERT(VARCHAR,FecTC,103) = CONVERT(VARCHAR,@FecMov,103) and Cd_Mda='02')          
          
 PRINT ''          
 PRINT '- Cambio Moneda: ' + CONVERT(VARCHAR,@CamMda)                                      
 PRINT ''                  
 PRINT '=============================== INICIO CURSOR ASIENTO ==============================='          
      
DECLARE Cur_Asiento CURSOR FOR                                       
 SELECT Cta, CtaME, IC_JDCtaPA, IC_CaAb, IN_TipoCta, Cd_IV, ISNULL(Porc,0), Fmla, IC_PFI, Glosa, IC_VFG, Cd_CC, Cd_SC, Cd_SS, IC_JDCC,                                      
   IB_Aux, IB_EsDes, Cd_IA, IC_ES,IB_Agrup ,ITEM, C_IB_PROV, C_IB_DEVOLUCION_IGV                                    
 FROM Asiento                             
 WHERE RucE = @RucE_P and Cd_MIS = @Cd_MIS_P and Ejer = @Ejer_P and Cd_TM = @Cd_TM                                      
                                      
OPEN Cur_Asiento                                      
FETCH Cur_Asiento INTO @Cta, @CtaME, @IC_JDCtaPA, @IC_CaAb, @IN_TipoCta, @Cd_IV, @Porc, @Fmla, @IC_PFI, @Glosa_Fmla, @IC_VFG, @Cd_CC, @Cd_SC, @Cd_SS, @IC_JDCC,                                       
   @IB_Aux, @IB_EsDes, @Cd_IA, @IC_ES, @IB_Agrup, @ITEM_ASIENTO, @L_IB_PROV, @L_IB_DEVOLUCION_IGV                                  
                                      
 WHILE (@@FETCH_STATUS = 0)                                      
  BEGIN                                      
   SET @Fmla = REPLACE(@Fmla,'|',' ')                                      
   SET @Glosa_Fmla =  REPLACE(@Glosa_Fmla,'|',' ')                                
                                      
   IF @Cd_MdRg = '01'                                      
    SET @NroCta_Temp = @Cta          
   ELSE                                      
    SET @NroCta_Temp = @CtaME          
          
   SET @NroCta = @NroCta_Temp  
             
   DECLARE @sql NVARCHAR(2000)          
   SELECT @NomCol=NomCol, @IC_DetCab=IC_DetCab FROM IndicadorValor WHERE Cd_IV=@Cd_IV and Cd_TM = @Cd_TM          
   --SELECT NomCol, IC_DetCab,@IC_DetCab FROM IndicadorValor WHERE Cd_IV=@Cd_IV and Cd_TM = @Cd_TM          
             
   PRINT '==================================================='          
   PRINT 'Parametros Cursor Cabecera:'          
   PRINT '- @Cta(' + @Cta + ')'          
   PRINT '- @CtaME('+ @CtaME +')'                
   PRINT '- @NomCol('+ @NomCol +')'          
   PRINT '- @IC_DetCab('+ @IC_DetCab +')'          
   PRINT '- @Glosa_Fmla('+ ISNULL(@Glosa_Fmla,'') +')'          
   PRINT '- @IC_VFG('+ @IC_VFG +')'          
   PRINT '- @Cd_IA('+ ISNULL(@Cd_IA,'')+')'      
   PRINT '- @Cd_TM('+ ISNULL(@Cd_TM,'')+')'      
   PRINT '==================================================='          
             
   IF @IB_Aux = 1                           
    BEGIN                                      
     IF (@Cd_TM='01' or @Cd_TM = '20')                               
      SELECT @Cd_Clt = Cd_Clt FROM VW_VENTAS_CAB WHERE RucE = @RucE_P and Cd_Vta = @Cod_P                                       
     ELSE IF (@Cd_TM='02')                                      
      SELECT @Cd_Prv=Cd_Prv FROM VW_COMPRAS_CAB WHERE RucE=@RucE_P and Cd_Com = @Cod_P                                      
     ELSE IF (@Cd_TM='05')                                       
      SELECT @Cd_Prv=Cd_Prv, @Cd_Clt=Cd_Clt FROM Inventario WHERE RucE=@RucE_P and Ejer=@Ejer_P and RegCtb = @Cod_P                
     ELSE IF (@Cd_TM='08')                                       
      SELECT @Cd_Prv=Cd_Prv FROM CanjePago WHERE RucE=@RucE_P and Cd_Cnj = @Cod_P                                      
     ELSE IF (@Cd_TM='09')                                       
      SELECT @Cd_Clt=Cd_Clt FROM Canje WHERE RucE=@RucE_P and Cd_Cnj = @Cod_P                                      
     ELSE IF (@Cd_TM='10')                                       
      SELECT @Cd_Clt=Cd_Clt FROM ComprobantePercep WHERE RucE=@RucE_P and Ejer = @Ejer_P and Cd_CPercep = @Cod_P                                      
     ELSE IF (@Cd_TM='12')                                       
      SELECT @Cd_Prv=Cd_Prv FROM Compra2_Resumen WHERE RucE=@RucE_P and Cd_Com = @Cod_P                                      
     ELSE IF (@Cd_TM='16')                                       
      BEGIN                                      
       IF (@ParametroAux1_P = '02')                         
        SELECT @Cd_Prv=Cd_Prv FROM Compra2_Resumen WHERE RucE=@RucE_P and Cd_Com = @Cod_P                                      
       ELSE                                      
        SELECT @Cd_Prv=Cd_Prv FROM VW_COMPRAS_CAB WHERE RucE=@RucE_P and Cd_Com = @Cod_P                                      
      END                  
     ELSE IF (@Cd_TM='17')                              
      SELECT @Cd_Prv=C_CODIGO_PROVEEDOR, @Cd_Clt=C_CODIGO_CLIENTE, @Cd_Trab = C_CODIGO_TRABAJADOR FROM Inventario2 WHERE RucE=@RucE_P and Ejercicio=@Ejer_P and RegistroContable = @RegCtb_P                    
     ELSE IF (@Cd_TM='21')                                      
      SELECT @Cd_Prv = Cd_Prv FROM DBO.F_ORDCOMPRA_COMPRA(@RucE_P,@Ejer_P,@Cod_P)--ORDCOMPRA WHERE RUCE = @RucE_P AND CD_OC = @Cod_P                                      
     ELSE IF (@Cd_TM='22')                                      
      SELECT @Cd_Prv = Cd_Prv FROM CanjePago WHERE RucE=@RucE_P and Cd_Cnj = @Cod_P                                      
     ELSE IF (@Cd_TM = '23')                                      
      SELECT TOP 1 @Cd_Clt = C_CODIGO_CLIENTE FROM [DBO].[VW_RETENCION_VENTA] WHERE C_RUC_COMPROBANTE_RETENCION=@RucE_P and C_REGISTRO_CONTABLE = @RegCtb_P                                      
     ELSE IF (@Cd_TM = '25')                                      
      SELECT TOP 1 @Cd_Clt = CODIGO_CLIENTE, @Cd_Prv = CODIGO_PROVEEDOR FROM integracion.VW_RECEPCION_INFORMACION_RESERVA WHERE RUC_EMPRESA = @RucE_P and EJERCICIO = @Ejer_P AND REGISTRO_CONTABLE = @RegCtb_P                                      
     ELSE IF (@Cd_TM = '26')                                      
      SELECT TOP 1 @Cd_Clt = CODIGO_CLIENTE, @Cd_Prv = CODIGO_PROVEEDOR FROM integracion.VW_RECEPCION_INFORMACION_PROVISION WHERE RUC_EMPRESA = @RucE_P and EJERCICIO = @Ejer_P AND REGISTRO_CONTABLE = @RegCtb_P                                      
     ELSE IF (@Cd_TM = '27')                                      
      SELECT TOP 1 @Cd_Clt = CODIGO_CLIENTE, @Cd_Prv = CODIGO_PROVEEDOR FROM integracion.VW_RECEPCION_INFORMACION_COBRANZA WHERE RUC_EMPRESA = @RucE_P and EJERCICIO = @Ejer_P AND REGISTRO_CONTABLE = @RegCtb_P                                      
     ELSE IF (@Cd_TM = '28')                                      
      SELECT TOP 1 @Cd_Clt = CODIGO_CLIENTE, @Cd_Prv = CODIGO_PROVEEDOR FROM integracion.VW_RECEPCION_INFORMACION_PAGO_DIRECTO WHERE RUC_EMPRESA = @RucE_P and EJERCICIO = @Ejer_P AND REGISTRO_CONTABLE = @RegCtb_P                                      
     ELSE IF (@Cd_TM = '29')                        
      SELECT TOP 1 @Cd_Clt = C_CODIGO_CLIENTE, @Cd_Prv = NULL FROM CASINO.VW_LIQUIDACION_MENSUAL WHERE C_RUC_EMPRESA = @RucE_P and C_EJERCICIO = @Ejer_P AND C_ID_LIQUIDACION_MENSUAL_CONTABILIDAD = @Cod_P    --NULL PROVEEDOR POR AHORA                     
  
    
           
    ELSE IF (@Cd_TM = '30')                                    
      SELECT TOP 1 @Cd_Clt = CODIGO_CLIENTE, @Cd_Prv = CODIGO_PROVEEDOR FROM CONTAAPI.VW_PRE_AFILIACION WHERE RUC_EMPRESA = @RucE_P and EJERCICIO = @Ejer_P AND ID_PRE_AFILIACION = @Cod_P                        
    ELSE IF (@Cd_TM = '31')                        
      SELECT TOP 1 @Cd_Clt = CODIGO_CLIENTE FROM CONTAAPI.VW_SERVICIO_DEVENGADO WHERE RUC_EMPRESA = @RucE_P and EJERCICIO = @Ejer_P AND CODIGO_CONCATENADO = @Cod_P                             
    END                                      
   ELSE                                       
    BEGIN                                       
     SET @Cd_Clt = NULL                                      
     SET @Cd_Prv = NULL                            
     SET @Cd_Trab = NULL                              
    END                                      
                        
   IF @L_IB_PROV = 1                          
    BEGIN                                      
     IF (@Cd_TM='01')                                      
      BEGIN                                      
       SELECT @L_ID_CONCEPTO_FEC = C_ID_CONCEPTO_FEC FROM VW_VENTAS_CAB WHERE RucE=@RucE_P and Cd_Vta=@Cod_P                                      
      END                                   
     IF (@Cd_TM='02')                                      
      BEGIN                                      
       SELECT @L_ID_CONCEPTO_FEC = C_ID_CONCEPTO_FEC FROM [dbo].[VW_COMPRAS_CAB] WHERE RucE=@RucE_P and Cd_Com=@Cod_P                                      
      END                                      
     ELSE IF (@Cd_TM='12')                                      
      BEGIN                        
       SELECT @L_ID_CONCEPTO_FEC = C_ID_CONCEPTO_FEC FROM Compra2_Resumen WHERE RucE=@RucE_P and Cd_Com=@Cod_P                                      
      END                                      
     ELSE IF (@Cd_TM='14')                                      
      BEGIN                                      
       SELECT @L_ID_CONCEPTO_FEC = C_ID_CONCEPTO_FEC FROM Liquidacion WHERE RucE=@RucE_P and Cd_Liq=@Cod_P                                      
      END                                      
     ELSE IF (@Cd_TM='16')/*DETRACCION*/                                      
      BEGIN                                      
      print 'DETRACCION' + cast(@L_USO_COMPRAS2 as varchar)                                      
       if(@L_USO_COMPRAS2 = 1)                                     
        SELECT @L_ID_CONCEPTO_FEC = C_ID_CONCEPTO_FEC FROM Compra2_Resumen WHERE RucE=@RucE_P and Cd_Com=@Cod_P                                      
       else                                      
        SELECT @L_ID_CONCEPTO_FEC = C_ID_CONCEPTO_FEC FROM [dbo].[VW_COMPRAS_CAB] WHERE RucE=@RucE_P and Cd_Com=@Cod_P                                      
  END                                           
    END                                      
   ELSE                               
    BEGIN                                      
     SET @L_ID_CONCEPTO_FEC = NULL                                      
    END                                      
       
 SET @L_IB_TransferenciaGratuita = 0               
          
   -- Obtenemos el valor de Forma Pago|Cobro de la provisión.                                      
                                      
   IF (@Cd_TM='01')                                       
    SELECT @Cd_FPC = Cd_FPC FROM VW_VENTAS_CAB WHERE RucE=@RucE_P and Cd_Vta = @Cod_P                                       
                                      
   ELSE IF (@Cd_TM='02')                                       
    SELECT @Cd_FPC = Cd_FPC FROM VW_COMPRAS_CAB WHERE RucE=@RucE_P and Cd_Com = @Cod_P                                      
                        
   ELSE IF (@Cd_TM = '12')                        
     SELECT @Cd_FPC = Cd_FPC FROM Compra2_Resumen WHERE RucE=@RucE_P and Cd_Com=@Cod_P                        
                        
   ELSE IF (@Cd_TM='21')                                      
    SELECT @Cd_FPC = Cd_FPC FROM DBO.F_ORDCOMPRA_COMPRA(@RucE_P,@Ejer_P,@Cod_P)                                      
                                      
   ELSE IF (@Cd_TM='25')                                      
    SELECT TOP 1 @Cd_FPC = CODIGO_FORMA_PAGO FROM integracion.VW_RECEPCION_INFORMACION_RESERVA WHERE RUC_EMPRESA = @RucE_P AND ID_RESERVA_CABECERA = @Cod_P                                      
                                      
   ELSE IF (@Cd_TM='26')                                      
    SELECT TOP 1 @Cd_FPC = CODIGO_FORMA_PAGO FROM integracion.VW_RECEPCION_INFORMACION_PROVISION WHERE RUC_EMPRESA = @RucE_P AND ID_PROVISION = @Cod_P                        
                                      
   ELSE IF (@Cd_TM='27')                                      
    SELECT TOP 1 @Cd_FPC = CODIGO_FORMA_PAGO FROM integracion.VW_RECEPCION_INFORMACION_COBRANZA WHERE RUC_EMPRESA = @RucE_P AND ITEM_CABECERA = @Cod_P                                      
                                      
   ELSE IF (@Cd_TM='28')                                      
    SELECT TOP 1 @Cd_FPC = CODIGO_FORMA_PAGO FROM integracion.VW_RECEPCION_INFORMACION_PAGO_DIRECTO WHERE RUC_EMPRESA = @RucE_P AND ID_PAGO_DIRECTO_CABECERA = @Cod_P                                  
                                  
   ELSE IF (@Cd_TM='29')                                      
    SET @Cd_FPC = '01'                                  
                                      
 ELSE IF (@Cd_TM='30')                                    
    SET @Cd_FPC = '01'                        
                        
 ELSE IF (@Cd_TM='31')                        
    SELECT TOP 1 @Cd_FPC = CODIGO_FORMA_PAGO FROM CONTAAPI.VW_SERVICIO_DEVENGADO WHERE RUC_EMPRESA = @RucE_P AND CODIGO_CONCATENADO = @Cod_P                          
                     
 -- Asignamos el documento si es Inventario (Cabecera)  
 IF (@Cd_TM='17')  
 BEGIN  
  if exists (select 1 from PlanCtas where RucE=@RucE_P and Ejer=@Ejer_P and NroCta=@NroCta and IB_NDoc=1)  
  begin  
   SELECT TOP 1  
    @Cd_TD = COALESCE(gr.Cd_TD,vt.Cd_TD,cp.Cd_TD,cpip.Cd_TD,''),  
    @NroSre = COALESCE(ge.NumSerie,gr.NroSre,vt.NroSre,cp.NroSre,cpip.NroSre),  
    @NroDoc = COALESCE(  
    CASE WHEN ISNULL(ge.NumDocumento,'') != '' THEN CONCAT('GE-',ge.NumDocumento) ELSE  
    CASE WHEN ISNULL(gr.NroGR,'') != '' THEN CONCAT('GR-',gr.NroGR) ELSE  
    CASE WHEN ISNULL(sr.NroSR,'') != '' THEN CONCAT('SR-',sr.NroSR) ELSE  
    CASE WHEN ISNULL(fb.NroOF,'') != '' THEN CONCAT('OF-',fb.NroOF) ELSE  
    NULL END END END END, vt.NroDoc,op.NroOp,cp.NroDoc,oc.NroOC,cpip.NroDoc)  
   FROM  
    MovimientoInventario mi  
    INNER JOIN Inventario2 i on i.RucE=mi.RucE and i.Cd_Inv=mi.Cd_Inv_Destino  
    LEFT JOIN GuiaRemision gr on gr.RucE = mi.RucE AND gr.Cd_GR = mi.Cd_GR_Origen  
    LEFT JOIN Venta vt WITH(NOLOCK) on vt.RucE = mi.RucE AND vt.Cd_Vta = mi.Cd_Vta_Origen  
    LEFT JOIN Compra2 cp on cp.RucE = mi.RucE AND cp.Cd_Com = mi.Cd_Com_Origen  
    LEFT JOIN ImportacionDet ipd on ipd.RucE = mi.RucE AND ipd.Cd_IP = mi.Cd_IP_Origen and ipd.Item = mi.Item_Origen  
    LEFT JOIN Compra2 cpip on cpip.RucE = mi.RucE AND cpip.Cd_Com = ipd.Cd_Com  
    LEFT JOIN GuiaEntrada ge on ge.RucE=mi.RucE AND ge.Cd_GE=mi.Cd_GE_Origen  
    LEFT JOIN OrdPedido op on op.RucE=mi.RucE AND op.Cd_OP=mi.Cd_OP_Origen  
    LEFT JOIN OrdCompra2 oc on oc.RucE=mi.RucE AND oc.Cd_OC=mi.Cd_OC_Origen  
    LEFT JOIN SolicitudReq2 sr on sr.RucE=mi.RucE AND sr.Cd_SR=mi.Cd_SR_Origen  
    LEFT JOIN OrdFabricacion fb on fb.RucE=mi.RucE AND fb.Cd_OF=mi.Cd_OF_Origen  
   WHERE  
    mi.RucE = @RucE_P  
    AND mi.Cd_Inv_Destino=@Cod_P  
  end  
 END  
  
   -- Si es Detalle  
                               
   IF (@IC_DetCab='D') OR (@IC_DetCab='E') OR (@IC_DetCab='T') OR (@IC_DetCab='A') OR (@IC_DetCab='L') OR (@IC_DetCab = 'O') OR (@IC_DetCab='R') OR (@IC_DetCab='M') OR (@IC_DetCab='U') OR (@IC_DetCab = 'Y' AND @Cd_TM ='17')                                
  
   
      
       
    BEGIN                                      
     PRINT '==================== INICIO SUB_CURSOR ' +@NomTabla+ ' DETALLE ===================='          
  PRINT ''          
  PRINT '- Codigo Tipo Movimiento (Cd_TM): ' + @Cd_TM          
  PRINT ''          
          
     IF (@Cd_TM='01' or @Cd_TM = '20')                                       
      DECLARE Cur_TabDet CURSOR FOR SELECT Nro_RegVdt FROM VW_VENTAS_DET WHERE RucE=@RucE_P and Cd_Vta=@Cod_P                                       
     ELSE IF (@Cd_TM='02')                                       
      DECLARE Cur_TabDet CURSOR FOR SELECT Item FROM VW_COMPRAS_DET WHERE RucE=@RucE_P and Cd_Com=@Cod_P                                      
     ELSE IF (@Cd_TM='05')                                       
      BEGIN                                      
       IF (@IC_DetCab = 'D' or @IC_DetCab = 'O')                                      
        BEGIN                                      
         SET @NomTablaDet = 'Inventario'                                       
         SET @colCodTabDet = 'Cd_Inv'                                      
         IF(ISNULL(@IC_ES, 'A') = 'A')                          
          BEGIN                                      
           IF(@IC_Inv = 'M')                                      
            DECLARE Cur_TabDet CURSOR FOR SELECT Cd_Inv FROM Inventario WHERE RucE=@RucE_P and Ejer=@Ejer_P and RegCtb=@Cod_P                                      
           ELSE                                      
            DECLARE Cur_TabDet CURSOR FOR                                       
             SELECT  Id, Cd_Inv FROM Inventario INV INNER JOIN CostoSalidaPEPS CSP ON Inv.RucE = CSP.RucEmp and Inv.Cd_Inv = CSP.Cd_Inv_Salida WHERE RucE = @RucE_P and Ejer = @Ejer_P and INV.RegCtb = @Cod_P                                                
   
   
          END                                      
         ELSE                                        
          BEGIN                                      
           IF(@IC_Inv = 'M')                                      
            DECLARE Cur_TabDet CURSOR FOR SELECT Cd_Inv FROM Inventario WHERE RucE=@RucE_P and Ejer=@Ejer_P and RegCtb=@Cod_P and IC_ES = @IC_ES          
           ELSE                                      
            BEGIN                                      
             IF (@IC_ES = 'S')                                      
              DECLARE Cur_TabDet CURSOR FOR                                       
               SELECT  Id, Cd_Inv FROM Inventario INV INNER JOIN CostoSalidaPEPS CSP ON Inv.RucE = CSP.RucEmp and Inv.Cd_Inv = CSP.Cd_Inv_Salida WHERE RucE = @RucE_P and Ejer = @Ejer_P and INV.RegCtb = @Cod_P                                      
             ELSE                                      
               DECLARE Cur_TabDet CURSOR FOR SELECT Cd_Inv FROM Inventario WHERE RucE=@RucE_P and Ejer=@Ejer_P and RegCtb=@Cod_P                                      
            END                          
          END                                      
        END                                      
       ELSE IF (@IC_DetCab = 'E' or @IC_DetCab = 'R' ) -- Produccion                                      
        BEGIN                                           
         SET @NomTablaDet = 'CptoCostoOFDoc'                                       
         SET @colCodTabDet = 'Cd_OF'                                      
         DECLARE Cur_TabDet CURSOR FOR                                       
          SELECT ''+d.Cd_OF+''' and Id_CCOF = '''+CONVERT(VARCHAR, d.Id_CCOF)+''' and RegCtb = '''+d.RegCtb+''' and NroCta = '''+d.NroCta+''                                       
          FROM CptoCostoOF as c INNER JOIN CptoCostoOFDoc as d on c.RucE = d.RucE and c.Cd_OF = d.Cd_OF and c.Id_CCOF = d.Id_CCOF                                       
          WHERE c.RucE = @RucE_P and c.Cd_OF = (SELECT min(Cd_OF) FROM Inventario WHERE RucE=@RucE_P and Ejer=@Ejer_P and RegCtb=@Cod_P) and ISNULL(c.IB_Eliminado,0)=0                                      
        END                                      
       ELSE IF (@IC_DetCab = 'T' or @IC_DetCab = 'M') -- Fabricacion                                      
        BEGIN                                      
         SET @NomTablaDet = 'FabEtapaComprobante'                                       
         SET @colCodTabDet = 'Cd_Fab'                            
         DECLARE Cur_TabDet CURSOR FOR                                       
          SELECT ''+Cd_Fab+''' and ID_EtaCom = '''+CONVERT(VARCHAR, ID_EtaCom)+''                                 
          FROM FabEtapaComprobante                                       
          WHERE RucE = @RucE_P and Cd_Fab + CONVERT(VARCHAR, ID_Eta) = (SELECT min(Cd_OF+ CONVERT(VARCHAR, Item) ) FROM Inventario WHERE RucE=@RucE_P and Ejer=@Ejer_P and RegCtb=@Cod_P)                                            
        END                                      
       ELSE IF (@IC_DetCab = 'A' or @IC_DetCab = 'U' ) -- Importacion Detalle                                      
        BEGIN                                      
         SET @NomTablaDet = 'ImportacionDet'                                       
         SET @colCodTabDet = 'Cd_IP'                                      
          DECLARE Cur_TabDet CURSOR FOR                                       
          SELECT ''+Cd_IP+''' and Item = '''+CONVERT(VARCHAR, Item)+''                                       
          FROM ImportacionDet                                       
          WHERE RucE = @RucE_P and Cd_IP = (SELECT Cd_IP FROM Importacion WHERE NroImp in (SELECT min(NroDoc) FROM Inventario WHERE RucE=@RucE_P and Ejer=@Ejer_P and RegCtb=@Cod_P))                                      
        END                                      
       ELSE IF (@IC_DetCab = 'L') -- Importacion Gasto                                      
        BEGIN                                      
        SET @NomTablaDet = 'ImpComp'                                       
         SET @colCodTabDet = 'Cd_IP'                                      
         DECLARE Cur_TabDet CURSOR FOR                                       
          SELECT ''+Cd_IP+''' and ItemIC = '''+CONVERT(VARCHAR, ItemIC)+''                                       
          FROM ImpComp                                       
          WHERE RucE = @RucE_P and Cd_IP = (SELECT Cd_IP FROM Importacion WHERE NroImp in (SELECT min(NroDoc) FROM Inventario WHERE RucE=@RucE_P and Ejer=@Ejer_P and RegCtb=@Cod_P))                                      
        END                                      
      END                                       
     ELSE IF (@Cd_TM = '08')                                      
      BEGIN                                      
       IF (@IC_DetCab = 'D' or @IC_DetCab = 'O')                                      
        BEGIN                                      
         DECLARE Cur_TabDet CURSOR FOR                                       
          SELECT Cd_Ltr FROM Letra_Pago WHERE RucE=@RucE_P and Cd_Cnj=@Cod_P            
         SET @NomTablaDet = 'letra.VW_LETRA_PAGO_CON_INF_CAB'                                      
         SET @colCodTabDet = 'Cd_Ltr'                                      
        END                                      
       ELSE IF (@IC_DetCab = 'E' or @IC_DetCab = 'R')                                      
        BEGIN                                      
         DECLARE Cur_TabDet CURSOR FOR                                       
          SELECT Item FROM CanjePagoDet WHERE RucE=@RucE_P and Cd_Cnj=@Cod_P                                       
         SET @NomTablaDet = 'letra.VW_CANJE_PAGO_DET_CON_INF_CAB'                                      
         SET @colCodTabDet = 'Item'                                      
        END                                      
      END                                      
     ELSE IF (@Cd_TM = '09')                                      
      BEGIN                                      
       IF (@IC_DetCab = 'D' or @IC_DetCab = 'O')                                      
        BEGIN                                     
         IF(@IC_Tipo = 'D')                                      
          DECLARE Cur_TabDet CURSOR FOR SELECT Cd_Ltr FROM Letra_Cobro WHERE RucE=@RucE_P and Cd_Cnj=@Cod_P and Cd_Ltr = @Cod_P_Item                                      
         ELSE                                      
          DECLARE Cur_TabDet CURSOR FOR SELECT Cd_Ltr FROM Letra_Cobro WHERE RucE=@RucE_P and Cd_Cnj=@Cod_P                                      
                                      
         SET @NomTablaDet = 'Letra_Cobro'                                      
         SET @colCodTabDet = 'Cd_Ltr'                                      
        END                                      
       ELSE IF (@IC_DetCab = 'E' or @IC_DetCab = 'R')                                      
        BEGIN                                      
         IF(@IC_Tipo = 'D')                                      
          DECLARE Cur_TabDet CURSOR FOR SELECT Item FROM CanjeDet WHERE RucE=@RucE_P and Cd_Cnj=@Cod_P and Cd_Ltr = @Cod_P_Item                                      
         ELSE                                      
          DECLARE Cur_TabDet CURSOR FOR SELECT Item FROM CanjeDet WHERE RucE=@RucE_P and Cd_Cnj=@Cod_P                                       
         SET @NomTablaDet = 'CanjeDet'                                      
         SET @colCodTabDet = 'Item'                                
        END                                      
      END                                      
     ELSE IF (@Cd_TM = '10')                                       
      DECLARE Cur_TabDet CURSOR FOR SELECT Cd_Vta FROM ComprobantePercepDet WHERE RucE=@RucE_P and Cd_CPercep=@Cod_P                                       
     ELSE IF (@Cd_TM = '12')                                       
      DECLARE Cur_TabDet CURSOR FOR SELECT Item FROM CompraDet2_Resumen WHERE RucE=@RucE_P and Cd_Com=@Cod_P                                       
     ELSE IF (@Cd_TM = '13')                                      
      BEGIN                                      
       IF (@IC_DetCab = 'D')                                      
        BEGIN                                      
         DECLARE Cur_TabDet CURSOR FOR                                       
          SELECT ID_EtaIns FROM FabEtaIns WHERE RucE=@RucE_P and Cd_Fab = LEFT(@Cod_P,10) and ID_Eta = RIGHT(@Cod_P,len(@Cod_P)-10) -- HACER PARA TODOS LA VALIDACION                                      
         SET @NomTablaDet = 'FabEtaIns'                                      
         SET @colCodTabDet = 'ID_EtaIns'                                      
        END                           
       ELSE IF (@IC_DetCab = 'E')                                      
        BEGIN                                      
         DECLARE Cur_TabDet CURSOR FOR                                       
          SELECT ID_EtaRes FROM FabEtaRes WHERE RucE=@RucE_P and Cd_Fab = LEFT(@Cod_P,10) and ID_Eta = RIGHT(@Cod_P,len(@Cod_P)-10)                                            
         SET @NomTablaDet = 'FabEtaRes'                                      
         SET @colCodTabDet = 'ID_EtaRes'                                      
        END                                      
       ELSE IF (@IC_DetCab = 'T')                                      
        BEGIN                                      
         DECLARE Cur_TabDet CURSOR FOR                                       
         SELECT ID_EtaCom FROM FabEtapaComprobante WHERE RucE=@RucE_P and Cd_Fab = LEFT(@Cod_P,10) and ID_Eta = RIGHT(@Cod_P,len(@Cod_P)-10)                                      
         SET @NomTablaDet = 'FabEtapaComprobante'                                      
         SET @colCodTabDet = 'ID_EtaCom'                                      
        END                                      
       SET @colCodTab = ' ID_Eta= '+ RIGHT(@Cod_P,len(@Cod_P)-10)+ ' and Cd_Fab '                                       
       SET @Cod_P = LEFT(@Cod_P, 10)                                      
                                      
      END                                      
     ELSE IF (@Cd_TM='14') /*LIQUIDACION DE FONDOS SOLO TRABAJA CON DETALLE*/                      
      DECLARE Cur_TabDet CURSOR FOR SELECT Item FROM LiquidacionDet WHERE RucE=@RucE_P and Cd_Liq=@Cod_P and Item = @Cod_P_Item                                        
     ELSE IF (@Cd_TM='15')                        
      DECLARE Cur_TabDet CURSOR FOR SELECT C_ID_ACTIVO FROM contabilidad.FS_BUSCAR_DEPRECIACION_AGRUPADA(@RucE_P, @Ejer_P, @Cod_P, @ParametroAux1_P)                                      
     ELSE IF (@Cd_TM='17')                                      
   BEGIN        
    IF(@NomCol like 'FabGastoTotal%') /* Se considera para el gasto del comprobante de fabricación */          
  BEGIN          
   DECLARE Cur_TabDet CURSOR FOR          
    SELECT id.Item, id.CD_Fabricacion, id.ID_Etapa, fec.ID_EtaCom          
     FROM Inventario2_Detalle id          
     inner join FabEtapaComprobante fec on fec.RucE=id.RucE and fec.Cd_Fab=id.CD_Fabricacion and fec.ID_Eta=id.ID_Etapa          
     inner join FabComprobante fc on fc.RucE=fec.RucE and fc.Cd_Fab=fec.Cd_Fab and fc.ID_Com=fec.ID_Com          
    WHERE id.RucE = @RucE_P and id.Cd_Inv = @Cod_P and id.Ejercicio = @Ejer_P          
     and CASE WHEN @IC_ES = 'A' THEN '' ELSE id.IC_ES END = CASE WHEN @IC_ES = 'A' THEN '' ELSE @IC_ES END          
     and (id.IC_TipoCostoInventario = @IC_Inv or ISNULL(id.IC_TipoCostoInventario,'') = '')        
  END        
    ELSE IF(@NomCol like 'ProdGastoTotal%') /* Se considera para el gasto del comprobante de producción */  
 BEGIN
  declare  
   Cur_TabDet  
  cursor for  
   select  
    ccof.Cd_OF,  
    ccof.Id_CCOF,
	ccofd.Cd_Vou
   from  
    (  
     select  
      Cd_OF_Origen  
     from  
      MovimientoInventario mi  
      left join Inventario2 i on i.RucE=mi.RucE and i.Cd_Inv=mi.Cd_Inv_Destino  
      left join InventarioDet2 id on id.RucE=mi.RucE and id.Cd_Inv=mi.Cd_Inv_Destino and id.Item=mi.Item_Destino  
     where  
      mi.RucE=@RucE  
      and Cd_Inv_Destino=@Cod_P  
      and i.Ejercicio=@Ejer_P  
      and case when @IC_ES='A' THEN '' ELSE id.IC_ES END = CASE WHEN @IC_ES='A' THEN '' ELSE @IC_ES END  
     group by  
      mi.Cd_OF_Origen  
    ) mi  
    inner join CptoCostoOF ccof on ccof.RucE=@RucE and ccof.Cd_OF=mi.Cd_OF_Origen AND ISNULL(ccof.IB_Eliminado,0)=0  
    inner join CptoCostoOFDoc ccofd on ccofd.RucE=@RucE and ccofd.Cd_OF=ccof.Cd_OF and ccofd.Id_CCOF=ccof.Id_CCOF  
  
  --DECLARE Cur_TabDet CURSOR FOR  
  --SELECT id.Item, id.Cd_OF  
  --FROM Inventario2_Detalle id  
  --inner join OrdFabricacion orf on orf.RucE=id.RucE and orf.Cd_OF=id.Cd_OF  
  --WHERE id.RucE = @RucE_P and id.Cd_Inv = @Cod_P and id.Ejercicio = @Ejer_P  
  --and CASE WHEN @IC_ES = 'A' THEN '' ELSE id.IC_ES END = CASE WHEN @IC_ES = 'A' THEN '' ELSE @IC_ES END  
  --and (id.IC_TipoCostoInventario = @IC_Inv or ISNULL(id.IC_TipoCostoInventario,'') = '')  
 END  
    ELSE        
  BEGIN          
   DECLARE Cur_TabDet CURSOR FOR          
   SELECT Item                                      
   FROM Inventario2_Detalle          
   WHERE RucE = @RucE_P and Cd_Inv = @Cod_P and Ejercicio = @Ejer_P          
   and CASE WHEN @IC_ES = 'A' THEN '' ELSE IC_ES END = CASE WHEN @IC_ES = 'A' THEN '' ELSE @IC_ES END          
   and (IC_TipoCostoInventario = @IC_Inv or ISNULL(IC_TipoCostoInventario,'') = '')          
  END        
   END        
     ELSE IF (@Cd_TM='18')                                      
      DECLARE Cur_TabDet CURSOR FOR SELECT C_ID_ACTIVO_BAJA FROM activo_fijo.VW_T_BAJA_ACTIVO WHERE C_RUC_EMPRESA = @RucE_P and CHARINDEX('[' + CONVERT(VARCHAR,C_ID_ACTIVO_BAJA) + ']', @Cod_P) > 0                                      
                                      
     ELSE IF (@CD_TM = '21')                                      
      DECLARE Cur_TabDet CURSOR FOR SELECT Item FROM DBO.F_ORDCOMPRADET_COMPRA(@RucE_P,@Ejer_P,@Cod_P)                                      
                                      
     ELSE IF (@Cd_TM = '22')                                             
      DECLARE Cur_TabDet CURSOR FOR SELECT Id FROM DBO.VW_LETRA_PAGO_RETENCIONES Where Ruc_Empresa=@RucE_P and Codigo_Canje = @Cod_P and Codigo_Letra = @ParametroAux1_P                                    
     ELSE IF (@Cd_TM = '23')                                       
      BEGIN                                       
       DECLARE Cur_TabDet CURSOR FOR                                       
         SELECT                                      
          C_CODIGO_VENTA                                      
         FROM                                      
          dbo.VW_RETENCION_VENTA                                      
         Where                                      
          C_RUC_COMPROBANTE_RETENCION = @RucE_P AND                                      
          C_REGISTRO_CONTABLE = @RegCtb_P                                      
      END                                      
     ELSE IF (@Cd_TM='25')     
      DECLARE Cur_TabDet CURSOR FOR SELECT ITEM_RESERVA_DETALLE FROM integracion.VW_RECEPCION_INFORMACION_RESERVA WHERE RUC_EMPRESA = @RucE_P and ID_RESERVA_CABECERA = @Cod_P                                                   
     ELSE IF (@Cd_TM='28')                                       
      DECLARE Cur_TabDet CURSOR FOR SELECT ITEM_PAGO_DIRECTO_DETALLE FROM integracion.VW_RECEPCION_INFORMACION_PAGO_DIRECTO WHERE RUC_EMPRESA = @RucE_P and ID_PAGO_DIRECTO_CABECERA = @Cod_P                                      
     ELSE IF (@Cd_TM='29')                                       
      DECLARE Cur_TabDet CURSOR FOR SELECT C_ID_LIQUIDACION_MENSUAL_CONTABILIDAD FROM CASINO.VW_LIQUIDACION_MENSUAL WHERE C_RUC_EMPRESA = @RucE_P and C_ID_LIQUIDACION_MENSUAL_CONTABILIDAD = @Cod_P                                  
     ELSE IF (@Cd_TM='31')                                       
      DECLARE Cur_TabDet CURSOR FOR SELECT CODIGO_CONCATENADO FROM CONTAAPI.VW_SERVICIO_DEVENGADO WHERE RUC_EMPRESA = @RucE_P and CODIGO_CONCATENADO = @Cod_P                        
     ELSE IF (@Cd_TM='32')                        
      DECLARE Cur_TabDet CURSOR FOR SELECT C_ID_REVALUACION FROM activo_fijo.VW_ACTIVO_REVALUADO WHERE C_RUC_EMPRESA=@RucE_P AND C_EJERCICIO= @Ejer_P AND C_ID_REVALUACION=@ParametroAux1_P       
     ELSE IF (@Cd_TM='33')                        
      DECLARE Cur_TabDet CURSOR FOR SELECT C_ID_DEPRECIACION_REVALUACION FROM activo_fijo.VW_ACTIVO_DEPRECIACION_REVALUADO WHERE C_RUC_EMPRESA=@RucE_P AND C_EJERCICIO= @Ejer_P AND C_ID_DEPRECIACION_REVALUACION=@ParametroAux1_P                         
                         
           
     PRINT '==================== ABRIMOS EL CURSOR DETALLE ===================='                
     OPEN Cur_TabDet                                      
                                      
     /* :::::::::::::::::::::  FETCH Del Detalle ::::::::::::::::::::: */                                      
                 
 IF(@Cd_TM = '05')                                      
  BEGIN                                       
   IF(@IC_Inv = 'M')                                      
    FETCH Cur_TabDet INTO @Cod_P_Item                                      
   ELSE                                      
    BEGIN                                      
     IF(@IC_ES = 'S')                                      
      FETCH Cur_TabDet INTO @Cod_P_Item_Peps, @Cod_P_Item                                      
     ELSE                                      
      FETCH Cur_TabDet INTO @Cod_P_Item                                      
    END          
  END          
 ELSE IF(@Cd_TM = '17' and @NomCol like 'FabGastoTotal%')          
  BEGIN          
   FETCH Cur_TabDet INTO @Cod_P_Item, @CD_Fabricacion, @ID_Etapa, @ID_FabItem          
  END  
 ELSE IF(@Cd_TM = '17' and @NomCol like 'ProdGastoTotal%')  
 BEGIN  
  --FETCH Cur_TabDet INTO @Cod_P_Item, @CD_Produccion  
  FETCH Cur_TabDet INTO @CD_Produccion,@Id_CCOF,@Cd_Vou_CCOF
 END  
 ELSE  
   FETCH Cur_TabDet INTO @Cod_P_Item        
          
     /* :::::::::::::::::::::  FETCH Del Detalle Fin ::::::::::::::::::::: */                                      
                                      
     WHILE (@@FETCH_STATUS = 0)                                      
     BEGIN                        
           
 IF @IB_Aux = 1                            
  BEGIN                                      
   IF (@Cd_TM='01')                                       
    SELECT @Cd_Clt=Cd_Clt FROM VW_VENTAS_CAB WHERE RucE=@RucE_P and Cd_Vta = @Cod_P                                       
   ELSE IF (@Cd_TM='02')                                       
    SELECT @Cd_Prv=Cd_Prv FROM VW_COMPRAS_CAB WHERE RucE=@RucE_P and Cd_Com = @Cod_P                  
   ELSE IF (@Cd_TM='05')                                       
    SELECT @Cd_Prv=Cd_Prv, @Cd_Clt=Cd_Clt FROM Inventario WHERE RucE=@RucE_P and Ejer=@Ejer_P and RegCtb = @Cod_P                                       
   ELSE IF (@Cd_TM='08')                                       
    SELECT @Cd_Prv=Cd_Prv FROM CanjePago WHERE RucE=@RucE_P and Cd_Cnj = @Cod_P                                      
   ELSE IF (@Cd_TM='09')                                       
    SELECT @Cd_Clt=Cd_Clt FROM Canje WHERE RucE=@RucE_P and Cd_Cnj = @Cod_P                                      
   ELSE IF (@Cd_TM='10')                                       
    SELECT @Cd_Clt=Cd_Clt FROM ComprobantePercep WHERE RucE=@RucE_P and Ejer = @Ejer_P and Cd_CPercep = @Cod_P                                      
   ELSE IF (@Cd_TM='12')                                       
    SELECT @Cd_Prv = Cd_Prv FROM Compra2_Resumen WHERE RucE = @RucE_P and Cd_Com = @Cod_P                                      
   ELSE IF(@Cd_TM='14')                                      
    SELECT @Cd_Prv=Cd_Prv, @Cd_Clt = Cd_Clt, @Cd_Trab = Cd_Trab FROM LiquidacionDet WHERE RucE=@RucE_P and Cd_Liq = @Cod_P and Item = @Cod_P_Item          
   ELSE IF(@Cd_TM='17')                                      
    SELECT @Cd_Prv=C_CODIGO_PROVEEDOR, @Cd_Clt = C_CODIGO_CLIENTE, @Cd_Trab = C_CODIGO_TRABAJADOR FROM Inventario2 WHERE RucE=@RucE_P and Cd_Inv = @Cod_P    
   ELSE IF(@CD_TM='21')                         
    SELECT @CD_PRV = CD_PRV FROM DBO.F_ORDCOMPRA_COMPRA(@RucE_P,@Ejer_P,@Cod_P)--ORDCOMPRA WHERE RUCE = @RucE_P AND CD_OC = @Cod_P                                      
   ELSE IF(@CD_TM='22')                                      
    SELECT @CD_PRV = CD_PRV FROM CanjePago WHERE RucE = @RucE_P AND Cd_Cnj = @Cod_P                                      
   ELSE IF(@CD_TM='23')                                      
    SELECT @Cd_Clt = C_CODIGO_CLIENTE FROM VW_RETENCION_VENTA WHERE C_RUC_COMPROBANTE_RETENCION = @RucE_P AND C_CODIGO_VENTA = @Cod_P_Item                                               
   ELSE IF(@CD_TM='25')                                      
    SELECT TOP 1 @Cd_Clt = CODIGO_CLIENTE, @Cd_Prv = CODIGO_PROVEEDOR FROM integracion.VW_RECEPCION_INFORMACION_RESERVA WHERE RUC_EMPRESA = @RucE_P AND ID_RESERVA_CABECERA = @Cod_P                                      
   ELSE IF(@CD_TM='26')          
    SELECT TOP 1 @Cd_Clt = CODIGO_CLIENTE, @Cd_Prv = CODIGO_PROVEEDOR FROM integracion.VW_RECEPCION_INFORMACION_PROVISION WHERE RUC_EMPRESA = @RucE_P AND ID_PROVISION = @Cod_P                                      
   ELSE IF(@CD_TM='28')                                      
    SELECT TOP 1 @Cd_Clt = CODIGO_CLIENTE, @Cd_Prv = CODIGO_PROVEEDOR FROM integracion.VW_RECEPCION_INFORMACION_PAGO_DIRECTO WHERE RUC_EMPRESA = @RucE_P AND ID_PAGO_DIRECTO_CABECERA = @Cod_P                                      
   ELSE IF(@CD_TM='29')                                      
    SELECT TOP 1 @Cd_Clt = C_CODIGO_CLIENTE, @Cd_Prv = null FROM CASINO.VW_LIQUIDACION_MENSUAL WHERE C_RUC_EMPRESA = @RucE_P AND C_ID_LIQUIDACION_MENSUAL_CONTABILIDAD = @Cod_P -- NULL PROVEEDOR POR AHORA                                  
   ELSE IF(@CD_TM='30')                                    
    SELECT TOP 1 @Cd_Clt = CODIGO_CLIENTE, @Cd_Prv = CODIGO_PROVEEDOR FROM ContaApi.VW_PRE_AFILIACION WHERE RUC_EMPRESA = @RucE_P AND ID_PRE_AFILIACION = @Cod_P                        
   ELSE IF(@CD_TM='31')                        
    SELECT TOP 1 @Cd_Clt = CODIGO_CLIENTE FROM CONTAAPI.VW_SERVICIO_DEVENGADO WHERE RUC_EMPRESA = @RucE_P AND CODIGO_CONCATENADO = @Cod_P                              
  END                                      
    ELSE                                       
  BEGIN                                       
   SET @Cd_Clt = NULL          
   SET @Cd_Prv = NULL          
   SET @Cd_Trab = NULL          
  END          
                                      
      --==================================================================                                      
                                      
      DECLARE @Cd_Doc VARCHAR(10)                                      
                                      
      IF (@Cd_TM = '08')                                      
       BEGIN                                      
        IF(@NomTablaDet = 'letra.VW_CANJE_PAGO_DET_CON_INF_CAB')             
         BEGIN                                  
          --SET @IB_EsProv = 0                                      
                                  
          SELECT @L_ID_CONCEPTO_FEC = C_ID_CONCEPTO_FEC FROM CanjePagoDet WHERE RucE = @RucE_P and Cd_Cnj = @Cod_P and Item = @Cod_P_Item                                
                                
          SELECT @Cd_Doc = ISNULL(Cd_Com, ISNULL(CONVERT(VARCHAR, Cd_Vou), 'L'+CONVERT(VARCHAR, Cd_Ltr))) FROM letra.VW_CANJE_PAGO_DET_CON_INF_CAB                                       
          WHERE RucE = @RucE_P and Cd_cnj = @Cod_P and Item = @Cod_P_Item                                      
          IF(LEFT(@Cd_Doc,2) = 'CM')                                      
           BEGIN                                       
            IF (@L_USO_COMPRAS2 = 0)                                      
             SELECT @Cd_TD = Cd_TD, @NroSre = NroSre, @NroDoc = NroDoc FROM VW_COMPRAS_CAB WHERE RucE = @RucE_P and Cd_Com = @Cd_Doc                                      
            ELSE                                      
             SELECT @Cd_TD = Cd_TD, @NroSre = NroSre, @NroDoc = NroDoc FROM Compra2_Resumen WHERE RucE = @RucE_P and Cd_Com = @Cd_Doc                                      
           END                                      
          ELSE IF (LEFT(@Cd_Doc,1) = 'L')                                      
           SELECT @Cd_TD = Cd_TD, @NroSre = NULL, @NroDoc = ISNULL(NroRenv, '')+ NroLtr FROM letra.VW_LETRA_PAGO_CON_INF_CAB                                 
            WHERE RucE = @RucE_P and Cd_Ltr = RIGHT(@Cd_Doc, len(@Cd_Doc)-1)                                      
          ELSE                                      
           SELECT @Cd_TD = Cd_TD, @NroSre = NroSre, @NroDoc = NroDoc FROM Voucher WHERE RucE = @RucE_P and Cd_Vou = @Cd_Doc                                      
         END                                      
        ELSE -- IF(@NomTablaDet = 'Letra_Pago')                                      
         SELECT @Cd_TD = Cd_TD, @NroSre = NULL, @NroDoc = ISNULL(NroRenv, '')+ NroLtr FROM                                       
         letra.VW_LETRA_PAGO_CON_INF_CAB WHERE RucE = @RucE_P and Cd_cnj = @Cod_P and Cd_Ltr = @Cod_P_Item                                      
                                      
        IF (@NomTablaDet = 'letra.VW_LETRA_PAGO_CON_INF_CAB')                                      
         SELECT @FecVD = CONVERT(SMALLDATETIME, FecVenc) FROM letra.VW_LETRA_PAGO_CON_INF_CAB WHERE RucE=@RucE_P and Cd_Cnj=@Cod_P and Cd_Ltr = @Cod_P_Item                                               
       END                                       
      ELSE IF (@Cd_TM = '09')                                      
       BEGIN                                      
        IF(@NomTablaDet = 'CanjeDet')                                      
         BEGIN                                      
          --SET @IB_EsProv = 0                                      
                                 
   SELECT @L_ID_CONCEPTO_FEC = C_ID_CONCEPTO_FEC FROM CanjeDet WHERE RucE = @RucE_P and Cd_Cnj = @Cod_P and item = @Cod_P_Item                                       
                                
   SELECT @Cd_Doc = ISNULL(Cd_Vta, ISNULL(CONVERT(VARCHAR, Cd_Vou), 'L'+CONVERT(VARCHAR, Cd_Ltr))) FROM CanjeDet WHERE RucE = @RucE_P and Cd_cnj = @Cod_P and Item = @Cod_P_Item                                      
                                      
          IF(LEFT(@Cd_Doc,2) = 'VT')                        
           SELECT @Cd_TD = Cd_TD, @NroSre = NroSre, @NroDoc = NroDoc, @DR_NDoc = DR_NDoc, @DR_CdTD = DR_CdTD, @DR_NSre = DR_NSre FROM VW_VENTAS_CAB WHERE RucE = @RucE_P and Cd_Vta = @Cd_Doc                                  
     ELSE IF (LEFT(@Cd_Doc,1) = 'L')  
           SELECT @Cd_TD = Cd_TD, @NroSre = NULL, @NroDoc = ISNULL(NroRenv, '')+ NroLtr FROM Letra_Cobro WHERE RucE = @RucE_P and Cd_Ltr = RIGHT(@Cd_Doc, len(@Cd_Doc)-1)                                      
          ELSE                     
           SELECT @Cd_TD = Cd_TD, @NroSre = NroSre, @NroDoc =NroDoc FROM CanjeDet WHERE RucE = @RucE_P and Cd_cnj = @Cod_P and item = @Cod_P_Item  
         END                                      
        ELSE                        
         SELECT @Cd_TD = Cd_TD, @NroSre = NULL, @NroDoc = ISNULL(NroRenv, '') + NroLtr FROM Letra_Cobro WHERE RucE = @RucE_P and Cd_cnj = @Cod_P and Cd_Ltr = @Cod_P_Item                                      
                                      
        IF (@NomTablaDet = 'Letra_Cobro')                                      
   --SELECT @FecVD ='05-05-2025'-- CONVERT(SMALLDATETIME, FecVenc) FROM Letra_Cobro WHERE RucE=@RucE_P and Cd_Cnj=@Cod_P and Cd_Ltr = @Cod_P_Item                                       
     
   SELECT @FecVD =  CONVERT(SMALLDATETIME, FecVenc) FROM Letra_Cobro WHERE RucE=@RucE_P and Cd_Cnj=@Cod_P and Cd_Ltr = @Cod_P_Item                                       
   SELECT @FecMov =  CONVERT(SMALLDATETIME, FecGiro) FROM Letra_Cobro WHERE RucE=@RucE_P and Cd_Cnj=@Cod_P and Cd_Ltr = @Cod_P_Item   
     
  --PRINT 'LETRA CANJE 1'  
  
    END                                      
      ELSE IF (@Cd_TM = '10')                                  
       BEGIN  
  --(100464)  
        --SELECT @DR_CdTD = B.Cd_TD, @DR_NSre = B.NroSre, @DR_NDoc = B.NroDoc   
  SELECT   
   @Cd_TD = B.Cd_TD, @NroSre = B.NroSre, @NroDoc = B.NroDoc  
   ,@DR_CdTD = '40', @DR_NSre = C.NroSre, @DR_NDoc = C.NroDoc  
  FROM   
   ComprobantePercepDet A   
   INNER JOIN venta B WITH(NOLOCK) ON A.RucE = B.RucE AND A.Cd_Vta = B.Cd_Vta   
   INNER JOIN ComprobantePercep C ON A.RucE = C.RucE AND A.Cd_CPercep = C.Cd_CPercep  
  WHERE   
   A.RucE = @RucE_P AND A.Cd_CPercep = @Cod_P AND A.Cd_Vta = @Cod_P_Item  
       END                                 
      ELSE IF (@Cd_TM = '13')             
       BEGIN                                      
        IF(@NomTablaDet = 'FabEtapaComprobante')                                      
         SELECT @Cd_TD = Cd_TD, @NroSre = NroSre, @NroDoc = NroDoc FROM FabComprobante WHERE RucE = @RucE_P and Cd_Fab = @Cod_P and ID_Com = @Cod_P_Item                                      
       END                                      
      ELSE IF(@Cd_TM = '14' and @IB_Aux = 1)                                      
  BEGIN                                      
   SELECT @Cd_TD=Cd_TD, @NroSre = NroSre, @NroDoc = NroDoc  FROM LiquidacionDet WHERE RucE=@RucE_P and Cd_Liq = @Cod_P and Item = @Cod_P_Item                                      
  END  
  ELSE IF(@Cd_TM = '17')  
  BEGIN  
 -- Asignamos el documento si es Inventario (Cabecera)  
 if exists (select 1 from PlanCtas where RucE=@RucE_P and Ejer=@Ejer_P and NroCta=@NroCta and IB_NDoc=1)  
 begin  
  SELECT TOP 1  
   @Cd_TD = COALESCE(gr.Cd_TD,vt.Cd_TD,cp.Cd_TD,cpip.Cd_TD,''),  
   @NroSre = COALESCE(ge.NumSerie,gr.NroSre,vt.NroSre,cp.NroSre,cpip.NroSre),  
   @NroDoc = COALESCE(  
   CASE WHEN ISNULL(ge.NumDocumento,'') != '' THEN CONCAT('GE-',ge.NumDocumento) ELSE  
   CASE WHEN ISNULL(gr.NroGR,'') != '' THEN CONCAT('GR-',gr.NroGR) ELSE  
   CASE WHEN ISNULL(sr.NroSR,'') != '' THEN CONCAT('SR-',sr.NroSR) ELSE  
   CASE WHEN ISNULL(fb.NroOF,'') != '' THEN CONCAT('OF-',fb.NroOF) ELSE  
   NULL END END END END, vt.NroDoc,op.NroOp,cp.NroDoc,oc.NroOC,cpip.NroDoc)  
  FROM  
   MovimientoInventario mi  
   INNER JOIN Inventario2 i on i.RucE=mi.RucE and i.Cd_Inv=mi.Cd_Inv_Destino  
   LEFT JOIN GuiaRemision gr on gr.RucE = mi.RucE AND gr.Cd_GR = mi.Cd_GR_Origen  
   LEFT JOIN Venta vt WITH(NOLOCK) on vt.RucE = mi.RucE AND vt.Cd_Vta = mi.Cd_Vta_Origen  
   LEFT JOIN Compra2 cp on cp.RucE = mi.RucE AND cp.Cd_Com = mi.Cd_Com_Origen  
   LEFT JOIN ImportacionDet ipd on ipd.RucE = mi.RucE AND ipd.Cd_IP = mi.Cd_IP_Origen and ipd.Item = mi.Item_Origen  
   LEFT JOIN Compra2 cpip on cpip.RucE = mi.RucE AND cpip.Cd_Com = ipd.Cd_Com  
   LEFT JOIN GuiaEntrada ge on ge.RucE=mi.RucE AND ge.Cd_GE=mi.Cd_GE_Origen  
   LEFT JOIN OrdPedido op on op.RucE=mi.RucE AND op.Cd_OP=mi.Cd_OP_Origen  
   LEFT JOIN OrdCompra2 oc on oc.RucE=mi.RucE AND oc.Cd_OC=mi.Cd_OC_Origen  
   LEFT JOIN SolicitudReq2 sr on sr.RucE=mi.RucE AND sr.Cd_SR=mi.Cd_SR_Origen  
   LEFT JOIN OrdFabricacion fb on fb.RucE=mi.RucE AND fb.Cd_OF=mi.Cd_OF_Origen  
  WHERE  
   mi.RucE = @RucE_P  
   AND mi.Cd_Inv_Destino=@Cod_P  
 end  
  END  
      ELSE IF(@Cd_TM = '22')                                             
  SELECT @Cd_TD=Codigo_Tipo_Documento, @NroSre = Serie, @NroDoc = Numero_Documento  FROM VW_LETRA_PAGO_RETENCIONES WHERE Ruc_Empresa = @RucE_P and Codigo_Canje = @Cod_P and Id = @Cod_P_Item                                                             
      ELSE IF(@Cd_TM = '23')                                      
       SELECT @Cd_TD= C_TIPO_DOCUMENTO_COMPROBANTE, @NroSre = C_SERIE_COMPROBANTE, @NroDoc = C_NUMERO_COMPROBANTE  FROM DBO.VW_RETENCION_VENTA WHERE C_RUC_COMPROBANTE_RETENCION = @RucE_P and C_CODIGO_VENTA = @Cod_P_Item                                   
  
   
                                      
      ELSE IF(@Cd_TM = '25')                                      
       SELECT TOP 1 @Cd_TD= CODIGO_TIPO_DOCUMENTO, @NroSre = SERIE_DOCUMENTO, @NroDoc = NUMERO_DOCUMENTO  FROM integracion.VW_RECEPCION_INFORMACION_RESERVA WHERE RUC_EMPRESA = @RucE_P and ID_RESERVA_CABECERA = @Cod_P                                      
                                      
      ELSE IF(@Cd_TM = '26')                                      
       SELECT TOP 1 @Cd_TD= CODIGO_TIPO_DOCUMENTO, @NroSre = SERIE_DOCUMENTO, @NroDoc = NUMERO_DOCUMENTO  FROM integracion.VW_RECEPCION_INFORMACION_PROVISION WHERE RUC_EMPRESA = @RucE_P and ID_PROVISION = @Cod_P                                      
                                            
      ELSE IF(@Cd_TM = '28')                                      
       SELECT TOP 1 @Cd_TD= CODIGO_TIPO_DOCUMENTO, @NroSre = SERIE_DOCUMENTO, @NroDoc = NUMERO_DOCUMENTO  FROM integracion.VW_RECEPCION_INFORMACION_PAGO_DIRECTO WHERE RUC_EMPRESA = @RucE_P and ID_PAGO_DIRECTO_CABECERA = @Cod_P                             
  
    
                                  
      ELSE IF(@Cd_TM = '29')                                  
    BEGIN                                
    --ACA EMPIEZA LA JUGADA                                
                                   
    -- @ParametroAux3_P : Tipo de Asiento                                
    IF (@ParametroAux3_P = '01')                                
  BEGIN                                
   SELECT TOP 1                                 
    @Cd_TD = C_CODIGO_TIPO_DOCUMENTO,                                 
    @NroSre = C_SERIE_DOCUMENTO,                               
    @NroDoc = C_NUMERO_DOCUMENTO                                  
   FROM                                 
    CASINO.VW_LIQUIDACION_MENSUAL                                 
   WHERE                                 
    C_RUC_EMPRESA = @RucE_P and C_ID_LIQUIDACION_MENSUAL_CONTABILIDAD = @Cod_P                                
  END                                
    ELSE IF (@ParametroAux3_P = '02')                            
  BEGIN                                
   IF (LEFT(@Cta,2) = '12')                                
    BEGIN                                
     /*Documento de Atribución*/                                
     SET @Cd_TD = '25'                                
                                
     /*CC*/                             
     IF (ISNULL(@ParametroAux4_P,'') != '')                        
   SET @NroSre = (SELECT Valor1 FROM dbo.FN_OBTENER_VALORES_DE_TABLA_SPLIT(@ParametroAux4_P,'-')) --   RIGHT('0' + CONVERT(VARCHAR,MONTH(@FecED)),2)                                
                                
     /*Mes y Año*/                        
     SET @NroDoc = CONCAT(RIGHT('0' + CONVERT(VARCHAR,MONTH(@FecED)),2),CONVERT(VARCHAR,YEAR(@FecED)))                                
    END                                
   ELSE                                
    BEGIN                 
     SELECT TOP 1                                 
   @Cd_TD = C_CODIGO_TIPO_DOCUMENTO,                             
   @NroSre = C_SERIE_DOCUMENTO,                                 
   @NroDoc = C_NUMERO_DOCUMENTO                                  
     FROM                                 
   CASINO.VW_LIQUIDACION_MENSUAL                                 
     WHERE                                 
   C_RUC_EMPRESA = @RucE_P and C_ID_LIQUIDACION_MENSUAL_CONTABILIDAD = @Cod_P                                
    END                                
  END                                
    ELSE IF (@ParametroAux3_P = '03')                                
  BEGIN                                
   /*Documento de Atribución*/                                
   SET @Cd_TD = '00'                                
                                
   /*CC*/                          
   IF (ISNULL(@ParametroAux4_P,'') != '')                        
   SET @NroSre = (SELECT Valor1 FROM dbo.FN_OBTENER_VALORES_DE_TABLA_SPLIT(@ParametroAux4_P,'-')) --   RIGHT('0' + CONVERT(VARCHAR,MONTH(@FecED)),2)                                
                                
   /*Mes y Año*/                                
   SET @NroDoc = CONCAT(RIGHT('0' + CONVERT(VARCHAR,MONTH(@FecED)),2),CONVERT(VARCHAR,YEAR(@FecED)))                                
  END                                
    ELSE IF (@ParametroAux3_P = '04')                                
  BEGIN                                
   IF (@IC_CaAb = 'C')                   
    BEGIN                                
     /*Documento de Atribución*/                                
     SET @Cd_TD = '00'                                
                                
     /*CC*/                                
     IF (ISNULL(@ParametroAux4_P,'') != '')                        
   SET @NroSre = (SELECT Valor1 FROM dbo.FN_OBTENER_VALORES_DE_TABLA_SPLIT(@ParametroAux4_P,'-')) --   RIGHT('0' + CONVERT(VARCHAR,MONTH(@FecED)),2)                                
                                
     /*Mes y Año*/                                
     SET @NroDoc = CONCAT(RIGHT('0' + CONVERT(VARCHAR,MONTH(@FecED)),2),CONVERT(VARCHAR,YEAR(@FecED)))                                
    END                                
   ELSE                                
BEGIN                                
     SELECT TOP 1                                 
   @Cd_TD = C_CODIGO_TIPO_DOCUMENTO,                                 
   @NroSre = C_SERIE_DOCUMENTO,                                 
   @NroDoc = C_NUMERO_DOCUMENTO                                  
     FROM                                 
   CASINO.VW_LIQUIDACION_MENSUAL                                 
     WHERE                                 
   C_RUC_EMPRESA = @RucE_P and C_ID_LIQUIDACION_MENSUAL_CONTABILIDAD = @Cod_P                                
    END                                
  END                                   
   END                                 
                                      
 ELSE IF(@Cd_TM = '30')                                    
       SELECT TOP 1 @Cd_TD= CODIGO_TIPO_DOCUMENTO, @NroSre = SERIE_DOCUMENTO, @NroDoc = NUMERO_DOCUMENTO  FROM CONTAAPI.VW_PRE_AFILIACION WHERE RUC_EMPRESA = @RucE_P and ID_PRE_AFILIACION = @Cod_P                            
                         
 ELSE IF(@Cd_TM = '31')                        
      SELECT TOP 1 @Cd_TD= CODIGO_TIPO_DOCUMENTO_CABECERA, @NroSre = SERIE_DOCUMENTO_CABECERA, @NroDoc = NUMERO_DOCUMENTO_CABECERA  FROM CONTAAPI.VW_SERVICIO_DEVENGADO WHERE RUC_EMPRESA = @RucE_P and CODIGO_CONCATENADO = @Cod_P                         
                                
      PRINT '-Nro de Reg. Detalle: ' + CONVERT(VARCHAR(100), @Cod_P_Item)            
             
   -- SE QUITO PORQUE SOLO APLICA A DCOMIDA MULTIFRANQUICIAS          
   --IF (@Cd_TM = '01' AND @IC_DetCab = 'D'and @RucE_P='20491891336') -- si es venta:                                      
   --    SELECT TOP 1 @L_IB_TransferenciaGratuita = TransferenciaGratuita FROM VW_VENTAS_DET WHERE RucE=@RucE_P and Cd_Vta=@Cod_P and Nro_RegVdt = @Cod_P_Item            
   --ELSE          
   -- SET @L_IB_TransferenciaGratuita = 0          
--==================================================================      
PRINT '=====INICIO CAPTURA CAMPOS ADICIONALES DETALLE====='      
      
BEGIN      
 SELECT      
  @CA01 = CASE WHEN cf.Id_CTb = 480 THEN dbo.FN_CONSULTA_INFORMACION_CAMPO_ADICIONAL(@RucE_P,@Ejer_P,@Cd_TM,@Cod_P,Convert(int,@Cod_P_Item),cf.Id_CtbB) ELSE @CA01 END,       
  @CA02 = CASE WHEN cf.Id_CTb = 481 THEN dbo.FN_CONSULTA_INFORMACION_CAMPO_ADICIONAL(@RucE_P,@Ejer_P,@Cd_TM,@Cod_P,Convert(int,@Cod_P_Item),cf.Id_CtbB) ELSE @CA02 END,       
  @CA03 = CASE WHEN cf.Id_CTb = 482 THEN dbo.FN_CONSULTA_INFORMACION_CAMPO_ADICIONAL(@RucE_P,@Ejer_P,@Cd_TM,@Cod_P,Convert(int,@Cod_P_Item),cf.Id_CtbB) ELSE @CA03 END,       
  @CA04 = CASE WHEN cf.Id_CTb = 483 THEN dbo.FN_CONSULTA_INFORMACION_CAMPO_ADICIONAL(@RucE_P,@Ejer_P,@Cd_TM,@Cod_P,Convert(int,@Cod_P_Item),cf.Id_CtbB) ELSE @CA04 END,       
  @CA05 = CASE WHEN cf.Id_CTb = 484 THEN dbo.FN_CONSULTA_INFORMACION_CAMPO_ADICIONAL(@RucE_P,@Ejer_P,@Cd_TM,@Cod_P,Convert(int,@Cod_P_Item),cf.Id_CtbB) ELSE @CA05 END,       
  @CA06 = CASE WHEN cf.Id_CTb = 485 THEN dbo.FN_CONSULTA_INFORMACION_CAMPO_ADICIONAL(@RucE_P,@Ejer_P,@Cd_TM,@Cod_P,Convert(int,@Cod_P_Item),cf.Id_CtbB) ELSE @CA06 END,       
  @CA07 = CASE WHEN cf.Id_CTb = 486 THEN dbo.FN_CONSULTA_INFORMACION_CAMPO_ADICIONAL(@RucE_P,@Ejer_P,@Cd_TM,@Cod_P,Convert(int,@Cod_P_Item),cf.Id_CtbB) ELSE @CA07 END,       
  @CA08 = CASE WHEN cf.Id_CTb = 487 THEN dbo.FN_CONSULTA_INFORMACION_CAMPO_ADICIONAL(@RucE_P,@Ejer_P,@Cd_TM,@Cod_P,Convert(int,@Cod_P_Item),cf.Id_CtbB) ELSE @CA08 END,       
  @CA09 = CASE WHEN cf.Id_CTb = 488 THEN dbo.FN_CONSULTA_INFORMACION_CAMPO_ADICIONAL(@RucE_P,@Ejer_P,@Cd_TM,@Cod_P,Convert(int,@Cod_P_Item),cf.Id_CtbB) ELSE @CA09 END,       
  @CA10 = CASE WHEN cf.Id_CTb = 489 THEN dbo.FN_CONSULTA_INFORMACION_CAMPO_ADICIONAL(@RucE_P,@Ejer_P,@Cd_TM,@Cod_P,Convert(int,@Cod_P_Item),cf.Id_CtbB) ELSE @CA10 END,       
  @CA11 = CASE WHEN cf.Id_CTb = 490 THEN dbo.FN_CONSULTA_INFORMACION_CAMPO_ADICIONAL(@RucE_P,@Ejer_P,@Cd_TM,@Cod_P,Convert(int,@Cod_P_Item),cf.Id_CtbB) ELSE @CA11 END,       
  @CA12 = CASE WHEN cf.Id_CTb = 491 THEN dbo.FN_CONSULTA_INFORMACION_CAMPO_ADICIONAL(@RucE_P,@Ejer_P,@Cd_TM,@Cod_P,Convert(int,@Cod_P_Item),cf.Id_CtbB) ELSE @CA12 END,       
  @CA13 = CASE WHEN cf.Id_CTb = 492 THEN dbo.FN_CONSULTA_INFORMACION_CAMPO_ADICIONAL(@RucE_P,@Ejer_P,@Cd_TM,@Cod_P,Convert(int,@Cod_P_Item),cf.Id_CtbB) ELSE @CA13 END,       
  @CA14 = CASE WHEN cf.Id_CTb = 493 THEN dbo.FN_CONSULTA_INFORMACION_CAMPO_ADICIONAL(@RucE_P,@Ejer_P,@Cd_TM,@Cod_P,Convert(int,@Cod_P_Item),cf.Id_CtbB) ELSE @CA14 END,       
  @CA15 = CASE WHEN cf.Id_CTb = 494 THEN dbo.FN_CONSULTA_INFORMACION_CAMPO_ADICIONAL(@RucE_P,@Ejer_P,@Cd_TM,@Cod_P,Convert(int,@Cod_P_Item),cf.Id_CtbB) ELSE @CA15 END      
 FROM       
  CfgCampos cf       
  LEFT JOIN CampoTabla ct on cf.Id_CtbB = ct.Id_Ctb      
 WHERE       
  cf.Id_CTb between 480 and 494      
  AND id_CtbB is not null      
  AND ct.Cd_Tab = CASE WHEN @Cd_TM = '17' THEN 'VT28'      
        WHEN @Cd_TM = '12' THEN 'CP30' END      
END      
 --SELECT 'CA08 ' + @CA08      
 --SELECT @RucE_P,@Ejer_P,@Cd_TM,@Cod_P,Convert(int,@Cod_P_Item)--,cf.Id_CtbB      
PRINT '======FIN CAPTURA CAMPOS ADICIONALES DETALLE======='      
--==================================================================      
                                      
 DECLARE @Cod_PProd VARCHAR(10)          
 DECLARE @FabNroCta VARCHAR(50)        
 DECLARE @ProdNroCta VARCHAR(50)        
            
      --==================================================================                                      
                                      
      /* JALAMOS LA CUENTA SEGUN CONFIGURADA                                      
                                            
      P = (PRODUCTO o SERVICIO)     
      A = (AUXILIAR)                                      
      G = (GASTO)                                      
      B = (BANCO)                                      
                                      
      */    
          
      IF @IC_JDCtaPA = 'P'                                       
       BEGIN                                       
        PRINT 'Primero sacamos codigo Producto o Servicio de '+@NomTablaDet+' (Detalle) y registramos en la variable @Cod_PProd'                                      
                  
        IF (@Cd_TM='01') -- si es venta:                                      
        begin                                      
         /* Código de Producto o Servicio, Tipo, Serie y Nro de Documento ANTICIPO */                                               
         select top 1 @Cod_PProd = ISNULL(NULLIF(Cd_Prod,''),Cd_Srv),                                      
           @Cd_TD=ISNULL(va.Cd_TD,v.Cd_TD), @NroSre=ISNULL(va.NroSre,v.NroSre), @NroDoc=ISNULL(va.NroDoc,v.NroDoc)                         
   from Venta v WITH(NOLOCK)                                    
          inner join VW_VENTAS_DET vd on vd.RucE=v.RucE and vd.Cd_Vta=v.Cd_Vta                                      
          left join Venta va WITH(NOLOCK) on va.RucE=v.RucE and vd.Cd_Vta_Ant=va.Cd_Vta                                      
         where v.RucE=@RucE_P and v.Cd_Vta=@Cod_P and Nro_RegVdt=@Cod_P_Item                                               
        end                                      
        ELSE IF (@Cd_TM='02') -- si es compra:                                      
         SELECT @Cod_PProd = ISNULL(NULLIF(Cd_Prod,''),Cd_Srv) FROM VW_COMPRAS_DET WHERE RucE=@RucE_P and Cd_Com=@Cod_P and Item = @Cod_P_Item                                      
        ELSE IF (@Cd_TM='05') -- si es Inventarios:                           
         SELECT @Cod_PProd = Cd_Prod FROM Inventario WHERE RucE=@RucE_P and Ejer=@Ejer_P and RegCtb=@Cod_P and Cd_Inv = @Cod_P_Item                                      
        ELSE IF (@Cd_TM='12') -- si es compra:                                      
         BEGIN
			/* Código de Producto o Servicio, Tipo, Serie y Nro de Documento ANTICIPO */ 
			SELECT 
				@Cod_PProd = ISNULL(NULLIF(Cd_Prod,''),Cd_Srv),
				@Cd_TD= COALESCE(C_CODIGO_TIPO_DOCUMENTO_ANTICIPO, @Cd_TD, ''),
				@NroSre= COALESCE(C_SERIE_ANTICIPO, @NroSre, ''),
				@NroDoc= COALESCE(C_NUMERO_DOCUMENTO_ANTICIPO, @NroDoc, '')				
			FROM CompraDet2_Resumen WHERE RucE=@RucE_P and Cd_Com=@Cod_P and Item = @Cod_P_Item                                      
		END
        ELSE IF (@Cd_TM='13')                                      
         BEGIN                                      
          DECLARE @sql2 NVARCHAR(1000) = 'SELECT @Cd_Prod = Cd_Prod FROM '+@NomTablaDet+' WHERE RucE= '''+@RucE_P+''' and '+@colCodTab+'= '''+@Cod_P + ''' and '+@colCodTabDet+'= '''+CONVERT(VARCHAR(100),@Cod_P_Item)+''''                                
          EXEC sp_EXECutesql @sql2, N'@Cd_Prod VARCHAR(10) OUTPUT', @Cod_PProd OUTPUT                                                       
         END                                      
        ELSE IF(@Cd_TM='14')                                      
         SELECT @Cod_PProd = ISNULL(NULLIF(Cd_Prod,''),Cd_Srv) FROM LiquidacionDet WHERE RucE=@RucE_P and Cd_Liq=@Cod_P and Item = @Cod_P_Item                                      
        ELSE IF (@Cd_TM='15')                                      
         SELECT @Cod_PProd = C_CODIGO_PRODUCTO FROM contabilidad.FS_BUSCAR_DEPRECIACION_AGRUPADA(@RucE_P, @Ejer_P, @Cod_P, @ParametroAux1_P) WHERE C_ID_ACTIVO = @Cod_P_Item                                      
        ELSE IF (@Cd_TM = '17')          
     begin          
   IF(@NomCol like 'FabGastoTotal%') /* Se considera para el gasto del comprobante de fabricación */          
    BEGIN          
     SELECT @Cod_PProd = fer.Cd_Prod, @FabNroCta=fc.NroCta          
      FROM FabEtapaComprobante fec          
    inner join FabComprobante fc on fc.RucE=fec.RucE and fc.Cd_Fab=fec.Cd_Fab and fc.ID_Com=fec.ID_Com          
    inner join FabEtaRes fer on fer.RucE=fec.RucE and fer.Cd_Fab=fec.Cd_Fab and fer.ID_Eta=fec.ID_Eta          
     WHERE fec.RucE = @RucE_P and fec.Cd_Fab=@CD_Fabricacion and fec.ID_Eta = @ID_Etapa and fec.ID_EtaCom = @ID_FabItem --Se agregó NroCta para comprobante de fabricación          
    END  
 ELSE IF(@NomCol like 'ProdGastoTotal%') /* Se considera para el gasto del comprobante de producción */  
    BEGIN  
  SELECT  
   @Cod_PProd=prd.Cd_Prod,  
   @ProdNroCta=fc.NroCta  
  FROM  
   OrdFabricacion prd  
   inner join CptoCostoOFDoc fc on fc.RucE=prd.RucE and fc.Cd_OF=prd.Cd_OF  
   inner join CptoCostoOF cc on cc.Ruce=fc.RucE and cc.Cd_OF=fc.Cd_OF and cc.Id_CCOF=fc.Id_CCOF and ISNULL(cc.IB_Eliminado,0)=0  
  WHERE  
   prd.RucE = @RucE_P  
   and prd.Cd_OF=@CD_Produccion  
   and cc.Id_CCOF=@Id_CCOF
   and fc.Cd_Vou=@Cd_Vou_CCOF
    END  
   ELSE  
    SELECT @Cod_PProd = Cd_Prod FROM Inventario2_Detalle WHERE RucE = @RucE_P and Ejercicio = @Ejer_P and Cd_Inv = @Cod_P and CONVERT(INT,Item) = @Cod_P_Item --Se agregó NroCta para comprobante de fabricación        
     end          
        ELSE IF (@Cd_TM = '18')                                      
         SELECT @Cod_PProd = C_CODIGO_PRODUCTO FROM activo_fijo.VW_T_BAJA_ACTIVO WHERE C_RUC_EMPRESA = @RucE_P and C_EJERCICIO_BAJA = @Ejer_P and C_ID_ACTIVO_BAJA = CONVERT(INT,REPLACE(REPLACE(@Cod_P,'[',''),']','')) --@Cod_P                             
  
    
      
        ELSE IF(@CD_TM = '21')                                      
         SELECT @Cod_PProd = ISNULL(NULLIF(Cd_Prod,''),Cd_Srv) FROM DBO.F_ORDCOMPRADET_COMPRA(@RucE_P,@Ejer_P,@Cod_P)                                      
        ELSE IF (@Cd_TM = '25')                                      
         SELECT @Cod_PProd = ISNULL(NULLIF(CODIGO_PRODUCTO,''),CODIGO_SERVICIO) FROM integracion.VW_RECEPCION_INFORMACION_RESERVA WHERE RUC_EMPRESA = @RucE_P and ID_RESERVA_CABECERA = @Cod_P AND ITEM_RESERVA_DETALLE = @Cod_P_Item                          
  
    
                
        ELSE IF (@Cd_TM = '28')                                      
         SELECT @Cod_PProd = ISNULL(NULLIF(CODIGO_PRODUCTO,''),CODIGO_SERVICIO) FROM integracion.VW_RECEPCION_INFORMACION_PAGO_DIRECTO WHERE RUC_EMPRESA = @RucE_P and ID_PAGO_DIRECTO_CABECERA = @Cod_P AND ITEM_PAGO_DIRECTO_DETALLE = @Cod_P_Item           
  
    
      
  ELSE IF (@Cd_TM='32')                        
   SELECT @Cod_PProd = C_CODIGO_PRODUCTO FROM activo_fijo.VW_ACTIVO_REVALUADO WHERE C_RUC_EMPRESA=@RucE_P AND C_EJERCICIO= @Ejer_P AND C_ID_REVALUACION=@ParametroAux1_P                        
  ELSE IF (@Cd_TM='33')                        
   SELECT @Cod_PProd = C_CODIGO_PRODUCTO FROM activo_fijo.VW_ACTIVO_DEPRECIACION_REVALUADO WHERE C_RUC_EMPRESA=@RucE_P AND C_EJERCICIO= @Ejer_P AND C_ID_DEPRECIACION_REVALUACION=@ParametroAux1_P                        
                           
        PRINT 'Codigo Prod: ' + @Cod_PProd                                
                  
        IF @Cod_PProd IS NOT NULL or @Cod_PProd != ''                                      
         BEGIN                                      
          IF LEFT(@Cod_PProd,1) = 'P' --Si es Producto                                      
           BEGIN                                
      IF @IN_TipoCta = '1'                        
    SELECT @NroCta_Temp = Cta1 FROM Producto2 WHERE RucE=@RucE_P and Cd_Prod=@Cod_PProd                                
      ELSE IF @IN_TipoCta = '2'                                 
    SELECT @NroCta_Temp = Cta2 FROM Producto2 WHERE RucE=@RucE_P and Cd_Prod=@Cod_PProd                                
      ELSE IF @IN_TipoCta = '3'                                 
    SELECT @NroCta_Temp = Cta3 FROM Producto2 WHERE RucE=@RucE_P and Cd_Prod=@Cod_PProd                                
      ELSE IF @IN_TipoCta = '4'                                 
    SELECT @NroCta_Temp = Cta4 FROM Producto2 WHERE RucE=@RucE_P and Cd_Prod=@Cod_PProd                                
      ELSE IF @IN_TipoCta = '5'                                 
    SELECT @NroCta_Temp = Cta5 FROM Producto2 WHERE RucE=@RucE_P and Cd_Prod=@Cod_PProd                                
      ELSE IF @IN_TipoCta = '6'                             
    SELECT @NroCta_Temp = Cta6 FROM Producto2 WHERE RucE=@RucE_P and Cd_Prod=@Cod_PProd                                
      ELSE IF @IN_TipoCta = '7'                                 
    SELECT @NroCta_Temp = Cta7 FROM Producto2 WHERE RucE=@RucE_P and Cd_Prod=@Cod_PProd                                
      ELSE IF @IN_TipoCta = '8'                                 
    SELECT @NroCta_Temp = Cta8 FROM Producto2 WHERE RucE=@RucE_P and Cd_Prod=@Cod_PProd                                
      ELSE IF @IN_TipoCta = '9'                                       
    SELECT @NroCta_Temp = Cta9 FROM Producto2 WHERE RucE=@RucE_P and Cd_Prod=@Cod_PProd                                    
      ELSE IF @IN_TipoCta = '10'                                       
    SELECT @NroCta_Temp = Cta10 FROM Producto2 WHERE RucE=@RucE_P and Cd_Prod=@Cod_PProd                                      
      ELSE IF @IN_TipoCta = '11'                                       
    SELECT @NroCta_Temp = Cta11 FROM Producto2 WHERE RucE=@RucE_P and Cd_Prod=@Cod_PProd                                      
      ELSE IF @IN_TipoCta = '12'                                       
    SELECT @NroCta_Temp = Cta12 FROM Producto2 WHERE RucE=@RucE_P and Cd_Prod=@Cod_PProd                                      
           END                                        
          ELSE --Si es Servicio                             
           BEGIN                                      
   IF @IN_TipoCta = '1'                                       
             SELECT @NroCta_Temp = Cta1 FROM Servicio2 WHERE RucE=@RucE_P and Cd_Srv=@Cod_PProd                                      
            ELSE IF @IN_TipoCta = '2'                                       
             SELECT @NroCta_Temp = Cta2 FROM Servicio2 WHERE RucE=@RucE_P and Cd_Srv=@Cod_PProd                                      
            ELSE IF @IN_TipoCta = '3'                                       
             SELECT @NroCta_Temp = Cta3 FROM Servicio2 WHERE RucE=@RucE_P and Cd_Srv=@Cod_PProd                                      
            ELSE IF @IN_TipoCta = '4'                                 
             SELECT @NroCta_Temp = Cta4 FROM Servicio2 WHERE RucE=@RucE_P and Cd_Srv=@Cod_PProd                                      
            ELSE IF @IN_TipoCta = '5'                                       
             SELECT @NroCta_Temp = Cta5 FROM Servicio2 WHERE RucE=@RucE_P and Cd_Srv=@Cod_PProd                                      
    ELSE IF @IN_TipoCta = '6'                                       
             SELECT @NroCta_Temp = Cta6 FROM Servicio2 WHERE RucE=@RucE_P and Cd_Srv=@Cod_PProd                                      
            ELSE IF @IN_TipoCta = '7'                                       
             SELECT @NroCta_Temp = Cta7 FROM Servicio2 WHERE RucE=@RucE_P and Cd_Srv=@Cod_PProd                                      
            ELSE IF @IN_TipoCta = '8'                                       
             SELECT @NroCta_Temp = Cta8 FROM Servicio2 WHERE RucE=@RucE_P and Cd_Srv=@Cod_PProd                       
            ELSE IF @IN_TipoCta = '9'                                       
             SELECT @NroCta_Temp = Cta9 FROM Servicio2 WHERE RucE=@RucE_P and Cd_Srv=@Cod_PProd                                      
            ELSE IF @IN_TipoCta = '10'                                       
             SELECT @NroCta_Temp = Cta10 FROM Servicio2 WHERE RucE=@RucE_P and Cd_Srv=@Cod_PProd                                      
            ELSE IF @IN_TipoCta = '11'                                       
             SELECT @NroCta_Temp = Cta11 FROM Servicio2 WHERE RucE=@RucE_P and Cd_Srv=@Cod_PProd                                      
            ELSE IF @IN_TipoCta = '12'                                       
             SELECT @NroCta_Temp = Cta12 FROM Servicio2 WHERE RucE=@RucE_P and Cd_Srv=@Cod_PProd                                      
           END                                     
         END                                      
               
  END                                      
                                             
      ELSE IF @IC_JDCtaPA = 'A'                                 
       BEGIN                                      
        IF (@Cd_Clt IS NULL or @Cd_Clt = '') and (@Cd_Prv IS NULL or @Cd_Prv = '')                        
         BEGIN                                      
          IF (@Cd_TM='01') -- si es venta:                                      
           SELECT @Cd_Clt=Cd_Clt FROM VW_VENTAS_CAB WHERE RucE=@RucE_P and Cd_Vta = @Cod_P                                       
          ELSE IF (@Cd_TM='02') -- si es compra:                                      
           SELECT @Cd_Prv=Cd_Prv FROM VW_COMPRAS_CAB WHERE RucE=@RucE_P and Cd_Com = @Cod_P                                                 
          ELSE IF (@Cd_TM='05') -- si es Inventario:                                      
           SELECT @Cd_Prv=Cd_Prv, @Cd_Clt=Cd_Clt FROM Inventario WHERE RucE=@RucE_P and Ejer=@Ejer_P and RegCtb = @Cod_P and Cd_Inv = @Cod_P_Item                                      
          ELSE IF (@Cd_TM='08') -- si es Letra:                                      
           SELECT @Cd_Prv=Cd_Prv FROM CanjePago WHERE RucE=@RucE_P and Cd_Cnj = @Cod_P                                      
          ELSE IF (@Cd_TM='09') -- si es Letra:                                      
           SELECT @Cd_Clt=Cd_Clt FROM Canje WHERE RucE=@RucE_P and Cd_Cnj = @Cod_P                                      
          ELSE IF (@Cd_TM='12') -- si es compra:                                      
           SELECT @Cd_Prv=Cd_Prv FROM Compra2_Resumen WHERE RucE=@RucE_P and Cd_Com = @Cod_P                            
          ELSE IF(@CD_TM = '21')                                      
           SELECT @Cd_Prv=Cd_Prv FROM DBO.F_ORDCOMPRA_COMPRA(@RucE_P,@Ejer_P,@Cod_P)--ORDCOMPRA WHERE RucE=@RucE_P and CD_OC = @Cod_P                                      
          ELSE IF(@CD_TM = '22')                                      
           SELECT @Cd_Prv=Cd_Prv FROM CanjePago WHERE RucE = @RucE_P AND Cd_Cnj = @Cod_P                                      
          ELSE IF(@CD_TM = '25')                                      
           SELECT TOP 1 @Cd_Clt=CODIGO_CLIENTE, @Cd_Prv=CODIGO_PROVEEDOR FROM integracion.VW_RECEPCION_INFORMACION_RESERVA WHERE RUC_EMPRESA = @RucE_P AND ID_RESERVA_CABECERA = @Cod_P                                      
          ELSE IF(@CD_TM = '26')                                      
           SELECT TOP 1 @Cd_Clt=CODIGO_CLIENTE, @Cd_Prv=CODIGO_PROVEEDOR FROM integracion.VW_RECEPCION_INFORMACION_PROVISION WHERE RUC_EMPRESA = @RucE_P AND ID_PROVISION = @Cod_P                                      
          ELSE IF(@CD_TM = '28')                                      
           SELECT TOP 1 @Cd_Clt=CODIGO_CLIENTE, @Cd_Prv=CODIGO_PROVEEDOR FROM integracion.VW_RECEPCION_INFORMACION_PAGO_DIRECTO WHERE RUC_EMPRESA = @RucE_P AND ID_PAGO_DIRECTO_CABECERA = @Cod_P                                      
          ELSE IF(@CD_TM = '29')                                      
           SELECT TOP 1 @Cd_Clt=C_CODIGO_CLIENTE, @Cd_Prv=NULL FROM CASINO.VW_LIQUIDACION_MENSUAL WHERE C_RUC_EMPRESA = @RucE_P AND C_ID_LIQUIDACION_MENSUAL_CONTABILIDAD = @Cod_P  --NULL PROVEEDOR POR AHORA                                  
    ELSE IF(@CD_TM = '30')                                    
           SELECT TOP 1 @Cd_Clt=CODIGO_CLIENTE, @Cd_Prv=CODIGO_PROVEEDOR FROM CONTAAPI.VW_PRE_AFILIACION WHERE RUC_EMPRESA = @RucE_P AND ID_PRE_AFILIACION = @Cod_P                     
    ELSE IF(@CD_TM = '31')                        
           SELECT TOP 1 @Cd_Clt=CODIGO_CLIENTE FROM CONTAAPI.VW_SERVICIO_DEVENGADO WHERE RUC_EMPRESA = @RucE_P AND CODIGO_CONCATENADO = @Cod_P                        
  END          
            
        IF @Cd_Clt IS NULL or @Cd_Clt = '' --es Proveedor                                      
         SELECT @NroCta_Temp = CtaCtb FROM Proveedor2 WHERE RucE=@RucE_P and Cd_Prv=@Cd_Prv                                      
        ELSE                    
         SELECT @NroCta_Temp = CtaCtb FROM Cliente2 WHERE RucE=@RucE_P and Cd_Clt=@Cd_Clt                             
       END                                      
            
      ELSE IF @IC_JDCtaPA = 'G'                                      
       BEGIN                                      
        IF (@Cd_TM='05')                                      
         BEGIN                                      
          IF (@IC_DetCab = 'E') or (@IC_DetCab = 'L') -- Producción or Importación                                      
           BEGIN                                      
            SET @sql = 'SELECT @NroCta = NroCta FROM '+@NomTablaDet+' WHERE RucE= '''+@RucE_P+''' and '+@colCodTabDet+'= '''+CONVERT(VARCHAR(100),@Cod_P_Item)+''''                                      
            EXEC sp_EXECutesql @sql, N'@NroCta VARCHAR(15) OUTPUT', @NroCta_Temp OUTPUT                                      
           END                                      
          ELSE IF (@IC_DetCab = 'T') -- Fabricacion                                      
           BEGIN                                      
            DECLARE @Id_Com INT                                      
                                                  
            SET @sql = 'SELECT @Id_Com = Id_Com FROM '+@NomTablaDet+' WHERE RucE= '''+@RucE_P+''' and '+@colCodTabDet+'= '''+CONVERT(VARCHAR(100),@Cod_P_Item)+''''                                      
            PRINT @sql                                      
                                      
            EXEC sp_EXECutesql @sql, N'@Id_Com INT OUTPUT', @Id_Com OUTPUT                                       
            SELECT @NroCta_Temp = NroCta FROM FabComprobante WHERE rucE = @RucE_P and Cd_Fab = (SELECT min(Cd_OF) FROM Inventario WHERE RucE=@RucE_P and Ejer=@Ejer_P and RegCtb=@Cod_P)                                            
           END                                              
         END                                      
       END                                      
      ELSE IF @IC_JDCtaPA ='B'                                      
       BEGIN                                      
        IF(@Cd_TM='14')                                      
         SELECT @NroCta_Temp = b.NroCta                                       
         FROM Liquidacion L INNER JOIN Banco b on l.RucE = b.RucE and l.Itm_BC=b.Itm_BC                                      
         WHERE l.RucE = @RucE_P and b.Ejer=@Ejer_P and l.RegCtb = @RegCtb_P                                      
       END                        
            
      IF (@CD_TM ='08' AND @IC_DetCab = 'E')                                      
       BEGIN                                      
        IF (SELECT ISNULL(CD_MDA,'') FROM CANJEPAGODET WHERE RUCE = @RucE_P AND CD_CNJ = @Cod_P AND Item = @Cod_P_Item) = '01'                                      
         SET @NroCta_Temp = @Cta                        ELSE                                      
         SET @NroCta_Temp = @CtaME                                      
       END                                      
                                      
      IF ISNULL(@NroCta_Temp,'')=''                        
       BEGIN                                      
        IF @Cd_MdRg='01'                                      
         SET @NroCta_Temp = @Cta                                      
        ELSE                                   
         SET @NroCta_Temp = @CtaME                                                
       END                                      
                                      
      IF ISNULL(@NroCta_Temp,'')=''                        
       SET @NroCta_Temp = '999999999'                                      
          
      SET @NroCta = @NroCta_Temp  
      PRINT '-Nro Cta: ' + @NroCta           
              
      IF @IC_VFG='f'                                      
       BEGIN     
      
        IF @CD_TM = '05' and @IC_DetCab != 'D'                                      
         SET @sql = 'SELECT @Glsa_fmDet = '+@Glosa_Fmla+' FROM '+@NomTablaDet+' WHERE RucE= '''+@RucE_P+''' and '+@colCodTabDet+'= '''+CONVERT(VARCHAR(100),@Cod_P_Item)+''''                                      
                                      
      ELSE IF (@CD_TM = '15')                                      
         SET @sql = 'SELECT @Glsa_fmDet = '+@Glosa_Fmla+' FROM '+@NomTabla+' WHERE C_ID_ACTIVO = ''' + @Cod_P_Item + ''''                                      
                          
        ELSE IF (@CD_TM = '18')                                      
         SET @sql = 'SELECT TOP 1 @Glsa_fmDet = '+@Glosa_Fmla+' FROM '+@NomTabla+' WHERE C_ID_ACTIVO = ''' + @Cod_P_Item + ''''                                      
                                              
        ELSE IF (@CD_TM = '22')                                      
         SET @sql = 'SELECT @Glsa_fmDet = '+@Glosa_Fmla+' FROM '+@NomTabla+' WHERE RucE= '''+@RucE_P+''' and '+@colCodTab+'= '''+@ParametroAux1_P+''' and Item = '''+CONVERT(VARCHAR(100),@Cod_P_Item)+''''                                      
                                              
        ELSE IF (@CD_TM = '21')                                      
         SET @sql = 'SELECT TOP 1 @Glsa_fmDet = '+ ISNULL(@Glosa_Fmla,'') +' FROM ' +@NomTablaDet+ ' ('''+@RucE_P+''','''+@Ejer_P+''','''+@Cod_P + ''') WHERE ITEM ='''+CONVERT(VARCHAR(100),@Cod_P_Item)+''''                                      
                                              
        ELSE IF (@CD_TM = '25' OR @CD_TM = '26' OR @CD_TM = '28' OR @CD_TM = '30' OR @CD_TM = '31')                                      
         SET @sql = 'SELECT @Glsa_fmDet = '+@Glosa_Fmla+' FROM '+@NomTablaDet+' WHERE RUC_EMPRESA = '''+@RucE_P+''' and '+@colCodTab+'= '''+@Cod_P + ''' and '+@colCodTabDet+'= '''+CONVERT(VARCHAR(100),@Cod_P_Item)+''''                                  
                                  
        ELSE IF (@CD_TM = '29')                                      
         SET @sql = 'SELECT @Glsa_fmDet = '+@Glosa_Fmla+' FROM '+@NomTablaDet+' WHERE C_RUC_EMPRESA = '''+@RucE_P+''' and '+@colCodTab+'= '''+CONVERT(VARCHAR(100),@Cod_P)+ ''''                                  
                                  
       ELSE IF (@CD_TM = '32')                        
         SET @sql = 'SELECT @Glsa_fmDet = '+@Glosa_Fmla+' FROM '+@NomTabla+' WHERE C_RUC_EMPRESA = '''+@RucE_P+''' AND C_ID_REVALUACION = ''' + @Cod_P_Item + ''''                        
                          
       ELSE IF (@CD_TM = '33')                        
         SET @sql = 'SELECT @Glsa_fmDet = '+@Glosa_Fmla+' FROM '+@NomTabla+' WHERE C_RUC_EMPRESA = '''+@RucE_P+''' AND C_ID_DEPRECIACION_REVALUACION = ''' + @Cod_P_Item + ''''                        
                        
        ELSE                                      
         SET @sql = 'SELECT @Glsa_fmDet = '+@Glosa_Fmla+' FROM '+@NomTablaDet+' WHERE RucE= '''+@RucE_P+''' and '+@colCodTab+'= '''+@Cod_P + ''' and '+@colCodTabDet+'= '''+CONVERT(VARCHAR(100),@Cod_P_Item)+''''                                      
                                               
        EXEC sp_EXECutesql @sql, N'@Glsa_fmDet VARCHAR(500) OUTPUT', @Glosa OUTPUT                                      
                                      
       END                                             
      ELSE                                      
       BEGIN  
        IF(@CD_TM = '23' and ISNULL(@Glosa_Fmla,'') = 'C_GLOSA')                                      
         SELECT @Glosa = C_GLOSA FROM CONCEPTOXMOV WHERE RucE = @Ruce_P and C_REGISTRO_CONTABLE= @RegCtb_P                                      
        ELSE                                      
         SET @Glosa = @Glosa_Fmla                                       
       END                                      
  
    PRINT ''           
       PRINT '-Glosa: ' + @Glosa          
             
      --==================================================================                                      
      IF @IC_JDCC = 'J'                                      
       BEGIN                                      
        IF (@Cd_TM='08')                                      
         BEGIN                                               
          IF(@NomTablaDet = 'letra.VW_CANJE_PAGO_DET_CON_INF_CAB')                                      
           BEGIN                                      
            SET @sql = 'SELECT TOP 1 @CC_obt = Cd_CC_CAB, @SC_obt = Cd_SC_CAB, @SS_obt = Cd_SS_CAB FROM letra.VW_CANJE_PAGO_DET_CON_INF_CAB WHERE RucE= '''+@RucE_P+''' and Cd_cnj = '''+@Cod_P + ''' AND  item = '''+@Cod_P_Item+''''        
           END                                      
          ELSE                                      
           BEGIN                                      
            SET @sql = 'SELECT TOP 1 @CC_obt = Cd_CC, @SC_obt = Cd_SC, @SS_obt = Cd_SS FROM letra.VW_LETRA_PAGO_CON_INF_CAB WHERE RucE= '''+@RucE_P+''' and Cd_cnj = '''+@Cod_P + ''' AND  CD_LTR = '''+@Cod_P_Item+''''                                      
           END                                      
                                                
         END                                      
        ELSE IF (@Cd_TM='09')                                      
         BEGIN                                      
          SET @sql = 'SELECT TOP 1 @CC_obt = Cd_CC, @SC_obt = Cd_SC, @SS_obt = Cd_SS FROM CanjeDet WHERE RucE= '''+@RucE_P+''' and Cd_cnj = '''+@Cod_P + ''' AND  item = '''+@Cod_P_Item+''''                                                
          --PRINT 'SQL --> : ' + @sql                                      
         END                                      
        ELSE IF (@Cd_TM='13')                                      
         BEGIN                                      
          SET @sql = 'SELECT TOP 1 @CC_obt = Cd_CC, @SC_obt = Cd_SC, @SS_obt = Cd_SS FROM ' +@NomTabla+ ' WHERE RucE= '''+@RucE_P+''' and '+@colCodTab+'= '''+@Cod_P + ''''                                      
         END                                              
        ELSE IF (@Cd_TM = '15')                                      
         SET @sql = 'SELECT TOP 1 @CC_obt = C_CENTRO_COSTO_ULTIMO, @SC_obt = C_SUB_CENTRO_COSTO_ULTIMO, @SS_obt = C_SUB_SUB_CENTRO_COSTO_ULTIMO FROM '+@NomTabla+' WHERE C_ID_ACTIVO = ''' + @Cod_P_Item + ''''                                      
                                      
        ELSE IF (@Cd_TM = '18')                                      
         BEGIN                                      
          SET @sql = 'SELECT TOP 1 @CC_obt = C_CENTRO_COSTO_ULTIMO, @SC_obt = C_SUB_CENTRO_COSTO_ULTIMO, @SS_obt = C_SUB_SUB_CENTRO_COSTO_ULTIMO FROM activo_fijo.VW_T_BAJA_ACTIVO WHERE C_RUC_EMPRESA = '''+@RucE_P+''' and                                   
  
   
     
          CHARINDEX(''['' + CONVERT(VARCHAR,C_ID_ACTIVO_BAJA) + '']'', '''+ @Cod_P + ''') > 0'                                      
         END                                      
                                      
        ELSE IF (@Cd_TM = '21')                                      
         SET @sql = 'SELECT TOP 1 @CC_obt = Cd_CC, @SC_obt = Cd_SC, @SS_obt = Cd_SS FROM ' + @NomTablaDet + '('''+@RucE_P+''','''+@Ejer_P+''','''+@Cod_P+''') WHERE '+ @colCodTabDet+'= '''+CONVERT(VARCHAR(100),@Cod_P_Item)+''''                             
  
    
     
         
         
                                      
        ELSE IF (@Cd_TM = '22')                                      
         BEGIN                                       
          --SET @sql = 'SELECT TOP 1 @CC_obt = Cd_CC, @SC_obt = Cd_SC, @SS_obt = Cd_SS FROM CanjePago WHERE Ruce = ''' + @RucE_P + ''' and Cd_Cnj = '''+@Cod_P+''''                                       
          SET @sql = 'SELECT TOP 1 @CC_obt = Centro_Costo_Documento, @SC_obt = Sub_Centro_Costo_Documento, @SS_obt = Sub_Sub_Centro_Costo_Documento FROM VW_LETRA_PAGO_RETENCIONES                                       
            WHERE Ruc_Empresa = '''+@RucE_P+''' AND Codigo_Canje = '''+@Cod_P+''' AND ID = '''+@Cod_P_Item+''''                                      
         END                                      
        ELSE IF (@Cd_TM = '23')                                      
     BEGIN                                      
          SET @sql = 'SELECT TOP 1 @CC_obt = Cd_CC, @SC_obt = Cd_SC, @SS_obt = Cd_SS FROM VW_RETENCION_VENTA WHERE C_RUC_COMPROBANTE_RETENCION = '''+@RucE_P+''' and C_CODIGO_VENTA ='''+@Cod_P_Item +''''                                      
         END                                      
        ELSE IF (@Cd_TM = '25' OR @Cd_TM = '26' OR @Cd_TM = '28' OR @CD_TM = '30' OR @CD_TM = '31')                        
         SET @sql = 'SELECT TOP 1 @CC_obt = CODIGO_CENTRO_COSTOS, @SC_obt = CODIGO_SUB_CENTRO_COSTOS, @SS_obt = CODIGO_SUB_SUB_CENTRO_COSTOS FROM ' +@NomTablaDet+ '                                       
            WHERE RUC_EMPRESA= '''+@RucE_P+''' and '+@colCodTab+'= '''+@Cod_P + ''' and '+@colCodTabDet+'= '''+CONVERT(VARCHAR(100),@Cod_P_Item)+''''                                   
        ELSE IF (@Cd_TM = '29')                                     
           SET @sql = 'SELECT TOP 1 @CC_obt = C_CODIGO_CENTRO_COSTOS, @SC_obt = C_CODIGO_SUB_CENTRO_COSTOS, @SS_obt = C_CODIGO_SUB_SUB_CENTRO_COSTOS FROM ' +@NomTablaDet+ ' WHERE C_RUC_EMPRESA = '''+@RucE_P+''' and '+@colCodTab+'= '''+@Cod_P + ''''       
 
                  
        ELSE IF (@Cd_TM = '32')                                      
         SET @sql = 'SELECT TOP 1 @CC_obt = C_CENTRO_COSTO_ULTIMO, @SC_obt = C_SUB_CENTRO_COSTO_ULTIMO, @SS_obt = C_SUB_SUB_CENTRO_COSTO_ULTIMO FROM '+@NomTabla+' WHERE C_RUC_EMPRESA = '''+@RucE_P+''' and C_ID_REVALUACION = ''' + @Cod_P_Item + ''''       
 
                                
        ELSE IF (@Cd_TM = '33')                        
         SET @sql = 'SELECT TOP 1 @CC_obt = C_CENTRO_COSTO_ULTIMO, @SC_obt = C_SUB_CENTRO_COSTO_ULTIMO, @SS_obt = C_SUB_SUB_CENTRO_COSTO_ULTIMO FROM '+@NomTabla+' WHERE C_RUC_EMPRESA = '''+@RucE_P+''' and C_ID_DEPRECIACION_REVALUACION = ''' + @Cod_P_Item+
  
     
 ''''                                      
  ELSE IF(@Cd_TM = '17' and @NomCol like 'ProdGastoTotal%')  
   SET @sql = 'SELECT TOP 1 @CC_obt=Cd_CC,@SC_obt=Cd_SC,@SS_obt=Cd_SS FROM OrdFabricacion WHERE RucE='''+@RucE_P+''' and Cd_OF='''+@CD_Produccion+''''  
  ELSE  
   SET @sql = 'SELECT TOP 1 @CC_obt = Cd_CC, @SC_obt = Cd_SC, @SS_obt = Cd_SS FROM ' +@NomTablaDet+ ' WHERE RucE= '''+@RucE_P+''' and '+@colCodTab+'= '''+@Cod_P + ''' and '+@colCodTabDet+'= '''+CONVERT(VARCHAR(100),@Cod_P_Item)+''''  
      
        
          
                                     
    EXEC sp_EXECutesql @sql, N'@CC_obt NVARCHAR(8) OUTPUT, @SC_obt NVARCHAR(8) OUTPUT, @SS_obt NVARCHAR(8) OUTPUT', @Cd_CC OUTPUT, @Cd_SC OUTPUT, @Cd_SS OUTPUT  
       END                                      
  
      IF @Cd_CC IS NULL or @Cd_CC = ''                                      
       SET @Cd_CC = '01010101'                                      
      IF @Cd_SC IS NULL or @Cd_SC = ''                                      
       SET @Cd_SC = '01010101'                                      
      IF @Cd_SS IS NULL or @Cd_SS = ''                                      
     SET @Cd_SS = '01010101'                                      
                
      PRINT '--CC: ' + @Cd_CC + ' - '+ + @Cd_SC + ' - '+ + @Cd_SS          
                                      
      --==================================================================                                      
                                      
      IF(@Cd_IA = 'J') -- Si se jala                                      
       BEGIN                                      
        IF (@Cd_TM='01') -- si es venta:                                      
         SELECT @IC_TipAfec = Cd_IAV FROM VW_VENTAS_DET WHERE RucE=@RucE_P and Cd_Vta=@Cod_P and Nro_RegVdt = @Cod_P_Item                                      
          
        ELSE IF (@Cd_TM='02') -- si es compra:                                      
         SELECT @IC_TipAfec = Cd_IA FROM VW_COMPRAS_DET WHERE RucE=@RucE_P and Cd_Com=@Cod_P and Item = @Cod_P_Item                                      
                                      
      ELSE IF (@Cd_TM='12') -- si es compra:                                      
         SELECT @IC_TipAfec = IC_IA FROM CompraDet2_Resumen WHERE RucE=@RucE_P and Cd_Com=@Cod_P and Item = @Cod_P_Item                                      
                                      
       ELSE IF (@Cd_TM='14') -- si es compra:                                      
         SELECT @IC_TipAfec = Cd_IA FROM LiquidacionDet WHERE RucE=@RucE_P and Cd_Liq=@Cod_P and Item = @Cod_P_Item                                      
                                      
        ELSE IF (@Cd_TM='25') -- si es Recepcion Información - Reserva:                                      
         SELECT @IC_TipAfec = CODIGO_INDICADOR_AFECTO_DETALLE FROM integracion.VW_RECEPCION_INFORMACION_RESERVA WHERE RUC_EMPRESA = @RucE_P and ID_RESERVA_CABECERA = @Cod_P and ITEM_RESERVA_DETALLE = @Cod_P_Item                                      
                                      
        ELSE IF (@Cd_TM='26') -- si es Recepcion Información - Provisión:                                      
         SELECT @IC_TipAfec = CODIGO_INDICADOR_AFECTO FROM integracion.VW_RECEPCION_INFORMACION_PROVISION WHERE RUC_EMPRESA=@RucE_P and ID_PROVISION=@Cod_P --and Item_DETALLE = @Cod_P_Item                                      
                                      
        ELSE IF (@Cd_TM='28') -- si es Recepcion Información - Pago Directo:                                      
         SELECT @IC_TipAfec = CODIGO_INDICADOR_AFECTO_DETALLE FROM integracion.VW_RECEPCION_INFORMACION_PAGO_DIRECTO WHERE RUC_EMPRESA = @RucE_P and ID_PAGO_DIRECTO_CABECERA = @Cod_P and ITEM_PAGO_DIRECTO_DETALLE = @Cod_P_Item                             
 
     
      
        
         
                                      
        ELSE                                       
         SET @IC_TipAfec = NULL                                      
  END                                      
      ELSE                                        
       SET @IC_TipAfec = @Cd_IA                                             
                                            
      IF (@Cd_TM='05')                                       
       BEGIN                                      
        IF @IC_DetCab = 'D'                                      
         SELECT @CamMda=ISNULL(CamMda, 1) FROM Inventario WHERE RucE=@RucE_P and Ejer=@Ejer_P and RegCtb=@Cod_P and Cd_Inv = @Cod_P_Item                                      
        IF @IC_DetCab = 'A' or @IC_DetCab = 'L'                                      
         BEGIN                                      
          SELECT @CamMda=ISNULL(CamMda, 1) FROM ImpComp WHERE RucE=@RucE_P and Cd_IP = @Cod_P_Item                                      
         END                                      
       END                                      
                                      
      IF (@Cd_TM='01' and @NomCol = 'Costo')                                       
       SELECT @CamMda = CASE(ISNULL(Costo,0)) WHEN 0 then 1 ELSE Costo / ISNULL(Costo_ME,Costo) END FROM VW_VENTAS_DET WHERE RucE= @RucE_P and Cd_Vta= @Cod_P and Nro_RegVdt= @Cod_P_Item                                      
                                            
      IF (@Cd_TM='08' or @Cd_TM='09')                                      
       BEGIN                                      
        IF @IC_DetCab = 'E'                                      
         SET @sql = 'SELECT @Val = TipCamb FROM '+@NomTablaDet+' WHERE RucE= '''+@RucE_P+''' and '+@colCodTab+'= '''+@Cod_P + ''' and '+@colCodTabDet+'= '''+CONVERT(VARCHAR(100),@Cod_P_Item)+''''                                      
        ELSE                                      
         SET @sql = 'SELECT @Val = TipCam FROM '+@NomTabla +' WHERE RucE= '''+@RucE_P+''' and '+@colCodTab+'= '''+@Cod_P + ''''                                      
                                      
        EXEC sp_EXECutesql @sql, N'@Val NUMERIC(6,3) OUTPUT', @CamMda OUTPUT                                      
       END            
            
 IF @Cd_TM = '17'  
 BEGIN  
  IF (@NomCol like 'ProdGastoTotal%')  
  BEGIN  
   SELECT @CamMda = ISNULL(Costo/Costo_ME,1) FROM CptoCostoOF WHERE RucE=@RucE_P and Cd_OF=@CD_Produccion and Id_CCOF=@Id_CCOF AND ISNULL(IB_Eliminado,0)=0  
  END  
  ELSE  
  BEGIN  
   SELECT @CamMda = ISNULL(CambioMoneda, 1) FROM Inventario2_Detalle  WHERE RucE = @RucE_P and Cd_Inv = @Cod_P  and Item = @Cod_P_Item  
  END  
  
  --declare @Cd_OF char(10) = (SELECT top 1 Cd_OF FROM Inventario2_Detalle  WHERE RucE = @RucE_P and Cd_Inv = @Cod_P  and Item = @Cod_P_Item)  
  -- IF(@NomCol like 'ProdGastoTotal_%' AND ISNULL(@Cd_OF,'') <>'')        
  --  SELECT @CamMda = ISNULL((select top 1 ProdGastoTotal_MN/ProdGastoTotal_ME from Inventario2_Detalle where RucE=@RucE_P AND Cd_OF=@Cd_OF),1)        
  -- ELSE        
  --  SELECT @CamMda = ISNULL(CambioMoneda, 1) FROM Inventario2_Detalle  WHERE RucE = @RucE_P and Cd_Inv = @Cod_P  and Item = @Cod_P_Item             
 END            
            
 IF (@Cd_TM='22')                                      
 BEGIN                                      
  IF @IC_DetCab = 'E'                                      
   SELECT @CamMda = ISNULL(TipCamb, 1) FROM CanjePagoDet WHERE RucE=@RucE_P and Cd_Cnj = @Cod_P and Item = @Cod_P_Item                                      
        ELSE IF(@IC_DetCab = 'D')                                      
   SELECT @CamMda = ISNULL(Tipo_Cambio_Documento, 1) FROM VW_LETRA_PAGO_RETENCIONES                             
   WHERE Ruc_Empresa=@RucE_P and Codigo_Canje = @Cod_P and Id = @Cod_P_Item                                      
 END                                      
                                      
 IF (@Cd_TM='25')                                      
  SELECT @CamMda = TIPO_CAMBIO FROM integracion.VW_RECEPCION_INFORMACION_RESERVA WHERE RUC_EMPRESA = @RucE_P and ID_RESERVA_CABECERA = @Cod_P and ITEM_RESERVA_DETALLE = @Cod_P_Item                                      
                                      
 IF (@Cd_TM='26')                                      
  SELECT @CamMda = TIPO_CAMBIO FROM integracion.VW_RECEPCION_INFORMACION_PROVISION WHERE RUC_EMPRESA= @RucE_P and ID_PROVISION= @Cod_P --and ITEM_DETALLE= @Cod_P_Item                                      
                                      
 IF (@Cd_TM='28')                                      
  SELECT @CamMda = TIPO_CAMBIO FROM integracion.VW_RECEPCION_INFORMACION_PAGO_DIRECTO WHERE RUC_EMPRESA= @RucE_P and ID_PAGO_DIRECTO_CABECERA = @Cod_P and ITEM_PAGO_DIRECTO_DETALLE = @Cod_P_Item                                
                                  
 IF (@Cd_TM='31')                        
  SELECT @CamMda = TIPO_CAMBIO_DETALLE FROM CONTAAPI.VW_SERVICIO_DEVENGADO WHERE RUC_EMPRESA= @RucE_P and CODIGO_CONCATENADO = @Cod_P                        
                        
 IF (@Cd_TM='32')                            
  SELECT TOP 1 @CamMda = TCVta FROM TipCam WHERE Cd_Mda = @Cd_MdRg AND CONVERT(DATE,FECTC) <= @FecMov ORDER BY YEAR(FecTC) DESC ,MONTH(FECTC) DESC,DAY(FECTC) DESC                                   
                           
 IF (@Cd_TM='33')                        
  SELECT TOP 1 @CamMda = TCVta FROM TipCam WHERE Cd_Mda = @Cd_MdRg AND CONVERT(DATE,FECTC) <= @FecMov ORDER BY YEAR(FecTC) DESC ,MONTH(FECTC) DESC,DAY(FECTC) DESC                                   
                              
      --==================================================================             
      print '-IC_PFI : ' + @IC_PFI  
      IF @IC_PFI='f'  
       BEGIN                                      
        DECLARE @FmlaAux VARCHAR(100)                                      
        SET @FmlaAux = @Fmla                                      
               
        IF (@Cd_TM='01' and @Fmla LIKE '%Costo%' and @Cd_MdRg = '02')                                      
         SET @FmlaAux = REPLACE(@FmlaAux, 'Costo', 'Costo_ME')                                      
        ELSE IF (@Cd_TM='05' and @Fmla LIKE '%CosUnt%' and @Cd_MdRg = '02')                          
         SET @FmlaAux = REPLACE(@FmlaAux, 'CosUnt', 'CosUnt_ME')                                      
        ELSE IF (@Cd_TM='05' and @Fmla LIKE '%Total%' and @Cd_MdRg = '02')                                      
         SET @FmlaAux = REPLACE(@FmlaAux, 'Total', 'Total_ME')                                      
        ELSE IF (@Cd_TM='05' and @Fmla LIKE '%CProm%' and @Cd_MdRg = '02')                                      
         SET @FmlaAux = REPLACE(@FmlaAux, 'CProm', 'CProm_ME')                                      
        ELSE IF (@Cd_TM='05' and @Fmla LIKE '%SCT%' and @Cd_MdRg = '02')                                      
         SET @FmlaAux = REPLACE(@FmlaAux, 'SCT', 'SCT_ME')                                      
        ELSE IF @CD_TM ='05' and @IC_DetCab != 'D'                                      
         BEGIN                                      
          SET @sql = 'SELECT @Val_FmDet = abs(ISNULL('+@FmlaAux+',0)) FROM '+@NomTablaDet+' WHERE RucE= '''+@RucE_P+''' and '+@colCodTabDet+'= '''+CONVERT(VARCHAR(100),@Cod_P_Item)+''''                                      
         END                                      
        ELSE IF (@CD_TM ='25' OR @CD_TM ='26' OR @CD_TM ='28')                                      
         BEGIN        
          SET @sql = 'SELECT @Val_FmDet = ISNULL('+@FmlaAux+',0) FROM '+@NomTablaDet+' WHERE RUC_EMPRESA = '''+@RucE_P+''' and '+@colCodTab+'= '''+@Cod_P + ''' and '+@colCodTabDet+'= '''+CONVERT(VARCHAR(100),@Cod_P_Item)+''''                             
  
    
       
        
          PRINT @sql                                      
         END                                              
        ELSE IF (@CD_TM ='29')                                   
         BEGIN                                      
          SET @sql = 'SELECT @Val_FmDet = ISNULL('+@FmlaAux+',0) FROM '+@NomTablaDet+' WHERE C_RUC_EMPRESA = '''+@RucE_P+''' and '+@colCodTab+'= '''+CONVERT(VARCHAR(100),@Cod_P) + ''''                                   
          PRINT @sql                                      
         END                        
        ELSE IF (@CD_TM ='31')                        
         BEGIN                                      
          SET @sql = 'SELECT @Val_FmDet = ISNULL('+@FmlaAux+',0) FROM '+@NomTablaDet+' WHERE RUC_EMPRESA = '''+@RucE_P+''' and '+@colCodTab+'= '''+CONVERT(VARCHAR(100),@Cod_P) + ''''                        
          PRINT @sql                          
         END                                    
        ELSE                                      
         BEGIN                                      
          SET @sql = 'SELECT @Val_FmDet = ISNULL('+@FmlaAux+',0) FROM '+@NomTablaDet+' WHERE RucE= '''+@RucE_P+''' and '+@colCodTab+'= '''+@Cod_P + ''' and '+@colCodTabDet+'= '''+CONVERT(VARCHAR(100),@Cod_P_Item)+''''                                      
          PRINT @sql                                      
         END                  
        EXEC sp_EXECutesql @sql, N'@Val_FmDet NUMERIC(20,2) OUTPUT', @Val_Cal OUTPUT                                        
       END                                  
 ELSE  
 BEGIN  
  DECLARE @ME VARCHAR(3)  
  SET @ME = ''  
  /*para inventario 2 vamos a coger la columna, según la moneda y columna seleccionada y que no esté relacionada al gasto de fabricación*/  
  IF(@Cd_TM = '17')  
  BEGIN  
   IF(@NomCol like 'FabGastoTotal%') /* Se considera para el gasto del comprobante de fabricación */  
   BEGIN  
    set @NroCta=@FabNroCta  
    set @FabNroCta=null  
   END  
   ELSE IF(@NomCol like 'ProdGastoTotal%') /* Se considera para el gasto del comprobante de producción */  
   BEGIN  
    IF (@IC_JDCtaPA = 'P')  
    BEGIN  
     --Asigna el número de cuenta del último gasto asociado a la OF (solo cuando es jalar por producto)  
     set @NroCta=@ProdNroCta  
     set @ProdNroCta=null  
    END  
   END  
   ELSE  
   BEGIN  
    --Asignamos el nombre de las columnas ME de acuerdo a lo que tiene configurado en el MIS (Indicadores Valores Detalle)  
    IF(@Cd_MdRg = '01')  
    BEGIN  
     IF (@NomCol='FiltroDetalleUnitario')  
     BEGIN  
      set @NomCol = 'Costo_MN'  
      set @NomCol_ME = 'Costo_ME'  
     END  
     ELSE IF (@NomCol='Filtro')  
     BEGIN  
      set @NomCol = 'Total_MN'  
      set @NomCol_ME = 'Total_ME'  
     END  
     ELSE  
     BEGIN  
      SET @NomCol = case when @NomCol like '%_MN' then @NomCol else CONCAT(@NomCol,'_MN') end
      SET @NomCol_ME = CONCAT(LEFT(@NomCol,LEN(@NomCol)-1),'E')  
     END  
     --SET @NomCol = CASE WHEN @NomCol = 'FiltroDetalleUnitario' THEN 'Costo_MN' ELSE 'Total_MN' END  
     --SET @NomCol_ME = CASE WHEN @NomCol = 'FiltroDetalleUnitario' THEN 'Costo_ME' ELSE 'Total_ME' END  
    END  
    ELSE  
    BEGIN  
     IF (@NomCol='FiltroDetalleUnitario')  
     BEGIN  
      set @NomCol = 'Costo_ME'  
      set @NomCol_ME = 'Costo_MN'  
     END  
     ELSE IF (@NomCol='Filtro')  
     BEGIN  
      set @NomCol = 'Total_ME'  
      set @NomCol_ME = 'Total_MN'  
     END  
     ELSE  
     BEGIN  
      SET @NomCol = case when @NomCol like '%_ME' then @NomCol else CONCAT(@NomCol,'_ME') end
	  SET @NomCol_ME = CONCAT(LEFT(@NomCol,LEN(@NomCol)-1),'N')
     END  
     --SET @NomCol = CASE WHEN @NomCol = 'FiltroDetalleUnitario' THEN 'Costo_ME' ELSE 'Total_ME' END  
     --SET @NomCol_ME = CASE WHEN @NomCol = 'FiltroDetalleUnitario' THEN 'Costo_MN' ELSE 'Total_MN' END  
    END  
    print '-Col   : ' + @nomCol  
    print '-ColME : ' + @nomCol_ME  
   END  
  END  
  
         IF ((@Cd_TM='01' and @NomCol = 'Costo' and @Cd_MdRg = '02')           
    or (@Cd_TM='05' and (@NomCol = 'CosUnt' or @NomCol = 'Total' or @NomCol = 'CProm' or @NomCol = 'SCT') and @Cd_MdRg = '02'))                          
         SET @ME = '_ME'                                      
                            
  IF @CD_TM = '05' and @IC_DetCab != 'D'                                      
         SET @sql = 'SELECT @Val_RetDet = abs(ISNULL('+@NomCol+@ME+',0)) FROM '+@NomTablaDet+' WHERE RucE= '''+@RucE_P+''' and '+@colCodTabDet+'= '''+CONVERT(VARCHAR(100),@Cod_P_Item)+''''                                      
  ELSE IF (@CD_TM= '15')                                      
         SET @sql = 'SELECT @Val_RetDet = ISNULL('+@NomCol+',0) FROM '+@NomTabla+'WHERE '+@colCodTab+'= '''+CONVERT(VARCHAR(100),@Cod_P_Item)+''''                                    
 ELSE IF (@Cd_TM = '17')          
  BEGIN          
   IF(@NomCol like 'FabGastoTotal%')          
    SET @sql = 'SELECT @Val_RetDet = ISNULL(CASE WHEN ''' + @Cd_MdRg + ''' = ''01'' THEN CostoAsig ELSE CostoAsig_ME END ,0)       
 from FabEtapaComprobante where RucE= '''+@RucE_P+''' and Cd_Fab= '''+@CD_Fabricacion+''' and ID_Eta= ''' + Convert(varchar, @ID_Etapa) + ''' and ID_EtaCom= ''' + Convert(varchar, @ID_FabItem) + ''' '          
 ELSE IF(@NomCol like 'ProdGastoTotal%')          
 BEGIN  
  --select @RucE_P,@CD_Produccion,@Id_CCOF  
  SET @sql =  
  '  
   select  
    @Val_RetDet = ISNULL(CASE WHEN ''' + @Cd_MdRg + ''' = ''01'' THEN ccofd.CstAsig ELSE ccofd.CstAsig/ccofd.CamMda END,0),  
    @Val_RetDet_ME = ISNULL(CASE WHEN ''' + @Cd_MdRg + ''' = ''01'' THEN ccofd.CstAsig/ccofd.CamMda ELSE ccofd.CstAsig END,0)  
   from  
    CptoCostoOFDoc ccofd
	left join CptoCostoOF ccof on ccof.RucE=ccofd.RucE and ccof.Cd_OF=ccofd.Cd_OF and ccof.Id_CCOF=ccofd.Id_CCOF
   where  
    ccofd.RucE='''+@RucE_P+'''  
    and ccofd.Cd_OF='''+@CD_Produccion+'''  
    and ccofd.Id_CCOF='+@Id_CCOF+'  
	and ccofd.Cd_Vou='+@Cd_Vou_CCOF+'  
    AND ISNULL(ccof.IB_Eliminado,0)=0  
  '  
  
  --SET @sql = 'SELECT @Val_RetDet = ISNULL(CASE WHEN ''' + @NomCol + ''' = ''ProdGastoTotal_MN'' THEN ProdGastoTotal_MN ELSE ProdGastoTotal_ME END ,0),  
  --   @Val_RetDet_ME = ISNULL(CASE WHEN ''' + @NomCol + ''' = ''ProdGastoTotal_MN'' THEN ProdGastoTotal_ME ELSE ProdGastoTotal_MN END ,0) from Inventario2_Cabecera where RucE= '''+@RucE_P+''' and Cd_Inv= '''+@Cod_P+''' '  
 END  
   ELSE          
    SET @sql = 'SELECT @Val_RetDet = ISNULL('+@NomCol+',0), @Val_RetDet_ME = ISNULL('+@NomCol_ME+',0) FROM '+@NomTablaDet+' WHERE RucE= '''+@RucE_P+''' and '+@colCodTab+'= '''+@Cod_P + ''' and '+'CONVERT(INT,'+@colCodTabDet+ ')'+ '= '''+CONVERT(VARCHAR(100),@Cod_P_Item)+''''          
   END        
   ELSE IF (@Cd_TM = '05')                                      
   BEGIN                                      
   IF(@IC_Inv = 'M')          
    SET @sql = 'SELECT @Val_RetDet = abs(ISNULL('+@NomCol+@ME+',0)) FROM '+@NomTablaDet+' WHERE RucE= '''+@RucE_P+''' and '+@colCodTabDet+'= '''+CONVERT(VARCHAR(100),@Cod_P_Item)+''''                                      
   ELSE                                      
    BEGIN        
    IF(@IC_ES = 'S')                                      
     BEGIN                                      
     /*Cuando es PEPS, traerá los costos DistINTOs y eso implica configurar las variables para la consulta.*/                                      
     IF(@Cd_MdRg = '01')                                      
      SET @NomCol = 'CostoUnitarioMN'                                      
     ELSE                                      
      SET @NomCol = 'CostoUnitarioME'        
      SET @sql = 'SELECT @Val_RetDet = abs(ISNULL('+@NomCol+' * CantidadRetirada,0)) FROM CostoSalidaPEPS WHERE RucEmp= '''+@RucE_P+''' and Id = '''+CONVERT(VARCHAR(100),@Cod_P_Item_Peps)+''''                                      
     END                                      
    ELSE                                      
     SET @sql = 'SELECT @Val_RetDet = abs(ISNULL('+@NomCol+@ME+',0)) FROM '+@NomTablaDet+' WHERE RucE= '''+@RucE_P+''' and '+@colCodTabDet+'= '''+CONVERT(VARCHAR(100),@Cod_P_Item)+''''                                      
    END        
   END        
 ELSE IF (@Cd_TM = '18')                                      
   SET @sql = 'SELECT @Val_RetDet = ISNULL('+@NomCol+@ME+',0) FROM '+@NomTablaDet+' WHERE C_RUC_EMPRESA = '''+@RucE_P+''' and CHARINDEX( + ''['' + CONVERT(VARCHAR,'+@colCodTab+' ) + '']'', '''+@Cod_P + ''') > 0'                                            
  
          
 ELSE IF (@CD_TM = '21')                                      
   SET @sql = 'SELECT @Val_RetDet = ISNULL('+@NomCol+@ME+',0) FROM '+@NomTablaDet+' ('''+@RucE_P+''','''+@Ejer_P + ''','''+ @Cod_P + ''') WHERE '+@colCodTabDet+'= '''+CONVERT(VARCHAR(100),@Cod_P_Item)+''''                                                  
  
 ELSE IF (@CD_TM = '22')                                                  
   SET @sql = 'SELECT @Val_RetDet = ISNULL('+@NomCol+@ME+',0) FROM '+@NomTabla+' WHERE Ruc_Empresa = '''+@RucE_P+''' and Codigo_Canje = '''+@Cod_P+''' and Id = '''+CONVERT(VARCHAR(100),@Cod_P_Item)+''''                                       
 ELSE IF (@CD_TM = '23')                                      
   BEGIN                                      
   SET @sql = 'SELECT @Val_RetDet = ISNULL(C_MONTO_COMPROBANTE_RETENCION, 0.00) FROM VW_RETENCION_VENTA WHERE C_RUC_COMPROBANTE_RETENCION = '''+@RucE_P +''' and C_CODIGO_VENTA = '''+@Cod_P_Item+ ''''                                      
   END                                      
 ELSE IF (@CD_TM = '25' OR @CD_TM = '26' OR @CD_TM = '28' OR @CD_TM = '30')                
   BEGIN                                      
   SET @sql = 'SELECT @Val_RetDet = ISNULL('+@NomCol+',0) FROM '+@NomTabla+' WHERE RUC_EMPRESA = '''+@RucE_P+''' AND '+@colCodTab+' = '''+@Cod_P+''' and '+@colCodTabDet+' = '''+@Cod_P_Item+ ''''                                      
   END                                      
 ELSE IF (@CD_TM = '29')                                  
   BEGIN                                      
   SET @sql = 'SELECT @Val_RetDet = ISNULL('+@NomCol+',0) FROM '+@NomTabla+' WHERE C_RUC_EMPRESA = '''+@RucE_P+''' AND '+@colCodTab+' = '''+@Cod_P+''''                                  
   END                        
 ELSE IF (@CD_TM = '31')                        
   BEGIN                                      
   SET @sql = 'SELECT @Val_RetDet = ISNULL('+@NomCol+',0) FROM '+@NomTabla+' WHERE RUC_EMPRESA = '''+@RucE_P+''' AND '+@colCodTab+' = '''+@Cod_P+''''                        
   END                                     
 ELSE                                      
   SET @sql = 'SELECT @Val_RetDet = ISNULL('+@NomCol+@ME+',0) FROM '+@NomTablaDet+' WHERE RucE= '''+@RucE_P+''' and '+@colCodTab+'= '''+@Cod_P + ''' and '+@colCodTabDet+'= '''+CONVERT(VARCHAR(100),@Cod_P_Item)+''''                                      
                  
        IF (ISNULL(@sql, '') <> '' AND @Cd_TM != '17')          
  BEGIN          
   EXEC sp_EXECutesql @sql, N'@Val_RetDet NUMERIC(20,2) OUTPUT', @Val_Cal OUTPUT                            
  END          
  IF (ISNULL(@sql, '') <> '' AND @Cd_TM = '17')          
  BEGIN        
   EXEC sp_EXECutesql @sql, N'@Val_RetDet NUMERIC(20,2) OUTPUT, @Val_RetDet_ME NUMERIC(20,2) OUTPUT', @Val_Cal OUTPUT, @Val_Cal_ME OUTPUT          
  END          
             
        IF(@CD_TM = '22')          
         BEGIN          
          DECLARE @L_CD_MDA NVARCHAR(2) = (SELECT Cd_Mda from CanjePagoDet WHERE RucE = @RucE_P and Cd_Cnj = @Cod_P and Item = @Cod_P_Item)          
          DECLARE @L_TIP_CAMB NUMERIC(6,3) = (SELECT TipCamb from CanjePagoDet WHERE RucE = @RucE_P and Cd_Cnj = @Cod_P and Item = @Cod_P_Item)          
          DECLARE @L_VALOR NUMERIC (20,2)          
                                      
          SET @L_VALOR = CASE WHEN (ISNULL(@Val_Cal,0) = 0) THEN 0 ELSE @Val_Cal END                                      
          SET @Val_Cal = @L_VALOR                                      
         END                                    
                                               
        SET @Val_Cal = @Val_Cal * @Porc/100                                      
       END           
          
   PRINT ''            
      Print '-Tipo cambio : ' + ISNULL(CONVERT(VARCHAR,@CamMda), '0.00')          
      PRINT '-Valor   : ' + CONVERT(VARCHAR,@Val_Cal)          
   PRINT '-ValorME : ' + CONVERT(VARCHAR,@Val_Cal_ME)          
   PRINT ''           
          
        
      IF @IC_CaAb='C'                                      
       BEGIN                                       
        SET @MtoD = @Val_Cal                                      
        SET @MtoH = 0.00          
  SET @MtoD_ME = @Val_Cal_ME  -- SOLO PARA INVENTARIO 2          
        SET @MtoH_ME = 0.00    -- SOLO PARA INVENTARIO 2          
       END                                      
      ELSE --IF @IC_CaAb='A'                                      
       BEGIN                                       
        SET @MtoD = 0.00                                      
        SET @MtoH = @Val_Cal          
  SET @MtoD_ME = 0.00    -- SOLO PARA INVENTARIO 2          
        SET @MtoH_ME = @Val_Cal_ME  -- SOLO PARA INVENTARIO 2          
       END                                      
                                              
 IF(@MtoD<0)                                      
  BEGIN                                      
   SET @MtoH = abs(@MtoD)                                      
   SET @MtoD = 0          
   SET @MtoH_ME = abs(@MtoD_ME) -- SOLO PARA INVENTARIO 2          
   SET @MtoD_ME = 0    -- SOLO PARA INVENTARIO 2          
  END                                      
 IF(@MtoH<0)                                      
  BEGIN                               
   SET @MtoD = abs(@MtoH)                                      
   SET @MtoH = 0          
   SET @MtoD_ME = abs(@MtoH_ME) -- SOLO PARA INVENTARIO 2          
   SET @MtoH_ME = 0    -- SOLO PARA INVENTARIO 2          
  END              
          
      PRINT '==== Montos Iniciales ==== ASIENTO_AUTOMATICO'          
      PRINT 'Debe     : ' + CONVERT(VARCHAR,@MtoD)          
      PRINT 'Haber    : ' + CONVERT(VARCHAR,@MtoH)          
   PRINT 'Debe ME  : ' + CONVERT(VARCHAR,@MtoD_ME)          
      PRINT 'Haber ME : ' + CONVERT(VARCHAR,@MtoH_ME)          
          
                        
      IF(@Cd_TM = '16')                      
       SET @Cd_MdRg = '01'                                      
                                      
      IF(@Cd_TM = '20')                                      
       SET @Cd_MdRg = '01'                                      
                                      
      IF(@Cd_TM = '22')                                      
       BEGIN                                       
        --SET @Cd_MdOr = (SELECT Cd_Mda from CanjePagoDet WHERE RucE = @RucE_P and Cd_Cnj = @Cod_P and Item = @Cod_P_Item)                                      
        SET @Cd_MdOr = (SELECT Codigo_Moneda_Canje from VW_LETRA_PAGO_RETENCIONES WHERE Ruc_Empresa = @RucE_P and Codigo_Canje = @Cod_P and Id = @Cod_P_Item)                                      
     SET @Cd_MdRg = @Cd_MdOr                                      
       END                                      
                                            
      IF (@Cd_TM = '15')                                      
       BEGIN                                       
        SET @Cd_MdOr = (SELECT C_CODIGO_MONEDA FROM contabilidad.FS_BUSCAR_DEPRECIACION_AGRUPADA(@RucE_P, @Ejer_P, @Cod_P, @ParametroAux1_P) WHERE C_ID_ACTIVO = @Cod_P_Item)                                      
        SET @Cd_MdRg = @Cd_MdOr                                              
       END                                      
                                      
      IF(@Cd_TM = '09')                                      
       BEGIN                                       
   SET @Cd_MdOr =(SELECT ISNULL((SELECT TOP 1 ISNULL(CD_MDA,'01') FROM PLANCTAS WHERE RUCE = @RucE_P AND EJER = @Ejer_P AND NROCTA = @NROCTA AND IB_CTASXCBR = 1),'01') )                                         
   SET @IB_PgTot = 0              
       END                                      
                                      
      IF(@Cd_TM = '08')                                      
       BEGIN                                       
        SET @Cd_MdOr = (SELECT ISNULL((SELECT TOP 1 ISNULL(CD_MDA,'01') FROM PLANCTAS WHERE RUCE = @RucE_P AND EJER = @Ejer_P AND NROCTA = @NROCTA AND IB_CTASXPAG = 1),'01'))                                          
       END                                            
                              
   IF (@Cd_TM = '32')                        
       BEGIN                                       
        SET @Cd_MdOr = (SELECT C_CODIGO_MONEDA FROM activo_fijo.VW_ACTIVO_REVALUADO WHERE C_RUC_EMPRESA=@RucE_P AND C_EJERCICIO= @Ejer_P AND C_ID_REVALUACION=@ParametroAux1_P)                        
        SET @Cd_MdRg = @Cd_MdOr                        
       END                        
                            
   IF (@Cd_TM = '33')                        
       BEGIN                                       
        SET @Cd_MdOr = (SELECT C_CODIGO_MONEDA FROM activo_fijo.VW_ACTIVO_DEPRECIACION_REVALUADO WHERE C_RUC_EMPRESA=@RucE_P AND C_EJERCICIO= @Ejer_P AND C_ID_DEPRECIACION_REVALUACION=@ParametroAux1_P)                        
        SET @Cd_MdRg = @Cd_MdOr                        
       END                                
                        
    IF (@Val_Cal != 0.00 OR @L_IB_PERMITIR_GENERAR_ASIENTO_MONTO_CERO = 1) AND ISNULL(@L_IB_TransferenciaGratuita,0) = 0                                   
     BEGIN                                      
      IF(ISNULL(@msj,'') = '')                                      
       BEGIN                                      
        IF (@Cd_MR = '05')                                      
     BEGIN                                       
          SET @DR_NDoc = @Cod_P_Item                                      
          SET @DR_NSre = @IC_ES                                      
         END                                      
          
  --print ''          
  --print '-MtoD ' + CONVERT(VARCHAR,@MtoD)          
  --print '-MtoH ' + CONVERT(VARCHAR,@MtoH)          
  --print '-MtoD_ME ' + CONVERT(VARCHAR,@MtoD_ME)          
  --print '-MtoH_ME ' + CONVERT(VARCHAR,@MtoH_ME)          
  --print ''          
  
        EXEC contabilidad.Ctb_Voucher_Inserta_Mov_Asiento_Temp_2                            
         @RucE_P, @Ejer_P, @Prdo, @RegCtb_P, @Cd_Fte, @FecMov, @FecCbr, @NroCta, @CtaAsoc, @Cd_Clt, @Cd_Prv, @Cd_Trab, @Cd_TD,                                      
         @NroSre, @NroDoc, @FecED, @FecVD, @Glosa, @MtoD, @MtoH, @Cd_MdOr, @Cd_MdRg, @CamMda, @Cd_CC, @Cd_SC, @Cd_SS,                                       
         @Cd_Area, @Cd_MR, @NroChke, @Cd_TG, @IC_CtrMd, @UsuCrea, null, @SaldoMN OUTPUT, @SaldoME OUTPUT, @TipMov,                                       
         @IC_TipAfec, @TipOper, @Grdo, @IC_Crea, @IB_PgTot, @L_IB_PROV, @DR_FecED, @DR_CdTD, @DR_NSre, @DR_NDoc,                                       
         @DR_NroDet, @DR_FecDet, NULL, NULL, @Cd_FPC, @Cd_FCP, NULL, NULL,      
   @CA01,@CA02,@CA03,@CA04,@CA05,@CA06,@CA07,@CA08,@CA09,@CA10,@CA11,@CA12,@CA13,@CA14,@CA15, @msj OUTPUT,          
         @L_REGCTB_REF, NULL, NULL, NULL,                                 
         NULL,@L_ID_CONCEPTO_FEC, @L_IB_DEVOLUCION_IGV  ,@Ib_Agrup, @MtoD_ME, @MtoH_ME, @L_IGV_TASA,@Cd_MIS_P        
                                      
       END                                      
                
     END                                             
    -- ===========================================================================================================================================================                                      
                                                   
                                      
      SET @msj = ''                                                
      SET @IC_Crea = 'T'                                       
      SET @IC_TipAfec = NULL                                      
      SET @Cd_Prv = NULL                                      
      SET @Cd_Clt = NULL                                      
      SET @Cd_Trab = NULL                                      
      /*LIMPIAMOS LOS CAMPOS REFERENCIALES*/                                      
      SET @DR_NDoc  = ''                                       
      SET @DR_CdTD = ''                                       
      SET @DR_NSre = ''                                      
                                      
      PRINT @Msj                                      
                                      
      /* :::::::::::::::::::::  FETCH Del Detalle ::::::::::::::::::::: */                                      
                                      
 IF(@Cd_TM = '05')                                      
  BEGIN                                      
   IF(@IC_Inv = 'M')                                      
    FETCH Cur_TabDet INTO @Cod_P_Item                                      
   ELSE                                      
    BEGIN                                      
     IF(@IC_ES = 'S')                                      
      FETCH Cur_TabDet INTO @Cod_P_Item_Peps, @Cod_P_Item                                      
     ELSE                         
      FETCH Cur_TabDet INTO @Cod_P_Item                                      
    END                                      
  END        
 ELSE IF(@Cd_TM = '17' and @NomCol like 'FabGastoTotal%')        
  BEGIN        
   FETCH Cur_TabDet INTO @Cod_P_Item, @CD_Fabricacion, @ID_Etapa, @ID_FabItem        
  END  
 ELSE IF(@Cd_TM = '17' and @NomCol like 'ProdGastoTotal%')  
 BEGIN  
  --FETCH Cur_TabDet INTO @Cod_P_Item, @CD_Produccion--, @ID_ProdItem  
  FETCH Cur_TabDet INTO @CD_Produccion,@Id_CCOF,@Cd_Vou_CCOF
 END  
 ELSE        
  BEGIN          
   FETCH Cur_TabDet INTO @Cod_P_Item          
  END          
                                      
      /* :::::::::::::::::::::  FETCH Del Detalle Fin ::::::::::::::::::::: */                                      
                                      
     END                                      
                                      
     CLOSE Cur_TabDet                                      
     --TODO!                                      
     IF(@Cd_TM='13')                                      
      SET @Cod_P= @Cod_P + RIGHT(LEFT(@colCodTab,10),1)                                       
                       
     DEALLOCATE Cur_TabDet                           
    END                                      
  ELSE -- si es cabecera(c) :                                      
    BEGIN                                      
                
     IF(@Cd_IA = 'J')                                      
      BEGIN                                      
       IF (@Cd_TM='01')                                      
        SELECT @IC_TipAfec = CASE Cd_IAV_DF WHEN 'X' then NULL ELSE Cd_IAV_DF END FROM VW_VENTAS_CAB WHERE RucE = @RucE_P and Eje = @Ejer_P and RegCtb LIKE @RegCtb_P                                      
                                      
       IF (@Cd_TM='02')                                      
        SET @IC_TipAfec = CASE @Cd_IA WHEN 'X' then NULL ELSE @Cd_IA END                                        
                                      
       IF (@Cd_TM='25')                                      
       SELECT TOP 1 @IC_TipAfec = CODIGO_INDICADOR_AFECTO_CABECERA FROM integracion.VW_RECEPCION_INFORMACION_RESERVA WHERE RUC_EMPRESA = @RucE_P AND EJERCICIO = @Ejer_P AND REGISTRO_CONTABLE = @RegCtb_P                                      
                                      
       IF (@Cd_TM='26')                                      
        SELECT TOP 1 @IC_TipAfec = CODIGO_INDICADOR_AFECTO FROM integracion.VW_RECEPCION_INFORMACION_PROVISION WHERE RUC_EMPRESA = @RucE_P AND EJERCICIO = @Ejer_P AND REGISTRO_CONTABLE = @RegCtb_P                                      
                                      
       IF (@Cd_TM='27')                                      
        SELECT TOP 1 @IC_TipAfec = CODIGO_INDICADOR_AFECTO FROM integracion.VW_RECEPCION_INFORMACION_COBRANZA WHERE RUC_EMPRESA = @RucE_P AND EJERCICIO = @Ejer_P AND REGISTRO_CONTABLE = @RegCtb_P                                      
                                      
       IF (@Cd_TM='28')                                      
        SELECT TOP 1 @IC_TipAfec = CODIGO_INDICADOR_AFECTO_CABECERA FROM integracion.VW_RECEPCION_INFORMACION_PAGO_DIRECTO WHERE RUC_EMPRESA = @RucE_P AND EJERCICIO = @Ejer_P AND REGISTRO_CONTABLE = @RegCtb_P                                      
                              
       IF (@Cd_TM='30')                                    
        SELECT TOP 1 @IC_TipAfec = CODIGO_INDICADOR_AFECTO FROM ContaApi.VW_PRE_AFILIACION WHERE RUC_EMPRESA = @RucE_P AND EJERCICIO = @Ejer_P AND REGISTRO_CONTABLE = @RegCtb_P                        
                               
      END                                      
     ELSE                                      
      SET @IC_TipAfec = @Cd_IA                                      
                                
     /*Armado de la GLOSA en la CABECERA, según FORMULA o VALOR*/                                      
                                           
     IF @IC_VFG= 'F' and ISNULL(@Glosa_Fmla,'') != ''           
      BEGIN                             
       IF (@CD_TM = '21')                                      
        BEGIN                                      
         SET @sql = 'SELECT TOP 1 @Glsa_Fm = '+ ISNULL(@Glosa_Fmla,'') +' FROM ' +@NomTabla+ ' ('''+@RucE_P+''','''+@Ejer_P+''','''+@Cod_P + ''')'                                      
         EXEC sp_EXECutesql @sql, N'@Glsa_Fm VARCHAR(500) OUTPUT', @Glosa OUTPUT                                      
        END                                      
       ELSE IF(@CD_TM = '23')                                      
        BEGIN                                      
         SET @sql = 'SELECT TOP 1 @Glsa_Fm = '+ ISNULL(@Glosa_Fmla,'') +' FROM CONCEPTOXMOV WHERE RucE= '''+@RucE_P+''' and C_REGISTRO_CONTABLE = '''+@RegCtb_P + ''''                                      
         EXEC sp_EXECutesql @sql, N'@Glsa_Fm VARCHAR(500) OUTPUT', @Glosa OUTPUT                                      
        END                                      
       ELSE IF(@CD_TM = '25' OR @CD_TM = '26' OR @CD_TM = '27' OR @CD_TM = '28' OR @CD_TM = '30')                                      
        BEGIN                                      
         SET @sql = 'SELECT TOP 1 @Glsa_Fm = '+ ISNULL(@Glosa_Fmla,'') +' FROM ' +@NomTabla+ ' WHERE RUC_EMPRESA = '''+@RucE_P+''' AND EJERCICIO = '''+@Ejer_P+''' and REGISTRO_CONTABLE = '''+@RegCtb_P + ''''                                      
         EXEC sp_EXECutesql @sql, N'@Glsa_Fm VARCHAR(500) OUTPUT', @Glosa OUTPUT                                      
        END                        
       ELSE IF(@CD_TM = '31')                        
        BEGIN                                      
         SET @sql = 'SELECT TOP 1 @Glsa_Fm = '+ ISNULL(@Glosa_Fmla,'') +' FROM ' +@NomTabla+ ' WHERE RUC_EMPRESA = '''+@RucE_P+''' AND EJERCICIO = '''+@Ejer_P+''' and REGISTRO_CONTABLE_DETALLE = '''+@RegCtb_P + ''''                                      
         EXEC sp_EXECutesql @sql, N'@Glsa_Fm VARCHAR(500) OUTPUT', @Glosa OUTPUT                                      
        END                                                    
       ELSE                                      
        BEGIN                                     
         SET @sql = 'SELECT TOP 1 @Glsa_Fm = '+ ISNULL(@Glosa_Fmla,'') +' FROM ' +@NomTabla+ ' WHERE RucE= '''+@RucE_P+''' and '+@colCodTab+'= '''+@Cod_P + ''''                                      
         EXEC sp_EXECutesql @sql, N'@Glsa_Fm VARCHAR(500) OUTPUT', @Glosa OUTPUT                                      
        END                                      
      END                                      
     ELSE                                       
      SET @Glosa = @Glosa_Fmla                                       
                                      
     PRINT 'Glosa: ' + @Glosa                               
     --==================================                                      
                                           
     IF @IC_JDCtaPA = 'A'                                      
      BEGIN                        
       IF (isnull(@Cd_Clt,'')='') and (isnull(@Cd_Prv,'')='')                                      
        BEGIN                                
         IF (@Cd_TM='01') -- si es venta:                             
          SELECT @Cd_Clt=Cd_Clt FROM VW_VENTAS_CAB WHERE RucE=@RucE_P and Cd_Vta = @Cod_P                                       
                                      
         ELSE IF (@Cd_TM='02') -- si es compra:                                      
          SELECT @Cd_Prv=Cd_Prv FROM VW_COMPRAS_CAB WHERE RucE=@RucE_P and Cd_Com = @Cod_P                                      
                                      
         ELSE IF (@Cd_TM='05') -- si es Inventario:                                      
          SELECT @Cd_Prv=min(Cd_Prv), @Cd_Clt=min(Cd_Clt) FROM Inventario WHERE RucE=@RucE_P and Ejer=@Ejer_P and RegCtb = @Cod_P                                      
                                      
         ELSE IF (@Cd_TM='08') -- si es Letra:                                      
          SELECT @Cd_Prv=Cd_Prv FROM CanjePago WHERE RucE=@RucE_P and Cd_Cnj = @Cod_P                                      
                                      
         ELSE IF (@Cd_TM='09') -- si es Letra:                                      
          SELECT @Cd_Clt=Cd_Clt FROM Canje WHERE RucE=@RucE_P and Cd_Cnj = @Cod_P                                      
                                      
         ELSE IF (@Cd_TM='12') -- si es compra:                                      
          SELECT @Cd_Prv=Cd_Prv FROM Compra2_Resumen WHERE RucE=@RucE_P and Cd_Com = @Cod_P                                      
                                      
         ELSE IF (@Cd_TM='21') -- si es compra:                                      
          SELECT @Cd_Prv=Cd_Prv FROM DBO.F_ORDCOMPRA_COMPRA(@RucE_P,@Ejer_P,@Cod_P)--ORDCOMPRA WHERE RucE=@RucE_P and CD_OC = @Cod_P                                      
                                      
         ELSE IF (@Cd_TM = '23')                                       
          SELECT top 1 @Cd_Clt=C_CODIGO_CLIENTE FROM [DBO].[VW_RETENCION_VENTA]WHERE C_RUC_COMPROBANTE_RETENCION=@RucE_P and C_REGISTRO_CONTABLE = @RegCtb_P                                      
                                      
         ELSE IF (@Cd_TM = '25')                                       
          SELECT top 1 @Cd_Clt= CODIGO_CLIENTE, @Cd_Prv = CODIGO_PROVEEDOR FROM integracion.VW_RECEPCION_INFORMACION_RESERVA WHERE RUC_EMPRESA = @RucE_P and EJERCICIO = @Ejer_P AND REGISTRO_CONTABLE = @RegCtb_P                                      
                                      
         ELSE IF (@Cd_TM = '26')                                       
          SELECT top 1 @Cd_Clt= CODIGO_CLIENTE, @Cd_Prv = CODIGO_PROVEEDOR FROM integracion.VW_RECEPCION_INFORMACION_PROVISION WHERE RUC_EMPRESA = @RucE_P and EJERCICIO = @Ejer_P AND REGISTRO_CONTABLE = @RegCtb_P                                      
                                      
         ELSE IF (@Cd_TM = '27')                                       
          SELECT top 1 @Cd_Clt= CODIGO_CLIENTE, @Cd_Prv = CODIGO_PROVEEDOR FROM integracion.VW_RECEPCION_INFORMACION_COBRANZA WHERE RUC_EMPRESA = @RucE_P and EJERCICIO = @Ejer_P AND REGISTRO_CONTABLE = @RegCtb_P                                      
                                      
         ELSE IF (@Cd_TM = '28')                                       
          SELECT top 1 @Cd_Clt= CODIGO_CLIENTE, @Cd_Prv = CODIGO_PROVEEDOR FROM integracion.VW_RECEPCION_INFORMACION_PAGO_DIRECTO WHERE RUC_EMPRESA = @RucE_P and EJERCICIO = @Ejer_P AND REGISTRO_CONTABLE = @RegCtb_P                                      
                                
        ELSE IF (@Cd_TM = '30')                                     
          SELECT top 1 @Cd_Clt= CODIGO_CLIENTE, @Cd_Prv = CODIGO_PROVEEDOR FROM ContaApi.VW_PRE_AFILIACION WHERE RUC_EMPRESA = @RucE_P and EJERCICIO = @Ejer_P AND REGISTRO_CONTABLE = @RegCtb_P                        
                           
        ELSE IF (@Cd_TM = '31')                        
          SELECT top 1 @Cd_Clt= CODIGO_CLIENTE FROM CONTAAPI.VW_SERVICIO_DEVENGADO WHERE RUC_EMPRESA = @RucE_P and EJERCICIO = @Ejer_P AND REGISTRO_CONTABLE_DETALLE = @RegCtb_P        
      END                                      
                                      
       IF isnull(@Cd_Clt,'')=''--es Proveedor                         
        SELECT @NroCta_Temp = CtaCtb FROM Proveedor2 WHERE RucE=@RucE_P and Cd_Prv=@Cd_Prv                                      
       ELSE                                      
        SELECT @NroCta_Temp = CtaCtb FROM Cliente2 WHERE RucE=@RucE_P and Cd_Clt=@Cd_Clt                                      
                                      
       IF isnull(@NroCta_Temp,'')=''                        
        BEGIN                                      
         IF @Cd_MdRg='01'                                      
          SET @NroCta_Temp = @Cta                                      
         ELSE                                   
          SET @NroCta_Temp = @CtaME                                      
        END                                      
       IF isnull(@NroCta_Temp,'')=''                        
        SET @NroCta_Temp = '999999999'                                      
       SET @NroCta = @NroCta_Temp         
      END                                      
                                        
     PRINT 'Numero de Cuenta :'+ @NroCta_Temp                                      
--==================================================================      
PRINT '=====INICIO CAPTURA CAMPOS ADICIONALES CABECERA====='      
      
BEGIN      
 SELECT      
  @CA01 = CASE WHEN cf.Id_CTb = 480 THEN dbo.FN_CONSULTA_INFORMACION_CAMPO_ADICIONAL(@RucE_P,@Ejer_P,@Cd_TM,@Cod_P,-1,cf.Id_CtbB) ELSE @CA01 END,       
  @CA02 = CASE WHEN cf.Id_CTb = 481 THEN dbo.FN_CONSULTA_INFORMACION_CAMPO_ADICIONAL(@RucE_P,@Ejer_P,@Cd_TM,@Cod_P,-1,cf.Id_CtbB) ELSE @CA02 END,       
  @CA03 = CASE WHEN cf.Id_CTb = 482 THEN dbo.FN_CONSULTA_INFORMACION_CAMPO_ADICIONAL(@RucE_P,@Ejer_P,@Cd_TM,@Cod_P,-1,cf.Id_CtbB) ELSE @CA03 END,       
  @CA04 = CASE WHEN cf.Id_CTb = 483 THEN dbo.FN_CONSULTA_INFORMACION_CAMPO_ADICIONAL(@RucE_P,@Ejer_P,@Cd_TM,@Cod_P,-1,cf.Id_CtbB) ELSE @CA04 END,       
  @CA05 = CASE WHEN cf.Id_CTb = 484 THEN dbo.FN_CONSULTA_INFORMACION_CAMPO_ADICIONAL(@RucE_P,@Ejer_P,@Cd_TM,@Cod_P,-1,cf.Id_CtbB) ELSE @CA05 END,       
  @CA06 = CASE WHEN cf.Id_CTb = 485 THEN dbo.FN_CONSULTA_INFORMACION_CAMPO_ADICIONAL(@RucE_P,@Ejer_P,@Cd_TM,@Cod_P,-1,cf.Id_CtbB) ELSE @CA06 END,       
  @CA07 = CASE WHEN cf.Id_CTb = 486 THEN dbo.FN_CONSULTA_INFORMACION_CAMPO_ADICIONAL(@RucE_P,@Ejer_P,@Cd_TM,@Cod_P,-1,cf.Id_CtbB) ELSE @CA07 END,       
  @CA08 = CASE WHEN cf.Id_CTb = 487 THEN dbo.FN_CONSULTA_INFORMACION_CAMPO_ADICIONAL(@RucE_P,@Ejer_P,@Cd_TM,@Cod_P,-1,cf.Id_CtbB) ELSE @CA08 END,       
  @CA09 = CASE WHEN cf.Id_CTb = 488 THEN dbo.FN_CONSULTA_INFORMACION_CAMPO_ADICIONAL(@RucE_P,@Ejer_P,@Cd_TM,@Cod_P,-1,cf.Id_CtbB) ELSE @CA09 END,       
  @CA10 = CASE WHEN cf.Id_CTb = 489 THEN dbo.FN_CONSULTA_INFORMACION_CAMPO_ADICIONAL(@RucE_P,@Ejer_P,@Cd_TM,@Cod_P,-1,cf.Id_CtbB) ELSE @CA10 END,       
  @CA11 = CASE WHEN cf.Id_CTb = 490 THEN dbo.FN_CONSULTA_INFORMACION_CAMPO_ADICIONAL(@RucE_P,@Ejer_P,@Cd_TM,@Cod_P,-1,cf.Id_CtbB) ELSE @CA11 END,       
  @CA12 = CASE WHEN cf.Id_CTb = 491 THEN dbo.FN_CONSULTA_INFORMACION_CAMPO_ADICIONAL(@RucE_P,@Ejer_P,@Cd_TM,@Cod_P,-1,cf.Id_CtbB) ELSE @CA12 END,       
  @CA13 = CASE WHEN cf.Id_CTb = 492 THEN dbo.FN_CONSULTA_INFORMACION_CAMPO_ADICIONAL(@RucE_P,@Ejer_P,@Cd_TM,@Cod_P,-1,cf.Id_CtbB) ELSE @CA13 END,       
  @CA14 = CASE WHEN cf.Id_CTb = 493 THEN dbo.FN_CONSULTA_INFORMACION_CAMPO_ADICIONAL(@RucE_P,@Ejer_P,@Cd_TM,@Cod_P,-1,cf.Id_CtbB) ELSE @CA14 END,       
  @CA15 = CASE WHEN cf.Id_CTb = 494 THEN dbo.FN_CONSULTA_INFORMACION_CAMPO_ADICIONAL(@RucE_P,@Ejer_P,@Cd_TM,@Cod_P,-1,cf.Id_CtbB) ELSE @CA15 END      
 FROM       
  CfgCampos cf       
  LEFT JOIN CampoTabla ct on cf.Id_CtbB = ct.Id_Ctb      
 WHERE       
  cf.Id_CTb between 480 and 494      
  AND id_CtbB is not null      
  AND ct.Cd_Tab = CASE WHEN @Cd_TM = '12' THEN 'CP29' END      
END      
 --SELECT 'CA08 ' + @CA08      
 --SELECT @RucE_P,@Ejer_P,@Cd_TM,@Cod_P,Convert(int,@Cod_P_Item)--,cf.Id_CtbB      
PRINT '======FIN CAPTURA CAMPOS ADICIONALES CABECERA======='      
--==================================================================                                            
     /*===================================================*/                                      
     IF(@Cd_TM = '23')                                      
     BEGIN                   
      IF EXISTS(SELECT 1 FROM PLANCTAS WHERE RUCE = @RucE_P AND Ejer = @Ejer_P AND NROCTA = @Cta AND IB_CtasXCbr = 1)                                      
      BEGIN                                      
       SET @sql = 'SELECT TOP 1                                       
            @Cd_TD_ = C_TIPO_DOCUMENTO_COMPROBANTE,                                       
            @NroSre_ = C_SERIE_COMPROBANTE,                                       
            @NroDoc_ = C_NUMERO_COMPROBANTE FROM '                                       
          + @NomTabla +                                       
          ' WHERE C_RUC_COMPROBANTE_RETENCION= '''+@RucE_P+''' and '+@colCodTab+'= '''+@RegCtb_P + ''''                                      
      END                                      
      ELSE                                      
      BEGIN                                      
       SET @sql = 'SELECT TOP 1                                       
            @Cd_TD_ = ''20'' ,                                       
            @NroSre_ = C_SERIE_COMPROBANTE_RETENCION,                                       
            @NroDoc_ = C_NUMERO_COMPROBANTE_RETENCION FROM'                                       
          + @NomTabla  +                                           ' WHERE C_RUC_COMPROBANTE_RETENCION= '''+@RucE_P+''' and '+@colCodTab+'= '''+@RegCtb_P + ''''                                      
  END                                      
      EXEC sp_EXECutesql @sql, N'@Cd_TD_ NVARCHAR(2) OUTPUT, @NroSre_ VARCHAR(20) OUTPUT, @NroDoc_ VARCHAR(20) OUTPUT' , @Cd_TD OUTPUT, @NroSre OUTPUT, @NroDoc OUTPUT                                      
     END                                      
     /*===================================================*/                                      
                                  
 /*INICIO PERCEPCION*/                                  
 IF (@Cd_TM = '10' AND @Cd_Fte = 'LD' AND LEFT(@Cta,2) = '12')                                  
 BEGIN                                  
  SELECT TOP 1 @DR_CdTD = B.Cd_TD, @DR_NSre = B.NroSre, @DR_NDoc = B.NroDoc                                   
  FROM ComprobantePercepDet A INNER JOIN venta B WITH(NOLOCK) ON A.RucE = B.RucE AND A.Cd_Vta = B.Cd_Vta                                   
  WHERE A.RucE = @RucE_P AND A.Cd_CPercep = @Cod_P                                  
 END                                  
 /*FIN PERCEPCION*/                                  
                                  
    IF(@Cd_TM='13')                                      
    BEGIN                                      
  SET @colCodTab = ' ID_Eta= '+ RIGHT(@Cod_P,len(@Cod_P)-10)+ ' and Cd_Fab '                                      
  SET @Cod_P = LEFT(@Cod_P, 10)                                      
    END                                       
                                          
     /* Jalamos - definimos Centro de Costos */                                   
                                      
     IF @IC_JDCC = 'J'                                      
      BEGIN            
       IF (@Cd_TM='21')                                      
        BEGIN                                      
         SET @sql = 'SELECT TOP 1 @CC_obt = Cd_CC, @SC_obt = Cd_SC, @SS_obt=Cd_SS FROM DBO.F_ORDCOMPRA_COMPRA('''+@RucE_P+''','''+@Ejer_P+''','''+@Cod_P+''')'                                       
         EXEC sp_EXECutesql @sql, N'@CC_obt NVARCHAR(8) OUTPUT, @SC_obt NVARCHAR(8) OUTPUT, @SS_obt NVARCHAR(8) OUTPUT', @Cd_CC OUTPUT, @Cd_SC OUTPUT, @Cd_SS OUTPUT                                      
        END      
  ELSE IF (@Cd_TM = '22')      
  BEGIN      
   SET @sql = 'SELECT TOP 1 @CC_obt = Centro_Costo_Documento, @SC_obt = Sub_Centro_Costo_Documento, @SS_obt = Sub_Sub_Centro_Costo_Documento FROM VW_LETRA_PAGO_RETENCIONES                                       
             WHERE Ruc_Empresa = '''+@RucE_P+''' AND Codigo_Canje = '''+@Cod_P+''''                 
  END      
       ELSE IF (@Cd_TM = '23')                                      
        BEGIN                                      
         SELECT                                      
          @Cd_CC = C_CC,                                      
          @Cd_SC = C_SCC,                                      
          @Cd_SS = C_SSCC                                       
         FROM                                       
          CONCEPTOXMOV                                      
         WHERE                                      
          RUCE = @RucE_P AND C_REGISTRO_CONTABLE = @RegCtb_P                                      
        END                                      
       ELSE IF (@Cd_TM = '25' OR @Cd_TM = '26' OR @Cd_TM = '27' OR @Cd_TM = '28' OR @Cd_TM = '30')                                      
        BEGIN                                        
         SET @sql = 'SELECT TOP 1 @CC_obt = CODIGO_CENTRO_COSTOS, @SC_obt = CODIGO_SUB_CENTRO_COSTOS, @SS_obt=CODIGO_SUB_SUB_CENTRO_COSTOS                                       
            FROM '+@NomTabla+' WHERE RUC_EMPRESA = '''+@RucE_P+''' AND EJERCICIO = '''+@Ejer_P+''' AND REGISTRO_CONTABLE =  '''+@RegCtb_P+''''                                      
         EXEC sp_EXECutesql @sql, N'@CC_obt NVARCHAR(8) OUTPUT, @SC_obt NVARCHAR(8) OUTPUT, @SS_obt NVARCHAR(8) OUTPUT', @Cd_CC OUTPUT, @Cd_SC OUTPUT, @Cd_SS OUTPUT                                      
        END                          ELSE IF (@Cd_TM = '31')                                      
        BEGIN                                 
         SET @sql = 'SELECT TOP 1 @CC_obt = CODIGO_CENTRO_COSTOS, @SC_obt = CODIGO_SUB_CENTRO_COSTOS, @SS_obt=CODIGO_SUB_SUB_CENTRO_COSTOS                                       
            FROM '+@NomTabla+' WHERE RUC_EMPRESA = '''+@RucE_P+''' AND EJERCICIO = '''+@Ejer_P+''' AND REGISTRO_CONTABLE_DETALLE =  '''+@RegCtb_P+''''                                      
         EXEC sp_EXECutesql @sql, N'@CC_obt NVARCHAR(8) OUTPUT, @SC_obt NVARCHAR(8) OUTPUT, @SS_obt NVARCHAR(8) OUTPUT', @Cd_CC OUTPUT, @Cd_SC OUTPUT, @Cd_SS OUTPUT                                      
        END                        
  ELSE IF (@Cd_TM = '32')                                      
        BEGIN                        
   SET @sql = 'SELECT TOP 1 @CC_obt = C_CENTRO_COSTO_ULTIMO, @SC_obt = C_SUB_CENTRO_COSTO_ULTIMO, @SS_obt=C_SUB_SUB_CENTRO_COSTO_ULTIMO                
            FROM '+@NomTabla+' WHERE C_RUC_EMPRESA = '''+@RucE_P+''' AND C_EJERCICIO = '''+@Ejer_P+''' AND C_ID_REVALUACION =  '''+@ParametroAux1_P+''''                        
                           
         EXEC sp_EXECutesql @sql, N'@CC_obt NVARCHAR(8) OUTPUT, @SC_obt NVARCHAR(8) OUTPUT, @SS_obt NVARCHAR(8) OUTPUT', @Cd_CC OUTPUT, @Cd_SC OUTPUT, @Cd_SS OUTPUT                                      
        END                        
    ELSE IF (@Cd_TM = '33')                                      
        BEGIN                        
   SET @sql = 'SELECT TOP 1 @CC_obt = C_CENTRO_COSTO_ULTIMO, @SC_obt = C_SUB_CENTRO_COSTO_ULTIMO, @SS_obt=C_SUB_SUB_CENTRO_COSTO_ULTIMO                                       
            FROM '+@NomTabla+' WHERE C_RUC_EMPRESA = '''+@RucE_P+''' AND C_EJERCICIO = '''+@Ejer_P+''' AND C_ID_DEPRECIACION_REVALUACION =  '''+@ParametroAux1_P+''''                        
                           
         EXEC sp_EXECutesql @sql, N'@CC_obt NVARCHAR(8) OUTPUT, @SC_obt NVARCHAR(8) OUTPUT, @SS_obt NVARCHAR(8) OUTPUT', @Cd_CC OUTPUT, @Cd_SC OUTPUT, @Cd_SS OUTPUT                                      
        END                        
       ELSE                                      
        BEGIN                                      
         SET @sql = 'SELECT TOP 1 @CC_obt = Cd_CC, @SC_obt = Cd_SC, @SS_obt=Cd_SS FROM '                                  
         + (CASE WHEN @Cd_TM = '17' THEN @NomTablaDet ELSE @NomTabla END) +                                       
         ' WHERE RucE= '''+@RucE_P+''' and '+@colCodTab+'= '''+@Cod_P + ''''                                      
                                      
         EXEC sp_EXECutesql @sql, N'@CC_obt NVARCHAR(8) OUTPUT, @SC_obt NVARCHAR(8) OUTPUT, @SS_obt NVARCHAR(8) OUTPUT', @Cd_CC OUTPUT, @Cd_SC OUTPUT, @Cd_SS OUTPUT                                      
         PRINT @sql                                      
        END                                      
      END                                      
     IF isnull(@Cd_CC,'')=''                        
      SET @Cd_CC = '01010101'                                      
    IF isnull(@Cd_SC,'')=''                        
      SET @Cd_SC = '01010101'                                      
     IF isnull(@Cd_SS,'')=''                        
      SET @Cd_SS = '01010101'                                      
                                          
     PRINT '-CC: ' + @Cd_CC + ' - '+ + @Cd_SC + ' - '+ + @Cd_SS                       
                              
     /* ===================================================================== */                                      
                                      
     /*Esta lógica aplica para Movimiento de Inventario 2, el cual determina la columna que se busca, si es (E, S, EyS), si es (Promedio o Peps),                                      
       esta columna es cogida desde la Vista de Inventario2_Cabecera.*/                                      
      
 IF (@Cd_TM = '17')  
 BEGIN  
  IF(@IC_DetCab = 'X')  
  BEGIN  
   IF (@NomCol like 'CostoTotal%' or @NomCol like 'Filtro%')  
   BEGIN  
    --Para los Indicadores Valores de CostoTotal y derivados se determina de acuerdo al tipo de costeo, moneda y indicador E/S  
    IF(@IC_Inv = 'P') /*Si la configuración del Clientes es (P)Peps*/  
    BEGIN  
     IF(@Cd_MdRg = '01')  
     BEGIN  
      IF(@IC_ES = 'E')  
      BEGIN  
       SET @NomCol = 'CostoTotal_MN_Peps_E'  
       SET @NomCol_ME = 'CostoTotal_ME_Peps_E'  
      END  
      ELSE IF (@IC_ES = 'S')  
      BEGIN  
       SET @NomCol = 'CostoTotal_MN_Peps_S'  
       SET @NomCol_ME = 'CostoTotal_ME_Peps_S'  
      END  
      ELSE IF (@IC_ES = 'A')  
      BEGIN  
       SET @NomCol = 'CostoTotal_MN_Peps_ES'  
       SET @NomCol_ME = 'CostoTotal_ME_Peps_ES'  
      END  
     END  
     ELSE IF (@Cd_MdRg = '02')  
     BEGIN  
      IF(@IC_ES = 'E')  
      BEGIN  
       SET @NomCol = 'CostoTotal_ME_Peps_E'  
       SET @NomCol_ME = 'CostoTotal_MN_Peps_E'  
      END  
      ELSE IF (@IC_ES = 'S')  
      BEGIN  
       SET @NomCol = 'CostoTotal_ME_Peps_S'  
       SET @NomCol_ME = 'CostoTotal_MN_Peps_S'  
      END  
      ELSE IF (@IC_ES = 'A')  
      BEGIN  
       SET @NomCol = 'CostoTotal_ME_Peps_ES'  
       SET @NomCol_ME = 'CostoTotal_MN_Peps_ES'  
      END  
     END  
    END  
    IF(@IC_Inv = 'M') /*Si la configuración del Clientes es Promedio(M)*/  
    BEGIN  
     IF(@Cd_MdRg = '01')  
     BEGIN  
      IF(@IC_ES = 'E')  
      BEGIN  
       SET @NomCol = 'CostoTotal_MN_Prom_E'  
       SET @NomCol_ME = 'CostoTotal_ME_Prom_E'  
      END  
      ELSE IF (@IC_ES = 'S')  
      BEGIN  
       SET @NomCol = 'CostoTotal_MN_Prom_S'  
       SET @NomCol_ME = 'CostoTotal_ME_Prom_S'  
      END  
      ELSE IF (@IC_ES = 'A')  
      BEGIN  
       SET @NomCol = 'CostoTotal_MN_Prom_ES'  
       SET @NomCol_ME = 'CostoTotal_ME_Prom_ES'  
      END  
     END  
     ELSE IF (@Cd_MdRg = '02')  
     BEGIN  
      IF(@IC_ES = 'E')  
      BEGIN  
       SET @NomCol = 'CostoTotal_ME_Prom_E'  
       SET @NomCol_ME = 'CostoTotal_MN_Prom_E'  
      END  
      ELSE IF (@IC_ES = 'S')  
      BEGIN  
       SET @NomCol = 'CostoTotal_ME_Prom_S'  
       SET @NomCol_ME = 'CostoTotal_MN_Prom_S'  
      END  
      ELSE IF (@IC_ES = 'A')  
      BEGIN  
       SET @NomCol = 'CostoTotal_ME_Prom_ES'  
       SET @NomCol_ME = 'CostoTotal_MN_Prom_ES'  
      END  
     END  
    END  
   END  
   ELSE  
   BEGIN  
    --Para los demás Indicadores Valores se asigna el nombre de las columnas ME de acuerdo a lo que tiene configurado en el MIS (Indicadores Valores Cabecera)  
    IF(@Cd_MdRg = '01')  
    BEGIN  
     IF (@NomCol='FiltroDetalleUnitario')  
     BEGIN  
      set @NomCol = 'Costo_MN'  
      set @NomCol_ME = 'Costo_ME'  
     END  
     ELSE IF (@NomCol='Filtro')  
     BEGIN  
      set @NomCol = 'Total_MN'  
      set @NomCol_ME = 'Total_ME'  
     END  
     ELSE  
     BEGIN  
      SET @NomCol = case when @NomCol like '%_MN' then @NomCol else CONCAT(@NomCol,'_MN') end
      SET @NomCol_ME = CONCAT(LEFT(@NomCol,LEN(@NomCol)-1),'E')
     END  
    END  
    ELSE  
    BEGIN  
     IF (@NomCol='FiltroDetalleUnitario')  
     BEGIN  
      set @NomCol = 'Costo_ME'  
      set @NomCol_ME = 'Costo_MN'  
     END  
     ELSE IF (@NomCol='Filtro')  
     BEGIN  
      set @NomCol = 'Total_ME'  
      set @NomCol_ME = 'Total_MN'  
     END  
     ELSE  
     BEGIN  
      SET @NomCol = case when @NomCol like '%_ME' then @NomCol else CONCAT(@NomCol,'_ME') end
      SET @NomCol_ME = CONCAT(LEFT(@NomCol,LEN(@NomCol)-1),'N')
     END  
    END  
   END  
  END  
 END  
   
  print '-Col   : ' + @nomCol          
  print '-ColME : ' + @nomCol_ME          
     PRINT '----------------'                                      
     IF @IC_PFI='f'                                      
     BEGIN                                      
  DECLARE @NomTablaVal VARCHAR(50)                                      
  IF (@NomCol='CFD') -- Cabecera FORmula con datos de Detalle                                      
  BEGIN                                      
   IF(@NomTablaDet <> NULL)                                      
    SET @NomTablaVal = @NomTablaDet        
   ELSE IF(@Cd_TM='13')                                      
   BEGIN                                      
    IF(@IC_DetCab='O')                           
     SET @NomTablaVal = 'FabEtaIns'                                      
    ELSE IF(@IC_DetCab='R')                                      
     SET @NomTablaVal = 'FabEtaRes'                                      
    ELSE IF(@IC_DetCab='M')                                      
     SET @NomTablaVal = 'FabEtapaComprobante'                                      
   END                                      
  END                                      
  ELSE                                       
   SET @NomTablaVal = @NomTabla                                      
                                      
  IF (@CD_TM = '21')                                     
  BEGIN                                      
   SET @sql = 'SELECT TOP 1 @Val_Ret = ' + @Fmla +' FROM ' +@NomTablaVal+ ' ('''+@RucE_P+''','''+@Ejer_P+''','''+@Cod_P + ''')' --TODO                                      
   EXEC sp_EXECutesql @sql, N'@Val_Ret NUMERIC(20,2) OUTPUT', @Val_Cal OUTPUT                                             
  END                                      
  ELSE IF (@CD_TM = '23')                                      
  BEGIN                
   SET @sql = 'SELECT TOP 1 @Val_Ret = ' + @Fmla +' FROM ' +@NomTablaVal+ ' WHERE C_RUC_COMPROBANTE_RETENCION= '''+@RucE_P+''' and '+@colCodTab+'= '''+@RegCtb_P + '''' --TODO                                   
   EXEC sp_EXECutesql @sql, N'@Val_Ret NUMERIC(20,2) OUTPUT', @Val_Cal OUTPUT                                      
  END                                      
  ELSE                                      
  BEGIN                                      
   SET @sql = 'SELECT TOP 1 @Val_Ret = ' + @Fmla +' FROM ' +@NomTablaVal+ ' WHERE RucE= '''+@RucE_P+''' and '+@colCodTab+'= '''+@Cod_P + '''' --TODO                                      
   EXEC sp_EXECutesql @sql, N'@Val_Ret NUMERIC(20,2) OUTPUT', @Val_Cal OUTPUT                                      
       END                                      
      END                                      
     ELSE                                       
      BEGIN                                      
                                      
      /******************DETRACCION COMPRA ****************************/        
       IF(@Cd_TM='16'  and @NomCol in ('ImpDetr' , 'ImpDetr_ORG') )                                      
       BEGIN                                      
        SET @IB_PgTot = 0                                      
                                              
        DECLARE @ITEMFINAL INT = (SELECT MAX(ITEM) FROM ASIENTO WHERE RUCE = @RucE_P AND CD_MIS = @Cd_MIS_P AND EJER = @Ejer_P)                                      
                                      
        IF @ITEMFINAL = @ITEM_ASIENTO                                      
         SET @IB_PgTot = 1                                      
       END                                      
      /**************************************************************/                                      
       IF(@Cd_TM='02' and @NomCol = 'ImpDetr' and @Cd_MdRg = '02')                                
        SET @NomCol = 'ImpDetr_ME'                                      
                
   /****************** DETRACCION VENTA ****************************/        
   IF(@Cd_TM='20' and @NomCol in ('C_IMPDETR','C_IMPDETR_REDONDEADO') /*AND @Cd_MdOr = '02'*/)        
   BEGIN        
  SET @NomCol_ME = CASE WHEN @NomCol='C_IMPDETR' THEN 'C_IMPDETRME' ELSE 'C_IMPDETRME_REDONDEADO' END        
        
  --IF @NomCol = 'C_IMPDETR'        
  -- SET @NomCol = 'C_IMPDETRME'        
  --ELSE         
  -- SET @NomCol = 'C_IMPDETRME_REDONDEADO'        
          
  SET @sql = 'SELECT TOP 1 @Val_Ret = ISNULL('+@NomCol+',0), @Val_Ret_ME = ISNULL('+@NomCol_ME+',0) FROM ' + @NomTabla + ' WHERE RucE= '''+@RucE_P+''' and '+@colCodTab+'= '''+@Cod_P + ''''        
        PRINT @sql      
  EXEC sp_EXECutesql @sql, N'@Val_Ret NUMERIC(20,2) OUTPUT, @Val_Ret_ME NUMERIC(20,2) OUTPUT', @Val_Cal OUTPUT, @Val_Cal_ME OUTPUT        
        
  --IF (@Val_Cal > 0 AND ISNULL(@CamMda,0) > 0)        
  --BEGIN           
  -- --SET @Val_Cal_ME = @Val_Cal        
  -- SET @Val_Cal = @Val_Cal * @CamMda        
  --END        
        
   --print 'Valor detraccion venta :' + convert(varchar, @Val_Cal)        
   END        
   /**************************************************************/         
        
      ELSE IF (@CD_TM = '21')                                      
        BEGIN                                      
         SET @sql = 'SELECT TOP 1 @Val_Ret = ISNULL('+@NomCol+',0) FROM ' +                                       
         @NomTabla +                                      
          ' ('''+@RucE_P+''','''+@Ejer_P+''','''+@Cod_P + ''')'                                        
                                                
         PRINT @sql                                      
         EXEC sp_EXECutesql @sql, N'@Val_Ret NUMERIC(20,2) OUTPUT', @Val_Cal OUTPUT                                           
        END                                      
       ELSE IF (@CD_TM = '23')                                      
        BEGIN                                      
         SELECT                                       
          @Val_Cal = SUM(Monto)                                      
         FROM                                      
          CONCEPTOXMOV                                      
         WHERE                                      
          RUCE = @RUCE_P AND C_REGISTRO_CONTABLE = @RegCtb_P                                      
         GROUP BY                                      
        C_REGISTRO_CONTABLE                                      
        END                                      
       ELSE IF (@CD_TM = '22')                                      
        BEGIN                                      
         SET @Val_Cal = (SELECT                                       
          TOP 1 Importe_Retencion_Total_Letra                                      
         FROM                                      
          DBO.VW_LETRA_PAGO_RETENCIONES                                      
         WHERE                                     
          Ruc_Empresa = @RUCE_P AND Codigo_Letra =  @ParametroAux1_P)                                      
        END                                      
       ELSE IF (@CD_TM = '25' OR @CD_TM = '26' OR @CD_TM = '27' OR @CD_TM = '28'  OR  @CD_TM = '30' OR  @CD_TM = '31')                                      
        BEGIN                                      
         SET @sql = 'SELECT TOP 1 @Val_Ret = ISNULL('+@NomCol+',0) FROM ' + @NomTabla  + ' WHERE RUC_EMPRESA = '''+@RucE_P+''' and '+@colCodTab+'= '''+@Cod_P + ''''                                      
         PRINT @sql                                      
         EXEC sp_EXECutesql @sql, N'@Val_Ret NUMERIC(20,2) OUTPUT', @Val_Cal OUTPUT                                      
        END                        
    ELSE IF (@CD_TM = '32')                        
        BEGIN                        
         SET @sql = 'SELECT TOP 1 @Val_Ret = ISNULL('+@NomCol+',0) FROM ' + @NomTabla  + ' WHERE C_RUC_EMPRESA = '''+@RucE_P+''' and '+@colCodTab+'= '''+@ParametroAux1_P + ''''                                      
         PRINT @sql                        
         EXEC sp_EXECutesql @sql, N'@Val_Ret NUMERIC(20,2) OUTPUT', @Val_Cal OUTPUT                        
        END                        
       ELSE IF (@CD_TM = '33')                        
        BEGIN                        
         SET @sql = 'SELECT TOP 1 @Val_Ret = ISNULL('+@NomCol+',0) FROM ' + @NomTabla  + ' WHERE C_RUC_EMPRESA = '''+@RucE_P+''' and '+@colCodTab+'= '''+@ParametroAux1_P + ''''                                      
         PRINT @sql                        
         EXEC sp_EXECutesql @sql, N'@Val_Ret NUMERIC(20,2) OUTPUT', @Val_Cal OUTPUT       
        END                        
      ELSE  IF (@Cd_TM = '17')          
   BEGIN          
          
    print @NomTabla +'---'+@NomTablaDet          
    print @NomCol +'---'+@NomCol_ME          
          
    SET @sql = 'SELECT TOP 1 @Val_Ret = ISNULL('+@NomCol+',0), @Val_Ret_ME = ISNULL('+@NomCol_ME+',0)           
    FROM '+ CASE WHEN @IC_DetCab = 'X' THEN @NomTabla ELSE @NomTablaDet END +'           
    WHERE RucE= '''+@RucE_P+''' and '+@colCodTab+'= '''+@Cod_P + ''''          
          
    PRINT 'SQL: ' + ISNULL(@sql, '')          
    EXEC sp_EXECutesql @sql, N'@Val_Ret NUMERIC(20,2) OUTPUT, @Val_Ret_ME NUMERIC(20,2) OUTPUT', @Val_Cal OUTPUT, @Val_Cal_ME OUTPUT          
   END          
 ELSE          
    BEGIN                        
        SET @sql = 'SELECT TOP 1 @Val_Ret = ISNULL('+@NomCol+',0) FROM ' +                                       
        --CASE WHEN @Cd_TM = '17' THEN (CASE WHEN @IC_DetCab = 'X' THEN @NomTabla ELSE @NomTablaDet END) ELSE                                      
        @NomTabla + ' WHERE RucE= '''+@RucE_P+''' and '+@colCodTab+'= '''+@Cod_P + ''''                                      
print '0000'                                      
        PRINT @sql          
 print '0000'            
        EXEC sp_EXECutesql @sql, N'@Val_Ret NUMERIC(20,2) OUTPUT', @Val_Cal OUTPUT          
    END                                             
                                      
       SET @Val_Cal = @Val_Cal * @Porc/100                                      
                                             
      END                                      
     PRINT 'valor : ' + CONVERT(VARCHAR,@Val_Cal)          
                                      
     IF @IC_CaAb='C'                                      
      BEGIN                                      
       SET @MtoD = @Val_Cal                                      
       SET @MtoH = 0.00          
       SET @MtoD_ME = @Val_Cal_ME  -- SOLO PARA INVENTARIO 2          
   SET @MtoH_ME = 0.00    -- SOLO PARA INVENTARIO 2          
      END                                      
     ELSE --IF @IC_CaAb='A'                                      
      BEGIN                                       
       SET @MtoD = 0.00                                      
       SET @MtoH = @Val_Cal          
       SET @MtoD_ME = 0.00    -- SOLO PARA INVENTARIO 2          
       SET @MtoH_ME = @Val_Cal_ME  -- SOLO PARA INVENTARIO 2                                   
      END                                      
                                      
     /*EN CASO DE MOV. INVENTARIO Y SALIDA NO SE EXTORNARÁ Al SER NEGATIVO EL MONTO */                                      
                                          
     IF(@Cd_TM = '05' and @IC_ES = 'S')                                      
      BEGIN                                      
       SET @MtoD = abs(@mtoD)                                      
       SET @MtoH = abs(@mtoH)            
       SET @MtoD_ME = abs(@mtoD_ME)                                      
       SET @MtoH_ME = abs(@mtoH_ME)           
                                       
      --/* EN CASO EL MOVIMIENTO TENGA TipCam DIFERENTES SE ENVIARÁ EL PROMEDIO */                                      
                                      
      IF(@Cd_TM = '05' and @IC_ES = 'S')                                      
       SELECT @CamMda =  sum(ISNULL(Total,0)) / Sum(ISNULL(Total_Me,0)) FROM Inventario WHERE RucE=@RucE_P and Ejer=@Ejer_P and RegCtb=@Cod_P                                        
      END                        
                                           
     IF(@MtoD<0)                                      
      BEGIN                                      
       SET @MtoH = abs(@MtoD)                                      
       SET @MtoD = 0          
       SET @MtoH_ME = abs(@MtoD_ME) -- SOLO PARA INVENTARIO 2          
       SET @MtoD_ME = 0    -- SOLO PARA INVENTARIO 2          
      END                             
     IF(@MtoH<0)    
      BEGIN                                      
       SET @MtoD = abs(@MtoH)                                      
       SET @MtoH = 0          
       SET @MtoD_ME = abs(@MtoH_ME) -- SOLO PARA INVENTARIO 2          
       SET @MtoH_ME = 0    -- SOLO PARA INVENTARIO 2                                
      END                                      
                                      
                                           
     PRINT CONVERT(VARCHAR,@MtoD) + '---' + CONVERT(VARCHAR,@MtoH)                                        
                                      
     -- ===========================================================================================================================================================                                      
                                            
     IF(@Cd_TM = '16')                                      
      SET @Cd_MdRg = '01'                                      
                                           
     IF(@Cd_TM = '20')                                      
      SET @Cd_MdRg = '01'                                      
                                           
     IF(@Cd_TM = '09')                                      
     BEGIN                                       
  SET @Cd_MdOr =(SELECT ISNULL((SELECT TOP 1 ISNULL(CD_MDA,'01') FROM PLANCTAS WHERE RUCE = @RucE_P AND EJER = @Ejer_P AND NROCTA = @NROCTA AND IB_CTASXCBR = 1),'01'))                                          
     END                                      
                                      
     IF(@Cd_TM = '08')                 
     BEGIN                                       
      SET @Cd_MdOr = (SELECT ISNULL((SELECT TOP 1 ISNULL(CD_MDA,'01') FROM PLANCTAS WHERE RUCE = @RucE_P AND EJER = @Ejer_P AND NROCTA = @NROCTA AND IB_CTASXPAG = 1),'01') )                                         
     END                                      
          
      print ''          
   print '-MtoD ' + CONVERT(VARCHAR,@MtoD)          
   print '-MtoH ' + CONVERT(VARCHAR,@MtoH)          
   print '-MtoD_ME ' + CONVERT(VARCHAR,@MtoD_ME)          
   print '-MtoH_ME ' + CONVERT(VARCHAR,@MtoH_ME)          
   print ''            
            
     IF (@Val_Cal != 0.00 OR @L_IB_PERMITIR_GENERAR_ASIENTO_MONTO_CERO = 1) AND ISNULL(@L_IB_TransferenciaGratuita,0) = 0                                  
      BEGIN                                                    
       SET @msj = ''                                               
          
       IF(ISNULL(@msj,'') = '')  
   BEGIN  
    EXEC contabilidad.Ctb_Voucher_Inserta_Mov_Asiento_Temp_2                                    
    @RucE_P, @Ejer_P, @Prdo, @RegCtb_P, @Cd_Fte, @FecMov, @FecCbr, @NroCta, @CtaAsoc, @Cd_Clt, @Cd_Prv, null, @Cd_TD,                                      
    @NroSre, @NroDoc, @FecED, @FecVD, @Glosa, @MtoD, @MtoH, @Cd_MdOr, @Cd_MdRg, @CamMda, @Cd_CC, @Cd_SC, @Cd_SS,                           
    @Cd_Area, @Cd_MR, @NroChke, @Cd_TG, @IC_CtrMd, @UsuCrea, null, @SaldoMN OUTPUT, @SaldoME OUTPUT, @TipMov,                                       
    @IC_TipAfec, @TipOper, @Grdo, @IC_Crea, @IB_PgTot, @L_IB_PROV, @DR_FecED, @DR_CdTD, @DR_NSre, @DR_NDoc,                                       
    @DR_NroDet, @DR_FecDet, NULL, NULL, @Cd_FPC, @Cd_FCP, NULL, NULL,      
    @CA01,@CA02,@CA03,@CA04,@CA05,@CA06,@CA07,@CA08,@CA09,@CA10,@CA11,@CA12,@CA13,@CA14,@CA15, @msj OUTPUT,                                              
    @L_REGCTB_REF, NULL, NULL, NULL,                                
    NULL,@L_ID_CONCEPTO_FEC, @L_IB_DEVOLUCION_IGV  ,@Ib_Agrup, @MtoD_ME, @MtoH_ME, @L_IGV_TASA,@Cd_MIS_P   
  
  
   END  
                                      
      END                                       
     -- ===========================================================================================================================================================                                      
      
     SET @msj = ''                                      
     SET @IC_Crea = 'T'                                      
     SET @IC_TipAfec = NULL                                      
     SET @Cd_Prv = NULL                                      
     SET @Cd_Clt = NULL                                      
     --SET @Cd_FPC = NULL                                      
                                      
     PRINT @Msj                                      
     PRINT '------ FIN LLAMA REGISTRO ' +@NomTabla+ ' ------'                                        
    END                                      
                                 
   --TODO                                      
   IF(@Cd_TM='13')                                      
    BEGIN                                      
     SET @Cod_P= @Cod_P + RIGHT(LEFT(@colCodTab,10),1)                                      
     SET @colCodTab = RIGHT(@colCodTab,7)                                 
    END                        
                         
   FETCH Cur_Asiento INTO @Cta, @CtaME, @IC_JDCtaPA, @IC_CaAb, @IN_TipoCta, @Cd_IV, @Porc, @Fmla, @IC_PFI, @Glosa_Fmla, @IC_VFG, @Cd_CC, @Cd_SC, @Cd_SS, @IC_JDCC,                             
                          @IB_Aux, @IB_EsDes, @Cd_IA, @IC_ES, @IB_Agrup, @ITEM_ASIENTO, @L_IB_PROV, @L_IB_DEVOLUCION_IGV                        
  END                                      
CLOSE Cur_Asiento                                      
DEALLOCATE Cur_Asiento                                      
                        
                        
                                     
-- FIN CURSOR ASIENTO                                      
                                      
/* INDICADOR ANULADO */                                      
IF @IB_Anulado = 1                                      
 UPDATE #tmp_TVoucher SET IB_Anulado = 1 WHERE RucE=@RucE_P and Ejer=@Ejer_P and RegCtb = @RegCtb_P                                      
                                      
--/* AJUSTE x CONVERSION y DESTINOS */                                      
DECLARE @Mto NUMERIC(20,2)                                      
DECLARE @Mto_ME NUMERIC(20,2)                                      
DECLARE @Cd_Mda CHAR(2)                                      
                                      
                                      
/* GANANCIAS Y PÉRDIDAS */                
SELECT                 
 @Mto = sum(MtoD - MtoH),                 
 @Mto_ME =sum(MtoD_ME - MtoH_ME),                 
 @Cd_Mda = Max(Cd_MdOr)                 
FROM                 
 #tmp_TVoucher                 
WHERE                 
 RucE = @RucE_P                 
 and RegCtb = @RegCtb_P                 
 and Ejer = @Ejer_P                      
  
/* DIFERENCIA AL PRODUCTO TERMINADO - PRODUCCIÓN */  
if(@Cd_TM = '17' and (@Mto <>0 or @Mto_ME <>0))  
BEGIN  
 UPDATE #tmp_TVoucher  
  SET MtoD -= @Mto,  
   MtoD_ME -= @Mto_ME  
 WHERE RucE=@RucE_P and Ejer=@Ejer_P and RegCtb = @RegCtb_P AND ISNULL(IB_EsProv,0) = 1  
 SELECT @Mto=0, @Mto_ME=0  
END  
                                      
IF(@Cd_Fte='CB' or @Cd_Fte='LD') and (@Mto <>0 or @Mto_ME <>0)                        
 BEGIN                                      
  DECLARE                         
  @Cta_DCPer NVARCHAR(50),                               
  @Cta_DCGan NVARCHAR(50)                                      
                                      
  SELECT  @Cta_DCPer = DCPer, @Cta_DCGan = DCGan FROM PlanCtasDef WHERE RucE=@RucE_P and Ejer=@Ejer_P                                      
                                      
  SET @Cd_Clt = NULL                                      
  SET @Cd_Prv = NULL                             
  SET @Cd_Trab = NULL                                      
  SET @Cd_TD = NULL                                      
  SET @NroSre = NULL                                      
  SET @NroDoc = NULL                            
          
  IF (@Mto_ME!=0)                                      
   BEGIN                                       
    SET @IC_CtrMd = '$'                                      
    SET @Cd_MdRg = '02'                                  
    IF(@Mto_ME<0)                                      
     BEGIN                                      
      SET @Mto_ME = abs(@Mto_ME)                                     
   SET @Mto = abs(@Mto)  
    
  
  EXEC contabilidad.Ctb_Voucher_Inserta_Registro_Asiento_Temp_2     
  @RucE_P, @Ejer_P, @Prdo, @RegCtb_P, @Cd_Fte, @FecMov, @FecCbr, @Cta_DCPer, NULL, NULL, NULL, NULL, NULL,                                      
  @FecED, @FecVD, @Glosa, @Mto_ME, 0.00, @Cd_MdOr, '02', @CamMda, @Cd_CC,                        
  @Cd_SC, @Cd_SS, @Cd_Area, @Cd_MR, @NroChke, @Cd_TG, '$', @UsuCrea, NULL, @IC_TipAfec, @TipOper, @Grdo, NULL,                                      
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL,      
  @CA01,@CA02,@CA03,@CA04,@CA05,@CA06,@CA07,@CA08,@CA09,@CA10,@CA11,@CA12,@CA13,@CA14,@CA15,      
  @msj OUTPUT,  
  @L_REGCTB_REF, NULL, NULL, NULL, null, null, @L_IB_DEVOLUCION_IGV,null, @Mto, 0.00,@L_IGV_TASA,@Cd_MIS_P        
                                      
     END                                      
    ELSE      
    
  EXEC contabilidad.Ctb_Voucher_Inserta_Registro_Asiento_Temp_2                                      
  @RucE_P, @Ejer_P, @Prdo, @RegCtb_P, @Cd_Fte, @FecMov, @FecCbr, @Cta_DCGan, NULL, NULL, NULL, NULL, NULL,                                      
  @FecED, @FecVD, @Glosa, 0.00, @Mto_ME, @Cd_MdOr, '02', @CamMda, @Cd_CC, @Cd_SC, @Cd_SS, @Cd_Area,                                       
  @Cd_MR, @NroChke, @Cd_TG, '$', @UsuCrea, NULL, @IC_TipAfec, @TipOper, @Grdo, NULL,                                      
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL,       
  @CA01,@CA02,@CA03,@CA04,@CA05,@CA06,@CA07,@CA08,@CA09,@CA10,@CA11,@CA12,@CA13,@CA14,@CA15,      
  @msj OUTPUT,                 
  @L_REGCTB_REF, NULL, NULL, NULL, null, null, @L_IB_DEVOLUCION_IGV,null, 0.00, @Mto,@L_IGV_TASA,@Cd_MIS_P        
                                      
   END                                      
  IF (@Mto!=0)                                      
   BEGIN                         
    SET @IC_CtrMd = 's'                                      
    SET @Cd_MdRg = '01'                                      
                                      
    IF(@Mto<0)                                      
     BEGIN                                      
      SET @Mto = abs(@Mto)                                      
      SET @Mto_ME = abs(@Mto_ME)   
     
  EXEC contabilidad.Ctb_Voucher_Inserta_Registro_Asiento_Temp_2                                      
  @RucE_P, @Ejer_P, @Prdo, @RegCtb_P, @Cd_Fte, @FecMov, @FecCbr, @Cta_DCPer, NULL, NULL, NULL, NULL, NULL,                                      
  @FecED, @FecVD, @Glosa, @Mto, 0.00, @Cd_MdOr, '01', @CamMda, @Cd_CC, @Cd_SC, @Cd_SS, @Cd_Area,                                       
  @Cd_MR, @NroChke, @Cd_TG, 's', @UsuCrea, NULL, @IC_TipAfec, @TipOper, @Grdo, NULL,                                      
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL,      
  @CA01,@CA02,@CA03,@CA04,@CA05,@CA06,@CA07,@CA08,@CA09,@CA10,@CA11,@CA12,@CA13,@CA14,@CA15,      
  @msj OUTPUT,                   
  @L_REGCTB_REF, NULL, NULL, NULL, null, null, @L_IB_DEVOLUCION_IGV, null, @Mto_ME, 0.00,@L_IGV_TASA,@Cd_MIS_P        
     END                                      
    ELSE        
    
  EXEC contabilidad.Ctb_Voucher_Inserta_Registro_Asiento_Temp_2                                      
  @RucE_P, @Ejer_P, @Prdo, @RegCtb_P, @Cd_Fte, @FecMov, @FecCbr, @Cta_DCGan, NULL, NULL, NULL, NULL, NULL,                                      
  @FecED, @FecVD, @Glosa, 0.00, @Mto, @Cd_MdOr, '01', @CamMda, @Cd_CC, @Cd_SC, @Cd_SS, @Cd_Area,                                       
  @Cd_MR, @NroChke, @Cd_TG, 's', @UsuCrea, NULL, @IC_TipAfec, @TipOper, @Grdo, NULL,                                      
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL,                                      
  @CA01,@CA02,@CA03,@CA04,@CA05,@CA06,@CA07,@CA08,@CA09,@CA10,@CA11,@CA12,@CA13,@CA14,@CA15,      
  @msj OUTPUT,                  
  @L_REGCTB_REF, NULL, NULL, NULL, null, null, @L_IB_DEVOLUCION_IGV, null, 0.00, @Mto_ME, @L_IGV_TASA,@Cd_MIS_P        
                                      
   END                                      
 END                        
                                      
BEGIN -- PARTIDA DOBLE                                      
                                       
 -- MONEDA PRINCIPAL                                      
 DECLARE @SALDO_A DECIMAL(20,2) = (SELECT SUM(MTOD) -  SUM(MtoH) FROM #tmp_TVoucher)                                      
                                       
 --MONEDA EXTRANJERA                                      
 DECLARE @SALDOME_A DECIMAL(20,2) = (SELECT SUM(MtoD_ME) -  SUM(MtoH_ME) FROM #tmp_TVoucher)                                      
                                      
 DECLARE                 
 @I INT = 0,                
 @B INT = 0                             
                                      
 SELECT  TOP 1                                       
  @B = ROW_NUMBER() OVER (ORDER BY MTOD DESC),                                      
  @I = CD_VOU                                      
 FROM #tmp_TVoucher  V INNER JOIN PlanCtas P ON V.RucE  = P.RUCE  AND V.Ejer  = P.EJER  AND V.NroCta  = P.NROCTA                         
  WHERE   ( (ISNULL(IC_TIPAFEC,'') IN ('S','E','C') AND ISNULL(C_IB_CUENTA_BASE,0) = 1  AND ISNULL(IB_EsProv,0) = 0 AND CD_MR NOT IN ('08','09')) OR ( ISNULL(IB_EsProv,0) = 1 AND CD_MR IN ('08','09')))  AND MTOD > 0                                       
                                        
  IF @I > 0                                       
  BEGIN                                      
  IF  @SALDO_A != 0 OR @SALDOME_A != 0                                      
  BEGIN                                      
   SET @DH_R = 'D'                                      
   UPDATE #tmp_TVoucher SET                                       
    MTOD = MTOD - @SALDO_A ,                                      
    MtoD_ME = MtoD_ME  - @SALDOME_A                                       
 WHERE Cd_Vou = @I AND (MtoH = 0 OR MtoH_ME = 0) AND (ABS(@SALDO_A) < MTOD OR ABS(@SALDOME_A) < MTOD_ME)                                      
  END                                      
 END                                      
 ELSE                                      
 BEGIN                      
  SELECT TOP 1                                       
   @B = ROW_NUMBER() OVER (ORDER BY MTOH DESC),                                      
   @I = CD_VOU                                      
  FROM #tmp_TVoucher  V INNER JOIN PlanCtas P ON V.RucE  = P.RUCE   AND V.Ejer  = P.EJER  AND V.NroCta  = P.NROCTA                         
   WHERE  ( (ISNULL(IC_TIPAFEC,'') IN ('S','E','C') AND ISNULL(C_IB_CUENTA_BASE,0) = 1 AND ISNULL(IB_EsProv,0) = 0 AND CD_MR NOT IN ('08','09')) OR ( ISNULL(IB_EsProv,0) = 1 AND CD_MR IN ('08','09')))  AND MTOH > 0                                      
  IF @I > 0                                      
   IF  @SALDO_A != 0  OR @SALDOME_A != 0                                      
   BEGIN                         
    SET @DH_R = 'H'                                      
    UPDATE #tmp_TVoucher SET                                       
     MTOH = MTOH  + @SALDO_A  ,                                      
     MtoH_ME = MtoH_ME + @SALDOME_A                                       
    WHERE Cd_Vou = @I AND (MtoD = 0 OR MtoD_ME = 0) AND (ABS(@SALDO_A) < MTOH OR ABS(@SALDOME_A) <  MtoH_ME)                                      
   END                                      
 END                                      
                                      
END                                      
                                      
BEGIN -- DESTINOS      
                                     DECLARE @Id int                          
                          
  DECLARE Voucher_cursor CURSOR FOR                                      
  SELECT DISTINCT C_CD_REF_DESTINO FROM #tmp_TVoucher WHERE ISNULL(C_CD_REF_DESTINO,0) > 0                                         
                                         
  OPEN Voucher_cursor                                      
                                      
  FETCH NEXT FROM Voucher_cursor                                      
  INTO @Id                                      
                                      
  WHILE @@FETCH_STATUS = 0                                        
  BEGIN                                        
                                         
   DECLARE @MTOD_DES DECIMAL(20,2),@MTOH_DES DECIMAL(20,2),@MTOD_ME_DES DECIMAL(20,2), @MTOH_ME_DES DECIMAL(20,2)          
                                         
   SELECT                                       
    @MTOD_DES = ISNULL(MTOD,0),                                       
    @MTOH_DES = ISNULL(MTOH,0),                                       
    @MTOD_ME_DES = ISNULL(MTOD_ME,0),                                       
    @MTOH_ME_DES = ISNULL(MTOH_ME,0)                                       
   FROM #tmp_TVoucher WHERE CD_VOU = @ID                                      
                                      
   DECLARE @MTOD_SUMA_DESTINOS DECIMAL(20,2), @MTOH_SUMA_DESTINOS DECIMAL(20,2),@MTOD_ME_SUMA_DESTINOS DECIMAL(20,2), @MTOH_ME_SUMA_DESTINOS DECIMAL(20,2)          
                                      
   SELECT                                       
    @MTOD_SUMA_DESTINOS = SUM(ISNULL(MTOD,0)),                                       
    @MTOH_SUMA_DESTINOS = SUM(ISNULL(MTOH,0)),                                       
    @MTOD_ME_SUMA_DESTINOS = SUM(ISNULL(MTOD_ME,0)),                  
    @MTOH_ME_SUMA_DESTINOS = SUM(ISNULL(MTOH_ME,0))                                       
   FROM #tmp_TVoucher WHERE C_CD_REF_DESTINO =  @ID                                      
                                      
   DECLARE @IC_FN CHAR(2), @IB_Ext BIT,@MtoD_Reg NUMERIC(20,2),@MtoH_Reg NUMERIC(20,2),@MtoD_Me_Reg NUMERIC(20,2),@MtoH_Me_Reg NUMERIC(20,2)          
                                       
   /*BUSCAMOS SU FUNCIÓN O NATURALEZA DE LA CUENTA A REGISTRAR PARA VERIFICAR EL EXTORNO*/                                       
                                              
   SELECT                                       
    @IC_FN = ISNULL(IC_IEF,IC_IEN),                                        
    @MtoD_Reg = ISNULL(MtoD,0),                                       
    @MtoH_Reg = ISNULL(MtoH,0),                                      
    @MtoD_Me_Reg = ISNULL(MtoD_ME,0),                                      
    @MtoH_Me_Reg = ISNULL(MtoH_ME,0),                                      
    @IC_CtrMd = IC_CtrMd                                      
   FROM #tmp_TVoucher vou INNER JOIN dbo.PlanCtas Pc                                       
    on vou.RucE  = Pc.RucE  and vou.Ejer  = pc.Ejer  and vou.NroCta  = pc.NroCta                         
   WHERE vou.RucE=@RucE_P and vou.Ejer=@Ejer_P and RegCtb = @RegCtb_P and Cd_Vou = @Id                                      
    GROUP BY MtoD, MtoH, MtoD_ME, MtoH_ME, IC_IEF, IC_IEN,IC_CtrMd                                      
                                      
   IF (@IC_FN LIKE 'E' and (@MtoH_Reg != 0 or @MtoH_Me_Reg != 0))                                      
      SET @IB_Ext = 1                                      
     ELSE IF  (@IC_FN LIKE 'I' and (@MtoD_Reg != 0 or @MtoD_Me_Reg != 0))   SET @IB_Ext = 1                                      
     ELSE                                      
      SET @IB_Ext = 0                                      
                                      
   DECLARE @DIFF DECIMAL(20,2)                                      
                                         
                                        
   delete from #tmp_TVoucher where C_CD_REF_DESTINO = @id                          
                          
   declare @Cd_Vou_Destino int = @ID                            
   declare @ItemDest int                          
   declare @IB_AMARRE_CUENTA_DESTINO_CENTRO_COSTO BIT                          
                             
   /*CONSULTA SI LA CUENTA TIENE HABILITADO EL INDICADOR DE CUENTA DESTINO O CUENTA DESTINO POR CENTRO DE COSTO*/                            
 IF EXISTS (SELECT 1 FROM #tmp_TVoucher T LEFT JOIN PlanCtas PC ON T.RucE  = PC.RucE  AND T.Ejer  = PC.Ejer  AND T.NroCta   = PC.NroCta                         
   WHERE Cd_Vou = @ID AND ISNULL(C_IB_CUENTA_DESTINO_CENTRO_COSTO,0) = 1)                          
  SET @IB_AMARRE_CUENTA_DESTINO_CENTRO_COSTO = 1                          
 ELSE IF EXISTS (SELECT 1 FROM #tmp_TVoucher T LEFT JOIN PlanCtas PC ON T.RucE  = PC.RucE  AND T.Ejer  = PC.Ejer  AND T.NroCta  = PC.NroCta                          
     WHERE Cd_Vou = @ID AND ISNULL(IB_CTAD,0) = 1)                          
  SET @IB_AMARRE_CUENTA_DESTINO_CENTRO_COSTO = 0                          
                          
 IF(@IB_AMARRE_CUENTA_DESTINO_CENTRO_COSTO = 1)                          
  BEGIN                          
   declare destino_cursor cursor for                          
    select A.C_ID from CONTABILIDAD.T_AMARRE_CUENTA_CENTRO_COSTO_DESTINOS A                                       
     inner join #tmp_TVoucher T                                       
    on                                      
      A.C_RUC_EMPRESA  = T.RucE                         
      and A.C_EJERCICIO  = T.Ejer                                        
      and A.C_CODIGO_CENTRO_COSTO + A.C_CODIGO_SUB_CENTRO_COSTO + A.C_CODIGO_SUB_SUB_CENTRO_COSTO   = T.Cd_cc + T.Cd_SC + T.Cd_SS                                      
    where                                       
     T.Cd_Vou = @ID                                
   open destino_cursor                          
  END                          
 ELSE IF (@IB_AMARRE_CUENTA_DESTINO_CENTRO_COSTO = 0)                          
  BEGIN                          
   declare destino_cursor cursor for                                       
    select A.Item from AmarreCta A                                       
     inner join #tmp_TVoucher T                                       
    on                                      
     A.RucE  = T.RucE                          
     and A.Ejer  = T.Ejer                         
     and A.NroCta  = T.NroCta                                       
    where                                       
     T.Cd_Vou = @ID                         
                                       
   open destino_cursor                          
  END                    
                                      
   fetch next from destino_cursor                                      
   into @ItemDest                                      
                  
   while @@FETCH_STATUS = 0                                      
   begin                                      
   set @Cd_Vou_Destino = @Cd_Vou_Destino + 1                                      
                                      
   declare @D_MtoD decimal(20,2)                                      
   declare @D_MtoH decimal(20,2)                                      
   declare @D_MtoD_ME decimal(20,2)                                      
   declare @D_MtoH_ME decimal(20,2)                                      
   declare @D_NroCtaD varchar(50)                                      
   declare @D_NroCtaH varchar(50)                                      
                             
                             
IF(@IB_AMARRE_CUENTA_DESTINO_CENTRO_COSTO = 1)                          
 BEGIN                          
  select                                       
   @D_MtoD = isnull((CASE WHEN T.MtoD = 0 THEN T.MtoH ELSE T.MtoD END) * A.C_PORCENTAJE / 100,0),                                      
   @D_MtoH = isnull((CASE WHEN T.MtoD = 0 THEN T.MtoH ELSE T.MtoD END) * A.C_PORCENTAJE / 100,0),                                      
   @D_MtoD_ME = isnull((CASE WHEN T.MtoD_ME = 0 THEN T.MtoH_ME ELSE T.MtoD_ME END) * A.C_PORCENTAJE / 100,0),                                      
   @D_MtoH_ME = isnull((CASE WHEN T.MtoD_ME = 0 THEN T.MtoH_ME ELSE T.MtoD_ME END) * A.C_PORCENTAJE / 100,0),                                 
   @D_NroCtaD = CASE WHEN @IB_Ext = 1 THEN A.C_NUMERO_CUENTA_HASTA ELSE A.C_NUMERO_CUENTA_DEBE END,                                    
   @D_NroCtaH = CASE WHEN @IB_Ext = 1 THEN A.C_NUMERO_CUENTA_DEBE ELSE A.C_NUMERO_CUENTA_HASTA END                                    
  from                                       
   CONTABILIDAD.T_AMARRE_CUENTA_CENTRO_COSTO_DESTINOS A                                                
   inner join #tmp_TVoucher T                                      
  on                                       
   A.C_RUC_EMPRESA  = T.RucE                         
   and A.C_EJERCICIO  = T.Ejer                         
   and A.C_CODIGO_CENTRO_COSTO + A.C_CODIGO_SUB_CENTRO_COSTO + A.C_CODIGO_SUB_SUB_CENTRO_COSTO  = T.Cd_cc + T.Cd_SC + T.Cd_SS                            
  where                         
   Cd_Vou = @id                                      
   and C_ID = @ItemDest                           
 END                          
ELSE IF (@IB_AMARRE_CUENTA_DESTINO_CENTRO_COSTO = 0)                          
      BEGIN                          
  select                                       
   @D_MtoD = isnull((CASE WHEN T.MtoD = 0 THEN T.MtoH ELSE T.MtoD END) * A.Porc / 100,0),                                      
   @D_MtoH = isnull((CASE WHEN T.MtoD = 0 THEN T.MtoH ELSE T.MtoD END) * A.Porc / 100,0),                                      
   @D_MtoD_ME = isnull((CASE WHEN T.MtoD_ME = 0 THEN T.MtoH_ME ELSE T.MtoD_ME END) * A.Porc / 100,0),                                      
   @D_MtoH_ME = isnull((CASE WHEN T.MtoD_ME = 0 THEN T.MtoH_ME ELSE T.MtoD_ME END) * A.Porc / 100,0),                                   
   @D_NroCtaD = CASE WHEN @IB_Ext = 1 THEN A.CtaH ELSE A.CtaD END,                                    
   @D_NroCtaH = CASE WHEN @IB_Ext = 1 THEN A.CtaD ELSE A.CtaH END                                    
  from                                       
   AmarreCta A                                      
   inner join #tmp_TVoucher T                                      
  on                                       
   A.RucE  = T.RucE                                      
   and A.Ejer  = T.Ejer                                      
   and A.NroCta  = T.NroCta                                      
  where                                       
   Cd_Vou = @id                                      
   and Item = @ItemDest                             
 END                                  
                                      
   insert into #tmp_TVoucher                                      
   (                                      
    RucE                                       
    ,Cd_Vou  --geneado                                      
    ,C_CD_REF_DESTINO --cd_vou                                  
    ,Ejer                                       
    ,Prdo                                       
    ,RegCtb                                       
    ,Cd_Fte                                       
    ,FecMov                       
    ,FecCbr                                       
    ,NroCta --jala amarre                                      
    ,Cd_Aux                                       
    ,Cd_TD                                       
    ,NroSre                                       
    ,NroDoc                                       
    ,FecED                                       
    ,FecVD                                       
    ,Glosa                                       
    ,MtoOr                                       
    ,MtoD --jala amarre                                      
    ,MtoH --jala amarre                                      
    ,MtoD_ME --jala amarre       
    ,MtoH_ME --jala amarre                                      
    ,Cd_MdOr                                       
 ,Cd_MdRg                                       
    ,CamMda                                       
    ,Cd_CC                                       
    ,Cd_SC                                       
    ,Cd_SS                                       
    ,Cd_Area         
    ,Cd_MR                                       
    ,Cd_TG                                       
    ,IC_CtrMd                                       
    ,IC_TipAfec --null                                      
    ,TipOper --null                                      
    ,NroChke --null                                      
    ,Grdo  --null                                      
    ,IB_Cndo --null                                      
    ,IB_Conc --null                                      
    ,IB_EsProv  --0                                      
    ,FecReg                                       
    ,FecMdf                                       
   ,UsuCrea                                       
    ,UsuModf                                       
    ,IB_Anulado                                       
    ,DR_CdVou                                       
    ,DR_FecED                                
    ,DR_CdTD                                       
    ,DR_NSre                                       
    ,DR_NDoc                                       
    ,IC_Gen                                       
    ,FecConc                                       
    ,IB_EsDes -- 1                                      
    ,DR_NCND                                       
    ,DR_NroDet                                       
    ,DR_FecDet                                       
    ,Cd_Clt                                       
    ,Cd_Prv                                       
    ,IB_Imdo --null                                      
    ,CA01                                       
    ,CA02                                       
    ,Cd_TMP                                       
    ,CA03                                       
    ,CA04                                       
    ,CA05                                       
    ,CA06                                       
    ,CA07                                       
    ,CA08                                       
    ,CA09                                       
    ,CA10                          
    ,CA11                                       
    ,CA12                                       
    ,CA13                                       
    ,CA14                                       
    ,CA15                                       
    ,CodT                                       
    ,Cd_Trab                                       
 ,Cd_FPC                                       
    ,Cd_FCP                                       
    ,Id_TMP                                       
    ,FecDif                                       
    ,C_CORRELATIVO                                       
    ,C_REGCTB_REF                                       
    ,C_CANTIDAD_TITULO                                       
    ,C_CODIGO_PATRIMONIO                                       
    ,C_CODIGO_TITULO                                       
    ,C_CODIGO_DETALLE_PATRIMONIO_SBS                                     
 ,C_IB_AGRUPADO          
 ,C_IGV_TASA          
   )                                         
   select                                       
    RucE                                       
    ,@Cd_Vou_Destino  --geneado                                      
    ,Cd_Vou --cd_vou                                      
    ,Ejer                                       
    ,Prdo                                       
    ,RegCtb                                       
    ,Cd_Fte                                       
    ,FecMov                                       
    ,FecCbr            
    ,@D_NroCtaD --NroCta --jala amarre                                      
    ,Cd_Aux                                       
    ,Cd_TD                                       
    ,NroSre                                       
    ,NroDoc                                       
    ,FecED                                       
    ,FecVD                                       
    ,Glosa                                       
    ,MtoOr                                       
    ,@D_MtoD --MtoD --jala amarre                                      
    ,0 --MtoH --jala amarre                                      
    ,@D_MtoD_ME --MtoD_ME --jala amarre                              
    ,0 --MtoH_ME --jala amarre                                      
    ,Cd_MdOr                                       
    ,Cd_MdRg                                       
    ,CamMda                                       
    ,Cd_CC                                       
    ,Cd_SC                                       
    ,Cd_SS                                       
    ,Cd_Area                                       
    ,Cd_MR                                       
    ,Cd_TG                                       
   ,IC_CtrMd                                
    ,null--IC_TipAfec --null                                      
    ,null--TipOper --null                                      
    ,null--NroChke --null                                      
    ,null--Grdo  --null                                      
    ,null--IB_Cndo --null                                      
    ,null--IB_Conc --null                                      
    ,0--IB_EsProv  --0                                      
    ,FecReg                                       
    ,FecMdf                                       
    ,UsuCrea                                       
    ,UsuModf                                   
 ,IB_Anulado                                       
    ,DR_CdVou                                       
    ,DR_FecED                                       
    ,DR_CdTD                                       
    ,DR_NSre                                       
    ,DR_NDoc                                       
    ,IC_Gen                                       
    ,FecConc                                       
    ,1 -- esDestino                                      
    ,DR_NCND                                       
    ,DR_NroDet                                       
    ,DR_FecDet                                       
    ,Cd_Clt                                       
    ,Cd_Prv                                       
    ,1--IB_Imdo --null                                      
    ,CA01                                       
    ,CA02                                       
    ,Cd_TMP                                       
    ,CA03                                       
    ,CA04                                       
    ,CA05                                     
    ,CA06                                       
    ,CA07                                       
    ,CA08                                       
    ,CA09                                       
    ,CA10                                       
    ,CA11                                       
    ,CA12                                       
    ,CA13                                       
    ,CA14                                       
    ,CA15                                       
    ,CodT                                       
    ,Cd_Trab                                       
    ,Cd_FPC                                       
    ,Cd_FCP                                       
    ,Id_TMP                                       
    ,FecDif                                       
    ,C_CORRELATIVO                                       
,C_REGCTB_REF                                       
    ,C_CANTIDAD_TITULO                                       
    ,C_CODIGO_PATRIMONIO                                       
    ,C_CODIGO_TITULO  
 ,C_CODIGO_DETALLE_PATRIMONIO_SBS                                
 ,C_IB_AGRUPADO          
 ,C_IGV_TASA         
   from                                       
   #tmp_TVoucher                                      
   where Cd_Vou = @ID                                      
        
   set @Cd_Vou_Destino = @Cd_Vou_Destino + 1                                      
                                      
   insert into #tmp_TVoucher                                      
   (                                      
    RucE                                       
    ,Cd_Vou  --geneado                                      
    ,C_CD_REF_DESTINO --cd_vou                     
    ,Ejer                                       
    ,Prdo                                       
    ,RegCtb                                       
    ,Cd_Fte                                       
    ,FecMov                                       
    ,FecCbr                                       
    ,NroCta --jala amarre                                      
    ,Cd_Aux                                       
    ,Cd_TD                                       
    ,NroSre                                       
    ,NroDoc                                       
    ,FecED                                       
    ,FecVD                                       
    ,Glosa                                       
    ,MtoOr                                       
    ,MtoD --jala amarre                                      
    ,MtoH --jala amarre                                      
    ,MtoD_ME --jala amarre                                      
    ,MtoH_ME --jala amarre                                      
    ,Cd_MdOr                                       
    ,Cd_MdRg                       
    ,CamMda                                       
    ,Cd_CC                                       
    ,Cd_SC                                       
    ,Cd_SS                                
    ,Cd_Area                                       
    ,Cd_MR                                       
    ,Cd_TG                                       
    ,IC_CtrMd                                       
    ,IC_TipAfec --null                                      
    ,TipOper --null                                      
    ,NroChke --null                                      
    ,Grdo  --null                                      
    ,IB_Cndo --null                                      
    ,IB_Conc --null                                      
    ,IB_EsProv  --0                                      
    ,FecReg                                       
    ,FecMdf                                       
    ,UsuCrea                                       
    ,UsuModf                                       
    ,IB_Anulado                                       
    ,DR_CdVou                                       
    ,DR_FecED                                       
    ,DR_CdTD                                       
    ,DR_NSre                                       
    ,DR_NDoc                                       
    ,IC_Gen                                       
    ,FecConc                                       
    ,IB_EsDes -- 1                                      
    ,DR_NCND                                       
    ,DR_NroDet                                       
    ,DR_FecDet                                       
    ,Cd_Clt                                       
    ,Cd_Prv                                       
    ,IB_Imdo --null                                      
    ,CA01                                     
    ,CA02                                       
    ,Cd_TMP                                       
    ,CA03                                       
    ,CA04                                       
    ,CA05                                       
    ,CA06                                       
    ,CA07                                       
    ,CA08                                       
    ,CA09                                       
    ,CA10                                       
    ,CA11                     ,CA12                             
    ,CA13                                       
    ,CA14                                       
    ,CA15                                       
    ,CodT                                       
    ,Cd_Trab                                       
    ,Cd_FPC                                       
    ,Cd_FCP                                       
    ,Id_TMP                                       
    ,FecDif                                       
    ,C_CORRELATIVO                                       
    ,C_REGCTB_REF                                       
    ,C_CANTIDAD_TITULO                                       
    ,C_CODIGO_PATRIMONIO                                       
    ,C_CODIGO_TITULO                                       
    ,C_CODIGO_DETALLE_PATRIMONIO_SBS                 
 ,C_IB_AGRUPADO          
 ,C_IGV_TASA          
   )                                         
   select                                       
    RucE                                       
    ,@Cd_Vou_Destino  --geneado                                      
    ,Cd_Vou --cd_vou                                      
    ,Ejer                                       
    ,Prdo                                       
    ,RegCtb                         
    ,Cd_Fte                                       
    ,FecMov                                       
    ,FecCbr                                       
    ,@D_NroCtaH --NroCta --jala amarre                                      
    ,Cd_Aux                                       
    ,Cd_TD                                       
    ,NroSre                                       
    ,NroDoc                                       
    ,FecED                                       
    ,FecVD                                       
    ,Glosa                                       
    ,MtoOr                                       
    ,0 --MtoD --jala amarre                                      
    ,@D_MtoH --MtoH --jala amarre                                      
    ,0 --MtoD_ME --jala amarre                                      
    ,@D_MtoH_ME --MtoH_ME --jala amarre                                      
    ,Cd_MdOr                                       
    ,Cd_MdRg                                       
    ,CamMda                           
    ,Cd_CC                                       
    ,Cd_SC                                       
    ,Cd_SS                                       
    ,Cd_Area                                       
    ,Cd_MR                                       
    ,Cd_TG                                       
    ,IC_CtrMd                                       
    ,null--IC_TipAfec --null                                      
    ,null--TipOper --null                            
    ,null--NroChke --null                                      
    ,null--Grdo  --null                                      
    ,null--IB_Cndo --null                                      
    ,null--IB_Conc --null                                      
    ,0--IB_EsProv  --0                                      
    ,FecReg                                       
    ,FecMdf                                       
    ,UsuCrea                                       
    ,UsuModf                                       
    ,IB_Anulado                                       
    ,DR_CdVou                                       
    ,DR_FecED                                       
    ,DR_CdTD                                       
    ,DR_NSre                                       
    ,DR_NDoc                                       
    ,IC_Gen                                       
    ,FecConc             
    ,1 -- esDestino                                      
    ,DR_NCND                       
    ,DR_NroDet                                       
    ,DR_FecDet                                       
    ,Cd_Clt                                       
    ,Cd_Prv                                       
    ,1--IB_Imdo --null                                
    ,CA01                                       
    ,CA02                                       
    ,Cd_TMP                                       
    ,CA03                                       
    ,CA04                                       
    ,CA05                                       
    ,CA06                                       
    ,CA07                                       
    ,CA08                                       
    ,CA09                                       
    ,CA10                   
    ,CA11                                       
    ,CA12                                       
    ,CA13                                       
    ,CA14                                       
    ,CA15                                       
    ,CodT                                       
    ,Cd_Trab                                       
    ,Cd_FPC                                       
    ,Cd_FCP             
    ,Id_TMP                                       
    ,FecDif                                       
    ,C_CORRELATIVO                                       
    ,C_REGCTB_REF                                       
    ,C_CANTIDAD_TITULO                                       
    ,C_CODIGO_PATRIMONIO                                       
    ,C_CODIGO_TITULO                                       
    ,C_CODIGO_DETALLE_PATRIMONIO_SBS                                      
 ,C_IB_AGRUPADO          
 ,C_IGV_TASA          
   from                                       
   #tmp_TVoucher                                      
   where Cd_Vou = @ID                                      
           
   fetch next from destino_cursor                                      
   into @ItemDest                                         
   end                                      
   close destino_cursor                                      
   deallocate destino_cursor                                      
                                      
   SELECT                                       
    @MTOD_DES = ISNULL(MTOD,0),                                       
    @MTOH_DES = ISNULL(MTOH,0),                                       
    @MTOD_ME_DES = ISNULL(MTOD_ME,0),                                       
    @MTOH_ME_DES = ISNULL(MTOH_ME,0)                                       
   FROM #tmp_TVoucher WHERE CD_VOU = @ID                                      
                            
   SELECT                                       
    @MTOD_SUMA_DESTINOS = SUM(ISNULL(MTOD,0)),                                 
    @MTOH_SUMA_DESTINOS = SUM(ISNULL(MTOH,0)),                                       
    @MTOD_ME_SUMA_DESTINOS = SUM(ISNULL(MTOD_ME,0)),                                       
    @MTOH_ME_SUMA_DESTINOS = SUM(ISNULL(MTOH_ME,0))                                       
   FROM #tmp_TVoucher WHERE C_CD_REF_DESTINO =  @ID                                      
                                      
 IF @MTOD_DES != 0                                      
 BEGIN                                      
 IF @MTOD_DES != @MTOD_SUMA_DESTINOS                                      
 BEGIN        
  SET @DIFF = @MTOD_DES - @MTOD_SUMA_DESTINOS        
          
  UPDATE  #tmp_TVoucher        
  SET                     
  MTOH = MTOH + @DIFF        
  WHERE CD_VOU = (SELECT TOP 1 CD_VOU FROM #tmp_TVoucher WHERE C_CD_REF_DESTINO = @ID AND MTOH != 0/*MTOH > 0*/ ORDER BY MTOH DESC)        
        
  UPDATE  #tmp_TVoucher        
  SET               
  MTOD = MTOD + @DIFF        
  WHERE CD_VOU = (SELECT TOP 1 CD_VOU FROM #tmp_TVoucher WHERE C_CD_REF_DESTINO = @ID AND MTOD != 0/*MTOD >0 */  ORDER BY MTOD DESC)        
 END                                      
 END                                      
                                      
 IF @MTOD_ME_DES != 0                                      
  BEGIN                                      
  IF @MTOD_ME_DES != @MTOD_ME_SUMA_DESTINOS                                      
  BEGIN                                      
  SET @DIFF = @MTOD_ME_DES - @MTOD_ME_SUMA_DESTINOS                          
                                      
  UPDATE  #tmp_TVoucher                                      
   SET                                       
   MTOH_ME = MTOH_ME + @DIFF                                      
  WHERE CD_VOU = (SELECT TOP 1 CD_VOU FROM #tmp_TVoucher WHERE C_CD_REF_DESTINO = @ID AND MTOH_ME != 0/*MTOH_ME > 0*/ ORDER BY MTOH_ME DESC)                                       
                                      
  UPDATE  #tmp_TVoucher                                      
   SET                                       
   MTOD_ME = MTOD_ME + @DIFF                                      
  WHERE CD_VOU = (SELECT TOP 1 CD_VOU FROM #tmp_TVoucher WHERE C_CD_REF_DESTINO = @ID AND  MTOD_ME != 0/*MTOD_ME > 0*/ ORDER BY MTOD_ME DESC)                                       
  END                                      
  END                                      
 IF @MTOH_DES != 0                                      
  BEGIN                                      
  IF @MTOH_DES != @MTOH_SUMA_DESTINOS                                 
  BEGIN                                      
   SET @DIFF  = @MTOH_DES - @MTOH_SUMA_DESTINOS                                      
                                      
   UPDATE  #tmp_TVoucher                                      
   SET                                       
   MTOD = MTOD + @DIFF                                      
   WHERE CD_VOU = (SELECT TOP 1 CD_VOU FROM #tmp_TVoucher WHERE C_CD_REF_DESTINO = @ID AND MTOD != 0/*MTOD > 0*/ ORDER BY MTOD DESC)                                       
                                      
   UPDATE  #tmp_TVoucher                                      
   SET                                       
   MTOH = MTOH + @DIFF                                      
   WHERE CD_VOU = (SELECT TOP 1 CD_VOU FROM #tmp_TVoucher WHERE C_CD_REF_DESTINO = @ID AND MTOH != 0/*MTOH > 0*/ ORDER BY MTOH DESC)                                       
  END                                   
  END                                      
 IF @MTOH_ME_DES != 0                                      
  BEGIN        
  IF @MTOH_ME_DES != @MTOH_ME_SUMA_DESTINOS                                      
  BEGIN                                      
   SET @DIFF = @MTOH_ME_DES - @MTOH_ME_SUMA_DESTINOS                                      
   UPDATE  #tmp_TVoucher                                      
   SET                                       
   MTOD_ME = MTOD_ME + @DIFF                                      
   WHERE CD_VOU = (SELECT TOP 1 CD_VOU FROM #tmp_TVoucher WHERE C_CD_REF_DESTINO = @ID AND MTOD_ME != 0/*MTOD_ME > 0*/ ORDER BY MTOD_ME DESC)                                       
                                      
   UPDATE  #tmp_TVoucher                                      
   SET                                       
   MTOH_ME = MTOH_ME + @DIFF                         
   WHERE CD_VOU = (SELECT TOP 1 CD_VOU FROM #tmp_TVoucher WHERE C_CD_REF_DESTINO = @ID AND MTOH_ME != 0/*MTOH_ME > 0*/ ORDER BY MTOH_ME DESC)                                       
  END                                      
  END                         
        
  FETCH NEXT FROM Voucher_cursor        
   INTO @Id        
  END        
  CLOSE Voucher_cursor;        
  DEALLOCATE Voucher_cursor;        
           
END                                      
                             
BEGIN -- REGISTRO DE ASIENTO                                      
        
IF EXISTS(SELECT 1 FROM #tmp_TVoucher WHERE ISNULL(C_IB_AGRUPADO,0) = 1)                                
 EXEC CONTABILIDAD.USP_T_VOUCHER_AGRUPAR_CUENTAS                          
            
                      
--REGISTRO VOUCHER                          
INSERT INTO Voucher                         
 (RucE, Ejer, Prdo, RegCtb, Cd_Fte, FecMov, FecCbr, NroCta, Cd_TD, NroSre, NroDoc, FecED, FecVD, Glosa, MtoOr, MtoD, MtoH, MtoD_ME, MtoH_ME,                           
 Cd_MdOr, Cd_MdRg, CamMda, Cd_CC, Cd_SC, Cd_SS, Cd_Area, Cd_MR, Cd_TG, IC_CtrMd, IC_TipAfec, TipOper, NroChke, Grdo, Ib_Cndo, Ib_Conc, IB_EsProv,                           
 FecReg, FecMdf, UsuCrea, UsuModf, IB_Anulado, DR_FecED, DR_CdTD, DR_NSre, DR_NDoc, FecConc, Ib_EsDes, DR_NCND, DR_NroDet, DR_FecDet,                           
 Cd_Clt, Cd_Prv, Ib_Imdo, Cd_Trab, Cd_FPC, Cd_FCP, Id_TMP, FecDIF, C_REGCTB_REF, C_CANTIDAD_TITULO, C_CODIGO_PATRIMONIO, C_CODIGO_TITULO,                         
 C_CODIGO_DETALLE_PATRIMONIO_SBS, C_ID_CONCEPTO_FEC, C_IB_DEVOLUCION_IGV, C_IGV_TASA,CA01,CA02,CA03,CA04,CA05,CA06,CA07,CA08,CA09,CA10,CA11,CA12,CA13,CA14,CA15)                          
   
SELECT RucE, Ejer, Prdo, RegCtb, Cd_Fte, FecMov, FecCbr, NroCta, Cd_TD, NroSre, NroDoc, FecED, FecVD, Glosa, 0.00, MtoD, MtoH, MtoD_ME, MtoH_ME,          
 Cd_MdOr, Cd_MdRg, CamMda, Cd_CC, Cd_SC, Cd_SS, Cd_Area, Cd_MR, Cd_TG, IC_CtrMd, IC_TipAfec, TipOper, NroChke, Grdo, Ib_Cndo, Ib_Conc, IB_EsProv,                           
 GETDATE(), FecMdf, UsuCrea, UsuModf, IB_Anulado, DR_FecED, DR_CdTD, DR_NSre, DR_NDoc, FecConc, Ib_EsDes, DR_NCND, DR_NroDet, DR_FecDet,                           
 Cd_Clt, Cd_Prv, Ib_Imdo, Cd_Trab, Cd_FPC, Cd_FCP, Id_TMP, FecDIF, C_REGCTB_REF, C_CANTIDAD_TITULO, C_CODIGO_PATRIMONIO, C_CODIGO_TITULO,                         
 C_CODIGO_DETALLE_PATRIMONIO_SBS, C_ID_CONCEPTO_FEC, C_IB_DEVOLUCION_IGV, C_IGV_TASA,CA01,CA02,CA03,CA04,CA05,CA06,CA07,CA08,CA09,CA10,CA11,CA12,CA13,CA14,CA15          
FROM #tmp_TVoucher ORDER BY cd_vou    
  
--PRINT 'LETRA CANJE 2'  
  
  
update #tmp_TVoucher                        
set #tmp_TVoucher.C_CD_VOU_TEMP = t2.cd_vou                        
from                         
#tmp_TVoucher t1,                        
(select ROW_NUMBER()over (order by cd_vou) as ID, Cd_Vou from Voucher with(nolock) where RucE = @RUCE_P and Ejer = @EJER_P and RegCtb = @REGCTB_P) t2                        
where                        
t1.cd_vou = t2.ID                        
                        
                        
--REGISTRO VOUCHERRM                        
INSERT INTO VoucherRM                           
 (RucE, RegCtb, Ejer, Cd_Vou, NroCta, Cd_TD, NroDoc, Debe, Haber, Cd_Mda, Cd_Area, Cd_MR, Usu, FecMov, Cd_Est)                          
SELECT                           
RucE, RegCtb, Ejer, C_CD_VOU_TEMP, NroCta, Cd_TD, NroDoc, MtoD, MtoH, Cd_MdRg, Cd_Area, Cd_MR, UsuCrea, GETDATE(), '01'                          
FROM #tmp_TVoucher                        
                        
          
print '====REGISTRO NO DOMICILIADO===='        
        
DECLARE @L_DOC_NO_DOMICILIADO NVARCHAR(100) = '91,00,97,98'        
        
SELECT 1 FROM                         
 VOUCHER V                         
 INNER JOIN PLANCTAS PC ON PC.RUCE = V.RUCE AND PC.EJER = V.EJER AND PC.NROCTA = V.NROCTA                         
WHERE                         
 V.RUCE = @RUCE_P AND V.EJER = @EJER_P AND V.REGCTB = @REGCTB_P                         
 AND ISNULL(V.IB_ESPROV,0) = 1 AND ISNULL(pc.IB_CtasXPag, 0) = 1        
 AND v.Cd_Fte = 'RC' AND CHARINDEX(v.Cd_TD,@L_DOC_NO_DOMICILIADO)>0        
        
/*Validamos existencia de algun registro del asiento que cumpla con las condiciones e insertamos en la temporal*/        
IF EXISTS(SELECT 1 FROM                         
     VOUCHER V                         
     INNER JOIN PLANCTAS PC ON PC.RUCE = V.RUCE AND PC.EJER = V.EJER AND PC.NROCTA = V.NROCTA                         
    WHERE                         
     V.RUCE = @RUCE_P AND V.EJER = @EJER_P AND V.REGCTB = @REGCTB_P                         
     AND ISNULL(V.IB_ESPROV,0) = 1 AND ISNULL(pc.IB_CtasXPag, 0) = 1        
     AND v.Cd_Fte = 'RC' AND CHARINDEX(v.Cd_TD,@L_DOC_NO_DOMICILIADO)>0)        
BEGIN        
 INSERT INTO #T_NO_DOMICILIADO_VOUCHER_TEMP            
  (C_RUC_EMPRESA,C_CODIGO_VOUCHER,C_CD_BENEFICIARIO,C_NRO_TV,C_RENTA_BRUTA,C_DEDUCCION_COSTO_CAPITAL,C_RENTA_NETA,        
   C_TASA_RET,C_IMPUESTO_RET,C_IGV_RET,C_NRO_CEDT,C_NRO_EOND,C_NRO_TR,C_NRO_MS,C_APLICACION_ART)            
 SELECT                         
  v.RucE, v.Cd_Vou,@L_CD_BENEFICIARIO,@L_NRO_TV,@L_RENTA_BRUTA,@L_DEDUCCION_COSTO_CAPITAL,@L_RENTA_NETA,@L_TASA_RET,        
  @L_IMPUESTO_RET,@L_IGV_RET,@L_NRO_CEDT,@L_NRO_EOND,@L_NRO_TR,@L_NRO_MS,@L_APLICACION_ART                      
 FROM                         
  VOUCHER V                         
  INNER JOIN PLANCTAS PC ON PC.RUCE = V.RUCE AND PC.EJER = V.EJER AND PC.NROCTA = V.NROCTA                         
 WHERE                         
  V.RUCE = @RUCE_P AND V.EJER = @EJER_P AND V.REGCTB = @REGCTB_P                         
  AND ISNULL(V.IB_ESPROV,0) = 1 AND ISNULL(pc.IB_CtasXPag, 0) = 1        
  AND v.Cd_Fte = 'RC' AND CHARINDEX(v.Cd_TD,@L_DOC_NO_DOMICILIADO)>0        
  AND (ISNULL(@L_CD_BENEFICIARIO,'')<>'' OR ISNULL(@L_NRO_TV,'')<>'' OR ISNULL(@L_RENTA_BRUTA,0)<>0 OR ISNULL(@L_DEDUCCION_COSTO_CAPITAL,0)<>0 OR             
   ISNULL(@L_RENTA_NETA,0)<>0 OR ISNULL(@L_TASA_RET,0)<>0 OR ISNULL(@L_IMPUESTO_RET,0)<>0 OR ISNULL(@L_IGV_RET,0)<>0 OR         
   ISNULL(@L_NRO_CEDT,'')<>'' OR ISNULL(@L_NRO_EOND,'')<>'' OR ISNULL(@L_NRO_TR,'')<>'' OR ISNULL(@L_NRO_MS,'')<>'' OR             
   ISNULL(@L_APLICACION_ART,'')<>'')           
END        
IF EXISTS(SELECT 1 FROM #T_NO_DOMICILIADO_VOUCHER_TEMP)                        
BEGIN        
INSERT INTO contabilidad.T_NO_DOMICILIADO_VOUCHER                           
 (C_RUC_EMPRESA,C_CODIGO_VOUCHER,C_CD_BENEFICIARIO,C_NRO_TV,C_RENTA_BRUTA,C_DEDUCCION_COSTO_CAPITAL,        
 C_RENTA_NETA,C_TASA_RET,C_IMPUESTO_RET,C_IGV_RET,C_NRO_CEDT,C_NRO_EOND,C_NRO_TR,C_NRO_MS,C_APLICACION_ART)                          
SELECT                           
 C_RUC_EMPRESA, C_CODIGO_VOUCHER, C_CD_BENEFICIARIO, C_NRO_TV,C_RENTA_BRUTA, C_DEDUCCION_COSTO_CAPITAL,                         
 C_RENTA_NETA, C_TASA_RET, C_IMPUESTO_RET, C_IGV_RET, C_NRO_CEDT, C_NRO_EOND, C_NRO_TR, C_NRO_MS, C_APLICACION_ART                           
FROM #T_NO_DOMICILIADO_VOUCHER_TEMP t1                           
END        
        
PRINT '====FIN REGISTRO NO DOMICILIADO===='        
                                
-----REGISTRO DE DISTRIBUCION POR CENTRO DE COSTO-------                                             
 IF(@CD_TM NOT IN ('16','10','19','22','23'))                        
 BEGIN                        
  IF ISNULL((SELECT TOP 1 ISNULL(IB_DISTCENTROCOSTO,0) FROM CFGCONTABILIDAD WHERE RUCE = @RUCE_P),0) = 1                        
  BEGIN                        
  IF NOT EXISTS(                        
      SELECT                         
      1                         
      FROM                         
      VOUCHER V                         
      INNER JOIN PLANCTAS PC ON PC.RUCE = V.RUCE AND PC.EJER = V.EJER AND PC.NROCTA = V.NROCTA                         
      WHERE                         
      V.RUCE = @RUCE_P                         
      AND V.EJER = @EJER_P                         
      AND V.REGCTB = @REGCTB_P                         
      AND ISNULL(V.IB_ESPROV,0) = 1                         
      AND (CAST(ISNULL(PC.IB_DTR,0) AS INT) + CAST(ISNULL(PC.IB_PERC,0) AS INT) + CAST(ISNULL(PC.IB_RET,0) AS INT)) != 0                        
     )                          
   BEGIN                        
    PRINT 'EL ASIENTO HA GENERADO DISTRIBUCION CENTRO DE COSTO X GASTO'                        
    EXEC [CONTABILIDAD].[USP_REGISTRO_DISTRIBUCION_ASIENTO_CC_X_GASTO] @RUCE_P ,@EJER_P ,@REGCTB_P ,@C_CODIGO_VOUCHER_DIST_AJUST ,@DH_R ,@SALDO_A ,@SALDOME_A                         
   END                        
  END                        
 END                        
          
                        
 IF EXISTS((SELECT 1 FROM CONTABILIDAD.T_RESERVA_GENERACION_REGISTRO_CONTABLE WHERE C_RUC_EMPRESA = @RucE_P AND C_REGISTRO_CONTABLE = @RegCtb_P AND C_EJERCICIO = @Ejer_P))  
 BEGIN                                      
  DELETE FROM CONTABILIDAD.T_RESERVA_GENERACION_REGISTRO_CONTABLE WHERE C_RUC_EMPRESA = @RucE_P AND C_EJERCICIO = @Ejer_P AND C_REGISTRO_CONTABLE = @RegCtb_P                        
 END                             
          
--EXEC sys.sp_refreshsqlmodule '[contabilidad].[CTB_ASIENTOAUTOMATICO_3]'                        
                        
END                        
      
--BEGIN -- AJUSTE X CONVERSIÓN                
                
----IF @P_IB_AJUSTAR_POR_CONVERSION = 1                
-- BEGIN                  
--  EXEC CONTABILIDAD.USP_VOUCHER_AJUSTAR_DECIMALES_X_CONVERSION @RucE_P, @Ejer_P, @RegCtb_P                
-- END                
--END                
                        
                        
/************************** LEYENDA                          
                          
| USUARIO            | | FECHA      | | DESCRIPCIÓN                        
| ABE                | | 31/10/2019 | | Se agregaron los 4 campos de cuentas contable, para que sean considerados cuando se genere el asiento automatico                        
| Andrés Santos      | | 05/11/2019 | | Se agregó la generacion de asientos para los tipos de movimientos 25,26 y 27 de recepcion de información                        
| Andrés Santos      | | 07/11/2019 | | Se agregó generacion de asiento para tipo de movimiento : 28                        
| DJ                 | | 20/11/2019 | | Se agregó la validación IB_Eliminado=0 en las tablas CptoCostoOF y EnvEmbOF                        
| Andrés Santos      | | 04/12/2019 | | Se modificó el asiento invertido para generar de forma correcta notas de credito para Compras y Ventas (analizar variable @IB_Ext)                        
| Andrés Santos      | | 19/12/2019 | | Se agregó la generacion de asientos para Tipo Movimiento : 29 (Casino)                        
| Andrés Santos      | | 08/01/2020 | | Se agregó que cargue el documento de referencia para percepciones                        
| Andrés Santos      | | 28/01/2020 | | Se modifico la generacion para Tipo 29 (Casino) con respecto a su Tipo de Asiento (01....04), y se agregó el parámetro local @ParametroAux4_P                        
| DS                 | | 11/02/2020 | | Se está agregando la opcion de agrupacion de cuentas con el @IB_EsAgrup                        
| ABE                | | 05/03/2020 | | Se agregó el Parámetro @Cod_TipExistencia, se cambió las cuentas de productos por CuentaTipoExistencia                        
| DS                 | | 07/04/2020 | | SE ESTA AGREGANDO EL INDICADOR DE FLUJO EFECTIVO CONTABLE PARA LAS LETRAS POR COBRAR Y PAGAR                        
| Andrés Santos      | | 15/04/2020 | | Se modificó la generación de asiento para tipo movimiento 25                        
| Andrés Santos      | | 25/04/2020 | | Se modificó la generación de asiento para tipo movimiento 26                        
| Andrés Santos      | | 13/05/2020 | | Se modificó la generación de asiento para tipo movimiento 28                        
| DJ                 | | 12/08/2020 | | Se cambió la la variable @CamMda a NUMERIC(20,2), para más precisión. Esa precisión sólo se está usando para inventarios que tengan importaciones relacionadas                        
| ABE                | | 06/10/2020 | | Se agregó la condición de generar destinos en base a la configuración del Número de Cuenta (Cuenta Destino o Cuenta Destino por Centro Costo)                        
| Andrés Santos      | | 11/11/2020 | | Se agregó el registro del trabajador (Cd_Trab) para Liquidación de Fondos (Caso 44183)                        
| Dénnis Santos      | | 17/12/2020 | | Se agregó una validacion para exluir las detracciones, retenciones y percepciones de la distribucion centro de costos x gasto                        
| JM                 | | 30/12/2020 | | Se agregó la función COLLATE DATABASE_DEFAULT a las tablas temporales #tmp_TVoucher_Dist y #tmp_TVoucher en las columas RucE, Ejer, y NroCta                        
| RL                 | | 07/01/2020 | | Se agrego el Cd_FPC para las operaciones provenientes de Compras2                        
| AB                 | | 07/01/2020 | | Se agregó la generacion de asientos para Tipo Movimiento : 30 (Pre Afiliación)                     
| Andrés Santos      | | 25/01/2021 | | Se agregó la generacion de asientos para Tipo Movimiento : 31 (Devengado)                        
| Pedro              | | 17/03/2021 | | Se agregó la generacion de asientos para Tipo Movimiento : 32 (Revaluado)                        
| Pedro              | | 27/04/2021 | | Se agregó la generacion de asientos para Tipo Movimiento : 33 (Revaluado)                        
| Rafael Linares     | | 14/06/2021 | | Modificacion de tamaño de nros de cta a 50                        
| Dénnis Santos      | | 28/06/2021 | | Se agregó los campos de detracción para compras 2                        
| Dénnis Santos      | | 20/08/2021 | | Se está eliminando el cursor REGISTRO DE ASIENTO                        
| Dénnis Santos      | | 06/09/2021 | | Se está optimizando el query, eliminando el update a planctas                      
| Andrés Santos      | | 15/10/2021 | | Se corrige línea para generar inventario2 con cambio de presentacion (Ref: Línea 2143)                        
| Pedro Espinoza     | | 14/12/2021 | | Se considera el tipo de cambio del activo fijo para depreciación, baja y revaluación.                    
| Ayrthon Bergamino  | | 14/12/2021 | | Se corrige la condición al darle valor al parámetro @ME                    
| Andrés Santos      | | 14/01/2022 | | Se agrega el ajuste x conversión CONTABILIDAD.USP_VOUCHER_AJUSTAR_DECIMALES_X_CONVERSION                
| Andrés Santos      | | 03/02/2022 | | Se elimina el ajuste x conversión CONTABILIDAD.USP_VOUCHER_AJUSTAR_DECIMALES_X_CONVERSION              
| Ayrthon Bergamino  | | 04/03/2022 | | Se agregó parámetros de Detracción a Liquidación de Fondos              
| Andrés Santos      | | 31/03/2022 | | Se agrega validación para permitir registro de monto cero.            
| Andrés Santos      | | 05/04/2022 | | Ref: Linea 706. Se comenta el T.C. de importación en inventario2, debido a lo conversado con Piero en el caso 68146            
| Andrés Santos      | | 07/04/2022 | | Ref: Linea 2084. Se Cambia el T.C asociado a inventario2 - detalle, debido a lo conversado con Piero en el caso 68146            
| Andrés Santos      | | 15/07/2022 | | Se agrega @L_CODIGO_DUA          
| Andrés Santos      | | 22/07/2022 | | Se elimina @L_CODIGO_DUA          
| Pedro Espinoza     | | 09/08/2022 | | Se considera NroCta de fabricación en el detalle de inventario          
| Ayrthon Bergamino  | | 02/09/2022 | | Se agrega @L_IGV_TASA          
| Rafael Linares     | | 22/09/2022 | | Se cambio el tamaño de las variables de importes numericos a 30,10          
| Rafael Linares     | | 13/10/2022 | | Se eliminaron algunos campos que redondeaban a dos decimales          
| Rafael Linares     | | 25/11/2022 | | Se cambiaron los tamaños de los decimales de las variables de cambio moneda para que solo trabaje con 3 decimales          
| Ayrthon Bergamino  | | 15/02/2023 | | Se agrega @L_IB_TransferenciaGratuita          
| Rafael Linares     | | 05/05/2023 | | Se agrego el proceso de captura de importes tanto MN Como ME para los movimientos de inventarios 2, se registran tal como vienen de inv2          
| Williams Gutierrez | | 17/05/2023 | | Se valida campos vacios y null en el campo de producto y servicio          
| Andrés Santos      | | 20/06/2023 | | Se crea validación del registro de detracciones para ventas con moneda extranjera (en cabecera)         
| Pedro Espinoza     | | 24/07/2023 | | Se cambio el ID para Activos de Baja         
| Rafael Linares     | | 08/08/2023 | | Se modificaron las variables numericas a 20,2 de precision        
| David Jove         | | 16/08/2023 | | Se está obteniendo @Val_Cal y @Val_Cal_ME directamente de la tabla (dentro del sector de código 'DETRACCION VENTA'). Se está enviando el parámetro @Cd_MIS_P a los sp's 'Ctb_Voucher_Inserta_Mov_Asiento_Temp' y 'Ctb_Voucher_Inserta_Registro_Asiento_Temp'  
| Pedro Espinoza     | | 23/10/2023 | | Se considera Gastos de producción en el detalle de inventario        
| Pedro Espinoza     | | 03/01/2024 | | Se genera el campo correcto para moneda extranjera de gasto de producción        
| Rafael Linares     | | 13/01/2024 | | Se cambio el filtro para la consulta de informacion de compras2 (vista) quitandole el filtro por Ejer        
| Andrés Santos      | | 26/01/2024 | | (92928) Se valida el obtener los centros de costos a nivel de cabecera para @Cd_TM = '22' (Referencia : /* Jalamos - definimos Centro de Costos */)      
| Rafael Linares     | | 14/03/2024 | | Se comento la condicion que obligaba la moneda de origen dolares para las detracciones de venta      
| Rafael Linares     | | 05/04/2024 | | Se agrego la informacion de campos adicionales tanto en cabecera como detalle para que estos jalen teniendo como origen proceso de inventario, compras y compras det     
| Andrés Santos      | | 27/04/2024 | | (96335) Se agrega código del trabajador en la variable @Cd_Trab para @Cd_TM='17'.    
| Andrés Santos      | | 17/06/2024 | | (100464) A nivel de cursor del detalle: Para @Cd_TM = '10' las variables @Cd_TD, @NroSre, @NroDoc estarán asociadas a las ventas y @DR_CdTD, @DR_NSre y @DR_NDoc estarán asociadas a la percepción.  
| David Jove         | | 17/09/2024 | | (100551) Se cambió la asignación de @NomCol_ME en la región 'Asignamos el nombre de las columnas ME de acuerdo a lo que tiene configurado en el MIS (Detalle)' (linea 2379)  
| David Jove         | | 17/09/2024 | | (100558) Se cambiaron los Indicadores Valores 'Gasto Total Producción M.N.' y 'Gasto Total Producción M.E.' a 'Cab. Gasto Total Producción M.N.' y 'Cab. Gasto Total Producción M.E.', para que trabaje a nivel de cabecera (trae el total de gastos de la producción con una cuenta asignada) Se agregaron los Indicadores Valores 'Det. Gasto Total Producción M.N.' y 'Det. Gasto Total Producción M.E.', para que trabaje a nivel de detalle (trae el costo detallado de la producción con una cuenta asignada o jalando su número de cuenta)  
| David Jove         | | 04/10/2024 | | (101929) Se agregó el tipo, serie y número de documento referencia cuando es un asiento de inventario 2 (trae solo el primero cuando son varios documentos en un mismo movimiento de inventario) tanto con IV cabecera como detalle  
| David Jove         | | 10/10/2024 | | (101924) En la asignación de @NomCol_ME cuando es inventario, se quitó la validación por @Cd_MdRg, porque el costo en inventario siempre guarda soles en MN y dólares (euros, etc.) en ME. Cuando se registraba un movimiento en dólares el Debe y el Haber mostraba el mismo monto en dólares (ME)  
| David Jove         | | 15/10/2024 | | (102978) Se corrigió la asignación de @NomCol y @NomCol_ME, para que valide de acuerdo a la @Cd_MdRg y si el IV es 'Filtro' (que se encuentra en desuso), para los sectores de código (Indicadores Valores Cabecera) y (Indicadores Valores Detalle)  
| Pedro Espinoza     | | 07/11/2024 | | (103077) Se valida la diferencia y se actualiza el resultado si tiene marcado provisión  
| Pedro Espinoza     | | 05/12/2024 | | (103099) Se validó IB_Eliminado=0 en la tabla CptoCostoOF  
| David Jove         | | 10/02/2025 | | (112548) Se corrigió la asignación de campos adicionales. Se preservó el valor asignado a cada CA con un ELSE, para que no sea reemplazada con la última fila del select  
| Hugo Delgado       | | 26/06/2025 | | (114212) Se asigno el valor de la variable @FecMov, con la FecGiro de la tabla  Letra_Cobro  
| Dénnis Santos      | | 11/07/2025 | | (112642) En el tipo modulo 23(retenciones de venta) se está colocando para que jale la moneda de registro en el origen. anteriormente se mandaba en duro 01 (soles)  
| David Jove         | | 06/09/2025 | | (116879) El indicador valor 'FabGastoTotal_MN' y 'FabGastoTotal_ME' se cambió a solo 'FabGastoTotal'. El indicador valor 'ProdGastoTotal_MN' y 'ProdGastoTotal_ME' se cambió a solo 'ProdGastoTotal'  
| David Jove         | | 22/09/2025 | | (116943) Se quitó el LEFT(@NomCol,LEN(@NomCol)-2) de las asignaciones de IV para el @Cd_TM = '17', ya no eran necesarias
| Andrés Santos      | | 06/10/2025 | | (118013) Se agrega lógica para obtener el tipo, serie y nro. documento si el ítem es un anticipo en compra2. Referencia : Buscar comentario "Código de Producto o Servicio, Tipo, Serie y Nro de Documento ANTICIPO" para @Cd_TM='12'
| David Jove		 | | 10/10/2025 | | (118046) Se corrigieron las asignaciones a @NomCol y @NomCol_ME a estas "SET @NomCol = case when @NomCol like '%_MN' then @NomCol else CONCAT(@NomCol,'_MN') end" y "SET @NomCol_ME = CONCAT(LEFT(@NomCol,LEN(@NomCol)-1),'E')" para MN y visceversa para ME, cuando el @Cd_TM es '17'
| David Jove		 | | 22/10/2025 | | (121123) Se agregó la variable @Cd_Vou_CCOF para tener la cuenta e importe detallado de los gastos

***************************/