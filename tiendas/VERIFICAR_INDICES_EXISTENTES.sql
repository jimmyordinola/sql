-- ============================================
-- VERIFICAR INDICES EXISTENTES EN LAS TABLAS
-- Objetivo: Detectar si ya existen índices con las columnas propuestas
-- ============================================

USE [ERP_ECHA]
GO

PRINT '=============================================='
PRINT 'VERIFICACION DE INDICES EXISTENTES'
PRINT '=============================================='
PRINT ''

-- ============================================
-- 1. MOVIMIENTOSDETALLEVENTA
-- ============================================
PRINT '1. TABLA: MOVIMIENTOSDETALLEVENTA'
PRINT '   Columnas propuestas: RUCE, Cd_OP_DESTINO, CD_OP_ORIGEN'
PRINT '----------------------------------------------'

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
WHERE i.object_id = OBJECT_ID('dbo.MOVIMIENTOSDETALLEVENTA')
GROUP BY i.name, i.type_desc, i.is_unique, i.is_primary_key
ORDER BY i.name

PRINT ''

-- Verificar si hay índice en RUCE + Cd_OP_DESTINO
IF EXISTS (
    SELECT 1
    FROM sys.indexes i
    INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
    INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
    WHERE i.object_id = OBJECT_ID('dbo.MOVIMIENTOSDETALLEVENTA')
    AND c.name IN ('RUCE', 'Cd_OP_DESTINO')
    AND ic.is_included_column = 0
    GROUP BY i.index_id
    HAVING COUNT(DISTINCT c.name) = 2
)
    PRINT '   [OK] Ya existe indice con RUCE + Cd_OP_DESTINO'
ELSE
    PRINT '   [FALTA] No existe indice con RUCE + Cd_OP_DESTINO'

-- Verificar si hay índice en RUCE + CD_OP_ORIGEN
IF EXISTS (
    SELECT 1
    FROM sys.indexes i
    INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
    INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
    WHERE i.object_id = OBJECT_ID('dbo.MOVIMIENTOSDETALLEVENTA')
    AND c.name IN ('RUCE', 'CD_OP_ORIGEN')
    AND ic.is_included_column = 0
    GROUP BY i.index_id
    HAVING COUNT(DISTINCT c.name) = 2
)
    PRINT '   [OK] Ya existe indice con RUCE + CD_OP_ORIGEN'
ELSE
    PRINT '   [FALTA] No existe indice con RUCE + CD_OP_ORIGEN'

PRINT ''
PRINT ''

-- ============================================
-- 2. Cliente2
-- ============================================
PRINT '2. TABLA: Cliente2'
PRINT '   Columnas propuestas: RucE, ESTADO, Cd_Clt, NDoc, RSocial, Cd_TDI'
PRINT '----------------------------------------------'

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
WHERE i.object_id = OBJECT_ID('dbo.Cliente2')
GROUP BY i.name, i.type_desc, i.is_unique, i.is_primary_key
ORDER BY i.name

PRINT ''

-- Verificar si hay índice en RucE + ESTADO
IF EXISTS (
    SELECT 1
    FROM sys.indexes i
    INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
    INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
    WHERE i.object_id = OBJECT_ID('dbo.Cliente2')
    AND c.name IN ('RucE', 'ESTADO')
    AND ic.is_included_column = 0
    GROUP BY i.index_id
    HAVING COUNT(DISTINCT c.name) = 2
)
    PRINT '   [OK] Ya existe indice con RucE + ESTADO'
ELSE
    PRINT '   [FALTA] No existe indice con RucE + ESTADO'

-- Verificar índice en NDoc
IF EXISTS (
    SELECT 1
    FROM sys.indexes i
    INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
    INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
    WHERE i.object_id = OBJECT_ID('dbo.Cliente2')
    AND c.name = 'NDoc'
    AND ic.is_included_column = 0
)
    PRINT '   [OK] Ya existe indice con NDoc'
ELSE
    PRINT '   [FALTA] No existe indice con NDoc'

PRINT ''
PRINT ''

