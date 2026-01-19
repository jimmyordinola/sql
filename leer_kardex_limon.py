import pandas as pd

# Leer el archivo Excel del kardex limón
excel_file = r"d:\nuvol\sp\kardex limon.xls"

try:
    df = pd.read_excel(excel_file, engine='xlrd')

    print("=" * 80)
    print("ESTRUCTURA DEL KARDEX - LIMÓN")
    print("=" * 80)
    print()

    print(f"Total de registros: {len(df)}")
    print(f"Columnas ({len(df.columns)}): {', '.join(df.columns.tolist()[:10])}...")
    print()

    # Mostrar primeros registros
    print("=" * 80)
    print("PRIMEROS 10 REGISTROS:")
    print("=" * 80)
    print(df.head(10).to_string())
    print()

    # Guardar a CSV
    csv_file = r"d:\nuvol\sp\kardex_limon.csv"
    df.to_csv(csv_file, index=False, encoding='utf-8-sig')
    print(f"Archivo exportado a CSV: {csv_file}")
    print()

except Exception as e:
    print(f"Error al leer el archivo Excel: {e}")
