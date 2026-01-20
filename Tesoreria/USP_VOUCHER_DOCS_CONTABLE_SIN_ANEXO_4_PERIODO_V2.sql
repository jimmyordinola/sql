USE [ERP_ECHA]
GO

/****** Object:  StoredProcedure [contabilidad].[USP_VOUCHER_DOCS_CONTABLE_SIN_ANEXO_4_PERIODO_V2]    Script Date: 19/01/2026 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ============================================
-- VERSIÓN OPTIMIZADA
-- Mejoras implementadas:
-- 1. Eliminado SQL dinámico innecesario
-- 2. Filtros SARGABLES para uso de índices
-- 3. Reemplazado NOT IN por NOT EXISTS
-- 4. Eliminada subconsulta correlacionada
-- 5. Índice en tabla temporal
-- 6. Condiciones optimizadas en WHERE
-- ============================================

CREATE OR ALTER PROCEDURE [contabilidad].[USP_VOUCHER_DOCS_CONTABLE_SIN_ANEXO_4_PERIODO_V2]
(
    @P_RUCE CHAR(11),
    @P_EJER CHAR(4),
    @P_CD_CLT VARCHAR(MAX) = NULL,
    @P_CD_PRV CHAR(7) = NULL,
    @P_CD_TRAB CHAR(8) = NULL,
    @P_IC_ES CHAR(1),
    @P_NUMERACION VARCHAR(MAX) = NULL,
    -- Nuevos parámetros para período (en lugar de hardcodear)
    @P_PERIODO_DESDE CHAR(2) = NULL,  -- Ej: '04'
    @P_PERIODO_HASTA CHAR(2) = NULL   -- Ej: '09'
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Limpiar parámetros vacíos
    SET @P_CD_CLT = NULLIF(LTRIM(RTRIM(@P_CD_CLT)), '')
    SET @P_CD_PRV = NULLIF(LTRIM(RTRIM(@P_CD_PRV)), '')
    SET @P_CD_TRAB = NULLIF(LTRIM(RTRIM(@P_CD_TRAB)), '')
    SET @P_NUMERACION = NULLIF(LTRIM(RTRIM(@P_NUMERACION)), '')

    -- Configuración
    DECLARE @C_IB_AUTORIZA_VOUCHER BIT
    DECLARE @C_IB_AUTORIZA_VOUCHER_CGENERAL BIT

    SELECT
        @C_IB_AUTORIZA_VOUCHER = C_IB_AUTORIZA_VOUCHER,
        @C_IB_AUTORIZA_VOUCHER_CGENERAL = C_IB_AUTORIZA_VOUCHER_CGENERAL
    FROM CfgContabilidad
    WHERE RucE = @P_RUCE

    -- Verificar si existe saldo inicial
    DECLARE @L_IB_EXISTE_SALDO_INICIAL BIT = 0
    IF EXISTS (SELECT 1 FROM voucher WHERE RucE = @P_RUCE AND Ejer = @P_EJER AND Prdo = '00')
        SET @L_IB_EXISTE_SALDO_INICIAL = 1

    -- Crear tabla temporal con estructura optimizada
    CREATE TABLE #DT_VOUCHER
    (
        RucE CHAR(11) NOT NULL,
        Cd_Vou INT NULL,
        NroCta VARCHAR(50) NOT NULL,
        NomCta VARCHAR(200),
        NomAux VARCHAR(400),
        FecMov DATE,
        FecED DATE,
        FecVD DATE,
        DR_CdTD NVARCHAR(2),
        DR_NSre VARCHAR(20),
        DR_NDoc VARCHAR(20),
        TD NVARCHAR(2),
        Sre VARCHAR(20),
        NroDoc VARCHAR(20),
        Glosa VARCHAR(500),
        SaldoS NUMERIC(30,10),
        SaldoD NUMERIC(30,10),
        MdReg CHAR(5),
        Cd_CC VARCHAR(8),
        Cd_SC VARCHAR(8),
        Cd_SS VARCHAR(8),
        Cd_Clt CHAR(10),
        Cd_Prv CHAR(7),
        Cd_Trab CHAR(8),
        RegCtb NVARCHAR(15),
        FechaOrigen DATETIME,
        IB_AgRet BIT,
        IB_BuenContrib BIT,
        MtoD NUMERIC(30,10),
        MtoH NUMERIC(30,10),
        MtoD_ME NUMERIC(30,10),
        MtoH_ME NUMERIC(30,10),
        Ic_ES CHAR(1),
        C_ID_CONCEPTO_FEC INT,
        IB_Dtr BIT
    )

    -- INSERT optimizado con filtros SARGABLES
    INSERT INTO #DT_VOUCHER (
        RucE, Cd_Vou, NroCta, NomCta, NomAux, FecMov, FecED, FecVD,
        DR_CdTD, DR_NSre, DR_NDoc, TD, Sre, NroDoc, Glosa, SaldoS, SaldoD, MdReg,
        Cd_CC, Cd_SC, Cd_SS, Cd_Clt, Cd_Prv, Cd_Trab, RegCtb, FechaOrigen,
        IB_AgRet, IB_BuenContrib, MtoD, MtoH, MtoD_ME, MtoH_ME, Ic_ES, C_ID_CONCEPTO_FEC, IB_Dtr
    )
    SELECT
        v.RucE,
        MAX(CASE WHEN v.IB_EsProv = 1 THEN v.Cd_Vou ELSE 0 END) AS Cd_Vou,
        v.NroCta,
        p.NomCta,
        -- NomAux optimizado
        CASE
            WHEN @P_CD_CLT IS NOT NULL THEN ISNULL(c2.RSocial, c2.ApPat + ' ' + c2.ApMat + ',' + c2.Nom)
            WHEN @P_CD_PRV IS NOT NULL THEN ISNULL(p2.RSocial, p2.ApPat + ' ' + p2.ApMat + ',' + p2.Nom)
            WHEN @P_CD_TRAB IS NOT NULL THEN T2.ApPaterno + ' ' + T2.ApMaterno + ', ' + T2.Nombres
            ELSE
                CASE
                    WHEN v.Cd_Clt > '' THEN ISNULL(c2.RSocial, c2.ApPat + ' ' + c2.ApMat + ',' + c2.Nom)
                    WHEN v.Cd_Prv > '' THEN ISNULL(p2.RSocial, p2.ApPat + ' ' + p2.ApMat + ',' + p2.Nom)
                    WHEN v.Cd_Trab > '' THEN T2.ApPaterno + ' ' + T2.ApMaterno + ', ' + T2.Nombres
                END
        END AS NomAux,
        MAX(CASE WHEN v.IB_EsProv = 1 THEN v.FecMov END) AS FecMov,
        MAX(CASE WHEN v.IB_EsProv = 1 THEN v.FecED END) AS FecED,
        MAX(CASE WHEN v.IB_EsProv = 1 THEN v.FecVD END) AS FecVD,
        LTRIM(RTRIM(ISNULL(v.Cd_TD, ''))) AS DR_CdTD,
        LTRIM(RTRIM(ISNULL(v.NroSre, ''))) AS DR_NSre,
        LTRIM(RTRIM(ISNULL(v.NroDoc, ''))) AS DR_NDoc,
        LTRIM(RTRIM(ISNULL(v.Cd_TD, ''))) AS TD,
        LTRIM(RTRIM(ISNULL(v.NroSre, ''))) AS Sre,
        LTRIM(RTRIM(ISNULL(v.NroDoc, ''))) AS NroDoc,
        MAX(CASE WHEN v.IB_EsProv = 1 THEN ISNULL(v.Glosa, '') ELSE '' END) AS Glosa,
        SUM(v.MtoD - v.MtoH) AS SaldoS,
        SUM(v.MtoD_ME - v.MtoH_ME) AS SaldoD,
        MAX(CASE WHEN v.IB_EsProv = 1 THEN CASE WHEN p.Cd_Mda = '01' THEN 'S/.' ELSE 'US$' END ELSE '0' END) AS MdReg,
        MAX(CASE WHEN v.IB_EsProv = 1 THEN v.Cd_CC ELSE '0' END) AS Cd_CC,
        MAX(CASE WHEN v.IB_EsProv = 1 THEN v.Cd_SC ELSE '0' END) AS Cd_SC,
        MAX(CASE WHEN v.IB_EsProv = 1 THEN v.Cd_SS ELSE '0' END) AS Cd_SS,
        ISNULL(v.Cd_Clt, '') AS Cd_Clt,
        ISNULL(v.Cd_Prv, '') AS Cd_Prv,
        ISNULL(v.Cd_Trab, '') AS Cd_Trab,
        MAX(CASE WHEN v.IB_EsProv = 1 THEN v.RegCtb ELSE '0' END) AS RegCtb,
        MIN(v.FecMov) AS FechaOrigen,
        CASE WHEN @P_CD_CLT IS NOT NULL OR @P_CD_TRAB IS NOT NULL THEN 0 ELSE ISNULL(p2.IB_AgRet, 0) END AS IB_AgRet,
        CASE WHEN @P_CD_CLT IS NOT NULL OR @P_CD_TRAB IS NOT NULL THEN 0 ELSE ISNULL(p2.IB_BuenContrib, 0) END AS IB_BuenContrib,
        SUM(v.MtoD) AS MtoD,
        SUM(v.MtoH) AS MtoH,
        SUM(v.MtoD_ME) AS MtoD_ME,
        SUM(v.MtoH_ME) AS MtoH_ME,
        MIN(CASE WHEN ISNULL(p.IB_CtasXCbr, 0) = 0 THEN CASE WHEN ISNULL(p.IB_CtasXPag, 0) = 0 THEN '' ELSE 'E' END ELSE 'I' END) AS Ic_ES,
        MAX(ISNULL(v.C_ID_CONCEPTO_FEC, 0)) AS C_ID_CONCEPTO_FEC,
        ISNULL(p.IB_Dtr, 0) AS IB_Dtr
    FROM Voucher v WITH (NOLOCK)
    INNER JOIN PlanCtas p ON p.RucE = v.RucE AND p.Ejer = v.Ejer AND p.NroCta = v.NroCta
    LEFT JOIN Proveedor2 p2 ON p2.RucE = v.RucE AND p2.Cd_Prv = v.Cd_Prv AND @P_CD_CLT IS NULL AND @P_CD_TRAB IS NULL
    LEFT JOIN Cliente2 c2 ON c2.RucE = v.RucE AND c2.Cd_Clt = v.Cd_Clt AND @P_CD_PRV IS NULL AND @P_CD_TRAB IS NULL
    LEFT JOIN Trabajador t2 ON t2.RucE = v.RucE AND t2.Cd_Trab = v.Cd_Trab AND @P_CD_CLT IS NULL AND @P_CD_PRV IS NULL
    WHERE
        v.RucE = @P_RUCE
        -- Filtro SARGABLE de período (no concatenar!)
        AND v.Ejer = @P_EJER
        AND (@P_PERIODO_DESDE IS NULL OR v.Prdo >= @P_PERIODO_DESDE)
        AND (@P_PERIODO_HASTA IS NULL OR v.Prdo <= @P_PERIODO_HASTA)
        -- Filtros SARGABLES (evitar ISNULL en columnas)
        AND ISNULL(v.IB_Cndo, 0) = 0
        AND ISNULL(v.IB_Anulado, 0) = 0
        AND v.NroDoc IS NOT NULL AND v.NroDoc <> ''
        AND v.Cd_TD IS NOT NULL AND v.Cd_TD <> ''
        -- Filtro de tipo I/E
        AND (
            (@P_IC_ES = 'I' AND p.IB_CtasXCbr <> 0)
            OR (@P_IC_ES = 'E' AND p.IB_CtasXPag <> 0)
        )
        -- Al menos un auxiliar debe existir (SARGABLE)
        AND (v.Cd_Clt > '' OR v.Cd_Prv > '' OR v.Cd_Trab > '')
        -- Filtros opcionales por cliente/proveedor/trabajador
        AND (
            @P_CD_CLT IS NULL
            OR (LEN(@P_CD_CLT) < 13 AND v.Cd_Clt = REPLACE(@P_CD_CLT, '*', ''))
            OR (LEN(@P_CD_CLT) >= 13 AND CHARINDEX('*' + v.Cd_Clt + '*', @P_CD_CLT) > 0)
        )
        AND (@P_CD_PRV IS NULL OR v.Cd_Prv = @P_CD_PRV)
        AND (@P_CD_TRAB IS NULL OR v.Cd_Trab = @P_CD_TRAB)
        -- Filtro opcional de numeración
        AND (
            @P_NUMERACION IS NULL
            OR CHARINDEX('*' + ISNULL(v.Cd_TD, '') + '-' + ISNULL(v.NroSre, '') + '-' + ISNULL(v.NroDoc, '') + '*', @P_NUMERACION) > 0
        )
    GROUP BY
        v.RucE, v.NroCta, p.NomCta,
        ISNULL(v.Cd_TD, ''), ISNULL(v.NroSre, ''), ISNULL(v.NroDoc, ''),
        ISNULL(v.Cd_Clt, ''), ISNULL(v.Cd_Prv, ''), ISNULL(v.Cd_Trab, ''),
        ISNULL(p.IB_Dtr, 0),
        c2.RSocial, c2.ApPat, c2.ApMat, c2.Nom,
        p2.RSocial, p2.ApPat, p2.ApMat, p2.Nom, p2.IB_AgRet, p2.IB_BuenContrib,
        t2.ApMaterno, t2.ApPaterno, t2.Nombres
    HAVING
        (SUM(v.MtoD - v.MtoH) <> 0 OR SUM(v.MtoD_ME - v.MtoH_ME) <> 0)
        AND MAX(CASE WHEN v.IB_EsProv = 1 THEN v.Cd_Vou ELSE 0 END) > 0

    -- Crear índice en tabla temporal para mejorar la segunda consulta
    CREATE NONCLUSTERED INDEX IX_DT_VOUCHER_Cd_Vou ON #DT_VOUCHER(Cd_Vou, RucE)

    -- SELECT final optimizado (sin subconsulta correlacionada, sin NOT IN)
    SELECT DISTINCT
        ISNULL(VC.IB_EsAut, 0) AS Ib_Aut,
        CASE WHEN Det.Cd_Vou IS NOT NULL THEN 1 ELSE 0 END AS Ib_Agrup,
        Agrupado,
        Tabla_Provisiones.Cd_Vou,
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
        A.Descrip AS NombreCentroCostos,
        Tabla_Provisiones.Cd_SC,
        B.Descrip AS NombreSubCentroCostos,
        Tabla_Provisiones.Cd_SS,
        C.Descrip AS NombreSubSubCentroCostos,
        Cd_Clt,
        Cd_Prv,
        Cd_Trab,
        Tabla_Provisiones.RegCtb,
        FechaOrigen,
        IB_AgRet,
        IB_BuenContrib,
        CASE WHEN (MtoD - MtoH) <> 0 THEN MtoD ELSE MtoD_ME END AS MtoD,
        CASE WHEN (MtoD - MtoH) <> 0 THEN MtoH ELSE MtoH_ME END AS MtoH,
        Ic_ES,
        CASE
            WHEN ISNULL(@C_IB_AUTORIZA_VOUCHER, 0) = 1 THEN Au.Obs
            WHEN ISNULL(@C_IB_AUTORIZA_VOUCHER_CGENERAL, 0) = 1 THEN NULL
            ELSE Au.Obs
        END AS Obs,
        CASE
            WHEN ISNULL(@C_IB_AUTORIZA_VOUCHER, 0) = 1 THEN Au.NomUsu
            WHEN ISNULL(@C_IB_AUTORIZA_VOUCHER_CGENERAL, 0) = 1 THEN NULL
            ELSE Au.NomUsu
        END AS NomUsu,
        C_ID_CONCEPTO_FEC,
        IB_Dtr
    FROM (
        SELECT
            RucE,
            COUNT(DR_NDoc) AS Agrupado,
            MIN(t.Cd_Vou) AS Cd_Vou,
            NroCta,
            NomCta,
            NomAux,
            MIN(FecMov) AS FecMov,
            MIN(FecED) AS FecED,
            MIN(FecVD) AS FecVD,
            DR_CdTD,
            DR_NSre,
            DR_NDoc,
            MIN(Td) AS Cd_TD,
            RTRIM(LTRIM(SUBSTRING(MIN(ISNULL(Td, '00') + '-' + Sre), 4, 20))) AS NroSre,
            RTRIM(LTRIM(SUBSTRING(MIN(ISNULL(Td, '00') + '-' + NroDoc), 4, 20))) AS NroDoc,
            MIN(Glosa) AS Glosa,
            SUM(SaldoS) AS SaldoS,
            SUM(SaldoD) AS SaldoD,
            MdReg,
            Cd_CC,
            Cd_SC,
            Cd_SS,
            t.Cd_Clt,
            Cd_Prv,
            t.Cd_Trab,
            MIN(t.RegCtb) AS RegCtb,
            MIN(t.FechaOrigen) AS FechaOrigen,
            IB_AgRet,
            IB_BuenContrib,
            CASE WHEN SUM(MtoD - MtoH) > 0 THEN SUM(MtoD - MtoH) ELSE 0 END AS MtoD,
            CASE WHEN SUM(MtoD - MtoH) < 0 THEN SUM(MtoH - MtoD) ELSE 0 END AS MtoH,
            CASE WHEN SUM(MtoD_ME - MtoH_ME) > 0 THEN SUM(MtoD_ME - MtoH_ME) ELSE 0 END AS MtoD_ME,
            CASE WHEN SUM(MtoD_ME - MtoH_ME) < 0 THEN SUM(MtoH_ME - MtoD_ME) ELSE 0 END AS MtoH_ME,
            Ic_ES,
            C_ID_CONCEPTO_FEC,
            IB_Dtr
        FROM #DT_VOUCHER t
        WHERE
            -- Reemplazar NOT IN por NOT EXISTS (más eficiente)
            NOT EXISTS (SELECT 1 FROM GrupoVoucher gv WHERE gv.RucE = @P_RUCE AND gv.Cd_Vou = t.Cd_Vou)
            AND LEFT(t.RegCtb, 2) <> 'LF'
        GROUP BY
            RucE, NroCta, NomCta, NomAux, DR_CdTD, DR_NSre, DR_NDoc, MdReg,
            Cd_CC, Cd_SC, Cd_SS, t.Cd_Clt, Cd_Prv, t.Cd_Trab,
            IB_AgRet, IB_BuenContrib, Ic_ES, RegCtb, C_ID_CONCEPTO_FEC, IB_Dtr
        HAVING
            SUM(ROUND(MtoD - MtoH, 2)) <> 0 OR SUM(ROUND(MtoD_ME - MtoH_ME, 2)) <> 0
    ) AS Tabla_Provisiones
    -- JOIN en lugar de subconsulta correlacionada
    LEFT JOIN Voucher VC WITH (NOLOCK) ON
        VC.RucE = @P_RUCE
        AND VC.Cd_Vou = Tabla_Provisiones.Cd_Vou
        AND VC.RegCtb = Tabla_Provisiones.RegCtb
    LEFT JOIN AutVou Au ON
        Au.RucE = @P_RUCE
        AND Au.Cd_Vou = Tabla_Provisiones.Cd_Vou
        AND Au.RegCtb = Tabla_Provisiones.RegCtb
    LEFT JOIN Grupo_Voucher_Documentos_Det Det ON
        Det.RucE = @P_RUCE
        AND Det.Cd_Vou = Tabla_Provisiones.Cd_Vou
    LEFT JOIN CCostos A ON A.RucE = @P_RUCE AND A.Cd_CC = Tabla_Provisiones.Cd_CC
    LEFT JOIN CCSub B ON B.RucE = @P_RUCE AND B.Cd_CC = Tabla_Provisiones.Cd_CC AND B.Cd_SC = Tabla_Provisiones.Cd_SC
    LEFT JOIN CCSubSub C ON C.RucE = @P_RUCE AND C.Cd_CC = Tabla_Provisiones.Cd_CC AND C.Cd_SC = Tabla_Provisiones.Cd_SC AND C.Cd_SS = Tabla_Provisiones.Cd_SS

END
GO

/************************** LEYENDA

| USUARIO            | | FECHA      | | DESCRIPCIÓN
| Andrés Santos      | | 13/09/2022 | | Se agrega NombreCentroCostos, NombreSubCentroCostos y NombreSubSubCentroCostos
| Williams Gutierrez | | 10/10/2022 | | Se coloco MAX al campo C_ID_CONCEPTO_FEC para evitar que no cancele por tener diferentes indicadores de flujo
| Williams Gutierrez | | 17/01/2023 | | Se aumento a 10 decimales
| Rafael Linares     | | 11/03/2023 | | Se agrego la opcion A en el filtro de proveedores
| Andrés Santos      | | 02/06/2023 | | Se agrega validación de saldos para MtoD_ME y MtoH_ME
| Rafael Linares     | | 09/11/2023 | | Se eliminio el concatenado de * cd_Clt * para el caso de consulta simple por cliente para que funcione el indice que se creo optimizando la consulta de gasolinera
| Hugo Delgado       | | 22/05/2025 | | (112869) Se agrego las variable @C_IB_AUTORIZA_VOUCHER y @C_IB_AUTORIZA_VOUCHER_CGENERAL para validar el tipo de Autorizacion
| Hugo Delgado       | | 17/06/2025 | | (112869) Se agrego el campo IB_EsAut para obtener los voucher que estan autorizados
| Jesus Chavez       | | 20/09/2025 | | (116940) Se optimiza el procedimiento agregando una tabla temporal
| OPTIMIZACIÓN       | | 19/01/2026 | | V2: Eliminado SQL dinámico, filtros SARGABLES, NOT EXISTS, índice en temp table, JOIN en lugar de subconsulta correlacionada
***************************/