-- ============================================
-- 3. SPV.T_MOVIMIENTO_CAJA
-- ============================================
PRINT '3. TABLA: SPV.T_MOVIMIENTO_CAJA'
PRINT '   Columnas propuestas: C_CODIGO_EMPRESA, C_CODIGO_LOCALIDAD, C_CODIGO_CAJA, C_ESTADO'
PRINT '----------------------------------------------'

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
WHERE i.object_id = OBJECT_ID('SPV.T_MOVIMIENTO_CAJA')
GROUP BY i.name, i.type_desc, i.is_unique, i.is_primary_key
ORDER BY i.name

PRINT ''

-- Verificar si hay índice en las 4 columnas
IF EXISTS (
    SELECT 1
    FROM sys.indexes i
    INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
    INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
    WHERE i.object_id = OBJECT_ID('SPV.T_MOVIMIENTO_CAJA')
    AND c.name IN ('C_CODIGO_EMPRESA', 'C_CODIGO_LOCALIDAD', 'C_CODIGO_CAJA', 'C_ESTADO')
    AND ic.is_included_column = 0
    GROUP BY i.index_id
    HAVING COUNT(DISTINCT c.name) >= 3
)
    PRINT '   [OK] Ya existe indice similar con columnas de busqueda'
ELSE
    PRINT '   [FALTA] No existe indice con C_CODIGO_EMPRESA + C_CODIGO_LOCALIDAD + C_CODIGO_CAJA + C_ESTADO'

PRINT ''
PRINT ''

-- ============================================
-- 4. ORDPEDIDO
-- ============================================
PRINT '4. TABLA: DBO.ORDPEDIDO'
PRINT '   Columnas propuestas: RUCE, CD_OP, C_DOCUMENTO_INTERNO'
PRINT '----------------------------------------------'

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
WHERE i.object_id = OBJECT_ID('dbo.ORDPEDIDO')
GROUP BY i.name, i.type_desc, i.is_unique, i.is_primary_key
ORDER BY i.name

PRINT ''
PRINT ''

-- ============================================
-- 5. VendedorxCliente
-- ============================================
PRINT '5. TABLA: VendedorxCliente'
PRINT '   Columnas propuestas: RucE, Cd_Clt, Cd_Vdr'
PRINT '----------------------------------------------'

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
WHERE i.object_id = OBJECT_ID('dbo.VendedorxCliente')
GROUP BY i.name, i.type_desc, i.is_unique, i.is_primary_key
ORDER BY i.name

PRINT ''
PRINT ''

-- ============================================
-- RESUMEN: INDICES FALTANTES A CREAR
-- ============================================
PRINT '=============================================='
PRINT 'RESUMEN: SCRIPTS DE INDICES FALTANTES'
PRINT '=============================================='
PRINT ''
PRINT '-- Ejecutar solo los que aparezcan como [FALTA] arriba:'
PRINT ''
PRINT '-- 1. MOVIMIENTOSDETALLEVENTA'
PRINT 'CREATE NONCLUSTERED INDEX IX_MovDetVenta_RucE_OpDestino'
PRINT 'ON dbo.MOVIMIENTOSDETALLEVENTA(RUCE, Cd_OP_DESTINO);'
PRINT ''
PRINT 'CREATE NONCLUSTERED INDEX IX_MovDetVenta_RucE_OpOrigen'
PRINT 'ON dbo.MOVIMIENTOSDETALLEVENTA(RUCE, CD_OP_ORIGEN);'
PRINT ''
PRINT '-- 2. Cliente2'
PRINT 'CREATE NONCLUSTERED INDEX IX_Cliente2_RucE_Estado'
PRINT 'ON dbo.Cliente2(RucE, ESTADO)'
PRINT 'INCLUDE (Cd_Clt, NDoc, RSocial, Cd_TDI);'
PRINT ''
PRINT '-- 3. T_MOVIMIENTO_CAJA'
PRINT 'CREATE NONCLUSTERED INDEX IX_MovCaja_Busqueda'
PRINT 'ON SPV.T_MOVIMIENTO_CAJA(C_CODIGO_EMPRESA, C_CODIGO_LOCALIDAD, C_CODIGO_CAJA, C_ESTADO)'
PRINT 'INCLUDE (C_ID_MOVIMIENTO_CAJA, C_FECHA_MOVIMIENTO);'
PRINT ''

GO
