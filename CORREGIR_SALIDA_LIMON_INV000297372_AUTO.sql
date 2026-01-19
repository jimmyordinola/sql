-- =====================================================
-- SCRIPT PARA CORREGIR SALIDA EXCESIVA DE LIMON
-- Documento: INV000297372
-- Producto: PD00534 (LIMON X KG)
-- Problema: Se registró salida de 22.400 kg cuando solo había 22.397 kg
-- VERSIÓN: COMMIT AUTOMÁTICO
-- =====================================================

USE [ERP_TEST]
GO

-- Iniciar transacción
BEGIN TRANSACTION

BEGIN TRY
    -- =====================================================
    -- PASO 1: VERIFICAR LOS VALORES ACTUALES
    -- =====================================================
    PRINT '======================================================'
    PRINT 'VALORES ACTUALES ANTES DE LA CORRECCIÓN'
    PRINT '======================================================'
    PRINT ''

    -- Verificar InventarioDet2
    PRINT 'InventarioDet2:'
    SELECT
        Cd_Inv,
        Cd_Prod,
        Cantidad AS Cantidad_Actual,
        22.397 AS Cantidad_Correcta
    FROM InventarioDet2
    WHERE Cd_Inv = 'INV000297372'
      AND Cd_Prod = 'PD00534'

    -- Verificar CostoInventario
    PRINT ''
    PRINT 'CostoInventario:'
    SELECT
        Cd_Inv,
        Item,
        Cantidad AS Cantidad_Actual,
        22.397 AS Cantidad_Correcta,
        IC_TipoCostoInventario
    FROM CostoInventario
    WHERE Cd_Inv = 'INV000297372'
      AND Item = 2
      AND IC_TipoCostoInventario = 'M'

    PRINT ''
    PRINT '======================================================'

    -- =====================================================
    -- PASO 2: REALIZAR LAS CORRECCIONES
    -- =====================================================
    DECLARE @RowsAffected1 INT = 0
    DECLARE @RowsAffected2 INT = 0

    -- Actualizar InventarioDet2
    UPDATE InventarioDet2
    SET Cantidad = 22.397
    WHERE Cd_Inv = 'INV000297372'
      AND Cd_Prod = 'PD00534'

    SET @RowsAffected1 = @@ROWCOUNT

    -- Actualizar CostoInventario
    UPDATE CostoInventario
    SET Cantidad = 22.397
    WHERE Cd_Inv = 'INV000297372'
      AND Item = 2
      AND IC_TipoCostoInventario = 'M'

    SET @RowsAffected2 = @@ROWCOUNT

    -- =====================================================
    -- PASO 3: VERIFICAR QUE SE ACTUALIZARON LOS REGISTROS
    -- =====================================================
    PRINT ''
    PRINT '======================================================'
    PRINT 'VERIFICACIÓN DE ACTUALIZACIÓN'
    PRINT '======================================================'
    PRINT 'Registros actualizados en InventarioDet2: ' + CAST(@RowsAffected1 AS VARCHAR(10))
    PRINT 'Registros actualizados en CostoInventario: ' + CAST(@RowsAffected2 AS VARCHAR(10))
    PRINT ''

    -- Validar que se actualizó exactamente 1 registro en cada tabla
    IF @RowsAffected1 != 1
    BEGIN
        RAISERROR('ERROR: Se esperaba actualizar 1 registro en InventarioDet2, pero se actualizaron %d', 16, 1, @RowsAffected1)
    END

    IF @RowsAffected2 != 1
    BEGIN
        RAISERROR('ERROR: Se esperaba actualizar 1 registro en CostoInventario, pero se actualizaron %d', 16, 1, @RowsAffected2)
    END

    -- =====================================================
    -- PASO 4: MOSTRAR VALORES FINALES
    -- =====================================================
    PRINT ''
    PRINT '======================================================'
    PRINT 'VALORES FINALES DESPUÉS DE LA CORRECCIÓN'
    PRINT '======================================================'
    PRINT ''

    -- Verificar InventarioDet2
    PRINT 'InventarioDet2:'
    SELECT
        Cd_Inv,
        Cd_Prod,
        Cantidad AS Cantidad_Corregida
    FROM InventarioDet2
    WHERE Cd_Inv = 'INV000297372'
      AND Cd_Prod = 'PD00534'

    -- Verificar CostoInventario
    PRINT ''
    PRINT 'CostoInventario:'
    SELECT
        Cd_Inv,
        Item,
        Cantidad AS Cantidad_Corregida,
        IC_TipoCostoInventario
    FROM CostoInventario
    WHERE Cd_Inv = 'INV000297372'
      AND Item = 2
      AND IC_TipoCostoInventario = 'M'

    -- =====================================================
    -- HACER COMMIT AUTOMÁTICAMENTE
    -- =====================================================
    COMMIT TRANSACTION

    PRINT ''
    PRINT '======================================================'
    PRINT 'TRANSACCIÓN CONFIRMADA CON ÉXITO'
    PRINT '======================================================'
    PRINT 'Los cambios han sido guardados permanentemente.'
    PRINT ''

END TRY
BEGIN CATCH
    -- Si hay algún error, hacer ROLLBACK automáticamente
    PRINT ''
    PRINT '======================================================'
    PRINT 'ERROR DETECTADO - HACIENDO ROLLBACK AUTOMÁTICO'
    PRINT '======================================================'
    PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR(10))
    PRINT 'Error Message: ' + ERROR_MESSAGE()
    PRINT ''

    ROLLBACK TRANSACTION
    PRINT 'TRANSACCIÓN CANCELADA - No se realizaron cambios'
    PRINT ''
END CATCH

GO
