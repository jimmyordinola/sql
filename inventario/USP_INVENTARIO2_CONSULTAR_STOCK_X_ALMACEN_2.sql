USE [ERP_ECHA]
GO
/****** Object:  StoredProcedure [inventario].[USP_INVENTARIO2_CONSULTAR_STOCK_X_ALMACEN_2]    Script Date: 23/01/2026 10:08:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [inventario].[USP_INVENTARIO2_CONSULTAR_STOCK_X_ALMACEN_2]
@P_RUCE NVARCHAR(11),
@P_CD_ALM VARCHAR(20),
@P_FECHA_HASTA DATETIME,
@P_USUARIO NVARCHAR(10),
@P_EJERCICIO CHAR(4)
AS
--DECLARE
--@P_RUCE NVARCHAR(11) = '20102351038',
--@P_CD_ALM VARCHAR(20) = 'A01',
--@P_FECHA_HASTA DATETIME = '07/05/2025',
--@P_USUARIO NVARCHAR(10) = 'contanet',
--@P_EJERCICIO CHAR(4) = '2025'

DECLARE
@IB_CONVERTIR_UMP BIT = ISNULL((select C_IB_CONVERTIR_UMP from Config_Inventario2 where RucE=@P_RUCE and Ejer=@P_EJERCICIO and Usuario=@P_USUARIO),0)

-- DETALLADO
SELECT
	*
FROM
	(
		SELECT
			a.RucE,
			a.Cd_Alm,
			a.Cd_Prod,
			a.Producto,
			CONVERT(DECIMAL(20,3),ROUND(ISNULL(a.StockMin,0),3)) AS StockMin,
			CONVERT(DECIMAL(20,3),ROUND(ISNULL(a.StockMax,0),3)) AS StockMax,
			CONVERT(DECIMAL(20,3),ROUND(ISNULL(e.CantAlm_Entradas,0),3)) as CantAlm_Entradas,
			CONVERT(DECIMAL(20,3),ROUND(ISNULL(s.CantAlm_Salidas,0),3)) as CantAlm_Salidas,
			CONVERT(DECIMAL(20,3),ROUND((ISNULL(e.CantAlm_Entradas,0) - ISNULL(s.CantAlm_Salidas,0)),3)) as StockActual,
			0 as CantAlm,
			0 as StockOrd,
			0 as StockRcb,
			0 as StockPenRcb,
			0 as StockPed,
			0 as StockEnt,
			0 as StockPenEnt
		FROM
			(
				SELECT
					p.RucE,
					p.Cd_Prod,
					a.Cd_Alm,
					p.Nombre1 as Producto,
					p.StockMin,
					p.StockMax
				FROM
					Almacen as a,
					producto2 as p
				WHERE
					P.RucE=@P_RUCE
					and p.RucE=a.RucE
					and a.Cd_Alm like @P_CD_ALM+'%'
			) AS a
			LEFT JOIN
			(
				SELECT
					id2.RucE,
					id2.Cd_Prod,
					id2.Cd_Alm,
					SUM(CASE WHEN @IB_CONVERTIR_UMP=1 THEN (CASE WHEN ISNULL(pum.IC_CL,'M')='M' THEN id2.Cantidad * pum.Factor ELSE id2.Cantidad / (CASE WHEN ISNULL(pum.Factor,0)=0 THEN 1 ELSE pum.Factor END) END) ELSE id2.Cantidad END) AS CantAlm_Entradas --CantAlm
				FROM
					InventarioDet2 id2
					LEFT JOIN Inventario2 i2 on id2.RucE=i2.RucE and id2.Cd_Inv=i2.Cd_Inv
					LEFT JOIN Prod_UM pum on pum.RucE=id2.RucE and pum.Cd_Prod=id2.Cd_Prod and pum.ID_UMP=id2.ID_UMP
				WHERE
					id2.RucE=@P_RUCE
					AND id2.Cd_Alm LIKE @P_CD_ALM+'%'
					AND CONVERT(date,i2.FechaMovimiento)<=CONVERT(date,@P_FECHA_HASTA)
					AND id2.IC_ES='E'
				GROUP BY
					id2.RucE,
					id2.Cd_Prod,
					id2.Cd_Alm
			) AS e ON e.RucE=a.RucE and e.Cd_Prod=a.Cd_Prod and e.Cd_Alm=a.Cd_Alm
			LEFT JOIN
			(
				SELECT
					id2.RucE,
					id2.Cd_Prod,
					id2.Cd_Alm,
					SUM(CASE WHEN @IB_CONVERTIR_UMP=1 THEN (CASE WHEN ISNULL(pum.IC_CL,'M')='M' THEN id2.Cantidad * pum.Factor ELSE id2.Cantidad / (CASE WHEN ISNULL(pum.Factor,0)=0 THEN 1 ELSE pum.Factor END) END) ELSE id2.Cantidad END) AS CantAlm_Salidas --CantAlm
				FROM
					InventarioDet2 id2
					LEFT JOIN Inventario2 i2 on id2.RucE=i2.RucE and id2.Cd_Inv=i2.Cd_Inv
					LEFT JOIN Prod_UM pum on pum.RucE=id2.RucE and pum.Cd_Prod=id2.Cd_Prod and pum.ID_UMP=id2.ID_UMP
				WHERE
					id2.RucE=@P_RUCE
					AND id2.Cd_Alm like @P_CD_ALM+'%'
					AND CONVERT(date,i2.FechaMovimiento)<=CONVERT(date,@P_FECHA_HASTA)
					AND id2.IC_ES='S'
				GROUP BY
					id2.RucE,
					id2.Cd_Prod,
					id2.Cd_Alm
			) AS s ON s.RucE=a.RucE and s.Cd_Prod=a.Cd_Prod and s.Cd_Alm=a.Cd_Alm
		WHERE
			(e.CantAlm_Entradas IS NOT NULL OR s.CantAlm_Salidas IS NOT NULL)
	) as Stock
ORDER BY
	Cd_Alm,
	Cd_Prod

-- RESUMIDO
SELECT
	*
FROM
	(
		SELECT 
			a.RucE,
			a.Cd_Prod, 
			a.Producto, 
			CONVERT(DECIMAL(20,3),ROUND(ISNULL(a.StockMin,0),3)) AS StockMin,
			CONVERT(DECIMAL(20,3),ROUND(ISNULL(a.StockMax,0),3)) AS StockMax,
			CONVERT(DECIMAL(20,3),ROUND(ISNULL(e.CantAlm_Entradas,0),3)) as CantAlm_Entradas,
			CONVERT(DECIMAL(20,3),ROUND(ISNULL(s.CantAlm_Salidas,0),3)) as CantAlm_Salidas,
			CONVERT(DECIMAL(20,3),ROUND((ISNULL(e.CantAlm_Entradas,0) - ISNULL(s.CantAlm_Salidas,0)),3)) as StockActual,
			0 as CantAlm,
			0 as StockOrd,
			0 as StockRcb,
			0 as StockPenRcb,
			0 as StockPed,
			0 as StockEnt,
			0 as StockPenEnt
		FROM
			(
				SELECT
					p.RucE,
					p.Cd_Prod,
					p.Nombre1 as Producto,
					p.StockMin,
					p.StockMax
				FROM
					producto2 as p
				WHERE
					p.RucE=@P_RUCE
			) AS a
			LEFT JOIN
			(
				SELECT 
					id2.RucE,
					id2.Cd_Prod,
					SUM(CASE WHEN @IB_CONVERTIR_UMP=1 THEN (CASE WHEN ISNULL(pum.IC_CL,'M')='M' THEN id2.Cantidad * pum.Factor ELSE id2.Cantidad / (CASE WHEN ISNULL(pum.Factor,0)=0 THEN 1 ELSE pum.Factor END) END) ELSE id2.Cantidad END) AS CantAlm_Entradas --CantAlm
				FROM
					InventarioDet2 id2
					LEFT JOIN Inventario2 i2 on id2.ruce=i2.RucE and id2.Cd_Inv=i2.Cd_Inv
					LEFT JOIN Prod_UM pum on pum.RucE=id2.RucE and pum.Cd_Prod=id2.Cd_Prod and pum.ID_UMP=id2.ID_UMP
				WHERE 
					id2.RucE=@P_RUCE
					AND id2.Cd_Alm LIKE @P_CD_ALM+'%'
					AND CONVERT(date,i2.FechaMovimiento)<=CONVERT(date,@P_FECHA_HASTA)
					AND id2.IC_ES='E'
				GROUP BY
					id2.RucE,
					id2.Cd_Prod
			) AS e ON e.RucE=a.RucE and e.Cd_Prod=a.Cd_Prod
			LEFT JOIN
			(
				SELECT
					id2.RucE,
					id2.Cd_Prod,
					SUM(CASE WHEN @IB_CONVERTIR_UMP=1 THEN (CASE WHEN ISNULL(pum.IC_CL,'M')='M' THEN id2.Cantidad * pum.Factor ELSE id2.Cantidad / (CASE WHEN ISNULL(pum.Factor,0)=0 THEN 1 ELSE pum.Factor END) END) ELSE id2.Cantidad END) AS CantAlm_Salidas --CantAlm
				FROM
					InventarioDet2 id2
					LEFT JOIN Inventario2 i2 ON id2.ruce=i2.RucE and id2.Cd_Inv=i2.Cd_Inv
					LEFT JOIN Prod_UM pum on pum.RucE=id2.RucE and pum.Cd_Prod=id2.Cd_Prod and pum.ID_UMP=id2.ID_UMP
				WHERE
					id2.RucE=@P_RUCE
					AND id2.Cd_Alm LIKE @P_CD_ALM+'%'
					AND CONVERT(date,i2.FechaMovimiento)<=CONVERT(date,@P_FECHA_HASTA)
					AND id2.IC_ES='S'
				GROUP BY
					id2.RucE,
					id2.Cd_Prod
			) AS s ON s.RucE=a.RucE and s.Cd_Prod=a.Cd_Prod
		WHERE
			(e.CantAlm_Entradas IS NOT NULL OR s.CantAlm_Salidas IS NOT NULL)
	) AS Stock
ORDER BY
	Cd_Prod

--Leyenda
--David Jove: 24/10/2025 <(121157) Se versionó el sp. Se agregaron los parámetros @P_USUARIO y @P_EJERCICIO para consultar @IB_CONVERTIR_UMP y poder afectar la cantidad por el factor cuando corresponda>