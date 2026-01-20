import pandas as pd

archivo = r"d:\nuvol\sp\Tesoreria\RESULTADOS.xlsx"
xl = pd.ExcelFile(archivo)
print("Hojas en el archivo:")
for i, sheet in enumerate(xl.sheet_names):
    print(f"  {i+1}. '{sheet}'")
    df = pd.read_excel(archivo, sheet_name=sheet)
    print(f"     Filas: {len(df)}, Columnas: {len(df.columns)}")
