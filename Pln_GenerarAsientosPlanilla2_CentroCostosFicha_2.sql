USE [ERP_ECHA]
GO
/****** Object:  StoredProcedure [dbo].[Pln_GenerarAsientosPlanilla2_CentroCostosFicha_2]    Script Date: 14/01/2026 15:22:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER   PROCEDURE [dbo].[Pln_GenerarAsientosPlanilla2_CentroCostosFicha_2]
(
	@i int,
	@RucE nvarchar(11),
	@Ejer char(4),
	@Prdo char(2),
	@Sem char(2),
	@Cd_Trab char(8),
	@Cd_Actividad char(3),
	@Cd_Conceptos varchar(max),
	@Importes varchar(max),
	@Cd_Concepto varchar(4),
	@Importe numeric(13,2),
	@j int,
	@Cd_CCs varchar(max),
	@Cd_SCs varchar(max),
	@Cd_SSs varchar(max),
	@SumHrss varchar(max),
	@ImporteTD numeric(13,2),
	@Porcs varchar(max),
	@Cd_CC varchar(8),
	@Cd_SC varchar(8),
	@Cd_SS varchar(8),
	@SumHrs decimal(5,2),
	@Porc numeric(5,2),
	@s varchar(max),
	@NroCta varchar(50),
	@Cuenta varchar(200),
	@Cd_TD char(2),
	@NroSre char(6),
	@NroDoc varchar(15),
	@Cd_Trabajador char(8),
	@HrsTrabPla numeric(5,2),
	@SumHrsXMes decimal(5,2),
	@IB_CDxPCC bit,
	@RegCtb nvarchar(30),
	@Cd_Fte char(2),
	@Trabajador varchar(120),
	@CamMda numeric(6,3),
	@Cd_Area varchar(6),
	@UsuCrea nvarchar(50),
	@k int,
	@CtaDs varchar(max),
	@CtaHs varchar(max),
	@PorcDs varchar(max),
	@CtaD varchar(50),
	@CtaH varchar(50),
	@PorcD numeric(5,2),
	@IB_AxA bit,
	@Actividades varchar(max),
	@Actividad varchar(50),
	@IB_DxA bit,
	@NroCtaDifEmp varchar(50),
	@CuentaDifEmp varchar(200),
	@NroCtaDifObr varchar(50),
	@CuentaDifObr varchar(200),
	@IB_DxRP bit,
	@msj nvarchar(max) output
)
as

--declare 
--	@i int=null,
--	@RucE nvarchar(11)='20102351038',
--	@Ejer char(4)='2025',
--	@Prdo char(2)='05',
--	@Sem char(2)='',
--	@Cd_Trab char(8)='T0000087',
--	@Cd_Actividad char(3)='',
--	@Cd_Conceptos varchar(max)='',
--	@Importes varchar(max)='',
--	@Cd_Concepto varchar(4)=null,
--	@Importe numeric(13,2)=null,
--	@j int=null,
--	@Cd_CCs varchar(max)='',
--	@Cd_SCs varchar(max)='',
--	@Cd_SSs varchar(max)='',
--	@SumHrss varchar(max)='',
--	@ImporteTD numeric(13,2)=0.00,
--	@Porcs varchar(max)='',
--	@Cd_CC varchar(8)=null,
--	@Cd_SC varchar(8)=null,
--	@Cd_SS varchar(8)=null,
--	@SumHrs decimal(5,2)=null,
--	@Porc numeric(5,2)=null,
--	@s varchar(max)='',
--	@NroCta varchar(50)=null,
--	@Cuenta varchar(200)=null,
--	@Cd_TD char(2)=null,
--	@NroSre char(6)=null,
--	@NroDoc varchar(15)=null,
--	@Cd_Trabajador char(8)=null,
--	@HrsTrabPla numeric(5,2)=1.00,
--	@SumHrsXMes decimal(5,2)=0.00,
--	@IB_CDxPCC bit=0,
--	@RegCtb nvarchar(30)='PEGN_LD05-00005',
--	@Cd_Fte char(2)='LD',
--	@Trabajador varchar(120)=' - PELAEZ CABELLOS, LUIS ALONSO',
--	@CamMda numeric(6,3)=3.793,
--	@Cd_Area varchar(6)='060606',
--	@UsuCrea nvarchar(50)='contanet',
--	@k int=null,
--	@CtaDs varchar(max)='',
--	@CtaHs varchar(max)='',
--	@PorcDs varchar(max)='',
--	@CtaD varchar(50)=null,
--	@CtaH varchar(50)=null,
--	@PorcD numeric(5,2)=null,
--	@IB_AxA bit=0,
--	@Actividades varchar(max)='',
--	@Actividad varchar(50)=null,
--	@IB_DxA bit=1,
--	@NroCtaDifEmp varchar(50)='41.1.1.10',
--	@CuentaDifEmp varchar(200)='SUELDOS POR PAGAR',
--	@NroCtaDifObr varchar(50)='',
--	@CuentaDifObr varchar(200)='',
--	@IB_DxRP bit=1,
--	@msj nvarchar(max)=''
	
begin
	SET LANGUAGE SPANISH
	DECLARE @ImporteDestino numeric(13,5)
	DECLARE @L_IB_DESAGRUPAR_DESTINOS BIT
	DECLARE @date DATETIME = @Prdo+'/'+@Prdo+'/'+@Ejer;  
	DECLARE @FecMov DATETIME = (select planilla.FS_FIN_MES(@date));
	DECLARE @FecCbr DATETIME = (select planilla.FS_FIN_MES(@date));
	declare @IC_TipoPlan char(1) = (select IC_TipoPlan from trabajador where RucE=@RucE and Cd_Trab=@Cd_Trab)

	declare @SumImporteConceptoPorcFicha numeric(13,5) = 0.00
	declare @IB_EsProv bit = 0
	declare @IB_GAxCCF bit = (select isnull(IB_AsientosXTrab, 0) from CfgPlanilla where RucE=@RucE) /*Generar Asiento por Centro de Costos Ficha*/
	declare @TrabajadorXPorcCC table (Cd_Trab char(8), Cd_CC nvarchar(8), Cd_SC nvarchar(8), Cd_SS nvarchar(8), Porc numeric(5,2), IB_CCPrincipal bit)
	declare @Cd_ModContrato char(2) = ISNULL((select Cd_ModContrato from Trabajador where RucE=@RucE and Cd_Trab=@Cd_Trab),'00')

	declare @P_IB_HABILITAR_CONCEPTOS_FLUJO_EFECTIVO_CONTABLE bit = 0
	select @P_IB_HABILITAR_CONCEPTOS_FLUJO_EFECTIVO_CONTABLE = ISNULL(C_IB_HABILITAR_CONCEPTOS_FLUJO_EFECTIVO_CONTABLE,0) from CfgContabilidad where RucE=@RucE
	declare @P_IB_FEC bit = 0, @P_ID_CONCEPTO_FEC int = 0, @IB_CentroCostoHistorico bit = 0, @P_IB_AGRUPAR_CUENTAS bit=0, @P_IB_SEPARAR_CONCEPTOS bit=0
	select @IB_CentroCostoHistorico=C_IB_CENTRO_COSTO_HISTORICO, @P_ID_CONCEPTO_FEC=C_ID_CONCEPTO_FEC, @P_IB_AGRUPAR_CUENTAS=C_IB_AGRUPAR_CUENTAS, @P_IB_SEPARAR_CONCEPTOS=C_IB_SEPARAR_CONCEPTOS from CfgPlanilla where RucE=@RucE

	DECLARE @IB_AMARRE_CUENTA_DESTINO_CENTRO_COSTO BIT = 0

	declare
	@IB_DesgloceAportexCCFicha bit,
	@IB_DesgloceDescuentoxCCFicha bit,
	@IB_DesgloceRegimenPensionarioxCCFicha bit
	
	select
		@IB_DesgloceAportexCCFicha = C_IB_DESGLOCE_APORTE_X_CC_FICHA,
		@IB_DesgloceDescuentoxCCFicha = C_IB_DESGLOCE_DESCUENTO_X_CC_FICHA,
		@IB_DesgloceRegimenPensionarioxCCFicha = C_IB_DESGLOCE_REGIMEN_PENSIONARIO_X_CC_FICHA
	from
		CfgPlanilla
	where
		RucE=@RucE

	declare
	@EjerCC char(4) = (case when @IB_CentroCostoHistorico = 1 and @IC_TipoPlan = 'E' then @Ejer else '' end),
	@PrdoCC char(2) = (case when @IB_CentroCostoHistorico = 1 and @IC_TipoPlan = 'E' then @Prdo else '' end)

	declare @k_total int
	DECLARE @IB_CtaVac BIT

	if (@IB_GAxCCF=1) 
		insert into @TrabajadorXPorcCC
			select Cd_Trab, Cd_CC, Cd_SC, Cd_SS, Porc, IB_CCPrincipal from TrabajadorXPorcCC where RucE=@RucE and C_EJERCICIO=@EjerCC and C_PERIODO=@PrdoCC
	else /*CUANDO LA CONFIGURACIÓN ESTÁ CON EL CC DE TAREO DIARIO Y NO POR FICHA*/
		insert into @TrabajadorXPorcCC
			select Cd_Trab, Cd_CC, Cd_SC, Cd_SS, 100.00, IB_CCPrincipal from TrabajadorXPorcCC where RucE=@RucE and C_EJERCICIO=@EjerCC and C_PERIODO=@PrdoCC and IB_CCPrincipal=1
			
	begin print 'GENERAR ASIENTOS POR C.C. FICHA'+char(13)+char(10)+char(13)+char(10)
		begin print '/*ASIENTOS DE REMUNERACIONES*/'+char(13)+char(10)+char(13)+char(10)
			set @i = (
						select
							COUNT(*)
						from
							(
								select
									rth.Cd_TipRemu
								from
									RemuTrabHist rth
									inner join TipoRemu tr on tr.RucE=rth.RucE and tr.Cd_TipRemu=rth.Cd_TipRemu
									AND CASE WHEN @IC_TipoPlan='E' THEN tr.IB_PlnEmpl ELSE tr.IB_PlnObr END = 1
								where
									rth.RucE=@RucE
									and rth.Ejer=@Ejer
									and rth.Prdo=@Prdo
									and rth.Sem=@Sem
									and rth.Cd_Trab=@Cd_Trab
									and rth.Importe<>0
									and rth.Cd_TipRemu not in (@Cd_Actividad)
								
								union all

								select
									rthq.Cd_TipRemu
								from
									RemuTrabHistQna rthq
									inner join TipoRemu tr on tr.RucE=rthq.RucE and tr.Cd_TipRemu=rthq.Cd_TipRemu and tr.IB_QuincenaAbsoluto=1
									AND CASE WHEN @IC_TipoPlan='E' THEN tr.IB_PlnEmpl ELSE tr.IB_PlnObr END = 1
								where
									rthq.RucE=@RucE
									and rthq.Ejer=@Ejer
									and rthq.Prdo=@Prdo
									and rthq.NroQna='01'
									and rthq.Cd_Trab=@Cd_Trab
									and rthq.Importe<>0
									and rthq.Cd_TipRemu not in (@Cd_Actividad)
							) t
					 )
					 
			set @Cd_Conceptos = ''
			set @Importes = ''

			select
				@Cd_Conceptos += rth.Cd_TipRemu + ',',
				@Importes += CONVERT(varchar,rth.Importe) + ','
			from
				RemuTrabHist rth
				inner join TipoRemu tr on tr.RucE=rth.RucE and tr.Cd_TipRemu=rth.Cd_TipRemu
									AND CASE WHEN @IC_TipoPlan='E' THEN tr.IB_PlnEmpl ELSE tr.IB_PlnObr END = 1
			where
				rth.RucE=@RucE
				and rth.Ejer=@Ejer
				and rth.Prdo=@Prdo
				and rth.Sem=@Sem
				and rth.Cd_Trab=@Cd_Trab
				and rth.Importe<>0
				and rth.Cd_TipRemu not in (@Cd_Actividad)
				
			select
				@Cd_Conceptos += rthq.Cd_TipRemu + ',',
				@Importes += CONVERT(varchar,rthq.Importe) + ','
			from
				RemuTrabHistQna rthq
				inner join TipoRemu tr on tr.RucE=rthq.RucE and tr.Cd_TipRemu=rthq.Cd_TipRemu and tr.IB_QuincenaAbsoluto=1
				AND CASE WHEN @IC_TipoPlan='E' THEN tr.IB_PlnEmpl ELSE tr.IB_PlnObr END = 1
			where
				rthq.RucE=@RucE
				and rthq.Ejer=@Ejer
				and rthq.Prdo=@Prdo
				and rthq.NroQna='01'
				and rthq.Cd_Trab=@Cd_Trab
				and rthq.Importe<>0
				and rthq.Cd_TipRemu not in (@Cd_Actividad)
					
			while(@i>0)
				begin
					set @Cd_Concepto = substring(@Cd_Conceptos, 1, (charindex(',', @Cd_Conceptos)-1))
					set @Importe = substring(@Importes, 1, (charindex(',', @Importes)-1))
							
					set @j = (select count(*) from @TrabajadorXPorcCC txpc where txpc.Cd_Trab=@Cd_Trab)

					set @Cd_CCs = ''
					set @Cd_SCs = ''
					set @Cd_SSs = ''
					set @Porcs = ''

					select @Cd_CCs+=Cd_CC+',', @Cd_SCs+=Cd_SC+',', @Cd_SSs+=Cd_SS+',', @Porcs+=convert(varchar, Porc)+','
					from @TrabajadorXPorcCC txpc where txpc.Cd_Trab=@Cd_Trab
							
					begin print '- Asiento Debe ' + case when @IB_GAxCCF=1 then '(F)' else '(TD)' end + ':'
						set @SumImporteConceptoPorcFicha = 0.00
						while(@j>0)
							begin /*Desgloce por Porcentajes de Centro de Costos*/
								set @Cd_CC = substring(@Cd_CCs, 1, (charindex(',', @Cd_CCs)-1))
								set @Cd_SC = substring(@Cd_SCs, 1, (charindex(',', @Cd_SCs)-1))
								set @Cd_SS = substring(@Cd_SSs, 1, (charindex(',', @Cd_SSs)-1))
								set @Porc = substring(@Porcs, 1, (charindex(',', @Porcs)-1))
										 
								if(not exists (select * from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@cd_SS))
									set @s += 'No existe el amarre de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
								else
									begin
										set @NroCta = isnull((select NroCta from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@cd_SS), '')
										set @Cuenta = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta), '')
										set @P_IB_FEC = ISNULL((select CASE WHEN @P_IB_HABILITAR_CONCEPTOS_FLUJO_EFECTIVO_CONTABLE=1 THEN CASE WHEN ISNULL(IB_CtasXCbr,0)=1 or ISNULL(IB_CtasXPag,0)=1 THEN 1 ELSE 0 END ELSE 0 END from PlanCtas where RucE=@RucE and NroCta=@NroCta and Ejer=@Ejer),0)
											
										if(@NroCta<>'')
											begin
												if((select isnull(C_IB_AUXILIAR_TRABAJADOR, 0) from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta)=1)
													begin
														set @Cd_Trabajador = @Cd_Trab
													end
												else
													begin
														set @Cd_Trabajador = null
													end
												if(ISNULL((select isnull(IB_NDoc, 0) from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta),0) = 1)
													begin
														SET @Cd_TD = (select Cd_TD_AsientosPlanillon from CfgPlanilla where RucE=@RucE)
														select @NroSre=NroSre from dbo.fn_NroDocTrabajador(@RucE,@Cd_TD,@Cd_Trab)
														SET @NroDoc = @Ejer + @Prdo + SUBSTRING(@Cd_Trab,2,7)
														SET @IB_EsProv = 1
													end
												else
													begin
														SET @Cd_TD=null
														SET @NroSre=null
														SET @NroDoc = null
														SET @IB_EsProv = 0
													end
													
												if(exists (select 1 from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta and IB_CC=1 and (ISNULL(IC_IEF,'')='E' or ISNULL(IC_IEN,'')='E')))
													begin
														set @IB_CDxPCC = 1
														set @SumImporteConceptoPorcFicha += ((@Importe*@Porc)/100)
														select 'A1', @Cd_Concepto, case when (@SumImporteConceptoPorcFicha > @Importe) then ((@Importe*@Porc)/100) - (@SumImporteConceptoPorcFicha - @Importe)
																										 when (@j=1) and (@SumImporteConceptoPorcFicha < @Importe) then ((@Importe*@Porc)/100) + ABS(@SumImporteConceptoPorcFicha - @Importe)
																										 else ((@Importe*@Porc)/100) 
																									end, @NroCta, 'Debe'
														if(@P_IB_AGRUPAR_CUENTAS=1 and @Cd_Trabajador IS NULL)
															begin
																if exists (select * from Voucher where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@NroCta and CodT=CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END and
																	Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS --and isnull(Cd_Area, '')=(case when Cd_Area is null then '' else @Cd_Area end)
																	and Glosa=(@Cuenta+CASE WHEN @P_IB_AGRUPAR_CUENTAS=0 THEN @Trabajador ELSE '' END+' - '+convert(varchar, @Porc)+'% ' + case when @IB_GAxCCF=1 then '(F)' else '(TD)' end))
																	begin
																		print 'update '''+@Cd_Concepto+'-'+@NroCta+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, @Importe)
																		update Voucher set MtoD=(MtoD+case when (@SumImporteConceptoPorcFicha > @Importe) then ((@Importe*@Porc)/100) - (@SumImporteConceptoPorcFicha - @Importe)
																										 when (@j=1) and (@SumImporteConceptoPorcFicha < @Importe) then ((@Importe*@Porc)/100) + ABS(@SumImporteConceptoPorcFicha - @Importe)
																										 else ((@Importe*@Porc)/100) 
																									end),
																							MtoD_ME=(MtoD_ME+(case when (@SumImporteConceptoPorcFicha > @Importe) then ((@Importe*@Porc)/100) - (@SumImporteConceptoPorcFicha - @Importe)
																													 when (@j=1) and (@SumImporteConceptoPorcFicha < @Importe) then ((@Importe*@Porc)/100) + ABS(@SumImporteConceptoPorcFicha - @Importe)
																													 else ((@Importe*@Porc)/100) 
																												end/@CamMda))/*, FecMdf=getdate(), UsuModf=@UsuCrea*/
																			where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@NroCta and CodT=CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END and
																				Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS --and isnull(Cd_Area, '')=(case when Cd_Area is null then '' else @Cd_Area end)
																				and Glosa=(@Cuenta+CASE WHEN @P_IB_AGRUPAR_CUENTAS=0 THEN @Trabajador ELSE '' END+' - '+convert(varchar, @Porc)+'% ' + case when @IB_GAxCCF=1 then '(F)' else '(TD)' end)
																		
																	end
																else
																	begin
																		print 'insert '''+@Cd_Concepto+'-'+@NroCta+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,5), case when (@SumImporteConceptoPorcFicha > @Importe) then ((@Importe*@Porc)/100) - (@SumImporteConceptoPorcFicha - @Importe)
																																															 when (@j=1) and (@SumImporteConceptoPorcFicha < @Importe) then ((@Importe*@Porc)/100) + ABS(@SumImporteConceptoPorcFicha - @Importe)
																																															 else ((@Importe*@Porc)/100) 
																																														end))+' (@IB_CDxPCC='+convert(varchar, @IB_CDxPCC)+')'
																		insert into dbo.Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																						MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																						FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,C_ID_CONCEPTO_FEC,CodT)
																		values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte, @FecMov, @FecCbr ,@NroCta,@Cd_TD,@NroSre,@NroDoc,@FecMov/*getdate()*/,(@Cuenta+CASE WHEN @P_IB_AGRUPAR_CUENTAS=0 THEN @Trabajador ELSE '' END+' - '+convert(varchar, @Porc)+'% ' + case when @IB_GAxCCF=1 then '(F)' else '(TD)' end),0.00,
																				case when (@SumImporteConceptoPorcFicha > @Importe) then ((@Importe*@Porc)/100) - (@SumImporteConceptoPorcFicha - @Importe)
																					 when (@j=1) and (@SumImporteConceptoPorcFicha < @Importe) then ((@Importe*@Porc)/100) + ABS(@SumImporteConceptoPorcFicha - @Importe)
																					 else ((@Importe*@Porc)/100) 
																				end,
																				0.00,
																				((case when (@SumImporteConceptoPorcFicha > @Importe) then ((@Importe*@Porc)/100) - (@SumImporteConceptoPorcFicha - @Importe)
																					 when (@j=1) and (@SumImporteConceptoPorcFicha < @Importe) then ((@Importe*@Porc)/100) + ABS(@SumImporteConceptoPorcFicha - @Importe)
																					 else ((@Importe*@Porc)/100) 
																				end)/@CamMda),
																				0.00,'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',@IB_EsProv,
																				getdate(),null,@UsuCrea,null,0,@Cd_Trabajador,CASE WHEN @P_IB_FEC=1 THEN @P_ID_CONCEPTO_FEC ELSE 0 END,CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END)
																	end
															end
														else
															begin
																print 'insert '''+@Cd_Concepto+'-'+@NroCta+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,5), case when (@SumImporteConceptoPorcFicha > @Importe) then ((@Importe*@Porc)/100) - (@SumImporteConceptoPorcFicha - @Importe)
																																															 when (@j=1) and (@SumImporteConceptoPorcFicha < @Importe) then ((@Importe*@Porc)/100) + ABS(@SumImporteConceptoPorcFicha - @Importe)
																																															 else ((@Importe*@Porc)/100) 
																																														end))+' (@IB_CDxPCC='+convert(varchar, @IB_CDxPCC)+')'
																insert into dbo.Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																				MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																				FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,C_ID_CONCEPTO_FEC,CodT)
																values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte, @FecMov, @FecCbr ,@NroCta,@Cd_TD,@NroSre,@NroDoc,@FecMov/*getdate()*/,(@Cuenta+CASE WHEN @P_IB_AGRUPAR_CUENTAS=0 THEN @Trabajador ELSE '' END+' - '+convert(varchar, @Porc)+'% ' + case when @IB_GAxCCF=1 then '(F)' else '(TD)' end),0.00,
																		case when (@SumImporteConceptoPorcFicha > @Importe) then ((@Importe*@Porc)/100) - (@SumImporteConceptoPorcFicha - @Importe)
																			 when (@j=1) and (@SumImporteConceptoPorcFicha < @Importe) then ((@Importe*@Porc)/100) + ABS(@SumImporteConceptoPorcFicha - @Importe)
																			 else ((@Importe*@Porc)/100) 
																		end,
																		0.00,
																		((case when (@SumImporteConceptoPorcFicha > @Importe) then ((@Importe*@Porc)/100) - (@SumImporteConceptoPorcFicha - @Importe)
																			 when (@j=1) and (@SumImporteConceptoPorcFicha < @Importe) then ((@Importe*@Porc)/100) + ABS(@SumImporteConceptoPorcFicha - @Importe)
																			 else ((@Importe*@Porc)/100) 
																		end)/@CamMda),
																		0.00,'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',@IB_EsProv,
																		getdate(),null,@UsuCrea,null,0,@Cd_Trabajador,CASE WHEN @P_IB_FEC=1 THEN @P_ID_CONCEPTO_FEC ELSE 0 END,CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END)
															end
													end
												else
													set @IB_CDxPCC = 0
											end
										else
											set @s += 'No existe el numero de cuenta de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
									end

								begin print '- Asiento Destino ' + case when @IB_GAxCCF=1 then '(F)' else '(TD)' end + ':'
									set @ImporteDestino = convert(numeric(13,5), case when (@SumImporteConceptoPorcFicha > @Importe) then ((@Importe*@Porc)/100) - (@SumImporteConceptoPorcFicha - @Importe)
																					  when (@j=1) and (@SumImporteConceptoPorcFicha < @Importe) then ((@Importe*@Porc)/100) /* + ABS(@SumImporteConceptoPorcFicha - @Importe) */ /* Se retira la suma de la diferencia porque si es el 100% es íntegra */
																					  else ((@Importe*@Porc)/100) 
																				 end)
								
									if(not exists (select * from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS))
										set @s += 'No existe el amarre de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
									else
										begin
											set @NroCta = isnull((select NroCta from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@cd_SS), '')
											SET @L_IB_DESAGRUPAR_DESTINOS = (SELECT ISNULL(C_IB_DESAGRUPAR_DESTINOS, 0) FROM PLANCTAS WHERE RUCE=@RucE AND EJER=@Ejer AND NROCTA=@NroCta)
											SET @IB_AMARRE_CUENTA_DESTINO_CENTRO_COSTO = (SELECT ISNULL(C_IB_CUENTA_DESTINO_CENTRO_COSTO, 0) FROM PLANCTAS WHERE RUCE=@RucE AND EJER=@Ejer AND NROCTA=@NroCta)
											
											if(@NroCta<>'')
												begin
													if(@IB_AMARRE_CUENTA_DESTINO_CENTRO_COSTO=1)
														begin
															if((select top 1 isnull(C_NUMERO_CUENTA_DEBE, '') from CONTABILIDAD.T_AMARRE_CUENTA_CENTRO_COSTO_DESTINOS where C_RUC_EMPRESA  = @RucE and C_EJERCICIO  = @Ejer and CONCAT(C_CODIGO_CENTRO_COSTO,C_CODIGO_SUB_CENTRO_COSTO,C_CODIGO_SUB_SUB_CENTRO_COSTO)=@Cd_CC+@Cd_SC+@cd_SS)!='')
																begin
																	set @k = (select COUNT(*) from CONTABILIDAD.T_AMARRE_CUENTA_CENTRO_COSTO_DESTINOS where C_RUC_EMPRESA  = @RucE and C_EJERCICIO  = @Ejer and CONCAT(C_CODIGO_CENTRO_COSTO,C_CODIGO_SUB_CENTRO_COSTO,C_CODIGO_SUB_SUB_CENTRO_COSTO)=@Cd_CC+@Cd_SC+@cd_SS)
																	set @k_total = @k

																	(select @CtaDs+=C_NUMERO_CUENTA_DEBE+',', @CtaHs+=C_NUMERO_CUENTA_HASTA+',', @PorcDs+=convert(varchar, C_PORCENTAJE)+',' from CONTABILIDAD.T_AMARRE_CUENTA_CENTRO_COSTO_DESTINOS where C_RUC_EMPRESA  = @RucE and C_EJERCICIO  = @Ejer and CONCAT(C_CODIGO_CENTRO_COSTO,C_CODIGO_SUB_CENTRO_COSTO,C_CODIGO_SUB_SUB_CENTRO_COSTO)=@Cd_CC+@Cd_SC+@cd_SS)
												
																	while(@k>0)
																		begin
																			set @CtaD = substring(@CtaDs, 1, (charindex(',', @CtaDs)-1))
																			set @CtaH = substring(@CtaHs, 1, (charindex(',', @CtaHs)-1))
																			set @PorcD = substring(@PorcDs, 1, (charindex(',', @PorcDs)-1))

																			begin /*Cuenta de Destino (Debe)*/
																				set @Cuenta = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@CtaD), '')
																				select 'A2a',@Cd_Concepto, CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END,@NroCta,'Destino Debe'
																				IF(@L_IB_DESAGRUPAR_DESTINOS=0) /* AGRUPAR DESTINOS:EL DEBE VA TODO EN UNA LINEA */
																					BEGIN
																					
																						IF(EXISTS (SELECT * FROM Voucher WHERE RucE=@RucE AND Ejer=@Ejer AND Prdo=@Prdo AND RegCtb=@RegCtb AND NroCta=@CtaD AND CodT=CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END))
																							BEGIN
																								PRINT 'update '''+@CtaD+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+CONVERT(VARCHAR, CONVERT(NUMERIC(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END)))+' (Debe-Agrupado)'
																								UPDATE Voucher SET MtoD=(MtoD+(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END)),
																								MtoD_ME=(MtoD_ME+(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino/@CamMda-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100/@CamMda) ELSE @ImporteDestino*@PorcD/100/@CamMda END))/*, FecMdf=GETDATE(), UsuModf=@UsuCrea*/
																								WHERE RucE=@RucE AND Ejer=@Ejer AND Prdo=@Prdo AND RegCtb=@RegCtb AND NroCta=@CtaD and CodT=CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END
																							END
																						ELSE
																							BEGIN
																								PRINT 'insert '''+@CtaD+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+CONVERT(VARCHAR, CONVERT(NUMERIC(13,5), ((@ImporteDestino*@PorcD)/100)))+' (Debe-Agrupado)'
																								INSERT INTO Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																													MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																													FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,IB_EsDes, CodT)
																								VALUES(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte, @FecMov, @FecCbr ,@CtaD,NULL,NULL,NULL,@FecMov/*getdate()*/,@Cuenta+' (Destino)',0.00,
																										(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END),0.00,(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino/@CamMda-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100/@CamMda) ELSE @ImporteDestino*@PorcD/100/@CamMda END),0.00,'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',0,
																										GETDATE(),NULL,@UsuCrea,NULL,0,NULL,1,CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END)
																							END
																					END
																				ELSE /* DESAGRUPAR DESTINOS: EL DEBE SE GENERA POR CADA LINEA */
																					BEGIN
																						PRINT 'insert '''+@CtaD+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+CONVERT(VARCHAR, CONVERT(NUMERIC(13,5), ((@ImporteDestino*@PorcD)/100)))+' (Debe-Desagrupado)'
																						INSERT INTO Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																											MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																											FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,IB_EsDes,CodT)
																						VALUES(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte, @FecMov, @FecCbr ,@CtaD,NULL,NULL,NULL,@FecMov/*getdate()*/,@Cuenta+' (Destino)',0.00,
																								(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END),0.00,(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino/@CamMda-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100/@CamMda) ELSE @ImporteDestino*@PorcD/100/@CamMda END),0.00,'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',0,
																								GETDATE(),NULL,@UsuCrea,NULL,0,NULL,1,CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END)
																					END
																			end
																			begin /*Cuenta de Destino (Haber)*/
																				set @Cuenta = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@CtaH), '')
																				select 'A2b', @Cd_Concepto, CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END, @CtaH, 'Haber'
																				if(exists (select * from Voucher where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@CtaH and CodT= CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END))
																					begin
																						print 'update '''+@CtaH+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END)))+' (Haber)' + ' ' + @Cuenta
																						update Voucher set MtoH=(MtoH+(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END)),
																						MtoH_ME=(MtoH_ME+(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino/@CamMda-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100/@CamMda) ELSE @ImporteDestino*@PorcD/100/@CamMda END))/*, FecMdf=getdate(), UsuModf=@UsuCrea*/
																						where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@CtaH and CodT=CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END
																					end
																				else
																					begin
																						print 'insert '''+@CtaH+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END)))+' (Haber)' + ' ' + @Cuenta
																						insert into Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																											MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																											FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,IB_EsDes, CodT)
																						values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte, @FecMov, @FecCbr ,@CtaH,null,null,null,@FecMov/*getdate()*/,@Cuenta+' (Destino)',0.00,
																								0.00,(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END),0.00,(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino/@CamMda-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100/@CamMda) ELSE @ImporteDestino*@PorcD/100/@CamMda END),'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',0,
																								getdate(),null,@UsuCrea,null,0,null,1, CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END)
																					end
																			end

																			set @CtaDs = substring(@CtaDs, (charindex(',',@CtaDs)+1), len(@CtaDs))
																			set @CtaHs = substring(@CtaHs, (charindex(',',@CtaHs)+1), len(@CtaHs))
																			set @PorcDs = substring(@PorcDs, (charindex(',',@PorcDs)+1), len(@PorcDs))
																			set @k = (@k-1)
																		end
																end
															else
																print 'El número de cuenta de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'| no tiene cuentas de destino'+char(13)+char(10)
														end
													else
														begin
															if((select isnull(IB_CtaD, 0) from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta)=1)
																begin											
																	set @k = (select count(*) from AmarreCta where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta)
																	set @k_total = @k

																	(select @CtaDs+=CtaD+',', @CtaHs+=CtaH+',', @PorcDs+=convert(varchar, Porc)+',' from AmarreCta where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta)
										
																	while(@k>0)
																		begin
																			set @CtaD = substring(@CtaDs, 1, (charindex(',', @CtaDs)-1))
																			set @CtaH = substring(@CtaHs, 1, (charindex(',', @CtaHs)-1))
																			set @PorcD = substring(@PorcDs, 1, (charindex(',', @PorcDs)-1))

																			begin /*Cuenta de Destino (Debe)*/
																				set @Cuenta = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@CtaD), '')
																				select 'A2c', @Cd_Concepto, CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END, @CtaD, 'Debe'
																				IF(@L_IB_DESAGRUPAR_DESTINOS=0) /* AGRUPAR DESTINOS:EL DEBE VA TODO EN UNA LINEA */
																					BEGIN
																					
																						IF(EXISTS (SELECT * FROM Voucher WHERE RucE=@RucE AND Ejer=@Ejer AND Prdo=@Prdo AND RegCtb=@RegCtb AND NroCta=@CtaD and CodT=CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END))
																							BEGIN
																								PRINT 'update '''+@CtaD+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+CONVERT(VARCHAR, CONVERT(NUMERIC(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END)))+' (Debe-Agrupado)'
																								UPDATE Voucher SET MtoD=(MtoD+(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END)),
																									MtoD_ME=(MtoD_ME+(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino/@CamMda-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100/@CamMda) ELSE @ImporteDestino*@PorcD/100/@CamMda END))/*, FecMdf=GETDATE(), UsuModf=@UsuCrea*/
																								WHERE RucE=@RucE AND Ejer=@Ejer AND Prdo=@Prdo AND RegCtb=@RegCtb AND NroCta=@CtaD and CodT=CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END
																							END
																						ELSE
																							BEGIN
																								PRINT 'insert '''+@CtaD+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+CONVERT(VARCHAR, CONVERT(NUMERIC(13,5), ((@ImporteDestino*@PorcD)/100)))+' (Debe-Agrupado)'
																								INSERT INTO Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																													MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																													FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,IB_EsDes,CodT)
																								VALUES(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte, @FecMov, @FecCbr ,@CtaD,NULL,NULL,NULL,@FecMov/*getdate()*/,@Cuenta+' (Destino)',0.00,
																										(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END),0.00,(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino/@CamMda-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100/@CamMda) ELSE @ImporteDestino*@PorcD/100/@CamMda END),0.00,'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',0,
																										GETDATE(),NULL,@UsuCrea,NULL,0,NULL,1,CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END)
																							END
																					END
																				ELSE /* DESAGRUPAR DESTINOS: EL DEBE SE GENERA POR CADA LINEA */
																					BEGIN
																						PRINT 'insert '''+@CtaD+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+CONVERT(VARCHAR, CONVERT(NUMERIC(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END)))+' (Debe-Desagrupado)'
																						INSERT INTO Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																											MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																											FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,IB_EsDes,CodT)
																						VALUES(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte, @FecMov, @FecCbr ,@CtaD,NULL,NULL,NULL,@FecMov/*getdate()*/,@Cuenta+' (Destino)',0.00,
																								(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END),0.00,(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino/@CamMda-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100/@CamMda) ELSE @ImporteDestino*@PorcD/100/@CamMda END),0.00,'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',0,
																								GETDATE(),NULL,@UsuCrea,NULL,0,NULL,1,CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END)
																					END
																			end
																			begin /*Cuenta de Destino (Haber)*/
																				set @Cuenta = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@CtaH), '')
																				select 'A2d', @Cd_Concepto, CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END, @CtaH, 'Destino Haber'
																				if(exists (select * from Voucher where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@CtaH and Glosa=@Cuenta+' (Destino)' and CodT=CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END))
																					begin
																						print 'update '''+@CtaH+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END)))+' (Haber)' + ' ' + @Cuenta
																						update Voucher set MtoH=(MtoH+(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END)),
																						MtoH_ME=(MtoH_ME+(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino/@CamMda-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100/@CamMda) ELSE @ImporteDestino*@PorcD/100/@CamMda END))/*, FecMdf=getdate(), UsuModf=@UsuCrea*/
																						where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@CtaH and Glosa=@Cuenta+' (Destino)' and CodT=CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END
																					end
																				else
																					begin
																						print 'insert '''+@CtaH+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,5), ((@ImporteDestino*@PorcD)/100)))+' (Haber)' + ' ' + @Cuenta
																						insert into Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																											MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																											FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,IB_EsDes,CodT)
																						values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte, @FecMov, @FecCbr ,@CtaH,null,null,null,@FecMov/*getdate()*/,@Cuenta+' (Destino)',0.00,
																								0.00,(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END),0.00,(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino/@CamMda-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100/@CamMda) ELSE @ImporteDestino*@PorcD/100/@CamMda END),'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',0,
																								getdate(),null,@UsuCrea,null,0,null,1,CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END)
																					end
																			end

																			set @CtaDs = substring(@CtaDs, (charindex(',',@CtaDs)+1), len(@CtaDs))
																			set @CtaHs = substring(@CtaHs, (charindex(',',@CtaHs)+1), len(@CtaHs))
																			set @PorcDs = substring(@PorcDs, (charindex(',',@PorcDs)+1), len(@PorcDs))
																			set @k = (@k-1)
																		end
																end
															else
																print 'El número de cuenta de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'| no tiene cuentas de destino'+char(13)+char(10)
														end
												end
											else
												set @s += 'No existe el numero de cuenta de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
										end

									print @s+char(13)+char(10)
									set @msj += @s
									set @s = ''
								end

								set @Cd_CCs = substring(@Cd_CCs, (charindex(',',@Cd_CCs)+1), len(@Cd_CCs))
								set @Cd_SCs = substring(@Cd_SCs, (charindex(',',@Cd_SCs)+1), len(@Cd_SCs))
								set @Cd_SSs = substring(@Cd_SSs, (charindex(',',@Cd_SSs)+1), len(@Cd_SSs))
								set @Porcs = substring(@Porcs, (charindex(',',@Porcs)+1), len(@Porcs))
								set @j = (@j-1)
							end
						if(@IB_CDxPCC=0)
							begin /*Desgloce por Centro de Costo Principal*/
								set @Cd_CC = (select Cd_CC from @TrabajadorXPorcCC where Cd_Trab=@Cd_Trab and IB_CCPrincipal=1)
								set @Cd_SC = (select Cd_SC from @TrabajadorXPorcCC where Cd_Trab=@Cd_Trab and IB_CCPrincipal=1)
								set @Cd_SS = (select Cd_SS from @TrabajadorXPorcCC where Cd_Trab=@Cd_Trab and IB_CCPrincipal=1)

								if(not exists (select * from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS))
									begin
										set @s = ''
										set @s += 'No existe el amarre de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
									end
								else
									begin
										set @NroCta = isnull((select NroCta from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS), '')
										set @Cuenta = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta), '')
										set @P_IB_FEC = ISNULL((select CASE WHEN @P_IB_HABILITAR_CONCEPTOS_FLUJO_EFECTIVO_CONTABLE=1 THEN CASE WHEN ISNULL(IB_CtasXCbr,0)=1 or ISNULL(IB_CtasXPag,0)=1 THEN 1 ELSE 0 END ELSE 0 END from PlanCtas where RucE=@RucE and NroCta=@NroCta and Ejer=@Ejer),0)
									
										if(@NroCta<>'')
											begin
												if((select isnull(C_IB_AUXILIAR_TRABAJADOR, 0) from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta)=1)
													begin
														set @Cd_Trabajador = @Cd_Trab
													end
												else
													begin
														set @Cd_Trabajador = null
													end
												if(ISNULL((select isnull(IB_NDoc, 0) from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta),0) = 1)
													begin
														set @Cd_TD = (select Cd_TD_AsientosPlanillon from CfgPlanilla where RucE=@RucE)
														select @NroSre=NroSre from dbo.fn_NroDocTrabajador(@RucE,@Cd_TD,@Cd_Trab)
														SET @NroDoc = @Ejer + @Prdo + SUBSTRING(@Cd_Trab,2,7)
														SET @IB_EsProv = 1
													end
												else
													begin
														set @Cd_TD = null
														SET @NroSre=null
														SET @NroDoc = null
														SET @IB_EsProv = 0
													end
													select 'A3', @Cd_Concepto, @Importe, @NroCta, 'Debe'
												if(@P_IB_AGRUPAR_CUENTAS=1 and @Cd_Trabajador IS NULL)
													begin
													
														if exists (select * from Voucher where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@NroCta and CodT=CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END and
																	Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS --and isnull(Cd_Area, '')=(case when Cd_Area is null then '' else @Cd_Area end)
																	)
															begin
																print 'update '''+@Cd_Concepto+'-'+@NroCta+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, @Importe)
																update Voucher set MtoD=(MtoD+@Importe), MtoD_ME=(MtoD_ME+(@Importe/@CamMda))/*, FecMdf=getdate(), UsuModf=@UsuCrea*/
																	where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@NroCta and CodT=CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END and
																		Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS --and isnull(Cd_Area, '')=(case when Cd_Area is null then '' else @Cd_Area end)
															end
														else
															begin
																print 'insert '''+@Cd_Concepto+'-'+@NroCta+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, @Importe)
																insert into Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																					MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																					FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,C_ID_CONCEPTO_FEC,CodT)
																values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte,@FecMov, @FecCbr ,@NroCta,@Cd_TD,@NroSre,@NroDoc,@FecMov/*getdate()*/,(@Cuenta+ case when @IB_GAxCCF=1 then ' (F)' else ' (TD)' end),0.00,
																		@Importe,0.00,(@Importe/@CamMda),0.00,'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',@IB_EsProv,
																		getdate(),null,@UsuCrea,null,0,@Cd_Trabajador,CASE WHEN @P_IB_FEC=1 THEN @P_ID_CONCEPTO_FEC ELSE 0 END,CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END)
															end
													end
												else
													begin
														print 'insert '''+@Cd_Concepto+'-'+@NroCta+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'| '+convert(varchar, @Importe)+' (@IB_CDxPCC='+convert(varchar, @IB_CDxPCC)+')'
														insert into Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																			MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																			FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,C_ID_CONCEPTO_FEC,CodT)
														values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte, @FecMov, @FecCbr ,@NroCta,@Cd_TD,@NroSre,@NroDoc,@FecMov/*getdate()*/,(@Cuenta+CASE WHEN @P_IB_AGRUPAR_CUENTAS=0 THEN @Trabajador ELSE '' END + case when @IB_GAxCCF=1 then ' (F)' else ' (TD)' end),0.00,
																@Importe,0.00,(@Importe/@CamMda),0.00,'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',@IB_EsProv,
																getdate(),null,@UsuCrea,null,0,@Cd_Trabajador,CASE WHEN @P_IB_FEC=1 THEN @P_ID_CONCEPTO_FEC ELSE 0 END,CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END)
													end
											end
										else
											set @s += 'No existe el numero de cuenta de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
									end
							end

						print @s+char(13)+char(10)
						set @msj += @s
						set @s = ''
					end
					begin print '- Asiento Haber ' + case when @IB_GAxCCF=1 then '(F)' else '(TD)' end + ':'
						set @Cd_CC = (select Cd_CC from @TrabajadorXPorcCC where Cd_Trab=@Cd_Trab and IB_CCPrincipal=1)
						set @Cd_SC = (select Cd_SC from @TrabajadorXPorcCC where Cd_Trab=@Cd_Trab and IB_CCPrincipal=1)
						set @Cd_SS = (select Cd_SS from @TrabajadorXPorcCC where Cd_Trab=@Cd_Trab and IB_CCPrincipal=1)
					
						if(not exists (select * from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS))
							set @s += 'No existe el amarre de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
						else
							begin
								set @NroCta = isnull((select (case when @Sem='' then Contrapartida else Contrapartida_Obr end) from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS), '')
								set @Cuenta = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta), '')
								set @P_IB_FEC = ISNULL((select CASE WHEN @P_IB_HABILITAR_CONCEPTOS_FLUJO_EFECTIVO_CONTABLE=1 THEN CASE WHEN ISNULL(IB_CtasXCbr,0)=1 or ISNULL(IB_CtasXPag,0)=1 THEN 1 ELSE 0 END ELSE 0 END from PlanCtas where RucE=@RucE and NroCta=@NroCta and Ejer=@Ejer),0)

								if(@NroCta<>'')
									begin /*Sumar Monto al Número de Cuenta de Haber*/
										if((select isnull(C_IB_AUXILIAR_TRABAJADOR, 0) from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta)=1)
											begin
												set @Cd_Trabajador = @Cd_Trab
											end
										else
											begin
												set @Cd_Trabajador = null
											end
										if(ISNULL((select isnull(IB_NDoc, 0) from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta),0) = 1)
											begin
												set @Cd_TD = (select Cd_TD_AsientosPlanillon from CfgPlanilla where RucE=@RucE)
												select @NroSre=NroSre from dbo.fn_NroDocTrabajador(@RucE,@Cd_TD,@Cd_Trab)
												SET @NroDoc = @Ejer + @Prdo + SUBSTRING(@Cd_Trab,2,7)
												SET @IB_EsProv = 1
											end
										else
											begin
												set @Cd_TD = null
												SET @NroSre=null
												SET @NroDoc = null
												SET @IB_EsProv = 0
											end
										select 'A4', @Cd_Concepto, @Importe, @NroCta, 'Haber'
										if(exists (select * from Voucher where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@NroCta and --CodT=@Cd_Concepto and
													Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS --and isnull(Cd_Area, '')=(case when Cd_Area is null then '' else @Cd_Area end) 
													and Glosa=(@Cuenta+CASE WHEN @P_IB_AGRUPAR_CUENTAS=0 THEN @Trabajador ELSE '' END + case when @IB_GAxCCF=1 then ' (F)' else ' (TD)' end) and isnull(Cd_Trab, '')=(case when @Cd_TD is null then '' else @Cd_Trabajador end)))
											begin
												print 'update '''+@Cd_Concepto+'-'+@NroCta+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, @Importe) + ' ' + @Cuenta
												update Voucher set MtoH=(MtoH+@Importe), MtoH_ME=(MtoH_ME+(@Importe/@CamMda))/*, FecMdf=getdate(), UsuModf=@UsuCrea*/
												where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@NroCta --and CodT=@Cd_Concepto 
												and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS --and isnull(Cd_Area, '')=(case when Cd_Area is null then '' else @Cd_Area end) 
												and Glosa=(@Cuenta+CASE WHEN @P_IB_AGRUPAR_CUENTAS=0 THEN @Trabajador ELSE '' END + case when @IB_GAxCCF=1 then ' (F)' else ' (TD)' end) and isnull(Cd_Trab, '')=(case when @Cd_TD is null then '' else @Cd_Trabajador end)
											end
										else
											begin
												print 'insert '''+@Cd_Concepto+'-'+@NroCta+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, @Importe) + ' ' + @Cuenta
												insert into Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																	MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																	FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,C_ID_CONCEPTO_FEC)--,CodT)
												values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte,@FecMov, @FecCbr ,@NroCta,@Cd_TD,@NroSre,@NroDoc,@FecMov/*getdate()*/,(@Cuenta+CASE WHEN @P_IB_AGRUPAR_CUENTAS=0 THEN @Trabajador ELSE '' END + case when @IB_GAxCCF=1 then ' (F)' else ' (TD)' end),0.00,
														0.00,@Importe,0.00,(@Importe/@CamMda),'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',@IB_EsProv,
														getdate(),null,@UsuCrea,null,0,@Cd_Trabajador,CASE WHEN @P_IB_FEC=1 THEN @P_ID_CONCEPTO_FEC ELSE 0 END)--,@Cd_Concepto)
											end
									end
								else
									set @s += 'No existe la contrapartida de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
							end

						print @s+char(13)+char(10)
						set @msj += @s
						set @s = ''
					end
				
					set @Cd_Conceptos = substring(@Cd_Conceptos, (charindex(',',@Cd_Conceptos)+1), len(@Cd_Conceptos))
					set @Importes = substring(@Importes, (charindex(',',@Importes)+1), len(@Importes))
					set @i = (@i-1)
				end
			print '/****************************/'+char(13)+char(10)+char(13)+char(10)
		end
		if(@IB_AxA=1)
			begin print '/*ASIENTOS DE ACTIVIDADES*/'+char(13)+char(10)+char(13)+char(10)
				set @i = (select count(*) from ActividadXTrab axt
							inner join ActividadDestajo ad on ad.RucE=axt.RucE and ad.Cd_ActDestajo=axt.Cd_ActDestajo
							where axt.RucE=@RucE and axt.Ejer=@Ejer and axt.Prdo=@Prdo and axt.Sem=@Sem and Cd_Trab=@Cd_Trab and axt.CostoTotal<>0)
						
				set @Cd_Conceptos = ''
				set @Importes = ''
				set @Actividades = ''
				set @Cd_CCs = ''
				set @Cd_SCs = ''
				set @Cd_SSs = ''

				(select @Cd_Conceptos+='R11,', @Importes+=convert(varchar, axt.CostoTotal)+',', @Actividades+=ad.Nombre+',', @Cd_CCs+=ad.Cd_CC+',', @Cd_SCs+=ad.Cd_SC+',', @Cd_SSs+=ad.Cd_SS+',' from ActividadXTrab axt
					inner join ActividadDestajo ad on ad.RucE=axt.RucE and ad.Cd_ActDestajo=axt.Cd_ActDestajo
					where axt.RucE=@RucE and axt.Ejer=@Ejer and axt.Prdo=@Prdo and axt.Sem=@Sem and Cd_Trab=@Cd_Trab and axt.CostoTotal<>0)
					
				while(@i>0)
					begin
						set @Cd_Concepto = substring(@Cd_Conceptos, 1, (charindex(',', @Cd_Conceptos)-1))
						set @Importe = substring(@Importes, 1, (charindex(',', @Importes)-1))
						set @Actividad = substring(@Actividades, 1, (charindex(',', @Actividades)-1))
						set @Cd_CC = substring(@Cd_CCs, 1, (charindex(',', @Cd_CCs)-1))
						set @Cd_SC = substring(@Cd_SCs, 1, (charindex(',', @Cd_SCs)-1))
						set @Cd_SS = substring(@Cd_SSs, 1, (charindex(',', @Cd_SSs)-1))
															
						begin print '- Asiento Debe ' + case when @IB_GAxCCF=1 then '(F)' else '(TD)' end + ':'
							if(not exists (select * from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@cd_SS))
								set @s += 'No existe el amarre de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
							else
								begin
									set @NroCta = isnull((select NroCta from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@cd_SS), '')
									set @Cuenta = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta), '')
									set @P_IB_FEC = ISNULL((select CASE WHEN @P_IB_HABILITAR_CONCEPTOS_FLUJO_EFECTIVO_CONTABLE=1 THEN CASE WHEN ISNULL(IB_CtasXCbr,0)=1 or ISNULL(IB_CtasXPag,0)=1 THEN 1 ELSE 0 END ELSE 0 END from PlanCtas where RucE=@RucE and NroCta=@NroCta and Ejer=@Ejer),0)
											
									if(@NroCta<>'')
										begin
											if((select isnull(C_IB_AUXILIAR_TRABAJADOR, 0) from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta)=1)
												begin
													set @Cd_Trabajador = @Cd_Trab
												end
											else
												begin
													set @Cd_Trabajador = null
												end
											if(ISNULL((select isnull(IB_NDoc, 0) from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta),0) = 1)
													begin
													set @Cd_TD = (select Cd_TD_AsientosPlanillon from CfgPlanilla where RucE=@RucE)
													select @NroSre=NroSre from dbo.fn_NroDocTrabajador(@RucE,@Cd_TD,@Cd_Trab)
													SET @NroDoc = @Ejer + @Prdo + SUBSTRING(@Cd_Trab,2,7)
													SET @IB_EsProv = 1
												end
											else
												begin
													set @Cd_TD = null
													SET @NroSre=null
													SET @NroDoc = null
													SET @IB_EsProv = 0
												end

											print 'insert '''+@Cd_Concepto+'-'+@NroCta+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,5), @Importe))
											insert into Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,C_ID_CONCEPTO_FEC)
											values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte,  @FecMov, @FecCbr ,@NroCta,@Cd_TD,@NroSre,@NroDoc,@FecMov/*getdate()*/,(@Cuenta+CASE WHEN @P_IB_AGRUPAR_CUENTAS=0 THEN @Trabajador ELSE '' END+' ('+@Actividad+')'),0.00,
													@Importe,0.00,(@Importe/@CamMda),0.00,'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',@IB_EsProv,
													getdate(),null,@UsuCrea,null,0,@Cd_Trabajador,CASE WHEN @P_IB_FEC=1 THEN @P_ID_CONCEPTO_FEC ELSE 0 END)
										end
									else
										set @s += 'No existe el numero de cuenta de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
								end

							print @s+char(13)+char(10)
							set @msj += @s
							set @s = ''
						end
						begin print '- Asiento Haber ' + case when @IB_GAxCCF=1 then '(F)' else '(TD)' end + ':'
							set @Cd_CC = (select Cd_CC from @TrabajadorXPorcCC where Cd_Trab=@Cd_Trab and IB_CCPrincipal=1)
							set @Cd_SC = (select Cd_SC from @TrabajadorXPorcCC where Cd_Trab=@Cd_Trab and IB_CCPrincipal=1)
							set @Cd_SS = (select Cd_SS from @TrabajadorXPorcCC where Cd_Trab=@Cd_Trab and IB_CCPrincipal=1)
								
							if(not exists (select * from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS))
								set @s += 'No existe el amarre de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
							else
								begin
									set @NroCta = isnull((select (case when @Sem='' then Contrapartida else Contrapartida_Obr end) from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS), '')
									set @Cuenta = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta), '')
									set @P_IB_FEC = ISNULL((select CASE WHEN @P_IB_HABILITAR_CONCEPTOS_FLUJO_EFECTIVO_CONTABLE=1 THEN CASE WHEN ISNULL(IB_CtasXCbr,0)=1 or ISNULL(IB_CtasXPag,0)=1 THEN 1 ELSE 0 END ELSE 0 END from PlanCtas where RucE=@RucE and NroCta=@NroCta and Ejer=@Ejer),0)

									if(@NroCta<>'')
										begin /*Sumar Monto al Número de Cuenta de Haber*/
											if((select isnull(C_IB_AUXILIAR_TRABAJADOR, 0) from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta)=1)
												begin
													set @Cd_Trabajador = @Cd_Trab
												end
											else
												begin
													set @Cd_Trabajador = null
												end
											if(ISNULL((select isnull(IB_NDoc, 0) from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta),0) = 1)
												begin
													set @Cd_TD = (select Cd_TD_AsientosPlanillon from CfgPlanilla where RucE=@RucE)
													select @NroSre=NroSre from dbo.fn_NroDocTrabajador(@RucE,@Cd_TD,@Cd_Trab)
													SET @NroDoc = @Ejer + @Prdo + SUBSTRING(@Cd_Trab,2,7)
													SET @IB_EsProv = 1
												end
											else
												begin
													set @Cd_TD = null
													SET @NroSre=null
													SET @NroDoc = null
													SET @IB_EsProv = 0
												end

											if(exists (select * from Voucher where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@NroCta and
														Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS --and isnull(Cd_Area, '')=(case when Cd_Area is null then '' else @Cd_Area end) 
														and Glosa=(@Cuenta+CASE WHEN @P_IB_AGRUPAR_CUENTAS=0 THEN @Trabajador ELSE '' END + case when @IB_GAxCCF=1 then ' (F)' else ' (TD)' end) and isnull(Cd_Trab, '')=(case when @Cd_TD is null then '' else @Cd_Trabajador end)))
												begin
													print 'update '''+@Cd_Concepto+'-'+@NroCta+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, @Importe)
													update Voucher set MtoH=(MtoH+@Importe), MtoH_ME=(MtoH_ME+(@Importe/@CamMda))/*, FecMdf=getdate(), UsuModf=@UsuCrea*/
													where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@NroCta and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS --and isnull(Cd_Area, '')=(case when Cd_Area is null then '' else @Cd_Area end) 
													and Glosa=(@Cuenta+CASE WHEN @P_IB_AGRUPAR_CUENTAS=0 THEN @Trabajador ELSE '' END + case when @IB_GAxCCF=1 then ' (F)' else ' (TD)' end) and isnull(Cd_Trab, '')=(case when @Cd_TD is null then '' else @Cd_Trabajador end)
												end
											else
												begin
													print 'insert '''+@Cd_Concepto+'-'+@NroCta+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, @Importe)
													insert into Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																		MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																		FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,C_ID_CONCEPTO_FEC)
													values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte, @FecMov, @FecCbr ,@NroCta,@Cd_TD,@NroSre,@NroDoc,@FecMov/*getdate()*/,(@Cuenta+CASE WHEN @P_IB_AGRUPAR_CUENTAS=0 THEN @Trabajador ELSE '' END + case when @IB_GAxCCF=1 then ' (F)' else ' (TD)' end),0.00,
															0.00,@Importe,0.00,(@Importe/@CamMda),'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',@IB_EsProv,
															getdate(),null,@UsuCrea,null,0,@Cd_Trabajador,CASE WHEN @P_IB_FEC=1 THEN @P_ID_CONCEPTO_FEC ELSE 0 END)
												end
										end
									else
										set @s += 'No existe la contrapartida de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
								end

							print @s+char(13)+char(10)
							set @msj += @s
							set @s = ''
						end
						begin print '- Asiento Destino ' + case when @IB_GAxCCF=1 then '(F)' else '(TD)' end + ':'
							set @Cd_CC = (select Cd_CC from @TrabajadorXPorcCC where Cd_Trab=@Cd_Trab and IB_CCPrincipal=1)
							set @Cd_SC = (select Cd_SC from @TrabajadorXPorcCC where Cd_Trab=@Cd_Trab and IB_CCPrincipal=1)
							set @Cd_SS = (select Cd_SS from @TrabajadorXPorcCC where Cd_Trab=@Cd_Trab and IB_CCPrincipal=1)

							if(not exists (select * from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS))
								set @s += 'No existe el amarre de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
							else
								begin
									set @NroCta = isnull((select NroCta from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@cd_SS), '')
									SET @L_IB_DESAGRUPAR_DESTINOS = (SELECT ISNULL(C_IB_DESAGRUPAR_DESTINOS, 0) FROM PLANCTAS WHERE RUCE=@RucE AND EJER=@Ejer AND NROCTA=@NroCta)
									SET @IB_AMARRE_CUENTA_DESTINO_CENTRO_COSTO = (SELECT ISNULL(C_IB_CUENTA_DESTINO_CENTRO_COSTO, 0) FROM PLANCTAS WHERE RUCE=@RucE AND EJER=@Ejer AND NROCTA=@NroCta)

									if(@NroCta<>'')
										begin
											if(@IB_AMARRE_CUENTA_DESTINO_CENTRO_COSTO=1)
												begin
													if((select top 1 isnull(C_NUMERO_CUENTA_DEBE, '') from CONTABILIDAD.T_AMARRE_CUENTA_CENTRO_COSTO_DESTINOS where C_RUC_EMPRESA  = @RucE and C_EJERCICIO  = @Ejer and CONCAT(C_CODIGO_CENTRO_COSTO,C_CODIGO_SUB_CENTRO_COSTO,C_CODIGO_SUB_SUB_CENTRO_COSTO)=@Cd_CC+@Cd_SC+@cd_SS)!='')
														begin
															set @k = (select COUNT(*) from CONTABILIDAD.T_AMARRE_CUENTA_CENTRO_COSTO_DESTINOS where C_RUC_EMPRESA  = @RucE and C_EJERCICIO  = @Ejer and CONCAT(C_CODIGO_CENTRO_COSTO,C_CODIGO_SUB_CENTRO_COSTO,C_CODIGO_SUB_SUB_CENTRO_COSTO)=@Cd_CC+@Cd_SC+@cd_SS)
															set @k_total = @k
	
															(select @CtaDs+=C_NUMERO_CUENTA_DEBE+',', @CtaHs+=C_NUMERO_CUENTA_HASTA+',', @PorcDs+=convert(varchar, C_PORCENTAJE)+',' from CONTABILIDAD.T_AMARRE_CUENTA_CENTRO_COSTO_DESTINOS where C_RUC_EMPRESA  = @RucE and C_EJERCICIO  = @Ejer and CONCAT(C_CODIGO_CENTRO_COSTO,C_CODIGO_SUB_CENTRO_COSTO,C_CODIGO_SUB_SUB_CENTRO_COSTO)=@Cd_CC+@Cd_SC+@cd_SS)

															while(@k>0)
																begin
																	set @CtaD = substring(@CtaDs, 1, (charindex(',', @CtaDs)-1))
																	set @CtaH = substring(@CtaHs, 1, (charindex(',', @CtaHs)-1))
																	set @PorcD = substring(@PorcDs, 1, (charindex(',', @PorcDs)-1))

																	begin /*Cuenta de Destino (Debe)*/
																		set @Cuenta = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@CtaD), '')
												
																		IF(@L_IB_DESAGRUPAR_DESTINOS=0) /* AGRUPAR DESTINOS:EL DEBE VA TODO EN UNA LINEA */
																			BEGIN
																				IF(EXISTS (SELECT * FROM Voucher WHERE RucE=@RucE AND Ejer=@Ejer AND Prdo=@Prdo AND RegCtb=@RegCtb AND NroCta=@CtaD))
																					BEGIN
																						PRINT 'update '''+@CtaD+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+CONVERT(VARCHAR, CONVERT(NUMERIC(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END)))+' (Debe-Agrupado)'
																						UPDATE Voucher SET MtoD=(MtoD+(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END)),
																										MtoD_ME=(MtoD_ME+(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino/@CamMda-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100/@CamMda) ELSE @ImporteDestino*@PorcD/100/@CamMda END))/*, FecMdf=GETDATE(), UsuModf=@UsuCrea*/
																						WHERE RucE=@RucE AND Ejer=@Ejer AND Prdo=@Prdo AND RegCtb=@RegCtb and NroCta=@CtaD
																					END
																				ELSE
																					BEGIN
																						PRINT 'insert '''+@CtaD+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+CONVERT(VARCHAR, CONVERT(NUMERIC(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END)))+' (Debe-Agrupado)'
																						INSERT INTO Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																											MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																											FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,IB_EsDes)
																						VALUES(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte, @FecMov, @FecCbr ,@CtaD,NULL,NULL,NULL,@FecMov/*getdate()*/,@Cuenta+' (Destino)',0.00,
																								(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END),0.00,(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino/@CamMda-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100/@CamMda) ELSE @ImporteDestino*@PorcD/100/@CamMda END),0.00,'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',0,
																								GETDATE(),NULL,@UsuCrea,NULL,0,NULL,1)
																					END
																			END
																		ELSE /* DESAGRUPAR DESTINOS: EL DEBE SE GENERA POR CADA LINEA */
																			BEGIN
																				PRINT 'insert '''+@CtaD+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+CONVERT(VARCHAR, CONVERT(NUMERIC(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END)))+' (Debe-Desagrupado)'
																				INSERT INTO Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																									MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																									FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,IB_EsDes)
																				VALUES(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte, @FecMov, @FecCbr ,@CtaD,NULL,NULL,NULL,@FecMov/*getdate()*/,@Cuenta+' (Destino)',0.00,
																						(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END),0.00,(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino/@CamMda-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100/@CamMda) ELSE @ImporteDestino*@PorcD/100/@CamMda END),0.00,'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',0,
																						GETDATE(),NULL,@UsuCrea,NULL,0,NULL,1)
																			END
																	end
																	begin /*Cuenta de Destino (Haber)*/
																		set @Cuenta = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@CtaH), '')

																		if(exists (select * from Voucher where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@CtaH))
																			begin
																				print 'update '''+@CtaH+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END)))+' (Haber)'
																				update Voucher set MtoH=(MtoH+(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END)),
																				MtoH_ME=(MtoH_ME+(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino/@CamMda-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100/@CamMda) ELSE @ImporteDestino*@PorcD/100/@CamMda END))/*, FecMdf=getdate(), UsuModf=@UsuCrea*/
																				where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@CtaH
																			end
																		else
																			begin
																				print 'insert '''+@CtaH+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END)))+' (Haber)'
																				insert into Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																									MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																									FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,IB_EsDes)
																				values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte,  @FecMov, @FecCbr ,@CtaH,null,null,null,@FecMov/*getdate()*/,@Cuenta+' (Destino)',0.00,
																						0.00,(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END),0.00,(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino/@CamMda-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100/@CamMda) ELSE @ImporteDestino*@PorcD/100/@CamMda END),'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',0,
																						getdate(),null,@UsuCrea,null,0,null,1)
																			end
																	end

																	set @CtaDs = substring(@CtaDs, (charindex(',',@CtaDs)+1), len(@CtaDs))
																	set @CtaHs = substring(@CtaHs, (charindex(',',@CtaHs)+1), len(@CtaHs))
																	set @PorcDs = substring(@PorcDs, (charindex(',',@PorcDs)+1), len(@PorcDs))
																	set @k = (@k-1)
																end
														end
													else
														print 'El número de cuenta de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'| no tiene cuentas de destino'+char(13)+char(10)
												end
											else
												begin
													if((select isnull(IB_CtaD, 0) from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta)=1)
														begin											
															set @k = (select count(*) from AmarreCta where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta)
															set @k_total = @k

															(select @CtaDs+=CtaD+',', @CtaHs+=CtaH+',', @PorcDs+=convert(varchar, Porc)+',' from AmarreCta where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta)
										
															while(@k>0)
																begin
																	set @CtaD = substring(@CtaDs, 1, (charindex(',', @CtaDs)-1))
																	set @CtaH = substring(@CtaHs, 1, (charindex(',', @CtaHs)-1))
																	set @PorcD = substring(@PorcDs, 1, (charindex(',', @PorcDs)-1))

																	begin /*Cuenta de Destino (Debe)*/
																		set @Cuenta = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@CtaD), '')
												
																		IF(@L_IB_DESAGRUPAR_DESTINOS=0) /* AGRUPAR DESTINOS:EL DEBE VA TODO EN UNA LINEA */
																			BEGIN
																				IF(EXISTS (SELECT * FROM Voucher WHERE RucE=@RucE AND Ejer=@Ejer AND Prdo=@Prdo AND RegCtb=@RegCtb AND NroCta=@CtaD))
																					BEGIN
																						PRINT 'update '''+@CtaD+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+CONVERT(VARCHAR, CONVERT(NUMERIC(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END)))+' (Debe-Agrupado)'
																						UPDATE Voucher SET MtoD=(MtoD+(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END)),
																						MtoD_ME=(MtoD_ME+(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino/@CamMda-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100/@CamMda) ELSE @ImporteDestino*@PorcD/100/@CamMda END))/*, FecMdf=GETDATE(), UsuModf=@UsuCrea*/
																						WHERE RucE=@RucE AND Ejer=@Ejer AND Prdo=@Prdo AND RegCtb=@RegCtb and NroCta=@CtaD
																					END
																				ELSE
																					BEGIN
																						PRINT 'insert '''+@CtaD+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+CONVERT(VARCHAR, CONVERT(NUMERIC(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END)))+' (Debe-Agrupado)'
																						INSERT INTO Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																											MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																											FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,IB_EsDes)
																						VALUES(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte, @FecMov, @FecCbr ,@CtaD,NULL,NULL,NULL,@FecMov/*getdate()*/,@Cuenta+' (Destino)',0.00,
																								(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END),0.00,(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino/@CamMda-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100/@CamMda) ELSE @ImporteDestino*@PorcD/100/@CamMda END),0.00,'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',0,
																								GETDATE(),NULL,@UsuCrea,NULL,0,NULL,1)
																					END
																			END
																		ELSE /* DESAGRUPAR DESTINOS: EL DEBE SE GENERA POR CADA LINEA */
																			BEGIN
																				PRINT 'insert '''+@CtaD+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+CONVERT(VARCHAR, CONVERT(NUMERIC(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END)))+' (Debe-Desagrupado)'
																				INSERT INTO Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																									MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																									FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,IB_EsDes)
																				VALUES(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte, @FecMov, @FecCbr ,@CtaD,NULL,NULL,NULL,@FecMov/*getdate()*/,@Cuenta+' (Destino)',0.00,
																						(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END),0.00,(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino/@CamMda-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100/@CamMda) ELSE @ImporteDestino*@PorcD/100/@CamMda END),0.00,'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',0,
																						GETDATE(),NULL,@UsuCrea,NULL,0,NULL,1)
																			END
																	end
																	begin /*Cuenta de Destino (Haber)*/
																		set @Cuenta = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@CtaH), '')

																		if(exists (select * from Voucher where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@CtaH))
																			begin
																				print 'update '''+@CtaH+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END)))+' (Haber)'
																				update Voucher set MtoH=(MtoH+(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END)),
																				MtoH_ME=(MtoH_ME+(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino/@CamMda-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100/@CamMda) ELSE @ImporteDestino*@PorcD/100/@CamMda END))/*, FecMdf=getdate(), UsuModf=@UsuCrea*/
																				where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@CtaH
																			end
																		else
																			begin
																				print 'insert '''+@CtaH+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,5), ((@Importe*@PorcD)/100)))+' (Haber)'
																				insert into Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																									MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																									FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,IB_EsDes)
																				values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte,  @FecMov, @FecCbr ,@CtaH,null,null,null,@FecMov/*getdate()*/,@Cuenta+' (Destino)',0.00,
																						0.00,(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END),0.00,(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino/@CamMda-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100/@CamMda) ELSE @ImporteDestino*@PorcD/100/@CamMda END),'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',0,
																						getdate(),null,@UsuCrea,null,0,null,1)
																			end
																	end

																	set @CtaDs = substring(@CtaDs, (charindex(',',@CtaDs)+1), len(@CtaDs))
																	set @CtaHs = substring(@CtaHs, (charindex(',',@CtaHs)+1), len(@CtaHs))
																	set @PorcDs = substring(@PorcDs, (charindex(',',@PorcDs)+1), len(@PorcDs))
																	set @k = (@k-1)
																end
														end
													else
														print 'El número de cuenta de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'| no tiene cuentas de destino'+char(13)+char(10)
												end
										end
									else
										set @s += 'No existe el numero de cuenta de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
								end

							print @s+char(13)+char(10)
							set @msj += @s
							set @s = ''
						end

						set @Cd_Conceptos = substring(@Cd_Conceptos, (charindex(',',@Cd_Conceptos)+1), len(@Cd_Conceptos))
						set @Importes = substring(@Importes, (charindex(',',@Importes)+1), len(@Importes))
						set @Actividades = substring(@Actividades, (charindex(',',@Actividades)+1), len(@Actividades))
						set @Cd_CCs = substring(@Cd_CCs, (charindex(',',@Cd_CCs)+1), len(@Cd_CCs))
						set @Cd_SCs = substring(@Cd_SCs, (charindex(',',@Cd_SCs)+1), len(@Cd_SCs))
						set @Cd_SSs = substring(@Cd_SSs, (charindex(',',@Cd_SSs)+1), len(@Cd_SSs))
						set @i = (@i-1)
					end
				print '/****************************/'+char(13)+char(10)+char(13)+char(10)
			end		
	
		begin print '/*ASIENTOS DE APORTES*/'+char(13)+char(10)+char(13)+char(10)
			set @i = (select count(*) from AporteTrabHist ath
						where ath.RucE=@RucE and ath.Ejer=@Ejer and ath.Prdo=@Prdo and ath.Sem=@Sem and ath.Cd_Trab=@Cd_Trab and ath.Importe<>0)
							
			set @Cd_Conceptos = ''
			set @Importes = ''

			(select @Cd_Conceptos+=ath.Cd_TipAporte+',', @Importes+=convert(varchar, ath.Importe)+',' from AporteTrabHist ath
				where ath.RucE=@RucE and ath.Ejer=@Ejer and ath.Prdo=@Prdo and ath.Sem=@Sem and ath.Cd_Trab=@Cd_Trab and ath.Importe<>0)
					
			while(@i>0)
				begin
					set @Cd_Concepto = substring(@Cd_Conceptos, 1, (charindex(',', @Cd_Conceptos)-1))
					set @Importe = substring(@Importes, 1, (charindex(',', @Importes)-1))
							
					set @j = (select count(*) from @TrabajadorXPorcCC txpc where txpc.Cd_Trab=@Cd_Trab)

					set @Cd_CCs = ''
					set @Cd_SCs = ''
					set @Cd_SSs = ''
					set @Porcs = ''

					select @Cd_CCs+=Cd_CC+',', @Cd_SCs+=Cd_SC+',', @Cd_SSs+=Cd_SS+',', @Porcs+=convert(varchar, Porc)+','
					from @TrabajadorXPorcCC txpc where txpc.Cd_Trab=@Cd_Trab
				
					begin print '- Asiento Debe ' + case when @IB_GAxCCF=1 then '(F)' else '(TD)' end + ':'
						set @SumImporteConceptoPorcFicha = 0.00
						while(@j>0)
							begin /*Desgloce por Porcentajes de Centro de Costos*/
								set @Cd_CC = substring(@Cd_CCs, 1, (charindex(',', @Cd_CCs)-1))
								set @Cd_SC = substring(@Cd_SCs, 1, (charindex(',', @Cd_SCs)-1))
								set @Cd_SS = substring(@Cd_SSs, 1, (charindex(',', @Cd_SSs)-1))
								set @Porc = substring(@Porcs, 1, (charindex(',', @Porcs)-1))
										 
								if(not exists (select * from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@cd_SS))
									set @s += 'No existe el amarre de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
								else
									begin
										set @NroCta = isnull((select NroCta from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@cd_SS), '')
										set @Cuenta = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta), '')
										set @P_IB_FEC = ISNULL((select CASE WHEN @P_IB_HABILITAR_CONCEPTOS_FLUJO_EFECTIVO_CONTABLE=1 THEN CASE WHEN ISNULL(IB_CtasXCbr,0)=1 or ISNULL(IB_CtasXPag,0)=1 THEN 1 ELSE 0 END ELSE 0 END from PlanCtas where RucE=@RucE and NroCta=@NroCta and Ejer=@Ejer),0)
											
										if(@NroCta<>'')
											begin
												if((select isnull(C_IB_AUXILIAR_TRABAJADOR, 0) from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta)=1)
													begin
														set @Cd_Trabajador = @Cd_Trab
													end
												else
													begin
														set @Cd_Trabajador = null
													end
												if(ISNULL((select isnull(IB_NDoc, 0) from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta),0) = 1)
													begin
														set @Cd_TD = (select Cd_TD_AsientosPlanillon from CfgPlanilla where RucE=@RucE)
														select @NroSre=NroSre from dbo.fn_NroDocTrabajador(@RucE,@Cd_TD,@Cd_Trab)
														SET @NroDoc = @Ejer + @Prdo + SUBSTRING(@Cd_Trab,2,7)
														SET @IB_EsProv = 1
													end
												else
													begin
														set @Cd_TD = null
														SET @NroSre=null
														SET @NroDoc = null
														SET @IB_EsProv = 0
													end
											
												if(exists (select * from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta and IB_CC=1 and (ISNULL(IC_IEF,'')='E' or ISNULL(IC_IEN,'')='E')))
													begin
														set @IB_CDxPCC = 1
														set @SumImporteConceptoPorcFicha += ((@Importe*@Porc)/100)
													select 'A5', @Cd_Concepto, case when (@SumImporteConceptoPorcFicha > @Importe) then ((@Importe*@Porc)/100) - (@SumImporteConceptoPorcFicha - @Importe)
																						 when (@j=1) and (@SumImporteConceptoPorcFicha < @Importe) then ((@Importe*@Porc)/100) + ABS(@SumImporteConceptoPorcFicha - @Importe)
																						 else ((@Importe*@Porc)/100)
																					end, @NroCta, 'Debe'
														if(@P_IB_AGRUPAR_CUENTAS=1 and @Cd_Trabajador IS NULL)
															begin
															--CASE WHEN @P_IB_AGRUPAR_CUENTAS=0 THEN @Trabajador ELSE '' END
																if exists (select * from Voucher where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@NroCta and
																		Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS --and isnull(Cd_Area, '')=(case when Cd_Area is null then '' else @Cd_Area end)
																		)
																		begin
																			print 'update '''+@Cd_Concepto+'-'+@NroCta+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, @Importe)
																			update Voucher set MtoD=(MtoD+case when (@SumImporteConceptoPorcFicha > @Importe) then ((@Importe*@Porc)/100) - (@SumImporteConceptoPorcFicha - @Importe)
																												 when (@j=1) and (@SumImporteConceptoPorcFicha < @Importe) then ((@Importe*@Porc)/100) + ABS(@SumImporteConceptoPorcFicha - @Importe)
																												 else ((@Importe*@Porc)/100)
																											end), 
																								MtoD_ME=(MtoD_ME+(case when (@SumImporteConceptoPorcFicha > @Importe) then ((@Importe*@Porc)/100) - (@SumImporteConceptoPorcFicha - @Importe)
																														 when (@j=1) and (@SumImporteConceptoPorcFicha < @Importe) then ((@Importe*@Porc)/100) + ABS(@SumImporteConceptoPorcFicha - @Importe)
																														 else ((@Importe*@Porc)/100)
																													end/@CamMda))/*, FecMdf=getdate(), UsuModf=@UsuCrea*/
																				where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@NroCta and
																					Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS --and isnull(Cd_Area, '')=(case when Cd_Area is null then '' else @Cd_Area end)
																		
																		end
																	else
																		begin
																			print 'insert '''+@Cd_Concepto+'-'+@NroCta+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,5), ((@Importe*@Porc)/100)))+' (@IB_CDxPCC='+convert(varchar, @IB_CDxPCC)+')'
																		
																			insert into Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																								MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																								FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,C_ID_CONCEPTO_FEC)
																			values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte, @FecMov, @FecCbr ,@NroCta,@Cd_TD,@NroSre,@NroDoc,@FecMov/*getdate()*/,(@Cuenta+CASE WHEN @P_IB_AGRUPAR_CUENTAS=0 THEN @Trabajador ELSE '' END+' - '+convert(varchar, @Porc)+'% ' + case when @IB_GAxCCF=1 then '(F)' else '(TD)' end),0.00,
																					case when (@SumImporteConceptoPorcFicha > @Importe) then ((@Importe*@Porc)/100) - (@SumImporteConceptoPorcFicha - @Importe)
																						 when (@j=1) and (@SumImporteConceptoPorcFicha < @Importe) then ((@Importe*@Porc)/100) + ABS(@SumImporteConceptoPorcFicha - @Importe)
																						 else ((@Importe*@Porc)/100)
																					end,
																					0.00,
																					((case when (@SumImporteConceptoPorcFicha > @Importe) then ((@Importe*@Porc)/100) - (@SumImporteConceptoPorcFicha - @Importe)
																						 when (@j=1) and (@SumImporteConceptoPorcFicha < @Importe) then ((@Importe*@Porc)/100) + ABS(@SumImporteConceptoPorcFicha - @Importe)
																						 else ((@Importe*@Porc)/100) 
																					end)/@CamMda),
																					0.00,'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',@IB_EsProv,
																					getdate(),null,@UsuCrea,null,0,@Cd_Trabajador,CASE WHEN @P_IB_FEC=1 THEN @P_ID_CONCEPTO_FEC ELSE 0 END)
																		end
															end
														else
															begin
																print 'insert '''+@Cd_Concepto+'-'+@NroCta+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,5), ((@Importe*@Porc)/100)))+' (@IB_CDxPCC='+convert(varchar, @IB_CDxPCC)+')'
																insert into Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																					MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																					FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,C_ID_CONCEPTO_FEC)
																values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte, @FecMov, @FecCbr ,@NroCta,@Cd_TD,@NroSre,@NroDoc,@FecMov/*getdate()*/,(@Cuenta+CASE WHEN @P_IB_AGRUPAR_CUENTAS=0 THEN @Trabajador ELSE '' END+' - '+convert(varchar, @Porc)+'% ' + case when @IB_GAxCCF=1 then '(F)' else '(TD)' end),0.00,
																		case when (@SumImporteConceptoPorcFicha > @Importe) then ((@Importe*@Porc)/100) - (@SumImporteConceptoPorcFicha - @Importe)
																			 when (@j=1) and (@SumImporteConceptoPorcFicha < @Importe) then ((@Importe*@Porc)/100) + ABS(@SumImporteConceptoPorcFicha - @Importe)
																			 else ((@Importe*@Porc)/100) 
																		end,
																		0.00,
																		((case when (@SumImporteConceptoPorcFicha > @Importe) then ((@Importe*@Porc)/100) - (@SumImporteConceptoPorcFicha - @Importe)
																			 when (@j=1) and (@SumImporteConceptoPorcFicha < @Importe) then ((@Importe*@Porc)/100) + ABS(@SumImporteConceptoPorcFicha - @Importe)
																			 else ((@Importe*@Porc)/100) 
																		end)/@CamMda),
																		0.00,'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',@IB_EsProv,
																		getdate(),null,@UsuCrea,null,0,@Cd_Trabajador,CASE WHEN @P_IB_FEC=1 THEN @P_ID_CONCEPTO_FEC ELSE 0 END)
															end
													end
												else
													set @IB_CDxPCC = 0
											end
										else
											set @s += 'No existe el numero de cuenta de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
									end

								begin print '- Asiento Destino ' + case when @IB_GAxCCF=1 then '(F)' else '(TD)' end + ':'
									set @ImporteDestino = convert(numeric(13,5), case when (@SumImporteConceptoPorcFicha > @Importe) then ((@Importe*@Porc)/100) - (@SumImporteConceptoPorcFicha - @Importe)
																					  when (@j=1) and (@SumImporteConceptoPorcFicha < @Importe) then ((@Importe*@Porc)/100) /* + ABS(@SumImporteConceptoPorcFicha - @Importe) */ /* Se retira la suma de la diferencia porque si es el 100% es íntegra */
																					  else ((@Importe*@Porc)/100) 
																				 end)

									if(not exists (select * from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS))
										set @s += 'No existe el amarre de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
									else
										begin
											set @NroCta = isnull((select NroCta from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@cd_SS), '')
											SET @L_IB_DESAGRUPAR_DESTINOS = (SELECT ISNULL(C_IB_DESAGRUPAR_DESTINOS, 0) FROM PLANCTAS WHERE RUCE=@RucE AND EJER=@Ejer AND NROCTA=@NroCta)
											SET @IB_AMARRE_CUENTA_DESTINO_CENTRO_COSTO = (SELECT ISNULL(C_IB_CUENTA_DESTINO_CENTRO_COSTO, 0) FROM PLANCTAS WHERE RUCE=@RucE AND EJER=@Ejer AND NROCTA=@NroCta)

											if(@NroCta<>'')
												begin

													if(@IB_AMARRE_CUENTA_DESTINO_CENTRO_COSTO=1)
															begin
																if((select TOP 1isnull(C_NUMERO_CUENTA_DEBE, '') from CONTABILIDAD.T_AMARRE_CUENTA_CENTRO_COSTO_DESTINOS where C_RUC_EMPRESA  = @RucE and C_EJERCICIO  = @Ejer and CONCAT(C_CODIGO_CENTRO_COSTO,C_CODIGO_SUB_CENTRO_COSTO,C_CODIGO_SUB_SUB_CENTRO_COSTO)=@Cd_CC+@Cd_SC+@cd_SS)!='')
																	begin
																		set @k = (select COUNT(*) from CONTABILIDAD.T_AMARRE_CUENTA_CENTRO_COSTO_DESTINOS where C_RUC_EMPRESA  = @RucE and C_EJERCICIO  = @Ejer and CONCAT(C_CODIGO_CENTRO_COSTO,C_CODIGO_SUB_CENTRO_COSTO,C_CODIGO_SUB_SUB_CENTRO_COSTO)=@Cd_CC+@Cd_SC+@cd_SS)
																		set @k_total = @k

																		(select @CtaDs+=C_NUMERO_CUENTA_DEBE+',', @CtaHs+=C_NUMERO_CUENTA_HASTA+',', @PorcDs+=convert(varchar, C_PORCENTAJE)+',' from CONTABILIDAD.T_AMARRE_CUENTA_CENTRO_COSTO_DESTINOS where C_RUC_EMPRESA  = @RucE and C_EJERCICIO  = @Ejer and CONCAT(C_CODIGO_CENTRO_COSTO,C_CODIGO_SUB_CENTRO_COSTO,C_CODIGO_SUB_SUB_CENTRO_COSTO)=@Cd_CC+@Cd_SC+@cd_SS)

																		while(@k>0)
																			begin
																				set @CtaD = substring(@CtaDs, 1, (charindex(',', @CtaDs)-1))
																				set @CtaH = substring(@CtaHs, 1, (charindex(',', @CtaHs)-1))
																				set @PorcD = substring(@PorcDs, 1, (charindex(',', @PorcDs)-1))

																				begin /*Cuenta de Destino (Debe)*/
																					set @Cuenta = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@CtaD), '')
																					select 'A6', @Cd_Concepto, CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END, @CtaD, 'Debe Destino'
																					IF(@L_IB_DESAGRUPAR_DESTINOS=0) /* AGRUPAR DESTINOS:EL DEBE VA TODO EN UNA LINEA */
																						BEGIN
																							IF(EXISTS (SELECT * FROM Voucher WHERE RucE=@RucE AND Ejer=@Ejer AND Prdo=@Prdo AND RegCtb=@RegCtb AND NroCta=@CtaD and Glosa=@Cuenta+' (Destino)' and CodT=CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END))
																								BEGIN
																									PRINT 'update '''+@CtaD+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+CONVERT(VARCHAR, CONVERT(NUMERIC(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END)))+' (Debe-Agrupado)'
																									UPDATE Voucher SET MtoD=(MtoD+(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END)),
																									MtoD_ME=(MtoD_ME+(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino/@CamMda-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100/@CamMda) ELSE @ImporteDestino*@PorcD/100/@CamMda END))/*, FecMdf=GETDATE(), UsuModf=@UsuCrea*/
																									WHERE RucE=@RucE AND Ejer=@Ejer AND Prdo=@Prdo AND RegCtb=@RegCtb AND NroCta=@CtaD and Glosa=@Cuenta+' (Destino)' and CodT=CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END
																								END
																							ELSE
																								BEGIN
																									PRINT 'insert '''+@CtaD+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+CONVERT(VARCHAR, CONVERT(NUMERIC(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END)))+' (Debe-Arupado)'
																									INSERT INTO Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																														MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																														FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,IB_EsDes, CodT)
																									values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte, @FecMov, @FecCbr ,@CtaD,NULL,NULL,NULL,@FecMov/*getdate()*/,@Cuenta+' (Destino)',0.00,
																											(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END),0.00,(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino/@CamMda-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100/@CamMda) ELSE @ImporteDestino*@PorcD/100/@CamMda END),0.00,'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',0,
																											GETDATE(),NULL,@UsuCrea,NULL,0,NULL,1,CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END)
																								END
																						END
																					ELSE /* DESAGRUPAR DESTINOS: EL DEBE SE GENERA POR CADA LINEA */
																						BEGIN
																							PRINT 'insert '''+@CtaD+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+CONVERT(VARCHAR, CONVERT(NUMERIC(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END)))+' (Debe-Desagrupado)'
																							INSERT INTO Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																												MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																												FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,IB_EsDes, CodT)
																							values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte, @FecMov, @FecCbr ,@CtaD,NULL,NULL,NULL,@FecMov/*getdate()*/,@Cuenta+' (Destino)',0.00,
																									(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END),0.00,(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino/@CamMda-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100/@CamMda) ELSE @ImporteDestino*@PorcD/100/@CamMda END),0.00,'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',0,
																									GETDATE(),NULL,@UsuCrea,NULL,0,NULL,1,CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END)
																						END
																				end
																				begin /*Cuenta de Destino (Haber)*/
																					set @Cuenta = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@CtaH), '')
																					select 'A7', @Cd_Concepto, CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END, @CtaH, 'Haber Destino'
																					if(exists (select * from Voucher where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@CtaH and CodT=CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END))
																						begin
																							print 'update '''+@CtaH+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END)))+' (Haber)'
																							update Voucher set MtoH=(MtoH+(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END)),
																							MtoH_ME=(MtoH_ME+(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino/@CamMda-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100/@CamMda) ELSE @ImporteDestino*@PorcD/100/@CamMda END))/*, FecMdf=getdate(), UsuModf=@UsuCrea*/
																							where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@CtaH and CodT=CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END
																						end
																					else
																						begin
																							print 'insert '''+@CtaH+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,5), ((@ImporteDestino*@PorcD)/100)))+' (Haber)'
																							insert into Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																												MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																												FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,IB_EsDes,CodT)
																							values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte, @FecMov, @FecCbr ,@CtaH,null,null,null,@FecMov/*getdate()*/,@Cuenta+' (Destino)',0.00,
																									0.00,(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END),0.00,(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino/@CamMda-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100/@CamMda) ELSE @ImporteDestino*@PorcD/100/@CamMda END),'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',0,
																									getdate(),null,@UsuCrea,null,0,null,1,CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END)
																						end
																				end

																				set @CtaDs = substring(@CtaDs, (charindex(',',@CtaDs)+1), len(@CtaDs))
																				set @CtaHs = substring(@CtaHs, (charindex(',',@CtaHs)+1), len(@CtaHs))
																				set @PorcDs = substring(@PorcDs, (charindex(',',@PorcDs)+1), len(@PorcDs))
																				set @k = (@k-1)
																			end
																	end
																else
																	print 'El número de cuenta de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'| no tiene cuentas de destino'+char(13)+char(10)
															end
														else
															begin
																if((select isnull(IB_CtaD, 0) from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta)=1)
																	begin											
																		set @k = (select count(*) from AmarreCta where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta)
																		set @k_total = @k
																		(select @CtaDs+=CtaD+',', @CtaHs+=CtaH+',', @PorcDs+=convert(varchar, Porc)+',' from AmarreCta where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta)
										
																		while(@k>0)
																			begin
																				set @CtaD = substring(@CtaDs, 1, (charindex(',', @CtaDs)-1))
																				set @CtaH = substring(@CtaHs, 1, (charindex(',', @CtaHs)-1))
																				set @PorcD = substring(@PorcDs, 1, (charindex(',', @PorcDs)-1))
																				
																				select 'A8 DESTINO APORTE:', @Cd_Concepto, (CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END), @CtaD, 'Debe'
																				begin /*Cuenta de Destino (Debe)*/
																					set @Cuenta = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@CtaD), '')

																					IF(@L_IB_DESAGRUPAR_DESTINOS=0) /* AGRUPAR DESTINOS:EL DEBE VA TODO EN UNA LINEA */
																						BEGIN
																							IF(EXISTS (SELECT * FROM Voucher WHERE RucE=@RucE AND Ejer=@Ejer AND Prdo=@Prdo AND RegCtb=@RegCtb AND NroCta=@CtaD and CodT=CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END))
																								BEGIN
																									PRINT 'update '''+@CtaD+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+CONVERT(VARCHAR, CONVERT(NUMERIC(13,5), ((@ImporteDestino*@PorcD)/100)))+' (Debe-Agrupado)'
																									UPDATE Voucher SET MtoD=(MtoD+(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END)), MtoD_ME=(MtoD_ME+((CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino/@CamMda-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100/@CamMda) ELSE @ImporteDestino*@PorcD/100/@CamMda END)))/*, FecMdf=GETDATE(), UsuModf=@UsuCrea*/
																									WHERE RucE=@RucE AND Ejer=@Ejer AND Prdo=@Prdo AND RegCtb=@RegCtb AND NroCta=@CtaD and CodT=CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END
																								END
																							ELSE
																								BEGIN
																									PRINT 'insert '''+@CtaD+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+CONVERT(VARCHAR, CONVERT(NUMERIC(13,5), ((@ImporteDestino*@PorcD)/100)))+' (Debe-Arupado)'
																									INSERT INTO Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																														MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																														FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,IB_EsDes,CodT)
																									values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte, @FecMov, @FecCbr ,@CtaD,NULL,NULL,NULL,@FecMov/*getdate()*/,@Cuenta+' (Destino)',0.00,
																											(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END),0.00,((CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino/@CamMda-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100/@CamMda) ELSE @ImporteDestino*@PorcD/100/@CamMda END)),0.00,'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',0,
																											GETDATE(),NULL,@UsuCrea,NULL,0,NULL,1,CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END)
																								END
																						END
																					ELSE /* DESAGRUPAR DESTINOS: EL DEBE SE GENERA POR CADA LINEA */
																						BEGIN
																							PRINT 'insert '''+@CtaD+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+CONVERT(VARCHAR, CONVERT(NUMERIC(13,5), ((@ImporteDestino*@PorcD)/100)))+' (Debe-Desagrupado)'
																							INSERT INTO Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																												MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																												FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,IB_EsDes,CodT)
																							values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte, @FecMov, @FecCbr ,@CtaD,NULL,NULL,NULL,@FecMov/*getdate()*/,@Cuenta+' (Destino)',0.00,
																									(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END),0.00,((CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino/@CamMda-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100/@CamMda) ELSE @ImporteDestino*@PorcD/100/@CamMda END)),0.00,'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',0,
																									GETDATE(),NULL,@UsuCrea,NULL,0,NULL,1,CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END)
																						END
																				end
																				begin /*Cuenta de Destino (Haber)*/
																					set @Cuenta = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@CtaH), '')
																					select 'A9', @Cd_Concepto, CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END, @CtaH, 'Haber'
																					if(exists (select * from Voucher where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@CtaH and Glosa=@Cuenta+' (Destino)' and CodT=CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END))
																						begin
																							print 'update '''+@CtaH+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,5), ((@ImporteDestino*@PorcD)/100)))+' (Haber)'
																							update Voucher set MtoH=(MtoH+(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END)), MtoH_ME=(MtoH_ME+((CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino/@CamMda-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100/@CamMda) ELSE @ImporteDestino*@PorcD/100/@CamMda END)))/*, FecMdf=getdate(), UsuModf=@UsuCrea*/
																							where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@CtaH and Glosa=@Cuenta+' (Destino)' and CodT=CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END
																						end
																					else
																						begin
																							print 'insert '''+@CtaH+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,5), ((@ImporteDestino*@PorcD)/100)))+' (Haber)'
																							insert into Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																												MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																												FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,IB_EsDes,CodT)
																							values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte, @FecMov, @FecCbr ,@CtaH,null,null,null,@FecMov/*getdate()*/,@Cuenta+' (Destino)',0.00,
																									0.00,(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END),0.00,((CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino/@CamMda-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100/@CamMda) ELSE @ImporteDestino*@PorcD/100/@CamMda END)),'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',0,
																									getdate(),null,@UsuCrea,null,0,null,1,CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END)
																						end
																				end

																				set @CtaDs = substring(@CtaDs, (charindex(',',@CtaDs)+1), len(@CtaDs))
																				set @CtaHs = substring(@CtaHs, (charindex(',',@CtaHs)+1), len(@CtaHs))
																				set @PorcDs = substring(@PorcDs, (charindex(',',@PorcDs)+1), len(@PorcDs))
																				set @k = (@k-1)
																			end
																	end
																else
																	print 'El número de cuenta de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'| no tiene cuentas de destino'+char(13)+char(10)
															end
												end
											else
												set @s += 'No existe el numero de cuenta de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
										end

									print @s+char(13)+char(10)
									set @msj += @s
									set @s = ''
								end

								set @Cd_CCs = substring(@Cd_CCs, (charindex(',',@Cd_CCs)+1), len(@Cd_CCs))
								set @Cd_SCs = substring(@Cd_SCs, (charindex(',',@Cd_SCs)+1), len(@Cd_SCs))
								set @Cd_SSs = substring(@Cd_SSs, (charindex(',',@Cd_SSs)+1), len(@Cd_SSs))
								set @Porcs = substring(@Porcs, (charindex(',',@Porcs)+1), len(@Porcs))
								set @j = (@j-1)
							end
						if(@IB_CDxPCC=0)
							begin /*Desgloce por Centro de Costo Principal*/
								set @Cd_CC = (select Cd_CC from @TrabajadorXPorcCC where Cd_Trab=@Cd_Trab and IB_CCPrincipal=1)
								set @Cd_SC = (select Cd_SC from @TrabajadorXPorcCC where Cd_Trab=@Cd_Trab and IB_CCPrincipal=1)
								set @Cd_SS = (select Cd_SS from @TrabajadorXPorcCC where Cd_Trab=@Cd_Trab and IB_CCPrincipal=1)

								if(not exists (select * from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS))
									begin
										set @s = ''
										set @s += 'No existe el amarre de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
									end
								else
									begin
										set @NroCta = isnull((select NroCta from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS), '')
										set @Cuenta = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta), '')
										set @P_IB_FEC = ISNULL((select CASE WHEN @P_IB_HABILITAR_CONCEPTOS_FLUJO_EFECTIVO_CONTABLE=1 THEN CASE WHEN ISNULL(IB_CtasXCbr,0)=1 or ISNULL(IB_CtasXPag,0)=1 THEN 1 ELSE 0 END ELSE 0 END from PlanCtas where RucE=@RucE and NroCta=@NroCta and Ejer=@Ejer),0)
									
										if(@NroCta<>'')
											begin
												if((select isnull(C_IB_AUXILIAR_TRABAJADOR, 0) from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta)=1)
													begin
														set @Cd_Trabajador = @Cd_Trab
													end
												else
													begin
														set @Cd_Trabajador = null
													end
												if(ISNULL((select isnull(IB_NDoc, 0) from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta),0) = 1)
													begin
														set @Cd_TD = (select Cd_TD_AsientosPlanillon from CfgPlanilla where RucE=@RucE)
														select @NroSre=NroSre from dbo.fn_NroDocTrabajador(@RucE,@Cd_TD,@Cd_Trab)
														SET @NroDoc = @Ejer + @Prdo + SUBSTRING(@Cd_Trab,2,7)
														SET @IB_EsProv = 1
													end
												else
													begin
														set @Cd_TD = null
														SET @NroSre=null
														SET @NroDoc = null
														SET @IB_EsProv = 0
													end
													select 'A10', @Cd_Concepto, @Importe, @NroCta, 'Debe'
												if(@P_IB_AGRUPAR_CUENTAS=1 and @Cd_Trabajador IS NULL)
													begin
													if exists (select * from Voucher where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@NroCta and
																		Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS --and isnull(Cd_Area, '')=(case when Cd_Area is null then '' else @Cd_Area end)
																		)
														begin
																print 'update '''+@Cd_Concepto+'-'+@NroCta+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, @Importe)
																update Voucher set MtoD=(MtoD+@Importe), MtoD_ME=(MtoD_ME+(@Importe/@CamMda))/*, FecMdf=getdate(), UsuModf=@UsuCrea*/
																	where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@NroCta and
																		Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS --and isnull(Cd_Area, '')=(case when Cd_Area is null then '' else @Cd_Area end)
														end
													else
														begin
															print 'insert '''+@Cd_Concepto+'-'+@NroCta+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'| '+convert(varchar, @Importe)+' (@IB_CDxPCC='+convert(varchar, @IB_CDxPCC)+')'
															insert into Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																				MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																				FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,C_ID_CONCEPTO_FEC)
															values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte, @FecMov, @FecCbr ,@NroCta,@Cd_TD,@NroSre,@NroDoc,@FecMov/*getdate()*/,(@Cuenta+CASE WHEN @P_IB_AGRUPAR_CUENTAS=0 THEN @Trabajador ELSE '' END + case when @IB_GAxCCF=1 then ' (F)' else ' (TD)' end),0.00,
																	@Importe,0.00,(@Importe/@CamMda),0.00,'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',@IB_EsProv,
																	getdate(),null,@UsuCrea,null,0,@Cd_Trabajador,CASE WHEN @P_IB_FEC=1 THEN @P_ID_CONCEPTO_FEC ELSE 0 END)
														end
													end
												else
													begin
														print 'insert '''+@Cd_Concepto+'-'+@NroCta+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'| '+convert(varchar, @Importe)+' (@IB_CDxPCC='+convert(varchar, @IB_CDxPCC)+')'
														insert into Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																			MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																			FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,C_ID_CONCEPTO_FEC)
														values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte, @FecMov, @FecCbr ,@NroCta,@Cd_TD,@NroSre,@NroDoc,@FecMov/*getdate()*/,(@Cuenta+CASE WHEN @P_IB_AGRUPAR_CUENTAS=0 THEN @Trabajador ELSE '' END + case when @IB_GAxCCF=1 then ' (F)' else ' (TD)' end),0.00,
																@Importe,0.00,(@Importe/@CamMda),0.00,'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',@IB_EsProv,
																getdate(),null,@UsuCrea,null,0,@Cd_Trabajador,CASE WHEN @P_IB_FEC=1 THEN @P_ID_CONCEPTO_FEC ELSE 0 END)
													end
											end
										else
											set @s += 'No existe el numero de cuenta de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
									end
							end

						print @s+char(13)+char(10)
						set @msj += @s
						set @s = ''
					end
					
					--Aignamos nuevamente para la generación de Asientos Haber
					

					set @Cd_CCs = ''
					set @Cd_SCs = ''
					set @Cd_SSs = ''
					set @Porcs = ''

					if (@IB_DesgloceAportexCCFicha=1)
					begin
						set @j = (select count(*) from @TrabajadorXPorcCC txpc where txpc.Cd_Trab=@Cd_Trab)
						select @Cd_CCs+=Cd_CC+',', @Cd_SCs+=Cd_SC+',', @Cd_SSs+=Cd_SS+',', @Porcs+=convert(varchar, Porc)+','
						from @TrabajadorXPorcCC txpc where txpc.Cd_Trab=@Cd_Trab
					end
					else
					begin
						set @j = (select count(*) from @TrabajadorXPorcCC txpc where txpc.Cd_Trab=@Cd_Trab and txpc.IB_CCPrincipal=1)
						select @Cd_CCs=Cd_CC+',', @Cd_SCs=Cd_SC+',', @Cd_SSs=Cd_SS+',',@Porcs='100'+','
						from @TrabajadorXPorcCC txpc where txpc.Cd_Trab=@Cd_Trab and txpc.IB_CCPrincipal=1
					end

					begin print '- Asiento Haber ' + case when @IB_GAxCCF=1 then '(F)' else '(TD)' end + ':'
						set @SumImporteConceptoPorcFicha = 0.00
						while(@j>0)
							begin /*Desgloce por Porcentajes de Centro de Costos*/
								set @Cd_CC = substring(@Cd_CCs, 1, (charindex(',', @Cd_CCs)-1))
								set @Cd_SC = substring(@Cd_SCs, 1, (charindex(',', @Cd_SCs)-1))
								set @Cd_SS = substring(@Cd_SSs, 1, (charindex(',', @Cd_SSs)-1))
								set @Porc = substring(@Porcs, 1, (charindex(',', @Porcs)-1))
								
								if(not exists (select * from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS))
									set @s += 'No existe el amarre de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
								else
									begin
										set @NroCta = isnull((select (case when @Sem='' then Contrapartida else Contrapartida_Obr end) from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS), '')
										set @Cuenta = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta), '')
										set @P_IB_FEC = ISNULL((select CASE WHEN @P_IB_HABILITAR_CONCEPTOS_FLUJO_EFECTIVO_CONTABLE=1 THEN CASE WHEN ISNULL(IB_CtasXCbr,0)=1 or ISNULL(IB_CtasXPag,0)=1 THEN 1 ELSE 0 END ELSE 0 END from PlanCtas where RucE=@RucE and NroCta=@NroCta and Ejer=@Ejer),0)

										if(@NroCta<>'')
											begin /*Sumar Monto al Número de Cuenta de Haber (Desgloce por Trabajador o Centro de Costos Principal)*/
												if(((select isnull(C_IB_AUXILIAR_TRABAJADOR, 0) from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta)=1) and (@IB_DxA=1))
													begin
														set @Cd_Trabajador = @Cd_Trab
													end
												else
													begin
														set @Cd_Trabajador = null
													end
												if(ISNULL((select isnull(IB_NDoc, 0) from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta),0) = 1)
													begin
														set @Cd_TD = (select Cd_TD_AsientosPlanillon from CfgPlanilla where RucE=@RucE)
														select @NroSre=NroSre from dbo.fn_NroDocTrabajador(@RucE,@Cd_TD,@Cd_Trab)
														SET @NroDoc = @Ejer + @Prdo + SUBSTRING(@Cd_Trab,2,7)
														SET @IB_EsProv = 1
													end
												else
													begin
														set @Cd_TD = null
														SET @NroSre=null
														SET @NroDoc = null
														SET @IB_EsProv = 0
													end

												set @SumImporteConceptoPorcFicha += ((@Importe*@Porc)/100)
												select 'A11', @Cd_Concepto, case when (@SumImporteConceptoPorcFicha > @Importe) then ((@Importe*@Porc)/100) - (@SumImporteConceptoPorcFicha - @Importe)
																												 when (@j=1) and (@SumImporteConceptoPorcFicha < @Importe) then ((@Importe*@Porc)/100) + ABS(@SumImporteConceptoPorcFicha - @Importe)
																												 else ((@Importe*@Porc)/100)
																											end, @NroCta, 'Haber'
												if(exists (select * from Voucher where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@NroCta and
															Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS --and isnull(Cd_Area, '')=(case when Cd_Area is null then '' else @Cd_Area end) 
															and Glosa=(case when (@IB_DxA=1) then (@Cuenta+CASE WHEN @P_IB_AGRUPAR_CUENTAS=0 THEN @Trabajador ELSE '' END + case when @IB_GAxCCF=1 then ' (F)' else ' (TD)' end) else (@Cuenta + case when @IB_GAxCCF=1 then ' (F)' else ' (TD)' end) end) and isnull(Cd_Trab, '')=(case when @Cd_TD is null then '' else @Cd_Trabajador end)))
													begin
														print 'update '''+@Cd_Concepto+'-'+@NroCta+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, @Importe)
														update Voucher set MtoH=(MtoH+case when (@SumImporteConceptoPorcFicha > @Importe) then ((@Importe*@Porc)/100) - (@SumImporteConceptoPorcFicha - @Importe)
																												 when (@j=1) and (@SumImporteConceptoPorcFicha < @Importe) then ((@Importe*@Porc)/100) + ABS(@SumImporteConceptoPorcFicha - @Importe)
																												 else ((@Importe*@Porc)/100)
																											end),
																		   MtoH_ME=(MtoH_ME+(case when (@SumImporteConceptoPorcFicha > @Importe) then ((@Importe*@Porc)/100) - (@SumImporteConceptoPorcFicha - @Importe)
																									when (@j=1) and (@SumImporteConceptoPorcFicha < @Importe) then ((@Importe*@Porc)/100) + ABS(@SumImporteConceptoPorcFicha - @Importe)
																									else ((@Importe*@Porc)/100)
																							end/@CamMda))/*, FecMdf=getdate(), UsuModf=@UsuCrea*/
														where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@NroCta and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS --and isnull(Cd_Area, '')=(case when Cd_Area is null then '' else @Cd_Area end)
														and Glosa=(case when (@IB_DxA=1) then (@Cuenta+ CASE WHEN @P_IB_AGRUPAR_CUENTAS=0 THEN @Trabajador ELSE '' END + case when @IB_GAxCCF=1 then ' (F)' else ' (TD)' end) else (@Cuenta + case when @IB_GAxCCF=1 then ' (F)' else ' (TD)' end) end) and isnull(Cd_Trab, '')=(case when @Cd_TD is null then '' else @Cd_Trabajador end)
													end
												else
													begin
														print 'insert '''+@Cd_Concepto+'-'+@NroCta+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, @Importe)
														insert into Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																			MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																			FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,C_ID_CONCEPTO_FEC)
														values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte,@FecMov, @FecCbr ,@NroCta,@Cd_TD,@NroSre,@NroDoc,@FecMov/*getdate()*/,(case when (@IB_DxA=1) then (@Cuenta+CASE WHEN @P_IB_AGRUPAR_CUENTAS=0 THEN @Trabajador ELSE '' END + case when @IB_GAxCCF=1 then ' (F)' else ' (TD)' end) else (@Cuenta + case when @IB_GAxCCF=1 then ' (F)' else ' (TD)' end) end),0.00,
																0.00,
																case when (@SumImporteConceptoPorcFicha > @Importe) then ((@Importe*@Porc)/100) - (@SumImporteConceptoPorcFicha - @Importe)
																		when (@j=1) and (@SumImporteConceptoPorcFicha < @Importe) then ((@Importe*@Porc)/100) + ABS(@SumImporteConceptoPorcFicha - @Importe)
																		else ((@Importe*@Porc)/100)
																end,
																0.00,
																((case when (@SumImporteConceptoPorcFicha > @Importe) then ((@Importe*@Porc)/100) - (@SumImporteConceptoPorcFicha - @Importe)
																		when (@j=1) and (@SumImporteConceptoPorcFicha < @Importe) then ((@Importe*@Porc)/100) + ABS(@SumImporteConceptoPorcFicha - @Importe)
																		else ((@Importe*@Porc)/100) 
																end)/@CamMda),
																'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',@IB_EsProv,
																getdate(),null,@UsuCrea,null,0,@Cd_Trabajador,CASE WHEN @P_IB_FEC=1 THEN @P_ID_CONCEPTO_FEC ELSE 0 END)
													end
											end
										else
											set @s += 'No existe la contrapartida de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
									end

								set @Cd_CCs = substring(@Cd_CCs, (charindex(',',@Cd_CCs)+1), len(@Cd_CCs))
								set @Cd_SCs = substring(@Cd_SCs, (charindex(',',@Cd_SCs)+1), len(@Cd_SCs))
								set @Cd_SSs = substring(@Cd_SSs, (charindex(',',@Cd_SSs)+1), len(@Cd_SSs))
								set @Porcs = substring(@Porcs, (charindex(',',@Porcs)+1), len(@Porcs))
								set @j = (@j-1)
							end

						print @s+char(13)+char(10)
						set @msj += @s
						set @s = ''
					end

					set @Cd_Conceptos = substring(@Cd_Conceptos, (charindex(',',@Cd_Conceptos)+1), len(@Cd_Conceptos))
					set @Importes = substring(@Importes, (charindex(',',@Importes)+1), len(@Importes))
					set @i = (@i-1)
				end
			print '/*********************/'+char(13)+char(10)+char(13)+char(10)
		end
	
		begin print '/*ASIENTOS DE DESCUENTOS*/'+char(13)+char(10)+char(13)+char(10)
			set @i = (select count(*) from DsctoTrabHist dth
						where dth.RucE=@RucE and dth.Ejer=@Ejer and dth.Prdo=@Prdo and dth.Sem=@Sem and dth.Cd_Trab=@Cd_Trab and dth.Importe<>0 )--and dth.Cd_TipDscto not in ('D98'))
					
			set @Cd_Conceptos = ''
			set @Importes = ''

			(select @Cd_Conceptos+=dth.Cd_TipDscto+',', @Importes+=convert(varchar, dth.Importe)+',' from DsctoTrabHist dth
				where dth.RucE=@RucE and dth.Ejer=@Ejer and dth.Prdo=@Prdo and dth.Sem=@Sem and dth.Cd_Trab=@Cd_Trab and dth.Importe<>0)-- and dth.Cd_TipDscto not in ('D98'))
					
			while(@i>0)
				begin
					set @Cd_Concepto = substring(@Cd_Conceptos, 1, (charindex(',', @Cd_Conceptos)-1))
					set @Importe = substring(@Importes, 1, (charindex(',', @Importes)-1))												

					set @Cd_CCs = ''
					set @Cd_SCs = ''
					set @Cd_SSs = ''
					set @Porcs = ''

					if (@IB_DesgloceDescuentoxCCFicha=1 and @Cd_Concepto='D00') --Solo es para la Renta 5ta
					begin
						set @j = (select count(*) from @TrabajadorXPorcCC txpc where txpc.Cd_Trab=@Cd_Trab)
						select @Cd_CCs+=Cd_CC+',', @Cd_SCs+=Cd_SC+',', @Cd_SSs+=Cd_SS+',', @Porcs+=convert(varchar, Porc)+','
						from @TrabajadorXPorcCC txpc where txpc.Cd_Trab=@Cd_Trab
					end
					else
					begin
						set @j = (select count(*) from @TrabajadorXPorcCC txpc where txpc.Cd_Trab=@Cd_Trab and txpc.IB_CCPrincipal=1)
						select @Cd_CCs=Cd_CC+',', @Cd_SCs=Cd_SC+',', @Cd_SSs=Cd_SS+',',@Porcs='100'+','
						from @TrabajadorXPorcCC txpc where txpc.Cd_Trab=@Cd_Trab and txpc.IB_CCPrincipal=1
					end
							
					begin print '- Asiento Haber ' + case when @IB_GAxCCF=1 then '(F)' else '(TD)' end + ':'
						set @SumImporteConceptoPorcFicha = 0.00
						while(@j>0)
							begin /*Desgloce por Porcentajes de Centro de Costos*/
								set @Cd_CC = substring(@Cd_CCs, 1, (charindex(',', @Cd_CCs)-1))
								set @Cd_SC = substring(@Cd_SCs, 1, (charindex(',', @Cd_SCs)-1))
								set @Cd_SS = substring(@Cd_SSs, 1, (charindex(',', @Cd_SSs)-1))
								set @Porc = substring(@Porcs, 1, (charindex(',', @Porcs)-1))
								
								if(not exists (select * from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS))
									set @s += 'No existe el amarre de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
								else
									begin
										set @NroCta = isnull((select NroCta from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS), '')
										set @Cuenta = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta), '')
										set @P_IB_FEC = ISNULL((select CASE WHEN @P_IB_HABILITAR_CONCEPTOS_FLUJO_EFECTIVO_CONTABLE=1 THEN CASE WHEN ISNULL(IB_CtasXCbr,0)=1 or ISNULL(IB_CtasXPag,0)=1 THEN 1 ELSE 0 END ELSE 0 END from PlanCtas where RucE=@RucE and NroCta=@NroCta and Ejer=@Ejer),0)

										if(@NroCta<>'')
											begin
												begin /*Sumar Monto al Número de Cuenta de Haber*/
												declare @IB_Aux bit=0, @IB_Doc bit=0
												select @IB_Aux = ISNULL(C_IB_AUXILIAR_TRABAJADOR, 0), @IB_Doc=ISNULL(IB_NDoc, 0) from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta
													if(@IB_Aux=1)
														begin
															--select @NroSre=NroSre, @NroDoc=NroDoc from dbo.fn_NroDocTrabajador(@RucE,@Cd_TD,@Cd_Trab)
															set @Cd_TD = CASE WHEN @IB_Doc = 0 THEN NULL ELSE (select Cd_TD_AsientosPlanillon from CfgPlanilla where RucE=@RucE) END
															SET @NroDoc = CASE WHEN @IB_Doc = 0 THEN NULL ELSE @Ejer + @Prdo + SUBSTRING(@Cd_Trab,2,7) END
															set @NroSre = CASE WHEN @IB_Doc = 0 THEN NULL ELSE (select NroSre from dbo.fn_NroDocTrabajador(@RucE,@Cd_TD,@Cd_Trab)) END
															set @Cd_Trabajador = @Cd_Trab
															SET @IB_EsProv = CASE WHEN @IB_Doc = 0 THEN 0 ELSE 1 END
														end
													else
														begin
															set @Cd_TD = CASE WHEN @IB_Doc = 0 THEN NULL ELSE (select Cd_TD_AsientosPlanillon from CfgPlanilla where RucE=@RucE) END
															SET @NroDoc = CASE WHEN @IB_Doc = 0 THEN NULL ELSE @Ejer + @Prdo + SUBSTRING(@Cd_Trab,2,7) END
															set @NroSre = CASE WHEN @IB_Doc = 0 THEN NULL ELSE (select NroSre from dbo.fn_NroDocTrabajador(@RucE,@Cd_TD,@Cd_Trab)) END
															set @Cd_Trabajador = null
															SET @IB_EsProv = CASE WHEN @IB_Doc = 0 THEN 0 ELSE 1 END
														end

													set @SumImporteConceptoPorcFicha += ((@Importe*@Porc)/100)
													select 'A12', @Cd_Concepto, case when (@SumImporteConceptoPorcFicha > @Importe) then ((@Importe*@Porc)/100) - (@SumImporteConceptoPorcFicha - @Importe)
																										when (@j=1) and (@SumImporteConceptoPorcFicha < @Importe) then ((@Importe*@Porc)/100) + ABS(@SumImporteConceptoPorcFicha - @Importe)
																										else ((@Importe*@Porc)/100)
																								end, @NroCta, 'Haber'
													if(exists (select * from Voucher where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@NroCta and CodT=CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END and
																Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS --and isnull(Cd_Area, '')=(case when Cd_Area is null then '' else @Cd_Area end) 
																and Glosa=(@Cuenta+CASE WHEN @P_IB_AGRUPAR_CUENTAS=0 THEN @Trabajador ELSE '' END + case when @IB_GAxCCF=1 then ' (F)' else ' (TD)' end) and isnull(Cd_Trab, '')=(case when @Cd_TD is null then '' else @Cd_Trabajador end)))
														begin
															print 'update '''+@Cd_Concepto+'-'+@NroCta+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, @Importe) + ' ' + @Cuenta
															update Voucher set MtoH=(MtoH+case when (@SumImporteConceptoPorcFicha > @Importe) then ((@Importe*@Porc)/100) - (@SumImporteConceptoPorcFicha - @Importe)
																												 when (@j=1) and (@SumImporteConceptoPorcFicha < @Importe) then ((@Importe*@Porc)/100) + ABS(@SumImporteConceptoPorcFicha - @Importe)
																												 else ((@Importe*@Porc)/100)
																											end),
																			   MtoH_ME=(MtoH_ME+(case when (@SumImporteConceptoPorcFicha > @Importe) then ((@Importe*@Porc)/100) - (@SumImporteConceptoPorcFicha - @Importe)
																										when (@j=1) and (@SumImporteConceptoPorcFicha < @Importe) then ((@Importe*@Porc)/100) + ABS(@SumImporteConceptoPorcFicha - @Importe)
																										else ((@Importe*@Porc)/100)
																								end/@CamMda))/*, FecMdf=getdate(), UsuModf=@UsuCrea*/
																where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@NroCta and CodT=CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS --and isnull(Cd_Area, '')=(case when Cd_Area is null then '' else @Cd_Area end) 
															and Glosa=(@Cuenta+CASE WHEN @P_IB_AGRUPAR_CUENTAS=0 THEN @Trabajador ELSE '' END + case when @IB_GAxCCF=1 then ' (F)' else ' (TD)' end) and isnull(Cd_Trab, '')=(case when @Cd_TD is null then '' else @Cd_Trabajador end)
														end
													else
														begin
															print 'insert '''+@Cd_Concepto+'-'+@NroCta+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, @Importe) + ' ' + @Cuenta
															insert into Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																				MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																				FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,C_ID_CONCEPTO_FEC,CodT)
															values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte, @FecMov, @FecCbr ,@NroCta,@Cd_TD,@NroSre,@NroDoc,@FecMov/*getdate()*/,(@Cuenta+CASE WHEN @P_IB_AGRUPAR_CUENTAS=0 THEN @Trabajador ELSE '' END + case when @IB_GAxCCF=1 then ' (F)' else ' (TD)' end),0.00,
																	0.00,
																	case when (@SumImporteConceptoPorcFicha > @Importe) then ((@Importe*@Porc)/100) - (@SumImporteConceptoPorcFicha - @Importe)
																			when (@j=1) and (@SumImporteConceptoPorcFicha < @Importe) then ((@Importe*@Porc)/100) + ABS(@SumImporteConceptoPorcFicha - @Importe)
																			else ((@Importe*@Porc)/100)
																	end
																	,0.00,
																	((case when (@SumImporteConceptoPorcFicha > @Importe) then ((@Importe*@Porc)/100) - (@SumImporteConceptoPorcFicha - @Importe)
																		when (@j=1) and (@SumImporteConceptoPorcFicha < @Importe) then ((@Importe*@Porc)/100) + ABS(@SumImporteConceptoPorcFicha - @Importe)
																		else ((@Importe*@Porc)/100) 
																	end)/@CamMda),
																	'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',@IB_EsProv,
																	getdate(),null,@UsuCrea,null,0,@Cd_Trabajador,CASE WHEN @P_IB_FEC=1 THEN @P_ID_CONCEPTO_FEC ELSE 0 END,CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END)
														end
												end
											end
										else
											set @s += 'No existe la contrapartida de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
									end

								set @Cd_CCs = substring(@Cd_CCs, (charindex(',',@Cd_CCs)+1), len(@Cd_CCs))
								set @Cd_SCs = substring(@Cd_SCs, (charindex(',',@Cd_SCs)+1), len(@Cd_SCs))
								set @Cd_SSs = substring(@Cd_SSs, (charindex(',',@Cd_SSs)+1), len(@Cd_SSs))
								set @Porcs = substring(@Porcs, (charindex(',',@Porcs)+1), len(@Porcs))
								set @j = (@j-1)
							end

						begin /*Restar Monto al Número de Cuenta de Diferencia*/
							set @Cd_CC = (select Cd_CC from @TrabajadorXPorcCC where Cd_Trab=@Cd_Trab and IB_CCPrincipal=1)
							set @Cd_SC = (select Cd_SC from @TrabajadorXPorcCC where Cd_Trab=@Cd_Trab and IB_CCPrincipal=1)
							set @Cd_SS = (select Cd_SS from @TrabajadorXPorcCC where Cd_Trab=@Cd_Trab and IB_CCPrincipal=1)

							if(not exists (select * from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS))
								set @s += 'No existe el amarre de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
							else
								begin
									SET @IB_CtaVac = CASE WHEN ISNULL((select SUM(Dias) from VacacionesDet Where RucE=@RucE and Ejer=@Ejer and Prdo= @Prdo and Cd_Trab=@Cd_Trab and ISNULL(IB_Venta, 0)=0), 0) >= 30 THEN 1 ELSE 0 END
									IF(@Cd_Concepto='D12' AND @RucE='20453789854')
										set @NroCta = isnull((select (case when @Sem='' then Contrapartida else Contrapartida_Obr end) from AmarreCtaCC where RucE=@RucE and CodRoD='R05' and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS), '')
									ELSE IF(@IB_CtaVac=1)
										set @NroCta = isnull((select (case when @Sem='' then Contrapartida else Contrapartida_Obr end) from AmarreCtaCC where RucE=@RucE and CodRoD='R03' and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS), '')
									ELSE
										set @NroCta = isnull((select NroCta from AmarreCtaCC where RucE=@RucE and CodRoD= @Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS), '')
								
									set @Cuenta = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta), '')
									set @P_IB_FEC = ISNULL((select CASE WHEN @P_IB_HABILITAR_CONCEPTOS_FLUJO_EFECTIVO_CONTABLE=1 THEN CASE WHEN ISNULL(IB_CtasXCbr,0)=1 or ISNULL(IB_CtasXPag,0)=1 THEN 1 ELSE 0 END ELSE 0 END from PlanCtas where RucE=@RucE and NroCta=@NroCta and Ejer=@Ejer),0)

									if(@NroCta<>'')
										begin
											if((select isnull(C_IB_AUXILIAR_TRABAJADOR, 0) from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=(case when @Sem='' then CASE WHEN (@Cd_Concepto='D12' AND @RucE='20453789854') OR @IB_CtaVac=1 THEN @NroCta ELSE @NroCtaDifEmp END else @NroCtaDifObr end))=1)
												begin
													set @Cd_Trabajador = @Cd_Trab
												end
											else
												begin
													set @Cd_Trabajador = null
												end
												
											if(ISNULL((select isnull(IB_NDoc, 0) from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=(case when @Sem='' then CASE WHEN (@Cd_Concepto='D12' AND @RucE='20453789854') OR @IB_CtaVac=1 THEN @NroCta ELSE @NroCtaDifEmp END else @NroCtaDifObr end)),0) = 1)
												begin
													set @Cd_TD = (select Cd_TD_AsientosPlanillon from CfgPlanilla where RucE=@RucE)
													select @NroSre=NroSre from dbo.fn_NroDocTrabajador(@RucE,@Cd_TD,@Cd_Trab)
													SET @NroDoc = @Ejer + @Prdo + SUBSTRING(@Cd_Trab,2,7)
													SET @IB_EsProv = 1
												end
											else
												begin
													set @Cd_TD = null
													set @NroSre = null
													set @NroDoc = null
													SET @IB_EsProv = 0
												end
												select 'A13', @Cd_Concepto, -@Importe, case when @Sem='' then CASE WHEN (@Cd_Concepto='D12' AND @RucE='20453789854') OR @IB_CtaVac=1 THEN @NroCta ELSE @NroCtaDifEmp END else @NroCtaDifObr end, 'Haber'
												
											if(exists (select * from Voucher 
													where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=(case when @Sem='' then CASE WHEN (@Cd_Concepto='D12' AND @RucE='20453789854') OR @IB_CtaVac=1 THEN @NroCta ELSE @NroCtaDifEmp END else @NroCtaDifObr end) and ISNULL(CodT,'')='' and
														Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS --and isnull(Cd_Area, '')=(case when Cd_Area is null then '' else @Cd_Area end) 
														and Glosa=((case when @Sem='' then CASE WHEN (@Cd_Concepto='D12' AND @RucE='20453789854') OR @IB_CtaVac=1 THEN @Cuenta ELSE @CuentaDifEmp END else @CuentaDifObr end)+CASE WHEN @P_IB_AGRUPAR_CUENTAS=0 THEN @Trabajador ELSE '' END + case when @IB_GAxCCF=1 then ' (F)' else ' (TD)' end) 
														--and Glosa=((case when @Sem='' then @Cuenta else @Cuenta end)+CASE WHEN @P_IB_AGRUPAR_CUENTAS=0 THEN @Trabajador ELSE '' END + case when @IB_GAxCCF=1 then ' (F)' else ' (TD)' end) 
														and isnull(Cd_Trab, '')=(case when @Cd_TD is null then '' else @Cd_Trabajador end)))
												begin
													print 'update '''+@Cd_Concepto+'-'+(case when @Sem='' then CASE WHEN (@Cd_Concepto='D12' AND @RucE='20453789854') OR @IB_CtaVac=1 THEN @NroCta ELSE @NroCtaDifEmp END else @NroCtaDifObr end)+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, -@Importe) + ' ' + @Cuenta
													update Voucher set MtoH=(MtoH-@Importe), MtoH_ME=(MtoH_ME-(@Importe/@CamMda))/*, FecMdf=getdate(), UsuModf=@UsuCrea*/
													where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=(case when @Sem='' then CASE WHEN (@Cd_Concepto='D12' AND @RucE='20453789854') OR @IB_CtaVac=1 THEN @NroCta ELSE @NroCtaDifEmp END else @NroCtaDifObr end) and ISNULL(CodT,'')='' and
														Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS --and isnull(Cd_Area, '')=(case when Cd_Area is null then '' else @Cd_Area end)
														and Glosa=((case when @Sem='' then CASE WHEN (@Cd_Concepto='D12' AND @RucE='20453789854') OR @IB_CtaVac=1 THEN @Cuenta ELSE @CuentaDifEmp END else @CuentaDifObr end)+CASE WHEN @P_IB_AGRUPAR_CUENTAS=0 THEN @Trabajador ELSE '' END + case when @IB_GAxCCF=1 then ' (F)' else ' (TD)' end)
														--and Glosa=((case when @Sem='' then @Cuenta else @Cuenta end)+CASE WHEN @P_IB_AGRUPAR_CUENTAS=0 THEN @Trabajador ELSE '' END + case when @IB_GAxCCF=1 then ' (F)' else ' (TD)' end) 
														and isnull(Cd_Trab, '')=(case when @Cd_TD is null then '' else @Cd_Trabajador end)
												end
											else
												begin
													print 'insert '''+@Cd_Concepto+'-'+(case when @Sem='' then CASE WHEN (@Cd_Concepto='D12' AND @RucE='20453789854') OR @IB_CtaVac=1 THEN @NroCta ELSE @NroCtaDifEmp END else @NroCtaDifObr end)+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, -@Importe) + ' ' + @Cuenta
													insert into Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,
																		Glosa,MtoOr,
																		MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																		FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,C_ID_CONCEPTO_FEC)
													values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte,  @FecMov, @FecCbr ,(case when @Sem='' then CASE WHEN (@Cd_Concepto='D12' AND @RucE='20453789854') OR @IB_CtaVac=1 THEN @NroCta ELSE @NroCtaDifEmp END else @NroCtaDifObr end),@Cd_TD,@NroSre,@NroDoc,@FecMov/*getdate()*/,
														((case when @Sem='' then CASE WHEN (@Cd_Concepto='D12' AND @RucE='20453789854') OR @IB_CtaVac=1 THEN @Cuenta ELSE @CuentaDifEmp END else @CuentaDifObr end)+CASE WHEN @P_IB_AGRUPAR_CUENTAS=0 THEN @Trabajador ELSE '' END + case when @IB_GAxCCF=1 then ' (F)' else ' (TD)' end),0.00,
															0.00,-@Importe,0.00,-(@Importe/@CamMda),'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',@IB_EsProv,
															getdate(),null,@UsuCrea,null,0,@Cd_Trabajador,CASE WHEN @P_IB_FEC=1 THEN @P_ID_CONCEPTO_FEC ELSE 0 END)
												end
										end
									else
										set @s += 'No existe la contrapartida de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
								end
						end

						print @s+char(13)+char(10)
						set @msj += @s
						set @s = ''
					end

					begin print '- Asiento Destino ' + case when @IB_GAxCCF=1 then '(F)' else '(TD)' end + ':'
						set @Cd_CC = (select Cd_CC from @TrabajadorXPorcCC where Cd_Trab=@Cd_Trab and IB_CCPrincipal=1)
						set @Cd_SC = (select Cd_SC from @TrabajadorXPorcCC where Cd_Trab=@Cd_Trab and IB_CCPrincipal=1)
						set @Cd_SS = (select Cd_SS from @TrabajadorXPorcCC where Cd_Trab=@Cd_Trab and IB_CCPrincipal=1)

						if(not exists (select * from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS))
							set @s += 'No existe el amarre de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
						else
							begin
								set @NroCta = isnull((select NroCta from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@cd_SS), '')
								SET @L_IB_DESAGRUPAR_DESTINOS = (SELECT ISNULL(C_IB_DESAGRUPAR_DESTINOS, 0) FROM PLANCTAS WHERE RUCE=@RucE AND EJER=@Ejer AND NROCTA=@NroCta)
								SET @IB_AMARRE_CUENTA_DESTINO_CENTRO_COSTO = (SELECT ISNULL(C_IB_CUENTA_DESTINO_CENTRO_COSTO, 0) FROM PLANCTAS WHERE RUCE=@RucE AND EJER=@Ejer AND NROCTA=@NroCta)

								declare
								@FactorRestaDestinoDescuento int = 1
								if exists (select top 1 * from RemuTrabHist rth 
												inner join TipoRemu tr on tr.RucE=rth.RucE and tr.Cd_TipRemu=rth.Cd_TipRemu AND CASE WHEN @IC_TipoPlan='E' THEN tr.IB_PlnEmpl ELSE tr.IB_PlnObr END = 1
									where rth.RucE=@RucE and rth.Ejer=@Ejer and rth.Prdo=@Prdo and rth.Cd_Trab=@Cd_Trab and rth.Sem=@Sem and rth.Cd_TipRemu in (select distinct CodRoD from AmarreCtaCC where RucE=@RucE and NroCta=@NroCta and CodRoD like 'R%') and rth.Importe>0.00)
									set @FactorRestaDestinoDescuento = -1

								if(@NroCta<>'')
									begin
										if(@IB_AMARRE_CUENTA_DESTINO_CENTRO_COSTO=1)
												begin
													if((select TOP 1 isnull(C_NUMERO_CUENTA_DEBE, '') from CONTABILIDAD.T_AMARRE_CUENTA_CENTRO_COSTO_DESTINOS where C_RUC_EMPRESA  = @RucE and C_EJERCICIO  = @Ejer and CONCAT(C_CODIGO_CENTRO_COSTO,C_CODIGO_SUB_CENTRO_COSTO,C_CODIGO_SUB_SUB_CENTRO_COSTO)=@Cd_CC+@Cd_SC+@cd_SS)!='')
														begin
															set @k = (select COUNT(*) from CONTABILIDAD.T_AMARRE_CUENTA_CENTRO_COSTO_DESTINOS where C_RUC_EMPRESA  = @RucE and C_EJERCICIO  = @Ejer and CONCAT(C_CODIGO_CENTRO_COSTO,C_CODIGO_SUB_CENTRO_COSTO,C_CODIGO_SUB_SUB_CENTRO_COSTO)=@Cd_CC+@Cd_SC+@cd_SS)
															set @k_total = @k

															(select @CtaDs+=C_NUMERO_CUENTA_DEBE+',', @CtaHs+=C_NUMERO_CUENTA_HASTA+',', @PorcDs+=convert(varchar, C_PORCENTAJE)+',' from CONTABILIDAD.T_AMARRE_CUENTA_CENTRO_COSTO_DESTINOS where C_RUC_EMPRESA  = @RucE and C_EJERCICIO  = @Ejer and CONCAT(C_CODIGO_CENTRO_COSTO,C_CODIGO_SUB_CENTRO_COSTO,C_CODIGO_SUB_SUB_CENTRO_COSTO)=@Cd_CC+@Cd_SC+@cd_SS)

															while(@k>0)
																begin
																	set @CtaD = substring(@CtaDs, 1, (charindex(',', @CtaDs)-1))
																	set @CtaH = substring(@CtaHs, 1, (charindex(',', @CtaHs)-1))
																	set @PorcD = substring(@PorcDs, 1, (charindex(',', @PorcDs)-1))

																	begin /*Cuenta de Destino (Debe)*/
																		set @Cuenta = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@CtaD), '')
																		
																		select 'A14', @Cd_Concepto, CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END, @CtaD, 'Destino Debe'
																		IF(@L_IB_DESAGRUPAR_DESTINOS=0) /* AGRUPAR DESTINOS:EL DEBE VA TODO EN UNA LINEA */
																			BEGIN
																				if(exists (select * from Voucher where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@CtaD))
																					begin
																						print 'update '''+@CtaD+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END)))+' (Debe)'
																						update Voucher set MtoD=(MtoD+(CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END)),
																						MtoD_ME=(MtoD_ME+(CASE WHEN @k_total>1 AND @k=1 THEN @Importe/@CamMda-Convert(numeric(20,2),@Importe*(100-@PorcD)/100/@CamMda) ELSE @Importe*@PorcD/100/@CamMda END))/*, FecMdf=getdate(), UsuModf=@UsuCrea*/
																						where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@CtaD
																					end
																				else
																					begin
																						print 'insert '''+@CtaD+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END)))+' (Debe)'
																						insert into Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																											MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																											FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,IB_EsDes)
																						values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte,  @FecMov, @FecCbr ,@CtaD,null,null,null,@FecMov/*getdate()*/,@Cuenta+' (Destino)',0.00,
																								(CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END),0.00,(CASE WHEN @k_total>1 AND @k=1 THEN @Importe/@CamMda-Convert(numeric(20,2),@Importe*(100-@PorcD)/100/@CamMda) ELSE @Importe*@PorcD/100/@CamMda END),0.00,'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',0,
																								getdate(),null,@UsuCrea,null,0,null,1)
																					end
																			END
																		ELSE /* DESAGRUPAR DESTINOS: EL DEBE SE GENERA POR CADA LINEA */
																			BEGIN
																				print 'insert '''+@CtaD+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END)))+' (Debe)'
																				insert into Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																									MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																									FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,IB_EsDes)
																				values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte,  @FecMov, @FecCbr ,@CtaD,null,null,null,@FecMov/*getdate()*/,@Cuenta+' (Destino)',0.00,
																						(CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END),0.00,(CASE WHEN @k_total>1 AND @k=1 THEN @Importe/@CamMda-Convert(numeric(20,2),@Importe*(100-@PorcD)/100/@CamMda) ELSE @Importe*@PorcD/100/@CamMda END),0.00,'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',0,
																						getdate(),null,@UsuCrea,null,0,null,1)
																			END
																	end
																	begin /*Cuenta de Destino (Haber)*/
																		set @Cuenta = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@CtaH), '')
																		select 'A15', @Cd_Concepto, CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END, @CtaH, 'Destino Haber'
																		if(exists (select * from Voucher where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@CtaH and Glosa=@Cuenta+' (Destino)'))
																			begin
																				print 'update '''+@CtaH+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END)))+' (Haber)' + ' ' + @Cuenta
																				update Voucher set MtoH=(MtoH+(CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END)),
																				MtoH_ME=(MtoH_ME+(CASE WHEN @k_total>1 AND @k=1 THEN @Importe/@CamMda-Convert(numeric(20,2),@Importe*(100-@PorcD)/100/@CamMda) ELSE @Importe*@PorcD/100/@CamMda END))/*, FecMdf=getdate(), UsuModf=@UsuCrea*/
																				where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@CtaH
																			end
																		else
																			begin
																				print 'insert '''+@CtaH+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END)))+' (Haber)' + ' ' + @Cuenta
																				insert into Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																									MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																									FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,IB_EsDes)
																				values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte,  @FecMov, @FecCbr ,@CtaH,null,null,null,@FecMov/*getdate()*/,@Cuenta+' (Destino)',0.00,
																						0.00,(CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END),0.00,(CASE WHEN @k_total>1 AND @k=1 THEN @Importe/@CamMda-Convert(numeric(20,2),@Importe*(100-@PorcD)/100/@CamMda) ELSE @Importe*@PorcD/100/@CamMda END),'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',0,
																						getdate(),null,@UsuCrea,null,0,null,1)
																			end
																	end

																	set @CtaDs = substring(@CtaDs, (charindex(',',@CtaDs)+1), len(@CtaDs))
																	set @CtaHs = substring(@CtaHs, (charindex(',',@CtaHs)+1), len(@CtaHs))
																	set @PorcDs = substring(@PorcDs, (charindex(',',@PorcDs)+1), len(@PorcDs))
																	set @k = (@k-1)
																end
														end
													else
														print 'El número de cuenta de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'| no tiene cuentas de destino'+char(13)+char(10)
												end
											else
												begin
													if((select isnull(IB_CtaD, 0) from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta)=1)
														begin											
															set @k = (select count(*) from AmarreCta where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta)
															set @k_total = @k

															(select @CtaDs+=CtaD+',', @CtaHs+=CtaH+',', @PorcDs+=convert(varchar, Porc)+',' from AmarreCta where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta)

															while(@k>0)
																begin
																	set @CtaD = substring(@CtaDs, 1, (charindex(',', @CtaDs)-1))
																	set @CtaH = substring(@CtaHs, 1, (charindex(',', @CtaHs)-1))
																	set @PorcD = substring(@PorcDs, 1, (charindex(',', @PorcDs)-1))

																	begin /*Cuenta de Destino (Debe)*/
																		set @Cuenta = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@CtaD), '')
																		select 'A16', @Cd_Concepto, CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END, @CtaH, @CtaD, 'Destino Debe'
																		IF(@L_IB_DESAGRUPAR_DESTINOS=0) /* AGRUPAR DESTINOS:EL DEBE VA TODO EN UNA LINEA */
																			BEGIN
																				if(exists (select * from Voucher where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@CtaD))
																					begin
																						print 'update '''+@CtaH+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END)))+' (Debe)'
																						update Voucher set MtoD=(MtoD+((CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END)*@FactorRestaDestinoDescuento)),
																						MtoD_ME=(MtoD_ME+((CASE WHEN @k_total>1 AND @k=1 THEN @Importe/@CamMda-Convert(numeric(20,2),@Importe*(100-@PorcD)/100/@CamMda) ELSE @Importe*@PorcD/100/@CamMda END)*@FactorRestaDestinoDescuento))/*, FecMdf=getdate(), UsuModf=@UsuCrea*/
																						where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@CtaH
																					end
																				else
																					begin
																						print 'insert '''+@CtaH+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END)))+' (Debe)'
																						insert into Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																											MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																											FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,IB_EsDes)
																						values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte,  @FecMov, @FecCbr ,@CtaH,null,null,null,@FecMov/*getdate()*/,@Cuenta+' (Destino)',0.00,
																								(CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END),0.00,(CASE WHEN @k_total>1 AND @k=1 THEN @Importe/@CamMda-Convert(numeric(20,2),@Importe*(100-@PorcD)/100/@CamMda) ELSE @Importe*@PorcD/100/@CamMda END),0.00,'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',0,
																								getdate(),null,@UsuCrea,null,0,null,1)
																					end
																			END
																		ELSE /* DESAGRUPAR DESTINOS: EL DEBE SE GENERA POR CADA LINEA */
																			BEGIN
																				print 'insert '''+@CtaH+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END)))+' (Debe)'
																				insert into Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																									MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																									FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,IB_EsDes)
																				values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte,  @FecMov, @FecCbr ,@CtaH,null,null,null,@FecMov/*getdate()*/,@Cuenta+' (Destino)',0.00,
																						(CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END),0.00,(CASE WHEN @k_total>1 AND @k=1 THEN @Importe/@CamMda-Convert(numeric(20,2),@Importe*(100-@PorcD)/100/@CamMda) ELSE @Importe*@PorcD/100/@CamMda END),0.00,'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',0,
																						getdate(),null,@UsuCrea,null,0,null,1)
																			END
																	end
																	begin /*Cuenta de Destino (Haber)*/
																		set @Cuenta = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@CtaH), '')
																		select 'A17', @Cd_Concepto, CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END, @CtaH, 'Haber'
																		--if(exists (select * from Voucher where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@CtaH))
																		--	begin
																		--		print 'update '''+@CtaH+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,2), ((@Importe*@PorcD)/100)))+' (Haber)'
																		--		update Voucher set MtoH=(MtoH+(((@Importe*@PorcD)/100)*@FactorRestaDestinoDescuento)), MtoH_ME=(MtoH_ME+(((@Importe*@PorcD)/100)/@CamMda*@FactorRestaDestinoDescuento))/*, FecMdf=getdate(), UsuModf=@UsuCrea*/
																		--		where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@CtaH
																		--	end
																		--else
																				print 'insert '''+@CtaD+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END)))+' (Haber)' + ' ' + @Cuenta + ' (Destino)'
																				insert into Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																									MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																									FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,IB_EsDes)
																				values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte,  @FecMov, @FecCbr ,@CtaD,null,null,null,@FecMov/*getdate()*/,@Cuenta+' (Destino)',0.00,
																						0.00,(CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END),0.00,(CASE WHEN @k_total>1 AND @k=1 THEN @Importe/@CamMda-Convert(numeric(20,2),@Importe*(100-@PorcD)/100/@CamMda) ELSE @Importe*@PorcD/100/@CamMda END),'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',0,
																						getdate(),null,@UsuCrea,null,0,null,1)
																	end

																	set @CtaDs = substring(@CtaDs, (charindex(',',@CtaDs)+1), len(@CtaDs))
																	set @CtaHs = substring(@CtaHs, (charindex(',',@CtaHs)+1), len(@CtaHs))
																	set @PorcDs = substring(@PorcDs, (charindex(',',@PorcDs)+1), len(@PorcDs))
																	set @k = (@k-1)
																end
														end
													else
														print 'El número de cuenta de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'| no tiene cuentas de destino'+char(13)+char(10)
												end
									end
								else
									set @s += 'No existe el numero de cuenta de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
							end

						print @s+char(13)+char(10)
						set @msj += @s
						set @s = ''
					end
				
					set @Cd_Conceptos = substring(@Cd_Conceptos, (charindex(',',@Cd_Conceptos)+1), len(@Cd_Conceptos))
					set @Importes = substring(@Importes, (charindex(',',@Importes)+1), len(@Importes))
					set @i = (@i-1)
				end
			print '/************************/'+char(13)+char(10)+char(13)+char(10)
		end
	
		begin print '/*ASIENTOS DE REGIMEN PENSIONARIO*/'+char(13)+char(10)+char(13)+char(10)
			set @i = (select count(*) from RegimenTrabHist rth
						where rth.RucE=@RucE and rth.Ejer=@Ejer and rth.Prdo=@Prdo and rth.Sem=@Sem and rth.Cd_Trab=@Cd_Trab and rth.Importe<>0)
					
			set @Cd_Conceptos = ''
			set @Importes = ''

			(select @Cd_Conceptos+=rth.Cd_TReg+',', @Importes+=convert(varchar, rth.Importe)+',' from RegimenTrabHist rth
				where rth.RucE=@RucE and rth.Ejer=@Ejer and rth.Prdo=@Prdo and rth.Sem=@Sem and rth.Cd_Trab=@Cd_Trab and rth.Importe<>0)
					
			while(@i>0)
				begin
					set @Cd_Concepto = substring(@Cd_Conceptos, 1, (charindex(',', @Cd_Conceptos)-1))
					set @Importe = substring(@Importes, 1, (charindex(',', @Importes)-1))
							
					

					set @Cd_CCs = ''
					set @Cd_SCs = ''
					set @Cd_SSs = ''
					set @Porcs = ''

					if (@IB_DesgloceRegimenPensionarioxCCFicha=1)
					begin
						set @j = (select count(*) from @TrabajadorXPorcCC txpc where txpc.Cd_Trab=@Cd_Trab)
						select @Cd_CCs+=Cd_CC+',', @Cd_SCs+=Cd_SC+',', @Cd_SSs+=Cd_SS+',', @Porcs+=convert(varchar, Porc)+','
						from @TrabajadorXPorcCC txpc where txpc.Cd_Trab=@Cd_Trab
					end
					else
					begin
						set @j = (select count(*) from @TrabajadorXPorcCC txpc where txpc.Cd_Trab=@Cd_Trab and txpc.IB_CCPrincipal=1)
						select @Cd_CCs=Cd_CC+',', @Cd_SCs=Cd_SC+',', @Cd_SSs=Cd_SS+',',@Porcs='100'+','
						from @TrabajadorXPorcCC txpc where txpc.Cd_Trab=@Cd_Trab and txpc.IB_CCPrincipal=1
					end
							
					begin print '- Asiento Haber ' + case when @IB_GAxCCF=1 then '(F)' else '(TD)' end + ':'
						set @SumImporteConceptoPorcFicha = 0.00
						while(@j>0)
							begin /*Sumar Monto al Número de Cuenta de Haber (Desgloce por Trabajador o Centro de Costos Principal)*/
								set @Cd_CC = substring(@Cd_CCs, 1, (charindex(',', @Cd_CCs)-1))
								set @Cd_SC = substring(@Cd_SCs, 1, (charindex(',', @Cd_SCs)-1))
								set @Cd_SS = substring(@Cd_SSs, 1, (charindex(',', @Cd_SSs)-1))
								set @Porc = substring(@Porcs, 1, (charindex(',', @Porcs)-1))
								
								if(not exists (select * from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS))
									set @s += 'No existe el amarre de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
								else
									begin
										set @NroCta = isnull((select NroCta from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS), '')
										set @Cuenta = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta), '')
										set @P_IB_FEC = ISNULL((select CASE WHEN @P_IB_HABILITAR_CONCEPTOS_FLUJO_EFECTIVO_CONTABLE=1 THEN CASE WHEN ISNULL(IB_CtasXCbr,0)=1 or ISNULL(IB_CtasXPag,0)=1 THEN 1 ELSE 0 END ELSE 0 END from PlanCtas where RucE=@RucE and NroCta=@NroCta and Ejer=@Ejer),0)

										if(@NroCta<>'')
											begin
												begin /*Sumar Monto al Número de Cuenta de Haber (Desgloce por Trabajador o Centro de Costos Principal)*/
													if(((select isnull(C_IB_AUXILIAR_TRABAJADOR, 0) from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta)=1) and (@IB_DxRP=1))
														begin
															set @Cd_Trabajador = @Cd_Trab
														end
													else
														begin
															set @Cd_Trabajador = null
														end
													if(ISNULL((select isnull(IB_NDoc, 0) from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta),0) = 1)
															begin
																set @Cd_TD = (select Cd_TD_AsientosPlanillon from CfgPlanilla where RucE=@RucE)
																select @NroSre=NroSre from dbo.fn_NroDocTrabajador(@RucE,@Cd_TD,@Cd_Trab)
																SET @NroDoc = @Ejer + @Prdo + SUBSTRING(@Cd_Trab,2,7)
																SET @IB_EsProv = 1
															end
														else
															begin
																set @Cd_TD = null
																SET @NroSre=null
																SET @NroDoc = null
																SET @IB_EsProv = 0
															end

													set @SumImporteConceptoPorcFicha += ((@Importe*@Porc)/100)
													select 'A18', @Cd_Concepto, case when (@SumImporteConceptoPorcFicha > @Importe) then ((@Importe*@Porc)/100) - (@SumImporteConceptoPorcFicha - @Importe)
																												 when (@j=1) and (@SumImporteConceptoPorcFicha < @Importe) then ((@Importe*@Porc)/100) + ABS(@SumImporteConceptoPorcFicha - @Importe)
																												 else ((@Importe*@Porc)/100)
																											end, @NroCta, 'Haber'
													if(exists (select * from Voucher where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@NroCta and
																Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS --and isnull(Cd_Area, '')=(case when Cd_Area is null then '' else @Cd_Area end) 
																and Glosa=(case when (@IB_DxRP=1) then (@Cuenta+CASE WHEN @P_IB_AGRUPAR_CUENTAS=0 THEN @Trabajador ELSE '' END + case when @IB_GAxCCF=1 then ' (F)' else ' (TD)' end) else (@Cuenta + case when @IB_GAxCCF=1 then ' (F)' else ' (TD)' end) end) 
																and isnull(Cd_Trab, '')=(case when @Cd_TD is null then '' else @Cd_Trabajador end)))
														begin
															print 'update '''+@Cd_Concepto+'-'+@NroCta+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, @Importe)
															update Voucher set MtoH=(MtoH+case when (@SumImporteConceptoPorcFicha > @Importe) then ((@Importe*@Porc)/100) - (@SumImporteConceptoPorcFicha - @Importe)
																												 when (@j=1) and (@SumImporteConceptoPorcFicha < @Importe) then ((@Importe*@Porc)/100) + ABS(@SumImporteConceptoPorcFicha - @Importe)
																												 else ((@Importe*@Porc)/100)
																											end),
																			   MtoH_ME=(MtoH_ME+(case when (@SumImporteConceptoPorcFicha > @Importe) then ((@Importe*@Porc)/100) - (@SumImporteConceptoPorcFicha - @Importe)
																										when (@j=1) and (@SumImporteConceptoPorcFicha < @Importe) then ((@Importe*@Porc)/100) + ABS(@SumImporteConceptoPorcFicha - @Importe)
																										else ((@Importe*@Porc)/100)
																								end/@CamMda))/*, FecMdf=getdate(), UsuModf=@UsuCrea*/
															where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@NroCta and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS --and isnull(Cd_Area, '')=(case when Cd_Area is null then '' else @Cd_Area end) 
															and Glosa=(case when (@IB_DxRP=1) then (@Cuenta+CASE WHEN @P_IB_AGRUPAR_CUENTAS=0 THEN @Trabajador ELSE '' END + case when @IB_GAxCCF=1 then ' (F)' else ' (TD)' end) else (@Cuenta + case when @IB_GAxCCF=1 then ' (F)' else ' (TD)' end) end) and isnull(Cd_Trab, '')=(case when @Cd_TD is null then '' else @Cd_Trabajador end)
														end
													else
														begin
															print 'insert '''+@Cd_Concepto+'-'+@NroCta+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, @Importe)
															insert into Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																				MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																				FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,C_ID_CONCEPTO_FEC)
															values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte,   @FecMov, @FecCbr ,@NroCta,@Cd_TD,@NroSre,@NroDoc,@FecMov/*getdate()*/,(case when (@IB_DxRP=1) then (@Cuenta+CASE WHEN @P_IB_AGRUPAR_CUENTAS=0 THEN @Trabajador ELSE '' END + case when @IB_GAxCCF=1 then ' (F)' else ' (TD)' end) else (@Cuenta + case when @IB_GAxCCF=1 then ' (F)' else ' (TD)' end) end),0.00,
																	0.00,
																	case when (@SumImporteConceptoPorcFicha > @Importe) then ((@Importe*@Porc)/100) - (@SumImporteConceptoPorcFicha - @Importe)
																			when (@j=1) and (@SumImporteConceptoPorcFicha < @Importe) then ((@Importe*@Porc)/100) + ABS(@SumImporteConceptoPorcFicha - @Importe)
																			else ((@Importe*@Porc)/100)
																	end
																	,0.00,
																	((case when (@SumImporteConceptoPorcFicha > @Importe) then ((@Importe*@Porc)/100) - (@SumImporteConceptoPorcFicha - @Importe)
																		when (@j=1) and (@SumImporteConceptoPorcFicha < @Importe) then ((@Importe*@Porc)/100) + ABS(@SumImporteConceptoPorcFicha - @Importe)
																		else ((@Importe*@Porc)/100) 
																	end)/@CamMda),
																	'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',@IB_EsProv,
																	getdate(),null,@UsuCrea,null,0,@Cd_Trabajador,CASE WHEN @P_IB_FEC=1 THEN @P_ID_CONCEPTO_FEC ELSE 0 END)
														end
												end
											end
										else
											set @s += 'No existe la contrapartida de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
									end

								set @Cd_CCs = substring(@Cd_CCs, (charindex(',',@Cd_CCs)+1), len(@Cd_CCs))
								set @Cd_SCs = substring(@Cd_SCs, (charindex(',',@Cd_SCs)+1), len(@Cd_SCs))
								set @Cd_SSs = substring(@Cd_SSs, (charindex(',',@Cd_SSs)+1), len(@Cd_SSs))
								set @Porcs = substring(@Porcs, (charindex(',',@Porcs)+1), len(@Porcs))
								set @j = (@j-1)
							end

						begin /*Restar Monto al Número de Cuenta de Diferencia*/
							set @Cd_CC = (select Cd_CC from @TrabajadorXPorcCC where Cd_Trab=@Cd_Trab and IB_CCPrincipal=1)
							set @Cd_SC = (select Cd_SC from @TrabajadorXPorcCC where Cd_Trab=@Cd_Trab and IB_CCPrincipal=1)
							set @Cd_SS = (select Cd_SS from @TrabajadorXPorcCC where Cd_Trab=@Cd_Trab and IB_CCPrincipal=1)

							if(not exists (select * from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS))
								set @s += 'No existe el amarre de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
							else
								begin
									SET @IB_CtaVac = CASE WHEN ISNULL((select SUM(Dias) from VacacionesDet Where RucE=@RucE and Ejer=@Ejer and Prdo= @Prdo and Cd_Trab=@Cd_Trab and ISNULL(IB_Venta, 0)=0), 0) >= 30 THEN 1 ELSE 0 END
									IF(@IB_CtaVac=1)
										set @NroCta = isnull((select (case when @Sem='' then Contrapartida else Contrapartida_Obr end) from AmarreCtaCC where RucE=@RucE and CodRoD='R03' and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS), '')
									ELSE
										set @NroCta = isnull((select NroCta from AmarreCtaCC where RucE=@RucE and CodRoD= @Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS), '')
									set @Cuenta = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta), '')
									set @P_IB_FEC = ISNULL((select CASE WHEN @P_IB_HABILITAR_CONCEPTOS_FLUJO_EFECTIVO_CONTABLE=1 THEN CASE WHEN ISNULL(IB_CtasXCbr,0)=1 or ISNULL(IB_CtasXPag,0)=1 THEN 1 ELSE 0 END ELSE 0 END from PlanCtas where RucE=@RucE and NroCta=@NroCta and Ejer=@Ejer),0)
									
									if(@NroCta<>'')
										begin
											if((select isnull(C_IB_AUXILIAR_TRABAJADOR, 0) from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=(case when @Sem='' then CASE WHEN @IB_CtaVac=1 THEN @NroCta ELSE @NroCtaDifEmp END else @NroCtaDifObr end))=1)
												begin
													set @Cd_Trabajador = @Cd_Trab
												end
											else
												begin
													set @Cd_Trabajador = null
												end

											if(ISNULL((select isnull(IB_NDoc, 0) from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=(case when @Sem='' then CASE WHEN @IB_CtaVac=1 THEN @NroCta ELSE @NroCtaDifEmp END else @NroCtaDifObr end)),0) = 1)
												begin
													set @Cd_TD = (select Cd_TD_AsientosPlanillon from CfgPlanilla where RucE=@RucE)
													select @NroSre=NroSre from dbo.fn_NroDocTrabajador(@RucE,@Cd_TD,@Cd_Trab)
													SET @NroDoc = @Ejer + @Prdo + SUBSTRING(@Cd_Trab,2,7)
													SET @IB_EsProv = 1
												end
											else
												begin
													set @Cd_TD = null
													SET @NroSre=null
													SET @NroDoc = null
													SET @IB_EsProv = 0
												end
												
											select 'A19', @Cd_Concepto, -@Importe, case when @Sem='' then CASE WHEN @IB_CtaVac=1 THEN @NroCta ELSE @NroCtaDifEmp END else @NroCtaDifObr end, 'Haber'
											if(exists (select * from Voucher where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=(case when @Sem='' then CASE WHEN @IB_CtaVac=1 THEN @NroCta ELSE @NroCtaDifEmp END else @NroCtaDifObr end) and ISNULL(CodT,'')='' and
														Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS --and isnull(Cd_Area, '')=(case when Cd_Area is null then '' else @Cd_Area end) 
														and Glosa=((case when @Sem='' then CASE WHEN @IB_CtaVac=1 THEN @Cuenta ELSE @CuentaDifEmp END else @CuentaDifObr end)+CASE WHEN @P_IB_AGRUPAR_CUENTAS=0 THEN @Trabajador ELSE '' END + case when @IB_GAxCCF=1 then ' (F)' else ' (TD)' end) 
														and isnull(Cd_Trab, '')=(case when @Cd_TD is null then '' else @Cd_Trabajador end)))
												begin
													print 'update '''+@Cd_Concepto+'-'+(case when @Sem='' then CASE WHEN @IB_CtaVac=1 THEN @NroCta ELSE @NroCtaDifEmp END else @NroCtaDifObr end)+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, -@Importe)
													update Voucher set MtoH=(MtoH-@Importe), MtoH_ME=(MtoH_ME-(@Importe/@CamMda))/*, FecMdf=getdate(), UsuModf=@UsuCrea*/
													where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=(case when @Sem='' then CASE WHEN @IB_CtaVac=1 THEN @NroCta ELSE @NroCtaDifEmp END else @NroCtaDifObr end) and ISNULL(CodT,'')=''
													and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS --and isnull(Cd_Area, '')=(case when Cd_Area is null then '' else @Cd_Area end) 
													and Glosa=((case when @Sem='' then CASE WHEN @IB_CtaVac=1 THEN @Cuenta ELSE @CuentaDifEmp END else @CuentaDifObr end)+CASE WHEN @P_IB_AGRUPAR_CUENTAS=0 THEN @Trabajador ELSE '' END + case when @IB_GAxCCF=1 then ' (F)' else ' (TD)' end) and isnull(Cd_Trab, '')=(case when @Cd_TD is null then '' else @Cd_Trabajador end)
												end
											else
												begin
													print 'insert '''+@Cd_Concepto+'-'+(case when @Sem='' then CASE WHEN @IB_CtaVac=1 THEN @NroCta ELSE @NroCtaDifEmp END else @NroCtaDifObr end)+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, -@Importe)
													insert into Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																		MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																		FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,C_ID_CONCEPTO_FEC)
													values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte,   @FecMov, @FecCbr ,(case when @Sem='' then CASE WHEN @IB_CtaVac=1 THEN @NroCta ELSE @NroCtaDifEmp END else @NroCtaDifObr end),@Cd_TD,@NroSre,@NroDoc,@FecMov/*getdate()*/,((case when @Sem='' then CASE WHEN @IB_CtaVac=1 THEN @Cuenta ELSE @CuentaDifEmp END else @CuentaDifObr end)+CASE WHEN @P_IB_AGRUPAR_CUENTAS=0 THEN @Trabajador ELSE '' END + case when @IB_GAxCCF=1 then ' (F)' else ' (TD)' end),0.00,
															0.00,-@Importe,0.00,-(@Importe/@CamMda),'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',@IB_EsProv,
															getdate(),null,@UsuCrea,null,0,@Cd_Trabajador,CASE WHEN @P_IB_FEC=1 THEN @P_ID_CONCEPTO_FEC ELSE 0 END)
												end
										end
									else
										set @s += 'No existe la contrapartida de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
								end
						end

						print @s+char(13)+char(10)
						set @msj += @s
						set @s = ''
					end

					begin print '- Asiento Destino ' + case when @IB_GAxCCF=1 then '(F)' else '(TD)' end + ':'
						set @Cd_CC = (select Cd_CC from @TrabajadorXPorcCC where Cd_Trab=@Cd_Trab and IB_CCPrincipal=1)
						set @Cd_SC = (select Cd_SC from @TrabajadorXPorcCC where Cd_Trab=@Cd_Trab and IB_CCPrincipal=1)
						set @Cd_SS = (select Cd_SS from @TrabajadorXPorcCC where Cd_Trab=@Cd_Trab and IB_CCPrincipal=1)

						if(not exists (select * from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS))
							set @s += 'No existe el amarre de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
						else
							begin
								set @NroCta = isnull((select NroCta from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@cd_SS), '')
								SET @L_IB_DESAGRUPAR_DESTINOS = (SELECT ISNULL(C_IB_DESAGRUPAR_DESTINOS, 0) FROM PLANCTAS WHERE RUCE=@RucE AND EJER=@Ejer AND NROCTA=@NroCta)
								SET @IB_AMARRE_CUENTA_DESTINO_CENTRO_COSTO = (SELECT ISNULL(C_IB_CUENTA_DESTINO_CENTRO_COSTO, 0) FROM PLANCTAS WHERE RUCE=@RucE AND EJER=@Ejer AND NROCTA=@NroCta)

								declare
								@FactorRestaDestinoRegimenPensionario int = 1
								if exists (select top 1 * from RemuTrabHist rth
												inner join TipoRemu tr on tr.RucE=rth.RucE and tr.Cd_TipRemu=rth.Cd_TipRemu AND CASE WHEN @IC_TipoPlan='E' THEN tr.IB_PlnEmpl ELSE tr.IB_PlnObr END = 1
									where rth.RucE=@RucE and rth.Ejer=@Ejer and rth.Prdo=@Prdo and rth.Cd_Trab=@Cd_Trab and rth.Sem=@Sem and rth.Cd_TipRemu in (select distinct CodRoD from AmarreCtaCC where RucE=@RucE and NroCta=@NroCta and CodRoD like 'R%') and rth.Importe>0.00)
								
									set @FactorRestaDestinoRegimenPensionario = -1

								if(@NroCta<>'')
									begin
										if(@IB_AMARRE_CUENTA_DESTINO_CENTRO_COSTO=1)
											begin
												if((select TOP 1 isnull(C_NUMERO_CUENTA_DEBE, '') from CONTABILIDAD.T_AMARRE_CUENTA_CENTRO_COSTO_DESTINOS where C_RUC_EMPRESA  = @RucE and C_EJERCICIO  = @Ejer and CONCAT(C_CODIGO_CENTRO_COSTO,C_CODIGO_SUB_CENTRO_COSTO,C_CODIGO_SUB_SUB_CENTRO_COSTO)=@Cd_CC+@Cd_SC+@cd_SS)!='')
												begin
													set @k = (select COUNT(*) from CONTABILIDAD.T_AMARRE_CUENTA_CENTRO_COSTO_DESTINOS where C_RUC_EMPRESA  = @RucE and C_EJERCICIO  = @Ejer and CONCAT(C_CODIGO_CENTRO_COSTO,C_CODIGO_SUB_CENTRO_COSTO,C_CODIGO_SUB_SUB_CENTRO_COSTO)=@Cd_CC+@Cd_SC+@cd_SS)
													set @k_total = @k

													(select @CtaDs+=C_NUMERO_CUENTA_DEBE+',', @CtaHs+=C_NUMERO_CUENTA_HASTA+',', @PorcDs+=convert(varchar, C_PORCENTAJE)+',' from CONTABILIDAD.T_AMARRE_CUENTA_CENTRO_COSTO_DESTINOS where C_RUC_EMPRESA  = @RucE and C_EJERCICIO  = @Ejer and CONCAT(C_CODIGO_CENTRO_COSTO,C_CODIGO_SUB_CENTRO_COSTO,C_CODIGO_SUB_SUB_CENTRO_COSTO)=@Cd_CC+@Cd_SC+@cd_SS)
												
													while(@k>0)
															begin
																set @CtaD = substring(@CtaDs, 1, (charindex(',', @CtaDs)-1))
																set @CtaH = substring(@CtaHs, 1, (charindex(',', @CtaHs)-1))
																set @PorcD = substring(@PorcDs, 1, (charindex(',', @PorcDs)-1))

																begin /*Cuenta de Destino (Debe)*/
																	set @Cuenta = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@CtaD), '')
																	select 'A20', @Cd_Concepto, CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END, @CtaD, 'Debe'
																	IF(@L_IB_DESAGRUPAR_DESTINOS=0) /* AGRUPAR DESTINOS:EL DEBE VA TODO EN UNA LINEA */
																		BEGIN
																			if(exists (select * from Voucher where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@CtaD))
																				begin
																					print 'update '''+@CtaD+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END)))+' (Debe)'
																					update Voucher set MtoD=(MtoD+(CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END)),
																						MtoD_ME=(MtoD_ME+(CASE WHEN @k_total>1 AND @k=1 THEN @Importe/@CamMda-Convert(numeric(20,2),@Importe*(100-@PorcD)/100/@CamMda) ELSE @Importe*@PorcD/100/@CamMda END))/*, FecMdf=getdate(), UsuModf=@UsuCrea*/
																					where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@CtaD
																				end
																			else
																				begin
																					print 'insert '''+@CtaD+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END)))+' (Debe)'
																					insert into Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																										MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																										FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,IB_EsDes)
																					values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte,   @FecMov, @FecCbr ,@CtaD,null,null,null,@FecMov/*getdate()*/,@Cuenta+' (Destino)',0.00,
																							(CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END),0.00,(CASE WHEN @k_total>1 AND @k=1 THEN @Importe/@CamMda-Convert(numeric(20,2),@Importe*(100-@PorcD)/100/@CamMda) ELSE @Importe*@PorcD/100/@CamMda END),0.00,'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',0,
																							getdate(),null,@UsuCrea,null,0,null,1)
																				end
																		END
																	ELSE /* DESAGRUPAR DESTINOS: EL DEBE SE GENERA POR CADA LINEA */
																		BEGIN
																			print 'insert '''+@CtaD+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END)))+' (Debe)'
																			insert into Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																								MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																								FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,IB_EsDes)
																			values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte,   @FecMov, @FecCbr ,@CtaD,null,null,null,@FecMov/*getdate()*/,@Cuenta+' (Destino)',0.00,
																					(CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END),0.00,(CASE WHEN @k_total>1 AND @k=1 THEN @Importe/@CamMda-Convert(numeric(20,2),@Importe*(100-@PorcD)/100/@CamMda) ELSE @Importe*@PorcD/100/@CamMda END),0.00,'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',0,
																					getdate(),null,@UsuCrea,null,0,null,1)
																		END
																end
																begin /*Cuenta de Destino (Haber)*/
																	set @Cuenta = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@CtaH), '')
																	select 'A21', @Cd_Concepto, CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END, @CtaH, 'Haber'
																	if(exists (select * from Voucher where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@CtaH))
																		begin
																			print 'update '''+@CtaH+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END)))+' (Haber)'
																			update Voucher set MtoH=(MtoH+(CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END)), MtoH_ME=(MtoH_ME+(CASE WHEN @k_total>1 AND @k=1 THEN @Importe/@CamMda-Convert(numeric(20,2),@Importe*(100-@PorcD)/100/@CamMda) ELSE @Importe*@PorcD/100/@CamMda END))/*, FecMdf=getdate(), UsuModf=@UsuCrea*/
																			where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@CtaH
																		end
																	else
																		begin
																			print 'insert '''+@CtaH+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END)))+' (Haber)'
																			insert into Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																								MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																								FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,IB_EsDes)
																			values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte, @FecMov, @FecCbr,@CtaH,null,null,null,@FecMov/*getdate()*/,@Cuenta+' (Destino)',0.00,
																					0.00,(CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END),0.00,(CASE WHEN @k_total>1 AND @k=1 THEN @Importe/@CamMda-Convert(numeric(20,2),@Importe*(100-@PorcD)/100/@CamMda) ELSE @Importe*@PorcD/100/@CamMda END),'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',0,
																					getdate(),null,@UsuCrea,null,0,null,1)
																		end
																end

																set @CtaDs = substring(@CtaDs, (charindex(',',@CtaDs)+1), len(@CtaDs))
																set @CtaHs = substring(@CtaHs, (charindex(',',@CtaHs)+1), len(@CtaHs))
																set @PorcDs = substring(@PorcDs, (charindex(',',@PorcDs)+1), len(@PorcDs))
																set @k = (@k-1)
															end
													end
												else
													print 'El número de cuenta de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'| no tiene cuentas de destino'+char(13)+char(10)
											end
										else
											begin
												if((select isnull(IB_CtaD, 0) from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta)=1)
													begin											
														set @k = (select count(*) from AmarreCta where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta)
														set @k_total = @k

														(select @CtaDs+=CtaD+',', @CtaHs+=CtaH+',', @PorcDs+=convert(varchar, Porc)+',' from AmarreCta where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta)
										
														while(@k>0)
															begin
																set @CtaD = substring(@CtaDs, 1, (charindex(',', @CtaDs)-1))
																set @CtaH = substring(@CtaHs, 1, (charindex(',', @CtaHs)-1))
																set @PorcD = substring(@PorcDs, 1, (charindex(',', @PorcDs)-1))

																begin /*Cuenta de Destino (Debe)*/
																	set @Cuenta = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@CtaD), '')
																	select 'A22', @Cd_Concepto, CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END, @CtaD, 'Debe'
																	IF(@L_IB_DESAGRUPAR_DESTINOS=0) /* AGRUPAR DESTINOS:EL DEBE VA TODO EN UNA LINEA */
																		BEGIN
																			if(exists (select * from Voucher where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@CtaD))
																				begin
																					print 'update '''+@CtaD+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END)))+' (Debe)'
																					update Voucher set MtoD=(MtoD+((CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END)*@FactorRestaDestinoRegimenPensionario)),
																					MtoD_ME=(MtoD_ME+((CASE WHEN @k_total>1 AND @k=1 THEN @Importe/@CamMda-Convert(numeric(20,2),@Importe*(100-@PorcD)/100/@CamMda) ELSE @Importe*@PorcD/100/@CamMda END)*@FactorRestaDestinoRegimenPensionario))/*, FecMdf=getdate(), UsuModf=@UsuCrea*/
																					where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@CtaD
																				end
																			else
																				begin
																					print 'insert '''+@CtaD+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END)))+' (Debe)'
																					insert into Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																										MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																										FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,IB_EsDes)
																					values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte,   @FecMov, @FecCbr ,@CtaD,null,null,null,@FecMov/*getdate()*/,@Cuenta+' (Destino)',0.00,
																							(CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END),0.00,(CASE WHEN @k_total>1 AND @k=1 THEN @Importe/@CamMda-Convert(numeric(20,2),@Importe*(100-@PorcD)/100/@CamMda) ELSE @Importe*@PorcD/100/@CamMda END),0.00,'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',0,
																							getdate(),null,@UsuCrea,null,0,null,1)
																				end
																		END
																	ELSE /* DESAGRUPAR DESTINOS: EL DEBE SE GENERA POR CADA LINEA */
																		BEGIN
																			print 'insert '''+@CtaD+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END)))+' (Debe)'
																			insert into Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																								MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																								FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,IB_EsDes)
																			values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte,   @FecMov, @FecCbr ,@CtaD,null,null,null,@FecMov/*getdate()*/,@Cuenta+' (Destino)',0.00,
																					(CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END),0.00,(CASE WHEN @k_total>1 AND @k=1 THEN @Importe/@CamMda-Convert(numeric(20,2),@Importe*(100-@PorcD)/100/@CamMda) ELSE @Importe*@PorcD/100/@CamMda END),0.00,'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',0,
																					getdate(),null,@UsuCrea,null,0,null,1)
																		END
																end
																begin /*Cuenta de Destino (Haber)*/
																	set @Cuenta = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@CtaH), '')
																	select 'A23', @Cd_Concepto, CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END, @CtaD, 'Haber'
																	if(exists (select * from Voucher where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@CtaH))
																		begin
																			print 'update '''+@CtaH+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END)))+' (Haber)'
																			update Voucher set MtoH=(MtoH+((CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END)*@FactorRestaDestinoRegimenPensionario)),
																			MtoH_ME=(MtoH_ME+(((@Importe*@PorcD)/100)/@CamMda*@FactorRestaDestinoRegimenPensionario))/*, FecMdf=getdate(), UsuModf=@UsuCrea*/
																			where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@CtaH
																		end
																	else
																		begin
																			print 'insert '''+@CtaH+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END)))+' (Haber)'
																			insert into Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																								MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																								FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,IB_EsDes)
																			values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte,   @FecMov, @FecCbr ,@CtaH,null,null,null,@FecMov/*getdate()*/,@Cuenta+' (Destino)',0.00,
																					0.00,(CASE WHEN @k_total>1 AND @k=1 THEN @Importe-Convert(numeric(20,2),@Importe*(100-@PorcD)/100) ELSE @Importe*@PorcD/100 END),0.00,(CASE WHEN @k_total>1 AND @k=1 THEN @Importe/@CamMda-Convert(numeric(20,2),@Importe*(100-@PorcD)/100/@CamMda) ELSE @Importe*@PorcD/100/@CamMda END),'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',0,
																					getdate(),null,@UsuCrea,null,0,null,1)
																		end
																end

																set @CtaDs = substring(@CtaDs, (charindex(',',@CtaDs)+1), len(@CtaDs))
																set @CtaHs = substring(@CtaHs, (charindex(',',@CtaHs)+1), len(@CtaHs))
																set @PorcDs = substring(@PorcDs, (charindex(',',@PorcDs)+1), len(@PorcDs))
																set @k = (@k-1)
															end
													end
												else
													print 'El número de cuenta de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'| no tiene cuentas de destino'+char(13)+char(10)
											end
									end
								else
									set @s += 'No existe el numero de cuenta de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
							end

						print @s+char(13)+char(10)
						set @msj += @s
						set @s = ''
					end

					set @Cd_Conceptos = substring(@Cd_Conceptos, (charindex(',',@Cd_Conceptos)+1), len(@Cd_Conceptos))
					set @Importes = substring(@Importes, (charindex(',',@Importes)+1), len(@Importes))
					set @i = (@i-1)
				end
			print '/*********************************/'+char(13)+char(10)+char(13)+char(10)
		end
	
		begin print '/*ASIENTOS DE LIQUIDACIÓN*/'+char(13)+char(10)+char(13)+char(10)
			set @i = (select count(*) from LiquidacionXTrab lxt
						where lxt.RucE=@RucE and lxt.Ejer=@Ejer and lxt.Prdo=@Prdo and lxt.Sem=@Sem and lxt.Cd_Trab=@Cd_Trab and lxt.Importe<>0)
		
			declare @ImpRegPen numeric(13,5) = 0.00
			declare @ImpOtroDscto numeric(13,5) = 0.00
			set @Cd_Conceptos = ''
			set @Importes = ''
			
			--set @ImpRegPen=ISNULL((select ISNULL(SUM(ImporteLiq),0.00) from RegimenDetTrabHist where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and ISNULL(Sem,'')=ISNULL(@Sem,'') and Cd_Trab=@Cd_Trab and ImporteLiq>0),0.00)
			set @ImpRegPen=0.00 --Jhan pidió que ya no se sume el AFP
			--Jhan pidió que solo sume a las vacaciones en el Debe :s
			set @ImpRegPen = ISNULL((select lxt.Importe from LiquidacionXTrab lxt
									 where lxt.RucE=@RucE and lxt.Ejer=@Ejer and lxt.Prdo=@Prdo and lxt.Sem=@Sem and lxt.Cd_Trab=@Cd_Trab and (lxt.Cd_TipLiq in ('L12','L13','L14','L15') or lxt.Cd_TipLiq in ('L06','L07')) and lxt.Importe<>0), 0.00)
			set @ImpOtroDscto = ISNULL((select lxt.Importe from LiquidacionXTrab lxt
									where lxt.RucE=@RucE and lxt.Ejer=@Ejer and lxt.Prdo=@Prdo and lxt.Sem=@Sem and lxt.Cd_Trab=@Cd_Trab and lxt.Cd_TipLiq='L05' and lxt.Importe<>0),0.00)
									
			(select @Cd_Conceptos+=lxt.Cd_TipLiq+',', @Importes+=convert(varchar, lxt.Importe)+',' from LiquidacionXTrab lxt
				where lxt.RucE=@RucE and lxt.Ejer=@Ejer and lxt.Prdo=@Prdo and lxt.Sem=@Sem and lxt.Cd_Trab=@Cd_Trab and lxt.Importe<>0)
					
			while(@i>0)
				begin
					set @Cd_Concepto = substring(@Cd_Conceptos, 1, (charindex(',', @Cd_Conceptos)-1))
					set @Importe = substring(@Importes, 1, (charindex(',', @Importes)-1))
					if( @Cd_Concepto not in ('L05','L06','L07','L12','L13','L14','L15'))
					begin print '- Asiento Debe ' + case when @IB_GAxCCF=1 then ' (F)' else ' (TD)' end + ':'
						begin /*Desgloce por Centro de Costo Principal*/
							set @Cd_CC = (select Cd_CC from @TrabajadorXPorcCC where Cd_Trab=@Cd_Trab and IB_CCPrincipal=1)
							set @Cd_SC = (select Cd_SC from @TrabajadorXPorcCC where Cd_Trab=@Cd_Trab and IB_CCPrincipal=1)
							set @Cd_SS = (select Cd_SS from @TrabajadorXPorcCC where Cd_Trab=@Cd_Trab and IB_CCPrincipal=1)

							if(not exists (select * from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS))
								begin
									set @s = ''
									set @s += 'No existe el amarre de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
								end
							else
								begin
									set @NroCta = isnull((select NroCta from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS), '')
									set @Cuenta = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta), '')
									set @P_IB_FEC = ISNULL((select CASE WHEN @P_IB_HABILITAR_CONCEPTOS_FLUJO_EFECTIVO_CONTABLE=1 THEN CASE WHEN ISNULL(IB_CtasXCbr,0)=1 or ISNULL(IB_CtasXPag,0)=1 THEN 1 ELSE 0 END ELSE 0 END from PlanCtas where RucE=@RucE and NroCta=@NroCta and Ejer=@Ejer),0)

									if(@NroCta<>'')
										begin
											if((select isnull(C_IB_AUXILIAR_TRABAJADOR, 0) from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta)=1)
												begin
													set @Cd_Trabajador = @Cd_Trab
												end
											else
												begin
													set @Cd_Trabajador = null
												end
											if(ISNULL((select isnull(IB_NDoc, 0) from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta),0) = 1)
													begin
														set @Cd_TD = (select Cd_TD_AsientosPlanillon from CfgPlanilla where RucE=@RucE)
														select @NroSre=NroSre from dbo.fn_NroDocTrabajador(@RucE,@Cd_TD,@Cd_Trab)
														SET @NroDoc = @Ejer + @Prdo + SUBSTRING(@Cd_Trab,2,7)
														SET @IB_EsProv = 1
													end
												else
													begin
														set @Cd_TD = null
														SET @NroSre=null
														SET @NroDoc = null
														SET @IB_EsProv = 0
													end
											
											select 'A24', @Cd_Concepto, @Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END, @NroCta, 'Debe'
											print 'insert '''+@Cd_Concepto+'-'+@NroCta+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'| '+convert(varchar, @Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)+' (@IB_CDxPCC='+convert(varchar, @IB_CDxPCC)+')'
											insert into Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,C_ID_CONCEPTO_FEC)
											values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte,   @FecMov, @FecCbr ,@NroCta,@Cd_TD,@NroSre,@NroDoc,@FecMov/*getdate()*/,(@Cuenta+CASE WHEN @P_IB_AGRUPAR_CUENTAS=0 THEN @Trabajador ELSE '' END + case when @IB_GAxCCF=1 then ' (F)' else ' (TD)' end),0.00,
													@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END,0.00,((@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)/@CamMda),0.00,'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',@IB_EsProv,
													getdate(),null,@UsuCrea,null,0,@Cd_Trabajador,CASE WHEN @P_IB_FEC=1 THEN @P_ID_CONCEPTO_FEC ELSE 0 END)
										end
									else
										set @s += 'No existe el numero de cuenta de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
								end
						end

						print @s+char(13)+char(10)
						set @msj += @s
						set @s = ''
					end
					begin print '- Asiento Haber ' + case when @IB_GAxCCF=1 then '(F)' else '(TD)' end + ':'
						set @Cd_CC = (select Cd_CC from @TrabajadorXPorcCC where Cd_Trab=@Cd_Trab and IB_CCPrincipal=1)
						set @Cd_SC = (select Cd_SC from @TrabajadorXPorcCC where Cd_Trab=@Cd_Trab and IB_CCPrincipal=1)
						set @Cd_SS = (select Cd_SS from @TrabajadorXPorcCC where Cd_Trab=@Cd_Trab and IB_CCPrincipal=1)
								
						if(not exists (select * from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS))
							set @s += 'No existe el amarre de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
						else
							begin
							if(@Cd_Concepto in ('L05','L06','L07','L12','L13','L14','L15'))
								set @NroCta = isnull((select NroCta from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS and ISNULL(Contrapartida_Obr,'')= case when @IC_TipoPlan='E' then '' else ISNULL(Contrapartida_Obr,'') end), '')
							else
								set @NroCta = isnull((select (case when @Sem='' then Contrapartida else Contrapartida_Obr end) from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS), '')
							set @Cuenta = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta), '')
							set @P_IB_FEC = ISNULL((select CASE WHEN @P_IB_HABILITAR_CONCEPTOS_FLUJO_EFECTIVO_CONTABLE=1 THEN CASE WHEN ISNULL(IB_CtasXCbr,0)=1 or ISNULL(IB_CtasXPag,0)=1 THEN 1 ELSE 0 END ELSE 0 END from PlanCtas where RucE=@RucE and NroCta=@NroCta and Ejer=@Ejer),0)

								if(@NroCta<>'')
									begin /*Sumar Monto al Número de Cuenta de Haber*/
										if((select isnull(C_IB_AUXILIAR_TRABAJADOR, 0) from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta)=1)
											begin
												set @Cd_Trabajador = @Cd_Trab
											end
										else
											begin
												set @Cd_Trabajador = null
											end
										if(ISNULL((select isnull(IB_NDoc, 0) from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta),0) = 1)
											begin
												set @Cd_TD = (select Cd_TD_AsientosPlanillon from CfgPlanilla where RucE=@RucE)
												select @NroSre=NroSre from dbo.fn_NroDocTrabajador(@RucE,@Cd_TD,@Cd_Trab)
												SET @NroDoc = @Ejer + @Prdo + SUBSTRING(@Cd_Trab,2,7)
												SET @IB_EsProv = 1
											end
										else
											begin
												set @Cd_TD = null
												SET @NroSre=null
												SET @NroDoc = null
												SET @IB_EsProv = 0
											end
									
										select 'A25', @Cd_Concepto, @Importe-CASE WHEN @Cd_Concepto='L01' THEN @ImpOtroDscto ELSE 0.00 END, @NroCta, 'Haber'
										if(exists (select * from Voucher where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@NroCta and
													Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS --and isnull(Cd_Area, '')=(case when Cd_Area is null then '' else @Cd_Area end) 
													and Glosa=(@Cuenta+CASE WHEN @P_IB_AGRUPAR_CUENTAS=0 THEN @Trabajador ELSE '' END + case when @IB_GAxCCF=1 then ' (F)' else ' (TD)' end) and isnull(Cd_Trab, '')=(case when @Cd_TD is null then '' else @Cd_Trabajador end)))
											begin
												print 'update '''+@Cd_Concepto+'-'+@NroCta+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, @Importe)
												update top (1) Voucher set MtoH=(MtoH+@Importe-CASE WHEN @Cd_Concepto='L01' THEN @ImpOtroDscto ELSE 0.00 END), MtoH_ME=(MtoH_ME+((@Importe-CASE WHEN @Cd_Concepto='L01' THEN @ImpOtroDscto ELSE 0.00 END)/@CamMda))/*, FecMdf=getdate(), UsuModf=@UsuCrea*/
												where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@NroCta and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS --and isnull(Cd_Area, '')=(case when Cd_Area is null then '' else @Cd_Area end) 
												and Glosa=(@Cuenta+CASE WHEN @P_IB_AGRUPAR_CUENTAS=0 THEN @Trabajador ELSE '' END + case when @IB_GAxCCF=1 then ' (F)' else ' (TD)' end) and isnull(Cd_Trab, '')=(case when @Cd_TD is null then '' else @Cd_Trabajador end)
											end
										else
											begin
												print 'insert '''+@Cd_Concepto+'-'+@NroCta+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, @Importe)
												insert into Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																	MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																	FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,C_ID_CONCEPTO_FEC)
												values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte,   @FecMov, @FecCbr ,@NroCta,@Cd_TD,@NroSre,@NroDoc,@FecMov/*getdate()*/,(@Cuenta+CASE WHEN @P_IB_AGRUPAR_CUENTAS=0 THEN @Trabajador ELSE '' END + case when @IB_GAxCCF=1 then ' (F)' else ' (TD)' end),0.00,
														0.00,@Importe-CASE WHEN @Cd_Concepto='L01' THEN @ImpOtroDscto ELSE 0.00 END,0.00,((@Importe-CASE WHEN @Cd_Concepto='L01' THEN @ImpOtroDscto ELSE 0.00 END)/@CamMda),'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',@IB_EsProv,
														getdate(),null,@UsuCrea,null,0,@Cd_Trabajador,CASE WHEN @P_IB_FEC=1 THEN @P_ID_CONCEPTO_FEC ELSE 0 END)
											end
									end
								else
									begin
										if not exists(select @Cd_Concepto where @Cd_Concepto in ('L05','L06','L12','L13','L14','L15'))
											set @s += 'No existe la contrapartida de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
									end
							end

						print @s+char(13)+char(10)
						set @msj += @s
						set @s = ''
					end
					begin print '- Asiento Destino ' + case when @IB_GAxCCF=1 then '(F)' else '(TD)' end + ':'
						set @Cd_CC = (select Cd_CC from @TrabajadorXPorcCC where Cd_Trab=@Cd_Trab and IB_CCPrincipal=1)
						set @Cd_SC = (select Cd_SC from @TrabajadorXPorcCC where Cd_Trab=@Cd_Trab and IB_CCPrincipal=1)
						set @Cd_SS = (select Cd_SS from @TrabajadorXPorcCC where Cd_Trab=@Cd_Trab and IB_CCPrincipal=1)

						if(not exists (select * from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS))
							set @s += 'No existe el amarre de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
						else
							begin
								set @NroCta = isnull((select NroCta from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@cd_SS), '')
								SET @L_IB_DESAGRUPAR_DESTINOS = (SELECT ISNULL(C_IB_DESAGRUPAR_DESTINOS, 0) FROM PLANCTAS WHERE RUCE=@RucE AND EJER=@Ejer AND NROCTA=@NroCta)
								SET @IB_AMARRE_CUENTA_DESTINO_CENTRO_COSTO = (SELECT ISNULL(C_IB_CUENTA_DESTINO_CENTRO_COSTO, 0) FROM PLANCTAS WHERE RUCE=@RucE AND EJER=@Ejer AND NROCTA=@NroCta)
							
								if(@NroCta<>'')
									begin
										if(@IB_AMARRE_CUENTA_DESTINO_CENTRO_COSTO=1)
											begin
												if((select TOP 1 isnull(C_NUMERO_CUENTA_DEBE, '') from CONTABILIDAD.T_AMARRE_CUENTA_CENTRO_COSTO_DESTINOS where C_RUC_EMPRESA  = @RucE and C_EJERCICIO  = @Ejer and CONCAT(C_CODIGO_CENTRO_COSTO,C_CODIGO_SUB_CENTRO_COSTO,C_CODIGO_SUB_SUB_CENTRO_COSTO)=@Cd_CC+@Cd_SC+@cd_SS)!='')
												begin
													set @k = (select COUNT(*) from CONTABILIDAD.T_AMARRE_CUENTA_CENTRO_COSTO_DESTINOS where C_RUC_EMPRESA  = @RucE and C_EJERCICIO  = @Ejer and CONCAT(C_CODIGO_CENTRO_COSTO,C_CODIGO_SUB_CENTRO_COSTO,C_CODIGO_SUB_SUB_CENTRO_COSTO)=@Cd_CC+@Cd_SC+@cd_SS)
													set @k_total = @k

													(select @CtaDs+=C_NUMERO_CUENTA_DEBE+',', @CtaHs+=C_NUMERO_CUENTA_HASTA+',', @PorcDs+=convert(varchar, C_PORCENTAJE)+',' from CONTABILIDAD.T_AMARRE_CUENTA_CENTRO_COSTO_DESTINOS where C_RUC_EMPRESA  = @RucE and C_EJERCICIO  = @Ejer and CONCAT(C_CODIGO_CENTRO_COSTO,C_CODIGO_SUB_CENTRO_COSTO,C_CODIGO_SUB_SUB_CENTRO_COSTO)=@Cd_CC+@Cd_SC+@cd_SS)
												
													while(@k>0)
															begin
																set @CtaD = substring(@CtaDs, 1, (charindex(',', @CtaDs)-1))
																set @CtaH = substring(@CtaHs, 1, (charindex(',', @CtaHs)-1))
																set @PorcD = substring(@PorcDs, 1, (charindex(',', @PorcDs)-1))
															
																begin /*Cuenta de Destino (Debe)*/
																	set @Cuenta = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@CtaD), '')
																	select 'A26', @Cd_Concepto, (CASE WHEN @k_total>1 AND @k=1 THEN (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)-Convert(numeric(20,2),(@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*(100-@PorcD)/100) ELSE (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*@PorcD/100 END), @CtaD, 'Debe'
																	IF(@L_IB_DESAGRUPAR_DESTINOS=0) /* AGRUPAR DESTINOS:EL DEBE VA TODO EN UNA LINEA */
																		BEGIN
																			IF(exists (SELECT * FROM Voucher WHERE RucE=@RucE AND Ejer=@Ejer AND Prdo=@Prdo AND RegCtb=@RegCtb AND NroCta=@CtaD and CodT=CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END))
																				BEGIN
																					PRINT 'update '''+@CtaD+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+CONVERT(VARCHAR, CONVERT(NUMERIC(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)-Convert(numeric(20,2),(@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*(100-@PorcD)/100) ELSE (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*@PorcD/100 END)))+' (Debe-Agrupar)'
																					UPDATE Voucher SET MtoD=(MtoD+(CASE WHEN @k_total>1 AND @k=1 THEN (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)-Convert(numeric(20,2),(@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*(100-@PorcD)/100) ELSE (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*@PorcD/100 END)),
																					MtoD_ME=(MtoD_ME+(CASE WHEN @k_total>1 AND @k=1 THEN (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)/@CamMda-Convert(numeric(20,2),(@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*(100-@PorcD)/100/@CamMda) ELSE (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*@PorcD/100/@CamMda END))/*, FecMdf=GETDATE(), UsuModf=@UsuCrea*/
																					WHERE RucE=@RucE AND Ejer=@Ejer AND Prdo=@Prdo AND RegCtb=@RegCtb AND NroCta=@CtaD and CodT=CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END
																				end
																			ELSE
																				BEGIN
																					PRINT 'insert '''+@CtaD+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+CONVERT(VARCHAR, CONVERT(NUMERIC(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)-Convert(numeric(20,2),(@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*(100-@PorcD)/100) ELSE (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*@PorcD/100 END)))+' (Debe-Agrupar)'
																					INSERT INTO Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																										MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																										FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,IB_EsDes,CodT)
																					VALUES(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte,   @FecMov, @FecCbr ,@CtaD,NULL,NULL,NULL,@FecMov/*getdate()*/,@Cuenta+' (Destino)',0.00,
																							(CASE WHEN @k_total>1 AND @k=1 THEN (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)-Convert(numeric(20,2),(@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*(100-@PorcD)/100) ELSE (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*@PorcD/100 END),0.00,
																							(CASE WHEN @k_total>1 AND @k=1 THEN (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)/@CamMda-Convert(numeric(20,2),(@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*(100-@PorcD)/100/@CamMda) ELSE (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*@PorcD/100/@CamMda END),0.00,'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',0,
																							GETDATE(),NULL,@UsuCrea,NULL,0,NULL,1,CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END)
																				END
																		END
																	ELSE /* DESAGRUPAR DESTINOS: EL DEBE SE GENERA POR CADA LINEA */
																		BEGIN
																			PRINT 'insert '''+@CtaD+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+CONVERT(VARCHAR, CONVERT(NUMERIC(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)-Convert(numeric(20,2),(@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*(100-@PorcD)/100) ELSE (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*@PorcD/100 END)))+' (Debe-Desagrupar)'
																			INSERT INTO Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																								MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																								FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,IB_EsDes)
																			VALUES(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte,   @FecMov, @FecCbr ,@CtaD,NULL,NULL,NULL,@FecMov/*getdate()*/,@Cuenta+' (Destino)',0.00,
																					(CASE WHEN @k_total>1 AND @k=1 THEN (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)-Convert(numeric(20,2),(@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*(100-@PorcD)/100) ELSE (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*@PorcD/100 END),0.00,
																					(CASE WHEN @k_total>1 AND @k=1 THEN (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)/@CamMda-Convert(numeric(20,2),(@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*(100-@PorcD)/100/@CamMda) ELSE (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*@PorcD/100/@CamMda END),0.00,'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',0,
																					GETDATE(),NULL,@UsuCrea,NULL,0,NULL,1)
																		END
																end
																begin /*Cuenta de Destino (Haber)*/
																	set @Cuenta = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@CtaH), '')
																select 'A27', @Cd_Concepto, (CASE WHEN @k_total>1 AND @k=1 THEN (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)-Convert(numeric(20,2),(@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*(100-@PorcD)/100) ELSE (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*@PorcD/100 END), @CtaH, 'Haber'
																	if(exists (select * from Voucher where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@CtaH and CodT=CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END))
																		begin
																			print 'update '''+@CtaH+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)-Convert(numeric(20,2),(@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*(100-@PorcD)/100) ELSE (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*@PorcD/100 END)))+' (Haber)'
																			update Voucher set MtoH=(MtoH+(CASE WHEN @k_total>1 AND @k=1 THEN (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)-Convert(numeric(20,2),(@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*(100-@PorcD)/100) ELSE (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*@PorcD/100 END)), 
																			MtoH_ME=(MtoH_ME+(CASE WHEN @k_total>1 AND @k=1 THEN (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)/@CamMda-Convert(numeric(20,2),(@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*(100-@PorcD)/100/@CamMda) ELSE (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*@PorcD/100/@CamMda END))/*, FecMdf=getdate(), UsuModf=@UsuCrea*/
																			where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@CtaH and CodT=CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END
																		end
																	else
																		begin
																			print 'insert '''+@CtaH+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)-Convert(numeric(20,2),(@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*(100-@PorcD)/100) ELSE (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*@PorcD/100 END)))+' (Haber)'
																			insert into Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																								MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																								FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,IB_EsDes,CodT)
																			values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte,   @FecMov, @FecCbr ,@CtaH,null,null,null,@FecMov/*getdate()*/,@Cuenta+' (Destino)',0.00,
																					0.00,(CASE WHEN @k_total>1 AND @k=1 THEN (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)-Convert(numeric(20,2),(@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*(100-@PorcD)/100) ELSE (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*@PorcD/100 END),0.00,
																					(CASE WHEN @k_total>1 AND @k=1 THEN (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)/@CamMda-Convert(numeric(20,2),(@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*(100-@PorcD)/100/@CamMda) ELSE (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*@PorcD/100/@CamMda END),'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',0,
																					getdate(),null,@UsuCrea,null,0,null,1,CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END)
																		end
																end

																set @CtaDs = substring(@CtaDs, (charindex(',',@CtaDs)+1), len(@CtaDs))
																set @CtaHs = substring(@CtaHs, (charindex(',',@CtaHs)+1), len(@CtaHs))
																set @PorcDs = substring(@PorcDs, (charindex(',',@PorcDs)+1), len(@PorcDs))
																set @k = (@k-1)
															end
													end
												else
													print 'El número de cuenta de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'| no tiene cuentas de destino'+char(13)+char(10)
											end
										else
											begin
												if((select isnull(IB_CtaD, 0) from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta)=1)
													begin											
														set @k = (select count(*) from AmarreCta where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta)
														set @k_total = @k

														(select @CtaDs+=CtaD+',', @CtaHs+=CtaH+',', @PorcDs+=convert(varchar, Porc)+',' from AmarreCta where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta)
										
														while(@k>0)
															begin
																set @CtaD = substring(@CtaDs, 1, (charindex(',', @CtaDs)-1))
																set @CtaH = substring(@CtaHs, 1, (charindex(',', @CtaHs)-1))
																set @PorcD = substring(@PorcDs, 1, (charindex(',', @PorcDs)-1))
															
																begin /*Cuenta de Destino (Debe)*/
																	set @Cuenta = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@CtaD), '')
																	select 'A28', @Cd_Concepto, (CASE WHEN @k_total>1 AND @k=1 THEN (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)-Convert(numeric(20,2),(@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*(100-@PorcD)/100) ELSE (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*@PorcD/100 END), @CtaD, 'Debe'
																	IF(@L_IB_DESAGRUPAR_DESTINOS=0) /* AGRUPAR DESTINOS:EL DEBE VA TODO EN UNA LINEA */
																		BEGIN
																			IF(exists (SELECT * FROM Voucher WHERE RucE=@RucE AND Ejer=@Ejer AND Prdo=@Prdo AND RegCtb=@RegCtb AND NroCta=@CtaD))
																				BEGIN
																					PRINT 'update '''+@CtaD+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+CONVERT(VARCHAR, CONVERT(NUMERIC(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)-Convert(numeric(20,2),(@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*(100-@PorcD)/100) ELSE (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*@PorcD/100 END)))+' (Debe-Agrupar)'
																					UPDATE Voucher SET MtoD=(MtoD+(CASE WHEN @k_total>1 AND @k=1 THEN (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)-Convert(numeric(20,2),(@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*(100-@PorcD)/100) ELSE (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*@PorcD/100 END)),
																					MtoD_ME=(MtoD_ME+(CASE WHEN @k_total>1 AND @k=1 THEN (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)/@CamMda-Convert(numeric(20,2),(@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*(100-@PorcD)/100/@CamMda) ELSE (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*@PorcD/100/@CamMda END))/*, FecMdf=GETDATE(), UsuModf=@UsuCrea*/
																					WHERE RucE=@RucE AND Ejer=@Ejer AND Prdo=@Prdo AND RegCtb=@RegCtb AND NroCta=@CtaD
																				end
																			ELSE
																				BEGIN
																					PRINT 'insert '''+@CtaD+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+CONVERT(VARCHAR, CONVERT(NUMERIC(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)-Convert(numeric(20,2),(@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*(100-@PorcD)/100) ELSE (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*@PorcD/100 END)))+' (Debe-Agrupar)'
																					INSERT INTO Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																										MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																										FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,IB_EsDes)
																					VALUES(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte,   @FecMov, @FecCbr ,@CtaD,NULL,NULL,NULL,@FecMov/*getdate()*/,@Cuenta+' (Destino)',0.00,
																							(CASE WHEN @k_total>1 AND @k=1 THEN (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)-Convert(numeric(20,2),(@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*(100-@PorcD)/100) ELSE (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*@PorcD/100 END),0.00,
																							(CASE WHEN @k_total>1 AND @k=1 THEN (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)/@CamMda-Convert(numeric(20,2),(@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*(100-@PorcD)/100/@CamMda) ELSE (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*@PorcD/100/@CamMda END),0.00,'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',0,
																							GETDATE(),NULL,@UsuCrea,NULL,0,NULL,1)
																				END
																		END
																	ELSE /* DESAGRUPAR DESTINOS: EL DEBE SE GENERA POR CADA LINEA */
																		BEGIN
																			PRINT 'insert '''+@CtaD+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+CONVERT(VARCHAR, CONVERT(NUMERIC(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)-Convert(numeric(20,2),(@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*(100-@PorcD)/100) ELSE (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*@PorcD/100 END)))+' (Debe-Desagrupar)'
																			INSERT INTO Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																								MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																								FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,IB_EsDes)
																			VALUES(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte,   @FecMov, @FecCbr ,@CtaD,NULL,NULL,NULL,@FecMov/*getdate()*/,@Cuenta+' (Destino)',0.00,
																					(CASE WHEN @k_total>1 AND @k=1 THEN (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)-Convert(numeric(20,2),(@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*(100-@PorcD)/100) ELSE (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*@PorcD/100 END),0.00,
																					(CASE WHEN @k_total>1 AND @k=1 THEN (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)/@CamMda-Convert(numeric(20,2),(@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*(100-@PorcD)/100/@CamMda) ELSE (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*@PorcD/100/@CamMda END),0.00,'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',0,
																					GETDATE(),NULL,@UsuCrea,NULL,0,NULL,1)
																		END
																end
																begin /*Cuenta de Destino (Haber)*/
																	set @Cuenta = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@CtaH), '')
																select 'A29', @Cd_Concepto, (CASE WHEN @k_total>1 AND @k=1 THEN (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)-Convert(numeric(20,2),(@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*(100-@PorcD)/100) ELSE (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*@PorcD/100 END), @CtaH, 'Haber'
																	if(exists (select * from Voucher where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@CtaH))
																		begin
																			print 'update '''+@CtaH+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)-Convert(numeric(20,2),(@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*(100-@PorcD)/100) ELSE (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*@PorcD/100 END)))+' (Haber)'
																			update Voucher set MtoH=(MtoH+(CASE WHEN @k_total>1 AND @k=1 THEN (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)-Convert(numeric(20,2),(@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*(100-@PorcD)/100) ELSE (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*@PorcD/100 END)),
																			MtoH_ME=(MtoH_ME+(CASE WHEN @k_total>1 AND @k=1 THEN (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)/@CamMda-Convert(numeric(20,2),(@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*(100-@PorcD)/100/@CamMda) ELSE (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*@PorcD/100/@CamMda END))/*, FecMdf=getdate(), UsuModf=@UsuCrea*/
																			where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@CtaH
																		end
																	else
																		begin
																			print 'insert '''+@CtaH+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)-Convert(numeric(20,2),(@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*(100-@PorcD)/100) ELSE (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*@PorcD/100 END)))+' (Haber)'
																			insert into Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																								MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																								FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,IB_EsDes)
																			values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte,   @FecMov, @FecCbr ,@CtaH,null,null,null,@FecMov/*getdate()*/,@Cuenta+' (Destino)',0.00,
																					0.00,(CASE WHEN @k_total>1 AND @k=1 THEN (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)-Convert(numeric(20,2),(@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*(100-@PorcD)/100) ELSE (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*@PorcD/100 END),0.00,
																					(CASE WHEN @k_total>1 AND @k=1 THEN (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)/@CamMda-Convert(numeric(20,2),(@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*(100-@PorcD)/100/@CamMda) ELSE (@Importe+CASE WHEN @Cd_Concepto='L03' THEN @ImpRegPen ELSE 0.00 END)*@PorcD/100/@CamMda END),'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',0,
																					getdate(),null,@UsuCrea,null,0,null,1)
																		end
																end

																set @CtaDs = substring(@CtaDs, (charindex(',',@CtaDs)+1), len(@CtaDs))
																set @CtaHs = substring(@CtaHs, (charindex(',',@CtaHs)+1), len(@CtaHs))
																set @PorcDs = substring(@PorcDs, (charindex(',',@PorcDs)+1), len(@PorcDs))
																set @k = (@k-1)
															end
													end
												else
													print 'El número de cuenta de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'| no tiene cuentas de destino'+char(13)+char(10)
											end
									end
								else
									set @s += 'No existe el numero de cuenta de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
							end

						print @s+char(13)+char(10)
						set @msj += @s
						set @s = ''
					end

					set @Cd_Conceptos = substring(@Cd_Conceptos, (charindex(',',@Cd_Conceptos)+1), len(@Cd_Conceptos))
					set @Importes = substring(@Importes, (charindex(',',@Importes)+1), len(@Importes))
					set @i = (@i-1)
				end
			print '/*************************/'+char(13)+char(10)+char(13)+char(10)
		end
	
		begin print '/*ASIENTOS DE CTS*/'+char(13)+char(10)+char(13)+char(10)
		if(@Cd_ModContrato='00')/*PRACTICANTES Y PART-TIME NO TIENEN CTS*/
		begin
		if(@IC_TipoPlan='E' AND ISNULL((select top 1 IB_PlnEmpl from TipoRemu where RucE=@RucE and Cd_TipRemu ='R94'),0)=1)
			begin
				set @i = (select count(1) from ctsSemestral _cts
								left join CTSImp ctsimp on ctsimp.RucE=_cts.RucE and ctsimp.Ejer=_cts.Ejer and ctsimp.Prdo=_cts.Prdo and ctsimp.Cd_Trab=_cts.Cd_Trab and ctsimp.Importe>0.00
							where _cts.RucE=@RucE and _cts.Ejer=@Ejer and _cts.Prdo=@Prdo and _cts.Sem=@Sem and _cts.Cd_Trab=@Cd_Trab and _cts.Importe<>0)
		
				set @Cd_Conceptos = ''
				set @Importes = ''
					
				select
					@Cd_Conceptos+='CTS'+',',
					@Importes+=convert(varchar,(case when ISNULL(ctsimp.Importe,0)>0 then CONVERT(decimal(13,5),ctsimp.Importe/360*ctsimp.DiasServ) else ISNULL(_cts.Importe, 0.00) end))+','
				from
					CTSSemestral _cts
					left join CTSImp ctsimp on ctsimp.RucE=_cts.RucE and ctsimp.Ejer=_cts.Ejer and ctsimp.Prdo=_cts.Prdo and ctsimp.Cd_Trab=_cts.Cd_Trab and ctsimp.Importe>0.00
				where
					_cts.RucE=@RucE
					and _cts.Ejer=@Ejer
					and _cts.Prdo=@Prdo
					and _cts.Sem=@Sem
					and _cts.Cd_Trab=@Cd_Trab
					and _cts.Importe<>0
			end
		else if(@IC_TipoPlan='O' AND ISNULL((select top 1 IB_PlnObr from TipoRemu where RucE=@RucE and Cd_TipRemu ='R94'),0)=1)
			begin
				set @i = (select Count(*) from (
											select RucE,Ejer,Prdo,Sem,Cd_Trab from ctsSemestral _cts
													where _cts.RucE=@RucE and _cts.Ejer=@Ejer and _cts.Prdo=@Prdo and _cts.Sem=@Sem and _cts.Cd_Trab=@Cd_Trab and _cts.Importe<>0
											union all
											select RucE,Ejer,Prdo,Sem,Cd_Trab from CTS _cts
													where _cts.RucE=@RucE and _cts.Ejer=@Ejer and _cts.Prdo=@Prdo and _cts.Sem=@Sem and _cts.Cd_Trab=@Cd_Trab and _cts.Importe<>0
												)cts
							)
				set @Cd_Conceptos = ''
				set @Importes = ''
					
				(select @Cd_Conceptos+='CTS'+',', @Importes+=convert(varchar, _cts.Importe)+','	
					from (
						select RucE,Ejer,Prdo,Sem,Cd_Trab,Importe from ctsSemestral _cts
								where _cts.RucE=@RucE and _cts.Ejer=@Ejer and _cts.Prdo=@Prdo and _cts.Sem=@Sem and _cts.Cd_Trab=@Cd_Trab and _cts.Importe<>0
						union all
						select RucE,Ejer,Prdo,Sem,Cd_Trab,Importe from CTS _cts
								where _cts.RucE=@RucE and _cts.Ejer=@Ejer and _cts.Prdo=@Prdo and _cts.Sem=@Sem and _cts.Cd_Trab=@Cd_Trab and _cts.Importe<>0
						)_cts
				)
			end
					
			while(@i>0)
				begin
					set @Cd_Concepto = substring(@Cd_Conceptos, 1, (charindex(',', @Cd_Conceptos)-1))
					set @Importe = substring(@Importes, 1, (charindex(',', @Importes)-1))
							
					set @j = (select count(*) from @TrabajadorXPorcCC txpc where txpc.Cd_Trab=@Cd_Trab)

					set @Cd_CCs = ''
					set @Cd_SCs = ''
					set @Cd_SSs = ''
					set @Porcs = ''

					select @Cd_CCs+=Cd_CC+',', @Cd_SCs+=Cd_SC+',', @Cd_SSs+=Cd_SS+',', @Porcs+=convert(varchar, Porc)+','
					from @TrabajadorXPorcCC txpc where txpc.Cd_Trab=@Cd_Trab
							
					begin print '- Asiento Debe ' + case when @IB_GAxCCF=1 then '(F)' else '(TD)' end + ':'
						set @SumImporteConceptoPorcFicha = 0.00
						while(@j>0)
							begin /*Desgloce por Porcentajes de Centro de Costos*/
								set @Cd_CC = substring(@Cd_CCs, 1, (charindex(',', @Cd_CCs)-1))
								set @Cd_SC = substring(@Cd_SCs, 1, (charindex(',', @Cd_SCs)-1))
								set @Cd_SS = substring(@Cd_SSs, 1, (charindex(',', @Cd_SSs)-1))
								set @Porc = substring(@Porcs, 1, (charindex(',', @Porcs)-1))
										 
								if(not exists (select * from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@cd_SS))
									set @s += 'No existe el amarre de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
								else
									begin
									
										set @NroCta = isnull((select top 1 NroCta from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS
																ORDER BY CASE WHEN @Sem = ''  AND ISNULL(Contrapartida_Obr, '') = '' THEN 1 WHEN @Sem = ''  THEN 0 WHEN @Sem <> '' AND ISNULL(Contrapartida_Obr, '') <> '' THEN 0 ELSE 1 END), '')
										set @Cuenta = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta), '')
										set @P_IB_FEC = ISNULL((select CASE WHEN @P_IB_HABILITAR_CONCEPTOS_FLUJO_EFECTIVO_CONTABLE=1 THEN CASE WHEN ISNULL(IB_CtasXCbr,0)=1 or ISNULL(IB_CtasXPag,0)=1 THEN 1 ELSE 0 END ELSE 0 END from PlanCtas where RucE=@RucE and NroCta=@NroCta and Ejer=@Ejer),0)
											
										if(@NroCta<>'')
											begin
												if((select isnull(C_IB_AUXILIAR_TRABAJADOR, 0) from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta)=1)
													begin
														set @Cd_Trabajador = @Cd_Trab
													end
												else
													begin
														set @Cd_Trabajador = null
													end
												if(ISNULL((select isnull(IB_NDoc, 0) from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta),0) = 1)
													begin
														set @Cd_TD = (select Cd_TD_AsientosPlanillon from CfgPlanilla where RucE=@RucE)
														select @NroSre=NroSre from dbo.fn_NroDocTrabajador(@RucE,@Cd_TD,@Cd_Trab)
														SET @NroDoc = @Ejer + @Prdo + SUBSTRING(@Cd_Trab,2,7)
														SET @IB_EsProv = 1
													end
												else
													begin
														set @Cd_TD = null
														SET @NroSre=null
														SET @NroDoc = null
														SET @IB_EsProv = 0
													end
													
												if(exists (select * from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta and IB_CC=1 and (ISNULL(IC_IEF,'')='E' or ISNULL(IC_IEN,'')='E')))
													begin
														set @IB_CDxPCC = 1
														set @SumImporteConceptoPorcFicha += ((@Importe*@Porc)/100)

														select 'A24', @Cd_Concepto, case when (@SumImporteConceptoPorcFicha > @Importe) then ((@Importe*@Porc)/100) - (@SumImporteConceptoPorcFicha - @Importe)
																	 when (@j=1) and (@SumImporteConceptoPorcFicha < @Importe) then ((@Importe*@Porc)/100) + ABS(@SumImporteConceptoPorcFicha - @Importe)
																	 else ((@Importe*@Porc)/100) 
																end, @NroCta, 'Debe'

														print 'insert '''+@Cd_Concepto+'-'+@NroCta+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,5), ((@Importe*@Porc)/100)))+' (@IB_CDxPCC='+convert(varchar, @IB_CDxPCC)+')'
														insert into Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																			MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																			FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,C_ID_CONCEPTO_FEC)
														values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte, @FecMov, @FecCbr ,@NroCta,@Cd_TD,@NroSre,@NroDoc,@FecMov/*getdate()*/,(@Cuenta+CASE WHEN @P_IB_AGRUPAR_CUENTAS=0 THEN @Trabajador ELSE '' END+' - '+convert(varchar, @Porc)+'% ' + case when @IB_GAxCCF=1 then '(F)' else '(TD)' end),0.00,
																case when (@SumImporteConceptoPorcFicha > @Importe) then ((@Importe*@Porc)/100) - (@SumImporteConceptoPorcFicha - @Importe)
																	 when (@j=1) and (@SumImporteConceptoPorcFicha < @Importe) then ((@Importe*@Porc)/100) + ABS(@SumImporteConceptoPorcFicha - @Importe)
																	 else ((@Importe*@Porc)/100) 
																end,
																0.00,
																((case when (@SumImporteConceptoPorcFicha > @Importe) then ((@Importe*@Porc)/100) - (@SumImporteConceptoPorcFicha - @Importe)
																	 when (@j=1) and (@SumImporteConceptoPorcFicha < @Importe) then ((@Importe*@Porc)/100) + ABS(@SumImporteConceptoPorcFicha - @Importe)
																	 else ((@Importe*@Porc)/100) 
																end)/@CamMda),
																0.00,'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',@IB_EsProv,
																getdate(),null,@UsuCrea,null,0,@Cd_Trabajador,CASE WHEN @P_IB_FEC=1 THEN @P_ID_CONCEPTO_FEC ELSE 0 END)
													end
												else
													set @IB_CDxPCC = 0
											end
										else
											set @s += 'No existe el numero de cuenta de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
									end

								begin print '- Asiento Destino ' + case when @IB_GAxCCF=1 then '(F)' else '(TD)' end + ':'
									set @ImporteDestino = convert(numeric(13,5), case when (@SumImporteConceptoPorcFicha > @Importe) then ((@Importe*@Porc)/100) - (@SumImporteConceptoPorcFicha - @Importe)
																					  when (@j=1) and (@SumImporteConceptoPorcFicha < @Importe) then ((@Importe*@Porc)/100) /* + ABS(@SumImporteConceptoPorcFicha - @Importe) */ /* Se retira la suma de la diferencia porque si es el 100% es íntegra */
																					  else ((@Importe*@Porc)/100) 
																				 end)

									if(not exists (select * from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS))
										set @s += 'No existe el amarre de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
									else
										begin
											set @NroCta = isnull((select top 1 NroCta from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@cd_SS
																	ORDER BY CASE WHEN @Sem = ''  AND ISNULL(Contrapartida_Obr, '') = '' THEN 1 WHEN @Sem = ''  THEN 0 WHEN @Sem <> '' AND ISNULL(Contrapartida_Obr, '') <> '' THEN 0 ELSE 1 END), '')
											SET @L_IB_DESAGRUPAR_DESTINOS = (SELECT ISNULL(C_IB_DESAGRUPAR_DESTINOS, 0) FROM PLANCTAS WHERE RUCE=@RucE AND EJER=@Ejer AND NROCTA=@NroCta)
											SET @IB_AMARRE_CUENTA_DESTINO_CENTRO_COSTO = (SELECT ISNULL(C_IB_CUENTA_DESTINO_CENTRO_COSTO, 0) FROM PLANCTAS WHERE RUCE=@RucE AND EJER=@Ejer AND NROCTA=@NroCta)

											if(@NroCta<>'')
												begin
													if(@IB_AMARRE_CUENTA_DESTINO_CENTRO_COSTO=1)
														begin
															if((select TOP 1 isnull(C_NUMERO_CUENTA_DEBE, '') from CONTABILIDAD.T_AMARRE_CUENTA_CENTRO_COSTO_DESTINOS where C_RUC_EMPRESA  = @RucE and C_EJERCICIO  = @Ejer and CONCAT(C_CODIGO_CENTRO_COSTO,C_CODIGO_SUB_CENTRO_COSTO,C_CODIGO_SUB_SUB_CENTRO_COSTO)=@Cd_CC+@Cd_SC+@cd_SS)!='')
															begin
																set @k = (select COUNT(*) from CONTABILIDAD.T_AMARRE_CUENTA_CENTRO_COSTO_DESTINOS where C_RUC_EMPRESA  = @RucE and C_EJERCICIO  = @Ejer and CONCAT(C_CODIGO_CENTRO_COSTO,C_CODIGO_SUB_CENTRO_COSTO,C_CODIGO_SUB_SUB_CENTRO_COSTO)=@Cd_CC+@Cd_SC+@cd_SS)
																set @k_total = @k

																(select @CtaDs+=C_NUMERO_CUENTA_DEBE+',', @CtaHs+=C_NUMERO_CUENTA_HASTA+',', @PorcDs+=convert(varchar, C_PORCENTAJE)+',' from CONTABILIDAD.T_AMARRE_CUENTA_CENTRO_COSTO_DESTINOS where C_RUC_EMPRESA  = @RucE and C_EJERCICIO  = @Ejer and CONCAT(C_CODIGO_CENTRO_COSTO,C_CODIGO_SUB_CENTRO_COSTO,C_CODIGO_SUB_SUB_CENTRO_COSTO)=@Cd_CC+@Cd_SC+@cd_SS)
												
																while(@k>0)
																		begin
																			set @CtaD = substring(@CtaDs, 1, (charindex(',', @CtaDs)-1))
																			set @CtaH = substring(@CtaHs, 1, (charindex(',', @CtaHs)-1))
																			set @PorcD = substring(@PorcDs, 1, (charindex(',', @PorcDs)-1))

																			begin /*Cuenta de Destino (Debe)*/
																				set @Cuenta = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@CtaD), '')
																				select 'A25', @Cd_Concepto, CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END, @CtaD, 'Debe'																				
																				IF(@L_IB_DESAGRUPAR_DESTINOS=0) /* AGRUPAR DESTINOS:EL DEBE VA TODO EN UNA LINEA */
																					BEGIN
																						IF(EXISTS (SELECT * FROM Voucher WHERE RucE=@RucE AND Ejer=@Ejer AND Prdo=@Prdo AND RegCtb=@RegCtb AND NroCta=@CtaD and CodT=CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END))
																							BEGIN
																								PRINT 'update '''+@CtaD+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+CONVERT(VARCHAR, CONVERT(NUMERIC(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END)))+' (Debe-Agrupar)'
																								UPDATE Voucher SET MtoD=(MtoD+(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END)),
																								MtoD_ME=(MtoD_ME+(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino/@CamMda-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100/@CamMda) ELSE @ImporteDestino*@PorcD/100/@CamMda END))/*, FecMdf=GETDATE(), UsuModf=@UsuCrea*/
																								WHERE RucE=@RucE AND Ejer=@Ejer AND Prdo=@Prdo AND RegCtb=@RegCtb AND NroCta=@CtaD and CodT=CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END
																							END
																						ELSE
																							BEGIN
																								PRINT 'insert '''+@CtaD+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+CONVERT(VARCHAR, CONVERT(NUMERIC(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END)))+' (Debe-Agrupar)'
																								INSERT INTO Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																													MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																													FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,IB_EsDes, CodT)
																								values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte, @FecMov, @FecCbr ,@CtaD,NULL,NULL,NULL,@FecMov/*getdate()*/,@Cuenta+' (Destino)',0.00,
																										(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END),0.00,(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino/@CamMda-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100/@CamMda) ELSE @ImporteDestino*@PorcD/100/@CamMda END),0.00,'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',0,
																										GETDATE(),NULL,@UsuCrea,NULL,0,NULL,1, @Cd_Concepto)
																							END
																					END
																				ELSE /* DESAGRUPAR DESTINOS: EL DEBE SE GENERA POR CADA LINEA */
																					BEGIN
																						PRINT 'insert '''+@CtaD+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+CONVERT(VARCHAR, CONVERT(NUMERIC(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END)))+' (Debe-Desagrupar)'
																						INSERT INTO Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																											MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																											FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,IB_EsDes, CodT)
																						values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte, @FecMov, @FecCbr ,@CtaD,NULL,NULL,NULL,@FecMov/*getdate()*/,@Cuenta+' (Destino)',0.00,
																								(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END),0.00,(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino/@CamMda-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100/@CamMda) ELSE @ImporteDestino*@PorcD/100/@CamMda END),0.00,'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',0,
																								GETDATE(),NULL,@UsuCrea,NULL,0,NULL,1, @Cd_Concepto)
																					END
																			end
																			begin /*Cuenta de Destino (Haber)*/
																				set @Cuenta = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@CtaH), '')
																				select 'A26', @Cd_Concepto, CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END, @CtaH, 'Haber'
																				if(exists (select * from Voucher where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@CtaH and CodT=CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END))
																					begin
																						print 'update '''+@CtaH+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END)))+' (Haber)'
																						update Voucher set MtoH=(MtoH+(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END)), MtoH_ME=(MtoH_ME+(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino/@CamMda-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100/@CamMda) ELSE @ImporteDestino*@PorcD/100/@CamMda END))/*, FecMdf=getdate(), UsuModf=@UsuCrea*/
																						where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@CtaH and CodT=CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END
																					end
																				else
																					begin
																						print 'insert '''+@CtaH+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END)))+' (Haber)'
																						insert into Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																											MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																											FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,IB_EsDes, CodT)
																						values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte, @FecMov, @FecCbr ,@CtaH,null,null,null,@FecMov/*getdate()*/,@Cuenta+' (Destino)',0.00,
																								0.00,(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END),0.00,(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino/@CamMda-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100/@CamMda) ELSE @ImporteDestino*@PorcD/100/@CamMda END),'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',0,
																								getdate(),null,@UsuCrea,null,0,null,1, @Cd_Concepto)
																					end
																			end

																			set @CtaDs = substring(@CtaDs, (charindex(',',@CtaDs)+1), len(@CtaDs))
																			set @CtaHs = substring(@CtaHs, (charindex(',',@CtaHs)+1), len(@CtaHs))
																			set @PorcDs = substring(@PorcDs, (charindex(',',@PorcDs)+1), len(@PorcDs))
																			set @k = (@k-1)
																		end
																end
															else
																print 'El número de cuenta de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'| no tiene cuentas de destino'+char(13)+char(10)
														end
													else
														begin
															if((select isnull(IB_CtaD, 0) from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta)=1)
																begin											
																	set @k = (select count(*) from AmarreCta where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta)

																	(select @CtaDs+=CtaD+',', @CtaHs+=CtaH+',', @PorcDs+=convert(varchar, Porc)+',' from AmarreCta where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta)
										
																	while(@k>0)
																		begin
																			set @CtaD = substring(@CtaDs, 1, (charindex(',', @CtaDs)-1))
																			set @CtaH = substring(@CtaHs, 1, (charindex(',', @CtaHs)-1))
																			set @PorcD = substring(@PorcDs, 1, (charindex(',', @PorcDs)-1))

																			begin /*Cuenta de Destino (Debe)*/
																				set @Cuenta = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@CtaD), '')
																				select 'A27', @Cd_Concepto, CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END, @CtaD, 'Debe'
																				IF(@L_IB_DESAGRUPAR_DESTINOS=0) /* AGRUPAR DESTINOS:EL DEBE VA TODO EN UNA LINEA */
																					BEGIN
																						IF(EXISTS (SELECT * FROM Voucher WHERE RucE=@RucE AND Ejer=@Ejer AND Prdo=@Prdo AND RegCtb=@RegCtb AND NroCta=@CtaD and CodT=CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END))
																							BEGIN
																								PRINT 'update '''+@CtaD+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+CONVERT(VARCHAR, CONVERT(NUMERIC(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END)))+' (Debe-Agrupar)'
																								UPDATE Voucher SET MtoD=(MtoD+(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END)),
																								MtoD_ME=(MtoD_ME+(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino/@CamMda-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100/@CamMda) ELSE @ImporteDestino*@PorcD/100/@CamMda END))/*, FecMdf=GETDATE(), UsuModf=@UsuCrea*/
																								WHERE RucE=@RucE AND Ejer=@Ejer AND Prdo=@Prdo AND RegCtb=@RegCtb AND NroCta=@CtaD and CodT=CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END
																							END
																						ELSE
																							BEGIN
																								PRINT 'insert '''+@CtaD+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+CONVERT(VARCHAR, CONVERT(NUMERIC(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END)))+' (Debe-Agrupar)'
																								INSERT INTO Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																													MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																													FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,IB_EsDes, CodT)
																								values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte, @FecMov, @FecCbr ,@CtaD,NULL,NULL,NULL,@FecMov/*getdate()*/,@Cuenta+' (Destino)',0.00,
																										(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END),0.00,(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino/@CamMda-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100/@CamMda) ELSE @ImporteDestino*@PorcD/100/@CamMda END),0.00,'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',0,
																										GETDATE(),NULL,@UsuCrea,NULL,0,NULL,1, @Cd_Concepto)
																							END
																					END
																				ELSE /* DESAGRUPAR DESTINOS: EL DEBE SE GENERA POR CADA LINEA */
																					BEGIN
																						PRINT 'insert '''+@CtaD+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+CONVERT(VARCHAR, CONVERT(NUMERIC(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END)))+' (Debe-Desagrupar)'
																						INSERT INTO Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																											MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																											FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,IB_EsDes, CodT)
																						values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte, @FecMov, @FecCbr ,@CtaD,NULL,NULL,NULL,@FecMov/*getdate()*/,@Cuenta+' (Destino)',0.00,
																								(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END),0.00,(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino/@CamMda-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100/@CamMda) ELSE @ImporteDestino*@PorcD/100/@CamMda END),0.00,'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',0,
																								GETDATE(),NULL,@UsuCrea,NULL,0,NULL,1, @Cd_Concepto)
																					END
																			end
																			begin /*Cuenta de Destino (Haber)*/
																				set @Cuenta = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@CtaH), '')
																				select 'A28', @Cd_Concepto, CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END, @CtaH, 'Haber'
																				if(exists (select * from Voucher where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@CtaH and CodT=CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END))
																					begin
																						print 'update '''+@CtaH+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END)))+' (Haber)'
																						update Voucher set MtoH=(MtoH+(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END)), MtoH_ME=(MtoH_ME+(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino/@CamMda-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100/@CamMda) ELSE @ImporteDestino*@PorcD/100/@CamMda END))/*, FecMdf=getdate(), UsuModf=@UsuCrea*/
																						where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@CtaH and CodT=CASE WHEN @P_IB_SEPARAR_CONCEPTOS=0 THEN '' ELSE @Cd_Concepto END
																					end
																				else
																					begin
																						print 'insert '''+@CtaH+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, convert(numeric(13,5), (CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END)))+' (Haber)'
																						insert into Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																											MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																											FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,IB_EsDes, CodT)
																						values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte, @FecMov, @FecCbr ,@CtaH,null,null,null,@FecMov/*getdate()*/,@Cuenta+' (Destino)',0.00,
																								0.00,(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100) ELSE @ImporteDestino*@PorcD/100 END),0.00,(CASE WHEN @k_total>1 AND @k=1 THEN @ImporteDestino/@CamMda-Convert(numeric(20,2),@ImporteDestino*(100-@PorcD)/100/@CamMda) ELSE @ImporteDestino*@PorcD/100/@CamMda END),'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',0,
																								getdate(),null,@UsuCrea,null,0,null,1, @Cd_Concepto)
																					end
																			end

																			set @CtaDs = substring(@CtaDs, (charindex(',',@CtaDs)+1), len(@CtaDs))
																			set @CtaHs = substring(@CtaHs, (charindex(',',@CtaHs)+1), len(@CtaHs))
																			set @PorcDs = substring(@PorcDs, (charindex(',',@PorcDs)+1), len(@PorcDs))
																			set @k = (@k-1)
																		end
																end
															else
																print 'El número de cuenta de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'| no tiene cuentas de destino'+char(13)+char(10)
														end
												end
											else
												set @s += 'No existe el numero de cuenta de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
										end

									print @s+char(13)+char(10)
									set @msj += @s
									set @s = ''
								end

								set @Cd_CCs = substring(@Cd_CCs, (charindex(',',@Cd_CCs)+1), len(@Cd_CCs))
								set @Cd_SCs = substring(@Cd_SCs, (charindex(',',@Cd_SCs)+1), len(@Cd_SCs))
								set @Cd_SSs = substring(@Cd_SSs, (charindex(',',@Cd_SSs)+1), len(@Cd_SSs))
								set @Porcs = substring(@Porcs, (charindex(',',@Porcs)+1), len(@Porcs))
								set @j = (@j-1)
							end
						if(@IB_CDxPCC=0)
							begin /*Desgloce por Centro de Costo Principal*/
								set @Cd_CC = (select Cd_CC from @TrabajadorXPorcCC where Cd_Trab=@Cd_Trab and IB_CCPrincipal=1)
								set @Cd_SC = (select Cd_SC from @TrabajadorXPorcCC where Cd_Trab=@Cd_Trab and IB_CCPrincipal=1)
								set @Cd_SS = (select Cd_SS from @TrabajadorXPorcCC where Cd_Trab=@Cd_Trab and IB_CCPrincipal=1)

								if(not exists (select * from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS))
									begin
										set @s = ''
										set @s += 'No existe el amarre de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
									end
								else
									begin
										set @NroCta = isnull((select TOP 1 NroCta from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS
																ORDER BY CASE WHEN @Sem = ''  AND ISNULL(Contrapartida_Obr, '') = '' THEN 1 WHEN @Sem = ''  THEN 0 WHEN @Sem <> '' AND ISNULL(Contrapartida_Obr, '') <> '' THEN 0 ELSE 1 END), '')
										set @Cuenta = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta), '')
										set @P_IB_FEC = ISNULL((select CASE WHEN @P_IB_HABILITAR_CONCEPTOS_FLUJO_EFECTIVO_CONTABLE=1 THEN CASE WHEN ISNULL(IB_CtasXCbr,0)=1 or ISNULL(IB_CtasXPag,0)=1 THEN 1 ELSE 0 END ELSE 0 END from PlanCtas where RucE=@RucE and NroCta=@NroCta and Ejer=@Ejer),0)

										if(@NroCta<>'')
											begin
												if((select isnull(C_IB_AUXILIAR_TRABAJADOR, 0) from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta)=1)
													begin
														set @Cd_Trabajador = @Cd_Trab
													end
												else
													begin
														set @Cd_Trabajador = null
													end
												if(ISNULL((select isnull(IB_NDoc, 0) from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta),0) = 1)
													begin
														set @Cd_TD = (select Cd_TD_AsientosPlanillon from CfgPlanilla where RucE=@RucE)
														select @NroSre=NroSre from dbo.fn_NroDocTrabajador(@RucE,@Cd_TD,@Cd_Trab)
														SET @NroDoc = @Ejer + @Prdo + SUBSTRING(@Cd_Trab,2,7)
														SET @IB_EsProv = 1
													end
												else
													begin
														set @Cd_TD = null
														SET @NroSre=null
														SET @NroDoc = null
														SET @IB_EsProv = 0
													end
												select 'A29', @Cd_Concepto, @Importe, @NroCta, 'Debe'
												print 'insert '''+@Cd_Concepto+'-'+@NroCta+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'| '+convert(varchar, @Importe)+' (@IB_CDxPCC='+convert(varchar, @IB_CDxPCC)+')'
												insert into Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																	MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																	FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,C_ID_CONCEPTO_FEC)
												values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte, @FecMov, @FecCbr ,@NroCta,@Cd_TD,@NroSre,@NroDoc,@FecMov/*getdate()*/,(@Cuenta+CASE WHEN @P_IB_AGRUPAR_CUENTAS=0 THEN @Trabajador ELSE '' END + case when @IB_GAxCCF=1 then ' (F)' else ' (TD)' end),0.00,
														@Importe,0.00,(@Importe/@CamMda),0.00,'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',@IB_EsProv,
														getdate(),null,@UsuCrea,null,0,@Cd_Trabajador,CASE WHEN @P_IB_FEC=1 THEN @P_ID_CONCEPTO_FEC ELSE 0 END)
											end
										else
											set @s += 'No existe el numero de cuenta de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
									end
							end

						print @s+char(13)+char(10)
						set @msj += @s
						set @s = ''
					end
					begin print '- Asiento Haber ' + case when @IB_GAxCCF=1 then '(F)' else '(TD)' end + ':'
						set @Cd_CC = (select Cd_CC from @TrabajadorXPorcCC where Cd_Trab=@Cd_Trab and IB_CCPrincipal=1)
						set @Cd_SC = (select Cd_SC from @TrabajadorXPorcCC where Cd_Trab=@Cd_Trab and IB_CCPrincipal=1)
						set @Cd_SS = (select Cd_SS from @TrabajadorXPorcCC where Cd_Trab=@Cd_Trab and IB_CCPrincipal=1)
								
						if(not exists (select * from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS))
							set @s += 'No existe el amarre de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)
						else
							begin
								set @NroCta = isnull((select TOP 1 (case when @Sem='' then Contrapartida else Contrapartida_Obr end) from AmarreCtaCC where RucE=@RucE and CodRoD=@Cd_Concepto and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS
														ORDER BY CASE WHEN @Sem = ''  AND ISNULL(Contrapartida_Obr, '') = '' THEN 1 WHEN @Sem = ''  THEN 0 WHEN @Sem <> '' AND ISNULL(Contrapartida_Obr, '') <> '' THEN 0 ELSE 1 END), '')
								set @Cuenta = isnull((select NomCta from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta), '')
								set @P_IB_FEC = ISNULL((select CASE WHEN @P_IB_HABILITAR_CONCEPTOS_FLUJO_EFECTIVO_CONTABLE=1 THEN CASE WHEN ISNULL(IB_CtasXCbr,0)=1 or ISNULL(IB_CtasXPag,0)=1 THEN 1 ELSE 0 END ELSE 0 END from PlanCtas where RucE=@RucE and NroCta=@NroCta and Ejer=@Ejer),0)

								if(@NroCta<>'')
									begin /*Sumar Monto al Número de Cuenta de Haber (Desgloce por Trabajador o Centro de Costos Principal)*/
										if(((select isnull(C_IB_AUXILIAR_TRABAJADOR, 0) from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta)=1) and (@IB_DxA=1))
											begin
												set @Cd_Trabajador = @Cd_Trab
											end
										else
											begin
												set @Cd_Trabajador = null
											end
										if(ISNULL((select isnull(IB_NDoc, 0) from PlanCtas where RucE=@RucE and Ejer=@Ejer and NroCta=@NroCta),0) = 1)
											begin
												set @Cd_TD = (select Cd_TD_AsientosPlanillon from CfgPlanilla where RucE=@RucE)
												select @NroSre=NroSre from dbo.fn_NroDocTrabajador(@RucE,@Cd_TD,@Cd_Trab)
												SET @NroDoc = @Ejer + @Prdo + SUBSTRING(@Cd_Trab,2,7)
												SET @IB_EsProv = 1
											end
										else
											begin
												set @Cd_TD = null
												SET @NroSre=null
												SET @NroDoc = null
												SET @IB_EsProv = 0
											end
										select 'A30', @Cd_Concepto, @Importe, @NroCta, 'Haber'
										if(exists (select * from Voucher where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@NroCta and
													Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS --and isnull(Cd_Area, '')=(case when Cd_Area is null then '' else @Cd_Area end) 
													and Glosa=(case when (@IB_DxA=1) then (@Cuenta+CASE WHEN @P_IB_AGRUPAR_CUENTAS=0 THEN @Trabajador ELSE '' END + case when @IB_GAxCCF=1 then ' (F)' else ' (TD)' end) else (@Cuenta + case when @IB_GAxCCF=1 then ' (F)' else ' (TD)' end) end) and isnull(Cd_Trab, '')=(case when @Cd_TD is null then '' else @Cd_Trabajador end)))
											begin
												print 'update '''+@Cd_Concepto+'-'+@NroCta+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, @Importe)
												update Voucher set MtoH=(MtoH+@Importe), MtoH_ME=(MtoH_ME+(@Importe/@CamMda))/*, FecMdf=getdate(), UsuModf=@UsuCrea*/
												where RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb and NroCta=@NroCta and Cd_CC=@Cd_CC and Cd_SC=@Cd_SC and Cd_SS=@Cd_SS --and isnull(Cd_Area, '')=(case when Cd_Area is null then '' else @Cd_Area end) 
												and Glosa=(case when (@IB_DxA=1) then (@Cuenta+CASE WHEN @P_IB_AGRUPAR_CUENTAS=0 THEN @Trabajador ELSE '' END + case when @IB_GAxCCF=1 then ' (F)' else ' (TD)' end) else (@Cuenta + case when @IB_GAxCCF=1 then ' (F)' else ' (TD)' end) end) and isnull(Cd_Trab, '')=(case when @Cd_TD is null then '' else @Cd_Trabajador end)
											end
										else
											begin
												print 'insert '''+@Cd_Concepto+'-'+@NroCta+''' |'+@Cd_CC+'-'+@Cd_SC+'-'+@CD_SS+'| '+convert(varchar, @Importe)
												insert into Voucher(RucE,Ejer,Prdo,RegCtb,Cd_Fte,FecMov,FecCbr,NroCta,Cd_TD,NroSre,NroDoc,FecED,Glosa,MtoOr,
																	MtoD,MtoH,MtoD_ME,MtoH_ME,Cd_MdOr,Cd_MdRg,CamMda,Cd_CC,Cd_SC,Cd_SS,Cd_Area,Cd_MR,Cd_TG,IC_CtrMd,IB_EsProv,
																	FecReg,FecMdf,UsuCrea,UsuModf,IB_Anulado,Cd_Trab,C_ID_CONCEPTO_FEC)
												values(@RucE,@Ejer,@Prdo,@RegCtb,@Cd_Fte,@FecMov, @FecCbr ,@NroCta,@Cd_TD,@NroSre,@NroDoc,@FecMov/*getdate()*/,(case when (@IB_DxA=1) then (@Cuenta+CASE WHEN @P_IB_AGRUPAR_CUENTAS=0 THEN @Trabajador ELSE '' END + case when @IB_GAxCCF=1 then ' (F)' else ' (TD)' end) else (rtrim(@Cuenta) + case when @IB_GAxCCF=1 then ' (F)' else ' (TD)' end) end),0.00,
														0.00,@Importe,0.00,(@Importe/@CamMda),'01','01',@CamMda,@Cd_CC,@Cd_SC,@Cd_SS,@Cd_Area,'15','01','a',@IB_EsProv,
														getdate(),null,@UsuCrea,null,0,@Cd_Trabajador,CASE WHEN @P_IB_FEC=1 THEN @P_ID_CONCEPTO_FEC ELSE 0 END)
											end
									end
								else
									set @s += 'No existe la contrapartida de '''+@Cd_Concepto+''' para |'+@Cd_CC+'-'+@Cd_SC+'-'+@Cd_SS+'|'+char(13)+char(10)								
							end

						print @s+char(13)+char(10)
						set @msj += @s
						set @s = ''
					end

					set @Cd_Conceptos = substring(@Cd_Conceptos, (charindex(',',@Cd_Conceptos)+1), len(@Cd_Conceptos))
					set @Importes = substring(@Importes, (charindex(',',@Importes)+1), len(@Importes))
					set @i = (@i-1)
				end
		end
			print '/*********************/'+char(13)+char(10)+char(13)+char(10)
		end
	
	end
end
BEGIN /*Eliminar vouchers vacíos*/
	DELETE Voucher WHERE RucE=@RucE and Ejer=@Ejer and Prdo=@Prdo and RegCtb=@RegCtb AND MtoD=0 AND MtoH=0
END
/*
++++++++++++++++++++++++Leyenda++++++++++++++++++++++++
--DJ: 21/10/2019 <Se cambió la funcionalidad del campo IB_Aux por C_IB_AUXILIAR_TRABAJADOR>
- Pedro: 05/11/2019 <Se agregó el check de IB_EsDes para el asiento de destino>
--DJ: 16/01/2020 <Se validó el uso de Centro de Costo Histórico de acuerdo a la configuración C_IB_CENTRO_COSTO_HISTORICO>
- Pedro: 20/03/2020 <Se utilizará un concepto de flujo configurado desde conf. general de planilla, y el check de conf. de contabilidad>
- Pedro: 17/02/2021 <Se agruparon los asientos por cuentas y centros de costo>
- Pedro: 20/04/2021 <Se separa el área al actualizar los asientos para poder agrupar>
- Pedro: 17/06/2021 <Se separan los destinos por centro de costos como en contabilidad para planilla>
- David: 19/07/2021 <Se cambiaron los parámetros @NroCta, @CtaD, @CtaH, @NroCtaDifEmp y @NroCtaDifObr a varchar(50)>
- Pedro: 10/08/2021 <Se agrega el regimen pensionario a la liquidación cuando es Vacación trunca 'L03'>
- David: 25/08/2021 <Para las remuneraciones y descuentos se está registrando el campo CodT (voucher), con el fin de permitir un mismo número de cuenta para distintos conceptos>
- Pedro: 05/10/2021 <Agrupación por cuentas de Aportes con desgloce de trabajador>
- Pedro: 05/10/2021 <Asientos cuadrados en descuentos>
- Pedro: 20/10/2021 <Se retiran otros descuentos de liquidación en el Debe y se agrega como diferencia al haber de la cta 41.>
- David: 16/12/2021 <Se agregó el join a CTSImp en el sector de CTS y se calculó de acuerdo a pt_LiquidacionCTS_1>
- Pedro: 20/05/2022 <Se considera el CodT vacío para restar la diferencia de Descuentos en Regimen Pensionario y Descuentos>
- David: 23/07/2022 <Los destinos ahora están generándose por cada NroCta - CC (desgloce de CC Ficha), antes solo generaba los destinos del CC Principal. El cambio fue hecho para Remuneraciones, Aportes y CTS>
- Pedro: 03/08/2022 <Se considera una nueva configuración "C_IB_SEPARAR_CONCEPTOS" para separar los conceptos al agrupar por CC>
- Pedro: 15/09/2022 <Se considera el check de provisión al Nro Documento>
- David: 15/09/2022 <Se agregó la variable @FactorRestaDestinoDescuento, encargado de aplicar la resta al NroCta destino acumulado cuando este NroCta tenga amarre con remuneraciones al mismo tiempo que con descuentos (o régimen pensionario). Caso: 61471>
- Pedro: 10/10/2022 <Se retira la suma de la diferencia porque si es el 100% es íntegra>
- Pedro: 28/10/2022 <Se agrega filtro de Glosa de cuenta para los destinos>
- Pedro: 08/11/2022 <Corrección para vacaciones de liquidación incluyendo AFP en destinos>
- Pedro: 19/12/2022 <Se integró @Concepto para CodT en destinos de Remuneraciones y Aportes. Se aumentaron decimales en @SumImporteConceptoPorcFicha>
- Pedro: 16/01/2023 <Corrección para auxiliar>
- Pedro: 29/08/2023 <Cambio de AFP liq de RegimenDetTrabHist a LiquidacionXTrab>
- Pedro: 08/09/2023 <Se respeta indicadores operativos del plan de cuentas antes que agrupación por cuentas en configuración de planilla>
- David Jove: 18/01/2024 <Se agregaron las remuneraciones con quincenas absolutas en la región de /*ASIENTOS DE REMUNERACIONES*/>
- Pedro: 04/04/2024 <Se corrigieron los destinos para decimales impares con los importes restantes>
- Pedro: 03/07/2024 <Se corrigieron las diferencias en moneda extranjera>
- David Jove: 08/07/2024 <(96292) Se agregaron las configuraciones @IB_DesgloceAportexCCFicha, @IB_DesgloceRegimenPensionarioxCCFicha y @IB_DesgloceDescuentoxCCFicha para desglozar el Monto Haber por los CC de la Ficha del trabajdor>
- Williams: 11/09/2024 <Se corrigieron los datos cuando no se usan las configuraciones @IB_DesgloceAportexCCFicha, @IB_DesgloceRegimenPensionarioxCCFicha y @IB_DesgloceDescuentoxCCFicha>
- Williams: 19/09/2024 <Se corrigio la asignacion de la variable @j cuando no se usan las configuraciones @IB_DesgloceAportexCCFicha, @IB_DesgloceRegimenPensionarioxCCFicha y @IB_DesgloceDescuentoxCCFicha>
- Pedro: 21/10/2024 <(103027) Validación de la existencia C_NUMERO_CUENTA_DEBE, '') from CONTABILIDAD.T_AMARRE_CUENTA_CENTRO_COSTO_DESTINOS
- Pedro: 06/01/2024 <(103235) Validación del tipo de remuneración si es Empleado u Obrero
- Pedro: 02/04/2025 <(112743) Se evita la suma de AFP en vacaciones trunca
- Pedro: 14/04/2025 <(112770) Se incluye el descuento de tardanza
- Pedro: 22/07/2025 <(114587) Se ajusta la provisión en descuento
- Pedro: 04/08/2025 <(114644) Se ajusta el check de destino
- David Jove: 16/08/2025 <(114748) Se incluyó el importe del Régimen Pensionario (Liquidación) en las Vacaciones (Liquidación).
- Pedro: 04/09/2025 <(115865) Se ordenó el amarre de cuentas para obreros
- David Jove: 06/10/2025 <(114572) Se agregó el Filtro para AFP y ONP en LiquidacionXTrab al obtener @ImpRegPen. Se agregó update top (1) en la región del 'Haber' (@ImpOtroDscto)>
- David Jove: 13/10/2025 <(119060) Se agregó la configuración @P_IB_SEPARAR_CONCEPTOS a las liquidaciones>
- Pedro: 26/10/2025 <(114603) Se corrigió el adelanto de gratificación en MyJ y se valida si CTS es para empleado u obrero>
- Pedro: 05/11/2025 <(122178) Se valida cuando cuando las vacaciones son completas y la cuenta diferencial es la contrapartida de vacaciones>
- David Jove: 02/12/2025 <(123269) Se agregó el union a CTS en la región obreros>
- Pedro: 31/12/2025 <(123449) Se separa concepto de CTS para evitar update con otras cuentas>
*/