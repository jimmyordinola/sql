import pandas as pd

# Leer CSV
df = pd.read_csv(r"d:\nuvol\sp\kardex_limon.csv", encoding='utf-8-sig')

# Convertir columnas con alta precisión
df['Fecha Movimiento'] = pd.to_datetime(df['Fecha Movimiento'], format='mixed', errors='coerce')
df['Cantidad Entrada'] = pd.to_numeric(df['Cantidad Entrada'], errors='coerce')
df['Cantidad Salida'] = pd.to_numeric(df['Cantidad Salida'], errors='coerce')
df['Saldo Cantidad'] = pd.to_numeric(df['Saldo Cantidad'], errors='coerce')
df['Movimiento'] = df['Movimiento'].str.strip()

# Filtrar solo ALMACEN FABRICA(INSUMOS)
df_insumos = df[df['Nom. Almacen'].str.strip() == 'ALMACEN FABRICA(INSUMOS)'].copy()

print("=" * 120)
print("ANÁLISIS DETALLADO DEL -0.003 KG EN ALMACEN FABRICA(INSUMOS)")
print("=" * 120)
print()

print(f"Total de movimientos en ALMACEN FABRICA(INSUMOS): {len(df_insumos)}")
print()

# Recalcular saldo con máxima precisión
print("=" * 120)
print("RECALCULANDO SALDO CON PRECISIÓN DECIMAL")
print("=" * 120)
print()

saldo = 0.0
movimientos_detalle = []

for idx, row in df_insumos.iterrows():
    saldo_antes = saldo

    if row['Movimiento'] == 'Entrada':
        cantidad = row['Cantidad Entrada']
        saldo += cantidad
        tipo = 'E'
    else:
        cantidad = row['Cantidad Salida']
        saldo -= cantidad
        tipo = 'S'

    saldo_kardex = row['Saldo Cantidad']
    diferencia = saldo - saldo_kardex

    movimientos_detalle.append({
        'idx': idx,
        'fecha': row['Fecha Movimiento'],
        'tipo': tipo,
        'cantidad': cantidad,
        'saldo_antes': saldo_antes,
        'saldo_calculado': saldo,
        'saldo_kardex': saldo_kardex,
        'diferencia': diferencia,
        'documento': row['Codigo Inventario']
    })

# Mostrar todos los movimientos con diferencias
print(f"{'#':>3} {'Fecha':<20} {'T':>1} {'Cantidad':>10} {'Saldo Antes':>12} {'Saldo Calc':>12} {'Saldo Kardex':>12} {'Diferencia':>12} {'Documento':<15}")
print("-" * 120)

for i, mov in enumerate(movimientos_detalle):
    diferencia_str = f"{mov['diferencia']:.6f}"
    if abs(mov['diferencia']) > 0.0001:
        diferencia_str = f"*** {mov['diferencia']:.6f} ***"

    print(f"{i+1:3d} {str(mov['fecha']):<20} {mov['tipo']:>1} {mov['cantidad']:>10.4f} {mov['saldo_antes']:>12.6f} "
          f"{mov['saldo_calculado']:>12.6f} {mov['saldo_kardex']:>12.6f} {diferencia_str:>12} {mov['documento']:<15}")

print()

# Encontrar el movimiento con saldo negativo
negativo_mov = [m for m in movimientos_detalle if m['saldo_kardex'] < 0]

if len(negativo_mov) > 0:
    print("=" * 120)
    print("MOVIMIENTO CON SALDO NEGATIVO")
    print("=" * 120)
    mov_neg = negativo_mov[0]
    print(f"Fecha: {mov_neg['fecha']}")
    print(f"Documento: {mov_neg['documento']}")
    print(f"Tipo: {'Entrada' if mov_neg['tipo'] == 'E' else 'Salida'}")
    print(f"Cantidad: {mov_neg['cantidad']:.6f} kg")
    print(f"Saldo ANTES: {mov_neg['saldo_antes']:.6f} kg")
    print(f"Saldo CALCULADO: {mov_neg['saldo_calculado']:.6f} kg")
    print(f"Saldo KARDEX: {mov_neg['saldo_kardex']:.6f} kg")
    print(f"Diferencia: {mov_neg['diferencia']:.6f} kg")
    print()

    # Análisis de la diferencia
    print("ANÁLISIS DE LA DIFERENCIA:")
    print(f"  Operación esperada: {mov_neg['saldo_antes']:.6f} - {mov_neg['cantidad']:.6f} = {mov_neg['saldo_calculado']:.6f} kg")
    print(f"  Resultado en kardex: {mov_neg['saldo_kardex']:.6f} kg")
    print(f"  Discrepancia: {mov_neg['diferencia']:.6f} kg")
    print()

    # Ver si la diferencia coincide con algún movimiento anterior
    print("¿De dónde sale el -0.003?")
    print()

    # Buscar si hay algún movimiento con cantidad cercana a 0.003
    for i, mov in enumerate(movimientos_detalle):
        if abs(mov['cantidad'] - 0.003) < 0.001:
            print(f"  Movimiento {i+1}: {mov['tipo']} de {mov['cantidad']:.6f} kg el {mov['fecha']}")

    # Buscar si hay diferencias acumuladas
    print()
    print("DIFERENCIAS ACUMULADAS:")
    diferencia_acum = 0.0
    for i, mov in enumerate(movimientos_detalle):
        if abs(mov['diferencia']) > 0.0001:
            diferencia_acum += mov['diferencia']
            print(f"  Movimiento {i+1}: Diferencia {mov['diferencia']:.6f} kg (Acumulado: {diferencia_acum:.6f} kg)")

print()
print("=" * 120)
print("RESUMEN")
print("=" * 120)
print(f"Saldo final CALCULADO: {saldo:.6f} kg")
print(f"Saldo final KARDEX: {df_insumos.iloc[-1]['Saldo Cantidad']:.6f} kg")
print(f"Diferencia total: {saldo - df_insumos.iloc[-1]['Saldo Cantidad']:.6f} kg")
print()

# Calcular suma total de entradas y salidas
total_entradas = df_insumos[df_insumos['Movimiento'] == 'Entrada']['Cantidad Entrada'].sum()
total_salidas = df_insumos[df_insumos['Movimiento'] == 'Salida']['Cantidad Salida'].sum()

print(f"Total ENTRADAS: {total_entradas:.6f} kg")
print(f"Total SALIDAS: {total_salidas:.6f} kg")
print(f"Diferencia (E-S): {total_entradas - total_salidas:.6f} kg")
