-- ============================================
-- Comparar resultados: SP Original vs Optimizado
-- ============================================

USE [ERP_ECHA]
GO

-- Crear tablas temporales para guardar resultados
IF OBJECT_ID('tempdb..#RESULTADO_ORIGINAL') IS NOT NULL DROP TABLE #RESULTADO_ORIGINAL
IF OBJECT_ID('tempdb..#RESULTADO_OPTIMIZADO') IS NOT NULL DROP TABLE #RESULTADO_OPTIMIZADO

-- Crear estructura para almacenar resultados
CREATE TABLE #RESULTADO_ORIGINAL (
    Ib_Aut BIT, Ib_Agrup INT, Agrupado INT, Cd_Vou INT,
    NroCta VARCHAR(50), NomCta VARCHAR(200), NomAux VARCHAR(400),
    FecMov DATE, FecED DATE, FecVD DATE,
    DR_CdTD NVARCHAR(2), DR_NSre VARCHAR(20), DR_NDoc VARCHAR(20),
    Cd_Td NVARCHAR(2), NroSre VARCHAR(20), NroDoc VARCHAR(20),
    Glosa VARCHAR(500), SaldoS NUMERIC(30,10), SaldoD NUMERIC(30,10),
    MdReg CHAR(5), Cd_CC VARCHAR(8), NombreCentroCostos VARCHAR(200),
    Cd_SC VARCHAR(8), NombreSubCentroCostos VARCHAR(200),
    Cd_SS VARCHAR(8), NombreSubSubCentroCostos VARCHAR(200),
    Cd_Clt CHAR(10), Cd_Prv CHAR(7), Cd_Trab CHAR(8),
    RegCtb NVARCHAR(15), FechaOrigen DATETIME,
    IB_AgRet BIT, IB_BuenContrib BIT,
    MtoD NUMERIC(30,10), MtoH NUMERIC(30,10),
    Ic_ES CHAR(1), Obs VARCHAR(500), NomUsu VARCHAR(100),
    C_ID_CONCEPTO_FEC INT, IB_Dtr BIT
)

CREATE TABLE #RESULTADO_OPTIMIZADO (
    Ib_Aut BIT, Ib_Agrup INT, Agrupado INT, Cd_Vou INT,
    NroCta VARCHAR(50), NomCta VARCHAR(200), NomAux VARCHAR(400),
    FecMov DATE, FecED DATE, FecVD DATE,
    DR_CdTD NVARCHAR(2), DR_NSre VARCHAR(20), DR_NDoc VARCHAR(20),
    Cd_Td NVARCHAR(2), NroSre VARCHAR(20), NroDoc VARCHAR(20),
    Glosa VARCHAR(500), SaldoS NUMERIC(30,10), SaldoD NUMERIC(30,10),
    MdReg CHAR(5), Cd_CC VARCHAR(8), NombreCentroCostos VARCHAR(200),
    Cd_SC VARCHAR(8), NombreSubCentroCostos VARCHAR(200),
    Cd_SS VARCHAR(8), NombreSubSubCentroCostos VARCHAR(200),
    Cd_Clt CHAR(10), Cd_Prv CHAR(7), Cd_Trab CHAR(8),
    RegCtb NVARCHAR(15), FechaOrigen DATETIME,
    IB_AgRet BIT, IB_BuenContrib BIT,
    MtoD NUMERIC(30,10), MtoH NUMERIC(30,10),
    Ic_ES CHAR(1), Obs VARCHAR(500), NomUsu VARCHAR(100),
    C_ID_CONCEPTO_FEC INT, IB_Dtr BIT
)

-- Ejecutar SP Original (usa el que tenías antes - ajusta el nombre si es diferente)
-- INSERT INTO #RESULTADO_ORIGINAL
-- EXEC contabilidad.USP_VOUCHER_DOCS_CONTABLE_SIN_ANEXO_4
--     @P_RUCE = '20102351038', @P_EJER = N'2025',
--     @P_CD_CLT = '', @P_CD_PRV = '       ', @P_CD_TRAB = '        ',
--     @P_IC_ES = 'I', @P_NUMERACION = NULL

-- Ejecutar SP Optimizado
INSERT INTO #RESULTADO_OPTIMIZADO
EXEC contabilidad.USP_VOUCHER_DOCS_CONTABLE_SIN_ANEXO_4_PERIODO
    @P_RUCE = '20102351038', @P_EJER = N'2025',
    @P_CD_CLT = '', @P_CD_PRV = '       ', @P_CD_TRAB = '        ',
    @P_IC_ES = 'I', @P_NUMERACION = NULL

-- ============================================
-- COMPARACIONES
-- ============================================

