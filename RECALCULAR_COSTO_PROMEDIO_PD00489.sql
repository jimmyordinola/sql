-- =====================================================
-- SCRIPT DE RECÁLCULO DE COSTO PROMEDIO PONDERADO
-- Producto: PD00489
-- Método: Costo Promedio Ponderado
-- =====================================================

USE [ERP_TEST]
GO

-- Parámetros
DECLARE @RucE VARCHAR(20) = '20102351038'
DECLARE @Cd_Prod VARCHAR(20) = 'PD00489'

-- Tabla temporal para almacenar todos los movimientos ordenados
IF OBJECT_ID('tempdb..#Movimientos') IS NOT NULL DROP TABLE #Movimientos
IF OBJECT_ID('tempdb..#Correcciones') IS NOT NULL DROP TABLE #Correcciones

CREATE TABLE #Movimientos (
    ID INT IDENTITY(1,1),
    Cd_Inv VARCHAR(20),
    Item INT,
    IC_ES CHAR(1),
    Cantidad DECIMAL(38,20),
    Costo_MN DECIMAL(38,20),
    FechaMovimiento DATETIME,
    OrdenProceso INT  -- 1=Entrada, 2=Salida (para ordenar dentro del mismo timestamp)
)

CREATE TABLE #Correcciones (
    Cd_Inv VARCHAR(20),
    Item INT,
    Costo_Actual DECIMAL(38,20),
    Costo_Correcto DECIMAL(38,20),
    Cantidad DECIMAL(38,20),
    FechaMovimiento DATETIME
)

-- Insertar todos los movimientos
-- IMPORTANTE: Ordenamos por Fecha, y dentro de la misma fecha, ENTRADAS antes que SALIDAS
INSERT INTO #Movimientos (Cd_Inv, Item, IC_ES, Cantidad, Costo_MN, FechaMovimiento, OrdenProceso)
SELECT
    ci.Cd_Inv,
    ci.Item,
    id.IC_ES,
    ci.Cantidad,
    ci.Costo_MN,
    i.FechaMovimiento,
    CASE WHEN id.IC_ES = 'E' THEN 1 ELSE 2 END as OrdenProceso
FROM CostoInventario ci
INNER JOIN InventarioDet2 id ON ci.RucE = id.RucE AND ci.Cd_Inv = id.Cd_Inv AND ci.Item = id.Item
INNER JOIN Inventario2 i ON ci.RucE = i.RucE AND ci.Cd_Inv = i.Cd_Inv
WHERE ci.RucE = @RucE
  AND id.Cd_Prod = @Cd_Prod
  AND ci.IC_TipoCostoInventario = 'M'
ORDER BY i.FechaMovimiento, CASE WHEN id.IC_ES = 'E' THEN 1 ELSE 2 END, ci.Cd_Inv, ci.Item

-- Variables para el cálculo del costo promedio
DECLARE @SaldoCantidad DECIMAL(38,20) = 0
DECLARE @SaldoTotal DECIMAL(38,20) = 0
DECLARE @CostoPromedio DECIMAL(38,20) = 0

-- Variables para el cursor
DECLARE @ID INT
DECLARE @Cd_Inv VARCHAR(20)
DECLARE @Item INT
DECLARE @IC_ES CHAR(1)
DECLARE @Cantidad DECIMAL(38,20)
DECLARE @Costo_MN DECIMAL(38,20)
DECLARE @FechaMovimiento DATETIME
DECLARE @CostoCorrecto DECIMAL(38,20)
DECLARE @Diferencia DECIMAL(38,20)

-- Cursor para procesar movimientos en orden
DECLARE cur_movimientos CURSOR FOR
SELECT ID, Cd_Inv, Item, IC_ES, Cantidad, Costo_MN, FechaMovimiento
FROM #Movimientos
ORDER BY FechaMovimiento, OrdenProceso, Cd_Inv, Item

OPEN cur_movimientos
FETCH NEXT FROM cur_movimientos INTO @ID, @Cd_Inv, @Item, @IC_ES, @Cantidad, @Costo_MN, @FechaMovimiento

WHILE @@FETCH_STATUS = 0
BEGIN
    IF @IC_ES = 'E'
    BEGIN
        -- ENTRADA: Actualizar saldo con el costo de la entrada
        SET @SaldoTotal = @SaldoTotal + (@Cantidad * @Costo_MN)
        SET @SaldoCantidad = @SaldoCantidad + @Cantidad

        -- Recalcular costo promedio
        IF @SaldoCantidad > 0
            SET @CostoPromedio = @SaldoTotal / @SaldoCantidad
        ELSE
            SET @CostoPromedio = 0
    END
    ELSE
    BEGIN
        -- SALIDA: El costo correcto es el costo promedio ANTES de la salida
        IF @SaldoCantidad > 0
            SET @CostoCorrecto = @SaldoTotal / @SaldoCantidad
        ELSE
            SET @CostoCorrecto = 0

        -- Verificar si hay diferencia significativa
        SET @Diferencia = ABS(@Costo_MN - @CostoCorrecto)

        IF @Diferencia > 0.01
        BEGIN
            -- Registrar corrección necesaria
            INSERT INTO #Correcciones (Cd_Inv, Item, Costo_Actual, Costo_Correcto, Cantidad, FechaMovimiento)
            VALUES (@Cd_Inv, @Item, @Costo_MN, @CostoCorrecto, @Cantidad, @FechaMovimiento)
        END

        -- Actualizar saldo DESPUÉS de la salida (usando el costo promedio correcto)
        SET @SaldoTotal = @SaldoTotal - (@Cantidad * @CostoCorrecto)
        SET @SaldoCantidad = @SaldoCantidad - @Cantidad

        -- Evitar saldos negativos por redondeo
        IF @SaldoCantidad < 0.0001
        BEGIN
            SET @SaldoCantidad = 0
            SET @SaldoTotal = 0
        END
    END

    FETCH NEXT FROM cur_movimientos INTO @ID, @Cd_Inv, @Item, @IC_ES, @Cantidad, @Costo_MN, @FechaMovimiento
