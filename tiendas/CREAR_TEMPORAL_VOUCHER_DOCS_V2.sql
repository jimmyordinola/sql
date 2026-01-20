-- ============================================
-- Script para crear tabla temporal con resultados de
-- USP_VOUCHER_DOCS_CONTABLE_SIN_ANEXO_4_ORIGINAL
-- OPCION 2: Sin OPENROWSET
-- ============================================

USE [ERP_ECHA]
GO

-- Limpiar tabla si existe
IF OBJECT_ID('dbo.TEMPORAL_VOUCHER_DOCS') IS NOT NULL
    DROP TABLE dbo.TEMPORAL_VOUCHER_DOCS
GO

-- Primero verificar la estructura del SP
DECLARE @sp NVARCHAR(MAX) = N'EXEC contabilidad.USP_VOUCHER_DOCS_CONTABLE_SIN_ANEXO_4_ORIGINAL @P_RUCE=N''20102351038'',@P_EJER=N''2025'',@P_CD_CLT=NULL,@P_CD_PRV=NULL,@P_CD_TRAB=NULL,@P_IC_ES=N''I'',@P_NUMERACION=NULL'

-- Ver estructura (debug)
SELECT * FROM sys.dm_exec_describe_first_result_set(@sp, NULL, 0)
GO

-- ============================================
-- OPCION A: Si el SP tiene SET NOCOUNT ON y retorna un solo result set
-- ============================================
/*
EXEC contabilidad.USP_VOUCHER_DOCS_CONTABLE_SIN_ANEXO_4_ORIGINAL
    @P_RUCE = '20102351038',
    @P_EJER = N'2025',
    @P_CD_CLT = NULL,
    @P_CD_PRV = NULL,
    @P_CD_TRAB = NULL,
    @P_IC_ES = 'I',
    @P_NUMERACION = NULL
*/

-- ============================================
-- OPCION B: Crear tabla manualmente basada en la estructura conocida
-- (Ejecuta primero el SELECT de arriba para ver las columnas)
-- ============================================

-- Basado en la estructura real del SP (corregido):
CREATE TABLE TEMPORAL_VOUCHER_DOCS (
    Ib_Aut INT NULL,
    Ib_Agrup INT NULL,
    Agrupado INT NULL,
    Cd_Vou INT NULL,
    NroCta VARCHAR(50) NULL,
    NomCta VARCHAR(200) NULL,
    NomAux VARCHAR(400) NULL,
    FecMov DATE NULL,
    FecED DATE NULL,
    FecVD DATE NULL,
    DR_CdTD NVARCHAR(2) NULL,
    DR_NSre VARCHAR(20) NULL,
    DR_NDoc VARCHAR(20) NULL,          -- Corregido: era BIGINT, es VARCHAR
    Cd_Td NVARCHAR(2) NULL,            -- Corregido: era INT, es NVARCHAR(2)
    NroSre VARCHAR(20) NULL,
    NroDoc VARCHAR(20) NULL,           -- Corregido: era BIGINT, es VARCHAR
    Glosa VARCHAR(500) NULL,
    SaldoS NUMERIC(30,10) NULL,
    SaldoD NUMERIC(30,10) NULL,
    MdReg CHAR(5) NULL,
    Cd_CC VARCHAR(8) NULL,             -- Corregido: era INT, es VARCHAR(8)
    NombreCentroCostos VARCHAR(200) NULL,
    Cd_SC VARCHAR(8) NULL,             -- Corregido: era INT, es VARCHAR(8)
    NombreSubCentroCostos VARCHAR(200) NULL,
    Cd_SS VARCHAR(8) NULL,             -- Corregido: era INT, es VARCHAR(8)
    NombreSubSubCentroCostos VARCHAR(200) NULL,
    Cd_Clt CHAR(10) NULL,
    Cd_Prv CHAR(7) NULL,
    Cd_Trab CHAR(8) NULL,
    RegCtb NVARCHAR(15) NULL,
    FechaOrigen DATETIME NULL,
    IB_AgRet BIT NULL,                 -- Corregido: era INT, es BIT
    IB_BuenContrib BIT NULL,           -- Corregido: era INT, es BIT
    MtoD NUMERIC(30,10) NULL,
    MtoH NUMERIC(30,10) NULL,
    Ic_ES CHAR(1) NULL,
    Obs VARCHAR(500) NULL,
    NomUsu VARCHAR(100) NULL,
    C_ID_CONCEPTO_FEC INT NULL,
    IB_Dtr BIT NULL                    -- Corregido: era INT, es BIT
)
GO

-- Insertar datos
INSERT INTO TEMPORAL_VOUCHER_DOCS
EXEC contabilidad.USP_VOUCHER_DOCS_CONTABLE_SIN_ANEXO_4_ORIGINAL
    @P_RUCE = '20102351038',
    @P_EJER = N'2025',
    @P_CD_CLT = NULL,
    @P_CD_PRV = NULL,
    @P_CD_TRAB = NULL,
    @P_IC_ES = 'I',
    @P_NUMERACION = NULL
GO

-- Verificar resultados
SELECT COUNT(*) AS TotalFilas FROM TEMPORAL_VOUCHER_DOCS
SELECT TOP 10 * FROM TEMPORAL_VOUCHER_DOCS
GO
