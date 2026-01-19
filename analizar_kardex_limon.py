import pandas as pd

# Leer CSV
df = pd.read_csv(r"d:\nuvol\sp\kardex_limon.csv", encoding='utf-8-sig')

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
print("ANÁLISIS DEL KARDEX - LIMÓN (PD00534)")
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
    print(negativos_cant[['Fecha Movimiento', 'Codigo Inventario', 'Saldo Cantidad']].to_string(index=False))
print()

# 2. Saldos de Costo negativos
cols = ['Fecha Movimiento', 'Codigo Inventario', 'Movimiento', 'Cantidad Entrada',
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

# ANÁLISIS DE COSTOS
print("=" * 100)
print("ANÁLISIS DE COSTOS EN ENTRADAS")
print("=" * 100)
costos_entrada = entradas['Costo Entrada'].dropna()
print(f"Costos únicos: {len(costos_entrada.unique())}")
print(f"Rango: {costos_entrada.min():.5f} a {costos_entrada.max():.5f}")
print(f"Promedio: {costos_entrada.mean():.5f}")
print()

# Costos anormalmente bajos
costos_bajos = entradas[entradas['Costo Entrada'] < 2].copy()
if len(costos_bajos) > 0:
    print(f"ENTRADAS CON COSTO ANORMALMENTE BAJO (< 2):")
    print(f"Total: {len(costos_bajos)}")
    print()
    cols_e = ['Fecha Movimiento', 'Codigo Inventario', 'Registro Contable', 'Cantidad Entrada',
              'Costo Entrada', 'Total Entrada', 'Tipo Operacion', 'Nombre Tipo Operacion']
    print(costos_bajos[cols_e].to_string(index=False))
    print()

# ANÁLISIS DE COSTOS EN SALIDAS
print("=" * 100)
print("ANÁLISIS DE COSTOS EN SALIDAS")
print("=" * 100)
costos_salida = salidas['Costo Salida'].dropna()
costos_salida_unicos = costos_salida.unique()
print(f"Costos únicos: {len(costos_salida_unicos)}")
print(f"Rango: {costos_salida.min():.5f} a {costos_salida.max():.5f}")
print()

# Verificar si hay costo fijo predominante
if len(costos_salida_unicos) <= 5:
    print("PROBLEMA: Muy pocos costos diferentes en salidas")
    print()
    for costo in sorted(costos_salida_unicos):
        cantidad = len(salidas[salidas['Costo Salida'] == costo])
        porcentaje = (cantidad / len(salidas)) * 100
        print(f"  Costo {costo:.5f}: {cantidad} salidas ({porcentaje:.1f}%)")
else:
    print("OK: Costos variables en salidas")
print()

# RESUMEN FINAL
print("=" * 100)
print("RESUMEN DE PROBLEMAS")
print("=" * 100)
print(f"Saldos de cantidad negativos: {len(negativos_cant)}")
print(f"Saldos de costo negativos: {len(negativos_costo)}")
print(f"Saldos totales negativos: {len(negativos_total)}")
print(f"Entradas con costo bajo (< 2): {len(costos_bajos) if len(costos_bajos) > 0 else 0}")
print()

if len(negativos_cant) > 0 or len(negativos_costo) > 0 or len(negativos_total) > 0:
    print("RESULTADO: Se encontraron problemas que requieren atención")
else:
    print("RESULTADO: Kardex sin problemas críticos")
