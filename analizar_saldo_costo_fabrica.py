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

# Filtrar solo ALMACEN FABRICA(INSUMOS)
df_fabrica = df[df['Nom. Almacen'].str.strip() == 'ALMACEN FABRICA(INSUMOS)'].copy()

print("=" * 140)
print("ANÁLISIS DEL SALDO COSTO 9901.80866666667 - ALMACEN FABRICA(INSUMOS)")
print("=" * 140)
print()

# Buscar el registro con ese saldo
registro_buscado = df_fabrica[abs(df_fabrica['Saldo Costo'] - 9901.80866666667) < 0.1]

if len(registro_buscado) > 0:
    row = registro_buscado.iloc[0]
    idx_en_fabrica = registro_buscado.index[0]

    print(f"REGISTRO ENCONTRADO:")
    print(f"  Fecha: {row['Fecha Movimiento']}")
    print(f"  Documento: {row['Codigo Inventario']}")
    print(f"  Tipo: {row['Movimiento']}")
    print(f"  Cantidad Salida: {row['Cantidad Salida']:.6f} kg")
    print(f"  Costo Salida: {row['Costo Salida']:.10f}")
    print(f"  Total Salida: {row['Total Salida']:.10f}")
    print()
    print(f"  Saldo Cantidad: {row['Saldo Cantidad']:.6f} kg  <<< NEGATIVO")
    print(f"  Saldo Costo: {row['Saldo Costo']:.15f}  <<< VALOR ANORMAL")
    print(f"  Saldo Total: {row['Saldo Total']:.10f}")
    print()

    # Mostrar todos los movimientos del ALMACEN FABRICA(INSUMOS)
    print("=" * 140)
    print("TODOS LOS MOVIMIENTOS EN ALMACEN FABRICA(INSUMOS)")
    print("=" * 140)
    print()

    print(f"{'#':>3} {'Fecha':<20} {'Tipo':>8} {'Cant.':>10} {'Costo':>12} {'Total':>12} {'Saldo Cant':>12} {'Saldo Costo':>14} {'Saldo Total':>14}")
    print("-" * 140)

    for i, (idx, frow) in enumerate(df_fabrica.iterrows()):
        marca = " <<<" if idx == idx_en_fabrica else ""
        tipo = frow['Movimiento'][:1]

        if tipo == 'E':
            print(f"{i+1:3d} {str(frow['Fecha Movimiento']):<20} {'ENTRADA':>8} "
                  f"{frow['Cantidad Entrada']:>10.3f} {frow['Costo Entrada']:>12.5f} {frow['Total Entrada']:>12.5f} "
                  f"{frow['Saldo Cantidad']:>12.3f} {frow['Saldo Costo']:>14.5f} {frow['Saldo Total']:>14.5f}{marca}")
        else:
            print(f"{i+1:3d} {str(frow['Fecha Movimiento']):<20} {'SALIDA':>8} "
                  f"{frow['Cantidad Salida']:>10.3f} {frow['Costo Salida']:>12.5f} {frow['Total Salida']:>12.5f} "
                  f"{frow['Saldo Cantidad']:>12.3f} {frow['Saldo Costo']:>14.5f} {frow['Saldo Total']:>14.5f}{marca}")

    print()

    # Obtener el movimiento anterior en el mismo almacén
    idx_en_lista = list(df_fabrica.index).index(idx_en_fabrica)

    if idx_en_lista > 0:
        idx_anterior = list(df_fabrica.index)[idx_en_lista - 1]
        anterior = df_fabrica.loc[idx_anterior]

        print("=" * 140)
        print("ANÁLISIS DEL CÁLCULO")
        print("=" * 140)
        print()

        print(f"MOVIMIENTO ANTERIOR (#{idx_en_lista}):")
        print(f"  Fecha: {anterior['Fecha Movimiento']}")
        print(f"  Saldo Cantidad: {anterior['Saldo Cantidad']:.6f} kg")
        print(f"  Saldo Costo: {anterior['Saldo Costo']:.10f}")
        print(f"  Saldo Total: {anterior['Saldo Total']:.10f}")
        print()

        print(f"MOVIMIENTO ACTUAL (#{idx_en_lista + 1}):")
        print(f"  Fecha: {row['Fecha Movimiento']}")
        print(f"  Tipo: SALIDA")
        print(f"  Cantidad: {row['Cantidad Salida']:.6f} kg")
        print(f"  Costo: {row['Costo Salida']:.10f}")
        print(f"  Total: {row['Total Salida']:.10f}")
        print()

        # Cálculo esperado
        cant_esperada = anterior['Saldo Cantidad'] - row['Cantidad Salida']
        total_esperado = anterior['Saldo Total'] - row['Total Salida']

        # El costo unitario debería mantenerse igual en una salida
        costo_esperado = anterior['Saldo Costo']

        print(f"CÁLCULO ESPERADO:")
        print(f"  Cantidad: {anterior['Saldo Cantidad']:.6f} - {row['Cantidad Salida']:.6f} = {cant_esperada:.6f} kg")
        print(f"  Total: {anterior['Saldo Total']:.5f} - {row['Total Salida']:.5f} = {total_esperado:.5f}")
        print(f"  Costo unitario (sin cambio): {costo_esperado:.10f}")
        print()

        print(f"RESULTADO EN KARDEX:")
        print(f"  Cantidad: {row['Saldo Cantidad']:.6f} kg")
        print(f"  Total: {row['Saldo Total']:.5f}")
        print(f"  Costo unitario: {row['Saldo Costo']:.10f}")
        print()

        print(f"PROBLEMA IDENTIFICADO:")
        print(f"  La cantidad esperada era: {cant_esperada:.6f} kg")
        print(f"  Pero el kardex muestra: {row['Saldo Cantidad']:.6f} kg")
        print(f"  Diferencia: {row['Saldo Cantidad'] - cant_esperada:.6f} kg")
        print()
        print(f"  El saldo costo anormal (9901.80866666667) se debe a:")
        print(f"  Saldo Total / Saldo Cantidad = {row['Saldo Total']:.5f} / {row['Saldo Cantidad']:.6f} = {row['Saldo Total'] / row['Saldo Cantidad']:.10f}")
        print()
        print("  CONCLUSIÓN:")
        print(f"    Hay una DISCREPANCIA en la cantidad del saldo.")
        print(f"    El saldo de cantidad es INCORRECTO (-0.003 en lugar de {cant_esperada:.3f})")
        print(f"    Esta discrepancia genera un costo unitario absurdamente alto.")
        print()
        print("  CAUSA RAÍZ:")
        print("    El kardex muestra movimientos de MÚLTIPLES ALMACENES mezclados.")
        print("    Los saldos están calculados GLOBALMENTE, no por almacén individual.")
        print("    El saldo -0.003 kg es el saldo GLOBAL de todos los almacenes.")

else:
    print("No se encontró el registro con ese saldo de costo.")
