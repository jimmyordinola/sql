# ANÁLISIS DE PROCEDIMIENTOS ALMACENADOS - OPTIMIZACIÓN

## Resumen de Rendimiento (SQL Profile)

| SP | Duration (ms) | Reads | CPU | Estado |
|----|---------------|-------|-----|--------|
| USP_T_ORDEN_PEDIDO_INSERTAR_VALE_VERSION_21 | 1,351 | 11,925 | 1,344 | CRÍTICO |
| USP_T_ORDEN_PEDIDO_MOVIMIENTOS_DETALLE_LISTAR | 285 | 5,734 | 281 | ALTO |
| USP_T_CLIENTE_SELECCIONAR_NRO_NOMBRE_CLIENTE_POR_TIPO_DOCUMENTO_07 | 177 | 1,206 | 172 | MEDIO |

---

## 1. USP_T_ORDEN_PEDIDO_INSERTAR_VALE_VERSION_21

**Problema Principal:** 11,925 lecturas para un INSERT es excesivo.

### Problemas Identificados:

#### Línea 104 - EXISTS con SELECT en vista
```sql
EXISTS(SELECT TOP(1)C_CODIGO_ORDENPEDIDO FROM SPV.VW_T_ORDEN_PEDIDO
       WHERE C_RUC_EMPRESA = @P_RUC_EMPRESA
       AND C_CODIGO_FORMA_PAGO = @P_CODIGO_FORMA_PAGO
       AND COALESCE(C_CAMPO_02,'') = @P_CAMPO_02)
```
**Problema:**
- Usa una VISTA que puede tener JOINs internos costosos
- `COALESCE(C_CAMPO_02,'')` impide uso de índice

**Solución:**
```sql
EXISTS(SELECT 1 FROM SPV.VW_T_ORDEN_PEDIDO
       WHERE C_RUC_EMPRESA = @P_RUC_EMPRESA
       AND C_CODIGO_FORMA_PAGO = @P_CODIGO_FORMA_PAGO
       AND C_CAMPO_02 = @P_CAMPO_02
       AND C_CAMPO_02 IS NOT NULL)
```

#### Línea 122 - SELECT TOP(1) con MAX innecesario
```sql
SELECT TOP(1) @P_ID_MOVIMIENTO_CAJA = MAX(C_ID_MOVIMIENTO_CAJA)
FROM SPV.T_MOVIMIENTO_CAJA
WHERE C_CODIGO_EMPRESA = @P_RUC_EMPRESA
AND C_CODIGO_LOCALIDAD = @P_CODIGO_LOCALIDAD
AND C_CODIGO_CAJA = @P_CODIGO_CAJA
AND C_ESTADO = 0
```
**Problema:** `TOP(1)` con `MAX()` es redundante.

**Solución:**
```sql
SELECT @P_ID_MOVIMIENTO_CAJA = MAX(C_ID_MOVIMIENTO_CAJA)
FROM SPV.T_MOVIMIENTO_CAJA
WHERE C_CODIGO_EMPRESA = @P_RUC_EMPRESA
AND C_CODIGO_LOCALIDAD = @P_CODIGO_LOCALIDAD
AND C_CODIGO_CAJA = @P_CODIGO_CAJA
AND C_ESTADO = 0
```

#### Línea 137 - CONCAT con subconsulta costosa
```sql
SET @P_DOCUMENTO_INTERNO = (SELECT CONCAT(@P_DOCUMENTO_INTERNO,'-',
    ISNULL(MAX(CONVERT(INT,SUBSTRING(C_DOCUMENTO_INTERNO,4,LEN(C_DOCUMENTO_INTERNO)))),0) + 1)
FROM DBO.ORDPEDIDO
WHERE RUCE = @P_RUC_EMPRESA
AND (C_DOCUMENTO_INTERNO LIKE 'VA-%' OR C_DOCUMENTO_INTERNO LIKE 'CA-%' OR C_DOCUMENTO_INTERNO LIKE 'OP-%')
AND SUBSTRING(C_DOCUMENTO_INTERNO,1,2) = @P_DOCUMENTO_INTERNO)
```
**Problemas:**
- `LIKE 'VA-%'` hace scan
- `SUBSTRING()` en WHERE impide uso de índices
- Múltiples OR con LIKE

**Solución:** Crear columna calculada indexada o tabla de secuencias.

