-- =====================================================
-- SCRIPT MAESTRO DE MANTENIMIENTO - ERP_ECHA
-- Fecha: 2026-01-14
-- =====================================================
-- EJECUTAR EN HORARIO DE BAJA ACTIVIDAD
-- Tiempo estimado: 15-30 minutos dependiendo del tamaño
-- =====================================================

USE [ERP_ECHA]
GO

SET NOCOUNT ON
PRINT '======================================'
PRINT 'INICIO DE MANTENIMIENTO: ' + CONVERT(VARCHAR, GETDATE(), 120)
PRINT '======================================'
PRINT ''

-- =====================================================
-- PARTE 1: ELIMINAR INDICES NO USADOS
-- Estos indices tienen 0 lecturas pero muchas escrituras
-- =====================================================

PRINT '>>> PARTE 1: ELIMINANDO INDICES NO USADOS...'
PRINT ''

-- 1. VentaDet - 319K updates sin uso
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_VentaDet' AND object_id = OBJECT_ID('dbo.VentaDet'))
BEGIN
    DROP INDEX [IX_VentaDet] ON [dbo].[VentaDet]
    PRINT '  [X] Eliminado: IX_VentaDet (319K updates desperdiciados)'
END
ELSE PRINT '  [-] IX_VentaDet no existe'
GO

-- 2. VoucherRM
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_VoucherRM_RucE_Ejer_RegCtb' AND object_id = OBJECT_ID('dbo.VoucherRM'))
BEGIN
    DROP INDEX [IX_VoucherRM_RucE_Ejer_RegCtb] ON [dbo].[VoucherRM]
    PRINT '  [X] Eliminado: IX_VoucherRM_RucE_Ejer_RegCtb'
END
ELSE PRINT '  [-] IX_VoucherRM_RucE_Ejer_RegCtb no existe'
GO

-- 3. Venta
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Venta_NCND' AND object_id = OBJECT_ID('dbo.Venta'))
BEGIN
    DROP INDEX [IX_Venta_NCND] ON [dbo].[Venta]
    PRINT '  [X] Eliminado: IX_Venta_NCND'
END
ELSE PRINT '  [-] IX_Venta_NCND no existe'
GO

-- 4. T_RESTAURANTE_PEDIDOS
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_RESPEDIDOS_RUCEMPRESA_LOCALIDAD_FECHA' AND object_id = OBJECT_ID('SPV.T_RESTAURANTE_PEDIDOS'))
BEGIN
    DROP INDEX [IX_RESPEDIDOS_RUCEMPRESA_LOCALIDAD_FECHA] ON [SPV].[T_RESTAURANTE_PEDIDOS]
    PRINT '  [X] Eliminado: IX_RESPEDIDOS_RUCEMPRESA_LOCALIDAD_FECHA'
END
ELSE PRINT '  [-] IX_RESPEDIDOS_RUCEMPRESA_LOCALIDAD_FECHA no existe'
GO

-- 5. Voucher
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Voucher_RucE_FecMov_NoAnulado' AND object_id = OBJECT_ID('dbo.voucher'))
BEGIN
    DROP INDEX [IX_Voucher_RucE_FecMov_NoAnulado] ON [dbo].[voucher]
    PRINT '  [X] Eliminado: IX_Voucher_RucE_FecMov_NoAnulado'
END
ELSE PRINT '  [-] IX_Voucher_RucE_FecMov_NoAnulado no existe'
GO

-- 6. MovimientoInventario
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_MovInv_GE_Origen_Completo' AND object_id = OBJECT_ID('dbo.MovimientoInventario'))
BEGIN
    DROP INDEX [IX_MovInv_GE_Origen_Completo] ON [dbo].[MovimientoInventario]
    PRINT '  [X] Eliminado: IX_MovInv_GE_Origen_Completo'
END
ELSE PRINT '  [-] IX_MovInv_GE_Origen_Completo no existe'
GO

