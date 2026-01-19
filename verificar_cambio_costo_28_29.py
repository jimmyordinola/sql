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

print("=" * 150)
print("TODOS LOS MOVIMIENTOS ENTRE EL 28/04 Y 29/04 - TODOS LOS ALMACENES")
print("=" * 150)
print()

# Filtrar movimientos entre 28 y 29 de abril
df_28_29 = df[
    (df['Fecha Movimiento'] >= '2025-04-28 00:00:00') &
    (df['Fecha Movimiento'] <= '2025-04-29 23:59:59')
].copy()

# Ordenar por fecha
df_28_29 = df_28_29.sort_values('Fecha Movimiento')

print(f"Total de movimientos: {len(df_28_29)}")
print()

print(f"{'#':<4} {'Fecha':<24} {'Almacen':<32} {'Tipo':<8} {'Cant':>9} {'Costo':>10} {'Total':>12} {'Saldo Cant':>11} {'Saldo Costo':>12}")
print("-" * 150)

for i, (idx, row) in enumerate(df_28_29.iterrows(), 1):
    tipo = row['Movimiento']

    if tipo == 'Entrada':
        cant = row['Cantidad Entrada']
        costo = row['Costo Entrada']
        total = row['Total Entrada']
    else:
        cant = row['Cantidad Salida']
        costo = row['Costo Salida']
        total = row['Total Salida']

    # Marcar el cambio de costo
    marca = ""
    if costo == 4.09178:
        marca = " <- 4.09"
    elif costo == 3.99119:
        marca = " <- 3.99"

    print(f"{i:<4} {str(row['Fecha Movimiento']):<24} {str(row['Nom. Almacen'])[:32]:<32} {tipo:<8} "
          f"{cant:>9.3f} {costo:>10.5f} {total:>12.5f} {row['Saldo Cantidad']:>11.3f} {row['Saldo Costo']:>12.5f}{marca}")

print()

# Calcular el costo global en diferentes momentos
print("=" * 150)
print("CALCULANDO COSTO GLOBAL DESPUÉS DE CADA MOVIMIENTO")
print("=" * 150)
print()

# Obtener TODOS los movimientos hasta el 28/04 final
df_ordenado = df.sort_values('Fecha Movimiento').copy()

# Diccionario para almacenar saldos por almacén
saldos_almacenes = {}

print("Procesando kardex cronológicamente para calcular costo global...")
print()

# Procesar hasta encontrar el cambio de 4.09 a 3.99
momentos_clave = []

for idx, row in df_ordenado.iterrows():
    almacen = row['Nom. Almacen']

    # Inicializar almacén si no existe
    if almacen not in saldos_almacenes:
        saldos_almacenes[almacen] = {'cantidad': 0.0, 'total': 0.0}

    # Actualizar saldo del almacén
    if row['Movimiento'] == 'Entrada':
        saldos_almacenes[almacen]['cantidad'] += row['Cantidad Entrada']
        saldos_almacenes[almacen]['total'] += row['Total Entrada']
    else:
        saldos_almacenes[almacen]['cantidad'] -= row['Cantidad Salida']
        saldos_almacenes[almacen]['total'] -= row['Total Salida']

    # Calcular costo global
    total_cantidad = sum([s['cantidad'] for s in saldos_almacenes.values()])
    total_valor = sum([s['total'] for s in saldos_almacenes.values()])

    if total_cantidad > 0:
        costo_global = total_valor / total_cantidad

        # Guardar momentos clave
        if row['Fecha Movimiento'] >= pd.Timestamp('2025-04-28 00:00:00'):
            # Guardar info del momento
            if abs(costo_global - 4.09178) < 0.001 or abs(costo_global - 3.99119) < 0.001:
                momentos_clave.append({
                    'fecha': row['Fecha Movimiento'],
                    'documento': row['Codigo Inventario'],
                    'almacen': almacen,
                    'movimiento': row['Movimiento'],
                    'costo_global': costo_global,
                    'total_cantidad': total_cantidad,
                    'total_valor': total_valor
                })

if len(momentos_clave) > 0:
    print(f"MOMENTOS CLAVE donde el costo global es ~4.09 o ~3.99:")
    print()

    for i, m in enumerate(momentos_clave, 1):
        print(f"{i}. {m['fecha']} | {m['documento']} | {m['almacen'][:25]:<25} | {m['movimiento']:<7}")
        print(f"   Costo Global: {m['costo_global']:.10f}")
        print(f"   Total Cant: {m['total_cantidad']:.3f} kg | Total Valor: S/ {m['total_valor']:.5f}")
        print()

print()
print("=" * 150)
print("SALDOS POR ALMACÉN AL FINAL DEL 28/04")
print("=" * 150)
print()

# Ver saldos de cada almacén al final del 28/04
df_hasta_28 = df[df['Fecha Movimiento'] <= '2025-04-28 23:59:59'].copy()

almacenes = df_hasta_28['Nom. Almacen'].unique()

total_cant_global = 0
total_valor_global = 0

print(f"{'Almacén':<35} {'Cantidad':>12} {'Saldo Costo':>13} {'Saldo Total':>14}")
print("-" * 150)

for almacen in almacenes:
    df_alm = df_hasta_28[df_hasta_28['Nom. Almacen'] == almacen]
    if len(df_alm) > 0:
        ultimo = df_alm.iloc[-1]
        print(f"{almacen:<35} {ultimo['Saldo Cantidad']:>12.3f} kg {ultimo['Saldo Costo']:>13.5f} {ultimo['Saldo Total']:>14.5f}")

        total_cant_global += ultimo['Saldo Cantidad']
        total_valor_global += ultimo['Saldo Total']

print("-" * 150)
print(f"{'TOTAL GLOBAL':<35} {total_cant_global:>12.3f} kg {' ':>13} {total_valor_global:>14.5f}")

if total_cant_global > 0:
    costo_global_28 = total_valor_global / total_cant_global
    print()
    print(f"COSTO PROMEDIO GLOBAL al final del 28/04: {total_valor_global:.5f} / {total_cant_global:.3f} = {costo_global_28:.10f}")

print()
print("=" * 150)
print("CONCLUSIÓN")
print("=" * 150)
print()

if total_cant_global > 0:
    print(f"Al final del 28/04, el costo promedio global era: {costo_global_28:.5f}")
    print()

    if abs(costo_global_28 - 4.09178) < 0.01:
        print("Este valor (~4.09) coincide con el costo usado en las salidas del 28/04.")
    elif abs(costo_global_28 - 3.99119) < 0.01:
        print("Este valor (~3.99) coincide con el costo usado en las salidas del 29/04.")
    else:
        print(f"Este valor NO coincide con 4.09178 ni con 3.99119")
        print()
        print("El costo 4.09178 y 3.99119 probablemente vienen de momentos anteriores")
        print("y están guardados en CostoInventario, sin actualizarse con cada movimiento.")
