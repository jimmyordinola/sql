USE [ERP_ECHA]
GO

-- ============================================
-- SP OPTIMIZADO - Lee de tabla pre-calculada
-- Basado en: USP_VOUCHER_DOCS_CONTABLE_SIN_ANEXO_4_ORIGINAL
-- ============================================
-- IMPORTANTE: Excluye automaticamente documentos consumidos:
--   1. Vouchers en GrupoVoucher (ya agrupados)
--   2. Vouchers con IB_Cndo = 1 (cancelados) - ya filtrado en origen
-- ============================================

CREATE OR ALTER PROCEDURE [contabilidad].[USP_VOUCHER_DOCS_CONTABLE_SIN_ANEXO_4_OPTIMIZADO]
(
    @P_RUCE CHAR(11),
    @P_EJER CHAR(4),
    @P_CD_CLT VARCHAR(MAX) = NULL,
    @P_CD_PRV CHAR(7) = NULL,
    @P_CD_TRAB CHAR(8) = NULL,
    @P_IC_ES CHAR(1),
    @P_NUMERACION VARCHAR(MAX) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    -- =============================================
    -- VERSION OPTIMIZADA: Lee de TEMPORAL_VOUCHER_DOCS
    -- Excluye documentos ya consumidos (en GrupoVoucher)
    -- =============================================

    SELECT
        t.Ib_Aut,
        t.Ib_Agrup,
        t.Agrupado,
        t.Cd_Vou,
        t.NroCta,
        t.NomCta,
        t.NomAux,
        t.FecMov,
        t.FecED,
        t.FecVD,
        t.DR_CdTD,
        t.DR_NSre,
        t.DR_NDoc,
        t.Cd_Td,
        t.NroSre,
        t.NroDoc,
        t.Glosa,
        t.SaldoS,
        t.SaldoD,
        t.MdReg,
        t.Cd_CC,
        t.NombreCentroCostos,
        t.Cd_SC,
        t.NombreSubCentroCostos,
        t.Cd_SS,
        t.NombreSubSubCentroCostos,
        t.Cd_Clt,
        t.Cd_Prv,
        t.Cd_Trab,
        t.RegCtb,
        t.FechaOrigen,
        t.IB_AgRet,
        t.IB_BuenContrib,
        t.MtoD,
        t.MtoH,
        t.Ic_ES,
        t.Obs,
        t.NomUsu,
        t.C_ID_CONCEPTO_FEC,
        t.IB_Dtr
    FROM TEMPORAL_VOUCHER_DOCS t
    WHERE
        -- Filtro por Ic_ES (Ingresos/Egresos)
        t.Ic_ES = @P_IC_ES

        -- *** EXCLUIR DOCUMENTOS YA CONSUMIDOS ***
        -- Vouchers que ya estan en GrupoVoucher (agrupados/procesados)
        AND t.Cd_Vou NOT IN (
            SELECT gv.Cd_Vou
            FROM GrupoVoucher gv
            WHERE gv.RucE = @P_RUCE
        )

        -- Filtro por Cliente (si se especifica)
        AND (
            ISNULL(@P_CD_CLT, '') = ''
            OR (
                LEN(@P_CD_CLT) < 13
                AND t.Cd_Clt = REPLACE(@P_CD_CLT, '*', '')
            )
            OR (
                LEN(@P_CD_CLT) >= 13
                AND CHARINDEX('*' + RTRIM(LTRIM(t.Cd_Clt)) + '*', @P_CD_CLT) > 0
            )
        )

        -- Filtro por Proveedor (si se especifica)
        AND (
            ISNULL(@P_CD_PRV, '') = ''
            OR RTRIM(LTRIM(@P_CD_PRV)) = ''
            OR t.Cd_Prv = @P_CD_PRV
        )

        -- Filtro por Trabajador (si se especifica)
        AND (
            ISNULL(@P_CD_TRAB, '') = ''
            OR RTRIM(LTRIM(@P_CD_TRAB)) = ''
            OR t.Cd_Trab = @P_CD_TRAB
        )

        -- Filtro por Numeracion (si se especifica)
        AND (
            ISNULL(@P_NUMERACION, '') = ''
            OR CHARINDEX(
                '*' + ISNULL(t.Cd_Td, '') + '-' + ISNULL(t.NroSre, '') + '-' + ISNULL(t.NroDoc, '') + '*',
                @P_NUMERACION
            ) > 0
        )

END
GO

-- ============================================
-- NOTA IMPORTANTE:
-- ============================================
-- Este SP requiere que la tabla TEMPORAL_VOUCHER_DOCS
-- este poblada previamente con los datos del SP original.
--
-- Ejecutar primero el script CREAR_TEMPORAL_VOUCHER_DOCS_V2.sql
-- para crear y poblar la tabla.
--
-- Para mantener los datos actualizados, se puede:
-- 1. Crear un Job de SQL Agent que ejecute el poblado cada X minutos
-- 2. Usar un trigger en las tablas fuente
-- 3. Ejecutar manualmente antes de usar este SP
-- ============================================

PRINT 'SP USP_VOUCHER_DOCS_CONTABLE_SIN_ANEXO_4_OPTIMIZADO creado exitosamente'
GO
