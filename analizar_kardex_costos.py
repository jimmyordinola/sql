import pandas as pd

# Leer CSV saltando las primeras 3 líneas (encabezados)
df = pd.read_csv(r"d:\nuvol\sp\kardex_cremolada.csv", encoding='utf-8-sig', skiprows=3)

# Filtrar solo movimientos válidos
df = df[df['Codigo Inventario'].notna() & df['Codigo Inventario'].str.startswith('INV', na=False)].copy()

# Convertir columnas numéricas
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

# Limpiar espacios
df['Movimiento'] = df['Movimiento'].str.strip()

print("=" * 100)
print("ANÁLISIS DETALLADO DEL KARDEX - CREMOLADA POR BOLSA (PD00489)")
print("=" * 100)
print()

print(f"Total de movimientos procesados: {len(df)}")
print(f"Período: {df['Fecha Movimiento'].min()} a {df['Fecha Movimiento'].max()}")
print()

# Separar entradas y salidas
entradas = df[df['Movimiento'] == 'Entrada'].copy()
salidas = df[df['Movimiento'] == 'Salida'].copy()

print("=" * 100)
print("RESUMEN")
print("=" * 100)
print(f"Total ENTRADAS: {len(entradas)} movimientos")
print(f"  Cantidad total: {entradas['Cantidad Entrada'].sum():.2f} unidades")
print(f"  Valor total: S/ {entradas['Total Entrada'].sum():.2f}")
print()
print(f"Total SALIDAS: {len(salidas)} movimientos")
print(f"  Cantidad total: {salidas['Cantidad Salida'].sum():.2f} unidades")
print(f"  Valor total: S/ {salidas['Total Salida'].sum():.2f}")
print()

# Análisis de costos en ENTRADAS
print("=" * 100)
print("ANÁLISIS DE COSTOS EN ENTRADAS")
print("=" * 100)
costos_entrada = entradas['Costo Entrada'].dropna()
print(f"Costos únicos: {len(costos_entrada.unique())}")
print(f"Rango de costos: {costos_entrada.min():.5f} a {costos_entrada.max():.5f}")
print()
print("Top 10 costos más frecuentes:")
top_costos = costos_entrada.value_counts().head(10)
for costo, cantidad in top_costos.items():
    print(f"  {costo:.5f}: {cantidad} movimientos")
print()

# Análisis de costos en SALIDAS - AQUÍ ESTÁ EL PROBLEMA
print("=" * 100)
print("ANÁLISIS DE COSTOS EN SALIDAS")
print("=" * 100)
costos_salida = salidas['Costo Salida'].dropna()
costos_salida_unicos = costos_salida.unique()
print(f"Costos únicos: {len(costos_salida_unicos)}")

if len(costos_salida_unicos) <= 5:
    print()
    print("PROBLEMA DETECTADO: Muy pocos costos diferentes en salidas")
    print()
    print("Distribución de costos en salidas:")
    for costo in sorted(costos_salida_unicos):
        cantidad = len(salidas[salidas['Costo Salida'] == costo])
        porcentaje = (cantidad / len(salidas)) * 100
        print(f"  Costo {costo:.5f}: {cantidad} salidas ({porcentaje:.1f}%)")
    print()

    # Verificar si hay un costo predominante
    costo_predominante = costos_salida.mode()[0]
    salidas_con_costo_fijo = len(salidas[salidas['Costo Salida'].round(5) == round(costo_predominante, 5)])
    porcentaje_fijo = (salidas_con_costo_fijo / len(salidas)) * 100

    print(f"Costo predominante: {costo_predominante:.5f}")
    print(f"Salidas con este costo: {salidas_con_costo_fijo} de {len(salidas)} ({porcentaje_fijo:.1f}%)")
    print()
    print("CONCLUSION: Las salidas usan un costo FIJO en lugar de promedio ponderado")
else:
    print("OK: Las salidas usan costos variables (aparentemente correcto)")
print()

# Comparar primeras 20 salidas con sus costos
print("=" * 100)
print("PRIMERAS 20 SALIDAS - DETALLE DE COSTOS")
print("=" * 100)
salidas_detalle = salidas[[
    'Fecha Movimiento', 'Codigo Inventario', 'Cantidad Salida',
    'Costo Salida', 'Total Salida', 'Saldo Cantidad', 'Saldo Costo'
]].head(20)
print(salidas_detalle.to_string(index=False))
print()

# Verificar si hay salidas después del 2025-04-03 (cuando deberían cambiar los costos)
print("=" * 100)
print("SALIDAS POR FECHA (primeras del mes)")
print("=" * 100)
salidas_abril = salidas[salidas['Fecha Movimiento'] >= '2025-04-01'].copy()
salidas_abril = salidas_abril.sort_values('Fecha Movimiento')

print("\nPrimeras 30 salidas de abril 2025:")
print(salidas_abril[['Fecha Movimiento', 'Codigo Inventario', 'Cantidad Salida', 'Costo Salida']].head(30).to_string(index=False))
print()

# Verificar entradas de producción (que deberían tener costos variables)
print("=" * 100)
print("ENTRADAS DE PRODUCCIÓN (Tipo 54 - PT TERMINADO)")
print("=" * 100)
entradas_prod = entradas[entradas['Tipo Operacion'] == 54].copy()
if len(entradas_prod) > 0:
    print(f"Total entradas de producción: {len(entradas_prod)}")
    print()
    print("Detalle de entradas de producción:")
    print(entradas_prod[['Fecha Movimiento', 'Codigo Inventario', 'Cantidad Entrada', 'Costo Entrada', 'Saldo Costo']].to_string(index=False))
else:
    print("No se encontraron entradas con Tipo Operacion = 54")
    print("Buscando por nombre de operación...")
    entradas_prod = entradas[entradas['Nombre Tipo Operacion'].str.contains('TERMINADO', case=False, na=False)]
    if len(entradas_prod) > 0:
        print(f"Total entradas de producción (por nombre): {len(entradas_prod)}")
        print(entradas_prod[['Fecha Movimiento', 'Codigo Inventario', 'Cantidad Entrada', 'Costo Entrada', 'Nombre Tipo Operacion']].to_string(index=False))

print()
print("=" * 100)
print("FIN DEL ANÁLISIS")
print("=" * 100)
