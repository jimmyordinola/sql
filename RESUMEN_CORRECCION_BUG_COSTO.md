# RESUMEN: Corrección Bug Costo 3.991195

## Estado Actual

✅ **CORRECCIÓN APLICADA** en los archivos locales:

1. **[USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS_2.sql](d:\nuvol\sp\USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS_2.sql#L353)**
   - Línea 353: Cambiado `<` por `<=`
   - Base de datos: `ERP_TEST`
   - Historial actualizado con documentación del fix

2. **[CORREGIR_BUG_Y_RECALCULAR_LIMON.sql](d:\nuvol\sp\CORREGIR_BUG_Y_RECALCULAR_LIMON.sql)**
   - Script completo que aplica la función corregida
   - Recalcula PD00534 (LIMON X KG)
   - Verifica los resultados
   - Base de datos: `ERP_TEST`

3. **[ANALISIS_BUG_COSTO_3.99.md](d:\nuvol\sp\ANALISIS_BUG_COSTO_3.99.md)**
   - Documentación detallada del bug
   - Evidencia del error
   - Análisis de impacto

---

## El Problema Identificado

### Bug en Línea 353

**ANTES (incorrecto):**
```sql
and id.FechaMovimiento < @P_FECHA_HASTA
```

**DESPUÉS (corregido):**
```sql
and id.FechaMovimiento <= @P_FECHA_HASTA  -- CORREGIDO: incluye movimientos de la misma fecha/hora
```

### Impacto del Bug

Cuando el SP de recálculo procesaba salidas de inventario:

1. Llamaba a `USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS_2` para obtener el costo
2. La función con el bug (`<`) **excluía** movimientos de la misma fecha/hora exacta
3. Devolvía un costo incorrecto (ej: 3.991195 en lugar de 3.102090)
4. El recálculo guardaba ese costo erróneo en `CostoInventario`
5. Resultado: Saldo Total negativo de -29.69 soles

### Evidencia Real

**Movimiento INV000297367 (29-04-2025 08:05:00):**
- Saldo anterior: 33.397 kg × 3.102090 = 103.60 soles
- Salida: 11.000 kg
- Costo INCORRECTO usado: 3.991195 → Total: 43.90 soles
- Costo CORRECTO: 3.102090 → Total: 34.12 soles
- **Error: -9.78 soles**

**Movimiento INV000297372 (29-04-2025 08:50:00):**
- Saldo anterior: 22.397 kg × 2.665417 = 59.70 soles
- Salida: 22.397 kg (todo el saldo)
- Costo INCORRECTO usado: 3.991195 → Total: 89.39 soles
- Costo CORRECTO: 2.665417 → Total: 59.70 soles
- **Error: -29.69 soles** ← Aquí aparece el negativo

---

## Próximos Pasos

### 1. Ejecutar la Corrección en SQL Server

Abre **SQL Server Management Studio** y ejecuta:

```
d:\nuvol\sp\CORREGIR_BUG_Y_RECALCULAR_LIMON.sql
```

Este script hace automáticamente:
- ✅ Aplica la función corregida en la base de datos `ERP_TEST`
- ✅ Recalcula PD00534 (LIMON X KG) desde 01-04-2025
- ✅ Muestra los costos corregidos

### 2. Verificar Resultados

El script mostrará una tabla con el estado de los costos:

**Resultado Esperado:**
```
Codigo      Fecha                Cantidad  CostoActual  Estado
----------  -------------------  --------  -----------  ------------------
INV000297367 2025-04-29 08:05:00  11.000   3.102090     ✓ CORRECTO (3.102)
INV000297372 2025-04-29 08:50:00  22.397   2.665417     ✓ CORRECTO (2.665)
```

**Si aún muestra ERROR:**
```
INV000297367 2025-04-29 08:05:00  11.000   3.991195     ✗ ERROR (3.991)
```

Significa que la función no se actualizó correctamente en la BD.

### 3. Verificar el Kardex

Después del recálculo, genera el kardex nuevamente:

**Comando esperado:**
```sql
EXEC sp_kardexAlmacenPM
    @RucE = '20102351038',
    @Cd_Prod = 'PD00534',
    @FechaDesde = '2025-04-01',
    @FechaHasta = '2025-04-30',
    @Cd_Alm = 'ALMACEN FABRICA(INSUMOS)'
```

**Resultado esperado en la última línea:**
- Saldo Cantidad: 0.000 kg ✓
- Saldo Total: 0.00 soles ✓ (en lugar de -29.69)

---

## Archivos Modificados

### Para Producción (ERP_ECHA)

Cuando estés listo para aplicar en producción:

1. Cambiar `USE [ERP_TEST]` a `USE [ERP_ECHA]` en:
   - `USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS_2.sql` línea 1
   - `CORREGIR_BUG_Y_RECALCULAR_LIMON.sql` línea 10

2. Ejecutar el mismo proceso en producción

3. Recalcular TODOS los productos afectados desde abril 2025

---

## Contexto Técnico

### Por Qué el Recálculo Anterior No Funcionó

El recálculo que hiciste antes **usaba la función con el bug**, por eso no corrigió el problema:

```
USP_COSTO_INVENTARIO_RECALCULAR_4
  ↓
  llama a → USP_COSTO_INVENTARIO_RECALCULAR_INDIVIDUAL_PROMEDIO
    ↓
    Para cada SALIDA:
      llama a → USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS_2 ← BUG AQUÍ
        ↓
        Devuelve costo incorrecto 3.991195 ❌
        ↓
    Guarda ese costo erróneo en CostoInventario
```

### Ahora con la Función Corregida

```
USP_COSTO_INVENTARIO_RECALCULAR_4
  ↓
  llama a → USP_COSTO_INVENTARIO_RECALCULAR_INDIVIDUAL_PROMEDIO
    ↓
    Para cada SALIDA:
      llama a → USP_SELECCIONAR_COSTO_SALIDA_PROMEDIO_PEPS_2 ← CORREGIDO
        ↓
        Devuelve costo correcto 3.102090 ✓
        ↓
    Guarda ese costo correcto en CostoInventario
```

---

## Origen del Bug

Según el historial del archivo:

```
--DJ: 30/04/2024 <Se corrigió el cálculo cuando @IB_VARIAS_UMP_PRINCIPAL esté activo.
                  Se agregó el filtro 'id.FechaMovimiento < @P_FECHA_HASTA'>
```

El cambio del **30/04/2024** introdujo el bug al agregar el filtro con `<` en lugar de `<=`.

Este error ha estado afectando los cálculos durante **8 meses** (desde abril 2024).

---

## Productos Potencialmente Afectados

Este bug afecta a **TODOS los productos** que tienen:
- `IB_KardexAlm = 1` (cálculo por almacén)
- Múltiples salidas en la misma fecha/hora exacta
- Costo promedio ponderado (`IC_TipoCostoInventario = 'PROMEDIO'`)

**Recomendación:** Después de verificar que la corrección funciona con PD00534 (LIMON X KG), considera recalcular todos los productos desde abril 2024.

---

## Contacto para Dudas

Si tienes preguntas sobre:
- La corrección aplicada
- El proceso de recálculo
- Otros productos afectados
- Implementación en producción

Consulta los archivos de documentación o pregunta directamente.
