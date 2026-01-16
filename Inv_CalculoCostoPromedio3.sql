USE [ERP_TEST]
GO
/****** Object:  UserDefinedFunction [dbo].[Inv_CalculoCostoPromedio3]    Script Date: 16/01/2026 17:11:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [dbo].[Inv_CalculoCostoPromedio3]
(
	@RucE NVARCHAR(11),
	@Cd_Prod CHAR(7),
	@ID_UMP INT,
	@Cd_Alm VARCHAR(20),
	@FecMov DATETIME,
	@Cd_Mda CHAR(2),
	@Version CHAR(4)
)
RETURNS decimal(38,20)
BEGIN
--DECLARE
--@RucE nvarchar(11) = '20603091443',
--@Cd_Prod char(7)= 'PD04144',
--@ID_UMP int = 1,
--@Cd_Alm varchar(20)= '',
--@FecMov datetime = '11/12/2024',
--@Cd_Mda char(2) = '01',
--@Version char(4)= ''

DECLARE
@Cd_UM char(2),
@IB_KardexAlm bit,
@IB_KardexUM bit,
@CostoPromedio decimal(38,20),
@IMPORTES decimal(38,20),
@CANTIDADES decimal(38,20)

SELECT @Cd_UM = pum.Cd_UM FROM Prod_UM pum WHERE pum.RucE = @RucE and pum.Cd_Prod = @Cd_Prod and pum.ID_UMP = @Id_UMP
SELECT @IB_KardexAlm = IB_KardexAlm, @IB_KardexUM = IB_KardexUM FROM CfgGeneral WHERE RucE = @RucE

SELECT
	@IMPORTES =
	SUM(CASE WHEN @Cd_Mda = '01' 
			 THEN (CASE WHEN a.IC_ES = 'E' THEN a.Costo_MN_UM_Total ELSE (-1) * a.Costo_MN_UM_Total END)
			 ELSE (CASE WHEN a.IC_ES = 'E' THEN a.Costo_ME_UM_Total ELSE (-1) * a.Costo_ME_UM_Total END)
		END),
	@CANTIDADES = 
	SUM(CASE WHEN a.IC_ES = 'E' 
			 THEN a.Cantidad_UM_Principal
			 ELSE (-1) * a.Cantidad_UM_Principal
		END)
FROM
	VW_COSTO_INVENTARIO_PROMEDIO a
	LEFT JOIN GrupoDinamicoProductoVersiones b on a.RucE = b.RucE and a.Cd_Prod = b.Cd_Prod and CASE WHEN ISNULL(@Version,'') = '' THEN 1 ELSE b.Codigo END = CASE WHEN ISNULL(@Version,'') = '' THEN 1 ELSE @Version END
WHERE
	A.RucE = @RucE
	AND a.Cd_Prod = @Cd_Prod
	AND a.Cd_UM = CASE @IB_KardexUM WHEN 0 THEN a.Cd_UM WHEN 1 THEN @Cd_UM END
	AND CASE WHEN ISNULL(@Cd_Alm,'')= '' AND @IB_KardexAlm = 1 THEN '' ELSE a.Cd_Alm END = CASE @IB_KardexAlm WHEN 0 THEN ISNULL(a.Cd_Alm,'') WHEN 1 THEN ISNULL(@Cd_Alm,'') END
	AND a.FechaMovimiento < @FecMov

--SELECT @IMPORTES imp, @CANTIDADES cant
SET @CostoPromedio = CASE WHEN @CANTIDADES = 0 THEN 0 ELSE (ISNULL(@IMPORTES / @CANTIDADES, 0.00)) END

SET @CostoPromedio = CASE WHEN @CostoPromedio = 0.00 
						  THEN [dbo].[Inv_CostoUltimaSalida](@RucE,@Cd_Prod,@ID_UMP,@Cd_Alm,@FecMov,@Cd_Mda)
						  ELSE @CostoPromedio END

--SELECT ISNULL(@CostoPromedio,0)
RETURN ISNULL(@CostoPromedio,0.00)
END

/************************** LEYENDA
| USUARIO				| | FECHA| | DESCRIPCIÓN
| Andrés Santos			| | 26/10/2021 | | Creación del query
| Andrés Santos			| | 01/09/2022 | | Se valida que si la cantidad es 0, el costo promedio sera 0
| Rafael Linares		| | 27/10/2022 | | Se hicieron correcciones con respecto a la precision de los calculos para evitar la perdida de decimales por valores provenientes de Fabricacion Caso 72940
| Rafael Linares		| | 22/11/2022 | | Estandarizacion de registro y variables a precision 30,20
| Pedro Espinoza		| | 25/11/2022 | | Reducción de tiempo al cargar
| Williams Gutierrez	| | 25/11/2022 | | Se quito el convert a float por problemas con decimales
| David Jove			| | 21/08/2024 | | (100728) Se comentó la condición 'AND (a.Costo_MN_UM_Principal > 0 or a.Costo_ME_UM_Principal > 0)' porque no estaba trayendo las entradas con costo cero para el recálculo
| Rafael Linares		| | 01/10/2024 | | Opcion para costos con valor 0, se jala de la ultima venta
| Pedro Espinoza		| | 28/11/2024 | | (103099) Se valida si los importes y cantidades son nulos
| Pedro Espinoza		| | 11/12/2024 | | (103245) Se incrementa los decimales a 38,20 para tener mayor espacio y evitar un desboramiento aritmético
***************************/