-- 7. T_MOVIMIENTO_PALLET
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IDX_T_MOVIMIENTO_PALLET_1' AND object_id = OBJECT_ID('dbo.T_MOVIMIENTO_PALLET'))
BEGIN
    DROP INDEX [IDX_T_MOVIMIENTO_PALLET_1] ON [dbo].[T_MOVIMIENTO_PALLET]
    PRINT '  [X] Eliminado: IDX_T_MOVIMIENTO_PALLET_1'
END
ELSE PRINT '  [-] IDX_T_MOVIMIENTO_PALLET_1 no existe'
GO

PRINT ''
PRINT '>>> PARTE 1 COMPLETADA'
PRINT ''

-- =====================================================
-- PARTE 2: CREAR INDICES PARA CONSULTAS LENTAS
-- Verifica si ya existe un indice con las mismas columnas
-- =====================================================

PRINT '>>> PARTE 2: CREANDO INDICES PARA CONSULTAS LENTAS...'
PRINT ''

-- Funcion auxiliar para verificar si existe indice con mismas columnas clave
-- Verificamos por columnas, no por nombre

-- 2.1 OrdPedidoDet (RucE, Cd_OP)
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes i
    INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
    INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
    WHERE i.object_id = OBJECT_ID('dbo.OrdPedidoDet') AND i.type > 0 AND ic.is_included_column = 0
    GROUP BY i.index_id
    HAVING STRING_AGG(c.name, ',') WITHIN GROUP (ORDER BY ic.key_ordinal) = 'RucE,Cd_OP'
)
BEGIN
    CREATE NONCLUSTERED INDEX [IX_OrdPedidoDet_RucE_CdOP]
    ON [dbo].[OrdPedidoDet] ([RucE], [Cd_OP])
    INCLUDE ([Item], [Cd_Prod], [Cd_Srv], [Cd_Alm], [Cd_CC], [Cd_SC], [Cd_SS], [ID_UMP], [Cant], [PU], [IGV], [Total], [TotalNeto])
    PRINT '  [+] Creado: IX_OrdPedidoDet_RucE_CdOP'
END
ELSE PRINT '  [-] Indice con columnas (RucE, Cd_OP) ya existe en OrdPedidoDet'
GO

-- 2.2 Cliente2 (RucE, Estado)
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes i
    INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
    INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
    WHERE i.object_id = OBJECT_ID('dbo.Cliente2') AND i.type > 0 AND ic.is_included_column = 0
    GROUP BY i.index_id
    HAVING STRING_AGG(c.name, ',') WITHIN GROUP (ORDER BY ic.key_ordinal) = 'RucE,Estado'
)
BEGIN
    CREATE NONCLUSTERED INDEX [IX_Cliente2_RucE_Estado_Busqueda]
    ON [dbo].[Cliente2] ([RucE], [Estado])
    INCLUDE ([Cd_Clt], [NDoc], [RSocial], [Nom], [ApPat], [ApMat], [Cd_TDI])
    PRINT '  [+] Creado: IX_Cliente2_RucE_Estado_Busqueda'
END
ELSE PRINT '  [-] Indice con columnas (RucE, Estado) ya existe en Cliente2'
GO

-- 2.3 OrdPedido (RucE, NroOP)
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes i
    INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
    INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
    WHERE i.object_id = OBJECT_ID('dbo.OrdPedido') AND i.type > 0 AND ic.is_included_column = 0
    GROUP BY i.index_id
    HAVING STRING_AGG(c.name, ',') WITHIN GROUP (ORDER BY ic.key_ordinal) = 'RucE,NroOP'
)
BEGIN
    CREATE NONCLUSTERED INDEX [IX_OrdPedido_RucE_NroOP]
    ON [dbo].[OrdPedido] ([RucE], [NroOP])
    PRINT '  [+] Creado: IX_OrdPedido_RucE_NroOP'
END
ELSE PRINT '  [-] Indice con columnas (RucE, NroOP) ya existe en OrdPedido'
GO