#### Línea 323 - CONVERT(DATE,...) en WHERE
```sql
SET @P_TURNO = (SELECT COUNT(C_ID_MOVIMIENTO_CAJA)
FROM SPV.T_MOVIMIENTO_CAJA
WHERE ISNULL(C_ID_MOVIMIENTO_CAJA,0) <= @P_ID_MOVIMIENTO_CAJA
AND CONVERT(DATE,C_FECHA_MOVIMIENTO) = CONVERT(DATE,@P_FECHA_EMISION))
```
**Problema:** `CONVERT(DATE,...)` impide uso de índice.

**Solución:**
```sql
AND C_FECHA_MOVIMIENTO >= CAST(@P_FECHA_EMISION AS DATE)
AND C_FECHA_MOVIMIENTO < DATEADD(DAY, 1, CAST(@P_FECHA_EMISION AS DATE))
```

### Índices Recomendados:
```sql
-- Para validación de duplicados
CREATE NONCLUSTERED INDEX IX_VW_OP_FormaPago_Campo02
ON SPV.T_ORDEN_PEDIDO(C_RUC_EMPRESA, C_CODIGO_FORMA_PAGO, C_CAMPO_02)
WHERE C_CAMPO_02 IS NOT NULL;

-- Para movimiento de caja
CREATE NONCLUSTERED INDEX IX_MovCaja_Empresa_Local_Caja
ON SPV.T_MOVIMIENTO_CAJA(C_CODIGO_EMPRESA, C_CODIGO_LOCALIDAD, C_CODIGO_CAJA, C_ESTADO)
INCLUDE (C_ID_MOVIMIENTO_CAJA);

-- Para secuencia de documentos
CREATE NONCLUSTERED INDEX IX_OrdPedido_DocInterno
ON DBO.ORDPEDIDO(RUCE, C_DOCUMENTO_INTERNO)
WHERE C_DOCUMENTO_INTERNO LIKE '[VC][AO]-%';
```

---

## 2. USP_T_ORDEN_PEDIDO_MOVIMIENTOS_DETALLE_LISTAR

**Problema Principal:** 5,734 lecturas para un SELECT simple.

### Problemas Identificados:

#### Líneas 45-48 - LEFT JOINs no utilizados
```sql
LEFT JOIN DBO.GUIAREMISION gr ON gr.RUCE=mv.RUCE AND gr.CD_GR=mv.CD_GR_DESTINO
LEFT JOIN DBO.VENTA vt ON vt.RUCE=mv.RUCE AND vt.CD_VTA=mv.CD_VTA_DESTINO
```
**Problema:** Se hacen JOINs pero no se usan columnas de `gr` ni `vt`.

**Solución:** Eliminar estos JOINs innecesarios.

#### Línea 51 - OR en WHERE
```sql
WHERE mv.RUCE=@P_RUC_EMPRESA
AND (mv.Cd_OP_DESTINO=@P_CODIGO_ORDEN_PEDIDO OR mv.CD_OP_ORIGEN=@P_CODIGO_ORDEN_PEDIDO)
```
**Problema:** El `OR` impide uso eficiente de índices.

**Solución:** Usar UNION ALL:
```sql
SELECT ... FROM MOVIMIENTOSDETALLEVENTA mv
WHERE mv.RUCE=@P_RUC_EMPRESA AND mv.Cd_OP_DESTINO=@P_CODIGO_ORDEN_PEDIDO
UNION ALL
SELECT ... FROM MOVIMIENTOSDETALLEVENTA mv
WHERE mv.RUCE=@P_RUC_EMPRESA AND mv.CD_OP_ORIGEN=@P_CODIGO_ORDEN_PEDIDO
AND mv.Cd_OP_DESTINO <> @P_CODIGO_ORDEN_PEDIDO -- evitar duplicados
```

#### Falta SET NOCOUNT ON
```sql
AS
-- Falta: SET NOCOUNT ON
SELECT ...
```

