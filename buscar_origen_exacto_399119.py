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

print("=" * 120)
print("BUSCANDO EL ORIGEN EXACTO DEL COSTO 3.99119")
print("=" * 120)
print()

# Buscar el documento INV000297367
doc_367 = df[df['Codigo Inventario'] == 'INV000297367']

if len(doc_367) > 0:
    row = doc_367.iloc[0]

    print("DOCUMENTO INV000297367:")
    print(f"  Fecha: {row['Fecha Movimiento']}")
    print(f"  Almacen: {row['Nom. Almacen']}")
    print(f"  Tipo Operacion: {row['Tipo Operacion']} - {row['Nombre Tipo Operacion']}")
    print(f"  Cantidad Salida: {row['Cantidad Salida']:.3f} kg")
    print(f"  Costo Salida: {row['Costo Salida']:.10f}")
    print(f"  Total Salida: {row['Total Salida']:.10f}")
    print()

    # Verificar el cálculo
    total_calculado = row['Cantidad Salida'] * row['Costo Salida']
    print(f"Verificacion: {row['Cantidad Salida']:.3f} x {row['Costo Salida']:.10f} = {total_calculado:.10f}")
    print(f"Total en kardex: {row['Total Salida']:.10f}")
    print(f"Diferencia: {abs(total_calculado - row['Total Salida']):.10f}")
    print()

print("=" * 120)
print("HIPOTESIS: El costo viene de CostoInventario")
print("=" * 120)
print()

print("Consulta SQL para verificar:")
print()
print("SELECT")
print("    Cd_Inv,")
print("    Item,")
print("    Cd_Prod,")
print("    Cantidad,")
print("    Costo_MN,")
print("    IC_TipoCostoInventario")
print("FROM CostoInventario")
print("WHERE Cd_Prod = 'PD00534'")
print("  AND Cd_Inv IN ('INV000297367', 'INV000297372')")
print("  AND IC_TipoCostoInventario = 'M'")
print("ORDER BY Cd_Inv, Item")
print()

print("=" * 120)
print("TEORIA: De donde sale 3.99119")
print("=" * 120)
print()

print("OPCION 1: Costo promedio GLOBAL en un momento especifico")
print("-" * 120)
print()

# Intentar encontrar en que momento el costo global es 3.99119
# Recorrer el kardex cronologicamente y calcular el costo global despues de cada movimiento

print("Calculando el costo promedio global despues de cada movimiento...")
print()

# Obtener todos los movimientos ordenados por fecha
df_ordenado = df.sort_values('Fecha Movimiento').copy()

# Diccionario para almacenar saldos por almacen
saldos_almacenes = {}

costos_encontrados = []

for idx, row in df_ordenado.iterrows():
    almacen = row['Nom. Almacen']

    # Inicializar almacen si no existe
    if almacen not in saldos_almacenes:
        saldos_almacenes[almacen] = {'cantidad': 0.0, 'total': 0.0}

    # Actualizar saldo del almacen
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

        # Si el costo global esta cerca de 3.99119, guardarlo
        if abs(costo_global - 3.99119) < 0.01:
            costos_encontrados.append({
                'fecha': row['Fecha Movimiento'],
                'documento': row['Codigo Inventario'],
                'almacen': almacen,
                'movimiento': row['Movimiento'],
                'costo_global': costo_global,
                'total_cantidad': total_cantidad,
                'total_valor': total_valor
            })

if len(costos_encontrados) > 0:
    print(f"ENCONTRADOS {len(costos_encontrados)} momentos donde el costo global ~ 3.99119:")
    print()

    for i, c in enumerate(costos_encontrados[:5], 1):  # Mostrar primeros 5
        print(f"{i}. Fecha: {c['fecha']}")
        print(f"   Documento: {c['documento']}")
        print(f"   Almacen: {c['almacen']}")
        print(f"   Movimiento: {c['movimiento']}")
        print(f"   Costo Global: {c['costo_global']:.10f}")
        print(f"   Total Cantidad: {c['total_cantidad']:.3f} kg")
        print(f"   Total Valor: {c['total_valor']:.5f} soles")
        print()

    # Ver el primero
    primer_momento = costos_encontrados[0]
    print("=" * 120)
    print("PRIMER MOMENTO CON COSTO GLOBAL ~3.99119")
    print("=" * 120)
    print()
    print(f"Fecha: {primer_momento['fecha']}")
    print(f"Documento que lo genero: {primer_momento['documento']}")
    print()
    print("CONCLUSION:")
    print(f"  El costo 3.99119 es el costo promedio GLOBAL que existia en este momento.")
    print(f"  Este costo se calculo asi:")
    print(f"    Total Valor Global = {primer_momento['total_valor']:.5f} soles")
    print(f"    Total Cantidad Global = {primer_momento['total_cantidad']:.3f} kg")
    print(f"    Costo Promedio = {primer_momento['total_valor']:.5f} / {primer_momento['total_cantidad']:.3f} = {primer_momento['costo_global']:.10f}")
    print()
    print("  Este valor se guardo en CostoInventario.Costo_MN y se uso para las salidas posteriores.")
else:
    print("NO se encontro ningun momento donde el costo global sea ~3.99119")
    print()
    print("CONCLUSION:")
    print("  El costo 3.99119 probablemente:")
    print("    1. Viene directamente de la tabla CostoInventario (ya estaba guardado)")
    print("    2. Fue calculado por otro proceso del sistema (no reflejado en el kardex)")
    print("    3. Es un valor fijo o por defecto configurado en el sistema")
    print()
    print("  Para confirmarlo, debes consultar directamente la tabla CostoInventario:")
    print()
    print("  SELECT * FROM CostoInventario")
    print("  WHERE Cd_Prod = 'PD00534'")
    print("    AND Cd_Inv = 'INV000297367'")
    print("    AND IC_TipoCostoInventario = 'M'")
