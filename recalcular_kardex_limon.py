import pandas as pd

# Leer CSV
df = pd.read_csv(r"d:\nuvol\sp\kardex_limon.csv", encoding='utf-8-sig')

# Convertir columnas
df['Fecha Movimiento'] = pd.to_datetime(df['Fecha Movimiento'], format='mixed', errors='coerce')
df['Cantidad Entrada'] = pd.to_numeric(df['Cantidad Entrada'], errors='coerce')
df['Cantidad Salida'] = pd.to_numeric(df['Cantidad Salida'], errors='coerce')
df['Saldo Cantidad'] = pd.to_numeric(df['Saldo Cantidad'], errors='coerce')
df['Movimiento'] = df['Movimiento'].str.strip()

print("=" * 120)
print("RECALCULANDO KARDEX LIMÓN - IDENTIFICANDO ERRORES")
print("=" * 120)
print()

# Recalcular saldo manualmente
saldo_calculado = 0.0
errores = []

print("Recalculando saldo acumulado movimiento por movimiento...")
print()

for idx, row in df.iterrows():
    # Guardar saldo anterior
    saldo_anterior = saldo_calculado

    # Calcular nuevo saldo
    if row['Movimiento'] == 'Entrada':
        saldo_calculado += row['Cantidad Entrada']
    else:
        saldo_calculado -= row['Cantidad Salida']

    # Comparar con el saldo del kardex
    saldo_kardex = row['Saldo Cantidad']
    diferencia = saldo_calculado - saldo_kardex

    # Si hay diferencia significativa (> 0.01 kg), registrar error
    if abs(diferencia) > 0.01:
        errores.append({
            'idx': idx,
            'fecha': row['Fecha Movimiento'],
            'documento': row['Codigo Inventario'],
            'movimiento': row['Movimiento'],
            'cantidad_mov': row['Cantidad Entrada'] if row['Movimiento'] == 'Entrada' else row['Cantidad Salida'],
            'saldo_calculado': saldo_calculado,
            'saldo_kardex': saldo_kardex,
            'diferencia': diferencia,
            'saldo_anterior': saldo_anterior
        })

print(f"Análisis completado. Total de movimientos: {len(df)}")
print(f"Errores encontrados: {len(errores)}")
print()

if len(errores) > 0:
    print("=" * 120)
    print("MOVIMIENTOS CON ERRORES EN EL SALDO")
    print("=" * 120)
    print()

    for i, error in enumerate(errores[:20]):  # Mostrar primeros 20 errores
        print(f"ERROR {i+1} [Índice {error['idx']}]")
        print(f"  Fecha: {error['fecha']}")
        print(f"  Documento: {error['documento']}")
        print(f"  Movimiento: {error['movimiento']} de {error['cantidad_mov']:.4f} kg")
        print(f"  Saldo ANTES: {error['saldo_anterior']:.4f} kg")
        print(f"  Saldo CALCULADO: {error['saldo_calculado']:.4f} kg")
        print(f"  Saldo KARDEX: {error['saldo_kardex']:.4f} kg")
        print(f"  DIFERENCIA: {error['diferencia']:.4f} kg")
        print()

    if len(errores) > 20:
        print(f"... y {len(errores) - 20} errores más")
        print()

    # Analizar el primer error
    print("=" * 120)
    print("ANÁLISIS DEL PRIMER ERROR")
    print("=" * 120)
    primer_error = errores[0]
    idx_error = primer_error['idx']

    print(f"\nEl primer error ocurre en el índice {idx_error}:")
    print(f"Fecha: {primer_error['fecha']}")
    print(f"Documento: {primer_error['documento']}")
    print()

    # Mostrar contexto (5 movimientos antes y después)
    inicio = max(0, idx_error - 5)
    fin = min(len(df), idx_error + 6)

    print("CONTEXTO (5 antes, 5 después):")
    print()

    for i in range(inicio, fin):
        row = df.iloc[i]
        marca = " >>> ERROR AQUÍ <<<" if i == idx_error else ""

        # Recalcular saldo para este punto
        saldo_temp = 0.0
        for j in range(i + 1):
            r = df.iloc[j]
            if r['Movimiento'] == 'Entrada':
                saldo_temp += r['Cantidad Entrada']
            else:
                saldo_temp -= r['Cantidad Salida']

        if row['Movimiento'] == 'Entrada':
            print(f"[{i:3d}] {row['Fecha Movimiento']} | ENTRADA {row['Cantidad Entrada']:8.4f} kg | "
                  f"Saldo Calc: {saldo_temp:8.4f} | Saldo Kardex: {row['Saldo Cantidad']:8.4f} | "
                  f"Dif: {saldo_temp - row['Saldo Cantidad']:8.4f}{marca}")
        else:
            print(f"[{i:3d}] {row['Fecha Movimiento']} | SALIDA  {row['Cantidad Salida']:8.4f} kg | "
                  f"Saldo Calc: {saldo_temp:8.4f} | Saldo Kardex: {row['Saldo Cantidad']:8.4f} | "
                  f"Dif: {saldo_temp - row['Saldo Cantidad']:8.4f}{marca}")

    print()

    # Análisis de patrón
    print("=" * 120)
    print("ANÁLISIS DE PATRÓN DE ERRORES")
    print("=" * 120)

    # Ver si los errores ocurren en transferencias (salida + entrada)
    transferencias = 0
    for error in errores:
        idx_e = error['idx']
        if idx_e < len(df) - 1:
            row_actual = df.iloc[idx_e]
            row_siguiente = df.iloc[idx_e + 1]

            # Verificar si es transferencia (salida seguida de entrada con misma cantidad)
            if (row_actual['Movimiento'] == 'Salida' and
                row_siguiente['Movimiento'] == 'Entrada' and
                abs(row_actual['Cantidad Salida'] - row_siguiente['Cantidad Entrada']) < 0.01):
                transferencias += 1

    print(f"Errores relacionados con transferencias: {transferencias} de {len(errores)} ({transferencias/len(errores)*100:.1f}%)")
    print()

else:
    print("No se encontraron errores significativos en el cálculo del saldo.")

# Resumen final
print("=" * 120)
print("RESUMEN")
print("=" * 120)
print(f"Saldo final CALCULADO (suma de todas las E-S): {saldo_calculado:.4f} kg")
print(f"Saldo final KARDEX: {df.iloc[-1]['Saldo Cantidad']:.4f} kg")
print(f"Diferencia total acumulada: {saldo_calculado - df.iloc[-1]['Saldo Cantidad']:.4f} kg")
