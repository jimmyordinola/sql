/****** Object:  StoredProcedure [dbo].[SP_ActualizaPrecioPromedioOptimizado]    Script Date: 20/01/2026 23:11:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER     PROCEDURE [dbo].[SP_ActualizaPrecioPromedioOptimizado]
    @IdArticulo INT=8954,
    @FechaInicio DATETIME='2025-06-01 00:00:00.000',
    @FechaFin DATETIME='2025-07-01 00:00:00.000',
    @TipoActualizacion VARCHAR(10) = 'NORMAL' -- 'NORMAL' o 'MONEDA'
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validar parámetro
    IF @TipoActualizacion NOT IN ('NORMAL', 'MONEDA')
    BEGIN
        RAISERROR('Tipo de actualización debe ser NORMAL o MONEDA', 16, 1);
        RETURN;
    END
    
    -- Variables para el cursor
    DECLARE @IdCuerpoMovimiento INT, @Cantidad FLOAT, @PrecioUnitario FLOAT;
    DECLARE @IdSucursal INT, @IdDeposito INT, @FechaContable DATETIME, @CotizacionCompra FLOAT;
    DECLARE @Saldo FLOAT, @UltimoSaldo FLOAT, @UltimoPromedio FLOAT, @NuevoPromedio FLOAT;
    DECLARE @FilasActualizadas INT = 0;
    
    -- PRE-CALCULAR MovimientosBase UNA SOLA VEZ (esto mejora mucho la performance)
    SELECT
        cuerpo.IdCuerpoMovimiento,
        cuerpo.Cantidad,
        cuerpo.PrecioUnitario,
        mov.IdSucursal,
        cuerpo.IdDeposito,
        mov.FechaContable,
        cuerpo.IdArticulo,
        -- Determinar el signo de la cantidad según el tipo de comprobante
        CASE 
            WHEN (compventa.idtipocomprobanteventa IS NOT NULL AND FuncionalidadComprobante.Nombre IN ('CR','NC'))
                OR (compcompra.idtipocomprobantecompra IS NOT NULL AND FuncionalidadComprobante.Nombre IN ('DE','ND'))
            THEN cuerpo.cantidad 
            WHEN (compcompra.idtipocomprobantecompra IS NOT NULL AND FuncionalidadComprobante.Nombre IN ('CR','NC'))
                OR (compventa.idtipocomprobanteventa IS NOT NULL AND FuncionalidadComprobante.Nombre IN ('DE','ND'))
            THEN cuerpo.cantidad * (-1)
            ELSE 0
        END AS CantidadConSigno
    INTO #MovimientosBase
    FROM 
        articulo ar 
        INNER JOIN vistareportescuerposmovimientos cuerpo ON cuerpo.idarticulo = ar.idarticulo
        INNER JOIN movimiento mov ON mov.idmovimiento = cuerpo.idmovimiento
        INNER JOIN deposito dep ON cuerpo.iddeposito = dep.iddeposito
        INNER JOIN comprobante comp ON comp.idcomprobante = mov.idcomprobante
        LEFT JOIN tipocomprobantecompra compcompra ON compcompra.idtipocomprobantecompra = comp.idcomprobante
        LEFT JOIN tipocomprobanteventa compventa ON compventa.idtipocomprobanteventa = comp.idcomprobante
        INNER JOIN Vista_FuncionalidadComprobanteTranspuesta vfct ON vfct.idcomprobante = mov.idcomprobante
        INNER JOIN FuncionalidadComprobante ON comp.IdFuncionalidadComprobante = FuncionalidadComprobante.IdFuncionalidadComprobante
    WHERE
        mov.estado <> 'ANU'
        AND cuerpo.AfectaStock = 1
        AND ((vfct.AfectaStock = 'SI' AND vfct.ConsiderarPendiente = 'SI' AND vfct.AfectaStockDefinitivo = 'SI' AND vfct.AfectaStockNoDefinitivo = 'NO')
            OR (vfct.AfectaStock = 'SI' AND vfct.ConsiderarPendiente = 'NO' AND vfct.AfectaStockDefinitivo = 'NO' AND vfct.AfectaStockNoDefinitivo = 'NO'))
        AND ar.IdArticulo = @IdArticulo
        AND mov.FechaContable <= @FechaFin;
    
    -- Crear índices en tabla temporal para optimizar las consultas del cursor
    CREATE INDEX IX_MovimientosBase_Sucursal_Deposito_Fecha ON #MovimientosBase (IdSucursal, IdDeposito, FechaContable);
    CREATE INDEX IX_MovimientosBase_CuerpoMov ON #MovimientosBase (IdCuerpoMovimiento);
    
    -- Crear tabla temporal para los movimientos a procesar con cotización si es necesario
    SELECT
        v.IdCuerpoMovimiento,
        v.Cantidad,
        v.PrecioUnitario,
        v.IdSucursal,
        v.IdDeposito,
        v.FechaContable,
        -- Cotización solo para moneda
        CASE 
            WHEN @TipoActualizacion = 'MONEDA' THEN ISNULL(tc.Compra, 1)
            ELSE 1.0
        END AS CotizacionCompra,
        -- PRE-CALCULAR saldos desde MovimientosBase
        (SELECT COALESCE(SUM(mb.CantidadConSigno), 0)
         FROM #MovimientosBase mb
         WHERE mb.IdSucursal = v.IdSucursal 
           AND mb.IdDeposito = v.IdDeposito
           AND mb.FechaContable <= v.FechaContable) AS SaldoSimple,
        (SELECT COALESCE(SUM(mb.CantidadConSigno), 0)
         FROM #MovimientosBase mb
         WHERE mb.IdSucursal = v.IdSucursal 
           AND mb.IdDeposito = v.IdDeposito
           AND mb.FechaContable < v.FechaContable) AS UltimoSaldo
    INTO #MovimientosAProcesar
    FROM Vista_ArticuloMovimientoExistencia v
    LEFT JOIN __DimensionTipoCambio tc ON 
        (@TipoActualizacion = 'MONEDA' AND tc.Fecha = CONVERT(DATE, v.FechaMovimiento))
    WHERE v.IdArticulo = @IdArticulo
      AND v.FechaContable BETWEEN @FechaInicio AND @FechaFin
    ORDER BY v.FechaContable, v.IdCuerpoMovimiento;

        -- Identificar y actualizar en una sola pasada
;WITH Duplicados AS (
    SELECT 
        IdCuerpoMovimiento,
        FechaContable,
        ROW_NUMBER() OVER (PARTITION BY FechaContable ORDER BY IdCuerpoMovimiento) AS Segundos
    FROM #MovimientosAProcesar
    WHERE FechaContable IN (
        SELECT FechaContable FROM #MovimientosAProcesar GROUP BY FechaContable HAVING COUNT(*) > 1
    )
)

UPDATE m
SET m.FechaContable = DATEADD(SECOND, d.Segundos - 1, m.FechaContable)
FROM Movimiento m
INNER JOIN CuerpoMovimiento cm ON cm.IdMovimiento = m.IdMovimiento
INNER JOIN Duplicados d ON d.IdCuerpoMovimiento = cm.IdCuerpoMovimiento
WHERE d.Segundos > 1;  -- Solo actualiza del segundo en adelante
    
    -- Crear índice para el cursor
    CREATE INDEX IX_MovimientosAProcesar_Cursor ON #MovimientosAProcesar (FechaContable, IdCuerpoMovimiento);
    
    -- CURSOR OPTIMIZADO: Solo para obtener último precio promedio secuencialmente
    DECLARE cursor_movimientos CURSOR FAST_FORWARD READ_ONLY FOR
        SELECT 
            IdCuerpoMovimiento, Cantidad, PrecioUnitario, IdSucursal, IdDeposito, 
            FechaContable, CotizacionCompra, SaldoSimple, UltimoSaldo
        FROM #MovimientosAProcesar
        ORDER BY FechaContable, IdCuerpoMovimiento;
    
    OPEN cursor_movimientos;
    FETCH NEXT FROM cursor_movimientos INTO 
        @IdCuerpoMovimiento, @Cantidad, @PrecioUnitario, @IdSucursal, @IdDeposito, 
        @FechaContable, @CotizacionCompra, @Saldo, @UltimoSaldo;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Obtener último precio promedio directamente desde CuerpoMovimiento
        -- (que ya tiene los valores actualizados de iteraciones anteriores)
        -- Buscar último precio promedio GLOBAL del artículo (sin filtrar por depósito)
        -- Esto es correcto porque el costo promedio es por ARTICULO, no por ubicación física
        -- Las transferencias entre depósitos no deben afectar el costo del artículo
        IF @TipoActualizacion = 'MONEDA'
        BEGIN
            SELECT @UltimoPromedio = COALESCE((
                -- Primero buscar en movimientos ya cargados (más rápido)
                SELECT TOP 1 cm.PrecioPromedioMoneda
                FROM #MovimientosBase mb
                INNER JOIN CuerpoMovimiento cm ON cm.IdCuerpoMovimiento = mb.IdCuerpoMovimiento
                WHERE mb.FechaContable < @FechaContable
                  AND cm.PrecioPromedioMoneda IS NOT NULL
                  AND cm.PrecioPromedioMoneda > 0
                ORDER BY mb.FechaContable DESC
            ), (
                -- Si no hay en #MovimientosBase, buscar en histórico completo
                SELECT TOP 1 cm.PrecioPromedioMoneda
                FROM CuerpoMovimiento cm
                INNER JOIN Movimiento mov ON mov.IdMovimiento = cm.IdMovimiento
                WHERE cm.IdArticulo = @IdArticulo
                  AND mov.FechaContable < @FechaContable
                  AND mov.Estado <> 'ANU'
                  AND cm.PrecioPromedioMoneda IS NOT NULL
                  AND cm.PrecioPromedioMoneda > 0
                ORDER BY mov.FechaContable DESC
            ), 0);
        END
        ELSE
        BEGIN
            SELECT @UltimoPromedio = COALESCE((
                -- Primero buscar en movimientos ya cargados (más rápido)
                SELECT TOP 1 cm.PrecioPromedio
                FROM #MovimientosBase mb
                INNER JOIN CuerpoMovimiento cm ON cm.IdCuerpoMovimiento = mb.IdCuerpoMovimiento
                WHERE mb.FechaContable < @FechaContable
                  AND cm.PrecioPromedio IS NOT NULL
                  AND cm.PrecioPromedio > 0
                ORDER BY mb.FechaContable DESC
            ), (
                -- Si no hay en #MovimientosBase, buscar en histórico completo
                SELECT TOP 1 cm.PrecioPromedio
                FROM CuerpoMovimiento cm
                INNER JOIN Movimiento mov ON mov.IdMovimiento = cm.IdMovimiento
                WHERE cm.IdArticulo = @IdArticulo
                  AND mov.FechaContable < @FechaContable
                  AND mov.Estado <> 'ANU'
                  AND cm.PrecioPromedio IS NOT NULL
                  AND cm.PrecioPromedio > 0
                ORDER BY mov.FechaContable DESC
            ), 0);
        END
        
        -- Calcular precio unitario ajustado
        IF @PrecioUnitario = 0 OR @PrecioUnitario IS NULL
            SET @PrecioUnitario = @UltimoPromedio;
        ELSE IF @TipoActualizacion = 'MONEDA'
            SET @PrecioUnitario = @PrecioUnitario / @CotizacionCompra;
        
        -- Calcular nuevo precio promedio
        IF @Saldo = 0
            SET @NuevoPromedio = @UltimoPromedio;
        ELSE
            SET @NuevoPromedio = ((@UltimoSaldo * @UltimoPromedio) + (@Cantidad * @PrecioUnitario)) / @Saldo;
        
        -- Actualizar el campo correspondiente
        IF @TipoActualizacion = 'MONEDA'
            UPDATE CuerpoMovimiento 
            SET PrecioPromedioMoneda = ABS(@NuevoPromedio) 
            WHERE IdCuerpoMovimiento = @IdCuerpoMovimiento;
        ELSE
            UPDATE CuerpoMovimiento 
            SET PrecioPromedio = ABS(@NuevoPromedio) 
            WHERE IdCuerpoMovimiento = @IdCuerpoMovimiento;
        
        SET @FilasActualizadas = @FilasActualizadas + 1;
        
        FETCH NEXT FROM cursor_movimientos INTO 
            @IdCuerpoMovimiento, @Cantidad, @PrecioUnitario, @IdSucursal, @IdDeposito, 
            @FechaContable, @CotizacionCompra, @Saldo, @UltimoSaldo;
    END
    
    CLOSE cursor_movimientos;
    DEALLOCATE cursor_movimientos;
    
    -- Limpiar tablas temporales
    DROP TABLE #MovimientosBase;
    DROP TABLE #MovimientosAProcesar;
    
    -- Retornar estadísticas
    --SELECT 
    --    @FilasActualizadas AS FilasActualizadas,
    --    @IdArticulo AS IdArticulo,
    --    @FechaInicio AS FechaInicio,
    --    @FechaFin AS FechaFin,
    --    @TipoActualizacion AS TipoActualizacion;
END