USE [ERP_ECHA]
GO

-- ============================================
-- Script para POBLAR/ACTUALIZAR la tabla
-- TEMPORAL_VOUCHER_DOCS con datos frescos
-- ============================================
-- Ejecutar este script:
-- - Como Job de SQL Agent (cada 5-10 minutos)
-- - Manualmente cuando se necesite datos actualizados
-- ============================================

SET NOCOUNT ON;

DECLARE @Inicio DATETIME = GETDATE()
DECLARE @Filas INT

PRINT '============================================'
PRINT 'Iniciando poblado de TEMPORAL_VOUCHER_DOCS'
PRINT 'Inicio: ' + CONVERT(VARCHAR, @Inicio, 120)
PRINT '============================================'

-- Crear tabla si no existe
IF OBJECT_ID('dbo.TEMPORAL_VOUCHER_DOCS') IS NULL
BEGIN
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
        DR_NDoc VARCHAR(20) NULL,
        Cd_Td NVARCHAR(2) NULL,
        NroSre VARCHAR(20) NULL,
        NroDoc VARCHAR(20) NULL,
        Glosa VARCHAR(500) NULL,
        SaldoS NUMERIC(30,10) NULL,
        SaldoD NUMERIC(30,10) NULL,
        MdReg CHAR(5) NULL,
        Cd_CC VARCHAR(8) NULL,
        NombreCentroCostos VARCHAR(200) NULL,
        Cd_SC VARCHAR(8) NULL,
        NombreSubCentroCostos VARCHAR(200) NULL,
        Cd_SS VARCHAR(8) NULL,
        NombreSubSubCentroCostos VARCHAR(200) NULL,
        Cd_Clt CHAR(10) NULL,
        Cd_Prv CHAR(7) NULL,
        Cd_Trab CHAR(8) NULL,
        RegCtb NVARCHAR(15) NULL,
        FechaOrigen DATETIME NULL,
        IB_AgRet BIT NULL,
        IB_BuenContrib BIT NULL,
        MtoD NUMERIC(30,10) NULL,
        MtoH NUMERIC(30,10) NULL,
        Ic_ES CHAR(1) NULL,
        Obs VARCHAR(500) NULL,
        NomUsu VARCHAR(100) NULL,
        C_ID_CONCEPTO_FEC INT NULL,
        IB_Dtr BIT NULL
    )
    PRINT 'Tabla TEMPORAL_VOUCHER_DOCS creada'
END

-- Limpiar datos existentes
TRUNCATE TABLE TEMPORAL_VOUCHER_DOCS
PRINT 'Tabla truncada'

-- Insertar datos frescos del SP original
PRINT 'Ejecutando SP original para obtener datos...'

INSERT INTO TEMPORAL_VOUCHER_DOCS
EXEC contabilidad.USP_VOUCHER_DOCS_CONTABLE_SIN_ANEXO_4_ORIGINAL
    @P_RUCE = '20102351038',
    @P_EJER = '2025',
    @P_CD_CLT = NULL,
    @P_CD_PRV = NULL,
    @P_CD_TRAB = NULL,
    @P_IC_ES = 'I',
    @P_NUMERACION = NULL

SET @Filas = @@ROWCOUNT

-- Tambien insertar los de Egreso (E)
INSERT INTO TEMPORAL_VOUCHER_DOCS
EXEC contabilidad.USP_VOUCHER_DOCS_CONTABLE_SIN_ANEXO_4_ORIGINAL
    @P_RUCE = '20102351038',
    @P_EJER = '2025',
    @P_CD_CLT = NULL,
    @P_CD_PRV = NULL,
    @P_CD_TRAB = NULL,
    @P_IC_ES = 'E',
    @P_NUMERACION = NULL

SET @Filas = @Filas + @@ROWCOUNT

-- Crear indices para optimizar consultas
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_TEMPORAL_VOUCHER_Ic_ES')
BEGIN
    CREATE NONCLUSTERED INDEX IX_TEMPORAL_VOUCHER_Ic_ES
    ON TEMPORAL_VOUCHER_DOCS (Ic_ES)
    INCLUDE (Cd_Clt, Cd_Prv, Cd_Trab)
    PRINT 'Indice IX_TEMPORAL_VOUCHER_Ic_ES creado'
END

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_TEMPORAL_VOUCHER_Cd_Clt')
BEGIN
    CREATE NONCLUSTERED INDEX IX_TEMPORAL_VOUCHER_Cd_Clt
    ON TEMPORAL_VOUCHER_DOCS (Cd_Clt)
    WHERE Cd_Clt IS NOT NULL AND Cd_Clt <> ''
    PRINT 'Indice IX_TEMPORAL_VOUCHER_Cd_Clt creado'
END

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_TEMPORAL_VOUCHER_Cd_Prv')
BEGIN
    CREATE NONCLUSTERED INDEX IX_TEMPORAL_VOUCHER_Cd_Prv
    ON TEMPORAL_VOUCHER_DOCS (Cd_Prv)
    WHERE Cd_Prv IS NOT NULL AND Cd_Prv <> ''
    PRINT 'Indice IX_TEMPORAL_VOUCHER_Cd_Prv creado'
END

PRINT '============================================'
PRINT 'Poblado completado'
PRINT 'Filas insertadas: ' + CAST(@Filas AS VARCHAR)
PRINT 'Duracion: ' + CAST(DATEDIFF(SECOND, @Inicio, GETDATE()) AS VARCHAR) + ' segundos'
PRINT 'Fin: ' + CONVERT(VARCHAR, GETDATE(), 120)
PRINT '============================================'
GO
