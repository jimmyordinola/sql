USE [ERP_ECHA]
GO
/****** Object:  StoredProcedure [dbo].[Pln_GenerarAsientosPlanilla2_v2_2]    Script Date: 14/01/2026 14:55:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Pln_GenerarAsientosPlanilla2_v2_2]  
(  
 @RucE nvarchar(11),  
 @Ejer char(4),  
 @Prdo char(2),  
 @Sem char(2),  
 @Cd_TipPln char(1),  
 @UsuCrea nvarchar(50),  
 @RegCtb nvarchar(30),   
 @Cd_Trab char(8),  
 @msj nvarchar(4000) output  
)  
as  
set language spanish  
--declare @RucE nvarchar(11) = '20292726628',  
--  @Ejer char(4) = '2024',  
--  @Prdo char(2) = '03',  
--  @Sem char(2) = '10',  
--  @Cd_TipPln char(1) = 'O',  
--  @UsuCrea nvarchar(50) = 'contanet',  
--  @RegCtb nvarchar(30) = 'POGN_LD03-00003',  
--  @Cd_Trab char(8) = 'T0000221',  
--  @msj nvarchar(max) = null  
begin  
 set @msj = ''  
  
 Declare @Estado bit  
  
    select  @Estado = ( Case(@Prdo) when '00' then P00  
                 when '01' then P01  
                 when '02' then P02  
                 when '03' then P03  
                 when '04' then P04  
                 when '05' then P05  
                 when '06' then P06  
                 when '07' then P07  
                 when '08' then P08  
                 when '09' then P09  
                 when '10' then P10  
                 when '11' then P11  
                 when '12' then P12  
                 when '13' then P13  
                 else P14  
                 end  
                )  
     from Periodo  
     where RucE=@RucE and Ejer=@Ejer  
  
 if(ISNULL(@Estado,0)=1)  
 begin  
  set @msj='El Periodo está cerrado'  
  select @msj  
  return  
 end  
  
 declare @IB_GAxCCF bit,/*Generar Asiento por Centro de Costos Ficha*/  
   @IB_GAxCCTD bit,/*Generar Asiento por Centro de Costos Tareo Diario*/  
   @IB_DxRP bit,/*Desgloce por Regimen Pensionario*/  
   @IB_DxA bit,/*Desgloce por Aporte*/  
   @IB_AxA bit,/*Asientos por Actividad*/  
   @Cd_Actividad char(3),  
   @IB_CDxPCC bit = 0,/*Configuracion para Desgloce por Porcentaje de Centro de Costos*/  
   @NroCtaDifEmp varchar(50),/*Numero de Cuenta de Diferencia para Empleados*/  
   @NroCtaDifObr varchar(50),/*Numero de Cuenta de Diferencia para Obreros*/  
   @CuentaDifEmp varchar(200),/*Nombre de Cuenta de Diferencia para Empleados*/  
   @CuentaDifObr varchar(200),/*Nombre de Cuenta de Diferencia para Obreros*/  
   @IB_TrabHTHTD bit,/*Trabajador: Horas Trabajadas = Horas Tareo Diario*/  
   @IB_TrabATD bit/*Trabajador: Aparece en Tareo Diario*/  
  
 select @IB_GAxCCF=isnull(IB_AsientosXTrab, 0), @IB_GAxCCTD=isnull(IB_AsientoxCC, 0), @IB_DxRP=isnull(IB_GAxT_RegPenXTrab, 0), @IB_DxA=isnull(IB_GAxT_AporteXTrab, 0), @IB_AxA=isnull(IB_AsientosActividades, 0),  
     @NroCtaDifEmp = case when isnull(IB_NroCtaDiferenciaEmpUnico,0)=1 then NroCtaDestino_Emp else (select C_NUMERO_CUENTA from planilla.T_NUMERO_CUENTA_DIFERENCIA_X_TRABAJADOR where C_RUC_EMPRESA=@RucE and C_CODIGO_TRABAJADOR=@Cd_Trab) end,  
     @NroCtaDifObr = case when isnull(IB_NroCtaDiferenciaObrUnico,0)=1 then NroCtaDestino_Obr else (select C_NUMERO_CUENTA from planilla.T_NUMERO_CUENTA_DIFERENCIA_X_TRABAJADOR where C_RUC_EMPRESA=@RucE and C_CODIGO_TRABAJADOR=@Cd_Trab) end  
 from CfgPlanilla where RucE=@RucE  
  
 set @CuentaDifEmp = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCtaDifEmp), '')  
 set @CuentaDifObr = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCtaDifObr), '')  
  
 set @Cd_Actividad = (case when @IB_AxA=1 then 'R11' else '' end)  
  
 if(exists (select * from CfgTrabajador where RucE=@RucE and Cd_Trab=@Cd_Trab))  
  select @IB_TrabHTHTD=isnull(IB_TareoDiario, 0), @IB_TrabATD=isnull(IB_CCTareoDia, 0) from CfgTrabajador where RucE=@RucE and Cd_Trab=@Cd_Trab  
 else  
  begin  
   set @IB_TrabHTHTD = 0  
   set @IB_TrabATD = 0  
  end  
    
 declare @CamMda numeric(6,3),  
   @Cd_Fte char(2),  
   @HrsTrabPla numeric(5,2),/*Horas Trabajadas según Planillón*/  
   @DiasXMesSem numeric(5,2),/*Días del mes (Empleado) o de la semana (Obrero)*/  
   @DiasVacaciones numeric(5,2),  
   @DiasSubsidiados numeric(5,2),  
   @HrsXDia int = 0  
   
 Declare @DiasXMes int = dbo.DiasAlMes_DiasFiscales(@RucE,@Ejer,@Prdo,@UsuCrea)  
 set @HrsXDia = dbo.HrsAlDia_DiasFiscales(@RucE)  
 set @CamMda = (select top 1 TCVta from TipCam where CONVERT(varchar,YEAR(FecTC)) + RIGHT('00' + CONVERT(varchar,MONTH(FecTC)),2) <= @Ejer+@Prdo order by CONVERT(date,FecTC) desc)  
 set @Cd_Fte = (select IC_Fte from CfgPlanilla where RucE=@RucE)  
 set @HrsTrabPla = isnull((select CASE WHEN (ISNULL(DiasTrab,0)+ISNULL(DiasSub,0)+ISNULL(DiasVac,0)) >= 30  
           then @DiasXMes  
          else (ISNULL(DiasTrab,0)+ISNULL(DiasSub,0)+ISNULL(DiasVac,0)) end  
           * @HrsXDia from Tareo where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and Sem=@Sem and Cd_Trab=@Cd_Trab), 1.00)  
             
 IF(@Cd_TipPln='O')  
 BEGIN  
  DECLARE @DiasTrabSubVac numeric(5,2)= ISNULL((select ISNULL(DiasSub,0)+ISNULL(DiasVac,0)  
               from Tareo where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and Sem=@Sem and Cd_Trab=@Cd_Trab), 0.00)  
           +  
           ISNULL((select Count(1)  
               from Asistencia where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and Sem=@Sem and Cd_Trab=@Cd_Trab and ISNULL(IB_Asist,0)=1  and ISNULL(IB_DescSem,0)=0), 1.00)  
   
  select @HrsTrabPla= (CASE WHEN @DiasTrabSubVac>7 THEN 7 ELSE @DiasTrabSubVac END) * @HrsXDia  
    
 END  
  
 if (@HrsTrabPla=0)  
  set @HrsTrabPla=1  
 if (@Cd_TipPln='E')  
  begin  
   set @DiasXMesSem = dbo.DiasAlMes_DiasFiscales(@RucE,@Ejer,@Prdo,@UsuCrea)  
   set @DiasVacaciones = ISNULL((select SUM(ISNULL(Dias,0.00)) from VacacionesDet where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and Sem='' and Cd_Trab=@Cd_Trab and IB_Venta=0),0.00)  
   set @DiasSubsidiados = ISNULL((select SUM(ISNULL(DiasSusp,0.00)) from Faltas where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and Sem='' and Cd_Trab=@Cd_Trab and TipSusp in ('21','22')),0.00)  
  end  
 else  
  begin  
   set @DiasXMesSem = 7  
   set @DiasVacaciones = ISNULL((select SUM(ISNULL(Dias,0.00)) from VacacionesDet2 where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and Sem=@Sem and Cd_Trab=@Cd_Trab and IB_Venta=0),0.00)  
   set @DiasSubsidiados = ISNULL((select SUM(ISNULL(DiasSusp,0.00)) from Faltas where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and Sem=@Sem and Cd_Trab=@Cd_Trab and TipSusp in ('21','22')),0.00)  
  end  
  
 declare @Trabajador varchar(120),  
   @Cd_Area varchar(6),  
   @Cd_TD char(2),  
   @NroSre char(6),  
   @NroDoc varchar(15),  
   @Cd_Trabajador char(8)  
  
 (select @Cd_Area=(case when ((Cd_Area is null) and (exists (select * from Area where RucE=@RucE and Cd_Area='010101'))) then '010101' else Cd_Area end),  
   @Trabajador=' - '+ApPaterno+' '+ApMaterno+', '+Nombres from Trabajador where RucE=@RucE and Cd_Trab=@Cd_Trab)  
  
 declare @Cd_Concepto varchar(4),  
   @Importe numeric(13,2),  
   @ImporteTD numeric(13,2) = 0,  
   @Actividad varchar(50),  
   @NroCta varchar(50),  
   @Cuenta varchar(200)  
  
 declare @i int,  
   @Cd_Conceptos varchar(max) = '',  
   @Importes varchar(max) = '',  
   @Actividades varchar(max) = ''  
  
 declare @Cd_CC varchar(8),  
   @Cd_SC varchar(8),  
   @Cd_SS varchar(8),  
   @Porc numeric(5,2),  
   @SumHrs decimal(5,2),/*Suma de Horas (por Centro de Costo) en Tareo Diario, para el Periodo*/  
   @SumHrsXMes decimal(5,2)/*Suma de Horas en Tareo Diario, para el Periodo*/  
     
 set @SumHrsXMes = isnull((select sum(Hrs) from TareoDia where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and Sem=@Sem and Cd_Trab=@Cd_Trab), 0.00)  
 select @HrsTrabPla= CASE WHEN @Cd_TipPln='O' AND @SumHrsXMes>0 THEN @SumHrsXMes ELSE @HrsTrabPla END  
   
 declare @j int,  
   @Cd_CCs varchar(max) = '',  
   @Cd_SCs varchar(max) = '',  
   @Cd_SSs varchar(max) = '',  
   @Porcs varchar(max) = '',  
   @SumHrss varchar(max) = ''  
     
 declare @CtaD varchar(50),  
   @CtaH varchar(50),  
   @PorcD numeric(5,2)  
  
 declare @k int,  
   @CtaDs varchar(max) = '',  
   @CtaHs varchar(max) = '',  
   @PorcDs varchar(max) = ''  
  
 declare @s varchar(max) = ''  
  
 /********************************************************************************************************/  
 /*                          */  
 /*     0 0 0 0                    */  
 /*     | | | |-> Configuración Trabajador ('Hrs. Tareo Diario')       */  
 /*     | | |---> Configuración Trabajador ('C.C. Tareo Diario')       */  
 /*     | |-----> Configuración General ('Generar Asientos Por Tareo Diario')    */  
 /*     |-------> Configuración General ('Generar Asientos Por Ficha')      */  
 /*                          */  
 /*   No se pueden generar asientos con la Configuración General           */  
 /*   ('Generar Asientos Por Ficha: Inactiva' y 'Generar Asientos Por Tareo Diario: Inactiva')   */  
 /*   - 0000                        */  
 /*   - 0001                        */  
 /*   - 0010                        */  
 /*   - 0011                        */  
 /*                          */  
 /*   GENERAR ASIENTOS POR C.C. FICHA                 */  
 /*   - 1000                        */  
 /*   - 1001 revisar                      */  
 /*   - 1010                        */  
 /*   - 1011 revisar                      */  
 /*   - 1100                        */  
 /*   - 1101 revisar                      */  
 /*                          */  
 /*   No se pueden generar asientos para @Cd_Trab - @Trabajador con la Configuración General    */  
 /*   ('Generar Asientos Por Ficha: Inactiva' y 'Generar Asientos Por Tareo Diario: Activa')    */  
 /*   y la Configuración Trabajador ('C.C. Tareo Diario: Inactiva')          */  
 /*   - 0100                        */  
 /*   - 0101                        */  
 /*                          */  
 /*   No se pueden generar asientos para @Cd_Trab - @Trabajador con la Configuración General    */  
 /*   ('Generar Asientos Por Ficha: Inactiva' y 'Generar Asientos Por Tareo Diario: Activa')    */  
 /*   y la Configuración Trabajador ('C.C. Tareo Diario: Activa' y 'Hrs. Tareo Diario: Inactivo')  */  
 /*   - 0110   explicar mensaje                 */  
 /*                          */  
 /*   GENERAR ASIENTO POR C.C. TAREO DIARIO                */  
 /*   - 0111                        */  
 /*   - 1111                        */  
 /*                          */  
 /*   GENERAR ASIENTO POR C.C. TAREO DIARIO - C.C. FICHA             */  
 /*   - 1110                        */  
 /*                          */  
 /********************************************************************************************************/  
   
 if(@IB_GAxCCF=0 and @IB_GAxCCTD=0)  
  begin  
   print '-0000'  
   print '-0001'  
   print '-0010'  
   print '-0011'  
   set @msj = 'No se pueden generar asientos debido a que no se tiene activado ningún criterio para generar asientos en ''Configuración General'''  
  end  
 else if(@IB_GAxCCF=1 and @IB_GAxCCTD=0)  
  begin  
   exec Pln_GenerarAsientosPlanilla2_CentroCostosFicha_2 @i,@RucE,@Ejer,@Prdo,@Sem,@Cd_Trab,@Cd_Actividad,@Cd_Conceptos,@Importes,@Cd_Concepto,@Importe,@j,@Cd_CCs,@Cd_SCs,@Cd_SSs,@SumHrss,@ImporteTD,@Porcs,@Cd_CC,@Cd_SC,@Cd_SS,@SumHrs,@Porc,@s,@NroCta,@Cuenta,@Cd_TD,@NroSre,@NroDoc,@Cd_Trabajador,@HrsTrabPla,@SumHrsXMes,@IB_CDxPCC,@RegCtb,@Cd_Fte,@Trabajador,@CamMda,@Cd_Area,@UsuCrea,@k,@CtaDs,@CtaHs,@PorcDs,@CtaD,@CtaH,@PorcD,@IB_AxA,@Actividades,@Actividad,@IB_DxA,@NroCtaDifEmp,@CuentaDifEmp,@NroCtaDifObr,@CuentaDifObr,@IB_DxRP,@msj output  
  end  
 else if(@IB_GAxCCF=0 and @IB_GAxCCTD=1)  
  begin  
   if ((@DiasVacaciones+@DiasSubsidiados) < @DiasXMesSem)  
    exec Pln_GenerarAsientosPlanilla2_CentroCostosTareoDiario_2 @i,@RucE,@Ejer,@Prdo,@Sem,@Cd_Trab,@Cd_Actividad,@Cd_Conceptos,@Importes,@Cd_Concepto,@Importe,@j,@Cd_CCs,@Cd_SCs,@Cd_SSs,@SumHrss,@ImporteTD,@Porcs,@Cd_CC,@Cd_SC,@Cd_SS,@SumHrs,@Porc,@s,@NroCta,@Cuenta,@Cd_TD,@NroSre,@NroDoc,@Cd_Trabajador,@HrsTrabPla,@SumHrsXMes,@IB_CDxPCC,@RegCtb,@Cd_Fte,@Trabajador,@CamMda,@Cd_Area,@UsuCrea,@k,@CtaDs,@CtaHs,@PorcDs,@CtaD,@CtaH,@PorcD,@IB_AxA,@Actividades,@Actividad,@IB_DxA,@NroCtaDifEmp,@CuentaDifEmp,@NroCtaDifObr,@CuentaDifObr,@IB_DxRP,@msj output  
   else /*SI TODOS LOS DÍAS DEL MES HAN SIDO ABARCADOS POR LAS VACACIONES Y/O SUBSIDIADOS, ENTONCES GENERARÁ LOS ASIENTOS CON SU CENTRO DE COSTO PRINCIPAL AL 100%*/  
    exec Pln_GenerarAsientosPlanilla2_CentroCostosFicha_2 @i,@RucE,@Ejer,@Prdo,@Sem,@Cd_Trab,@Cd_Actividad,@Cd_Conceptos,@Importes,@Cd_Concepto,@Importe,@j,@Cd_CCs,@Cd_SCs,@Cd_SSs,@SumHrss,@ImporteTD,@Porcs,@Cd_CC,@Cd_SC,@Cd_SS,@SumHrs,@Porc,@s,@NroCta,@Cuenta,@Cd_TD,@NroSre,@NroDoc,@Cd_Trabajador,@HrsTrabPla,@SumHrsXMes,@IB_CDxPCC,@RegCtb,@Cd_Fte,@Trabajador,@CamMda,@Cd_Area,@UsuCrea,@k,@CtaDs,@CtaHs,@PorcDs,@CtaD,@CtaH,@PorcD,@IB_AxA,@Actividades,@Actividad,@IB_DxA,@NroCtaDifEmp,@CuentaDifEmp,@NroCtaDifObr,@CuentaDifObr,@IB_DxRP,@msj output  
  end  
 else if(@IB_GAxCCF=1 and @IB_GAxCCTD=1)  
  begin  
   exec Pln_GenerarAsientosPlanilla2_CentroCostosTareoDiarioFicha_2 @i,@RucE,@Ejer,@Prdo,@Sem,@Cd_Trab,@Cd_Actividad,@Cd_Conceptos,@Importes,@Cd_Concepto,@Importe,@j,@Cd_CCs,@Cd_SCs,@Cd_SSs,@SumHrss,@ImporteTD,@Porcs,@Cd_CC,@Cd_SC,@Cd_SS,@SumHrs,@Porc,@s,
