import pandas as pd

# Leer CSV
df = pd.read_csv(r"d:\nuvol\sp\kardex_limon_v2.csv", encoding='utf-8-sig')

# Convertir columnas
df['Fecha Movimiento'] = pd.to_datetime(df['Fecha Movimiento'], format='mixed', errors='coerce')
df['Cantidad Salida'] = pd.to_numeric(df['Cantidad Salida'], errors='coerce')
df['Costo Salida'] = pd.to_numeric(df['Costo Salida'], errors='coerce')
df['Total Salida'] = pd.to_numeric(df['Total Salida'], errors='coerce')
df['Saldo Cantidad'] = pd.to_numeric(df['Saldo Cantidad'], errors='coerce')
df['Saldo Costo'] = pd.to_numeric(df['Saldo Costo'], errors='coerce')
df['Saldo Total'] = pd.to_numeric(df['Saldo Total'], errors='coerce')
df['Movimiento'] = df['Movimiento'].str.strip()

print("=" * 140)
print("ANÁLISIS DE COSTOS DE SALIDA - ALMACEN FABRICA(INSUMOS)")
print("=" * 140)
print()

# Filtrar ALMACEN FABRICA(INSUMOS)
df_fabrica = df[df['Nom. Almacen'].str.strip() == 'ALMACEN FABRICA(INSUMOS)'].copy()

# Filtrar solo salidas desde el 25/04
df_salidas = df_fabrica[
    (df_fabrica['Movimiento'] == 'Salida') &
    (df_fabrica['Fecha Movimiento'] >= '2025-04-25')
].copy()

print("TODAS LAS SALIDAS DESDE EL 25/04/2025:")
print("-" * 140)
print()

print(f"{'Fecha':<20} {'Documento':<17} {'Cantidad':>10} {'Costo Salida':>13} {'Total Salida':>13} {'Saldo Costo':>13} {'Observación':<30}")
print("-" * 140)

for idx, row in df_salidas.iterrows():
    # Obtener el movimiento anterior para ver el saldo costo previo
    idx_en_lista = list(df_fabrica.index).index(idx)

    if idx_en_lista > 0:
        idx_anterior = list(df_fabrica.index)[idx_en_lista - 1]
        anterior = df_fabrica.loc[idx_anterior]
        saldo_costo_previo = anterior['Saldo Costo']

        # Comparar
        diferencia = row['Costo Salida'] - saldo_costo_previo

        if abs(diferencia) < 0.01:
            obs = "OK: Usa saldo costo previo"
        else:
            obs = f"ERROR: Dif {diferencia:+.5f}"
    else:
        saldo_costo_previo = 0.0
        obs = "Primer movimiento"

    print(f"{str(row['Fecha Movimiento']):<20} {row['Codigo Inventario']:<17} {row['Cantidad Salida']:>10.3f} "
          f"{row['Costo Salida']:>13.5f} {row['Total Salida']:>13.5f} {row['Saldo Costo']:>13.5f} {obs:<30}")

print()
print("=" * 140)
print("ANÁLISIS DE COSTOS ÚNICOS")
print("=" * 140)
print()

# Ver todos los costos de salida únicos en FABRICA
costos_unicos = df_fabrica[df_fabrica['Movimiento'] == 'Salida']['Costo Salida'].dropna().unique()
costos_unicos = sorted(costos_unicos)

print(f"Total de costos de salida diferentes en ALMACEN FABRICA(INSUMOS): {len(costos_unicos)}")
print()

print("COSTOS ÚNICOS:")
for costo in costos_unicos:
    cantidad = len(df_fabrica[(df_fabrica['Movimiento'] == 'Salida') & (df_fabrica['Costo Salida'] == costo)])
    print(f"  {costo:>10.5f} : usado en {cantidad} salidas")

print()
print("=" * 140)
print("VERIFICACIÓN: ¿Los costos de salida coinciden con el saldo costo anterior?")
print("=" * 140)
print()

# Verificar TODAS las salidas
salidas_fabrica = df_fabrica[df_fabrica['Movimiento'] == 'Salida'].copy()

correctos = 0
incorrectos = 0

print(f"{'#':<4} {'Fecha':<20} {'Documento':<17} {'Saldo Costo Previo':>19} {'Costo Salida':>13} {'Match':>8}")
print("-" * 140)

for i, (idx, row) in enumerate(salidas_fabrica.iterrows(), 1):
    idx_en_lista = list(df_fabrica.index).index(idx)

    if idx_en_lista > 0:
        idx_anterior = list(df_fabrica.index)[idx_en_lista - 1]
        anterior = df_fabrica.loc[idx_anterior]
        saldo_costo_previo = anterior['Saldo Costo']

        diferencia = abs(row['Costo Salida'] - saldo_costo_previo)

        if diferencia < 0.01:
            match = "OK"
            correctos += 1
        else:
            match = "ERROR"
            incorrectos += 1

        print(f"{i:<4} {str(row['Fecha Movimiento']):<20} {row['Codigo Inventario']:<17} "
              f"{saldo_costo_previo:>19.5f} {row['Costo Salida']:>13.5f} {match:>8}")

print()
print(f"Total salidas verificadas: {correctos + incorrectos}")
print(f"  Correctas (usan saldo costo previo): {correctos}")
print(f"  Incorrectas (usan otro costo): {incorrectos}")
print()

if incorrectos > 0:
    print("=" * 140)
    print("CONCLUSIÓN")
    print("=" * 140)
    print()
    print(f"Hay {incorrectos} salidas que NO usan el Saldo Costo del movimiento anterior.")
    print()
    print("Esto indica que:")
    print("  1. El sistema NO está usando el método de Costo Promedio Ponderado correctamente")
    print("  2. Los costos vienen de otra fuente (posiblemente CostoInventario)")
    print("  3. Cada salida puede tener un costo diferente dependiendo de cuándo se calculó")
    print()
    print("NO hay un único 'costo global' fijo. El costo varía según el momento.")
else:
    print("TODAS las salidas usan correctamente el Saldo Costo del movimiento anterior.")
