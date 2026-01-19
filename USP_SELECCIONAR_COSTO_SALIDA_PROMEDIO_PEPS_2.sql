USE [ERP_TEST]
GO
/****** Object:  UserDefinedFunction [inventario].[USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS_2]    Script Date: 16/01/2026 16:47:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [inventario].[USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS_2]
(  
@P_RUC_EMPRESA VARCHAR(11),  
@P_FECHA_HASTA DATETIME,  
@P_CODIGO_MONEDA CHAR(2),  
@P_CODIGO_PRODUCTO CHAR(7),  
@P_ID_UMP INT,  
@P_CODIGO_ALMACEN VARCHAR(20)
) 

RETURNS NUMERIC(38,15)  

BEGIN
--DECLARE  
--@P_RUC_EMPRESA VARCHAR(11) = '20603091443',  
--@P_FECHA_HASTA DATETIME = '11/12/2024',  
--@P_CODIGO_MONEDA CHAR(2) = '02',  
--@P_CODIGO_PRODUCTO CHAR(7) = 'PD04144',  
--@P_ID_UMP INT = 1,  
--@P_CODIGO_ALMACEN VARCHAR(20) = ''
  
DECLARE   
@COSTO_INVENTARIO NUMERIC(38,20),  
@L_ESTADO CHAR(1) = 'B',  
@L_TIPO_COSTO VARCHAR(1),  
@L_IC_NOMBRE CHAR(1),  
@L_IC_CODIGO CHAR(1),  
@IB_KardexAlm BIT,  
@IB_KardexUM BIT,  
@Cd_UM char(2) = (SELECT Cd_UM FROM Prod_UM WHERE RucE=@P_RUC_EMPRESA and Cd_Prod=@P_CODIGO_PRODUCTO and ID_UMP=@P_ID_UMP),  
@IB_VARIAS_UMP_PRINCIPAL BIT = ISNULL((select C_IB_VARIAS_UMP_PRINCIPAL from Cfg_Inv_General where RucE=@P_RUC_EMPRESA),0),  
@CANTIDAD_DECIMALES_COSTO INT = 20  
  
IF (@IB_VARIAS_UMP_PRINCIPAL = 1)  
BEGIN  
SET @P_ID_UMP = ISNULL((select C_ID_UMP_PRINCIPAL from Prod_UM where RucE=@P_RUC_EMPRESA and Cd_Prod=@P_CODIGO_PRODUCTO and ID_UMP=@P_ID_UMP),@P_ID_UMP)  
SELECT TOP 1 @L_IC_NOMBRE = IC_DescripProd, @L_IC_CODIGO = IC_CodComerProd FROM Cfg_Inv_General WHERE RucE = @P_RUC_EMPRESA  
  
SELECT TOP 1  
 @L_TIPO_COSTO = CASE IC_TipoCostoInventario WHEN 'PROMEDIO' THEN 'M' WHEN 'PEPS' THEN 'P' END, --PROMEDIO(M) | PEPS(P)  
 @IB_KardexAlm = IB_KardexAlm,  
 @IB_KardexUM = IB_KardexUM  
FROM  
 CfgGeneral  
WHERE  
 RucE=@P_RUC_EMPRESA  
   
IF (@P_CODIGO_PRODUCTO = '')  
 SET @P_CODIGO_PRODUCTO = NULL  
  
SELECT TOP 1  
 --core.FechaMovimiento,  
 --core.Cd_Prod,  
 --core.ID_UMP_PRINCIPAL,  
 @COSTO_INVENTARIO = ISNULL(core.SaldoCosto,0) --as C_SALDO_COSTO  
FROM  
 (  
  SELECT   
   FechaMovimiento,  
   Cd_Prod,  
   ID_UMP_PRINCIPAL,  
   CASE @L_TIPO_COSTO  
    WHEN 'M' THEN  
       CASE WHEN core.SaldoCantidad = 0 THEN 0 ELSE core.SaldoTotal / core.SaldoCantidad END  
    WHEN 'P' THEN  
       CASE core.IC_ES WHEN 'E' THEN core.CostoEntradas WHEN 'S' THEN core.CostoSalidas ELSE 0 END  
    ELSE 0  
   END as SaldoCosto  
  FROM  
   (  
    SELECT  
     core.FechaMovimiento,  
     core.Cd_Prod,  
     core.ID_UMP_PRINCIPAL,  
     core.SaldoCantidad,  
     core.IC_ES,  
     core.CostoEntradas,  
     core.CostoSalidas,  
     core.CantidadEntradas * core.CostoEntradas as TotalEntradas,  
     core.CantidadSalidas * core.CostoSalidas as TotalSalidas,  
     CASE @L_ESTADO WHEN 'B' THEN  
      SUM (ROUND(CASE core.IC_ES WHEN 'E' THEN core.CantidadEntradas * core.CostoEntradas WHEN 'S' THEN -1 * ABS(core.CantidadSalidas * core.CostoSalidas) ELSE 0 END,@CANTIDAD_DECIMALES_COSTO))   
      OVER  
      (  
       PARTITION BY   
        core.Cd_Prod,  
        CASE WHEN @IB_KardexAlm = 1 THEN core.Cd_Alm ELSE '1' END,  
        CASE WHEN @IB_KardexUM = 1 THEN core.Cd_UM ELSE '1' END,   
        CASE @L_TIPO_COSTO WHEN 'P' THEN (CASE core.IC_ES WHEN 'E' THEN core.CostoEntradas WHEN 'S' THEN core.CostoSalidas ELSE 0 END) ELSE 1 END,  
        core.ID_UMP_PRINCIPAL  
       ORDER BY  
        core.FechaMovimiento,  
        core.Cd_INV,  
        core.Item ASC  
      )  
     ELSE  
      SUM (ROUND(CASE core.IC_ES WHEN 'E' THEN core.CantidadEntradas * core.CostoEntradas WHEN 'S' THEN -1 * ABS(core.CantidadSalidas * core.CostoSalidas) ELSE 0 END,@CANTIDAD_DECIMALES_COSTO))   
      OVER  
      (  
       PARTITION BY  
        core.Cd_Prod,  
        core.Cd_UM,  
        CASE @L_TIPO_COSTO WHEN 'P' THEN (CASE core.IC_ES WHEN 'E' THEN core.CostoEntradas WHEN 'S' THEN core.CostoSalidas ELSE 0 END) ELSE 1 END,  
        core.ID_UMP_PRINCIPAL  
       ORDER BY  
        core.FechaMovimiento,  
        core.Cd_INV,  
        core.Item ASC  
      )  
     END as SaldoTotal  
    FROM  
     (  
      SELECT  
       id.Cd_Alm,  
       id.Cd_Inv,  
       id.Item,  
       id.Cd_Prod,  
       pum.Cd_UM,  
       pumBase.ID_UMP_PRINCIPAL,  
       id.IC_ES,  
       id.FechaMovimiento,  
       CASE id.IC_ES WHEN 'E' THEN CASE @L_ESTADO WHEN 'B' THEN ISNULL(ci.Cantidad,0) * pum.FactorCalculado ELSE ISNULL(ci.Cantidad,0) END ELSE 0 END as CantidadEntradas,  
       CASE id.IC_ES WHEN 'S' THEN CASE @L_ESTADO WHEN 'B' THEN ISNULL(ci.Cantidad,0) * pum.FactorCalculado ELSE ISNULL(ci.Cantidad,0) END ELSE 0 END as CantidadSalidas,  
       CASE id.IC_ES WHEN 'E' THEN ISNULL(ci.Costo, 0) * (CASE ISNULL(pum.FactorCalculado,0) WHEN 0 THEN 0 ELSE 1.0/pum.FactorCalculado END) ELSE 0 END as CostoEntradas,  
       CASE id.IC_ES WHEN 'S' THEN ISNULL(ci.Costo, 0) END as CostoSalidas,  
       CASE @L_ESTADO WHEN 'B'   
        THEN   
         SUM (CASE id.IC_ES WHEN 'E' THEN ISNULL(ci.Cantidad,0) * pum.FactorCalculado WHEN 'S' THEN -1 * ABS(ISNULL(ci.Cantidad,0) * pum.FactorCalculado) ELSE 0 END)   
         OVER  
         (  
          PARTITION BY   
           id.Cd_Prod,  
           case when @L_TIPO_COSTO='P' then id.Cd_Alm else (CASE WHEN @IB_KardexAlm = 1 THEN id.Cd_Alm ELSE '1' END) end,  
           case when @L_TIPO_COSTO='P' then pum.Cd_UM else (CASE WHEN @IB_KardexUM = 1 THEN pum.Cd_UM ELSE '1' END) end,  
           CASE @L_TIPO_COSTO WHEN 'P' THEN ci.Costo ELSE 1 END,  
           pumBase.ID_UMP_PRINCIPAL  
          ORDER BY  
           id.FechaMovimiento,  
           id.Cd_INV,  
           id.Item ASC  
         )  
        ELSE   
         SUM (CASE id.IC_ES WHEN 'E' THEN ISNULL(ci.Cantidad,0) * pum.FactorCalculado WHEN 'S' THEN -1 * ABS(ISNULL(ci.Cantidad,0) * pum.FactorCalculado) ELSE 0 END)   
         OVER  
         (  
          PARTITION BY   
           id.Cd_Prod,   
           pum.Cd_UM,   
           CASE @L_TIPO_COSTO WHEN 'P' THEN ci.Costo ELSE 1 END,  
           pumBase.ID_UMP_PRINCIPAL  
          ORDER BY  
           id.FechaMovimiento,  
           id.Cd_INV,  
           id.Item ASC  
         )  
       END AS SaldoCantidad  
      FROM  
       (  
        SELECT   
         'SALDO_INICIAL' AS Cd_TO,  
         '' AS FechaMovimiento,  
         '-' AS RegistroContable,  
         id.RucE,  
         id.Cd_Prod AS Cd_Inv,  
         id.Cd_Prod,  
         Convert(varchar,CASE WHEN @IB_KardexUM = 1 THEN id.ID_UMP ELSE 0 END) + CASE WHEN @IB_KardexAlm = 1 THEN id.Cd_Alm ELSE 'ALM' END AS Item,  
         CASE WHEN @IB_KardexUM = 1 THEN id.ID_UMP ELSE 0 END AS ID_UMP,  
         CASE WHEN @IB_KardexAlm = 1 THEN id.Cd_Alm ELSE 'ALM' END AS Cd_Alm,  
         SUM(id.Cantidad) AS Cantidad,  
         '-' AS Cd_CC,  
         '-' AS Cd_SC,  
         '-' AS Cd_SS,  
         'E' AS IC_ES  
        FROM  
         InventarioDet2 id WITH(NOLOCK)  
         INNER JOIN Inventario2 i WITH(NOLOCK) on i.RucE = id.RucE AND i.Cd_Inv = id.Cd_Inv  
         LEFT JOIN Almacen alm on alm.RucE = id.RucE AND alm.Cd_Alm = id.Cd_Alm  
        WHERE  
         id.RucE = @P_RUC_EMPRESA  
         and id.Cd_Prod = @P_CODIGO_PRODUCTO  
         AND ISNULL(alm.IB_EsVi, 0) = 0  
         AND CASE @L_ESTADO WHEN 'P' THEN 1 ELSE 0 END = 1  
        GROUP BY  
         id.RucE,  
         id.Cd_Prod,  
         CASE WHEN @IB_KardexAlm = 1 THEN id.Cd_Alm ELSE 'ALM' END,  
         CASE WHEN @IB_KardexUM = 1 THEN id.ID_UMP ELSE 0 END   
  
        UNION ALL  
  
        SELECT  
         i.Cd_TO,  
         i.FechaMovimiento,  
         i.RegistroContable,  
         id.RucE,  
         id.Cd_Inv,  
         id.Cd_Prod,  
         Convert(varchar,id.Item) as Item,  
         id.ID_UMP,  
         id.Cd_Alm,  
         id.Cantidad,  
         id.Cd_CC,  
         id.Cd_SC,  
         id.Cd_SS,  
         id.IC_ES  
        FROM  
         InventarioDet2 id WITH(NOLOCK)  
         INNER  JOIN Inventario2 i WITH(NOLOCK) on i.RucE = id.RucE AND i.Cd_Inv = id.Cd_Inv  
         LEFT JOIN Almacen alm on alm.RucE = id.RucE and alm.Cd_Alm = id.Cd_Alm  
        WHERE  
         id.RucE = @P_RUC_EMPRESA  
         and id.Cd_Prod = @P_CODIGO_PRODUCTO  
         AND ISNULL(alm.IB_EsVi, 0) = 0              
         --FILTRO HASTA  
         AND i.FechaMovimiento <= CASE WHEN @P_FECHA_HASTA IS NULL THEN i.FechaMovimiento ELSE CONVERT(datetime, @P_FECHA_HASTA) + ' 23:59:29' END  
       ) as  id  
       LEFT JOIN  
       (  
        SELECT  
         pum.RucE,  
         pum.Cd_Prod,  
         pum.Cd_UM,  
         NULL as ID_UMP,  
         pum.Factor,  
         pum.IC_CL,  
         pum.ID_UMP as ID_UMP_PRINCIPAL  
        FROM  
         Prod_UM pum  
        WHERE   
         @IB_VARIAS_UMP_PRINCIPAL = 0  
         AND pum.RucE = @P_RUC_EMPRESA  
         AND pum.Cd_Prod = @P_CODIGO_PRODUCTO  
         AND pum.IB_UMPPrin = 1  
         AND pum.Factor = 1  
  
         UNION ALL  
  
        SELECT  
         ISNULL(pumB.RucE,pum.RucE) as RucE,  
         ISNULL(pumB.Cd_Prod,pum.Cd_Prod) as Cd_Prod,  
         ISNULL(pumB.Cd_UM,pum.Cd_UM) as Cd_UM,  
         ISNULL(pum.ID_UMP,0) as ID_UMP,  
         ISNULL(pumB.Factor,pum.Factor) as Factor,  
         ISNULL(pumB.IC_CL,pum.IC_CL) as IC_CL,  
         ISNULL(pumB.ID_UMP,pum.ID_UMP) as ID_UMP_PRINCIPAL  
        FROM  
         Prod_UM pum  
         left join Prod_UM pumB on pumB.RucE=pum.RucE and pumB.Cd_Prod=pum.Cd_Prod and pumB.ID_UMP=pum.C_ID_UMP_PRINCIPAL  
        WHERE   
         @IB_VARIAS_UMP_PRINCIPAL = 1  
         AND pum.RucE = @P_RUC_EMPRESA  
         AND pum.Cd_Prod = @P_CODIGO_PRODUCTO  
       ) AS pumBase ON pumBase.RucE = id.RucE and pumBase.Cd_Prod = id.Cd_Prod and ISNULL(pumBase.ID_UMP,id.ID_UMP)=id.ID_UMP  
       LEFT JOIN  
       (  
        SELECT  
         pum.RucE,  
         pum.Cd_Prod,  
         pum.ID_UMP,  
         pum.Factor,  
         pum.DescripAlt,  
         CASE WHEN ISNULL(pum.IC_CL,'') = '' OR pum.IC_CL = 'M' THEN pum.Factor ELSE (CASE WHEN pum.Factor = 0 THEN 0 ELSE 1.0 / pum.Factor END) END as FactorCalculado,  
         pum.Cd_UM   
        FROM  
         Prod_UM pum  
        WHERE  
         pum.RucE = @P_RUC_EMPRESA  
         and pum.cd_prod = @P_CODIGO_PRODUCTO  
       ) as pum on pum.RucE = id.RucE AND pum.Cd_Prod = id.Cd_Prod AND pum.ID_UMP = id.ID_UMP  
       LEFT JOIN  
       (  
        SELECT  
         core.RucE,  
         core.IC_ES,  
         core.Cd_Inv,  
         core.Item,  
         core.Costo,  
         SUM(core.Cantidad) as Cantidad,  
         core.TipoCosto,  
         SUM(core.CantidadSecundaria) as CantidadSecundaria,  
         core.TipoDocumentoAuxiliar,  
         core.NumeroDocumentoAuxiliar,  
         core.NombreAuxiliar,  
         core.Cd_prod  
        FROM  
         (  
          SELECT  
           *  
          FROM  
           (  
            SELECT   
             ci.RucE,  
             id.IC_ES,  
             ci.Cd_Inv,  
             Convert(varchar,ci.Item) as Item,  
             CONVERT(float,CASE @P_CODIGO_MONEDA WHEN '01' THEN ci.Costo_MN WHEN '02' THEN ci.Costo_ME ELSE 0 END) AS Costo,  
             ci.Cantidad,  
             ci.IC_TipoCostoInventario as TipoCosto,  
             ci.Cd_Inv_Entrada,  
             ci.Item_Entrada,  
             ci.CantidadSecundaria,  
             CASE WHEN i.C_CODIGO_PROVEEDOR is not null THEN p2.Cd_TDI  
               WHEN i.C_CODIGO_CLIENTE is not null THEN c2.Cd_TDI  
             END AS TipoDocumentoAuxiliar,  
             CASE WHEN i.C_CODIGO_PROVEEDOR is not null THEN p2.Ndoc  
               WHEN i.C_CODIGO_CLIENTE is not null THEN c2.Ndoc  
             END AS NumeroDocumentoAuxiliar,  
             CASE WHEN i.C_CODIGO_PROVEEDOR is not null THEN COALESCE(p2.RSocial, p2.Nom + ' ' + p2.ApPat + ' ' + p2.ApMat)  
               WHEN i.C_CODIGO_CLIENTE is not null THEN COALESCE(c2.RSocial, c2.Nom + ' ' + c2.ApPat + ' ' + c2.ApMat)  
             END AS NombreAuxiliar,  
             id.Cd_Prod  
            FROM  
             CostoInventario ci WITH(NOLOCK)  
             INNER JOIN InventarioDet2 id WITH(NOLOCK) on ci.RucE = id.RucE and ci.Cd_Inv = id.Cd_Inv and ci.Item = id.Item  
             INNER JOIN Inventario2 i WITH(NOLOCK) on i.RucE = ci.RucE and i.cd_inv = id.cd_inv  
             LEFT JOIN Almacen alm on alm.RucE = id.RucE and alm.Cd_Alm = id.Cd_Alm  
             LEFT JOIN Cliente2 c2 on c2.RucE = i.RucE and c2.Cd_Clt = i.C_CODIGO_CLIENTE  
             LEFT JOIN Proveedor2 p2 on p2.RucE = i.RucE and p2.Cd_Prv = i.C_CODIGO_PROVEEDOR  
            WHERE  
             ci.RucE = @P_RUC_EMPRESA and id.cd_prod = @P_CODIGO_PRODUCTO  
             AND ISNULL(alm.IB_EsVi, 0) = 0  
           ) as core  
          WHERE  
           ISNULL(core.TipoCosto, @L_TIPO_COSTO) = @L_TIPO_COSTO  
           and core.ruce = @P_RUC_EMPRESA  
           and core.cd_prod = @P_CODIGO_PRODUCTO  
         ) AS core   
        GROUP BY  
         core.RucE,  
         core.IC_ES,  
         core.Cd_Inv,  
         core.Item,  
         core.Costo,  
         core.TipoCosto,  
         core.TipoDocumentoAuxiliar,  
         core.NumeroDocumentoAuxiliar,  
         core.NombreAuxiliar,  
         core.Cd_prod  
       ) as ci on ci.RucE = id.RucE AND ci.Cd_Inv = id.Cd_Inv AND convert(varchar,ci.Item) = convert(varchar,id.Item)  
      WHERE  
       id.RucE = @P_RUC_EMPRESA  
       and pumBase.ID_UMP_PRINCIPAL=@P_ID_UMP  
       and id.Cd_Prod = @P_CODIGO_PRODUCTO
       and CASE WHEN @IB_KardexUM = 1 THEN pum.Cd_UM ELSE '1' END = CASE WHEN @IB_KardexUM = 1 THEN ISNULL(@Cd_UM,pum.Cd_UM) ELSE '1' END
       and CASE WHEN @IB_KardexAlm = 1 THEN id.Cd_Alm ELSE '1' END = CASE WHEN @IB_KardexAlm = 1 THEN ISNULL(@P_CODIGO_ALMACEN,id.Cd_Alm) ELSE '1' END
	   and id.FechaMovimiento <= @P_FECHA_HASTA  -- CORREGIDO: Cambiado < por <= para incluir movimientos de la misma fecha/hora
     ) as core  
   ) as core  
 ) AS core  
ORDER BY  
 core.FechaMovimiento desc
OPTION(RECOMPILE)  
END  
ELSE  
BEGIN  
 SET @COSTO_INVENTARIO = dbo.Inv_CalculoCostoPromedio3(@P_RUC_EMPRESA,@P_CODIGO_PRODUCTO,@P_ID_UMP,@P_CODIGO_ALMACEN,@P_FECHA_HASTA,@P_CODIGO_MONEDA,'')
END  

return @COSTO_INVENTARIO
--select @COSTO_INVENTARIO
  
END  
  
/************************** LEYENDA
--DJ: 03/03/2021 <Se creó la función para obtener el costo de salida PROMEDIO o PEPS, considerando la configuración C_IB_VARIAS_UMP_PRINCIPAL>  
--DJ: 23/03/2021 <Se condicionó para que consulte Inv_CalculoCostoPromedio cuando no está utilizando la configuración C_IB_VARIAS_UMP_PRINCIPAL>  
--DJ: 24/03/2021 <Se agregó el WITH(NOLOCK) y OPTION(RECOMPILE)>  
--AB: 14/04/2021 <Se modificó el tipo de parámetro @P_FECHA_HASTA por DataTime>
--Andrés Santos : 26/10/2021 <Se agregó la función dbo.Inv_CalculoCostoPromedio2
--RL: 27/10/2022 <Se hicieron correcciones con respecto a la precisión de los cálculos para evitar la perdida de decimales por valores provenientes de Fabricacion Caso 72940>
--DJ: 30/04/2024 <Se corrigió el cálculo cuando @IB_VARIAS_UMP_PRINCIPAL esté activo. Se agregó el filtro 'id.FechaMovimiento < @P_FECHA_HASTA'>
--RL: 03/10/2024 <Se versiono la funcion Inv_CalculoCostoPromedio3>
| PE: 11/12/2024 <(103245) Se incrementa los decimales a 38,15 para tener mayor espacio y evitar un desboramiento aritmético>
--FIX: 16/01/2026 <BUGFIX CRÍTICO línea 353: Cambiado operador < por <= para incluir movimientos de la misma fecha/hora exacta.
                   Esto corrige el error donde se calculaba costo incorrecto (ej: 3.991195 en lugar de 3.102090) causando saldos negativos.
                   El operador < excluía movimientos del mismo momento, violando la lógica del costo promedio ponderado con IB_KardexAlm=1>
***************************/