-- 2.4 T_TESORERIA (Busqueda)
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes i
    WHERE i.object_id = OBJECT_ID('SPV.T_TESORERIA')
    AND i.name = 'IX_Tesoreria_Busqueda'
)
BEGIN
    CREATE NONCLUSTERED INDEX [IX_Tesoreria_Busqueda]
    ON [SPV].[T_TESORERIA] ([C_CODIGO_EMPRESA], [C_CODIGO_TIPO_DOCUMENTO], [C_NRO_SERIE], [C_NRO_DOCUMENTO])
    INCLUDE ([C_ID_TESORERIA], [C_CODIGO_VENTA])
    PRINT '  [+] Creado: IX_Tesoreria_Busqueda'
END
ELSE PRINT '  [-] IX_Tesoreria_Busqueda ya existe'
GO

-- 2.5 T_TESORERIA_DETALLE
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes i
    WHERE i.object_id = OBJECT_ID('SPV.T_TESORERIA_DETALLE')
    AND i.name = 'IX_TesoreriaDetalle_IdTesoreria'
)
BEGIN
    CREATE NONCLUSTERED INDEX [IX_TesoreriaDetalle_IdTesoreria]
    ON [SPV].[T_TESORERIA_DETALLE] ([C_CODIGO_EMPRESA], [C_ID_TESORERIA], [C_CODIGO_MONEDA])
    INCLUDE ([C_IMPORTE])
    PRINT '  [+] Creado: IX_TesoreriaDetalle_IdTesoreria'
END
ELSE PRINT '  [-] IX_TesoreriaDetalle_IdTesoreria ya existe'
GO

-- 2.6 Voucher (RucE, Ib_EsProv)
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes i
    INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
    INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
    WHERE i.object_id = OBJECT_ID('dbo.Voucher') AND i.type > 0 AND ic.is_included_column = 0
    GROUP BY i.index_id
    HAVING STRING_AGG(c.name, ',') WITHIN GROUP (ORDER BY ic.key_ordinal) = 'RucE,Ib_EsProv'
)
BEGIN
    CREATE NONCLUSTERED INDEX [IX_Voucher_RucE_IbEsProv]
    ON [dbo].[Voucher] ([RucE], [Ib_EsProv])
    INCLUDE ([Cd_Vou], [Ejer], [RegCtb], [NroCta], [MtoD], [MtoH], [Cd_Clt], [Cd_Prv])
    PRINT '  [+] Creado: IX_Voucher_RucE_IbEsProv'
END
ELSE PRINT '  [-] Indice con columnas (RucE, Ib_EsProv) ya existe en Voucher'
GO

PRINT ''
PRINT '>>> PARTE 2 COMPLETADA'
PRINT ''

-- =====================================================
-- PARTE 3: CREAR INDICES RECOMENDADOS POR SQL SERVER
-- =====================================================

PRINT '>>> PARTE 3: CREANDO INDICES RECOMENDADOS POR SQL SERVER...'
PRINT ''

-- 3.1 T_MOVIMIENTO_CAJA (Estado) - 89.95% impacto
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes i
    WHERE i.object_id = OBJECT_ID('SPV.T_MOVIMIENTO_CAJA')
    AND i.name = 'IX_MovCaja_Empresa_Local_Caja_Estado'
)
BEGIN
    CREATE NONCLUSTERED INDEX [IX_MovCaja_Empresa_Local_Caja_Estado]
    ON [SPV].[T_MOVIMIENTO_CAJA] ([C_CODIGO_EMPRESA], [C_CODIGO_LOCALIDAD], [C_CODIGO_CAJA], [C_ESTADO])
    PRINT '  [+] Creado: IX_MovCaja_Empresa_Local_Caja_Estado (89.95% impacto)'
END
ELSE PRINT '  [-] IX_MovCaja_Empresa_Local_Caja_Estado ya existe'
GO

