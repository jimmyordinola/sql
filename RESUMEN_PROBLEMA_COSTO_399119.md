# RESUMEN: ¿DE DÓNDE SALE EL COSTO 3.99119?

## 📋 PROBLEMA IDENTIFICADO

Dos movimientos de salida en **ALMACEN FABRICA(INSUMOS)** el 29/04/2025 usan un costo incorrecto:

| Documento | Fecha | Cantidad | Costo Usado | Costo Correcto | Error |
|-----------|-------|----------|-------------|----------------|-------|
| INV000297367 | 29/04 08:05 | 11.000 kg | **3.99119** | 3.10209 | +0.88910 |
| INV000297372 | 29/04 08:50 | 22.397 kg | **3.99119** | 2.66542 | +1.32577 |

---

## 🔍 ORIGEN DEL COSTO 3.99119

### El costo 3.99119 **NO** viene de ningún movimiento en ALMACEN FABRICA(INSUMOS)

**Evidencia:**

1. **Movimiento anterior a INV000297367:**
   - Documento: INV000307010 (entrada del 28/04 23:58)
   - Saldo Costo resultante: **3.10209**
   - Costo que debería usar INV000297367: **3.10209**
   - Costo que realmente usa: **3.99119** ❌

2. **No hay entradas con costo 3.99119:**
   - Revisando todas las entradas en ALMACEN FABRICA(INSUMOS): NINGUNA tiene costo 3.99
   - Las últimas entradas del 28/04 tienen costo 3.70

3. **No hay saldos costo 3.99119 antes del 29/04:**
   - El Saldo Costo nunca llegó a 3.99119 en este almacén

---

## 💡 HIPÓTESIS: COSTO GLOBAL vs COSTO POR ALMACÉN

### El costo 3.99119 viene de la tabla **CostoInventario**

**Explicación:**

```
┌─────────────────────────────────────────────────────────────────┐
│ TABLA: CostoInventario                                          │
├─────────────────────────────────────────────────────────────────┤
│ - Almacena EL COSTO GLOBAL del producto (todos los almacenes)  │
│ - Campo: Costo_MN = 3.99119 (promedio GLOBAL)                  │
│ - Campo: IC_TipoCostoInventario = 'M' (Promedio)               │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ El sistema consulta este costo
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ SALIDA: INV000297367 / INV000297372                            │
├─────────────────────────────────────────────────────────────────┤
│ - Usa Costo_MN = 3.99119 (GLOBAL) ❌                           │
│ - Debería usar: Saldo Costo del almacén (3.10209 / 2.66542) ✓ │
└─────────────────────────────────────────────────────────────────┘
```

---

## ⚠️ ERROR DE DISEÑO DEL SISTEMA

### Problema:

El sistema calcula el **Costo Promedio Ponderado GLOBALMENTE** (todos los almacenes juntos) y lo almacena en `CostoInventario.Costo_MN`.

Cuando se registra una salida, el sistema:
1. ❌ **INCORRECTO:** Consulta `CostoInventario.Costo_MN` (costo global = 3.99119)
2. ✓ **CORRECTO:** Debería usar el `Saldo Costo` del movimiento anterior en el **MISMO almacén**

### ¿Por qué es un error?

En el método de **Costo Promedio Ponderado**, cada almacén debe tener su propio costo promedio porque:

- **ALMACEN A** puede tener stock antiguo con costo 3.00
- **ALMACEN B** puede tener stock nuevo con costo 5.00
- El **costo promedio GLOBAL** (4.00) no representa correctamente el costo de ninguno de los dos

---

## 📊 IMPACTO DEL ERROR

### En ALMACEN FABRICA(INSUMOS):

```
Movimiento: INV000297367 (11.000 kg)
  Costo usado:     3.99119
  Costo correcto:  3.10209
  Sobrecosto:      0.88910 por kg
  Total error:     11.000 × 0.88910 = S/ 9.80 de sobrecosto

Movimiento: INV000297372 (22.397 kg)
  Costo usado:     3.99119
  Costo correcto:  2.66542
  Sobrecosto:      1.32577 por kg
  Total error:     22.397 × 1.32577 = S/ 29.69 de sobrecosto

TOTAL SOBRECOSTO: S/ 39.49
```

Esto genera:
- ✓ Saldo Cantidad: 0.000 kg (correcto)
- ❌ Saldo Total: -29.69 soles (incorrecto, debería ser ~0)

---

## ✅ SOLUCIÓN

### Opción 1: Corrección Manual (Más precisa)

Corregir los costos de salida en las tablas:

**InventarioDet2:**
```sql
-- INV000297367
UPDATE InventarioDet2
SET Cantidad = 11.000,
    Costo = 3.10209,
    Subtotal = 11.000 * 3.10209  -- 34.12299
WHERE Cd_Inv = 'INV000297367'
  AND Cd_Prod = 'PD00534'

-- INV000297372
UPDATE InventarioDet2
SET Cantidad = 22.397,
    Costo = 2.66542,
    Subtotal = 22.397 * 2.66542  -- 59.69734
WHERE Cd_Inv = 'INV000297372'
  AND Cd_Prod = 'PD00534'
```

**CostoInventario:**
```sql
-- INV000297367
UPDATE CostoInventario
SET Cantidad = 11.000,
    Costo_MN = 3.10209
WHERE Cd_Inv = 'INV000297367'
  AND Item = [item correspondiente]
  AND IC_TipoCostoInventario = 'M'

-- INV000297372
UPDATE CostoInventario
SET Cantidad = 22.397,
    Costo_MN = 2.66542
WHERE Cd_Inv = 'INV000297372'
  AND Item = 2
  AND IC_TipoCostoInventario = 'M'
```

### Opción 2: Corrección Estructural (Largo plazo)

Modificar el sistema para que:
1. Calcule el costo promedio **POR ALMACÉN** en lugar de globalmente
2. Use el `Saldo Costo` del movimiento anterior del **mismo almacén**
3. Almacene costos por almacén en `CostoInventario` (añadir campo `Cd_Almacen`)

---

## 📝 CONCLUSIÓN

**El costo 3.99119 es el COSTO PROMEDIO GLOBAL del producto PD00534** (calculado considerando todos los almacenes juntos), almacenado en la tabla `CostoInventario`.

**El error está en que el sistema usa este costo GLOBAL** en lugar del costo específico de cada almacén, violando el principio del método de Costo Promedio Ponderado que debe aplicarse por almacén individual.

**Resultado:** Sobrecostos en salidas, saldos totales incorrectos y pérdidas ficticias de valor en el inventario.
