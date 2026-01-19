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
df['Tipo Operacion'] = pd.to_numeric(df['Tipo Operacion'], errors='coerce')
df['Movimiento'] = df['Movimiento'].str.strip()

print("=" * 100)
print("ANÁLISIS DEL KARDEX - LIMÓN V2 (CORREGIDO)")
print("=" * 100)
print()

print(f"Total de movimientos: {len(df)}")
print(f"Período: {df['Fecha Movimiento'].min()} a {df['Fecha Movimiento'].max()}")
print()

# Separar entradas y salidas
entradas = df[df['Movimiento'] == 'Entrada'].copy()
salidas = df[df['Movimiento'] == 'Salida'].copy()

print("=" * 100)
print("RESUMEN")
print("=" * 100)
print(f"Total ENTRADAS: {len(entradas)} movimientos")
print(f"  Cantidad total: {entradas['Cantidad Entrada'].sum():.2f} kg")
print(f"  Valor total: S/ {entradas['Total Entrada'].sum():.2f}")
print()
print(f"Total SALIDAS: {len(salidas)} movimientos")
print(f"  Cantidad total: {salidas['Cantidad Salida'].sum():.2f} kg")
print(f"  Valor total: S/ {salidas['Total Salida'].sum():.2f}")
print()

# ANÁLISIS DE VALORES NEGATIVOS
print("=" * 100)
print("ANÁLISIS DE VALORES NEGATIVOS")
print("=" * 100)

# 1. Saldos de Cantidad negativos
negativos_cant = df[df['Saldo Cantidad'] < 0]
print(f"1. Saldos de CANTIDAD negativos: {len(negativos_cant)}")
if len(negativos_cant) > 0:
    print(negativos_cant[['Fecha Movimiento', 'Codigo Inventario', 'Nom. Almacen', 'Saldo Cantidad']].to_string(index=False))
print()

# 2. Saldos de Costo negativos
cols = ['Fecha Movimiento', 'Codigo Inventario', 'Nom. Almacen', 'Movimiento', 'Cantidad Entrada',
        'Costo Entrada', 'Cantidad Salida', 'Saldo Cantidad', 'Saldo Costo', 'Saldo Total']

negativos_costo = df[df['Saldo Costo'] < 0]
print(f"2. Saldos de COSTO negativos: {len(negativos_costo)}")
if len(negativos_costo) > 0:
    print()
    print("DETALLE:")
    print(negativos_costo[cols].to_string(index=False))
print()

# 3. Saldos Totales negativos
negativos_total = df[df['Saldo Total'] < 0]
print(f"3. Saldos TOTALES negativos: {len(negativos_total)}")
if len(negativos_total) > 0:
    print()
    print("DETALLE:")
    print(negativos_total[cols].to_string(index=False))
print()

# 4. Saldos de Costo anormalmente altos (> 100)
costo_alto = df[df['Saldo Costo'] > 100]
print(f"4. Saldos de COSTO anormalmente altos (> 100): {len(costo_alto)}")
if len(costo_alto) > 0:
    print()
    print("DETALLE:")
    print(costo_alto[cols].to_string(index=False))
print()

# ANÁLISIS ESPECÍFICO: ALMACEN FABRICA(INSUMOS)
print("=" * 100)
print("ANÁLISIS ESPECÍFICO: ALMACEN FABRICA(INSUMOS)")
print("=" * 100)

df_fabrica = df[df['Nom. Almacen'].str.strip() == 'ALMACEN FABRICA(INSUMOS)'].copy()
print(f"Total de movimientos en ALMACEN FABRICA(INSUMOS): {len(df_fabrica)}")
print()

if len(df_fabrica) > 0:
    # Buscar el documento corregido
    doc_corregido = df_fabrica[df_fabrica['Codigo Inventario'] == 'INV000297372']

    if len(doc_corregido) > 0:
        print("DOCUMENTO CORREGIDO: INV000297372")
        print("-" * 100)
        row = doc_corregido.iloc[0]
        print(f"  Fecha: {row['Fecha Movimiento']}")
        print(f"  Tipo: {row['Movimiento']}")
        print(f"  Cantidad Salida: {row['Cantidad Salida']:.6f} kg")
        print(f"  Costo Salida: {row['Costo Salida']:.10f}")
        print(f"  Total Salida: {row['Total Salida']:.10f}")
        print(f"  Saldo Cantidad: {row['Saldo Cantidad']:.6f} kg")
        print(f"  Saldo Costo: {row['Saldo Costo']:.10f}")
        print(f"  Saldo Total: {row['Saldo Total']:.10f}")
        print()

        if row['Cantidad Salida'] == 22.397:
            print("  OK: CORREGIDO - La cantidad de salida es ahora 22.397 kg")
        else:
            print(f"  ERROR: NO CORREGIDO - La cantidad de salida sigue siendo {row['Cantidad Salida']:.3f} kg")
        print()

    # Últimos 5 movimientos
    print("ÚLTIMOS 5 MOVIMIENTOS EN ALMACEN FABRICA(INSUMOS):")
    print("-" * 100)
    ultimos = df_fabrica.tail(5)
    for idx, row in ultimos.iterrows():
        tipo = row['Movimiento'][:1]
        if tipo == 'E':
            print(f"{row['Fecha Movimiento']} | ENTRADA {row['Cantidad Entrada']:8.3f} kg | "
                  f"Saldo: {row['Saldo Cantidad']:8.3f} kg × {row['Saldo Costo']:10.5f} = {row['Saldo Total']:12.5f}")
        else:
            print(f"{row['Fecha Movimiento']} | SALIDA  {row['Cantidad Salida']:8.3f} kg | "
                  f"Saldo: {row['Saldo Cantidad']:8.3f} kg × {row['Saldo Costo']:10.5f} = {row['Saldo Total']:12.5f}")
    print()

# RESUMEN FINAL
print("=" * 100)
print("RESUMEN DE PROBLEMAS")
print("=" * 100)
print(f"Saldos de cantidad negativos: {len(negativos_cant)}")
print(f"Saldos de costo negativos: {len(negativos_costo)}")
print(f"Saldos totales negativos: {len(negativos_total)}")
print(f"Saldos de costo anormalmente altos (> 100): {len(costo_alto)}")
print()

if len(negativos_cant) == 0 and len(negativos_costo) == 0 and len(negativos_total) == 0 and len(costo_alto) == 0:
    print("RESULTADO: OK - Kardex CORREGIDO - No se encontraron problemas")
else:
    print("RESULTADO: ATENCION - Kardex con problemas pendientes")
