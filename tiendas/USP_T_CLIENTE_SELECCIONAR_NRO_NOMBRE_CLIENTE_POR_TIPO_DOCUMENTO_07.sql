USE [ERP_ECHA]
GO
/****** Object:  StoredProcedure [SPV].[USP_T_CLIENTE_SELECCIONAR_NRO_NOMBRE_CLIENTE_POR_TIPO_DOCUMENTO_07]    Script Date: 20/01/2026 10:47:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [SPV].[USP_T_CLIENTE_SELECCIONAR_NRO_NOMBRE_CLIENTE_POR_TIPO_DOCUMENTO_07]
(
@P_RUC_EMPRESA	nvarchar(11),
@P_CODIGO_VENDEDOR CHAR(10),
@P_VALOR_FILTRO nvarchar(100),
@P_TIPO_DOCUMENTO nvarchar(2)
)
AS
BEGIN

	DECLARE 	
	@L_TIPO_DOC_IDENTIDAD NVARCHAR(200),
	@L_TIPO_DOCUMENTO VARCHAR(200)

	SELECT @L_TIPO_DOCUMENTO = CONCAT(@L_TIPO_DOCUMENTO,CD_TDI,',') FROM TIPDOCIDN WHERE CD_TDI <> '06'

	SET @P_TIPO_DOCUMENTO = (SELECT TOP(1) C_CODIGO_SUNAT FROM TIPDOC WHERE CD_TD = @P_TIPO_DOCUMENTO)	
	
	IF @P_TIPO_DOCUMENTO = '01' -- (C_CODIGO_SUNAT) FACTURA
		SET @L_TIPO_DOC_IDENTIDAD = '06' -- RUC
	ELSE IF @P_TIPO_DOCUMENTO = '03' -- (C_CODIGO_SUNAT) BOLETA
		SET @L_TIPO_DOC_IDENTIDAD = @L_TIPO_DOCUMENTO --TODOS MENOS RUC
	ELSE
		SET @L_TIPO_DOC_IDENTIDAD = CONCAT('06,',@L_TIPO_DOCUMENTO) --TODOS	

	SELECT TOP 1
		C.RucE as Codigo_Empresa,
        C.Cd_Clt as Codigo_Cliente,
        C.Cd_TDI as Cod_tipo_doc_identidad,
		C.Cd_TDI as Codigo_TipoDocIdentidad,
        C.NDoc as Numero_Doc,
        C.RSocial as Razon_Social,
        C.NComercial as Nombre_Comercial,
        C.ApPat as Apellido_Paterno,
        C.ApMat as Apellido_Materno,
		CASE WHEN ISNULL(LTRIM(RTRIM(C.RSocial)),'') = '' THEN 0 ELSE 1 END as Persona_Juridica,
        C.Nom as Nombres,
        C.Cd_Pais as Codigo_pais,
		C.UBIGEO AS Ubigeo,
        CONCAT(LTRIM(RTRIM(C.Direc)),' ',(UD.NOMBRE + ' - ' + UP.NOMBRE + ' - ' + UT.NOMBRE)) as Direccion_Fiscal,
        C.Telf1 as Telefono_1,
        C.Telf2 as Telefono_2,
        C.CORREO as Correo,
        C.PWeb as Pagina_Web,
        C.CtaCte as Cuenta_Corriente,
        C.Cd_TClt as Codigo_Tipo_cliente,
        C.IB_AgRet as Agente_Retencion,
        C.IB_AgPercep as Agente_Percepcion,
        C.IB_BuenContrib as Buen_Contribuyente,
        C.EsExtranjero as Extranjero,
        C.PASSWEB as Passweb,
        C.Obs as Observacion,
        C.CtaCtb as Cta_Contable,
        C.Msj_Alert as Mensaje_Notificacion,
        C.ESTADO as Estado,
        C.FecReg as Fecha_Registro,
        C.FecMdf as Fecha_Modificacion,
        C.UsuCrea as Usuario_Registro,
        C.UsuMdf as Usuario_Modificacion,
        C.CA01 as Campo_01,
		C.CA02 as Campo_02,
        C.CA03 as Campo_03,
		C.CA04 as Campo_04,
        C.CA05 as Campo_05,
		C.CA06 as Campo_06,
        C.CA07 as Campo_07,
		C.CA08 as Campo_08,
        C.CA09 as Campo_09,
		C.CA10 as Campo_10,
		C.C_TOTAL_PUNTOS as C_TOTAL_PUNTOS,
		C.C_TOTAL_PUNTOS_USADOS as C_TOTAL_PUNTOS_USADOS,
		COALESCE(C.C_TOTAL_PUNTOS,0) - COALESCE(C.C_TOTAL_PUNTOS_USADOS,0) AS C_TOTAL_PUNTOS_SALDO,
		tdi.Descrip as Nombre_Tipo_Doc_Identidad,
		tdi.NCorto as NombreCorto_Tipo_Doc_Identidad
	FROM 
		Cliente2 c
		LEFT JOIN UDEPA UD ON LEFT(C.UBIGEO,2) = UD.CD_UDp
		LEFT JOIN UPROV UP ON LEFT(C.UBIGEO,4) = UP.CD_UPv
		LEFT JOIN UDIST UT ON C.UBIGEO = UT.CD_UDT
		LEFT JOIN VendedorxCliente VXC ON VXC.RucE = C.RucE AND VXC.Cd_Clt = C.Cd_Clt AND VXC.Cd_Vdr = @P_CODIGO_VENDEDOR
		LEFT JOIN TipDocIdn  tdi ON tdi.Cd_TDI=c.Cd_TDI
	WHERE 
		C.RUCE = @P_RUC_EMPRESA
		AND COALESCE(VXC.CD_VDR,'') = CASE WHEN COALESCE(@P_CODIGO_VENDEDOR,'') = '' THEN COALESCE(VXC.CD_VDR,'') ELSE @P_CODIGO_VENDEDOR END
		AND ISNULL(C.ESTADO,0) = 1
		AND CHARINDEX(C.Cd_TDI,@L_TIPO_DOC_IDENTIDAD) > 0
		AND (CASE WHEN ISNULL(C.Cd_Clt,'')<>'' THEN C.Cd_Clt ELSE '--' END=@P_VALOR_FILTRO
			or CASE WHEN ISNULL(C.NDoc,'')<>'' THEN C.NDoc ELSE '--' END=@P_VALOR_FILTRO
			or CASE WHEN ISNULL(C.RSocial,'')<>'' THEN ISNULL(C.RSocial,'') ELSE '--' END=@P_VALOR_FILTRO
			or CASE WHEN ISNULL(C.Nom,'')+ISNULL(C.ApPat,'')+ISNULL(C.ApMat,'')<>'' THEN ISNULL(C.Nom,'')+' '+ISNULL(C.ApPat,'')+' '+ISNULL(C.ApMat,'') ELSE '--' END=@P_VALOR_FILTRO)
END
-- Leyenda --
-- 04/05/2016 < DIEGO : Creacion del SP>
-- 13/05/2016 < DIEGO : Se agrego filtro por codigo>
-- 18/05/2017 < RODRIGO : Se agregó columna Persona Jurídica >
-- 17/02/2022 < RODRIGO : Se agregó consulta para relacionar VendedorxCliente >
-- 05/04/2022 < RODRIGO : Se agregó TRIM a la dirección del Cliente >
-- 11/04/2023 < RODRIGO : Se agregó TOTAL PUNTOS >
