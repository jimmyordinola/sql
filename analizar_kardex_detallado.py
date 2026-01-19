import pandas as pd

try:
    file_path = r'd:\nuvol\sp\kardex cremolada por bolsa.xls'
    xls = pd.ExcelFile(file_path, engine='xlrd')

    df = pd.read_excel(xls, sheet_name='Sheet', skiprows=2)
    df.columns = df.iloc[0]
    df = df[1:]
    df.reset_index(drop=True, inplace=True)

    # Convertir columnas numéricas
    df['Cantidad Entrada'] = pd.to_numeric(df['Cantidad Entrada'], errors='coerce')
    df['Costo Entrada'] = pd.to_numeric(df['Costo Entrada'], errors='coerce')
    df['Total Entrada'] = pd.to_numeric(df['Total Entrada'], errors='coerce')
    df['Cantidad Salida'] = pd.to_numeric(df['Cantidad Salida'], errors='coerce')
    df['Costo Salida'] = pd.to_numeric(df['Costo Salida'], errors='coerce')
    df['Total Salida'] = pd.to_numeric(df['Total Salida'], errors='coerce')
    df['Saldo Cantidad'] = pd.to_numeric(df['Saldo Cantidad'], errors='coerce')
    df['Saldo Costo'] = pd.to_numeric(df['Saldo Costo'], errors='coerce')
    df['Saldo Total'] = pd.to_numeric(df['Saldo Total'], errors='coerce')

    print("="*120)
    print("ANÁLISIS DETALLADO DEL KARDEX - CREMOLADA X BOLSA MARACUYA")
    print("="*120)
    print()

    # Mostrar todos los movimientos con detalle
    print("Nro | Fecha/Hora          | Mov    | Cant.E | Costo.E  | Total.E    | Cant.S | Costo.S  | Total.S    | Saldo.Q | Saldo.Costo | Saldo.Total  | Tipo Operacion")
    print("-"*120)

    for idx, row in df.iterrows():
        fecha = str(row['Fecha Movimiento'])[:19] if len(str(row['Fecha Movimiento'])) > 10 else str(row['Fecha Movimiento'])
        mov = row['Movimiento']
        cant_e = row['Cantidad Entrada'] if pd.notna(row['Cantidad Entrada']) else 0
        costo_e = row['Costo Entrada'] if pd.notna(row['Costo Entrada']) else 0
        total_e = row['Total Entrada'] if pd.notna(row['Total Entrada']) else 0
        cant_s = row['Cantidad Salida'] if pd.notna(row['Cantidad Salida']) else 0
        costo_s = row['Costo Salida'] if pd.notna(row['Costo Salida']) else 0
        total_s = row['Total Salida'] if pd.notna(row['Total Salida']) else 0
        saldo_q = row['Saldo Cantidad'] if pd.notna(row['Saldo Cantidad']) else 0
        saldo_c = row['Saldo Costo'] if pd.notna(row['Saldo Costo']) else 0
        saldo_t = row['Saldo Total'] if pd.notna(row['Saldo Total']) else 0
        tipo_op = str(row['Tipo Operacion'])[:2] if pd.notna(row['Tipo Operacion']) else ''
        tipo_op_nombre = str(row['Nombre Tipo Operacion'])[:18] if pd.notna(row['Nombre Tipo Operacion']) else ''

        # Marcar en rojo si hay valores negativos
        negativo = " <<<< NEGATIVO" if saldo_c < 0 or saldo_t < 0 else ""
        problema = " ** COSTO ENTRADA BAJO **" if cant_e > 0 and costo_e < 5 and costo_e > 0 else ""

        print(f"{idx:3d} | {fecha:19s} | {mov:6s} | {cant_e:6.0f} | {costo_e:8.5f} | {total_e:10.2f} | {cant_s:6.0f} | {costo_s:8.5f} | {total_s:10.2f} | {saldo_q:7.0f} | {saldo_c:11.5f} | {saldo_t:12.2f} | {tipo_op:2s}-{tipo_op_nombre:18s}{negativo}{problema}")

    print()
    print("="*120)
    print("RESUMEN DE ENTRADAS")
    print("="*120)

    entradas = df[df['Cantidad Entrada'] > 0].copy()
    print(f"\nTotal de entradas: {len(entradas)}")
    print()
    print("Fecha               | Cantidad | Costo Unit | Total Entrada | Tipo Operacion")
    print("-"*90)
    for idx, row in entradas.iterrows():
        fecha = str(row['Fecha Movimiento'])[:19]
        cant = row['Cantidad Entrada']
        costo = row['Costo Entrada']
        total = row['Total Entrada']
        tipo_op = str(row['Tipo Operacion']) if pd.notna(row['Tipo Operacion']) else ''
        tipo_op_nombre = str(row['Nombre Tipo Operacion']) if pd.notna(row['Nombre Tipo Operacion']) else ''

        print(f"{fecha:19s} | {cant:8.0f} | {costo:10.5f} | {total:13.2f} | {tipo_op}-{tipo_op_nombre}")

    print()
    print("="*120)
    print("ANÁLISIS DE COSTO PROMEDIO")
    print("="*120)
    print()

    # Calcular costo promedio manual
    print("Verificación del cálculo de costo promedio:")
    print()
    for idx, row in df.iterrows():
        if idx >= 35 and idx <= 45:  # Rango crítico alrededor del día 7
            fecha = str(row['Fecha Movimiento'])[:19]
            mov = row['Movimiento']
            saldo_q = row['Saldo Cantidad']
            saldo_c = row['Saldo Costo']
            saldo_t = row['Saldo Total']

            # Calcular costo promedio esperado
            costo_prom_esperado = saldo_t / saldo_q if saldo_q != 0 else 0
            coincide = "OK" if abs(costo_prom_esperado - saldo_c) < 0.01 else "ERROR"

            print(f"{idx:3d} | {fecha:19s} | {mov:7s} | Saldo Q: {saldo_q:6.0f} | Saldo Total: {saldo_t:12.2f} | Costo Unit DB: {saldo_c:10.5f} | Costo Esperado: {costo_prom_esperado:10.5f} | {coincide}")

except Exception as e:
    print(f"Error: {str(e)}")
    import traceback
    traceback.print_exc()
