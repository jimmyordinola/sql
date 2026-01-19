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
df['Movimiento'] = df['Movimiento'].str.strip()

print("=" * 140)
print("INVESTIGACION DEL SALDO COSTO: 9901.80866666667")
print("=" * 140)
print()

# Buscar el registro con ese saldo de costo
saldo_buscado = 9901.80866666667
registros = df[abs(df['Saldo Costo'] - saldo_buscado) < 0.01]

if len(registros) > 0:
    print(f"REGISTROS ENCONTRADOS CON SALDO COSTO ~{saldo_buscado:.5f}: {len(registros)}")
    print()

    for idx, row in registros.iterrows():
        print(f"REGISTRO #{idx}")
        print(f"  Fecha: {row['Fecha Movimiento']}")
        print(f"  Documento: {row['Codigo Inventario']}")
        print(f"  Almacén: {row['Nom. Almacen']}")
        print(f"  Tipo: {row['Movimiento']}")

        if row['Movimiento'] == 'Entrada':
            print(f"  Cantidad Entrada: {row['Cantidad Entrada']:.6f} kg")
            print(f"  Costo Entrada: {row['Costo Entrada']:.10f}")
            print(f"  Total Entrada: {row['Total Entrada']:.10f}")
        else:
            print(f"  Cantidad Salida: {row['Cantidad Salida']:.6f} kg")
            print(f"  Costo Salida: {row['Costo Salida']:.10f}")
            print(f"  Total Salida: {row['Total Salida']:.10f}")

        print(f"  Saldo Cantidad: {row['Saldo Cantidad']:.6f} kg")
        print(f"  Saldo Costo: {row['Saldo Costo']:.15f}  <<< VALOR BUSCADO")
        print(f"  Saldo Total: {row['Saldo Total']:.10f}")
        print()

        # Mostrar contexto: 10 movimientos antes
        print("  CONTEXTO - 10 MOVIMIENTOS ANTERIORES:")
        print("  " + "-" * 130)

        inicio = max(0, idx - 10)
        contexto = df.iloc[inicio:idx+1]

        for i, (ctx_idx, ctx_row) in enumerate(contexto.iterrows()):
            marca = " <<< AQUI" if ctx_idx == idx else ""
            tipo = ctx_row['Movimiento'][:1]

            if tipo == 'E':
                print(f"  [{ctx_idx:3d}] {ctx_row['Fecha Movimiento']} | ENTRADA {ctx_row['Cantidad Entrada']:8.3f} kg × {ctx_row['Costo Entrada']:10.5f} = {ctx_row['Total Entrada']:12.5f} | "
                      f"Saldo: {ctx_row['Saldo Cantidad']:8.3f} kg × {ctx_row['Saldo Costo']:10.5f} = {ctx_row['Saldo Total']:12.5f}{marca}")
            else:
                print(f"  [{ctx_idx:3d}] {ctx_row['Fecha Movimiento']} | SALIDA  {ctx_row['Cantidad Salida']:8.3f} kg × {ctx_row['Costo Salida']:10.5f} = {ctx_row['Total Salida']:12.5f} | "
                      f"Saldo: {ctx_row['Saldo Cantidad']:8.3f} kg × {ctx_row['Saldo Costo']:10.5f} = {ctx_row['Saldo Total']:12.5f}{marca}")

        print()

        # Análisis del cálculo
        if idx > 0:
            anterior = df.iloc[idx - 1]
            print("  ANÁLISIS DEL CÁLCULO:")
            print("  " + "-" * 130)
            print(f"  Saldo ANTERIOR:")
            print(f"    Cantidad: {anterior['Saldo Cantidad']:.6f} kg")
            print(f"    Costo: {anterior['Saldo Costo']:.10f}")
            print(f"    Total: {anterior['Saldo Total']:.10f}")
            print()

            if row['Movimiento'] == 'Entrada':
                print(f"  ENTRADA ACTUAL:")
                print(f"    Cantidad: {row['Cantidad Entrada']:.6f} kg")
                print(f"    Costo: {row['Costo Entrada']:.10f}")
                print(f"    Total: {row['Total Entrada']:.10f}")
                print()

                # Cálculo esperado del costo promedio ponderado
                nueva_cantidad = anterior['Saldo Cantidad'] + row['Cantidad Entrada']
                nuevo_total = anterior['Saldo Total'] + row['Total Entrada']
                nuevo_costo_esperado = nuevo_total / nueva_cantidad if nueva_cantidad != 0 else 0

                print(f"  CÁLCULO ESPERADO (Promedio Ponderado):")
                print(f"    Nueva Cantidad = {anterior['Saldo Cantidad']:.6f} + {row['Cantidad Entrada']:.6f} = {nueva_cantidad:.6f} kg")
                print(f"    Nuevo Total = {anterior['Saldo Total']:.5f} + {row['Total Entrada']:.5f} = {nuevo_total:.5f}")
                print(f"    Nuevo Costo = {nuevo_total:.5f} / {nueva_cantidad:.6f} = {nuevo_costo_esperado:.15f}")
                print()

                print(f"  RESULTADO EN KARDEX:")
                print(f"    Saldo Cantidad: {row['Saldo Cantidad']:.6f} kg")
                print(f"    Saldo Costo: {row['Saldo Costo']:.15f}")
                print(f"    Saldo Total: {row['Saldo Total']:.10f}")
                print()

                # Verificar
                diferencia_costo = row['Saldo Costo'] - nuevo_costo_esperado
                diferencia_cantidad = row['Saldo Cantidad'] - nueva_cantidad
                diferencia_total = row['Saldo Total'] - nuevo_total

                print(f"  VERIFICACIÓN:")
                print(f"    Diferencia en Costo: {diferencia_costo:.15f}")
                print(f"    Diferencia en Cantidad: {diferencia_cantidad:.10f} kg")
                print(f"    Diferencia en Total: {diferencia_total:.10f}")

                if abs(diferencia_costo) < 0.000001:
                    print("    OK: CALCULO CORRECTO")
                else:
                    print("    ERROR: DISCREPANCIA DETECTADA")

            else:  # Salida
                print(f"  SALIDA ACTUAL:")
                print(f"    Cantidad: {row['Cantidad Salida']:.6f} kg")
                print(f"    Costo: {row['Costo Salida']:.10f}")
                print(f"    Total: {row['Total Salida']:.10f}")
                print()

                # Cálculo esperado
                nueva_cantidad = anterior['Saldo Cantidad'] - row['Cantidad Salida']
                nuevo_total = anterior['Saldo Total'] - row['Total Salida']

                # El costo unitario NO cambia en una salida (método promedio ponderado)
                nuevo_costo_esperado = anterior['Saldo Costo']

                print(f"  CÁLCULO ESPERADO:")
                print(f"    Nueva Cantidad = {anterior['Saldo Cantidad']:.6f} - {row['Cantidad Salida']:.6f} = {nueva_cantidad:.6f} kg")
                print(f"    Nuevo Total = {anterior['Saldo Total']:.5f} - {row['Total Salida']:.5f} = {nuevo_total:.5f}")
                print(f"    Costo (sin cambio) = {nuevo_costo_esperado:.15f}")
                print()

                print(f"  RESULTADO EN KARDEX:")
                print(f"    Saldo Cantidad: {row['Saldo Cantidad']:.6f} kg")
                print(f"    Saldo Costo: {row['Saldo Costo']:.15f}")
                print(f"    Saldo Total: {row['Saldo Total']:.10f}")
                print()

                # Verificar
                diferencia_costo = row['Saldo Costo'] - nuevo_costo_esperado
                diferencia_cantidad = row['Saldo Cantidad'] - nueva_cantidad
                diferencia_total = row['Saldo Total'] - nuevo_total

                print(f"  VERIFICACIÓN:")
                print(f"    Diferencia en Costo: {diferencia_costo:.15f}")
                print(f"    Diferencia en Cantidad: {diferencia_cantidad:.10f} kg")
                print(f"    Diferencia en Total: {diferencia_total:.10f}")

                if abs(diferencia_costo) < 0.000001:
                    print("    OK: CALCULO CORRECTO")
                else:
                    print("    ERROR: DISCREPANCIA DETECTADA")

        print()
        print("=" * 140)

else:
    print(f"NO SE ENCONTRÓ ningún registro con Saldo Costo = {saldo_buscado:.5f}")
    print()
    print("Mostrando todos los saldos de costo únicos:")
    saldos_unicos = df['Saldo Costo'].dropna().unique()
    for saldo in sorted(saldos_unicos)[:20]:
        count = len(df[abs(df['Saldo Costo'] - saldo) < 0.01])
        print(f"  Saldo Costo: {saldo:.10f} ({count} registros)")
