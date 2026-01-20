-- ============================================
-- Script comparativo V1 vs V2
-- ============================================

USE [ERP_ECHA]
GO

-- ============================================
-- PASO 1: Crear índice recomendado (ejecutar una sola vez)
-- ============================================
/*
-- Índice para optimizar búsquedas en Voucher
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Voucher_RucE_Ejer_Prdo_Optimizado')
BEGIN
    CREATE NONCLUSTERED INDEX IX_Voucher_RucE_Ejer_Prdo_Optimizado
    ON dbo.Voucher (RucE, Ejer, Prdo, IB_Cndo, IB_Anulado)
    INCLUDE (NroCta, Cd_Vou, IB_EsProv, FecMov, FecED, FecVD, Cd_TD, NroSre, NroDoc,
             Glosa, MtoD, MtoH, MtoD_ME, MtoH_ME, Cd_CC, Cd_SC, Cd_SS,
             Cd_Clt, Cd_Prv, Cd_Trab, RegCtb, C_ID_CONCEPTO_FEC, IB_EsAut)
    WITH (ONLINE = ON, SORT_IN_TEMPDB = ON);

    PRINT 'Índice IX_Voucher_RucE_Ejer_Prdo_Optimizado creado exitosamente'
END
*/

-- ============================================
-- PASO 2: Prueba comparativa
-- ============================================

SET STATISTICS TIME ON
SET STATISTICS IO ON

PRINT '=========================================='
PRINT 'PRUEBA V1 (Original)'
PRINT '=========================================='

DECLARE @Start1 DATETIME2 = SYSDATETIME()

EXEC contabilidad.USP_VOUCHER_DOCS_CONTABLE_SIN_ANEXO_4
    @P_RUCE = '20102351038',
    @P_EJER = N'2025',
    @P_CD_CLT = '',
    @P_CD_PRV = '       ',
    @P_CD_TRAB = '        ',
    @P_IC_ES = 'I',
    @P_NUMERACION = NULL

DECLARE @End1 DATETIME2 = SYSDATETIME()

PRINT ''
PRINT 'V1 TIEMPO TOTAL: ' + CAST(DATEDIFF(MILLISECOND, @Start1, @End1) AS VARCHAR(20)) + ' ms'
PRINT ''

PRINT '=========================================='
PRINT 'PRUEBA V2 (Optimizada)'
PRINT '=========================================='

DECLARE @Start2 DATETIME2 = SYSDATETIME()

EXEC contabilidad.USP_VOUCHER_DOCS_CONTABLE_SIN_ANEXO_4_PERIODO_V2
    @P_RUCE = '20102351038',
    @P_EJER = N'2025',
    @P_CD_CLT = NULL,
    @P_CD_PRV = NULL,
    @P_CD_TRAB = NULL,
    @P_IC_ES = 'I',
    @P_NUMERACION = NULL,
    @P_PERIODO_DESDE = '08',  -- Ajustar según necesidad
    @P_PERIODO_HASTA = '11'   -- Ajustar según necesidad

DECLARE @End2 DATETIME2 = SYSDATETIME()

PRINT ''
PRINT 'V2 TIEMPO TOTAL: ' + CAST(DATEDIFF(MILLISECOND, @Start2, @End2) AS VARCHAR(20)) + ' ms'
PRINT ''

SET STATISTICS TIME OFF
SET STATISTICS IO OFF

PRINT '=========================================='
PRINT 'RESUMEN COMPARATIVO'
PRINT '=========================================='
PRINT 'V1 (Original):   ' + CAST(DATEDIFF(MILLISECOND, @Start1, @End1) AS VARCHAR(20)) + ' ms'
PRINT 'V2 (Optimizada): ' + CAST(DATEDIFF(MILLISECOND, @Start2, @End2) AS VARCHAR(20)) + ' ms'
PRINT 'Mejora:          ' + CAST(
    CAST(DATEDIFF(MILLISECOND, @Start1, @End1) - DATEDIFF(MILLISECOND, @Start2, @End2) AS FLOAT)
    / NULLIF(DATEDIFF(MILLISECOND, @Start1, @End1), 0) * 100 AS VARCHAR(20)) + ' %'
PRINT '=========================================='
GO
