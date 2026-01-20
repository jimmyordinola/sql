-- ============================================
-- Modificar índice para USP_VOUCHER_DOCS_CONTABLE_SIN_ANEXO_4_PERIODO
-- VERSIÓN SEGURA - Para ejecutar en horario laboral
-- ============================================

USE [ERP_ECHA]
GO

-- ============================================
-- PASO 1: Crear índice nuevo con nombre temporal (SEGURO - no bloquea)
-- Ejecutar AHORA
-- ============================================

PRINT 'Creando índice IX_Voucher_RucE_Ejer_Prdo_NEW (no afecta operaciones actuales)...'

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Voucher_RucE_Ejer_Prdo_NEW' AND object_id = OBJECT_ID('dbo.Voucher'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Voucher_RucE_Ejer_Prdo_NEW
    ON dbo.Voucher (RucE, Ejer, Prdo)
    INCLUDE (
        -- Columnas que ya tenía el índice original
        FecMov, FecED, RegCtb, Cd_Fte, NroCta, Cd_Area, Cd_CC,
        Cd_MdRg, Cd_TD, NroSre, NroDoc, Glosa, MtoD, MtoH,
        MtoD_ME, MtoH_ME, IB_Anulado, Cd_Clt, Cd_Prv,
        -- Columnas nuevas que necesita el SP
        Cd_Vou, IB_EsProv, IB_Cndo, FecVD, Cd_SC, Cd_SS,
        Cd_Trab, C_ID_CONCEPTO_FEC, IB_EsAut
    )
    WITH (ONLINE = ON, SORT_IN_TEMPDB = ON, MAXDOP = 2);

    PRINT 'Índice IX_Voucher_RucE_Ejer_Prdo_NEW creado exitosamente.'
END
ELSE
BEGIN
    PRINT 'El índice IX_Voucher_RucE_Ejer_Prdo_NEW ya existe.'
END
GO

-- Verificar que el índice nuevo se creó
SELECT
    i.name AS NombreIndice,
    COUNT(CASE WHEN ic.is_included_column = 0 THEN 1 END) AS ColumnasClave,
    COUNT(CASE WHEN ic.is_included_column = 1 THEN 1 END) AS ColumnasIncluidas
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
WHERE i.object_id = OBJECT_ID('dbo.Voucher')
    AND i.name IN ('IX_Voucher_RucE_Ejer_Prdo', 'IX_Voucher_RucE_Ejer_Prdo_NEW')
GROUP BY i.name;
GO

PRINT ''
PRINT '================================================================'
PRINT 'PASO 1 COMPLETADO - El índice nuevo ya está disponible.'
PRINT 'El SP ya puede usar el nuevo índice para las consultas.'
PRINT ''
PRINT 'PASO 2: Ejecutar en HORARIO DE BAJA ACTIVIDAD (noche/fin de semana)'
PRINT '================================================================'
PRINT ''
GO

-- ============================================
-- PASO 2: Eliminar índice viejo y renombrar el nuevo
-- Ejecutar en HORARIO DE BAJA ACTIVIDAD
-- ============================================
/*
-- Descomentar y ejecutar cuando no haya usuarios trabajando:

PRINT 'Eliminando índice antiguo IX_Voucher_RucE_Ejer_Prdo...'

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Voucher_RucE_Ejer_Prdo' AND object_id = OBJECT_ID('dbo.Voucher'))
BEGIN
    DROP INDEX IX_Voucher_RucE_Ejer_Prdo ON dbo.Voucher;
    PRINT 'Índice antiguo eliminado.'
END
GO

PRINT 'Renombrando IX_Voucher_RucE_Ejer_Prdo_NEW a IX_Voucher_RucE_Ejer_Prdo...'

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Voucher_RucE_Ejer_Prdo_NEW' AND object_id = OBJECT_ID('dbo.Voucher'))
BEGIN
    EXEC sp_rename N'dbo.Voucher.IX_Voucher_RucE_Ejer_Prdo_NEW', N'IX_Voucher_RucE_Ejer_Prdo', N'INDEX';
    PRINT 'Índice renombrado exitosamente.'
END
GO

-- Verificación final
SELECT
    i.name AS NombreIndice,
    STRING_AGG(CASE WHEN ic.is_included_column = 0 THEN c.name END, ', ')
        WITHIN GROUP (ORDER BY ic.key_ordinal) AS ColumnasClave,
    COUNT(CASE WHEN ic.is_included_column = 1 THEN 1 END) AS TotalColumnasIncluidas
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE i.object_id = OBJECT_ID('dbo.Voucher')
    AND i.name = 'IX_Voucher_RucE_Ejer_Prdo'
GROUP BY i.name;
GO
*/