### SP Optimizado:
```sql
ALTER PROC [SPV].[USP_T_ORDEN_PEDIDO_MOVIMIENTOS_DETALLE_LISTAR]
    @P_RUC_EMPRESA NVARCHAR(11),
    @P_CODIGO_ORDEN_PEDIDO CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
         mv.CD_OP_ORIGEN As Codigo_OrdenPedido_Origen
        ,mv.ITEM_OP_ORIGEN As Item_OrdenPedido_Origen
        ,mv.CD_OP_DESTINO As Codigo_OrdenPedido_Destino
        ,mv.ITEM_OP_DESTINO As Item_OrdenPedido_Destino
        ,mv.CD_GR_DESTINO As Codigo_GuiaRemision_Destino
        ,mv.ITEM_GR_DESTINO As Item_GuiaRemision_Destino
        ,mv.CD_VTA_DESTINO As Codigo_Venta_Destino
        ,mv.NRO_REGVDT_DESTINO As Numero_Reg_Venta_Destino
        ,mv.CantidadTotalDocumentoItem As Cantidad_Total_Item
        ,mv.CANTIDADUSADA As Cantidad_Usada
        ,mv.CANTIDADSALDO As Cantidad_Saldo
        ,op.FecE As Fecha_Emision
        ,op.C_DOCUMENTO_INTERNO As Documento
        ,op.C_DOCUMENTO_INTERNO As Serie_Destino
        ,op.C_DOCUMENTO_INTERNO As Numero_Destino
        ,op.BIM_Neto As Total_Valor_Neto
        ,op.IGV AS Total_Igv
        ,op.TOTAL As Total_Venta
        ,op.CD_MDA As Codigo_Moneda
        ,op_mn.Simbolo AS Simbolo_Moneda
        ,op.CamMda As Tipo_Cambio
    FROM MOVIMIENTOSDETALLEVENTA mv
    INNER JOIN DBO.ORDPEDIDO op ON op.RUCE=mv.RUCE AND op.CD_OP=mv.CD_OP_DESTINO
    LEFT JOIN DBO.MONEDA op_mn ON op_mn.CD_MDA=op.CD_MDA
    WHERE mv.RUCE=@P_RUC_EMPRESA
      AND mv.Cd_OP_DESTINO=@P_CODIGO_ORDEN_PEDIDO

    UNION ALL

    SELECT
         mv.CD_OP_ORIGEN
        ,mv.ITEM_OP_ORIGEN
        ,mv.CD_OP_DESTINO
        ,mv.ITEM_OP_DESTINO
        ,mv.CD_GR_DESTINO
        ,mv.ITEM_GR_DESTINO
        ,mv.CD_VTA_DESTINO
        ,mv.NRO_REGVDT_DESTINO
        ,mv.CantidadTotalDocumentoItem
        ,mv.CANTIDADUSADA
        ,mv.CANTIDADSALDO
        ,op.FecE
        ,op.C_DOCUMENTO_INTERNO
        ,op.C_DOCUMENTO_INTERNO
        ,op.C_DOCUMENTO_INTERNO
        ,op.BIM_Neto
        ,op.IGV
        ,op.TOTAL
        ,op.CD_MDA
        ,op_mn.Simbolo
        ,op.CamMda
    FROM MOVIMIENTOSDETALLEVENTA mv
    INNER JOIN DBO.ORDPEDIDO op ON op.RUCE=mv.RUCE AND op.CD_OP=mv.CD_OP_DESTINO
    LEFT JOIN DBO.MONEDA op_mn ON op_mn.CD_MDA=op.CD_MDA
    WHERE mv.RUCE=@P_RUC_EMPRESA
      AND mv.CD_OP_ORIGEN=@P_CODIGO_ORDEN_PEDIDO
      AND mv.Cd_OP_DESTINO <> @P_CODIGO_ORDEN_PEDIDO
END
```

### Índices Recomendados:
```sql
CREATE NONCLUSTERED INDEX IX_MovDetVenta_RucE_OpDestino
ON MOVIMIENTOSDETALLEVENTA(RUCE, Cd_OP_DESTINO)
INCLUDE (CD_OP_ORIGEN, ITEM_OP_ORIGEN, ITEM_OP_DESTINO, CD_GR_DESTINO,
         ITEM_GR_DESTINO, CD_VTA_DESTINO, NRO_REGVDT_DESTINO,
         CantidadTotalDocumentoItem, CANTIDADUSADA, CANTIDADSALDO);

CREATE NONCLUSTERED INDEX IX_MovDetVenta_RucE_OpOrigen
ON MOVIMIENTOSDETALLEVENTA(RUCE, CD_OP_ORIGEN);
```

---

## 3. USP_T_CLIENTE_SELECCIONAR_NRO_NOMBRE_CLIENTE_POR_TIPO_DOCUMENTO_07

**Problema Principal:** 1,206 lecturas con múltiples condiciones no-SARGABLES.

### Problemas Identificados:

#### Línea 91 - COALESCE en ambos lados
```sql
AND COALESCE(VXC.CD_VDR,'') = CASE WHEN COALESCE(@P_CODIGO_VENDEDOR,'') = ''
    THEN COALESCE(VXC.CD_VDR,'') ELSE @P_CODIGO_VENDEDOR END
```
**Problema:** No usa índice.

