USE [ERP_ECHA]
GO
/****** Object:  StoredProcedure [contabilidad].[USP_CONTABILIDAD_LISTA_02]    Script Date: 19/01/2026 15:41:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROC [contabilidad].[USP_CONTABILIDAD_LISTA_02]  
(  
@P_RUC_EMPRESA VARCHAR(11),    
@P_EJERCICIO VARCHAR(4),    
@P_FECHA_DESDE DATETIME,    
@P_FECHA_HASTA DATETIME,    
@P_COLUMNA VARCHAR(MAX),    
@P_DATO VARCHAR(MAX),    
@P_FILTRO_DETALLADO NVARCHAR(MAX),    
@P_PERIODO_DESDE VARCHAR(2),    
@P_PERIODO_HASTA VARCHAR(2),    
@P_NUM_PAGINA   INT,    
@P_TAM_PAGINA   INT,    
@P_TOTAL_FILAS INT output,  
@P_COLUMNAS_PROPUESTA BIT  
)  
  
AS    
    
--DECLARE    
--@P_RUC_EMPRESA VARCHAR(11) = '20492186130',    
--@P_EJERCICIO VARCHAR(4) = '2025',    
--@P_FECHA_DESDE DATETIME = '01/02/2025',    
--@P_FECHA_HASTA DATETIME = '28/02/2025',    
--@P_COLUMNA VARCHAR(MAX)='',    
--@P_DATO VARCHAR(MAX)='',    
--@P_PERIODO_DESDE VARCHAR(2)='',    
--@P_PERIODO_HASTA VARCHAR(2)='',    
--@P_NUM_PAGINA   INT = 1,    
--@P_TAM_PAGINA   INT = 10000,    
--@P_TOTAL_FILAS INT = 0,    
--@P_FILTRO_DETALLADO NVARCHAR(MAX),  
--@P_COLUMNAS_PROPUESTA BIT = 1  
    
DECLARE     
@P_RUC_EMPRESA_ VARCHAR(11) = @P_RUC_EMPRESA,    
@P_EJERCICIO_ VARCHAR(4) = @P_EJERCICIO,    
@P_FECHA_DESDE_ DATETIME = @P_FECHA_DESDE,    
@P_FECHA_HASTA_ DATETIME = @P_FECHA_HASTA,    
@P_COLUMNA_ VARCHAR(MAX) = @P_COLUMNA,    
@P_DATO_ VARCHAR(MAX) = @P_DATO,    
@L_NUM_PAGINA INT = @P_NUM_PAGINA,    
@L_TAM_PAGINA INT = @P_TAM_PAGINA,    
@L_PERIODO_DESDE VARCHAR(2) = @P_PERIODO_DESDE,    
@L_PERIODO_HASTA VARCHAR(2) = @P_PERIODO_HASTA,    
@L_INDICADOR_PERIODO BIT = (CASE WHEN ISNULL(@P_PERIODO_DESDE,'') = '' THEN 0 ELSE 1 END)    
    
    
DECLARE @COLUMNAS VARCHAR(MAX)    
DECLARE @COLUMNAS_COUNT VARCHAR(MAX)    
DECLARE @TABLAS VARCHAR(MAX)    
DECLARE @CONDICIONES VARCHAR(MAX)    
DECLARE @FILTROS VARCHAR(MAX)    
DECLARE @PAGINACION VARCHAR(MAX)    
DECLARE @TOTAL_PAGINA INT    
DECLARE @QUERY_COUNT NVARCHAR(MAX)    
DECLARE @QUERY_DATA NVARCHAR(MAX)  

DECLARE @P_VISUALIZA_CA BIT = (SELECT ISNULL(C_IB_VISUALIZAR_CA,0) FROM CfgContabilidad WHERE RucE = @P_RUC_EMPRESA_)
    
IF @P_COLUMNA_ <> '' AND  @P_DATO_ <> ''    
BEGIN    
    
 IF @P_COLUMNA_ = 'Cd_Clt'    
 BEGIN    
  SET @FILTROS =     
  'AND Cd_Clt in (SELECT Cd_Clt FROM Cliente2 WHERE RucE = ''' + @P_RUC_EMPRESA_  + ''' AND ISNULL(RSocial,CONCAT(Nom,'' '',ApPat,'' '',ApMat)) LIKE ''%'' + ''' + @P_DATO_ + ''' + ''%'')'    
 END    
 ELSE IF @P_COLUMNA_ = 'Cd_Clt_TD'    
 BEGIN    
  SET @FILTROS =     
  'AND Cd_Clt in (SELECT Cd_Clt FROM Cliente2 CL LEFT JOIN TipDocIdn TDI ON CL.Cd_TDI = TDI.Cd_TDI    
      WHERE CL.RucE = ''' + @P_RUC_EMPRESA_  + ''' AND TDI.NCorto LIKE ''%'' + ''' + @P_DATO_ + ''' + ''%'')'    
 END    
 ELSE IF @P_COLUMNA_ = 'Cd_Clt_ND'    
 BEGIN    
  SET @FILTROS =     
  'AND Cd_Clt in (SELECT Cd_Clt FROM Cliente2 WHERE RucE = ''' + @P_RUC_EMPRESA_  + ''' AND Ndoc LIKE ''%'' + ''' + @P_DATO_ + ''' + ''%'')'    
 END       
 ELSE IF @P_COLUMNA_ = 'Cd_Prv'    
 BEGIN    
  SET @FILTROS =     
  'AND Cd_Prv in (SELECT Cd_Prv FROM Proveedor2 WHERE RucE = ''' + @P_RUC_EMPRESA_  + ''' AND ISNULL(RSocial,CONCAT(Nom,'' '',ApPat,'' '',ApMat)) LIKE ''%'' + ''' + @P_DATO_ + ''' + ''%'')'    
 END    
 ELSE IF @P_COLUMNA_ = 'Cd_Prv_TD'    
 BEGIN    
  SET @FILTROS =     
  'AND Cd_Prv in (SELECT Cd_Prv FROM Proveedor2 PR LEFT JOIN TipDocIdn TDI ON PR.Cd_TDI = TDI.Cd_TDI    
      WHERE PR.RucE = ''' + @P_RUC_EMPRESA_  + ''' AND TDI.NCorto LIKE ''%'' + ''' + @P_DATO_ + ''' + ''%'')'    
 END     
 ELSE IF @P_COLUMNA_ = 'Cd_Prv_ND'    
 BEGIN    
  SET @FILTROS =     
  'AND Cd_Prv in (SELECT Cd_Prv FROM Proveedor2 WHERE RucE = ''' + @P_RUC_EMPRESA_  + ''' AND Ndoc LIKE ''%'' + ''' + @P_DATO_ + ''' + ''%'')'    
 END    
 ELSE IF @P_COLUMNA_ = 'Cd_Trab'    
 BEGIN    
  SET @FILTROS =     
  'AND Cd_Trab in (SELECT Cd_Trab FROM Trabajador WHERE RucE = ''' + @P_RUC_EMPRESA_  + ''' AND CONCAT(ApPaterno,'' '',ApMaterno,'' '',Nombres) LIKE ''%'' + ''' + @P_DATO_ + ''' + ''%'')'    
 END    
 ELSE IF @P_COLUMNA_ = 'Cd_Trab_TD'    
 BEGIN    
  SET @FILTROS =     
  'AND Cd_Trab in (SELECT Cd_Trab FROM Trabajador TR LEFT JOIN TipDocIdn TDI ON TR.Cd_TipDoc = TDI.Cd_TDI    
      WHERE TR.RucE = ''' + @P_RUC_EMPRESA_  + ''' AND TDI.NCorto LIKE ''%'' + ''' + @P_DATO_ + ''' + ''%'')'    
 END   
 ELSE IF @P_COLUMNA_ = 'Cd_Trab_ND'    
 BEGIN    
  SET @FILTROS =     
  'AND Cd_Trab in (SELECT Cd_Trab FROM Trabajador WHERE RucE = ''' + @P_RUC_EMPRESA_  + ''' AND NroDoc LIKE ''%'' + ''' + @P_DATO_ + ''' + ''%'')'    
 END    
 ELSE IF @P_COLUMNA_ = 'Cd_Area'    
 BEGIN    
  SET @FILTROS =     
  'AND Cd_Area in (SELECT Cd_Area FROM Area WHERE RucE = ''' + @P_RUC_EMPRESA_  + ''' AND Descrip LIKE ''%'' + ''' + @P_DATO_ + ''' + ''%'')'    
 END    
 ELSE IF @P_COLUMNA_ = 'Cd_Area_'    
 BEGIN    
  SET @FILTROS =     
  'AND Cd_Area = ''' + @P_DATO_ + ''' '    
 END    
 ELSE IF @P_COLUMNA_ = 'Cd_TD'    
 BEGIN    
  SET @FILTROS =     
  'AND Cd_TD in (SELECT Cd_TD FROM TipDoc WHERE RucE = ''' + @P_RUC_EMPRESA_  + ''' AND NCorto LIKE ''%'' + ''' + @P_DATO_ + ''' + ''%'')'    
 END    
 ELSE IF @P_COLUMNA_ = 'Cd_TD_'    
 BEGIN    
  SET @FILTROS =     
  'AND Cd_TD =  ''' + @P_DATO_  + ''' '    
 END    
 ELSE IF @P_COLUMNA_ = 'NroCta'    
 BEGIN    
  SET @FILTROS =     
  'AND NroCta in (SELECT NroCta FROM PlanCtas WHERE RucE = ''' + @P_RUC_EMPRESA_  + ''' AND NomCta LIKE ''%'' + ''' + @P_DATO_ + ''' + ''%'' AND Ejer = ''' + @P_EJERCICIO_ + ''')'      
 END    
 ELSE IF @P_COLUMNA_ = 'NroCta_'    
 BEGIN    
  SET @FILTROS =     
  'AND NroCta =  ''' + @P_DATO_  + ''' '    
 END    
 ELSE IF @P_COLUMNA_ = 'NroCtaH1'    
 BEGIN    
  SET @FILTROS =     
  'AND NroCta in (SELECT NroCta FROM PlanCtas WHERE RucE = ''' + @P_RUC_EMPRESA_  + ''' AND NroCtaH1 LIKE ''%'' + ''' + @P_DATO_ + ''' + ''%'' AND Ejer = ''' + @P_EJERCICIO_ + ''')'      
 END    
 ELSE IF @P_COLUMNA_ = 'NomCtaH1'    
 BEGIN    
  SET @FILTROS =     
  'AND NroCta in (SELECT NroCta FROM PlanCtas WHERE RucE = ''' + @P_RUC_EMPRESA_  + ''' AND NomCtaH1 LIKE ''%'' + ''' + @P_DATO_ + ''' + ''%'' AND Ejer = ''' + @P_EJERCICIO_ + ''')'      
 END    
 ELSE IF @P_COLUMNA_ = 'NroCtaH2'    
 BEGIN    
  SET @FILTROS =     
  'AND NroCta in (SELECT NroCta FROM PlanCtas WHERE RucE = ''' + @P_RUC_EMPRESA_  + ''' AND NroCtaH2 LIKE ''%'' + ''' + @P_DATO_ + ''' + ''%'' AND Ejer = ''' + @P_EJERCICIO_ + ''')'      
 END    
 ELSE IF @P_COLUMNA_ = 'NomCtaH2'    
 BEGIN    
  SET @FILTROS =     
  'AND NroCta in (SELECT NroCta FROM PlanCtas WHERE RucE = ''' + @P_RUC_EMPRESA_  + ''' AND NomCtaH2 LIKE ''%'' + ''' + @P_DATO_ + ''' + ''%'' AND Ejer = ''' + @P_EJERCICIO_ + ''')'      
 END    
 ELSE IF @P_COLUMNA_ = 'Cd_MR'    
 BEGIN    
  SET @FILTROS =     
  'AND Cd_MR in (SELECT Cd_MR FROM Modulo WHERE NCorto LIKE ''%'' + ''' + @P_DATO_ + ''' + ''%'')'    
 END    
 ELSE IF @P_COLUMNA_ = 'Cd_MdOr'    
 BEGIN    
  SET @FILTROS =     
  'AND Cd_MdOr in (SELECT top(1) Cd_Mda FROM Moneda WHERE Nombre LIKE ''%'' + ''' + @P_DATO_ + ''' + ''%'')'    
 END    
 ELSE IF @P_COLUMNA_ = 'Cd_MdOr_'    
 BEGIN    
  SET @FILTROS =     
  'AND Cd_MdOr in (SELECT top(1) Cd_Mda FROM Moneda WHERE Cd_Mda LIKE ''%'' + ''' + @P_DATO_ + ''' + ''%'')'    
 END    
 ELSE IF @P_COLUMNA_ = 'Cd_MdRg'    
 BEGIN    
  SET @FILTROS =     
  'AND Cd_MdRg in (SELECT top(1) Cd_Mda FROM Moneda WHERE Nombre LIKE ''%'' + ''' + @P_DATO_ + ''' + ''%'')'    
 END    
 ELSE IF @P_COLUMNA_ = 'C_ID_CONCEPTO_FEC'    
 BEGIN    
  SET @FILTROS =     
  'AND C_ID_CONCEPTO_FEC in (SELECT C_ID_CONCEPTO_FEC FROM contabilidad.T_TIPO_CONCEPTO_FLUJO_EFECTIVO_CONTABLE WHERE C_NOMBRE_CONCEPTO LIKE ''%'' + ''' + @P_DATO_ + ''' + ''%'')'    
 END    
 ELSE IF @P_COLUMNA_ = 'Cd_CC'    
 BEGIN    
  SET @FILTROS =     
  'AND Cd_CC in (SELECT Cd_CC FROM CCostos WHERE RucE = ''' + @P_RUC_EMPRESA_  + ''' AND Descrip LIKE ''%'' + ''' + @P_DATO_ + ''' + ''%'')'    
 END    
 ELSE IF @P_COLUMNA_ = 'Cd_CC_'    
 BEGIN    
  SET @FILTROS =     
  'AND Cd_CC in (SELECT Cd_CC FROM CCostos WHERE RucE = ''' + @P_RUC_EMPRESA_  + ''' AND Cd_CC LIKE ''%'' + ''' + @P_DATO_ + ''' + ''%'')'    
 END    
 ELSE IF @P_COLUMNA_ = 'Cd_CC_SC'    
 BEGIN    
  SET @FILTROS =     
  'AND Cd_SC in (SELECT Cd_SC FROM CCSub WHERE RucE = ''' + @P_RUC_EMPRESA_  + ''' AND Descrip LIKE ''%'' + ''' + @P_DATO_ + ''' + ''%'')'    
 END    
 ELSE IF @P_COLUMNA_ = 'Cd_CC_SC_SS'    
 BEGIN    
  SET @FILTROS =     
  'AND Cd_SS in (SELECT Cd_SS FROM CCSubSub WHERE RucE = ''' + @P_RUC_EMPRESA_  + ''' AND Descrip LIKE ''%'' + ''' + @P_DATO_ + ''' + ''%'')'    
 END    
 ELSE IF @P_COLUMNA_ = 'Id_TMP'    
 BEGIN    
  SET @FILTROS =     
  'AND Id_TMP in (SELECT top(1) codigo FROM MedioPago WHERE RucE = ''' + @P_RUC_EMPRESA_  + ''' AND NomCorto LIKE ''%'' + ''' + @P_DATO_ + ''' + ''%'')'    
 END    
 ELSE IF @P_COLUMNA_ IN ('FecDif','FecED','FecVD','FecMov','FecCbr','FecConc')    
 BEGIN    
  SET @FILTROS = ' AND CONVERT( VARCHAR, ' + @P_COLUMNA_ + ',103) LIKE ''%' + @P_DATO_ +'%'''    
 END    
 ELSE    
  SET @FILTROS = ' AND ' + @P_COLUMNA_ + ' LIKE ''%' + @P_DATO_ +'%'''    
END    
ELSE    
 SET @FILTROS = ''    
    
SET @COLUMNAS_COUNT =     
'    
SELECT     
@FILAS = count(*)     
'    
IF (@P_VISUALIZA_CA = 1)
BEGIN    
SET @COLUMNAS =     
'    
SELECT     
 RucE    
,Cd_Vou    
,Ejer    
,Prdo    
,RegCtb    
,Cd_Fte    
,NroCta    
,NroCta as NroCta_    
,NroCta as NroCtaH1    
,NroCta as NomCtaH1    
,NroCta as NroCtaH2    
,NroCta as NomCtaH2    
,Cd_TD    
,Cd_TD as Cd_TD_    
,NroSre    
,NroDoc    
,Glosa    
,CASE WHEN ISNULL(IB_ANULADO, 0) = 1 THEN 0 ELSE MtoD END AS MtoD    
,CASE WHEN ISNULL(IB_ANULADO, 0) = 1 THEN 0 ELSE MtoH END AS MtoH    
,CASE WHEN ISNULL(IB_ANULADO, 0) = 1 THEN 0 ELSE MtoD_ME END AS MtoD_ME    
,CASE WHEN ISNULL(IB_ANULADO, 0) = 1 THEN 0 ELSE MtoH_ME END AS MtoH_ME    
,Cd_MdOr    
,Cd_MdOr as Cd_MdOr_    
,Cd_MdRg    
,Cd_MdRg as Cd_MdRg_    
,CamMda    
,Cd_CC    
,Cd_SC    
,Cd_SS    
,Cd_CC+''|''+Cd_SC as Cd_CC_SC    
,Cd_CC+''|''+Cd_SC+''|''+ Cd_SS as Cd_CC_SC_SS    
    
,Cd_CC as Cd_CC_    
,Cd_SC as Cd_SC_    
,Cd_SS as Cd_SS_    
,Cd_CC+''|''+Cd_SC as Cd_CC_SC_    
,Cd_CC+''|''+Cd_SC+''|''+ Cd_SS as Cd_CC_SC_SS_    
    
,Cd_Area    
,Cd_Area as Cd_Area_    
    
,Cd_MR    
,TipOper    
,NroChke    
,Grdo    
,IB_Cndo    
,IB_Conc    
,IB_EsProv    
,IB_Anulado    
,IB_Anulado as C_IB_ANULADO    
,IB_EsDes    
,DR_CdVou    
,DR_FecED    
,DR_CdTD    
,DR_NSre    
,DR_NDoc    
,DR_NCND    
,DR_NroDet    
,FORMAT(DR_FecDet,''dd/MM/yy'') as DR_FecDet    
,Cd_Clt    
,Cd_Prv    
,Cd_Trab    
    
,Cd_Clt as  Cd_Clt_TD    
,Cd_Prv as  Cd_Prv_TD    
,Cd_Trab as Cd_Trab_TD    
,Cd_Clt as  Cd_Clt_ND    
,Cd_Prv as  Cd_Prv_ND    
,Cd_Trab as Cd_Trab_ND    
    
,CA01    
,CA02    
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
,Cd_FPC    
,Cd_FCP    
,Id_TMP    
,FecDif    
,FecED    
,CASE WHEN Cd_FTE = ''RC'' AND (ISNULL(Cd_FPC, '''') = '''' or Cd_FPC != ''02'')  THEN null ELSE FecVD END as FecVD    
,FecMov    
,FecCbr    
,FecConc    
,FecReg    
,FecMdf    
,UsuCrea    
,UsuModf    
,IC_TipAfec    
,C_ID_CONCEPTO_FEC    
,C_IB_DEVOLUCION_IGV  
,C_IGV_TASA  
'  
END
ELSE
BEGIN
SET @COLUMNAS =     
'    
SELECT     
 RucE    
,Cd_Vou    
,Ejer    
,Prdo    
,RegCtb    
,Cd_Fte    
,NroCta    
,NroCta as NroCta_    
,NroCta as NroCtaH1    
,NroCta as NomCtaH1    
,NroCta as NroCtaH2    
,NroCta as NomCtaH2    
,Cd_TD    
,Cd_TD as Cd_TD_    
,NroSre    
,NroDoc    
,Glosa    
,CASE WHEN ISNULL(IB_ANULADO, 0) = 1 THEN 0 ELSE MtoD END AS MtoD    
,CASE WHEN ISNULL(IB_ANULADO, 0) = 1 THEN 0 ELSE MtoH END AS MtoH    
,CASE WHEN ISNULL(IB_ANULADO, 0) = 1 THEN 0 ELSE MtoD_ME END AS MtoD_ME    
,CASE WHEN ISNULL(IB_ANULADO, 0) = 1 THEN 0 ELSE MtoH_ME END AS MtoH_ME    
,Cd_MdOr    
,Cd_MdOr as Cd_MdOr_    
,Cd_MdRg    
,Cd_MdRg as Cd_MdRg_    
,CamMda    
,Cd_CC    
,Cd_SC    
,Cd_SS    
,Cd_CC+''|''+Cd_SC as Cd_CC_SC    
,Cd_CC+''|''+Cd_SC+''|''+ Cd_SS as Cd_CC_SC_SS    
    
,Cd_CC as Cd_CC_    
,Cd_SC as Cd_SC_    
,Cd_SS as Cd_SS_    
,Cd_CC+''|''+Cd_SC as Cd_CC_SC_    
,Cd_CC+''|''+Cd_SC+''|''+ Cd_SS as Cd_CC_SC_SS_    
    
,Cd_Area    
,Cd_Area as Cd_Area_    
    
,Cd_MR    
,TipOper    
,NroChke    
,Grdo    
,IB_Cndo    
,IB_Conc    
,IB_EsProv    
,IB_Anulado    
,IB_Anulado as C_IB_ANULADO    
,IB_EsDes    
,DR_CdVou    
,DR_FecED    
,DR_CdTD    
,DR_NSre    
,DR_NDoc    
,DR_NCND    
,DR_NroDet    
,FORMAT(DR_FecDet,''dd/MM/yy'') as DR_FecDet    
,Cd_Clt    
,Cd_Prv    
,Cd_Trab    
    
,Cd_Clt as  Cd_Clt_TD    
,Cd_Prv as  Cd_Prv_TD    
,Cd_Trab as Cd_Trab_TD    
,Cd_Clt as  Cd_Clt_ND    
,Cd_Prv as  Cd_Prv_ND    
,Cd_Trab as Cd_Trab_ND          
,Cd_FPC    
,Cd_FCP    
,Id_TMP    
,FecDif    
,FecED    
,CASE WHEN Cd_FTE = ''RC'' AND (ISNULL(Cd_FPC, '''') = '''' or Cd_FPC != ''02'')  THEN null ELSE FecVD END as FecVD    
,FecMov    
,FecCbr    
,FecConc    
,FecReg    
,FecMdf    
,UsuCrea    
,UsuModf    
,IC_TipAfec    
,C_ID_CONCEPTO_FEC    
,C_IB_DEVOLUCION_IGV  
,C_IGV_TASA  
'
END

SET @TABLAS =     
'    
 FROM VOUCHER v with(nolock)     
'    
    
IF(@L_INDICADOR_PERIODO = 1)    
BEGIN    
    
SET @CONDICIONES =    
 '    
 WHERE    
 v.RucE = ''' + @P_RUC_EMPRESA_ + '''     
 AND v.Ejer = ''' + @P_EJERCICIO_ + '''    
 AND v.Prdo BETWEEN '''+ @L_PERIODO_DESDE +'''  and '''+ @L_PERIODO_HASTA +'''    
    
 '    
END    
ELSE    
BEGIN    
    
SET @CONDICIONES =    
 '    
 WHERE    
 v.RucE = ''' + @P_RUC_EMPRESA_ + '''     
 AND (Cast(v.FecMov as date) >=  Cast('''+ CAST(@P_FECHA_DESDE_ AS VARCHAR) +''' as date) and Cast(v.FecMov as date) <= Cast('''+ CAST(@P_FECHA_HASTA_ AS VARCHAR) +''' as date) )    
    
 '    
END    
    
set @PAGINACION = ' ORDER BY v.FecMov,v.RegCtb    
OFFSET ('+ cast(@L_NUM_PAGINA as varchar) + '-1)*'+cast(@L_TAM_PAGINA as varchar)+'ROWS    
FETCH NEXT '+ cast(@L_TAM_PAGINA as varchar)+' ROWS ONLY '    
  
IF (@P_COLUMNAS_PROPUESTA = 1)  
BEGIN  
 SET @TABLAS = @TABLAS + '  
  LEFT JOIN   
  (  
   SELECT  
    Ruce C_Ruce,  
    RegCtb C_RegCtb,  
    Ejer C_Ejer,  
    ISNULL(C_IB_COMPROBANTE_CON_DIFERENCIAS, 0) as C_IB_COMPROBANTE_CON_DIFERENCIAS  
   FROM  
    T_REGISTROS_PROPUESTA_API_SIRE pas  
    INNER JOIN   
    (  
     SELECT  
      d.Ruce,   
      d.Cd_TD,   
      d.NroSre,   
      d.NroDoc,  
      d.Cd_Prv,  
      d.RegCtb,  
      d.Ejer,  
      t.CodSNT_ Cd_TDI,  
      p.NDoc  
     FROM  
     (  
      SELECT  
       v.Ruce,   
       MAX(Cd_TD) Cd_TD,   
       MAX(NroSre) NroSre,   
       MAX(NroDoc) NroDoc,  
       MAX(Cd_Prv) Cd_Prv,  
       v.RegCtb,  
       v.Ejer  
      FROM  
       voucher v  
      ' + @CONDICIONES + '  
       and v.Cd_Fte = ''RC''  
      GROUP BY  
       v.RucE,v.Ejer,v.RegCtb  
     ) d  
     LEFT JOIN Proveedor2 p on d.RucE = p.RucE and d.Cd_Prv = p.Cd_Prv  
     LEFT JOIN tipdocidn t on p.Cd_TDI = t.Cd_TDI  
    )base on base.RucE = pas.C_RUC_EMPRESA and base.Cd_TD = pas.C_CODIGO_TIPO_DOCUMENTO and base.NROSRE = pas.C_NUMERO_SERIE   
     and base.NroDoc = pas.C_NUMERO_DOCUMENTO_INICIAL and base.Cd_TDI = pas.C_TIPO_DOCUMENTO_IDENTIDAD   
     and base.NDoc = pas.C_NUMERO_DOCUMENTO_IDENTIDAD  
  ) p on v.RucE = p.C_Ruce AND v.Ejer = p.C_Ejer and v.RegCtb = p.C_RegCtb'  
  
 SET @COLUMNAS = @COLUMNAS + ',ISNULL(p.C_IB_COMPROBANTE_CON_DIFERENCIAS, 0) as C_IB_COMPROBANTE_CON_DIFERENCIAS  
 '  
END  
    
SET @QUERY_COUNT = @COLUMNAS_COUNT + @TABLAS + @CONDICIONES + @FILTROS + case when isnull(@P_FILTRO_DETALLADO,'')='' then '' else @P_FILTRO_DETALLADO end    
SET @QUERY_DATA = @COLUMNAS + @TABLAS + @CONDICIONES + @FILTROS + case when isnull(@P_FILTRO_DETALLADO,'')='' then '' else @P_FILTRO_DETALLADO end +@PAGINACION    
    
    
--Count    
EXECUTE sp_executesql @QUERY_COUNT, N'@FILAS INT OUTPUT', @FILAS = @P_TOTAL_FILAS OUTPUT    
-- Data    
EXECUTE sp_executesql @QUERY_DATA    
    
--SELECT @P_TOTAL_FILAS AS TOTAL    
print @QUERY_DATA    
/*    
LEYENDA:    
DS 18/10/2019 : <Se está agregando la paginación al query del explorador de voucher>    
AB 14/11/2019 : <Detalle : Se agregó los columnas faltantes al query ,para que permita realizar la búsqueda por el filtro avanzando de todas las columnas>    
RL 29/01/2020 : <Se le agrego el campo C_IB_DEVOLUCION_IGV>    
DS 13/04/2020 : <Se está agregando el filtro por tipo medio pago>    
AB 06/04/2022 : <Se está agregando el filtro por Numero de Cuenta 1 y Nombre de Cuenta 1>    
AB 18/04/2022 : <Se modificó formato  de fecha de columna Fecha Detracción>    
AB 04/05/2022 : <Se está agregando el filtro por Numero de Cuenta 2 y Nombre de Cuenta 2>  
Andrés Santos : 15/07/2022 - Se agrega C_CODIGO_DUA  
Andrés Santos : 22/07/2022 - Se elimina C_CODIGO_DUA  
RL 19/08/2022 : Se oculto la info de la columna fecha de vencimiento excepto los casos donde es una compra a credito  
RL 04/04/2025 : Se agrego la columna con la informacion de la propuesta del SIRE  
RL 14/04/2025 : Se condiciono la consulta de las columnas de api SIRE con la variable @P_COLUMNAS_PROPUESTA
Jesus Chavez  : 11/09/2025 | | (116896) Se agregola validación para visualizar o no Campos Adicionales
*/