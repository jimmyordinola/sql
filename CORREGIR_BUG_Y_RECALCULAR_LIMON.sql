-- =============================================
-- CORRECCIÓN COMPLETA: Bug en costo 3.991195
-- =============================================
-- Este script:
-- 1. Aplica la corrección en la función USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS_2
-- 2. Recalcula el producto PD00534 (LIMON X KG)
-- 3. Verifica que los costos se corrijan
-- =============================================

USE [ERP_TEST]
GO

SET NOCOUNT ON;

DECLARE
    @Inicio DATETIME = GETDATE(),
    @Fin DATETIME,
    @TiempoTotal INT,
    @P_FECHA_RECALCULO_REAL DATETIME;

PRINT '========================================================================';
PRINT 'CORRECCIÓN BUG COSTO INCORRECTO 3.991195';
PRINT '========================================================================';
PRINT 'Fecha inicio: ' + CONVERT(VARCHAR(20), @Inicio, 120);
PRINT '';
PRINT 'PASO 1: Aplicando corrección en función USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS_2';
PRINT '        (Línea 353: Cambiado < por <= en filtro de fecha)';
PRINT '';

-- Ejecutar el script de la función corregida
:r "d:\nuvol\sp\USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS_2.sql"
GO

PRINT '';
PRINT '✓ Función corregida aplicada';
PRINT '';
PRINT '========================================================================';
PRINT 'PASO 2: Recalculando costos de PD00534 (LIMON X KG)';
PRINT '========================================================================';
PRINT 'Rango: Desde 01-04-2025';
PRINT 'Límite: Hasta 31-05-2025 (configurado en el SP)';
PRINT '';

-- Variables para el recálculo
DECLARE
    @InicioRecalculo DATETIME = GETDATE(),
    @FinRecalculo DATETIME,
    @TiempoRecalculo INT;

-- Ejecutar recálculo
EXEC inventario.USP_COSTO_INVENTARIO_RECALCULAR_4
    @RucE = '20102351038',
    @Cd_Prod_cadena = 'PD00534',              -- LIMON X KG
    @FechaMovimiento = '2025-04-01',
    @P_FECHA_RECALCULO_REAL = @P_FECHA_RECALCULO_REAL OUT,
    @P_USUARIO_RECALCULO = 'PROJECT01',
    @P_FECHA_RECALCULO = GETDATE();

SET @FinRecalculo = GETDATE();
SET @TiempoRecalculo = DATEDIFF(SECOND, @InicioRecalculo, @FinRecalculo);

PRINT '';
PRINT '✓ Recálculo completado';
PRINT '  Tiempo: ' + CAST(@TiempoRecalculo AS VARCHAR(10)) + ' segundos';
PRINT '  Fecha procesada: ' + CONVERT(VARCHAR(20), @P_FECHA_RECALCULO_REAL, 120);
PRINT '';

PRINT '========================================================================';
PRINT 'PASO 3: Verificando corrección de costos';
PRINT '========================================================================';
PRINT '';

-- Verificar los movimientos problemáticos
SELECT
    'Verificación de Corrección' AS Titulo,
    i2.FechaMovimiento,
    ci.Cd_Inv,
    id2.Cd_Alm,
    id2.Cantidad,
    ci.Costo_MN AS CostoActual,
    CASE
        WHEN ABS(ci.Costo_MN - 3.102090) < 0.01 THEN '✓ CORRECTO (3.102)'
        WHEN ABS(ci.Costo_MN - 3.991195) < 0.01 THEN '✗ ERROR (3.991) - PERSISTE EL BUG'
        WHEN ABS(ci.Costo_MN - 2.665417) < 0.01 THEN '✓ CORRECTO (2.665)'
        ELSE '? OTRO COSTO: ' + CAST(ci.Costo_MN AS VARCHAR(20))
    END AS Estado
FROM
    CostoInventario ci
    INNER JOIN InventarioDet2 id2 ON id2.RucE = ci.RucE AND id2.Cd_Inv = ci.Cd_Inv AND id2.Item = ci.Item
    INNER JOIN Inventario2 i2 ON i2.RucE = id2.RucE AND i2.Cd_Inv = id2.Cd_Inv
WHERE
    ci.RucE = '20102351038'
    AND ci.Cd_Inv IN ('INV000297367', 'INV000297372')
    AND id2.IC_ES = 'S'
ORDER BY
    i2.FechaMovimiento;

PRINT '';
PRINT '========================================================================';
PRINT 'RESULTADO ESPERADO:';
PRINT '========================================================================';
PRINT 'INV000297367 (29-04 08:05): ✓ CORRECTO (3.102)';
PRINT 'INV000297372 (29-04 08:50): ✓ CORRECTO (2.665) o (3.102)';
PRINT '';
PRINT 'Si muestra "ERROR (3.991)", significa que el bug persiste.';
PRINT 'Posibles causas:';
PRINT '  - La función no se actualizó en la BD';
PRINT '  - Hay otra función/SP que sobrescribe el costo';
PRINT '  - El valor está cacheado en alguna tabla temporal';
PRINT '';

SET @Fin = GETDATE();
SET @TiempoTotal = DATEDIFF(SECOND, @Inicio, @Fin);

PRINT '========================================================================';
PRINT 'PROCESO COMPLETADO';
PRINT '========================================================================';
PRINT 'Tiempo total: ' + CAST(@TiempoTotal AS VARCHAR(10)) + ' segundos';
PRINT 'Fecha fin: ' + CONVERT(VARCHAR(20), @Fin, 120);
PRINT '';
