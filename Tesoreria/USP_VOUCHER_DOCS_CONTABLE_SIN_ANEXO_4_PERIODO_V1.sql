USE [ERP_ECHA]
GO
/****** Object:  StoredProcedure [contabilidad].[USP_VOUCHER_DOCS_CONTABLE_SIN_ANEXO_4_PERIODO]    Script Date: 19/01/2026 16:25:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [contabilidad].[USP_VOUCHER_DOCS_CONTABLE_SIN_ANEXO_4_PERIODO]  
(    
@P_RUCE CHAR(11),  
@P_EJER CHAR(4),  
@P_CD_CLT VARCHAR(MAX) = null,  
@P_CD_PRV CHAR(7) = null,  
@P_CD_TRAB CHAR(8) = null,  
@P_IC_ES CHAR(1),  
@P_NUMERACION VARCHAR(MAX) = null  
)    
  
AS      
      
--DECLARE      
--@P_RUCE    CHAR(11) = '20101313833',      
--@P_EJER    CHAR(4) = '2023',      
--@P_CD_CLT   VARCHAR(MAX) = '*CLT0000002*',      
--@P_CD_PRV   CHAR(7) = '',      
--@P_CD_TRAB   CHAR(8) = '',      
--@P_IC_ES   CHAR(1) = 'I',      
--@P_NUMERACION VARCHAR(MAX) = null      
      
      
declare @L_CONSULTA varchar(max)
declare @L_CONSULTA1 varchar(max)
declare @L_CONSULTA2 varchar(max)
declare @L_CONSULTA3 varchar(max)

-- FILTRO DE PERIODOS HARDCODEADO
DECLARE @PeriodoDesde VARCHAR(6) = '202504'
DECLARE @PeriodoHasta VARCHAR(6) = '202509'

declare @L_OPC varchar(500)      
declare @C_IB_AUTORIZA_VOUCHER  BIT     
declare @C_IB_AUTORIZA_VOUCHER_CGENERAL BIT  
  
select @C_IB_AUTORIZA_VOUCHER = C_IB_AUTORIZA_VOUCHER, @C_IB_AUTORIZA_VOUCHER_CGENERAL = C_IB_AUTORIZA_VOUCHER_CGENERAL  from CfgContabilidad where RucE = @P_RUCE  
  
if(@P_IC_ES='I')       
 set @L_OPC='and p.IB_CtasXCbr <> 0'      
else if(@P_IC_ES='E')       
begin      
 set @L_OPC = 'and p.IB_CtasXPag<>0'      
end      
      
DECLARE @L_IB_EXISTE_SALDO_INICIAL BIT = 0      
SET @L_IB_EXISTE_SALDO_INICIAL = CAST(ISNULL((select TOP(1) 1 from voucher where RucE = @P_RUCE and Ejer = @P_EJER AND Prdo = '00'),0) AS BIT)      

IF OBJECT_ID('tempdb..#DT_VOUCHER') IS NOT NULL
DROP TABLE #DT_VOUCHER
      
set @L_CONSULTA='      
create table #DT_VOUCHER      
(       
 RucE CHAR(11),      
 Cd_Vou int null,      
 NroCta varchar(50),      
 NomCta varchar(200),      
 NomAux varchar(400),      
 FecMov DATE,  
 FecED  DATE,  
 FecVD  DATE,  
 DR_CdTD nvarchar(2),  
 DR_NSre varchar(20),      
 DR_NDoc varchar(20),  
 TD nvarchar(2),  
 Sre varchar(20),  
 NroDoc varchar(20),  
 Glosa varchar(500),  
 SaldoS numeric(30,10),  
 SaldoD numeric(30,10),  
 MdReg char(5),  
 Cd_CC varchar(8),  
 Cd_SC varchar(8),   
 Cd_SS varchar(8),  
 Cd_Clt char(10),      
 Cd_Prv char(7),      
 Cd_Trab char(8),      
 RegCtb nvarchar(15),      
 FechaOrigen datetime,           
 IB_AgRet bit,      
 IB_BuenContrib bit,  
 MtoD numeric(30,10),  
 MtoH numeric(30,10),  
 MtoD_ME numeric(30,10),  
 MtoH_ME numeric(30,10),  
 Ic_ES CHAR(1),  
 C_ID_CONCEPTO_FEC INT,  
 IB_Dtr bit  
)      
      
insert into #DT_VOUCHER (RucE, Cd_Vou, NroCta, NomCta, NomAux, FecMov, FecED, FecVD, DR_CdTD, DR_NSre, Dr_NDoc, TD, Sre, NroDoc, Glosa, SaldoS, SaldoD, MdReg,      
 Cd_CC, Cd_SC, Cd_SS, Cd_Clt, Cd_Prv, Cd_Trab, RegCtb, FechaOrigen, IB_AgRet, IB_BuenContrib, MtoD, MtoH, MtoD_ME, MtoH_ME, Ic_ES, C_ID_CONCEPTO_FEC, IB_Dtr  
 )        
       
select  
 v.RucE,      
 MAX(CASE WHEN ISNULL(v.IB_EsProv,0) = ''1'' THEN v.Cd_Vou ELSE ''0'' END) as Cd_Vou,      
 v.NroCta,      
 p.NomCta,      
 ' +       
      
 case       
 when ISNULL(@P_CD_CLT,'') != '' then 'isnull(c2.RSocial, c2.ApPat + '' '' + c2.ApMat + '','' + c2.Nom) as NomAux,'      
 when ISNULL(@P_CD_PRV,'') != '' then 'isnull(p2.RSocial, p2.ApPat + '' '' + p2.ApMat + '','' + p2.Nom) as NomAux,'      
 when ISNULL(@P_CD_TRAB,'') != '' then 'T2.ApPaterno + '' '' + T2.ApMaterno + '', '' + T2.Nombres as NomAux,'      
 else       
 '      
 CASE SUBSTRING(LTRIM(RTRIM((ISNULL(nullif(v.Cd_Clt,''''),'''') + ISNULL(nullif(v.Cd_Trab,''''),'''') +  ISNULL(nullif(v.Cd_Prv,''''),'''')))),1,1)      
 WHEN ''C'' THEN ISNULL(c2.RSocial, (c2.ApPat + '' '' + c2.ApMat + '','' + c2.Nom))      
 WHEN ''P'' THEN ISNULL(p2.RSocial, (p2.ApPat + '' '' + p2.ApMat + '','' + p2.Nom))      
 WHEN ''A'' THEN ISNULL(p2.RSocial, (p2.ApPat + '' '' + p2.ApMat + '','' + p2.Nom))      
 WHEN ''T'' THEN (T2.ApPaterno + '' '' + T2.ApMaterno + '', '' + T2.Nombres ) END as NomAux,      
 '      
  end + '  
 MAX(CASE WHEN ISNULL(v.IB_EsProv,0) = ''1'' THEN v.FecMov ELSE '''' END) as FecMov,      
 MAX(CASE WHEN ISNULL(v.IB_EsProv,0) = 1 THEN v.FecED ELSE 0 END) as FecED,      
 MAX(CASE WHEN ISNULL(v.IB_EsProv,0) = ''1'' THEN v.FecVD ELSE '''' END) as FecVD,      
      
 LTRIM(RTRIM(ISNULL(nullif(v.Cd_TD,''''),''''))) as DR_CdTD,  
 LTRIM(RTRIM(ISNULL(nullif(v.NroSre,''''),''''))) as DR_NSre,  
 LTRIM(RTRIM(ISNULL(nullif(v.NroDoc,''''),''''))) as DR_NDoc,  
 LTRIM(RTRIM(ISNULL(nullif(v.Cd_TD,''''),''''))) as TD,       
 LTRIM(RTRIM(ISNULL(nullif(v.NroSre,''''),''''))) as Sre,       
 LTRIM(RTRIM(ISNULL(nullif(v.NroDoc,''''),''''))) as NroDoc,       
 MAX(CASE WHEN ISNULL(v.IB_EsProv,0) = ''1'' THEN ISNULL(v.Glosa,'''') ELSE '''' END) as Glosa,      
 SUM(v.MtoD-v.MtoH)  as SaldoS,       
 SUM(v.MtoD_ME-v.MtoH_ME) as SaldoD,      
 MAX(CASE WHEN ISNULL(v.IB_EsProv,0) = ''1'' THEN (CASE WHEN (p.Cd_Mda) = ''01'' THEN ''S/.'' ELSE ''US$'' END) ELSE ''0'' END) as MdReg,      
 MAX(CASE WHEN ISNULL(v.IB_EsProv,0) = ''1'' THEN v.Cd_CC ELSE ''0'' END) as Cd_CC,      
 MAX(CASE WHEN ISNULL(v.IB_EsProv,0) = ''1'' THEN v.Cd_SC ELSE ''0'' END) as CD_SC,      
 MAX(CASE WHEN ISNULL(v.IB_EsProv,0) = ''1'' THEN v.Cd_SS ELSE ''0'' END) as CD_SS,      
 ISNULL(nullif(v.Cd_Clt,''''),'''') as Cd_Clt,       
 ISNULL(nullif(v.Cd_Prv,''''),'''') as Cd_Prv,      
 ISNULL(nullif(v.Cd_Trab,''''),'''') as Cd_Trab,      
 MAX(CASE WHEN ISNULL(v.IB_EsProv,0) = ''1'' THEN v.RegCtb ELSE ''0'' END) as RegCtb,      
 MIN(V.FECMOV) as FechaOrigen,  
 ' + case       
 when ISNULL(@P_CD_CLT,'') != ''  then '0 as IB_AgRet, 0 as IB_BuenContrib,'      
 when ISNULL(@P_CD_TRAB,'') != '' then '0 as IB_AgRet, 0 as IB_BuenContrib,'      
 else 'isnull(p2.IB_AgRet,0) as IB_AgRet, isnull(p2.IB_BuenContrib, 0) as IB_BuenContrib,' end + '      
 SUM(v.MtoD) as MtoD,       
 SUM(v.MtoH) as MtoH,  
 SUM(v.MtoD_ME) as MtoD_ME,      
 SUM(v.MtoH_ME) as MtoH_ME,  
 MIN(CASE WHEN ISNULL(p.IB_CtasXCbr,0) = ''0'' THEN (CASE WHEN ISNULL(p.IB_CtasXPag,0) = ''0'' THEN '''' ELSE ''E'' END) ELSE ''I'' END) as IC_ES,      
 MAX(isnull(nullif(v.C_ID_CONCEPTO_FEC,''''),0)) as C_ID_CONCEPTO_FEC,      
 isnull(p.IB_Dtr,0) as IB_Dtr  
 --, isnull(v.IB_EsAut,0) as IB_EsAut  
 FROM Voucher v with(nolock)       
 INNER JOIN PlanCtas p on p.RucE = v.RucE and p.Ejer = v.Ejer and p.NroCta = v.NroCta '       
 + case       
 when ISNULL(@P_CD_CLT,'') != '' then 'left join Cliente2 c2 on c2.Ruce = v.RucE and c2.Cd_Clt = v.Cd_Clt'      
 when ISNULL(@P_CD_PRV,'') != '' then 'left join Proveedor2 p2 on p2.Ruce = v.RucE and p2.Cd_Prv = v.Cd_Prv'      
 when ISNULL(@P_CD_TRAB,'') != '' then 'left join Trabajador t2 on t2.RucE = v.RucE and t2.Cd_Trab = v.Cd_Trab'      
      
 else '      
 left join Proveedor2 p2 on p2.Ruce = v.RucE and p2.Cd_Prv = v.Cd_Prv       
 left join Cliente2 c2 on c2.Ruce = v.RucE and c2.Cd_Clt = v.Cd_Clt       
 left join Trabajador t2 on t2.RucE = v.RucE and t2.Cd_Trab = v.Cd_Trab ' end + '      
 WHERE       
 v.RucE='''+@P_RUCE+''' and '+      
 case when @L_IB_EXISTE_SALDO_INICIAL = 1 then ' v.ejer = ''' +@P_EJER + ''' and ' else '' END + '      
 isnull(v.IB_Cndo,0) <> 1 and       
 ISNULL(v.NroDoc,'''') != '''' and      
 ISNULL(v.Cd_TD,'''') != '''' and      
 isnull(v.IB_Anulado,0) <> 1 '+ @L_OPC + ' and
 (v.Ejer + v.Prdo) BETWEEN ''' + @PeriodoDesde + ''' AND ''' + @PeriodoHasta + ''' and
 LEN(ISNULL(v.Cd_Clt,'''') + ISNULL(v.Cd_Prv,'''') + ISNULL(v.Cd_Trab,'''')) > 0       
 ' + case       
       
 when ISNULL(@P_CD_CLT,'') != '' then (case when len(@P_CD_CLT) < 13 then 'and v.Cd_Clt = ''' + REPLACE(@P_CD_CLT, '*','') +'''' else 'and CHARINDEX(CONCAT(''*'' , v.Cd_Clt , ''*'' ) , ''' + @P_CD_CLT +''' ) > 0' end)      
 when ISNULL(@P_CD_PRV,'') != '' then 'and v.Cd_Prv = ''' + @P_CD_PRV + ''''      
 when ISNULL(@P_CD_TRAB,'') != '' then 'and v.Cd_Trab = ''' + @P_CD_TRAB + ''''      
 else '' end       
 +      
  case when ISNULL(@P_NUMERACION,'') != '' then 'and CHARINDEX(CONCAT(''*'' , isnull(v.Cd_TD,''''),''-'',isnull(v.NroSre,''''),''-'',isnull(v.NroDoc,''''), ''*'' ) , ''' + @P_NUMERACION +''' ) > 0' else '' end      
 +      
 '      
 GROUP BY v.RucE, v.NroCta, p.NomCta,ISNULL(nullif(v.Cd_TD,''''),''''),ISNULL(nullif(v.NroSre,''''),''''),ISNULL(nullif(v.NroDoc,''''),''''),ISNULL(nullif(v.Cd_Clt,''''),'''') , ISNULL(nullif(v.Cd_Prv,''''),''''),     
 ISNULL(nullif(v.Cd_Trab,''''),''''), isnull(p.IB_Dtr,0),      
          
 ' + case       
 when ISNULL(@P_CD_CLT,'') != '' then 'c2.RSocial, c2.ApPat, c2.ApMat, c2.Nom'      
 when ISNULL(@P_CD_PRV,'') != '' then 'p2.RSocial, p2.ApPat, p2.ApMat, p2.Nom, p2.IB_AgRet, p2.IB_BuenContrib'       
 when ISNULL(@P_CD_TRAB,'') != '' then 't2.ApMaterno, t2.ApPaterno, t2.Nombres,v.IB_EsAut'      
 else       
 'c2.RSocial, c2.ApPat, c2.ApMat, c2.Nom,      
 p2.RSocial, p2.ApPat, p2.ApMat, p2.Nom, p2.IB_AgRet, p2.IB_BuenContrib,      
 t2.ApMaterno, t2.ApPaterno, t2.Nombres  
'       
 end + '       
      
 HAVING (sum(v.MtoD-v.MtoH) <> 0 OR sum(v.MtoD_ME-v.MtoH_ME) <> 0) and max(case(IB_EsProv) when ''1'' then v.Cd_Vou else 0 end)  > 0   
 '      
       
 SET @L_CONSULTA1 = '      
       
 SELECT  
 DISTINCT  
 --CASE WHEN ISNULL(Au.Cd_Vou,'''') = '''' THEN 0 ELSE 1 END as Ib_Aut,  
 (select isnull( VC.IB_EsAut,0) IB_EsAut  from  Voucher  VC WHERE VC.RucE = ''' + @P_RUCE + '''  and VC.Cd_Vou = Tabla_Provisiones.Cd_Vou AND  VC.RegCtb = Tabla_Provisiones.RegCtb) AS Ib_Aut  
 ,  
 CASE WHEN ISNULL(Det.Cd_Vou,'''') = '''' THEN 0 ELSE 1 END as Ib_Agrup,      
 Agrupado,      
 Tabla_Provisiones.Cd_Vou,    
   
  --Tabla_Provisiones.RucE,  
  
 NroCta,      
 NomCta,       
 NomAux,      
 FecMov,      
 FecED,      
 FecVD,      
 DR_CdTD,       
 DR_NSre,       
 DR_NDoc,      
 Cd_Td,      
 NroSre,      
 NroDoc,      
 Glosa,      
 SaldoS,      
 SaldoD,      
 MdReg,       
 Tabla_Provisiones.Cd_CC,    
 A.Descrip AS ''NombreCentroCostos'',    
 Tabla_Provisiones.Cd_SC,        
 B.Descrip AS ''NombreSubCentroCostos'',    
 Tabla_Provisiones.Cd_SS,         
 C.Descrip AS ''NombreSubSubCentroCostos'',    
 Cd_Clt,      
 Cd_Prv,      
 Cd_Trab,      
 Tabla_Provisiones.RegCtb,      
 FechaOrigen,         
 IB_AgRet,      
 IB_BuenContrib,      
 CASE WHEN (MtoD - MtoH) != 0 THEN MtoD ELSE MtoD_ME END AS MtoD,     
 CASE WHEN (MtoD - MtoH) != 0 THEN MtoH else MtoH_ME END AS MtoH,      
 Ic_ES,  
 '  
 +  
   
 CASE   WHEN  ISNULL(@C_IB_AUTORIZA_VOUCHER,0) = 1 THEN    '    Au.Obs,    Au.NomUsu,   '  WHEN ISNULL(@C_IB_AUTORIZA_VOUCHER_CGENERAL,0) = 1 THEN   '    NULL Obs,    NULL NomUsu,   '  ELSE   '    Au.Obs,    Au.NomUsu,   '  END   
 +  
 '  
 C_ID_CONCEPTO_FEC,      
 IB_Dtr      
 FROM      
 (   
  select  
  RucE,  
  COUNT(DR_NDoc) as Agrupado,  
  MIN(t.Cd_Vou) as Cd_Vou,  
  NroCta,  
  NomCta,  
  NomAux,  
  MIN(FecMov) as FecMov,  
  MIN(FecED) as FecED,  
  MIN(FecVD) as FecVD,  
  DR_CdTD,  
  DR_NSre,  
  DR_NDoc,  
  MIN(Td) as Cd_TD,  
  RTRIM(LTRIM(SUBSTRING(MIN(ISNULL(Td,''00'') +  ''-'' + Sre), 4, 20))) as NroSre,  
  RTRIM(LTRIM(SUBSTRING(MIN(ISNULL(Td,''00'') +  ''-'' + NroDoc), 4, 20))) as NroDoc,  
  MIN(Glosa) as Glosa,  
  SUM(SaldoS) SaldoS,  
  SUM(SaldoD) SaldoD,  
  MdReg,       
  Cd_CC,       
  Cd_SC,       
  Cd_SS,       
  t.Cd_Clt,      
  Cd_Prv,      
  t.Cd_Trab,      
  MIN(t.RegCtb) as RegCtb,       
  MIN(t.FechaOrigen) as FechaOrigen,             
  IB_AgRet,       
  IB_BuenContrib,      
  case when SUM(MtoD-MtoH) > 0 then SUM(MtoD-MtoH) else 0 end as ''MtoD'',      
  case when SUM(MtoD-MtoH) < 0 then SUM(MtoH-MtoD) else 0 end as ''MtoH'',  
  case when SUM(MtoD_ME-MtoH_ME) > 0 then SUM(MtoD_ME-MtoH_ME) else 0 end as ''MtoD_ME'',  
  case when SUM(MtoD_ME-MtoH_ME) < 0 then SUM(MtoH_ME-MtoD_ME) else 0 end as ''MtoH_ME'',  
  Ic_ES,      
  C_ID_CONCEPTO_FEC,      
  IB_Dtr      
  from #DT_VOUCHER t  
  WHERE       
  t.Cd_Vou NOT IN (SELECT Cd_Vou FROM GrupoVoucher WHERE RucE = ''' + @P_RUCE + ''')      
  AND SUBSTRING(T.RegCtb,1,2) <> ''LF''      
      
  group by Ruce, NroCta, NomCta, NomAux, DR_CdTD, DR_NSre, DR_NDoc, MdReg, Cd_CC, Cd_SC, Cd_SS,       
  t.Cd_Clt, Cd_Prv, t.Cd_Trab, IB_AgRet, IB_BuenContrib,Ic_ES,RegCtb, C_ID_CONCEPTO_FEC, IB_Dtr      
  
  HAVING SUM(ROUND(MtoD-MtoH,2)) <> 0 OR SUM(ROUND(MtoD_ME-MtoH_ME,2)) <> 0      
  ) as Tabla_Provisiones      
    '  
  
 set @L_CONSULTA2='  
  LEFT JOIN AutVou Au ON       
  Tabla_Provisiones.RucE = Au.RucE and      
  Tabla_Provisiones.Cd_Vou = Au.Cd_Vou and      
  Tabla_Provisiones.RegCtb = Au.RegCtb    
    
  LEFT JOIN Grupo_Voucher_Documentos_Det Det ON      
  Tabla_Provisiones.RucE = Det.RucE and      
  Tabla_Provisiones.Cd_Vou = Det.Cd_Vou      
    
  LEFT JOIN CCostos A ON A.RucE = ''' + @P_RUCE + ''' AND A.Cd_CC = Tabla_Provisiones.Cd_CC    
  LEFT JOIN CCSub B ON B.RucE = ''' + @P_RUCE + ''' AND B.Cd_CC = Tabla_Provisiones.Cd_CC AND B.Cd_SC = Tabla_Provisiones.Cd_SC    
  LEFT JOIN CCSubSub C ON C.RucE = ''' + @P_RUCE + ''' AND C.Cd_CC = Tabla_Provisiones.Cd_CC AND C.Cd_SC = Tabla_Provisiones.Cd_SC AND C.Cd_SS = Tabla_Provisiones.Cd_SS      
      
 '      
       
 PRINT @L_CONSULTA  +  @L_CONSULTA2    
 EXEC(@L_CONSULTA + @L_CONSULTA1 + @L_CONSULTA2   )      
       
/************************** LEYENDA          
          
| USUARIO            | | FECHA      | | DESCRIPCIÓN    
| Andrés Santos      | | 13/09/2022 | | Se agrega NombreCentroCostos, NombreSubCentroCostos y NombreSubSubCentroCostos     
| Williams Gutierrez | | 10/10/2022 | | Se coloco MAX al campo C_ID_CONCEPTO_FEC para evitar que no cancele por tener diferentes indicadores de flujo    
| Williams Gutierrez | | 17/01/2023 | | Se aumento a 10 decimales    
| Rafael Linares     | | 11/03/2023 | | Se agrego la opcion A en el filtro de proveedores    
| Andrés Santos      | | 02/06/2023 | | Se agrega validación de saldos para MtoD_ME y MtoH_ME  
| Rafael Linares  | | 09/11/2023 | | Se eliminio el concatenado de * cd_Clt * para el caso de consulta simple por cliente para que funcione el indice que se creo optimizando la consulta de gasolinera  
| Hugo Delgado    | | 22/05/2025 | | (112869) Se agrego las variable @C_IB_AUTORIZA_VOUCHER y @C_IB_AUTORIZA_VOUCHER_CGENERAL para validar el tipo de  Autorizacion  
| Hugo Delgado    | | 17/06/2025 | | (112869) Se agrego el campo IB_EsAut para obtener los voucher que estan autorizados   
| Jesus Chavez    | | 20/09/2025 | | (116940) Se optimiza el procedimiento agregando una tabla temporal
***************************/    
