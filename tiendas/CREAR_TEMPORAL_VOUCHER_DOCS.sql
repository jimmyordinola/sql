-- ============================================
-- Script para crear tabla temporal con resultados de
-- USP_VOUCHER_DOCS_CONTABLE_SIN_ANEXO_4_ORIGINAL
-- ============================================

USE [ERP_ECHA]
GO

-- Limpiar tabla si existe
IF OBJECT_ID('dbo.TEMPORAL_VOUCHER_DOCS') IS NOT NULL
    DROP TABLE dbo.TEMPORAL_VOUCHER_DOCS
GO

-- Insertar directamente con SELECT INTO
SELECT * INTO TEMPORAL_VOUCHER_DOCS
FROM OPENROWSET(
    'SQLNCLI',
    'Server=(local);Trusted_Connection=yes;',
    'EXEC ERP_ECHA.contabilidad.USP_VOUCHER_DOCS_CONTABLE_SIN_ANEXO_4_ORIGINAL
        @P_RUCE = N''20102351038'',
        @P_EJER = N''2025'',
        @P_CD_CLT = N'''',
        @P_CD_PRV = N''       '',
        @P_CD_TRAB = N''        '',
        @P_IC_ES = N''I'',
        @P_NUMERACION = NULL'
)

SELECT * FROM TEMPORAL_VOUCHER_DOCS
GO
