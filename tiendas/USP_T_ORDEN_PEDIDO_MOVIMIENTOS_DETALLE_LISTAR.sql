USE [ERP_ECHA]
GO
/****** Object:  StoredProcedure [SPV].[USP_T_ORDEN_PEDIDO_MOVIMIENTOS_DETALLE_LISTAR]    Script Date: 20/01/2026 10:46:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROC [SPV].[USP_T_ORDEN_PEDIDO_MOVIMIENTOS_DETALLE_LISTAR]

@P_RUC_EMPRESA NVARCHAR(11),
@P_CODIGO_ORDEN_PEDIDO CHAR(10)

AS

SELECT 
	 mv.CD_OP_ORIGEN As Codigo_OrdenPedido_Origen
	,mv.ITEM_OP_ORIGEN As Item_OrdenPedido_Origen

	,mv.CD_OP_DESTINO As Codigo_OrdenPedido_Destino
	,mv.ITEM_OP_DESTINO As Item_OrdenPedido_Destino

	,mv.CD_GR_DESTINO As Codigo_GuiaRemision_Destino
	,mv.ITEM_GR_DESTINO As Item_GuiaRemision_Destino

	,mv.CD_VTA_DESTINO As Codigo_Venta_Destino
	,mv.NRO_REGVDT_DESTINO As Numero_Reg_Venta_Destino

	,mv.CantidadTotalDocumentoItem As Cantidad_Total_Item
	,mv.CANTIDADUSADA As Cantidad_Usada
	,mv.CANTIDADSALDO As Cantidad_Saldo

	,op.FecE As Fecha_Emision
	,op.C_DOCUMENTO_INTERNO As Documento
	,op.C_DOCUMENTO_INTERNO As Serie_Destino
	,op.C_DOCUMENTO_INTERNO As Numero_Destino
	,op.BIM_Neto As Total_Valor_Neto
	,op.IGV AS Total_Igv
	,op.TOTAL As Total_Venta
	,op.CD_MDA As Codigo_Moneda
	,op_mn.Simbolo AS Simbolo_Moneda
	,op.CamMda As Tipo_Cambio
FROM 
	MOVIMIENTOSDETALLEVENTA mv
	LEFT JOIN DBO.ORDPEDIDO op ON op.RUCE=mv.RUCE AND op.CD_OP=CD_OP_DESTINO
	LEFT JOIN DBO.MONEDA op_mn ON op_mn.CD_MDA=op.CD_MDA 
	LEFT JOIN DBO.GUIAREMISION gr ON gr.RUCE=mv.RUCE AND gr.CD_GR=mv.CD_GR_DESTINO
	LEFT JOIN DBO.VENTA vt ON vt.RUCE=mv.RUCE AND vt.CD_VTA=mv.CD_VTA_DESTINO
WHERE 
	mv.RUCE=@P_RUC_EMPRESA
	AND (mv.Cd_OP_DESTINO=@P_CODIGO_ORDEN_PEDIDO OR mv.CD_OP_ORIGEN=@P_CODIGO_ORDEN_PEDIDO)

