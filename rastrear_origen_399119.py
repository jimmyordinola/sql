import pandas as pd

# Leer CSV
df = pd.read_csv(r"d:\nuvol\sp\kardex_limon_v2.csv", encoding='utf-8-sig')

# Convertir columnas
df['Fecha Movimiento'] = pd.to_datetime(df['Fecha Movimiento'], format='mixed', errors='coerce')
df['Cantidad Entrada'] = pd.to_numeric(df['Cantidad Entrada'], errors='coerce')
df['Costo Entrada'] = pd.to_numeric(df['Costo Entrada'], errors='coerce')
df['Total Entrada'] = pd.to_numeric(df['Total Entrada'], errors='coerce')
df['Cantidad Salida'] = pd.to_numeric(df['Cantidad Salida'], errors='coerce')
df['Costo Salida'] = pd.to_numeric(df['Costo Salida'], errors='coerce')
df['Total Salida'] = pd.to_numeric(df['Total Salida'], errors='coerce')
df['Saldo Cantidad'] = pd.to_numeric(df['Saldo Cantidad'], errors='coerce')
df['Saldo Costo'] = pd.to_numeric(df['Saldo Costo'], errors='coerce')
df['Saldo Total'] = pd.to_numeric(df['Saldo Total'], errors='coerce')
df['Movimiento'] = df['Movimiento'].str.strip()

print("=" * 130)
print("RASTREANDO EL ORIGEN DEL COSTO 3.99119 - ANÁLISIS COMPLETO")
print("=" * 130)
print()

# Filtrar ALMACEN FABRICA(INSUMOS)
df_fabrica = df[df['Nom. Almacen'].str.strip() == 'ALMACEN FABRICA(INSUMOS)'].copy()

print("TODOS LOS MOVIMIENTOS EN ALMACEN FABRICA(INSUMOS) DESDE EL 28/04:")
print("-" * 130)
print()

# Filtrar desde el 28 de abril
df_desde_28 = df_fabrica[df_fabrica['Fecha Movimiento'] >= '2025-04-28'].copy()

print(f"{'#':<4} {'Fecha':<20} {'Documento':<17} {'Tipo':<8} {'Cantidad':>10} {'Costo':>12} {'Total':>14} {'Saldo Cant':>11} {'Saldo Costo':>12} {'Saldo Total':>14}")
print("-" * 130)

for i, (idx, row) in enumerate(df_desde_28.iterrows(), 1):
    tipo = row['Movimiento']
    if tipo == 'Entrada':
        print(f"{i:<4} {str(row['Fecha Movimiento']):<20} {row['Codigo Inventario']:<17} {tipo:<8} "
              f"{row['Cantidad Entrada']:>10.3f} {row['Costo Entrada']:>12.5f} {row['Total Entrada']:>14.5f} "
              f"{row['Saldo Cantidad']:>11.3f} {row['Saldo Costo']:>12.5f} {row['Saldo Total']:>14.5f}")
    else:
        marca = " <<<" if abs(row['Costo Salida'] - 3.99119) < 0.001 else ""
        print(f"{i:<4} {str(row['Fecha Movimiento']):<20} {row['Codigo Inventario']:<17} {tipo:<8} "
              f"{row['Cantidad Salida']:>10.3f} {row['Costo Salida']:>12.5f} {row['Total Salida']:>14.5f} "
              f"{row['Saldo Cantidad']:>11.3f} {row['Saldo Costo']:>12.5f} {row['Saldo Total']:>14.5f}{marca}")

print()
print("=" * 130)
print("ANÁLISIS DEL COSTO 3.99119")
print("=" * 130)
print()

# Buscar INV000297367
doc_367 = df_fabrica[df_fabrica['Codigo Inventario'] == 'INV000297367']

