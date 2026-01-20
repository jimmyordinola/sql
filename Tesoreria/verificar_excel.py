"""
Script para verificar el contenido del Excel y sus métricas de rendimiento
"""

import pandas as pd
import sys
import io

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

archivo = r"d:\nuvol\sp\Tesoreria\RESULTADOS.xlsx"

print("=" * 80)
print("VERIFICACION DEL CONTENIDO DEL EXCEL")
print("=" * 80)

# Cargar ambas hojas
xl = pd.ExcelFile(archivo)

for sheet in xl.sheet_names:
    print(f"\n{'='*60}")
    print(f"HOJA: {sheet}")
    print("=" * 60)

    df = pd.read_excel(archivo, sheet_name=sheet)

    print(f"\nDimensiones: {len(df)} filas x {len(df.columns)} columnas")

    print(f"\nColumnas:")
    for i, col in enumerate(df.columns, 1):
        print(f"  {i:2}. {col}")

    print(f"\nPrimeras 5 filas:")
    print(df.head().to_string())

    print(f"\nTipos de datos:")
    print(df.dtypes)

# Comparar si los datos son iguales
print("\n" + "=" * 80)
print("COMPARACION ENTRE HOJAS")
print("=" * 80)

df_orig = pd.read_excel(archivo, sheet_name='ORIGINAL')
df_opt = pd.read_excel(archivo, sheet_name='OPTIMIZAO')

# Verificar si tienen las mismas columnas
if list(df_orig.columns) == list(df_opt.columns):
    print("\nColumnas: IDENTICAS")
else:
    print("\nColumnas: DIFERENTES")
    print(f"  Original: {list(df_orig.columns)}")
    print(f"  Optimizado: {list(df_opt.columns)}")

# Verificar si tienen los mismos datos
if df_orig.equals(df_opt):
    print("\nDatos: IDENTICOS (ambas hojas tienen exactamente los mismos valores)")
else:
    print("\nDatos: DIFERENTES")
    # Encontrar diferencias
    diff_count = 0
    for col in df_orig.columns:
        if col in df_opt.columns:
            diff = (df_orig[col] != df_opt[col]).sum()
            if diff > 0:
                print(f"  Columna '{col}': {diff} diferencias")
                diff_count += diff
    print(f"\nTotal diferencias encontradas: {diff_count}")
