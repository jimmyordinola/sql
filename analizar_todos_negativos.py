import pandas as pd

# Leer CSV
df = pd.read_csv(r"d:\nuvol\sp\kardex_cremolada.csv", encoding='utf-8-sig', skiprows=3)

# Filtrar movimientos válidos
df = df[df['Codigo Inventario'].notna() & df['Codigo Inventario'].str.startswith('INV', na=False)].copy()

# Convertir columnas
df['Fecha Movimiento'] = pd.to_datetime(df['Fecha Movimiento'], format='mixed', errors='coerce')
df['Saldo Cantidad'] = pd.to_numeric(df['Saldo Cantidad'], errors='coerce')
df['Saldo Costo'] = pd.to_numeric(df['Saldo Costo'], errors='coerce')
df['Saldo Total'] = pd.to_numeric(df['Saldo Total'], errors='coerce')
df['Costo Salida'] = pd.to_numeric(df['Costo Salida'], errors='coerce')
df['Costo Entrada'] = pd.to_numeric(df['Costo Entrada'], errors='coerce')
df['Cantidad Salida'] = pd.to_numeric(df['Cantidad Salida'], errors='coerce')
df['Cantidad Entrada'] = pd.to_numeric(df['Cantidad Entrada'], errors='coerce')

print("=" * 100)
print("ANÁLISIS COMPLETO DE VALORES NEGATIVOS EN KARDEX")
print("=" * 100)
print()

# 1. Saldos de Cantidad negativos
print("1. SALDOS DE CANTIDAD NEGATIVOS")
print("-" * 100)
negativos_cant = df[df['Saldo Cantidad'] < 0]
print(f"Total: {len(negativos_cant)}")
if len(negativos_cant) > 0:
    print(negativos_cant[['Fecha Movimiento', 'Codigo Inventario', 'Saldo Cantidad']].to_string(index=False))
else:
    print("OK - No hay saldos de cantidad negativos")
print()

# 2. Saldos de Costo negativos
print("2. SALDOS DE COSTO NEGATIVOS")
print("-" * 100)
negativos_costo = df[df['Saldo Costo'] < 0]
print(f"Total: {len(negativos_costo)}")
if len(negativos_costo) > 0:
    print(negativos_costo[['Fecha Movimiento', 'Codigo Inventario', 'Saldo Cantidad', 'Saldo Costo']].to_string(index=False))
else:
    print("OK - No hay saldos de costo negativos")
print()

# 3. Saldos Totales negativos (valor total del inventario)
print("3. SALDOS TOTALES NEGATIVOS (Valor en dinero)")
print("-" * 100)
negativos_total = df[df['Saldo Total'] < 0]
print(f"Total: {len(negativos_total)}")
if len(negativos_total) > 0:
    print("\nDETALLE DE SALDOS TOTALES NEGATIVOS:")
    cols = ['Fecha Movimiento', 'Codigo Inventario', 'Movimiento', 'Cantidad Entrada',
            'Cantidad Salida', 'Saldo Cantidad', 'Saldo Costo', 'Saldo Total']
    print(negativos_total[cols].to_string(index=False))

    print("\n" + "=" * 100)
    print("CONTEXTO DEL PRIMER SALDO TOTAL NEGATIVO:")
    print("=" * 100)
    if len(negativos_total) > 0:
        idx_primer_neg = negativos_total.index[0]
        inicio = max(0, idx_primer_neg - 10)
        fin = min(len(df), idx_primer_neg + 5)

        contexto = df.iloc[inicio:fin].copy()
        print(contexto[cols].to_string(index=True))
        print(f"\n>>> PRIMER NEGATIVO EN ÍNDICE: {idx_primer_neg}")
        print(f"    Fecha: {df.iloc[idx_primer_neg]['Fecha Movimiento']}")
        print(f"    Documento: {df.iloc[idx_primer_neg]['Codigo Inventario']}")
        print(f"    Saldo Cantidad: {df.iloc[idx_primer_neg]['Saldo Cantidad']}")
        print(f"    Saldo Costo: {df.iloc[idx_primer_neg]['Saldo Costo']}")
        print(f"    Saldo Total: {df.iloc[idx_primer_neg]['Saldo Total']}")
else:
    print("OK - No hay saldos totales negativos")
print()

# 4. Costos de salida = 0 o negativos
print("4. COSTOS DE SALIDA CERO O NEGATIVOS")
print("-" * 100)
salidas = df[df['Cantidad Salida'] > 0]
costos_cero_neg = salidas[(salidas['Costo Salida'] <= 0)]
print(f"Total: {len(costos_cero_neg)}")
if len(costos_cero_neg) > 0:
    print(costos_cero_neg[['Fecha Movimiento', 'Codigo Inventario', 'Cantidad Salida',
                            'Costo Salida', 'Saldo Cantidad']].to_string(index=False))
else:
    print("OK - Todos los costos de salida son positivos")
print()

# 5. Resumen general
print("=" * 100)
print("RESUMEN")
print("=" * 100)
print(f"Total de movimientos analizados: {len(df)}")
print(f"Saldos de cantidad negativos: {len(negativos_cant)}")
print(f"Saldos de costo negativos: {len(negativos_costo)}")
print(f"Saldos totales negativos: {len(negativos_total)}")
print(f"Costos de salida cero/negativos: {len(costos_cero_neg)}")
print()

if len(negativos_cant) == 0 and len(negativos_costo) == 0 and len(negativos_total) == 0 and len(costos_cero_neg) == 0:
    print("RESULTADO: Kardex sin problemas de valores negativos")
else:
    print("RESULTADO: Se encontraron problemas que requieren atención")
