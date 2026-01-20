"""
Análisis del archivo de pedidos - SQL Profile
"""

import pandas as pd
import sys
import io

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

archivo = r"d:\nuvol\sp\tiendas\pedidos.xlsx"

print("=" * 80)
print("ANALISIS DE SQL PROFILE - PEDIDOS")
print("=" * 80)

# Ver hojas disponibles
xl = pd.ExcelFile(archivo)
print(f"\nHojas disponibles: {xl.sheet_names}")

for sheet in xl.sheet_names:
    print(f"\n{'='*60}")
    print(f"HOJA: {sheet}")
    print("=" * 60)

    df = pd.read_excel(archivo, sheet_name=sheet)

    print(f"\nDimensiones: {len(df)} filas x {len(df.columns)} columnas")

    print(f"\nColumnas:")
    for i, col in enumerate(df.columns, 1):
        dtype = df[col].dtype
        print(f"  {i:2}. {col:<50} | {dtype}")

    print(f"\nPrimeras 10 filas:")
    pd.set_option('display.max_columns', None)
    pd.set_option('display.width', None)
    print(df.head(10).to_string())

    # Buscar columnas de tiempo/duracion
    cols_tiempo = [c for c in df.columns if any(x in c.lower() for x in ['time', 'duration', 'elapsed', 'cpu', 'read', 'write', 'wait', 'tiempo', 'duracion', 'ms', 'seg'])]
    if cols_tiempo:
        print(f"\n*** COLUMNAS DE METRICAS DE TIEMPO ENCONTRADAS: {cols_tiempo}")
        for col in cols_tiempo:
            if df[col].dtype in ['int64', 'float64']:
                print(f"\n  {col}:")
                print(f"    Min: {df[col].min()}")
                print(f"    Max: {df[col].max()}")
                print(f"    Promedio: {df[col].mean():.2f}")
                print(f"    Total: {df[col].sum()}")