-- 1. Contar registros
SELECT 'Conteo de registros' AS Comparacion
SELECT
    (SELECT COUNT(*) FROM #RESULTADO_ORIGINAL) AS Total_Original,
    (SELECT COUNT(*) FROM #RESULTADO_OPTIMIZADO) AS Total_Optimizado,
    CASE
        WHEN (SELECT COUNT(*) FROM #RESULTADO_ORIGINAL) = (SELECT COUNT(*) FROM #RESULTADO_OPTIMIZADO)
        THEN 'OK - Mismo número de registros'
        ELSE 'ERROR - Diferente número de registros'
    END AS Resultado

-- 2. Registros en Original que NO están en Optimizado
SELECT 'Registros en ORIGINAL que NO están en OPTIMIZADO' AS Comparacion
SELECT o.Cd_Vou, o.NroCta, o.Cd_Clt, o.Cd_Prv, o.DR_NDoc, o.SaldoS, o.SaldoD
FROM #RESULTADO_ORIGINAL o
WHERE NOT EXISTS (
    SELECT 1 FROM #RESULTADO_OPTIMIZADO n
    WHERE ISNULL(o.Cd_Vou, 0) = ISNULL(n.Cd_Vou, 0)
    AND ISNULL(o.NroCta, '') = ISNULL(n.NroCta, '')
    AND ISNULL(o.DR_NDoc, '') = ISNULL(n.DR_NDoc, '')
    AND ISNULL(o.Cd_Clt, '') = ISNULL(n.Cd_Clt, '')
    AND ISNULL(o.Cd_Prv, '') = ISNULL(n.Cd_Prv, '')
)

-- 3. Registros en Optimizado que NO están en Original
SELECT 'Registros en OPTIMIZADO que NO están en ORIGINAL' AS Comparacion
SELECT n.Cd_Vou, n.NroCta, n.Cd_Clt, n.Cd_Prv, n.DR_NDoc, n.SaldoS, n.SaldoD
FROM #RESULTADO_OPTIMIZADO n
WHERE NOT EXISTS (
    SELECT 1 FROM #RESULTADO_ORIGINAL o
    WHERE ISNULL(o.Cd_Vou, 0) = ISNULL(n.Cd_Vou, 0)
    AND ISNULL(o.NroCta, '') = ISNULL(n.NroCta, '')
    AND ISNULL(o.DR_NDoc, '') = ISNULL(n.DR_NDoc, '')
    AND ISNULL(o.Cd_Clt, '') = ISNULL(n.Cd_Clt, '')
    AND ISNULL(o.Cd_Prv, '') = ISNULL(n.Cd_Prv, '')
)

-- 4. Diferencias en montos (mismo registro pero valores diferentes)
SELECT 'Diferencias en MONTOS' AS Comparacion
SELECT
    o.Cd_Vou, o.NroCta, o.DR_NDoc,
    o.SaldoS AS SaldoS_Original, n.SaldoS AS SaldoS_Optimizado,
    o.SaldoD AS SaldoD_Original, n.SaldoD AS SaldoD_Optimizado,
    o.MtoD AS MtoD_Original, n.MtoD AS MtoD_Optimizado,
    o.MtoH AS MtoH_Original, n.MtoH AS MtoH_Optimizado
FROM #RESULTADO_ORIGINAL o
INNER JOIN #RESULTADO_OPTIMIZADO n ON
    ISNULL(o.Cd_Vou, 0) = ISNULL(n.Cd_Vou, 0)
    AND ISNULL(o.NroCta, '') = ISNULL(n.NroCta, '')
    AND ISNULL(o.DR_NDoc, '') = ISNULL(n.DR_NDoc, '')
WHERE ROUND(o.SaldoS, 2) <> ROUND(n.SaldoS, 2)
   OR ROUND(o.SaldoD, 2) <> ROUND(n.SaldoD, 2)
   OR ROUND(o.MtoD, 2) <> ROUND(n.MtoD, 2)
   OR ROUND(o.MtoH, 2) <> ROUND(n.MtoH, 2)

-- 5. Resumen final
SELECT 'RESUMEN FINAL' AS Comparacion
SELECT
    (SELECT COUNT(*) FROM #RESULTADO_ORIGINAL) AS Registros_Original,
    (SELECT COUNT(*) FROM #RESULTADO_OPTIMIZADO) AS Registros_Optimizado,
    (SELECT COUNT(*) FROM #RESULTADO_ORIGINAL o
     WHERE NOT EXISTS (SELECT 1 FROM #RESULTADO_OPTIMIZADO n
        WHERE ISNULL(o.Cd_Vou,0)=ISNULL(n.Cd_Vou,0) AND ISNULL(o.NroCta,'')=ISNULL(n.NroCta,'')
        AND ISNULL(o.DR_NDoc,'')=ISNULL(n.DR_NDoc,''))) AS Solo_En_Original,
    (SELECT COUNT(*) FROM #RESULTADO_OPTIMIZADO n
     WHERE NOT EXISTS (SELECT 1 FROM #RESULTADO_ORIGINAL o
        WHERE ISNULL(o.Cd_Vou,0)=ISNULL(n.Cd_Vou,0) AND ISNULL(o.NroCta,'')=ISNULL(n.NroCta,'')
        AND ISNULL(o.DR_NDoc,'')=ISNULL(n.DR_NDoc,''))) AS Solo_En_Optimizado

-- Limpiar
DROP TABLE #RESULTADO_ORIGINAL
DROP TABLE #RESULTADO_OPTIMIZADO
