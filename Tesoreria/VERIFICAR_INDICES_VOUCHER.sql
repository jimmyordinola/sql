-- ============================================
-- Verificar índices existentes en tabla Voucher
-- ============================================

USE [ERP_ECHA]
GO

-- Ver todos los índices de la tabla Voucher
SELECT
    i.name AS NombreIndice,
    i.type_desc AS TipoIndice,
    i.is_unique AS EsUnico,
    i.is_primary_key AS EsPK,
    STRING_AGG(c.name, ', ') WITHIN GROUP (ORDER BY ic.key_ordinal) AS ColumnasIndice,
    STRING_AGG(CASE WHEN ic.is_included_column = 1 THEN c.name END, ', ')
        WITHIN GROUP (ORDER BY ic.key_ordinal) AS ColumnasIncluidas
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE i.object_id = OBJECT_ID('dbo.Voucher')
GROUP BY i.name, i.type_desc, i.is_unique, i.is_primary_key
ORDER BY i.name;

-- Ver detalle de columnas por índice
SELECT
    i.name AS NombreIndice,
    c.name AS Columna,
    ic.key_ordinal AS OrdenEnClave,
    ic.is_included_column AS EsIncluida,
    i.type_desc AS TipoIndice
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE i.object_id = OBJECT_ID('dbo.Voucher')
ORDER BY i.name, ic.key_ordinal, ic.is_included_column;

-- Buscar específicamente índices que incluyan RucE, Ejer, Prdo
SELECT
    i.name AS NombreIndice,
    STRING_AGG(c.name, ', ') WITHIN GROUP (ORDER BY ic.key_ordinal) AS ColumnasIndice
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id AND ic.is_included_column = 0
INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE i.object_id = OBJECT_ID('dbo.Voucher')
GROUP BY i.name
HAVING
    SUM(CASE WHEN c.name = 'RucE' THEN 1 ELSE 0 END) > 0
    OR SUM(CASE WHEN c.name = 'Ejer' THEN 1 ELSE 0 END) > 0
    OR SUM(CASE WHEN c.name = 'Prdo' THEN 1 ELSE 0 END) > 0;