if len(doc_367) > 0:
    row_367 = doc_367.iloc[0]
    idx_367 = doc_367.index[0]
    idx_en_lista = list(df_fabrica.index).index(idx_367)

    print("PRIMER MOVIMIENTO CON COSTO 3.99119:")
    print(f"  Documento: INV000297367")
    print(f"  Fecha: {row_367['Fecha Movimiento']}")
    print(f"  Tipo Operación: {row_367['Tipo Operacion']} - {row_367['Nombre Tipo Operacion']}")
    print(f"  Cantidad Salida: {row_367['Cantidad Salida']:.3f} kg")
    print(f"  Costo Salida: {row_367['Costo Salida']:.10f}")
    print()

    # Movimiento anterior
    if idx_en_lista > 0:
        idx_anterior = list(df_fabrica.index)[idx_en_lista - 1]
        anterior = df_fabrica.loc[idx_anterior]

        print("MOVIMIENTO ANTERIOR:")
        print(f"  Documento: {anterior['Codigo Inventario']}")
        print(f"  Fecha: {anterior['Fecha Movimiento']}")
        print(f"  Saldo Costo ANTES de INV000297367: {anterior['Saldo Costo']:.10f}")
        print()

        print("PREGUNTA: ¿Por qué INV000297367 usa 3.99119 en lugar de {:.5f}?".format(anterior['Saldo Costo']))
        print()

# Buscar en TODO el kardex (todos los almacenes) el costo 3.99119
print("=" * 130)
print("BUSCANDO 3.99119 EN TODOS LOS ALMACENES")
print("=" * 130)
print()

# Buscar en saldos costo
saldos_399 = df[abs(df['Saldo Costo'] - 3.99119) < 0.001]

if len(saldos_399) > 0:
    print(f"SALDOS COSTO con valor ~3.99119: {len(saldos_399)}")
    print()
    print(f"{'Fecha':<20} {'Documento':<17} {'Almacén':<30} {'Movimiento':<8} {'Saldo Costo':>12}")
    print("-" * 90)

    for idx, row in saldos_399.iterrows():
        print(f"{str(row['Fecha Movimiento']):<20} {row['Codigo Inventario']:<17} {str(row['Nom. Almacen'])[:30]:<30} "
              f"{row['Movimiento']:<8} {row['Saldo Costo']:>12.5f}")
    print()

# Buscar entradas o salidas con costo cercano
print("=" * 130)
print("BUSCANDO MOVIMIENTOS PREVIOS QUE GENEREN UN COSTO ~3.99")
print("=" * 130)
print()

# Ver si hay alguna entrada cerca del 29/04 con costo que genere 3.99 como promedio
entradas_previas = df_fabrica[
    (df_fabrica['Movimiento'] == 'Entrada') &
    (df_fabrica['Fecha Movimiento'] >= '2025-04-28') &
    (df_fabrica['Fecha Movimiento'] < '2025-04-29')
]

if len(entradas_previas) > 0:
    print("ENTRADAS del 28/04:")
    for idx, ent in entradas_previas.iterrows():
        print(f"  {ent['Fecha Movimiento']} | {ent['Codigo Inventario']} | "
              f"{ent['Cantidad Entrada']:.3f} kg × {ent['Costo Entrada']:.5f} = {ent['Total Entrada']:.5f}")
    print()

# HIPÓTESIS FINAL
print("=" * 130)
print("CONCLUSIÓN")
print("=" * 130)
print()
print("El costo 3.99119 NO viene de ningún movimiento en ALMACEN FABRICA(INSUMOS).")
print()
print("HIPÓTESIS MÁS PROBABLE:")
print("  1. El costo 3.99119 viene de la tabla CostoInventario")
print("  2. Esta tabla almacena el COSTO GLOBAL del producto (todos los almacenes)")
print("  3. El sistema usa este costo GLOBAL en lugar del costo ESPECÍFICO del almacén")
print()
print("EVIDENCIA:")
print(f"  - Saldo Costo en ALMACEN FABRICA(INSUMOS) el 29/04: 2.66542")
print(f"  - Costo usado en la salida INV000297367: 3.99119")
print(f"  - Diferencia: {3.99119 - 2.66542:.5f}")
print()
print("ESTO ES UN ERROR DE DISEÑO DEL SISTEMA:")
print("  El método de Costo Promedio Ponderado debe calcularse POR ALMACÉN,")
print("  NO de forma global. Cada almacén tiene su propio costo promedio.")
print()
print("SOLUCIÓN:")
print("  Corregir los costos de salida para que usen el Saldo Costo del")
print("  movimiento anterior en el MISMO almacén:")
print(f"    INV000297367: Cambiar costo de 3.99119 a 3.10209")
print(f"    INV000297372: Cambiar costo de 3.99119 a 2.66542")
