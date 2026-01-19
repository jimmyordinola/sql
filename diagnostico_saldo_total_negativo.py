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
print("DIAGNÓSTICO DEL SALDO TOTAL NEGATIVO - INV000297372")
print("=" * 120)
print()

# Filtrar ALMACEN FABRICA(INSUMOS)
df_fabrica = df[df['Nom. Almacen'].str.strip() == 'ALMACEN FABRICA(INSUMOS)'].copy()

print(f"Total de movimientos en ALMACEN FABRICA(INSUMOS): {len(df_fabrica)}")
print()

# Buscar el movimiento problemático
mov_problema = df_fabrica[df_fabrica['Codigo Inventario'] == 'INV000297372'].iloc[0]
idx_problema = df_fabrica[df_fabrica['Codigo Inventario'] == 'INV000297372'].index[0]

print("=" * 120)
print("MOVIMIENTO PROBLEMÁTICO")
print("=" * 120)
print(f"Documento: {mov_problema['Codigo Inventario']}")
print(f"Fecha: {mov_problema['Fecha Movimiento']}")
print(f"Tipo: {mov_problema['Movimiento']}")
print()
print(f"Cantidad Salida: {mov_problema['Cantidad Salida']:.6f} kg")
print(f"Costo Salida: {mov_problema['Costo Salida']:.10f}")
print(f"Total Salida: {mov_problema['Total Salida']:.10f}")
print()
print(f"Saldo Cantidad: {mov_problema['Saldo Cantidad']:.6f} kg")
print(f"Saldo Costo: {mov_problema['Saldo Costo']:.10f}")
print(f"Saldo Total: {mov_problema['Saldo Total']:.10f}  <<< NEGATIVO")
print()

# Obtener movimiento anterior
idx_en_lista = list(df_fabrica.index).index(idx_problema)
if idx_en_lista > 0:
    idx_anterior = list(df_fabrica.index)[idx_en_lista - 1]
    anterior = df_fabrica.loc[idx_anterior]

    print("=" * 120)
    print("ANÁLISIS DEL PROBLEMA")
    print("=" * 120)
    print()

    print("MOVIMIENTO ANTERIOR:")
    print(f"  Saldo Cantidad: {anterior['Saldo Cantidad']:.6f} kg")
    print(f"  Saldo Costo: {anterior['Saldo Costo']:.10f}")
    print(f"  Saldo Total: {anterior['Saldo Total']:.10f}")
    print()

    print("SALIDA ACTUAL:")
    print(f"  Cantidad: {mov_problema['Cantidad Salida']:.6f} kg")
    print(f"  Costo: {mov_problema['Costo Salida']:.10f}")
    print(f"  Total: {mov_problema['Total Salida']:.10f}")
    print()

    # Verificar cálculo
    print("VERIFICACIÓN DEL CÁLCULO:")
    print()

    # Verificar cantidad
    cant_esperada = anterior['Saldo Cantidad'] - mov_problema['Cantidad Salida']
    print(f"  1. CANTIDAD:")
    print(f"     Saldo anterior: {anterior['Saldo Cantidad']:.6f} kg")
    print(f"     Salida: {mov_problema['Cantidad Salida']:.6f} kg")
    print(f"     Saldo esperado: {anterior['Saldo Cantidad']:.6f} - {mov_problema['Cantidad Salida']:.6f} = {cant_esperada:.6f} kg")
    print(f"     Saldo en kardex: {mov_problema['Saldo Cantidad']:.6f} kg")

    if abs(cant_esperada - mov_problema['Saldo Cantidad']) < 0.001:
        print(f"     OK: Cantidad correcta")
    else:
        print(f"     ERROR: Diferencia de {mov_problema['Saldo Cantidad'] - cant_esperada:.6f} kg")
    print()

    # Verificar total
    total_esperado = anterior['Saldo Total'] - mov_problema['Total Salida']
    print(f"  2. TOTAL:")
    print(f"     Saldo Total anterior: {anterior['Saldo Total']:.10f}")
    print(f"     Total Salida: {mov_problema['Total Salida']:.10f}")
    print(f"     Saldo Total esperado: {anterior['Saldo Total']:.5f} - {mov_problema['Total Salida']:.5f} = {total_esperado:.5f}")
    print(f"     Saldo Total en kardex: {mov_problema['Saldo Total']:.10f}")

    if abs(total_esperado - mov_problema['Saldo Total']) < 0.01:
        print(f"     OK: Total correcto")
    else:
        print(f"     ERROR: Diferencia de {mov_problema['Saldo Total'] - total_esperado:.5f}")
    print()

    # Verificar Total Salida
    print(f"  3. VERIFICAR TOTAL SALIDA:")
    total_salida_calc = mov_problema['Cantidad Salida'] * mov_problema['Costo Salida']
    print(f"     Total Salida calculado: {mov_problema['Cantidad Salida']:.6f} × {mov_problema['Costo Salida']:.10f} = {total_salida_calc:.10f}")
    print(f"     Total Salida en kardex: {mov_problema['Total Salida']:.10f}")
    print(f"     Diferencia: {total_salida_calc - mov_problema['Total Salida']:.10f}")
    print()

    # CAUSA RAÍZ
    print("=" * 120)
    print("CAUSA RAÍZ DEL PROBLEMA")
    print("=" * 120)
    print()

    if total_salida_calc != mov_problema['Total Salida']:
        print("PROBLEMA IDENTIFICADO:")
        print()
        print(f"  El Total Salida en el kardex ({mov_problema['Total Salida']:.5f}) NO coincide con")
        print(f"  el cálculo: Cantidad × Costo = {mov_problema['Cantidad Salida']:.3f} × {mov_problema['Costo Salida']:.5f} = {total_salida_calc:.5f}")
        print()
        print("  CORRECCIÓN NECESARIA:")
        print(f"    El campo 'Total Salida' en InventarioDet2 debe ser: {total_salida_calc:.10f}")
        print(f"    Actualmente es: {mov_problema['Total Salida']:.10f}")
        print(f"    Diferencia: {mov_problema['Total Salida'] - total_salida_calc:.10f}")
        print()
        print("  Esto causará que el Saldo Total quede en:")
        saldo_total_correcto = anterior['Saldo Total'] - total_salida_calc
        print(f"    {anterior['Saldo Total']:.5f} - {total_salida_calc:.5f} = {saldo_total_correcto:.5f}")
        print()

        if abs(saldo_total_correcto) < 0.01:
            print("  RESULTADO: Con esta corrección, el Saldo Total quedará en ~0 (correcto)")
        else:
            print(f"  ADVERTENCIA: Aún quedará un Saldo Total de {saldo_total_correcto:.5f}")
    else:
        print("El Total Salida es correcto.")
        print()
        print("El Saldo Total negativo se debe a que:")
        print(f"  Saldo Total anterior: {anterior['Saldo Total']:.5f}")
        print(f"  Total Salida: {mov_problema['Total Salida']:.5f}")
        print(f"  Diferencia: {anterior['Saldo Total']:.5f} - {mov_problema['Total Salida']:.5f} = {total_esperado:.5f}")
        print()
        print("Esto indica que el valor del inventario anterior era insuficiente para cubrir esta salida.")
