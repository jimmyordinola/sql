# BUG CRÍTICO IDENTIFICADO: Costo 3.991195 Incorrecto

## Problema

El costo de salida **3.991195** utilizado en los movimientos **INV000297367** y **INV000297372** es incorrecto, causando un saldo total negativo de **-29.69 soles**.

---

## Causa Raíz: ERROR EN LÍNEA 353

**Archivo:** [USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS_2.sql:353](d:\nuvol\sp\USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS_2.sql#L353)

```sql
and id.FechaMovimiento < @P_FECHA_HASTA
```

### El Problema

Esta línea usa el operador **`<`** (menor que) en lugar de **`<=`** (menor o igual que).

**Consecuencia:**
- Cuando se calcula el costo de salida para un movimiento con fecha `2025-04-29 08:05:00`
- La función busca movimientos **anteriores** a esa fecha usando `< @P_FECHA_HASTA`
- Pero como usa `<` en lugar de `<=`, **EXCLUYE** movimientos de la misma fecha/hora exacta
- Esto puede causar que tome un costo de un periodo anterior o de otro almacén

---

## Evidencia del Error

### Estado Correcto (28-04-2025 23:58:20)
```
Movimiento: INV000307010 (ALMACEN FABRICA INSUMOS)
- Entrada: 25.000 kg × 3.700110 = 92.50 soles
- Saldo Cantidad: 33.397 kg
- Saldo Total: 103.60 soles
- Saldo Costo: 103.60 / 33.397 = 3.102090 soles/kg ✓ CORRECTO
```

### Salida Incorrecta (29-04-2025 08:05:00)
```
Movimiento: INV000297367 (ALMACEN FABRICA INSUMOS)
- Cantidad Salida: 11.000 kg
- Costo usado: 3.991195 soles/kg ❌ INCORRECTO
- Costo correcto: 3.102090 soles/kg ✓
- Error: La función NO encuentra el saldo correcto debido a la línea 353
```

### Origen del Costo 3.991195

Este costo **NO EXISTE** en el ALMACEN FABRICA(INSUMOS) en esas fechas. Posibles fuentes:

1. **Cálculo global** en lugar de por almacén (violando IB_KardexAlm = 1)
2. **Promedio de otros almacenes** incluidos incorrectamente
3. **Costo "fantasma"** de un periodo anterior que no debería aplicar

---

## Comparación con Línea 222 (Correcta)

**Línea 222** (en la consulta UNION ALL anterior) usa el operador correcto:

```sql
AND i.FechaMovimiento <= CASE WHEN @P_FECHA_HASTA IS NULL THEN i.FechaMovimiento ELSE CONVERT(datetime, @P_FECHA_HASTA) + ' 23:59:29' END
```

**Línea 353** usa el operador incorrecto:

```sql
and id.FechaMovimiento < @P_FECHA_HASTA
```

Esta **inconsistencia** entre las dos líneas causa el error.

---

## Solución Propuesta

### Cambio en Línea 353

**ANTES:**
```sql
and id.FechaMovimiento < @P_FECHA_HASTA
```

**DESPUÉS:**
```sql
and id.FechaMovimiento <= @P_FECHA_HASTA
```

### Justificación

1. **Consistencia:** La línea 222 usa `<=`, la línea 353 debe usar lo mismo
2. **Lógica correcta:** Para calcular el costo de salida a las `08:05:00`, DEBE incluir movimientos hasta esa hora exacta
3. **IB_KardexAlm = 1:** Con esta configuración activa, debe calcular el promedio del almacén específico hasta el momento exacto del movimiento

---

## Impacto del Error

### Antes de la Corrección
```
INV000297367 (29-04 08:05): 11.000 kg × 3.991195 = 43.90 soles
INV000297372 (29-04 08:50): 22.397 kg × 3.991195 = 89.39 soles
Saldo Total Final: -29.69 soles ❌
```

### Después de la Corrección (Esperado)
```
INV000297367 (29-04 08:05): 11.000 kg × 3.102090 = 34.12 soles
INV000297372 (29-04 08:50): 22.397 kg × 3.102090 = 69.48 soles
Saldo Total Final: 0.00 soles ✓
```

**Diferencia:** -29.69 soles de error corregidos

---

## Historial de Cambios (del archivo)

Según los comentarios al final del SP:

```
--DJ: 30/04/2024 <Se corrigió el cálculo cuando @IB_VARIAS_UMP_PRINCIPAL esté activo.
                  Se agregó el filtro 'id.FechaMovimiento < @P_FECHA_HASTA'>
```

**Análisis:** El cambio del 30/04/2024 **introdujo el bug** al agregar el filtro con `<` en lugar de `<=`.

Este es un **error de lógica** en la corrección que se hizo hace 8 meses.

---

## Acción Requerida

1. **Modificar USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS_2.sql línea 353**
   - Cambiar `<` por `<=`

2. **Ejecutar el SP modificado** en la base de datos

3. **Recalcular costos** para PD00534 (LIMON X KG) desde abril 2025

4. **Verificar resultados** con el script de verificación

---

## Script de Verificación Post-Corrección

```sql
-- Verificar que los costos se corrijan después de modificar la función
SELECT
    i2.FechaMovimiento,
    ci.Cd_Inv,
    id2.Cd_Alm,
    id2.Cantidad,
    ci.Costo_MN,
    CASE
        WHEN ABS(ci.Costo_MN - 3.102090) < 0.01 THEN 'CORRECTO (3.10)'
        WHEN ABS(ci.Costo_MN - 3.991195) < 0.01 THEN 'ERROR (3.99)'
        ELSE 'OTRO: ' + CAST(ci.Costo_MN AS VARCHAR(20))
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
```

**Resultado Esperado:** Ambos movimientos deben mostrar "CORRECTO (3.10)"
