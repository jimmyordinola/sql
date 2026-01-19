USE [ERP_ECHA]
GO

PRINT '=========================================='
PRINT 'Ejecutando SP de Kardex para PD00026...'
PRINT '=========================================='
GO

-- Ejecutar el SP directamente
EXEC inventario.USP_INVENTARIO2_BUSCAR_KARDEX_DETALLE_6
    @P_RUC_EMPRESA = N'20102351038',
    @P_EJERCICIO = N'2025',
    @P_CODIGO_MONEDA = '01',
    @P_FECHA_HASTA = '2025-10-31',
    @P_CODIGO_PRODUCTO = 'PD00026',
    @P_FECHA_DESDE = '2025-10-01',
    @P_IB_MOSTRAR_DOCUMENTOS_RELACIONADOS = 0,
    @P_USUARIO = N'PROJECT01'
GO
