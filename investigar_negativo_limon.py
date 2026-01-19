import pandas as pd

# Leer CSV
df = pd.read_csv(r"d:\nuvol\sp\kardex_limon.csv", encoding='utf-8-sig')

# Convertir columnas
df['Fecha Movimiento'] = pd.to_datetime(df['Fecha Movimiento'], format='mixed', errors='coerce')
df['Cantidad Entrada'] = pd.to_numeric(df['Cantidad Entrada'], errors='coerce')
df['Costo Entrada'] = pd.to_numeric(df['Costo Entrada'], errors='coerce')
df['Cantidad Salida'] = pd.to_numeric(df['Cantidad Salida'], errors='coerce')
df['Costo Salida'] = pd.to_numeric(df['Costo Salida'], errors='coerce')
df['Saldo Cantidad'] = pd.to_numeric(df['Saldo Cantidad'], errors='coerce')
df['Saldo Costo'] = pd.to_numeric(df['Saldo Costo'], errors='coerce')
df['Saldo Total'] = pd.to_numeric(df['Saldo Total'], errors='coerce')
df['Movimiento'] = df['Movimiento'].str.strip()

print("=" * 120)
print("INVESTIGACIÓN DEL SALDO NEGATIVO -0.003 KG")
print("=" * 120)
print()

# Buscar el registro con saldo negativo
negativo = df[df['Saldo Cantidad'] < 0].iloc[0]
idx_negativo = df[df['Saldo Cantidad'] < 0].index[0]

print("INFORMACIÓN DEL MOVIMIENTO CON SALDO NEGATIVO:")
print("=" * 120)
print(f"Fecha: {negativo['Fecha Movimiento']}")
print(f"Documento: {negativo['Codigo Inventario']}")
print(f"Registro Contable: {negativo['Registro Contable']}")
print(f"Tipo: {negativo['Movimiento']}")
print(f"Cantidad Salida: {negativo['Cantidad Salida']:.10f} kg")
print(f"Costo Salida: {negativo['Costo Salida']:.10f}")
print(f"Saldo Cantidad: {negativo['Saldo Cantidad']:.10f} kg  <<< NEGATIVO")
print(f"Saldo Costo: {negativo['Saldo Costo']:.10f}")
print(f"Saldo Total: {negativo['Saldo Total']:.10f}")
print(f"Almacén: {negativo['Nom. Almacen']}")
print(f"Tipo Operación: {negativo['Tipo Operacion']}")
print(f"Nombre Tipo Operación: {negativo['Nombre Tipo Operacion']}")
print()

# Ver el contexto: 20 movimientos antes
print("=" * 120)
print("CONTEXTO: 20 MOVIMIENTOS ANTERIORES")
print("=" * 120)

inicio = max(0, idx_negativo - 20)
fin = idx_negativo + 1

contexto = df.iloc[inicio:fin].copy()

print(f"\nMovimientos desde índice {inicio} hasta {idx_negativo}:")
print()

for i, (idx, row) in enumerate(contexto.iterrows()):
    marca = " >>> NEGATIVO AQUÍ <<<" if idx == idx_negativo else ""
    tipo = row['Movimiento'][:1]  # E o S

    if tipo == 'E':
        print(f"{i:2d} [{idx:3d}] {row['Fecha Movimiento']} | ENTRADA {row['Cantidad Entrada']:8.4f} kg × {row['Costo Entrada']:7.4f} = {row['Total Entrada']:10.4f} | "
              f"Saldo: {row['Saldo Cantidad']:8.4f} kg × {row['Saldo Costo']:7.4f} = {row['Saldo Total']:10.4f}{marca}")
    else:
        print(f"{i:2d} [{idx:3d}] {row['Fecha Movimiento']} | SALIDA  {row['Cantidad Salida']:8.4f} kg × {row['Costo Salida']:7.4f} = {row['Total Salida']:10.4f} | "
              f"Saldo: {row['Saldo Cantidad']:8.4f} kg × {row['Saldo Costo']:7.4f} = {row['Saldo Total']:10.4f}{marca}")

print()

# Analizar el saldo antes de la salida problemática
if idx_negativo > 0:
    anterior = df.iloc[idx_negativo - 1]
    print("=" * 120)
    print("ANÁLISIS DEL SALDO ANTERIOR")
    print("=" * 120)
    print(f"Saldo ANTES de la salida: {anterior['Saldo Cantidad']:.10f} kg")
    print(f"Cantidad a SALIR: {negativo['Cantidad Salida']:.10f} kg")
    print(f"Diferencia: {anterior['Saldo Cantidad'] - negativo['Cantidad Salida']:.10f} kg")
    print()
    print(f"Resultado esperado: {anterior['Saldo Cantidad']:.10f} - {negativo['Cantidad Salida']:.10f} = {anterior['Saldo Cantidad'] - negativo['Cantidad Salida']:.10f} kg")
    print(f"Resultado real (del kardex): {negativo['Saldo Cantidad']:.10f} kg")
    print()

    diferencia = (anterior['Saldo Cantidad'] - negativo['Cantidad Salida']) - negativo['Saldo Cantidad']
    print(f"Discrepancia: {diferencia:.10f} kg")

    if abs(diferencia) < 0.01:
        print()
        print("CONCLUSIÓN: La discrepancia es despreciable (< 0.01 kg), probablemente error de redondeo.")
    else:
        print()
        print("CONCLUSIÓN: Hay una discrepancia significativa que requiere investigación.")

print()

# Ver movimientos DESPUÉS del negativo
print("=" * 120)
print("MOVIMIENTOS POSTERIORES (siguientes 10)")
print("=" * 120)

inicio_post = idx_negativo + 1
fin_post = min(len(df), inicio_post + 10)

posteriores = df.iloc[inicio_post:fin_post]

for i, (idx, row) in enumerate(posteriores.iterrows()):
    tipo = row['Movimiento'][:1]

    if tipo == 'E':
        print(f"{i:2d} [{idx:3d}] {row['Fecha Movimiento']} | ENTRADA {row['Cantidad Entrada']:8.4f} kg | "
              f"Saldo: {row['Saldo Cantidad']:8.4f} kg × {row['Saldo Costo']:10.4f}")
    else:
        print(f"{i:2d} [{idx:3d}] {row['Fecha Movimiento']} | SALIDA  {row['Cantidad Salida']:8.4f} kg | "
              f"Saldo: {row['Saldo Cantidad']:8.4f} kg × {row['Saldo Costo']:10.4f}")

print()

# Verificar suma acumulada
print("=" * 120)
print("VERIFICACIÓN DE SUMA ACUMULADA")
print("=" * 120)

# Calcular el saldo acumulado hasta el movimiento problemático
saldo_calculado = 0.0
for idx_calc in range(idx_negativo + 1):
    row = df.iloc[idx_calc]
    if row['Movimiento'] == 'Entrada':
        saldo_calculado += row['Cantidad Entrada']
    else:
        saldo_calculado -= row['Cantidad Salida']

print(f"Saldo calculado manualmente hasta el movimiento {idx_negativo}: {saldo_calculado:.10f} kg")
print(f"Saldo en el kardex: {negativo['Saldo Cantidad']:.10f} kg")
print(f"Diferencia: {saldo_calculado - negativo['Saldo Cantidad']:.10f} kg")
