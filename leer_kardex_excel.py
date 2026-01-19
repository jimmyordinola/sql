import pandas as pd
import sys

# Leer el archivo Excel
excel_file = r"d:\nuvol\sp\kardex cremolada por bolsa.xls"

try:
    # Intentar leer con xlrd (para archivos .xls antiguos)
    df = pd.read_excel(excel_file, engine='xlrd')

    print("=" * 80)
    print("ESTRUCTURA DEL KARDEX - CREMOLADA POR BOLSA")
    print("=" * 80)
    print()

    # Mostrar información básica
    print(f"Total de registros: {len(df)}")
    print(f"Columnas ({len(df.columns)}): {', '.join(df.columns.tolist())}")
    print()

    # Mostrar primeros registros
    print("=" * 80)
    print("PRIMEROS 10 REGISTROS:")
    print("=" * 80)
    print(df.head(10).to_string())
    print()

    # Mostrar últimos registros
    print("=" * 80)
    print("ÚLTIMOS 10 REGISTROS:")
    print("=" * 80)
    print(df.tail(10).to_string())
    print()

    # Estadísticas de columnas numéricas
    print("=" * 80)
    print("ESTADÍSTICAS DE COLUMNAS NUMÉRICAS:")
    print("=" * 80)
    print(df.describe())
    print()

    # Valores únicos en columnas clave (si existen)
    columnas_clave = ['Tipo', 'Movimiento', 'TipoDoc', 'IC_ES']
    for col in columnas_clave:
        if col in df.columns:
            print(f"\nValores únicos en '{col}': {df[col].unique()}")

    # Guardar a CSV para análisis más fácil
    csv_file = r"d:\nuvol\sp\kardex_cremolada.csv"
    df.to_csv(csv_file, index=False, encoding='utf-8-sig')
    print()
    print(f"Archivo exportado a CSV: {csv_file}")

except Exception as e:
    print(f"Error al leer el archivo Excel: {e}")
    print()
    print("Intentando instalar dependencias necesarias...")
    import subprocess
    subprocess.run([sys.executable, "-m", "pip", "install", "xlrd", "openpyxl"], check=False)
    print("\nPor favor, ejecuta el script nuevamente después de instalar las dependencias.")