-- 3.2 RemuTrabHist (Cd_TipRemu) - 100% impacto
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes i
    WHERE i.object_id = OBJECT_ID('dbo.RemuTrabHist')
    AND i.name = 'IX_RemuTrabHist_RucE_CdTrab_TipRemu'
)
BEGIN
    CREATE NONCLUSTERED INDEX [IX_RemuTrabHist_RucE_CdTrab_TipRemu]
    ON [dbo].[RemuTrabHist] ([RucE], [Cd_Trab], [Cd_TipRemu])
    INCLUDE ([Importe])
    PRINT '  [+] Creado: IX_RemuTrabHist_RucE_CdTrab_TipRemu (100% impacto)'
END
ELSE PRINT '  [-] IX_RemuTrabHist_RucE_CdTrab_TipRemu ya existe'
GO

-- 3.3 RemuTrabHist (Ejer) - 100% impacto
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes i
    WHERE i.object_id = OBJECT_ID('dbo.RemuTrabHist')
    AND i.name = 'IX_RemuTrabHist_RucE_Ejer_CdTrab_TipRemu'
)
BEGIN
    CREATE NONCLUSTERED INDEX [IX_RemuTrabHist_RucE_Ejer_CdTrab_TipRemu]
    ON [dbo].[RemuTrabHist] ([RucE], [Ejer], [Cd_Trab], [Cd_TipRemu])
    INCLUDE ([Prdo], [Importe])
    PRINT '  [+] Creado: IX_RemuTrabHist_RucE_Ejer_CdTrab_TipRemu (100% impacto)'
END
ELSE PRINT '  [-] IX_RemuTrabHist_RucE_Ejer_CdTrab_TipRemu ya existe'
GO

-- 3.4 DsctoTrabHist - 79% impacto
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes i
    WHERE i.object_id = OBJECT_ID('dbo.DsctoTrabHist')
    AND i.name = 'IX_DsctoTrabHist_RucE_Ejer_Prdo_CdTrab_TipDscto'
)
BEGIN
    CREATE NONCLUSTERED INDEX [IX_DsctoTrabHist_RucE_Ejer_Prdo_CdTrab_TipDscto]
    ON [dbo].[DsctoTrabHist] ([RucE], [Ejer], [Prdo], [Cd_Trab], [Cd_TipDscto])
    PRINT '  [+] Creado: IX_DsctoTrabHist_RucE_Ejer_Prdo_CdTrab_TipDscto (79% impacto)'
END
ELSE PRINT '  [-] IX_DsctoTrabHist_RucE_Ejer_Prdo_CdTrab_TipDscto ya existe'
GO

-- 3.5 PDT_DAT_JORLAB - 75.65% impacto
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes i
    WHERE i.object_id = OBJECT_ID('dbo.PDT_DAT_JORLAB')
    AND i.name = 'IX_PDT_DAT_JORLAB_RucE_Ejer_Prdo_CdTrab'
)
BEGIN
    CREATE NONCLUSTERED INDEX [IX_PDT_DAT_JORLAB_RucE_Ejer_Prdo_CdTrab]
    ON [dbo].[PDT_DAT_JORLAB] ([RucE], [Ejer], [Prdo], [Cd_Trab])
    PRINT '  [+] Creado: IX_PDT_DAT_JORLAB_RucE_Ejer_Prdo_CdTrab (75.65% impacto)'
END
ELSE PRINT '  [-] IX_PDT_DAT_JORLAB_RucE_Ejer_Prdo_CdTrab ya existe'
GO

-- 3.6 Producto2 (Fabricacion) - 62.38% impacto
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes i
    WHERE i.object_id = OBJECT_ID('dbo.Producto2')
    AND i.name = 'IX_Producto2_RucE_IbFabricacion'
)
BEGIN
    CREATE NONCLUSTERED INDEX [IX_Producto2_RucE_IbFabricacion]
    ON [dbo].[Producto2] ([RucE], [C_IB_FABRICACION])
    INCLUDE ([Nombre1])
    PRINT '  [+] Creado: IX_Producto2_RucE_IbFabricacion (62.38% impacto)'
