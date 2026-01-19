import pandas as pd

# Leer CSV
df = pd.read_csv(r"d:\nuvol\sp\kardex_limon_v2.csv", encoding='utf-8-sig')

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

print("=" * 130)
print("INVESTIGACIÓN: ¿DE DÓNDE SALE EL COSTO DE SALIDA 3.99119?")
print("=" * 130)
print()

# Filtrar ALMACEN FABRICA(INSUMOS)
df_fabrica = df[df['Nom. Almacen'].str.strip() == 'ALMACEN FABRICA(INSUMOS)'].copy()

print(f"Total de movimientos en ALMACEN FABRICA(INSUMOS): {len(df_fabrica)}")
print()

# Buscar el movimiento problemático
mov_problema = df_fabrica[df_fabrica['Codigo Inventario'] == 'INV000297372']

if len(mov_problema) > 0:
    row = mov_problema.iloc[0]

    print("=" * 130)
    print("MOVIMIENTO CON COSTO 3.99119")
    print("=" * 130)
    print(f"Documento: {row['Codigo Inventario']}")
    print(f"Fecha: {row['Fecha Movimiento']}")
    print(f"Tipo Operación: {row['Tipo Operacion']}")
    print(f"Nombre Tipo Operación: {row['Nombre Tipo Operacion']}")
    print()
    print(f"Cantidad Salida: {row['Cantidad Salida']:.6f} kg")
    print(f"Costo Salida: {row['Costo Salida']:.10f}  <<< ESTE VALOR")
    print(f"Total Salida: {row['Total Salida']:.10f}")
    print()

    # Buscar otros movimientos con el mismo costo
    print("=" * 130)
    print("BUSCANDO OTROS MOVIMIENTOS CON COSTO SIMILAR (3.99)")
    print("=" * 130)
    print()

    # En todo el kardex
    costo_buscado = 3.99119
    tolerancia = 0.001

    salidas_mismo_costo = df[
        (df['Movimiento'] == 'Salida') &
        (abs(df['Costo Salida'] - costo_buscado) < tolerancia)
    ]

    print(f"Total de salidas con costo ~{costo_buscado:.5f}: {len(salidas_mismo_costo)}")
    print()

    if len(salidas_mismo_costo) > 0:
        print("DETALLE DE SALIDAS CON ESTE COSTO:")
        print("-" * 130)
        print(f"{'Fecha':<20} {'Documento':<17} {'Almacén':<30} {'Cant. Salida':>12} {'Costo Salida':>14} {'Total Salida':>14}")
        print("-" * 130)

        for idx, sal in salidas_mismo_costo.iterrows():
            print(f"{str(sal['Fecha Movimiento']):<20} {sal['Codigo Inventario']:<17} {str(sal['Nom. Almacen'])[:30]:<30} "
                  f"{sal['Cantidad Salida']:>12.3f} {sal['Costo Salida']:>14.5f} {sal['Total Salida']:>14.5f}")
        print()

    # Buscar entradas con costo similar
    print("=" * 130)
    print("BUSCANDO ENTRADAS CON COSTO SIMILAR")
    print("=" * 130)
    print()

    entradas_costo_similar = df[
        (df['Movimiento'] == 'Entrada') &
        (abs(df['Costo Entrada'] - costo_buscado) < tolerancia)
    ]

    print(f"Total de entradas con costo ~{costo_buscado:.5f}: {len(entradas_costo_similar)}")

    if len(entradas_costo_similar) > 0:
        print()
        print("DETALLE DE ENTRADAS CON COSTO SIMILAR:")
        print("-" * 130)
        print(f"{'Fecha':<20} {'Documento':<17} {'Almacén':<30} {'Cant. Entrada':>13} {'Costo Entrada':>14} {'Total Entrada':>14}")
        print("-" * 130)

        for idx, ent in entradas_costo_similar.iterrows():
            print(f"{str(ent['Fecha Movimiento']):<20} {ent['Codigo Inventario']:<17} {str(ent['Nom. Almacen'])[:30]:<30} "
                  f"{ent['Cantidad Entrada']:>13.3f} {ent['Costo Entrada']:>14.5f} {ent['Total Entrada']:>14.5f}")
    print()

    # Revisar el movimiento ANTERIOR en el mismo almacén
    print("=" * 130)
    print("ANÁLISIS DEL MOVIMIENTO ANTERIOR EN EL MISMO ALMACÉN")
    print("=" * 130)
    print()

    idx_problema = mov_problema.index[0]
    idx_en_fabrica = list(df_fabrica.index).index(idx_problema)

    if idx_en_fabrica > 0:
        idx_anterior = list(df_fabrica.index)[idx_en_fabrica - 1]
        anterior = df_fabrica.loc[idx_anterior]

        print("MOVIMIENTO ANTERIOR:")
        print(f"  Documento: {anterior['Codigo Inventario']}")
        print(f"  Fecha: {anterior['Fecha Movimiento']}")
        print(f"  Tipo: {anterior['Movimiento']}")

        if anterior['Movimiento'] == 'Entrada':
            print(f"  Cantidad Entrada: {anterior['Cantidad Entrada']:.6f} kg")
            print(f"  Costo Entrada: {anterior['Costo Entrada']:.10f}")
        else:
            print(f"  Cantidad Salida: {anterior['Cantidad Salida']:.6f} kg")
            print(f"  Costo Salida: {anterior['Costo Salida']:.10f}")

        print(f"  Saldo Cantidad: {anterior['Saldo Cantidad']:.6f} kg")
        print(f"  Saldo Costo: {anterior['Saldo Costo']:.10f}  <<< COSTO PROMEDIO DEL INVENTARIO")
        print(f"  Saldo Total: {anterior['Saldo Total']:.10f}")
        print()

        print("COMPARACIÓN:")
        print(f"  Costo promedio del inventario: {anterior['Saldo Costo']:.10f}")
        print(f"  Costo usado en la salida: {row['Costo Salida']:.10f}")
        print(f"  Diferencia: {row['Costo Salida'] - anterior['Saldo Costo']:.10f}")
        print()

        if abs(row['Costo Salida'] - anterior['Saldo Costo']) > 0.01:
            print("  ERROR DETECTADO:")
            print("    En método de COSTO PROMEDIO PONDERADO, la salida debe usar")
            print(f"    el Saldo Costo anterior ({anterior['Saldo Costo']:.5f}), NO un costo diferente ({row['Costo Salida']:.5f})")
        else:
            print("  OK: El costo de salida coincide con el saldo costo anterior")
        print()

    # Buscar de dónde podría venir 3.99119
    print("=" * 130)
    print("HIPÓTESIS: ¿DE DÓNDE VIENE 3.99119?")
    print("=" * 130)
    print()

    # Verificar si es el costo de OTRO documento o movimiento
    doc_origen = df_fabrica[df_fabrica['Codigo Inventario'] == 'INV000297367']

    if len(doc_origen) > 0:
        print("DOCUMENTO INV000297367 (movimiento anterior al problemático):")
        doc = doc_origen.iloc[0]
        print(f"  Fecha: {doc['Fecha Movimiento']}")
        print(f"  Tipo: {doc['Movimiento']}")
        print(f"  Cantidad Salida: {doc['Cantidad Salida']:.6f} kg")
        print(f"  Costo Salida: {doc['Costo Salida']:.10f}")
        print()

        if abs(doc['Costo Salida'] - costo_buscado) < 0.01:
            print("  ENCONTRADO: Este documento usa el mismo costo 3.99119!")
            print("  Este podría ser el costo que se está replicando erróneamente.")
        else:
            print(f"  Este documento usa un costo diferente: {doc['Costo Salida']:.5f}")
        print()

    # Revisar si viene de CostoInventario
    print("POSIBLE ORIGEN:")
    print("  El costo 3.99119 probablemente viene de la tabla CostoInventario.")
    print("  Esto sucede cuando:")
    print("    1. El costo se calcula GLOBALMENTE (todos los almacenes juntos)")
    print("    2. En lugar de calcularse POR ALMACÉN individual")
    print()
    print("  SOLUCIÓN:")
    print("    El Costo Salida debería ser el Saldo Costo del movimiento anterior")
    print(f"    en este almacén: {anterior['Saldo Costo']:.10f}")

else:
    print("No se encontró el movimiento INV000297372")
