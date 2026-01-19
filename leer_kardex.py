import pandas as pd
import sys

try:
    # Intentar leer el archivo .xls
    file_path = r'd:\nuvol\sp\kardex cremolada por bolsa.xls'

    # Leer todas las hojas del archivo
    xls = pd.ExcelFile(file_path, engine='xlrd')

    print(f"Hojas encontradas: {xls.sheet_names}\n")

    # Leer la primera hoja (o todas si hay múltiples)
    for sheet_name in xls.sheet_names:
        print(f"\n{'='*80}")
        print(f"HOJA: {sheet_name}")
        print(f"{'='*80}\n")

        # Leer con skiprows para saltar las primeras filas de encabezado
        df = pd.read_excel(xls, sheet_name=sheet_name, skiprows=2)

        # Usar la primera fila como encabezado
        df.columns = df.iloc[0]
        df = df[1:]  # Eliminar la fila de encabezado que ahora es data
        df.reset_index(drop=True, inplace=True)

        print(f"Dimensiones: {df.shape[0]} filas x {df.shape[1]} columnas")
        print(f"\nColumnas: {list(df.columns)}\n")

        # Mostrar las primeras filas
        print("Primeras 20 filas:")
        print(df.head(20).to_string())

        # Buscar columnas que podrían contener saldos/stock
        posibles_columnas_saldo = [col for col in df.columns if any(
            keyword in str(col).lower()
            for keyword in ['saldo', 'stock', 'cantidad', 'cant', 'existencia', 'balance']
        )]

        if posibles_columnas_saldo:
            print(f"\n\nColumnas de saldo/stock detectadas: {posibles_columnas_saldo}")

            # Buscar valores negativos en esas columnas
            for col in posibles_columnas_saldo:
                try:
                    negativos = df[df[col] < 0]
                    if not negativos.empty:
                        print(f"\n{'*'*80}")
                        print(f"VALORES NEGATIVOS EN COLUMNA: {col}")
                        print(f"{'*'*80}")
                        print(f"Total de registros negativos: {len(negativos)}")
                        print(f"\nRegistros con valores negativos:")
                        print(negativos.to_string())
                except:
                    pass

        # Mostrar estadísticas de todas las columnas numéricas
        print(f"\n\nEstadísticas de columnas numéricas:")
        print(df.describe().to_string())

except Exception as e:
    print(f"Error al leer el archivo: {str(e)}")
    import traceback
    traceback.print_exc()