**Solución:**
```sql
AND (@P_CODIGO_VENDEDOR IS NULL OR @P_CODIGO_VENDEDOR = '' OR VXC.CD_VDR = @P_CODIGO_VENDEDOR)
```

#### Línea 92 - ISNULL en columna
```sql
AND ISNULL(C.ESTADO,0) = 1
```
**Solución:**
```sql
AND C.ESTADO = 1
```

#### Línea 93 - CHARINDEX para búsqueda
```sql
AND CHARINDEX(C.Cd_TDI,@L_TIPO_DOC_IDENTIDAD) > 0
```
**Problema:** No usa índice.

**Solución:** Usar tabla temporal o IN:
```sql
AND C.Cd_TDI IN (SELECT value FROM STRING_SPLIT(@L_TIPO_DOC_IDENTIDAD, ','))
```

#### Líneas 94-97 - CASE WHEN múltiples en WHERE
```sql
AND (CASE WHEN ISNULL(C.Cd_Clt,'')<>'' THEN C.Cd_Clt ELSE '--' END=@P_VALOR_FILTRO
    or CASE WHEN ISNULL(C.NDoc,'')<>'' THEN C.NDoc ELSE '--' END=@P_VALOR_FILTRO
    or CASE WHEN ISNULL(C.RSocial,'')<>'' THEN ISNULL(C.RSocial,'') ELSE '--' END=@P_VALOR_FILTRO
    or CASE WHEN ISNULL(C.Nom,'')+ISNULL(C.ApPat,'')+ISNULL(C.ApMat,'')<>'' ...
```
**Problema:** Múltiples OR con CASE impiden cualquier uso de índice.

**Solución:**
```sql
AND (
    C.Cd_Clt = @P_VALOR_FILTRO
    OR C.NDoc = @P_VALOR_FILTRO
    OR C.RSocial = @P_VALOR_FILTRO
    OR CONCAT(C.Nom, ' ', C.ApPat, ' ', C.ApMat) = @P_VALOR_FILTRO
)
```

#### Falta SET NOCOUNT ON

### Índices Recomendados:
```sql
-- Índice principal para búsqueda de clientes
CREATE NONCLUSTERED INDEX IX_Cliente2_RucE_Estado_TDI
ON Cliente2(RucE, ESTADO, Cd_TDI)
INCLUDE (Cd_Clt, NDoc, RSocial, Nom, ApPat, ApMat);

-- Índice para búsqueda por documento
CREATE NONCLUSTERED INDEX IX_Cliente2_NDoc
ON Cliente2(RucE, NDoc)
WHERE ESTADO = 1;

-- Índice para búsqueda por código cliente
CREATE NONCLUSTERED INDEX IX_Cliente2_CdClt
ON Cliente2(RucE, Cd_Clt)
WHERE ESTADO = 1;
```

---

## Resumen de Acciones Prioritarias

### ALTA PRIORIDAD (hacer primero):
1. Agregar `SET NOCOUNT ON` a todos los SPs
2. Eliminar JOINs no utilizados en SP #2
3. Cambiar OR por UNION ALL en SP #2
4. Crear índices en tablas principales

### MEDIA PRIORIDAD:
5. Reemplazar COALESCE/ISNULL en WHERE por condiciones SARGABLES
6. Evitar funciones en columnas del WHERE (CONVERT, SUBSTRING, etc.)
7. Optimizar EXISTS eliminando SELECT de columnas

### Scripts de Índices a Ejecutar:
```sql
-- Ejecutar en orden de prioridad

-- 1. Movimientos Detalle Venta
CREATE NONCLUSTERED INDEX IX_MovDetVenta_RucE_OpDestino
ON MOVIMIENTOSDETALLEVENTA(RUCE, Cd_OP_DESTINO);

CREATE NONCLUSTERED INDEX IX_MovDetVenta_RucE_OpOrigen
ON MOVIMIENTOSDETALLEVENTA(RUCE, CD_OP_ORIGEN);

-- 2. Clientes
CREATE NONCLUSTERED INDEX IX_Cliente2_RucE_Estado
ON Cliente2(RucE, ESTADO)
INCLUDE (Cd_Clt, NDoc, RSocial, Cd_TDI);

-- 3. Movimiento Caja
CREATE NONCLUSTERED INDEX IX_MovCaja_Busqueda
ON SPV.T_MOVIMIENTO_CAJA(C_CODIGO_EMPRESA, C_CODIGO_LOCALIDAD, C_CODIGO_CAJA, C_ESTADO)
INCLUDE (C_ID_MOVIMIENTO_CAJA, C_FECHA_MOVIMIENTO);
```
