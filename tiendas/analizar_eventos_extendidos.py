"""
Análisis de Extended Events - SQL Server
Objetivo: Identificar consultas lentas, bloqueos y problemas de rendimiento
"""

import pandas as pd
import numpy as np
import sys
import io
import re

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

archivo = r"d:\nuvol\sp\tiendas\eventos.xlsx"

print("=" * 100)
print("ANALISIS DE EXTENDED EVENTS - SQL SERVER")
print("=" * 100)

# Cargar datos
xl = pd.ExcelFile(archivo)
print(f"\nHojas disponibles: {xl.sheet_names}")

for sheet in xl.sheet_names:
    print(f"\n{'='*80}")
    print(f"HOJA: {sheet}")
    print("=" * 80)

    df = pd.read_excel(archivo, sheet_name=sheet)

    print(f"\nDimensiones: {len(df)} filas x {len(df.columns)} columnas")

    print(f"\nColumnas:")
    for i, col in enumerate(df.columns, 1):
        dtype = df[col].dtype
        nulls = df[col].isnull().sum()
        print(f"  {i:2}. {col:<40} | {str(dtype):<15} | Nulos: {nulls}")

# Cargar primera hoja para análisis
df = pd.read_excel(archivo, sheet_name=xl.sheet_names[0])

print("\n" + "=" * 100)
print("PRIMERAS 5 FILAS DE DATOS")
print("=" * 100)
pd.set_option('display.max_columns', None)
pd.set_option('display.width', None)
pd.set_option('display.max_colwidth', 100)
print(df.head().to_string())

# Buscar columnas de métricas
print("\n" + "=" * 100)
print("ANALISIS DE METRICAS")
print("=" * 100)

# Columnas numéricas
cols_num = df.select_dtypes(include=[np.number]).columns.tolist()
print(f"\nColumnas numéricas: {cols_num}")

for col in cols_num:
    if df[col].notna().any():
        print(f"\n  {col}:")
        print(f"    Min: {df[col].min():,.2f}")
        print(f"    Max: {df[col].max():,.2f}")
        print(f"    Promedio: {df[col].mean():,.2f}")
        print(f"    Suma: {df[col].sum():,.2f}")

# Buscar columna de duración
cols_duracion = [c for c in df.columns if any(x in str(c).lower() for x in ['duration', 'tiempo', 'elapsed', 'ms', 'time'])]
print(f"\nColumnas de duración encontradas: {cols_duracion}")

# Buscar columna de SQL/Query
cols_sql = [c for c in df.columns if any(x in str(c).lower() for x in ['sql', 'statement', 'query', 'text', 'batch'])]
print(f"Columnas de SQL encontradas: {cols_sql}")

# Si hay columna de duración, analizar top consultas
if cols_duracion:
    col_dur = cols_duracion[0]
    print(f"\n" + "=" * 100)
    print(f"TOP 20 EVENTOS MAS LENTOS (por {col_dur})")
    print("=" * 100)

    if df[col_dur].dtype in ['int64', 'float64']:
        top = df.nlargest(20, col_dur)
        print(top.to_string())
