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
df['Cantidad Salida'] = pd.to_numeric(df['Cantidad Salida'], errors='coerce')
df['Cantidad Entrada'] = pd.to_numeric(df['Cantidad Entrada'], errors='coerce')
df['Movimiento'] = df['Movimiento'].str.strip()

print("=" * 100)
print("ANÁLISIS DE SALDOS NEGATIVOS EN KARDEX")
print("=" * 100)
print()

# Identificar registros con saldos negativos
negativos = df[df['Saldo Cantidad'] < 0].copy()

if len(negativos) > 0:
    print(f"PROBLEMA: Se encontraron {len(negativos)} registros con SALDO NEGATIVO")
    print()
    print("=" * 100)
    print("DETALLE DE MOVIMIENTOS CON SALDO NEGATIVO:")
    print("=" * 100)

    columnas = ['Fecha Movimiento', 'Codigo Inventario', 'Movimiento',
                'Cantidad Entrada', 'Cantidad Salida', 'Saldo Cantidad', 'Saldo Costo', 'Saldo Total']

    print(negativos[columnas].to_string(index=False))
    print()

    # Ver el contexto: 5 movimientos antes del primer negativo
    if len(negativos) > 0:
        idx_primer_negativo = negativos.index[0]
        inicio = max(0, idx_primer_negativo - 5)
        fin = min(len(df), idx_primer_negativo + 10)

        print("=" * 100)
        print("CONTEXTO DEL PRIMER SALDO NEGATIVO (5 movimientos antes y 9 después):")
        print("=" * 100)
        contexto = df.iloc[inicio:fin][columnas]
        print(contexto.to_string(index=True))
        print()

        # Marcar el movimiento problemático
        print(f"\n>>> Primer saldo negativo en índice {idx_primer_negativo}")
        print(f">>> Fecha: {df.iloc[idx_primer_negativo]['Fecha Movimiento']}")
        print(f">>> Documento: {df.iloc[idx_primer_negativo]['Codigo Inventario']}")
        print()
else:
    print("OK: No se encontraron saldos negativos")
    print()

# Verificar saldos muy cercanos a cero o negativos
print("=" * 100)
print("MOVIMIENTOS CON SALDOS CERCANOS A CERO (< 1)")
print("=" * 100)
cercanos_cero = df[(df['Saldo Cantidad'] >= -0.01) & (df['Saldo Cantidad'] < 1)].copy()
print(f"Encontrados: {len(cercanos_cero)} movimientos")
print()
if len(cercanos_cero) > 0:
    print(cercanos_cero[['Fecha Movimiento', 'Codigo Inventario', 'Movimiento', 'Saldo Cantidad']].to_string(index=False))
print()

# Análisis de almacenes
print("=" * 100)
print("ANÁLISIS POR ALMACÉN")
print("=" * 100)
df['Nom. Almacen'] = df['Nom. Almacen'].str.strip()
almacenes = df.groupby('Nom. Almacen').agg({
    'Cantidad Entrada': 'sum',
    'Cantidad Salida': 'sum',
    'Saldo Cantidad': 'last'
}).reset_index()

almacenes['Diferencia'] = almacenes['Cantidad Entrada'] - almacenes['Cantidad Salida']

print(almacenes.to_string(index=False))
print()

# Verificar si es un problema de ordenamiento
print("=" * 100)
print("VERIFICACIÓN DE ORDENAMIENTO DE MOVIMIENTOS")
print("=" * 100)
print("Primer movimiento:", df.iloc[0]['Fecha Movimiento'])
print("Último movimiento:", df.iloc[-1]['Fecha Movimiento'])
print()

# Verificar si hay saltos en fechas
fechas = df['Fecha Movimiento'].dropna()
print(f"Total de movimientos con fecha válida: {len(fechas)}")
print(f"Rango de fechas: {fechas.min()} a {fechas.max()}")
print()

# Buscar salidas que excedan el saldo disponible
print("=" * 100)
print("SALIDAS QUE PODRÍAN CAUSAR PROBLEMAS")
print("=" * 100)

salidas_grandes = df[df['Movimiento'] == 'Salida'].copy()
salidas_grandes['Saldo_Previo'] = salidas_grandes['Saldo Cantidad'] + salidas_grandes['Cantidad Salida']

# Salidas que dejaron saldo negativo o muy bajo
problematicas = salidas_grandes[salidas_grandes['Saldo Cantidad'] < 1].copy()

if len(problematicas) > 0:
    print(f"Encontradas {len(problematicas)} salidas que dejaron saldo < 1:")
    print()
    cols_prob = ['Fecha Movimiento', 'Codigo Inventario', 'Cantidad Salida', 'Saldo_Previo', 'Saldo Cantidad']
    print(problematicas[cols_prob].to_string(index=False))
else:
    print("No se encontraron salidas problemáticas")

print()
print("=" * 100)
print("FIN DEL ANÁLISIS")
print("=" * 100)