@NroCta,@Cuenta,@Cd_TD,@NroSre,@NroDoc,@Cd_Trabajador,@HrsTrabPla,@SumHrsXMes,@IB_CDxPCC,@RegCtb,@Cd_Fte,@Trabajador,@CamMda,@Cd_Area,@UsuCrea,@k,@CtaDs,@CtaHs,@PorcDs,@CtaD,@CtaH,@PorcD,@IB_AxA,@Actividades,@Actividad,@IB_DxA,@NroCtaDifEmp,@CuentaDifEmp,
@NroCtaDifObr,@CuentaDifObr,@IB_DxRP,@msj output  
  end  
 /*  
 if(@IB_GAxCCF=0 and @IB_GAxCCTD=0)  
  begin  
   print '-0000'  
   print '-0001'  
   print '-0010'  
   print '-0011'  
   set @msj = 'No se pueden generar asientos debido a que no se tiene activado ningún criterio para generar asientos en ''Configuración General'''  
  end  
 else if(@IB_GAxCCF=1 and @IB_GAxCCTD=0 and @IB_TrabATD=0 and @IB_TrabHTHTD=0)  
  begin  
   print '-1000'  
   if(@HrsTrabPla=0 and @SumHrsXMes=0)  
    set @msj = 'No se pueden generar asientos debido a que el trabajador no posee Horas Trabajadas en su Planillón, para el periodo o semana actual'  
   else if(@HrsTrabPla<>0 and @SumHrsXMes=0)  
    exec Pln_GenerarAsientosPlanilla2_CentroCostosFicha @i,@RucE,@Ejer,@Prdo,@Sem,@Cd_Trab,@Cd_Actividad,@Cd_Conceptos,@Importes,@Cd_Concepto,@Importe,@j,@Cd_CCs,@Cd_SCs,@Cd_SSs,@SumHrss,@ImporteTD,@Porcs,@Cd_CC,@Cd_SC,@Cd_SS,@SumHrs,@Porc,@s,@NroCta,@Cue
nta,@Cd_TD,@NroSre,@NroDoc,@Cd_Trabajador,@HrsTrabPla,@SumHrsXMes,@IB_CDxPCC,@RegCtb,@Cd_Fte,@Trabajador,@CamMda,@Cd_Area,@UsuCrea,@k,@CtaDs,@CtaHs,@PorcDs,@CtaD,@CtaH,@PorcD,@IB_AxA,@Actividades,@Actividad,@IB_DxA,@NroCtaDifEmp,@CuentaDifEmp,@NroCtaDifOb
r,@CuentaDifObr,@IB_DxRP,@msj output  
   else if(@HrsTrabPla=0 and @SumHrsXMes<>0)  
    set @msj = 'No se pueden generar asientos debido a que el trabajador no posee Horas Trabajadas en su Planillón, para el periodo o semana actual'  
   else if(@HrsTrabPla<>0 and @SumHrsXMes<>0)  
    exec Pln_GenerarAsientosPlanilla2_CentroCostosFicha @i,@RucE,@Ejer,@Prdo,@Sem,@Cd_Trab,@Cd_Actividad,@Cd_Conceptos,@Importes,@Cd_Concepto,@Importe,@j,@Cd_CCs,@Cd_SCs,@Cd_SSs,@SumHrss,@ImporteTD,@Porcs,@Cd_CC,@Cd_SC,@Cd_SS,@SumHrs,@Porc,@s,@NroCta,@Cue
nta,@Cd_TD,@NroSre,@NroDoc,@Cd_Trabajador,@HrsTrabPla,@SumHrsXMes,@IB_CDxPCC,@RegCtb,@Cd_Fte,@Trabajador,@CamMda,@Cd_Area,@UsuCrea,@k,@CtaDs,@CtaHs,@PorcDs,@CtaD,@CtaH,@PorcD,@IB_AxA,@Actividades,@Actividad,@IB_DxA,@NroCtaDifEmp,@CuentaDifEmp,@NroCtaDifOb
r,@CuentaDifObr,@IB_DxRP,@msj output  
  end  
 else if(@IB_GAxCCF=1 and @IB_GAxCCTD=0 and @IB_TrabATD=0 and @IB_TrabHTHTD=1)  
  begin  
   print '-1001'  
   if(@HrsTrabPla=0 and @SumHrsXMes=0)  
    set @msj = 'No se pueden generar asientos debido a que el trabajador no posee Horas Trabajadas en su Planillón, para el periodo o semana actual'  
   else if(@HrsTrabPla<>0 and @SumHrsXMes=0)  
    exec Pln_GenerarAsientosPlanilla2_CentroCostosFicha @i,@RucE,@Ejer,@Prdo,@Sem,@Cd_Trab,@Cd_Actividad,@Cd_Conceptos,@Importes,@Cd_Concepto,@Importe,@j,@Cd_CCs,@Cd_SCs,@Cd_SSs,@SumHrss,@ImporteTD,@Porcs,@Cd_CC,@Cd_SC,@Cd_SS,@SumHrs,@Porc,@s,@NroCta,@Cue
nta,@Cd_TD,@NroSre,@NroDoc,@Cd_Trabajador,@HrsTrabPla,@SumHrsXMes,@IB_CDxPCC,@RegCtb,@Cd_Fte,@Trabajador,@CamMda,@Cd_Area,@UsuCrea,@k,@CtaDs,@CtaHs,@PorcDs,@CtaD,@CtaH,@PorcD,@IB_AxA,@Actividades,@Actividad,@IB_DxA,@NroCtaDifEmp,@CuentaDifEmp,@NroCtaDifOb
r,@CuentaDifObr,@IB_DxRP,@msj output  
   else if(@HrsTrabPla=0 and @SumHrsXMes<>0)  
    set @msj = 'No se pueden generar asientos debido a que el trabajador posee Horas Trabajadas en su Planillón que se basan en sus Horas de Tareo Diario'  
   else if(@HrsTrabPla<>0 and @SumHrsXMes<>0)  
    set @msj = 'No se pueden generar asientos debido a que el trabajador posee Horas Trabajadas en su Planillón que se basan en sus Horas de Tareo Diario'  
  end  
 else if(@IB_GAxCCF=1 and @IB_GAxCCTD=0 and @IB_TrabATD=1 and @IB_TrabHTHTD=0)  
  begin  
   print '-1010'  
   if(@HrsTrabPla=0 and @SumHrsXMes=0)  
    set @msj = 'No se pueden generar asientos debido a que el trabajador no posee Horas Trabajadas en su Planillón, para el periodo o semana actual'  
   else if(@HrsTrabPla<>0 and @SumHrsXMes=0)  
    exec Pln_GenerarAsientosPlanilla2_CentroCostosFicha @i,@RucE,@Ejer,@Prdo,@Sem,@Cd_Trab,@Cd_Actividad,@Cd_Conceptos,@Importes,@Cd_Concepto,@Importe,@j,@Cd_CCs,@Cd_SCs,@Cd_SSs,@SumHrss,@ImporteTD,@Porcs,@Cd_CC,@Cd_SC,@Cd_SS,@SumHrs,@Porc,@s,@NroCta,@Cue
nta,@Cd_TD,@NroSre,@NroDoc,@Cd_Trabajador,@HrsTrabPla,@SumHrsXMes,@IB_CDxPCC,@RegCtb,@Cd_Fte,@Trabajador,@CamMda,@Cd_Area,@UsuCrea,@k,@CtaDs,@CtaHs,@PorcDs,@CtaD,@CtaH,@PorcD,@IB_AxA,@Actividades,@Actividad,@IB_DxA,@NroCtaDifEmp,@CuentaDifEmp,@NroCtaDifOb
r,@CuentaDifObr,@IB_DxRP,@msj output  
   else if(@HrsTrabPla=0 and @SumHrsXMes<>0)  
    set @msj = 'No se pueden generar asientos debido a que el trabajador no posee Horas Trabajadas en su Planillón, para el periodo o semana actual'  
   else if(@HrsTrabPla<>0 and @SumHrsXMes<>0)  
    exec Pln_GenerarAsientosPlanilla2_CentroCostosFicha @i,@RucE,@Ejer,@Prdo,@Sem,@Cd_Trab,@Cd_Actividad,@Cd_Conceptos,@Importes,@Cd_Concepto,@Importe,@j,@Cd_CCs,@Cd_SCs,@Cd_SSs,@SumHrss,@ImporteTD,@Porcs,@Cd_CC,@Cd_SC,@Cd_SS,@SumHrs,@Porc,@s,@NroCta,@Cue
nta,@Cd_TD,@NroSre,@NroDoc,@Cd_Trabajador,@HrsTrabPla,@SumHrsXMes,@IB_CDxPCC,@RegCtb,@Cd_Fte,@Trabajador,@CamMda,@Cd_Area,@UsuCrea,@k,@CtaDs,@CtaHs,@PorcDs,@CtaD,@CtaH,@PorcD,@IB_AxA,@Actividades,@Actividad,@IB_DxA,@NroCtaDifEmp,@CuentaDifEmp,@NroCtaDifOb
r,@CuentaDifObr,@IB_DxRP,@msj output  
  end  
 else if(@IB_GAxCCF=1 and @IB_GAxCCTD=0 and @IB_TrabATD=1 and @IB_TrabHTHTD=1)  
  begin  
   print '-1011'  
   if(@HrsTrabPla=0 and @SumHrsXMes=0)  
    set @msj = 'No se pueden generar asientos debido a que el trabajador no posee Horas Trabajadas en su Planillón, para el periodo o semana actual'  
   else if(@HrsTrabPla<>0 and @SumHrsXMes=0)  
    exec Pln_GenerarAsientosPlanilla2_CentroCostosFicha @i,@RucE,@Ejer,@Prdo,@Sem,@Cd_Trab,@Cd_Actividad,@Cd_Conceptos,@Importes,@Cd_Concepto,@Importe,@j,@Cd_CCs,@Cd_SCs,@Cd_SSs,@SumHrss,@ImporteTD,@Porcs,@Cd_CC,@Cd_SC,@Cd_SS,@SumHrs,@Porc,@s,@NroCta,@Cue
nta,@Cd_TD,@NroSre,@NroDoc,@Cd_Trabajador,@HrsTrabPla,@SumHrsXMes,@IB_CDxPCC,@RegCtb,@Cd_Fte,@Trabajador,@CamMda,@Cd_Area,@UsuCrea,@k,@CtaDs,@CtaHs,@PorcDs,@CtaD,@CtaH,@PorcD,@IB_AxA,@Actividades,@Actividad,@IB_DxA,@NroCtaDifEmp,@CuentaDifEmp,@NroCtaDifOb
r,@CuentaDifObr,@IB_DxRP,@msj output  
   else if(@HrsTrabPla=0 and @SumHrsXMes<>0)  
    set @msj = 'No se pueden generar asientos debido a que el trabajador posee Horas Trabajadas en su Planillón que se basan en sus Horas de Tareo Diario'  
   else if(@HrsTrabPla<>0 and @SumHrsXMes<>0)  
    set @msj = 'No se pueden generar asientos debido a que el trabajador posee Horas Trabajadas en su Planillón que se basan en sus Horas de Tareo Diario'  
  end  
 else if(@IB_GAxCCF=0 and @IB_GAxCCTD=1 and @IB_TrabATD=0 and @IB_TrabHTHTD=0)  
  begin  
   print '-0100'  
   if(@HrsTrabPla=0 and @SumHrsXMes=0)  
    set @msj = 'No se pueden generar asientos debido a que el trabajador no posee Horas en su Tareo Diario, para el periodo o semana actual'  
   else if(@HrsTrabPla<>0 and @SumHrsXMes=0)  
    set @msj = 'No se pueden generar asientos debido a que el trabajador no posee Horas en su Tareo Diario, para el periodo o semana actual'  
   else if(@HrsTrabPla=0 and @SumHrsXMes<>0)  
    exec Pln_GenerarAsientosPlanilla2_CentroCostosTareoDiario @i,@RucE,@Ejer,@Prdo,@Sem,@Cd_Trab,@Cd_Actividad,@Cd_Conceptos,@Importes,@Cd_Concepto,@Importe,@j,@Cd_CCs,@Cd_SCs,@Cd_SSs,@SumHrss,@ImporteTD,@Porcs,@Cd_CC,@Cd_SC,@Cd_SS,@SumHrs,@Porc,@s,@NroCt
a,@Cuenta,@Cd_TD,@NroSre,@NroDoc,@Cd_Trabajador,@HrsTrabPla,@SumHrsXMes,@IB_CDxPCC,@RegCtb,@Cd_Fte,@Trabajador,@CamMda,@Cd_Area,@UsuCrea,@k,@CtaDs,@CtaHs,@PorcDs,@CtaD,@CtaH,@PorcD,@IB_AxA,@Actividades,@Actividad,@IB_DxA,@NroCtaDifEmp,@CuentaDifEmp,@NroCt
aDifObr,@CuentaDifObr,@IB_DxRP,@msj output  
   else if(@HrsTrabPla<>0 and @SumHrsXMes<>0)  
    exec Pln_GenerarAsientosPlanilla2_CentroCostosTareoDiario @i,@RucE,@Ejer,@Prdo,@Sem,@Cd_Trab,@Cd_Actividad,@Cd_Conceptos,@Importes,@Cd_Concepto,@Importe,@j,@Cd_CCs,@Cd_SCs,@Cd_SSs,@SumHrss,@ImporteTD,@Porcs,@Cd_CC,@Cd_SC,@Cd_SS,@SumHrs,@Porc,@s,@NroCt
a,@Cuenta,@Cd_TD,@NroSre,@NroDoc,@Cd_Trabajador,@HrsTrabPla,@SumHrsXMes,@IB_CDxPCC,@RegCtb,@Cd_Fte,@Trabajador,@CamMda,@Cd_Area,@UsuCrea,@k,@CtaDs,@CtaHs,@PorcDs,@CtaD,@CtaH,@PorcD,@IB_AxA,@Actividades,@Actividad,@IB_DxA,@NroCtaDifEmp,@CuentaDifEmp,@NroCt
aDifObr,@CuentaDifObr,@IB_DxRP,@msj output  
  end  
 else if(@IB_GAxCCF=0 and @IB_GAxCCTD=1 and @IB_TrabATD=0 and @IB_TrabHTHTD=1)  
  begin  
   print '-0101'  
   if(@HrsTrabPla=0 and @SumHrsXMes=0)  
    set @msj = 'No se pueden generar asientos debido a que el trabajador no posee Horas en su Tareo Diario, para el periodo o semana actual'  
   else if(@HrsTrabPla<>0 and @SumHrsXMes=0)  
    set @msj = 'No se pueden generar asientos debido a que el trabajador no posee Horas en su Tareo Diario, para el periodo o semana actual'  
   else if(@HrsTrabPla=0 and @SumHrsXMes<>0)  
    exec Pln_GenerarAsientosPlanilla2_CentroCostosTareoDiario @i,@RucE,@Ejer,@Prdo,@Sem,@Cd_Trab,@Cd_Actividad,@Cd_Conceptos,@Importes,@Cd_Concepto,@Importe,@j,@Cd_CCs,@Cd_SCs,@Cd_SSs,@SumHrss,@ImporteTD,@Porcs,@Cd_CC,@Cd_SC,@Cd_SS,@SumHrs,@Porc,@s,@NroCt
a,@Cuenta,@Cd_TD,@NroSre,@NroDoc,@Cd_Trabajador,@HrsTrabPla,@SumHrsXMes,@IB_CDxPCC,@RegCtb,@Cd_Fte,@Trabajador,@CamMda,@Cd_Area,@UsuCrea,@k,@CtaDs,@CtaHs,@PorcDs,@CtaD,@CtaH,@PorcD,@IB_AxA,@Actividades,@Actividad,@IB_DxA,@NroCtaDifEmp,@CuentaDifEmp,@NroCt
aDifObr,@CuentaDifObr,@IB_DxRP,@msj output  
   else if(@HrsTrabPla<>0 and @SumHrsXMes<>0)  
    exec Pln_GenerarAsientosPlanilla2_CentroCostosTareoDiario @i,@RucE,@Ejer,@Prdo,@Sem,@Cd_Trab,@Cd_Actividad,@Cd_Conceptos,@Importes,@Cd_Concepto,@Importe,@j,@Cd_CCs,@Cd_SCs,@Cd_SSs,@SumHrss,@ImporteTD,@Porcs,@Cd_CC,@Cd_SC,@Cd_SS,@SumHrs,@Porc,@s,@NroCt
a,@Cuenta,@Cd_TD,@NroSre,@NroDoc,@Cd_Trabajador,@HrsTrabPla,@SumHrsXMes,@IB_CDxPCC,@RegCtb,@Cd_Fte,@Trabajador,@CamMda,@Cd_Area,@UsuCrea,@k,@CtaDs,@CtaHs,@PorcDs,@CtaD,@CtaH,@PorcD,@IB_AxA,@Actividades,@Actividad,@IB_DxA,@NroCtaDifEmp,@CuentaDifEmp,@NroCt
aDifObr,@CuentaDifObr,@IB_DxRP,@msj output  
  end  
 else if(@IB_GAxCCF=0 and @IB_GAxCCTD=1 and @IB_TrabATD=1 and @IB_TrabHTHTD=0)  
  begin  
   print '-0110'  
   if(@HrsTrabPla=0 and @SumHrsXMes=0)  
    set @msj = 'No se pueden generar asientos debido a que el trabajador no posee Horas en su Tareo Diario, para el periodo o semana actual'  
   else if(@HrsTrabPla<>0 and @SumHrsXMes=0)  
    set @msj = 'No se pueden generar asientos debido a que el trabajador no posee Horas en su Tareo Diario, para el periodo o semana actual'  
   else if(@HrsTrabPla=0 and @SumHrsXMes<>0)  
    exec Pln_GenerarAsientosPlanilla2_CentroCostosTareoDiario @i,@RucE,@Ejer,@Prdo,@Sem,@Cd_Trab,@Cd_Actividad,@Cd_Conceptos,@Importes,@Cd_Concepto,@Importe,@j,@Cd_CCs,@Cd_SCs,@Cd_SSs,@SumHrss,@ImporteTD,@Porcs,@Cd_CC,@Cd_SC,@Cd_SS,@SumHrs,@Porc,@s,@NroCt
a,@Cuenta,@Cd_TD,@NroSre,@NroDoc,@Cd_Trabajador,@HrsTrabPla,@SumHrsXMes,@IB_CDxPCC,@RegCtb,@Cd_Fte,@Trabajador,@CamMda,@Cd_Area,@UsuCrea,@k,@CtaDs,@CtaHs,@PorcDs,@CtaD,@CtaH,@PorcD,@IB_AxA,@Actividades,@Actividad,@IB_DxA,@NroCtaDifEmp,@CuentaDifEmp,@NroCt
aDifObr,@CuentaDifObr,@IB_DxRP,@msj output  
   else if(@HrsTrabPla<>0 and @SumHrsXMes<>0)  
    exec Pln_GenerarAsientosPlanilla2_CentroCostosTareoDiario @i,@RucE,@Ejer,@Prdo,@Sem,@Cd_Trab,@Cd_Actividad,@Cd_Conceptos,@Importes,@Cd_Concepto,@Importe,@j,@Cd_CCs,@Cd_SCs,@Cd_SSs,@SumHrss,@ImporteTD,@Porcs,@Cd_CC,@Cd_SC,@Cd_SS,@SumHrs,@Porc,@s,@NroCt
a,@Cuenta,@Cd_TD,@NroSre,@NroDoc,@Cd_Trabajador,@HrsTrabPla,@SumHrsXMes,@IB_CDxPCC,@RegCtb,@Cd_Fte,@Trabajador,@CamMda,@Cd_Area,@UsuCrea,@k,@CtaDs,@CtaHs,@PorcDs,@CtaD,@CtaH,@PorcD,@IB_AxA,@Actividades,@Actividad,@IB_DxA,@NroCtaDifEmp,@CuentaDifEmp,@NroCt
aDifObr,@CuentaDifObr,@IB_DxRP,@msj output  
  end  
 else if(@IB_GAxCCF=0 and @IB_GAxCCTD=1 and @IB_TrabATD=1 and @IB_TrabHTHTD=1)  
  begin  
   print '-0111'  
   if(@HrsTrabPla=0 and @SumHrsXMes=0)  
    set @msj = 'No se pueden generar asientos debido a que el trabajador no posee Horas en su Tareo Diario, para el periodo o semana actual'  
   else if(@HrsTrabPla<>0 and @SumHrsXMes=0)  
    set @msj = 'No se pueden generar asientos debido a que el trabajador no posee Horas en su Tareo Diario, para el periodo o semana actual'  
   else if(@HrsTrabPla=0 and @SumHrsXMes<>0)  
    exec Pln_GenerarAsientosPlanilla2_CentroCostosTareoDiario @i,@RucE,@Ejer,@Prdo,@Sem,@Cd_Trab,@Cd_Actividad,@Cd_Conceptos,@Importes,@Cd_Concepto,@Importe,@j,@Cd_CCs,@Cd_SCs,@Cd_SSs,@SumHrss,@ImporteTD,@Porcs,@Cd_CC,@Cd_SC,@Cd_SS,@SumHrs,@Porc,@s,@NroCt
a,@Cuenta,@Cd_TD,@NroSre,@NroDoc,@Cd_Trabajador,@HrsTrabPla,@SumHrsXMes,@IB_CDxPCC,@RegCtb,@Cd_Fte,@Trabajador,@CamMda,@Cd_Area,@UsuCrea,@k,@CtaDs,@CtaHs,@PorcDs,@CtaD,@CtaH,@PorcD,@IB_AxA,@Actividades,@Actividad,@IB_DxA,@NroCtaDifEmp,@CuentaDifEmp,@NroCt
aDifObr,@CuentaDifObr,@IB_DxRP,@msj output  
   else if(@HrsTrabPla<>0 and @SumHrsXMes<>0)  
    exec Pln_GenerarAsientosPlanilla2_CentroCostosTareoDiario @i,@RucE,@Ejer,@Prdo,@Sem,@Cd_Trab,@Cd_Actividad,@Cd_Conceptos,@Importes,@Cd_Concepto,@Importe,@j,@Cd_CCs,@Cd_SCs,@Cd_SSs,@SumHrss,@ImporteTD,@Porcs,@Cd_CC,@Cd_SC,@Cd_SS,@SumHrs,@Porc,@s,@NroCt
a,@Cuenta,@Cd_TD,@NroSre,@NroDoc,@Cd_Trabajador,@HrsTrabPla,@SumHrsXMes,@IB_CDxPCC,@RegCtb,@Cd_Fte,@Trabajador,@CamMda,@Cd_Area,@UsuCrea,@k,@CtaDs,@CtaHs,@PorcDs,@CtaD,@CtaH,@PorcD,@IB_AxA,@Actividades,@Actividad,@IB_DxA,@NroCtaDifEmp,@CuentaDifEmp,@NroCt
aDifObr,@CuentaDifObr,@IB_DxRP,@msj output  
  end  
 else if(@IB_GAxCCF=1 and @IB_GAxCCTD=1 and @IB_TrabATD=0 and @IB_TrabHTHTD=0)  
  begin  
   print '-1100'  
   if(@HrsTrabPla=0 and @SumHrsXMes=0)  
    set @msj = 'No se pueden generar asientos debido a que el trabajador no posee Horas Trabajadas en su Planillón u Horas en su Tareo Diario, para el periodo o semana actual'  
   else if(@HrsTrabPla<>0 and @SumHrsXMes=0)  
    exec Pln_GenerarAsientosPlanilla2_CentroCostosFicha @i,@RucE,@Ejer,@Prdo,@Sem,@Cd_Trab,@Cd_Actividad,@Cd_Conceptos,@Importes,@Cd_Concepto,@Importe,@j,@Cd_CCs,@Cd_SCs,@Cd_SSs,@SumHrss,@ImporteTD,@Porcs,@Cd_CC,@Cd_SC,@Cd_SS,@SumHrs,@Porc,@s,@NroCta,@Cue
nta,@Cd_TD,@NroSre,@NroDoc,@Cd_Trabajador,@HrsTrabPla,@SumHrsXMes,@IB_CDxPCC,@RegCtb,@Cd_Fte,@Trabajador,@CamMda,@Cd_Area,@UsuCrea,@k,@CtaDs,@CtaHs,@PorcDs,@CtaD,@CtaH,@PorcD,@IB_AxA,@Actividades,@Actividad,@IB_DxA,@NroCtaDifEmp,@CuentaDifEmp,@NroCtaDifOb
r,@CuentaDifObr,@IB_DxRP,@msj output  
   else if(@HrsTrabPla=0 and @SumHrsXMes<>0)  
    exec Pln_GenerarAsientosPlanilla2_CentroCostosTareoDiario @i,@RucE,@Ejer,@Prdo,@Sem,@Cd_Trab,@Cd_Actividad,@Cd_Conceptos,@Importes,@Cd_Concepto,@Importe,@j,@Cd_CCs,@Cd_SCs,@Cd_SSs,@SumHrss,@ImporteTD,@Porcs,@Cd_CC,@Cd_SC,@Cd_SS,@SumHrs,@Porc,@s,@NroCt
a,@Cuenta,@Cd_TD,@NroSre,@NroDoc,@Cd_Trabajador,@HrsTrabPla,@SumHrsXMes,@IB_CDxPCC,@RegCtb,@Cd_Fte,@Trabajador,@CamMda,@Cd_Area,@UsuCrea,@k,@CtaDs,@CtaHs,@PorcDs,@CtaD,@CtaH,@PorcD,@IB_AxA,@Actividades,@Actividad,@IB_DxA,@NroCtaDifEmp,@CuentaDifEmp,@NroCt
aDifObr,@CuentaDifObr,@IB_DxRP,@msj output  
   else if(@HrsTrabPla<>0 and @SumHrsXMes<>0)  
    exec Pln_GenerarAsientosPlanilla2_CentroCostosTareoDiarioFicha @i,@RucE,@Ejer,@Prdo,@Sem,@Cd_Trab,@Cd_Actividad,@Cd_Conceptos,@Importes,@Cd_Concepto,@Importe,@j,@Cd_CCs,@Cd_SCs,@Cd_SSs,@SumHrss,@ImporteTD,@Porcs,@Cd_CC,@Cd_SC,@Cd_SS,@SumHrs,@Porc,@s,@
NroCta,@Cuenta,@Cd_TD,@NroSre,@NroDoc,@Cd_Trabajador,@HrsTrabPla,@SumHrsXMes,@IB_CDxPCC,@RegCtb,@Cd_Fte,@Trabajador,@CamMda,@Cd_Area,@UsuCrea,@k,@CtaDs,@CtaHs,@PorcDs,@CtaD,@CtaH,@PorcD,@IB_AxA,@Actividades,@Actividad,@IB_DxA,@NroCtaDifEmp,@CuentaDifEmp,@
NroCtaDifObr,@CuentaDifObr,@IB_DxRP,@msj output  
  end  
 else if(@IB_GAxCCF=1 and @IB_GAxCCTD=1 and @IB_TrabATD=0 and @IB_TrabHTHTD=1)  
  begin  
   print '-1101'  
   if(@HrsTrabPla=0 and @SumHrsXMes=0)  
    set @msj = 'No se pueden generar asientos debido a que el trabajador no posee Horas Trabajadas en su Planillón u Horas en su Tareo Diario, para el periodo o semana actual'  
   else if(@HrsTrabPla<>0 and @SumHrsXMes=0)  
    exec Pln_GenerarAsientosPlanilla2_CentroCostosFicha @i,@RucE,@Ejer,@Prdo,@Sem,@Cd_Trab,@Cd_Actividad,@Cd_Conceptos,@Importes,@Cd_Concepto,@Importe,@j,@Cd_CCs,@Cd_SCs,@Cd_SSs,@SumHrss,@ImporteTD,@Porcs,@Cd_CC,@Cd_SC,@Cd_SS,@SumHrs,@Porc,@s,@NroCta,@Cue
nta,@Cd_TD,@NroSre,@NroDoc,@Cd_Trabajador,@HrsTrabPla,@SumHrsXMes,@IB_CDxPCC,@RegCtb,@Cd_Fte,@Trabajador,@CamMda,@Cd_Area,@UsuCrea,@k,@CtaDs,@CtaHs,@PorcDs,@CtaD,@CtaH,@PorcD,@IB_AxA,@Actividades,@Actividad,@IB_DxA,@NroCtaDifEmp,@CuentaDifEmp,@NroCtaDifOb
r,@CuentaDifObr,@IB_DxRP,@msj output  
   else if(@HrsTrabPla=0 and @SumHrsXMes<>0)  
    exec Pln_GenerarAsientosPlanilla2_CentroCostosTareoDiario @i,@RucE,@Ejer,@Prdo,@Sem,@Cd_Trab,@Cd_Actividad,@Cd_Conceptos,@Importes,@Cd_Concepto,@Importe,@j,@Cd_CCs,@Cd_SCs,@Cd_SSs,@SumHrss,@ImporteTD,@Porcs,@Cd_CC,@Cd_SC,@Cd_SS,@SumHrs,@Porc,@s,@NroCt
a,@Cuenta,@Cd_TD,@NroSre,@NroDoc,@Cd_Trabajador,@HrsTrabPla,@SumHrsXMes,@IB_CDxPCC,@RegCtb,@Cd_Fte,@Trabajador,@CamMda,@Cd_Area,@UsuCrea,@k,@CtaDs,@CtaHs,@PorcDs,@CtaD,@CtaH,@PorcD,@IB_AxA,@Actividades,@Actividad,@IB_DxA,@NroCtaDifEmp,@CuentaDifEmp,@NroCt
aDifObr,@CuentaDifObr,@IB_DxRP,@msj output  
   else if(@HrsTrabPla<>0 and @SumHrsXMes<>0)  
    exec Pln_GenerarAsientosPlanilla2_CentroCostosTareoDiario @i,@RucE,@Ejer,@Prdo,@Sem,@Cd_Trab,@Cd_Actividad,@Cd_Conceptos,@Importes,@Cd_Concepto,@Importe,@j,@Cd_CCs,@Cd_SCs,@Cd_SSs,@SumHrss,@ImporteTD,@Porcs,@Cd_CC,@Cd_SC,@Cd_SS,@SumHrs,@Porc,@s,@NroCt
a,@Cuenta,@Cd_TD,@NroSre,@NroDoc,@Cd_Trabajador,@HrsTrabPla,@SumHrsXMes,@IB_CDxPCC,@RegCtb,@Cd_Fte,@Trabajador,@CamMda,@Cd_Area,@UsuCrea,@k,@CtaDs,@CtaHs,@PorcDs,@CtaD,@CtaH,@PorcD,@IB_AxA,@Actividades,@Actividad,@IB_DxA,@NroCtaDifEmp,@CuentaDifEmp,@NroCt
aDifObr,@CuentaDifObr,@IB_DxRP,@msj output  
  end  
 else if(@IB_GAxCCF=1 and @IB_GAxCCTD=1 and @IB_TrabATD=1 and @IB_TrabHTHTD=0)  
  begin  
   print '-1110'  
   if(@HrsTrabPla=0 and @SumHrsXMes=0)  
    set @msj = 'No se pueden generar asientos debido a que el trabajador no posee Horas Trabajadas en su Planillón u Horas en su Tareo Diario, para el periodo o semana actual'  
   else if(@HrsTrabPla<>0 and @SumHrsXMes=0)  
    exec Pln_GenerarAsientosPlanilla2_CentroCostosFicha @i,@RucE,@Ejer,@Prdo,@Sem,@Cd_Trab,@Cd_Actividad,@Cd_Conceptos,@Importes,@Cd_Concepto,@Importe,@j,@Cd_CCs,@Cd_SCs,@Cd_SSs,@SumHrss,@ImporteTD,@Porcs,@Cd_CC,@Cd_SC,@Cd_SS,@SumHrs,@Porc,@s,@NroCta,@Cue
nta,@Cd_TD,@NroSre,@NroDoc,@Cd_Trabajador,@HrsTrabPla,@SumHrsXMes,@IB_CDxPCC,@RegCtb,@Cd_Fte,@Trabajador,@CamMda,@Cd_Area,@UsuCrea,@k,@CtaDs,@CtaHs,@PorcDs,@CtaD,@CtaH,@PorcD,@IB_AxA,@Actividades,@Actividad,@IB_DxA,@NroCtaDifEmp,@CuentaDifEmp,@NroCtaDifOb
r,@CuentaDifObr,@IB_DxRP,@msj output  
   else if(@HrsTrabPla=0 and @SumHrsXMes<>0)  
    exec Pln_GenerarAsientosPlanilla2_CentroCostosTareoDiario @i,@RucE,@Ejer,@Prdo,@Sem,@Cd_Trab,@Cd_Actividad,@Cd_Conceptos,@Importes,@Cd_Concepto,@Importe,@j,@Cd_CCs,@Cd_SCs,@Cd_SSs,@SumHrss,@ImporteTD,@Porcs,@Cd_CC,@Cd_SC,@Cd_SS,@SumHrs,@Porc,@s,@NroCt
a,@Cuenta,@Cd_TD,@NroSre,@NroDoc,@Cd_Trabajador,@HrsTrabPla,@SumHrsXMes,@IB_CDxPCC,@RegCtb,@Cd_Fte,@Trabajador,@CamMda,@Cd_Area,@UsuCrea,@k,@CtaDs,@CtaHs,@PorcDs,@CtaD,@CtaH,@PorcD,@IB_AxA,@Actividades,@Actividad,@IB_DxA,@NroCtaDifEmp,@CuentaDifEmp,@NroCt
aDifObr,@CuentaDifObr,@IB_DxRP,@msj output  
   else if(@HrsTrabPla<>0 and @SumHrsXMes<>0)  
    exec Pln_GenerarAsientosPlanilla2_CentroCostosTareoDiarioFicha @i,@RucE,@Ejer,@Prdo,@Sem,@Cd_Trab,@Cd_Actividad,@Cd_Conceptos,@Importes,@Cd_Concepto,@Importe,@j,@Cd_CCs,@Cd_SCs,@Cd_SSs,@SumHrss,@ImporteTD,@Porcs,@Cd_CC,@Cd_SC,@Cd_SS,@SumHrs,@Porc,@s,@
NroCta,@Cuenta,@Cd_TD,@NroSre,@NroDoc,@Cd_Trabajador,@HrsTrabPla,@SumHrsXMes,@IB_CDxPCC,@RegCtb,@Cd_Fte,@Trabajador,@CamMda,@Cd_Area,@UsuCrea,@k,@CtaDs,@CtaHs,@PorcDs,@CtaD,@CtaH,@PorcD,@IB_AxA,@Actividades,@Actividad,@IB_DxA,@NroCtaDifEmp,@CuentaDifEmp,@
NroCtaDifObr,@CuentaDifObr,@IB_DxRP,@msj output  
  end  
 else if(@IB_GAxCCF=1 and @IB_GAxCCTD=1 and @IB_TrabATD=1 and @IB_TrabHTHTD=1)  
  begin  
   print '-1111'  
   if(@HrsTrabPla=0 and @SumHrsXMes=0)  
    set @msj = 'No se pueden generar asientos debido a que el trabajador no posee Horas Trabajadas en su Planillón u Horas en su Tareo Diario, para el periodo o semana actual'  
   else if(@HrsTrabPla<>0 and @SumHrsXMes=0)  
    exec Pln_GenerarAsientosPlanilla2_CentroCostosFicha @i,@RucE,@Ejer,@Prdo,@Sem,@Cd_Trab,@Cd_Actividad,@Cd_Conceptos,@Importes,@Cd_Concepto,@Importe,@j,@Cd_CCs,@Cd_SCs,@Cd_SSs,@SumHrss,@ImporteTD,@Porcs,@Cd_CC,@Cd_SC,@Cd_SS,@SumHrs,@Porc,@s,@NroCta,@Cue
nta,@Cd_TD,@NroSre,@NroDoc,@Cd_Trabajador,@HrsTrabPla,@SumHrsXMes,@IB_CDxPCC,@RegCtb,@Cd_Fte,@Trabajador,@CamMda,@Cd_Area,@UsuCrea,@k,@CtaDs,@CtaHs,@PorcDs,@CtaD,@CtaH,@PorcD,@IB_AxA,@Actividades,@Actividad,@IB_DxA,@NroCtaDifEmp,@CuentaDifEmp,@NroCtaDifOb
r,@CuentaDifObr,@IB_DxRP,@msj output  
   else if(@HrsTrabPla=0 and @SumHrsXMes<>0)  
    exec Pln_GenerarAsientosPlanilla2_CentroCostosTareoDiario @i,@RucE,@Ejer,@Prdo,@Sem,@Cd_Trab,@Cd_Actividad,@Cd_Conceptos,@Importes,@Cd_Concepto,@Importe,@j,@Cd_CCs,@Cd_SCs,@Cd_SSs,@SumHrss,@ImporteTD,@Porcs,@Cd_CC,@Cd_SC,@Cd_SS,@SumHrs,@Porc,@s,@NroCt
a,@Cuenta,@Cd_TD,@NroSre,@NroDoc,@Cd_Trabajador,@HrsTrabPla,@SumHrsXMes,@IB_CDxPCC,@RegCtb,@Cd_Fte,@Trabajador,@CamMda,@Cd_Area,@UsuCrea,@k,@CtaDs,@CtaHs,@PorcDs,@CtaD,@CtaH,@PorcD,@IB_AxA,@Actividades,@Actividad,@IB_DxA,@NroCtaDifEmp,@CuentaDifEmp,@NroCt
aDifObr,@CuentaDifObr,@IB_DxRP,@msj output  
   else if(@HrsTrabPla<>0 and @SumHrsXMes<>0)  
    exec Pln_GenerarAsientosPlanilla2_CentroCostosTareoDiario @i,@RucE,@Ejer,@Prdo,@Sem,@Cd_Trab,@Cd_Actividad,@Cd_Conceptos,@Importes,@Cd_Concepto,@Importe,@j,@Cd_CCs,@Cd_SCs,@Cd_SSs,@SumHrss,@ImporteTD,@Porcs,@Cd_CC,@Cd_SC,@Cd_SS,@SumHrs,@Porc,@s,@NroCt
a,@Cuenta,@Cd_TD,@NroSre,@NroDoc,@Cd_Trabajador,@HrsTrabPla,@SumHrsXMes,@IB_CDxPCC,@RegCtb,@Cd_Fte,@Trabajador,@CamMda,@Cd_Area,@UsuCrea,@k,@CtaDs,@CtaHs,@PorcDs,@CtaD,@CtaH,@PorcD,@IB_AxA,@Actividades,@Actividad,@IB_DxA,@NroCtaDifEmp,@CuentaDifEmp,@NroCt
aDifObr,@CuentaDifObr,@IB_DxRP,@msj output  
  end  
 */  
  
 select @msj  
end  
  
/* Leyenda  
-DJ: 21/10/2019 <Se versionaron los queries Pln_GenerarAsientosPlanilla2_CentroCostosFicha_1, Pln_GenerarAsientosPlanilla2_CentroCostosTareoDiario_1, Pln_GenerarAsientosPlanilla2_CentroCostosFicha_1 y Pln_GenerarAsientosPlanilla2_CentroCostosTareoDiarioFi
cha_1>  
-DJ: 16/01/2020 <Se validó el uso de Centro de Costo Histórico de acuerdo a la configuración C_IB_CENTRO_COSTO_HISTORICO>  
-Pedro: 26/10/2020 <Se validó el cierre del Periodo de contabilidad para no continuar el asiento>  
-DJ: 19/07/2021 <Se cambiaron las variables @NroCtaDifEmp, @NroCtaDifObr, @NroCta,@CtaD y @CtaH a varchar(50)>  
-Pedro: 28/02/2024 <Se contabiliza bien las horas trabajadas por semana para obreros: HrsTrabPla >  
*/