END
ELSE PRINT '  [-] IX_Producto2_RucE_IbFabricacion ya existe'
GO

-- 3.7 GExCOxOCxSCo (ComDestino) - 48.87% impacto
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes i
    WHERE i.object_id = OBJECT_ID('dbo.GExCOxOCxSCo')
    AND i.name = 'IX_GExCOxOCxSCo_ComDestino'
)
BEGIN
    CREATE NONCLUSTERED INDEX [IX_GExCOxOCxSCo_ComDestino]
    ON [dbo].[GExCOxOCxSCo] ([RucE], [Cd_Com_Destino], [Item_Destino])
    INCLUDE ([Cd_GE_Origen], [Item_Origen])
    PRINT '  [+] Creado: IX_GExCOxOCxSCo_ComDestino (48.87% impacto)'
END
ELSE PRINT '  [-] IX_GExCOxOCxSCo_ComDestino ya existe'
GO

-- 3.8 GExCOxOCxSCo (ComOrigen) - 35.57% impacto
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes i
    WHERE i.object_id = OBJECT_ID('dbo.GExCOxOCxSCo')
    AND i.name = 'IX_GExCOxOCxSCo_ComOrigen'
)
BEGIN
    CREATE NONCLUSTERED INDEX [IX_GExCOxOCxSCo_ComOrigen]
    ON [dbo].[GExCOxOCxSCo] ([RucE], [Cd_Com_Origen], [Item_Origen])
    INCLUDE ([Cd_GE_Destino], [Item_Destino])
    PRINT '  [+] Creado: IX_GExCOxOCxSCo_ComOrigen (35.57% impacto)'
END
ELSE PRINT '  [-] IX_GExCOxOCxSCo_ComOrigen ya existe'
GO

-- 3.9 SCoxSR - 37.66% impacto, 1.4M busquedas
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes i
    WHERE i.object_id = OBJECT_ID('dbo.SCoxSR')
    AND i.name = 'IX_SCoxSR_RucE_CdSR'
)
BEGIN
    CREATE NONCLUSTERED INDEX [IX_SCoxSR_RucE_CdSR]
    ON [dbo].[SCoxSR] ([RucE], [Cd_SR])
    PRINT '  [+] Creado: IX_SCoxSR_RucE_CdSR (37.66% impacto, 1.4M busquedas)'
END
ELSE PRINT '  [-] IX_SCoxSR_RucE_CdSR ya existe'
GO

-- 3.10 RemusTrab - 35.91% impacto
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes i
    WHERE i.object_id = OBJECT_ID('dbo.RemusTrab')
    AND i.name = 'IX_RemusTrab_RucE_CdTrab'
)
BEGIN
    CREATE NONCLUSTERED INDEX [IX_RemusTrab_RucE_CdTrab]
    ON [dbo].[RemusTrab] ([RucE], [Cd_Trab])
    PRINT '  [+] Creado: IX_RemusTrab_RucE_CdTrab (35.91% impacto)'
END
ELSE PRINT '  [-] IX_RemusTrab_RucE_CdTrab ya existe'
GO

-- 3.11 T_MOVIMIENTO_CAJA (FecMov) - 35.49% impacto
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes i
    WHERE i.object_id = OBJECT_ID('SPV.T_MOVIMIENTO_CAJA')
    AND i.name = 'IX_MovCaja_Empresa_Local_FecMov'
)
BEGIN
    CREATE NONCLUSTERED INDEX [IX_MovCaja_Empresa_Local_FecMov]
    ON [SPV].[T_MOVIMIENTO_CAJA] ([C_CODIGO_EMPRESA], [C_CODIGO_LOCALIDAD], [C_FECHA_MOVIMIENTO])
    PRINT '  [+] Creado: IX_MovCaja_Empresa_Local_FecMov (35.49% impacto)'
END
ELSE PRINT '  [-] IX_MovCaja_Empresa_Local_FecMov ya existe'
GO

