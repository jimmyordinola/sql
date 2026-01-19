USE [ERP_ECHA]
GO
/****** Object:  StoredProcedure [inventario].[USP_COSTO_INVENTARIO_RECALCULAR_4]    Script Date: 15/01/2026 13:12:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [inventario].[USP_COSTO_INVENTARIO_RECALCULAR_4]
@RucE VARCHAR(11),
@Cd_Prod_cadena VARCHAR(MAX),
@FechaMovimiento DATETIME,
@P_FECHA_RECALCULO_REAL DATETIME OUT,
@P_USUARIO_RECALCULO NVARCHAR(10),
@P_FECHA_RECALCULO DATETIME --Fecha actual de la PC del cliente
AS
select
	@P_FECHA_RECALCULO_REAL = case when DATEADD(DAY,1,EOMONTH(MAX(FechaCierre))) > @FechaMovimiento then DATEADD(DAY,1,EOMONTH(MAX(FechaCierre))) else @FechaMovimiento end
from
	CierreProcesoxFecha
where
	RucE = @RucE
	and Cd_MR = '19'

declare @Producto_Tabla table
(
	Id INT,
	Cd_Prod char(7)
)

insert into
	@Producto_Tabla
select
	id,
	val
from
	dbo.fnSplit2(@Cd_Prod_cadena,',')

declare
@RowCount int = (select COUNT(*) from @Producto_Tabla),
@RowHandle int = 1,
@Cd_Prod char(7)

WHILE (@RowHandle <= @RowCount)
BEGIN
	set @Cd_Prod = (select Cd_Prod from @Producto_Tabla where Id=@RowHandle)
	exec inventario.USP_COSTO_INVENTARIO_RECALCULAR_INDIVIDUAL_3 @RucE, @Cd_Prod, @P_FECHA_RECALCULO_REAL,@P_USUARIO_RECALCULO,@P_FECHA_RECALCULO
	set @RowHandle += 1
END

/************************** LEYENDA

| USUARIO       | | FECHA      | | DESCRIPCIÓN
| Andrés Santos | | 30/11/2021 | | Creación del query
| David Jove	| | 30/10/2025 | | (121139) Se versionó el sp porque se versionó inventario.USP_COSTO_INVENTARIO_RECALCULAR_INDIVIDUAL_1 a inventario.USP_COSTO_INVENTARIO_RECALCULAR_INDIVIDUAL_2
| David Jove	| | 04/11/2025 | | (122181) Se versionó el sp. Se agregaron los parámetros @P_USUARIO_RECALCULO y @P_FECHA_RECALCULO. Se versionó el sp inventario.USP_COSTO_INVENTARIO_RECALCULAR_INDIVIDUAL_2 a inventario.USP_COSTO_INVENTARIO_RECALCULAR_INDIVIDUAL_3

***************************/