END

CLOSE cur_movimientos
DEALLOCATE cur_movimientos

-- =====================================================
-- MOSTRAR RESULTADOS
-- =====================================================
DECLARE @TotalCorrecciones INT
SELECT @TotalCorrecciones = COUNT(*) FROM #Correcciones

PRINT '====================================================================='
PRINT 'CORRECCIONES NECESARIAS PARA PRODUCTO: ' + @Cd_Prod
PRINT '====================================================================='
PRINT ''

SELECT
    Cd_Inv,
    Item,
    Cantidad,
    Costo_Actual,
    Costo_Correcto,
    Costo_Actual - Costo_Correcto as Diferencia,
    FechaMovimiento
FROM #Correcciones
ORDER BY FechaMovimiento

PRINT ''
PRINT 'Total de registros a corregir: ' + CAST(@TotalCorrecciones AS VARCHAR(10))
PRINT ''

-- =====================================================
-- EJECUTAR ACTUALIZACIONES CON TRANSACCIÓN
-- =====================================================
PRINT '====================================================================='
PRINT 'EJECUTANDO ACTUALIZACIONES...'
PRINT '====================================================================='
PRINT ''

-- Iniciar transacción
BEGIN TRANSACTION

DECLARE @RegistrosActualizados INT = 0
DECLARE @ErrorOcurrido BIT = 0

-- Cursor para ejecutar cada UPDATE
DECLARE @Cd_Inv_Update VARCHAR(20)
DECLARE @Item_Update INT
DECLARE @CostoActual_Update DECIMAL(38,20)
DECLARE @CostoCorrecto_Update DECIMAL(38,20)
DECLARE @Cantidad_Update DECIMAL(38,20)
DECLARE @FechaMovimiento_Update DATETIME

DECLARE cur_updates CURSOR FOR
SELECT Cd_Inv, Item, Costo_Actual, Costo_Correcto, Cantidad, FechaMovimiento
FROM #Correcciones
ORDER BY FechaMovimiento

OPEN cur_updates
FETCH NEXT FROM cur_updates INTO @Cd_Inv_Update, @Item_Update, @CostoActual_Update, @CostoCorrecto_Update, @Cantidad_Update, @FechaMovimiento_Update

WHILE @@FETCH_STATUS = 0
BEGIN
    BEGIN TRY
        -- Mostrar información del UPDATE
        PRINT '-- ' + CONVERT(VARCHAR(20), @FechaMovimiento_Update, 120) + ' | Cant: ' + CAST(CAST(@Cantidad_Update AS DECIMAL(18,2)) AS VARCHAR(20)) +
              ' | Actual: ' + CAST(CAST(@CostoActual_Update AS DECIMAL(18,5)) AS VARCHAR(25)) +
              ' -> Correcto: ' + CAST(CAST(@CostoCorrecto_Update AS DECIMAL(18,5)) AS VARCHAR(25))

        -- Ejecutar UPDATE
        UPDATE CostoInventario
        SET Costo_MN = @CostoCorrecto_Update
        WHERE RucE = @RucE
          AND Cd_Inv = @Cd_Inv_Update
          AND Item = @Item_Update
          AND IC_TipoCostoInventario = 'M'

        SET @RegistrosActualizados = @RegistrosActualizados + @@ROWCOUNT

    END TRY
    BEGIN CATCH
        PRINT 'ERROR al actualizar Cd_Inv: ' + @Cd_Inv_Update + ', Item: ' + CAST(@Item_Update AS VARCHAR(10))
        PRINT 'Mensaje: ' + ERROR_MESSAGE()
        SET @ErrorOcurrido = 1
        BREAK  -- Salir del cursor si hay error
    END CATCH

    FETCH NEXT FROM cur_updates INTO @Cd_Inv_Update, @Item_Update, @CostoActual_Update, @CostoCorrecto_Update, @Cantidad_Update, @FechaMovimiento_Update
END

CLOSE cur_updates
DEALLOCATE cur_updates

-- Verificar si hubo errores
IF @ErrorOcurrido = 1
BEGIN
    PRINT ''
    PRINT '====================================================================='
    PRINT 'ERROR: Se ha producido un error. Haciendo ROLLBACK...'
    PRINT '====================================================================='
    ROLLBACK TRANSACTION
END
ELSE
BEGIN
    PRINT ''
    PRINT '====================================================================='
    PRINT 'ÉXITO: ' + CAST(@RegistrosActualizados AS VARCHAR(10)) + ' registros actualizados correctamente'
    PRINT 'Correcciones esperadas: ' + CAST(@TotalCorrecciones AS VARCHAR(10))
    PRINT '====================================================================='
    PRINT ''

    -- Verificar que los números coincidan
    IF @RegistrosActualizados = @TotalCorrecciones
    BEGIN
        PRINT 'Haciendo COMMIT de la transacción...'
        COMMIT TRANSACTION
        PRINT 'TRANSACCIÓN COMPLETADA CON ÉXITO'
    END
    ELSE
    BEGIN
        PRINT 'ADVERTENCIA: Número de registros actualizados no coincide con correcciones esperadas'
        PRINT 'Haciendo ROLLBACK por precaución...'
        ROLLBACK TRANSACTION
    END
END

PRINT ''
PRINT '====================================================================='

-- Limpiar
DROP TABLE #Movimientos
DROP TABLE #Correcciones