-- 3.12 CptoCostoOFDoc - 32.09% impacto
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes i
    WHERE i.object_id = OBJECT_ID('dbo.CptoCostoOFDoc')
    AND i.name = 'IX_CptoCostoOFDoc_RucE_CdOF_IdCCOF'
)
BEGIN
    CREATE NONCLUSTERED INDEX [IX_CptoCostoOFDoc_RucE_CdOF_IdCCOF]
    ON [dbo].[CptoCostoOFDoc] ([RucE], [Cd_OF], [Id_CCOF])
    PRINT '  [+] Creado: IX_CptoCostoOFDoc_RucE_CdOF_IdCCOF (32.09% impacto)'
END
ELSE PRINT '  [-] IX_CptoCostoOFDoc_RucE_CdOF_IdCCOF ya existe'
GO

PRINT ''
PRINT '>>> PARTE 3 COMPLETADA'
PRINT ''

-- =====================================================
-- PARTE 4: DESFRAGMENTACION DE INDICES
-- =====================================================

PRINT '>>> PARTE 4: DESFRAGMENTANDO INDICES...'
PRINT ''

-- 4.1 HEAPS - Rebuild tablas sin clustered index
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'T_FORMA_PAGO_POR_VENTA')
BEGIN
    ALTER TABLE [dbo].[T_FORMA_PAGO_POR_VENTA] REBUILD
    PRINT '  [R] T_FORMA_PAGO_POR_VENTA HEAP rebuilt'
END
GO

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'T_RESTAURANTE_PEDIDOS' AND schema_id = SCHEMA_ID('SPV'))
BEGIN
    ALTER TABLE [SPV].[T_RESTAURANTE_PEDIDOS] REBUILD
    PRINT '  [R] T_RESTAURANTE_PEDIDOS HEAP rebuilt'
END
GO

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'T_MOVIMIENTO_DETALLE_VENTA_LOG')
BEGIN
    ALTER TABLE [dbo].[T_MOVIMIENTO_DETALLE_VENTA_LOG] REBUILD
    PRINT '  [R] T_MOVIMIENTO_DETALLE_VENTA_LOG HEAP rebuilt'
END
GO

-- 4.2 InventarioDet2 - Indices fragmentados
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_InventarioDet2_RucE_Prod_Alm' AND object_id = OBJECT_ID('dbo.InventarioDet2'))
BEGIN
    ALTER INDEX [IX_InventarioDet2_RucE_Prod_Alm] ON [dbo].[InventarioDet2] REBUILD
    PRINT '  [R] IX_InventarioDet2_RucE_Prod_Alm rebuilt (79% -> 0%)'
END
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_InventarioDet2_RucE_CdProd_ICES' AND object_id = OBJECT_ID('dbo.InventarioDet2'))
BEGIN
    ALTER INDEX [IX_InventarioDet2_RucE_CdProd_ICES] ON [dbo].[InventarioDet2] REBUILD
    PRINT '  [R] IX_InventarioDet2_RucE_CdProd_ICES rebuilt (73% -> 0%)'
END
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_InventarioDet2_RucE_CdProd_Costo' AND object_id = OBJECT_ID('dbo.InventarioDet2'))
BEGIN
    ALTER INDEX [IX_InventarioDet2_RucE_CdProd_Costo] ON [dbo].[InventarioDet2] REBUILD
    PRINT '  [R] IX_InventarioDet2_RucE_CdProd_Costo rebuilt (67% -> 0%)'
END
GO

-- 4.3 MovimientoInventario
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IDX_MI_GUIA_ORIGEN' AND object_id = OBJECT_ID('dbo.MovimientoInventario'))
BEGIN
    ALTER INDEX [IDX_MI_GUIA_ORIGEN] ON [dbo].[MovimientoInventario] REBUILD
    PRINT '  [R] IDX_MI_GUIA_ORIGEN rebuilt (40% -> 0%)'
