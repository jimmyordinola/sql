-- =============================================
-- Verificar qué fecha usó el recálculo
-- =============================================

USE [ERP_TEST]
GO

SET NOCOUNT ON;

PRINT '========================================================================';
PRINT 'DIAGNÓSTICO: ¿Qué fecha de recálculo se usó?';
PRINT '========================================================================';
PRINT '';

-- Simular el cálculo que hace USP_COSTO_INVENTARIO_RECALCULAR_4
DECLARE @FechaMovimiento DATETIME = '2025-04-28';
DECLARE @P_FECHA_RECALCULO_REAL DATETIME;

SELECT
    @P_FECHA_RECALCULO_REAL = CASE
        WHEN DATEADD(DAY,1,EOMONTH(MAX(FechaCierre))) > @FechaMovimiento
        THEN DATEADD(DAY,1,EOMONTH(MAX(FechaCierre)))
        ELSE @FechaMovimiento
    END
FROM CierreProcesoxFecha
WHERE RucE = '20102351038'
  AND Cd_MR = '19';

PRINT 'Parámetro @FechaMovimiento pasado: ' + CONVERT(VARCHAR(20), @FechaMovimiento, 120);
PRINT 'Fecha REAL usada por el recálculo: ' + CONVERT(VARCHAR(20), @P_FECHA_RECALCULO_REAL, 120);
PRINT '';

-- Verificar último cierre
SELECT
    'Último Cierre Inventario' AS Info,
    MAX(FechaCierre) AS UltimaFechaCierre,
    DATEADD(DAY,1,EOMONTH(MAX(FechaCierre))) AS FechaCalculada,
    CASE
        WHEN DATEADD(DAY,1,EOMONTH(MAX(FechaCierre))) > '2025-04-28'
        THEN 'El recálculo comenzó DESPUÉS del 28-04 (por cierre contable)'
        ELSE 'El recálculo comenzó el 28-04'
    END AS Interpretacion
FROM CierreProcesoxFecha
WHERE RucE = '20102351038'
  AND Cd_MR = '19';

PRINT '';
PRINT '========================================================================';
PRINT 'PROBLEMA IDENTIFICADO:';
PRINT '========================================================================';
PRINT '';
PRINT 'Si la "Fecha REAL" es POSTERIOR al 29-04-2025, entonces el recálculo';
PRINT 'NO procesó los movimientos INV000297367 (29-04 08:05) e INV000297372';
PRINT '(29-04 08:50) porque comenzó DESPUÉS de esas fechas.';
PRINT '';
PRINT 'SOLUCIÓN:';
PRINT 'Recalcular desde una fecha MÁS ANTIGUA que garantice incluir todos';
PRINT 'los movimientos problemáticos.';
PRINT '';
PRINT '========================================================================';
