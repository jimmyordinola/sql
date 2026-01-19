import pandas as pd

# Leer CSV
df = pd.read_csv(r"d:\nuvol\sp\kardex_cremolada.csv", encoding='utf-8-sig', skiprows=3)

# Filtrar movimientos válidos
df = df[df['Codigo Inventario'].notna() & df['Codigo Inventario'].str.startswith('INV', na=False)].copy()

# Convertir columnas
df['Fecha Movimiento'] = pd.to_datetime(df['Fecha Movimiento'], format='mixed', errors='coerce')
df['Cantidad Entrada'] = pd.to_numeric(df['Cantidad Entrada'], errors='coerce')
df['Costo Entrada'] = pd.to_numeric(df['Costo Entrada'], errors='coerce')
df['Total Entrada'] = pd.to_numeric(df['Total Entrada'], errors='coerce')
df['Saldo Cantidad'] = pd.to_numeric(df['Saldo Cantidad'], errors='coerce')
df['Saldo Costo'] = pd.to_numeric(df['Saldo Costo'], errors='coerce')
df['Saldo Total'] = pd.to_numeric(df['Saldo Total'], errors='coerce')
df['Tipo Operacion'] = pd.to_numeric(df['Tipo Operacion'], errors='coerce')
df['Movimiento'] = df['Movimiento'].str.strip()

print("=" * 120)
print("ANÁLISIS DE ENTRADAS DE PRODUCCIÓN - COSTOS BAJOS PROBLEMÁTICOS")
print("=" * 120)
print()

# Filtrar entradas de producción (Tipo 54)
entradas_prod = df[(df['Movimiento'] == 'Entrada') & (df['Tipo Operacion'] == 54)].copy()

print(f"Total de entradas de producción (Tipo 54): {len(entradas_prod)}")
print()

# Mostrar todas las entradas de producción ordenadas por costo
print("=" * 120)
print("TODAS LAS ENTRADAS DE PRODUCCIÓN ORDENADAS POR COSTO")
print("=" * 120)
entradas_prod_sorted = entradas_prod.sort_values('Costo Entrada')

cols = ['Fecha Movimiento', 'Codigo Inventario', 'Cantidad Entrada', 'Costo Entrada',
        'Total Entrada', 'Saldo Cantidad', 'Saldo Costo', 'Saldo Total']

print(entradas_prod_sorted[cols].to_string(index=False))
print()

# Identificar costos anormalmente bajos
print("=" * 120)
print("ENTRADAS CON COSTOS ANORMALMENTE BAJOS (< 10)")
print("=" * 120)
costos_bajos = entradas_prod[entradas_prod['Costo Entrada'] < 10].copy()

if len(costos_bajos) > 0:
    print(f"Encontradas {len(costos_bajos)} entradas con costo < 10:")
    print()

    for idx, row in costos_bajos.iterrows():
        print(f"Fecha: {row['Fecha Movimiento']}")
        print(f"Documento: {row['Codigo Inventario']}")
        print(f"Cantidad: {row['Cantidad Entrada']}")
        print(f"Costo: {row['Costo Entrada']:.5f} <<< ANORMALMENTE BAJO")
        print(f"Total: {row['Total Entrada']:.2f}")
        print(f"Registro Contable: {row['Registro Contable']}")
        print(f"Saldo después: {row['Saldo Cantidad']} unidades × {row['Saldo Costo']:.5f} = S/ {row['Saldo Total']:.2f}")
        print("-" * 120)
        print()
else:
    print("No se encontraron entradas con costo < 10")
print()

# Ver el impacto de estas entradas en el saldo
print("=" * 120)
print("IMPACTO DE ENTRADAS CON COSTOS BAJOS EN EL KARDEX")
print("=" * 120)

if len(costos_bajos) > 0:
    for idx, row in costos_bajos.iterrows():
        # Buscar el contexto: 5 movimientos antes y 10 después
        pos = df.index.get_loc(idx)
        inicio = max(0, pos - 5)
        fin = min(len(df), pos + 11)

        contexto = df.iloc[inicio:fin].copy()

        print(f"\nCONTEXTO DE ENTRADA CON COSTO {row['Costo Entrada']:.5f} el {row['Fecha Movimiento']}")
        print("=" * 120)

        cols_ctx = ['Fecha Movimiento', 'Codigo Inventario', 'Movimiento', 'Cantidad Entrada',
                    'Costo Entrada', 'Cantidad Salida', 'Saldo Cantidad', 'Saldo Costo', 'Saldo Total']

        for i, (idx_ctx, row_ctx) in enumerate(contexto.iterrows()):
            marca = " >>> ENTRADA PROBLEMÁTICA <<<" if idx_ctx == idx else ""
            print(f"{i}: {row_ctx['Fecha Movimiento']} | {row_ctx['Movimiento']:7} | "
                  f"E:{row_ctx['Cantidad Entrada']:6.2f} S:{row_ctx['Cantidad Salida']:6.2f} | "
                  f"Costo:{row_ctx['Costo Entrada'] if row_ctx['Movimiento'] == 'Entrada' else 0:8.5f} | "
                  f"Saldo:{row_ctx['Saldo Cantidad']:6.2f} × {row_ctx['Saldo Costo']:8.5f} = {row_ctx['Saldo Total']:10.2f}"
                  f"{marca}")
        print()

# Estadísticas de costos de producción
print("=" * 120)
print("ESTADÍSTICAS DE COSTOS DE PRODUCCIÓN")
print("=" * 120)
print(f"Costo mínimo: {entradas_prod['Costo Entrada'].min():.5f}")
print(f"Costo máximo: {entradas_prod['Costo Entrada'].max():.5f}")
print(f"Costo promedio: {entradas_prod['Costo Entrada'].mean():.5f}")
print(f"Costo mediana: {entradas_prod['Costo Entrada'].median():.5f}")
print()

# Ver si hay un patrón en los costos
print("Distribución de costos:")
print(entradas_prod['Costo Entrada'].describe())
print()

# Verificar si los costos bajos coinciden con fechas específicas
print("=" * 120)
print("ANÁLISIS TEMPORAL DE COSTOS BAJOS")
print("=" * 120)
if len(costos_bajos) > 0:
    print("Fechas con costos anormalmente bajos:")
    for fecha in costos_bajos['Fecha Movimiento'].sort_values():
        print(f"  - {fecha}")
    print()
    print("POSIBLE CAUSA: Estos podrían ser:")
    print("  1. Errores de captura en el costo de producción")
    print("  2. Costos de materia prima incorrectos")
    print("  3. Problemas en el cálculo del costo de producción")
    print("  4. Órdenes de producción con datos incompletos")