END
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IDX_VENTA_ORIGEN' AND object_id = OBJECT_ID('dbo.MovimientoInventario'))
BEGIN
    ALTER INDEX [IDX_VENTA_ORIGEN] ON [dbo].[MovimientoInventario] REBUILD
    PRINT '  [R] IDX_VENTA_ORIGEN rebuilt (40% -> 0%)'
END
GO

-- 4.4 CostoInventario
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IDX_COSTOINVENTARIO_1' AND object_id = OBJECT_ID('dbo.CostoInventario'))
BEGIN
    ALTER INDEX [IDX_COSTOINVENTARIO_1] ON [dbo].[CostoInventario] REBUILD
    PRINT '  [R] IDX_COSTOINVENTARIO_1 rebuilt (39% -> 0%)'
END
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_CostoInventario_Lookup' AND object_id = OBJECT_ID('dbo.CostoInventario'))
BEGIN
    ALTER INDEX [IX_CostoInventario_Lookup] ON [dbo].[CostoInventario] REBUILD
    PRINT '  [R] IX_CostoInventario_Lookup rebuilt (34% -> 0%)'
END
GO

PRINT ''
PRINT '>>> PARTE 4 COMPLETADA'
PRINT ''

-- =====================================================
-- PARTE 5: ACTUALIZAR ESTADISTICAS
-- =====================================================

PRINT '>>> PARTE 5: ACTUALIZANDO ESTADISTICAS...'
PRINT ''

UPDATE STATISTICS [dbo].[T_FACTURA_BOLETA_ELECTRONICA_INFO] WITH FULLSCAN
PRINT '  [S] T_FACTURA_BOLETA_ELECTRONICA_INFO actualizado'

UPDATE STATISTICS [dbo].[voucher] WITH FULLSCAN
PRINT '  [S] voucher actualizado'

UPDATE STATISTICS [dbo].[Venta] WITH FULLSCAN
PRINT '  [S] Venta actualizado'

UPDATE STATISTICS [dbo].[VentaDet] WITH FULLSCAN
PRINT '  [S] VentaDet actualizado'

UPDATE STATISTICS [dbo].[VoucherRM] WITH FULLSCAN
PRINT '  [S] VoucherRM actualizado'

UPDATE STATISTICS [dbo].[OrdPedidoDet] WITH FULLSCAN
PRINT '  [S] OrdPedidoDet actualizado'

UPDATE STATISTICS [dbo].[MovimientosDetalleVenta] WITH FULLSCAN
PRINT '  [S] MovimientosDetalleVenta actualizado'

UPDATE STATISTICS [dbo].[MovimientoInventario] WITH FULLSCAN
PRINT '  [S] MovimientoInventario actualizado'

UPDATE STATISTICS [dbo].[OrdPedido] WITH FULLSCAN
PRINT '  [S] OrdPedido actualizado'

UPDATE STATISTICS [dbo].[InventarioDet2] WITH FULLSCAN
PRINT '  [S] InventarioDet2 actualizado'

UPDATE STATISTICS [dbo].[CostoInventario] WITH FULLSCAN
PRINT '  [S] CostoInventario actualizado'

PRINT ''
PRINT '>>> PARTE 5 COMPLETADA'
PRINT ''

-- =====================================================
-- RESUMEN FINAL
-- =====================================================

PRINT '======================================'
PRINT 'FIN DE MANTENIMIENTO: ' + CONVERT(VARCHAR, GETDATE(), 120)
PRINT '======================================'
PRINT ''
PRINT 'RESUMEN:'
PRINT '  - Indices no usados eliminados'
PRINT '  - Indices nuevos creados (si no existian)'
PRINT '  - Indices fragmentados reconstruidos'
PRINT '  - Estadisticas actualizadas'
PRINT ''
PRINT 'RECOMENDACIONES:'
PRINT '  - Ejecutar este script semanalmente en horario nocturno'
PRINT '  - Monitorear rendimiento despues de 24-48 horas'
PRINT '  - Considerar comprimir tablas grandes (T_FACTURA_BOLETA_ELECTRONICA_INFO)'
PRINT '======================================'
GO
