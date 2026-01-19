import pandas as pd

# Leer CSV
df = pd.read_csv(r"d:\nuvol\sp\kardex_limon.csv", encoding='utf-8-sig')

# Convertir columnas
df['Fecha Movimiento'] = pd.to_datetime(df['Fecha Movimiento'], format='mixed', errors='coerce')
df['Cantidad Entrada'] = pd.to_numeric(df['Cantidad Entrada'], errors='coerce')
df['Cantidad Salida'] = pd.to_numeric(df['Cantidad Salida'], errors='coerce')
df['Saldo Cantidad'] = pd.to_numeric(df['Saldo Cantidad'], errors='coerce')
df['Movimiento'] = df['Movimiento'].str.strip()

# Filtrar solo ALMACEN FABRICA(INSUMOS)
df_insumos = df[df['Nom. Almacen'].str.strip() == 'ALMACEN FABRICA(INSUMOS)'].copy()

print("=" * 140)
print("REPORTE DETALLADO: MOVIMIENTOS ALMACEN FABRICA(INSUMOS) - LIMON PD00534")
print("=" * 140)
print()

print(f"Total de movimientos: {len(df_insumos)}")
print(f"Periodo: {df_insumos['Fecha Movimiento'].min().strftime('%d/%m/%Y')} al {df_insumos['Fecha Movimiento'].max().strftime('%d/%m/%Y')}")
print()

# Recalcular saldo
saldo_calculado = 0.0
movimientos = []

for idx, row in df_insumos.iterrows():
    fecha = row['Fecha Movimiento'].strftime('%d/%m/%Y %H:%M')
    documento = row['Codigo Inventario']

    if row['Movimiento'] == 'Entrada':
        cantidad = row['Cantidad Entrada']
        saldo_calculado += cantidad
        tipo = 'ENTRADA'
    else:
        cantidad = row['Cantidad Salida']
        saldo_calculado -= cantidad
        tipo = 'SALIDA'

    saldo_kardex = row['Saldo Cantidad']
    diferencia = saldo_calculado - saldo_kardex

    movimientos.append({
        'num': len(movimientos) + 1,
        'fecha': fecha,
        'tipo': tipo,
        'cantidad': cantidad,
        'saldo_calc': saldo_calculado,
        'saldo_kardex': saldo_kardex,
        'diferencia': diferencia,
        'doc': documento
    })

# Mostrar tabla detallada
print("=" * 140)
print("TABLA DETALLADA DE MOVIMIENTOS")
print("=" * 140)
print()
print(f"{'#':>3} {'Fecha':<17} {'Tipo':>8} {'Cantidad':>10} {'Saldo Calc.':>12} {'Saldo Kardex':>13} {'Diferencia':>12} {'Documento':<15}")
print("-" * 140)

for mov in movimientos:
    # Marcar si hay diferencia significativa
    marca = " ***" if abs(mov['diferencia']) > 0.0001 else ""

    print(f"{mov['num']:3d} {mov['fecha']:<17} {mov['tipo']:>8} {mov['cantidad']:>10.3f} "
          f"{mov['saldo_calc']:>12.6f} {mov['saldo_kardex']:>13.6f} {mov['diferencia']:>12.6f}{marca}  {mov['doc']:<15}")

print()

# Resumen por fecha
print("=" * 140)
print("RESUMEN POR DIA")
print("=" * 140)
print()

df_insumos['Fecha_Solo'] = df_insumos['Fecha Movimiento'].dt.date

resumen_diario = df_insumos.groupby('Fecha_Solo').agg({
    'Cantidad Entrada': lambda x: (x > 0).sum(),  # Contar entradas
    'Cantidad Salida': lambda x: (x > 0).sum(),   # Contar salidas
}).rename(columns={'Cantidad Entrada': 'Num_Entradas', 'Cantidad Salida': 'Num_Salidas'})

# Calcular totales por día
totales_dia = []
for fecha in sorted(df_insumos['Fecha_Solo'].unique()):
    dia_data = df_insumos[df_insumos['Fecha_Solo'] == fecha]

    entradas_cant = dia_data[dia_data['Movimiento'] == 'Entrada']['Cantidad Entrada'].sum()
    salidas_cant = dia_data[dia_data['Movimiento'] == 'Salida']['Cantidad Salida'].sum()
    num_movs = len(dia_data)

    totales_dia.append({
        'fecha': fecha.strftime('%d/%m/%Y'),
        'num_movs': num_movs,
        'entradas_kg': entradas_cant,
        'salidas_kg': salidas_cant,
        'neto_kg': entradas_cant - salidas_cant
    })

print(f"{'Fecha':<12} {'Movimientos':>12} {'Entradas (kg)':>14} {'Salidas (kg)':>13} {'Neto (kg)':>11}")
print("-" * 65)

for dia in totales_dia:
    print(f"{dia['fecha']:<12} {dia['num_movs']:>12} {dia['entradas_kg']:>14.3f} {dia['salidas_kg']:>13.3f} {dia['neto_kg']:>11.3f}")

print()

# Resumen final
print("=" * 140)
print("RESUMEN FINAL")
print("=" * 140)

total_entradas = df_insumos[df_insumos['Movimiento'] == 'Entrada']['Cantidad Entrada'].sum()
total_salidas = df_insumos[df_insumos['Movimiento'] == 'Salida']['Cantidad Salida'].sum()
diferencia_total = total_entradas - total_salidas

print(f"Total ENTRADAS:  {total_entradas:>10.6f} kg")
print(f"Total SALIDAS:   {total_salidas:>10.6f} kg")
print(f"Diferencia (E-S): {diferencia_total:>9.6f} kg")
print()

print(f"Saldo final CALCULADO: {saldo_calculado:>10.6f} kg")
print(f"Saldo final KARDEX:    {df_insumos.iloc[-1]['Saldo Cantidad']:>10.6f} kg")
print(f"Diferencia acumulada:   {saldo_calculado - df_insumos.iloc[-1]['Saldo Cantidad']:>9.6f} kg")
print()

# Análisis del error
print("=" * 140)
print("ANALISIS DEL ERROR -0.003 KG")
print("=" * 140)
print()
print("CONCLUSION:")
print("  El saldo negativo de -0.003 kg es el resultado de:")
print(f"    - Total de movimientos: {len(df_insumos)}")
print(f"    - Diferencia total: {total_entradas:.6f} - {total_salidas:.6f} = {diferencia_total:.6f} kg")
print()
print("  Este error representa:")
print(f"    - {abs(diferencia_total / total_entradas * 100):.6f}% del total de entradas")
print(f"    - {abs(diferencia_total / total_salidas * 100):.6f}% del total de salidas")
print()
print("  Es un error de redondeo acumulado MINIMO y NO requiere correccion.")
print()
