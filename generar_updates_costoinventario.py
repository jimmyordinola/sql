import pandas as pd

try:
    file_path = r'd:\nuvol\sp\kardex cremolada por bolsa.xls'
    xls = pd.ExcelFile(file_path, engine='xlrd')

    df = pd.read_excel(xls, sheet_name='Sheet', skiprows=2)
    df.columns = df.iloc[0]
    df = df[1:]
    df.reset_index(drop=True, inplace=True)

    # Convertir columnas numéricas
    cols_num = ['Cantidad Entrada', 'Costo Entrada', 'Total Entrada',
                'Cantidad Salida', 'Costo Salida', 'Total Salida',
                'Saldo Cantidad', 'Saldo Costo', 'Saldo Total']
    for col in cols_num:
        df[col] = pd.to_numeric(df[col], errors='coerce').fillna(0)

    # Recalcular con costo promedio correcto
    saldo_cantidad = 0
    saldo_total = 0

    # Archivo SQL de salida
    sql_file = open(r'd:\nuvol\sp\UPDATE_CostoInventario_Correccion.sql', 'w', encoding='utf-8')

    sql_file.write("-- =====================================================\n")
    sql_file.write("-- SCRIPT DE CORRECCIÓN DE COSTOS EN CostoInventario\n")
    sql_file.write("-- Producto: CREMOLADA X BOLSA MARACUYA\n")
    sql_file.write("-- Generado automáticamente\n")
    sql_file.write("-- =====================================================\n\n")
    sql_file.write("USE [ERP_ECHA]\nGO\n\n")
    sql_file.write("BEGIN TRANSACTION\n\n")

    count = 0

    for idx, row in df.iterrows():
        fecha = str(row['Fecha Movimiento'])[:19]
        mov = str(row['Movimiento'])
        cant_entrada = row['Cantidad Entrada']
        costo_entrada = row['Costo Entrada']
        total_entrada = row['Total Entrada']
        cant_salida = row['Cantidad Salida']

        # Obtener código de inventario
        cd_inv = row.get('Codigo Inventario', '')
        if pd.isna(cd_inv) or cd_inv == '':
            cd_inv = row.get('Cd_Inv', '')
        if pd.isna(cd_inv) or cd_inv == '':
            cd_inv = row.get('CodigoInventario', '')

        costo_salida_original = row['Costo Salida']

        if cant_entrada > 0:
            # ENTRADA
            saldo_total = saldo_total + total_entrada
            saldo_cantidad = saldo_cantidad + cant_entrada
            costo_promedio = saldo_total / saldo_cantidad if saldo_cantidad > 0 else 0
        elif cant_salida > 0:
            # SALIDA - El costo correcto es el promedio actual
            costo_promedio = saldo_total / saldo_cantidad if saldo_cantidad > 0 else 0
            costo_salida_correcto = costo_promedio

            # Calcular diferencia
            diff = abs(costo_salida_original - costo_salida_correcto)

            if diff > 0.01 and not pd.isna(cd_inv) and cd_inv != '':
                count += 1
                sql_file.write(f"-- Fila {idx}: {fecha} | Cant: {cant_salida:.0f} | Actual: {costo_salida_original:.5f} -> Correcto: {costo_salida_correcto:.5f}\n")
                sql_file.write(f"UPDATE CostoInventario\n")
                sql_file.write(f"SET Costo_MN = {costo_salida_correcto:.10f},\n")
                sql_file.write(f"    Costo_ME = {costo_salida_correcto:.10f}\n")  # Ajustar si el TC es diferente
                sql_file.write(f"WHERE RucE = '20603091443'\n")
                sql_file.write(f"  AND Cd_Inv = '{cd_inv}'\n")
                sql_file.write(f"  AND IC_TipoCostoInventario = 'M';\n\n")

            # Actualizar saldo
            nuevo_total_salida = cant_salida * costo_promedio
            saldo_cantidad = saldo_cantidad - cant_salida
            saldo_total = saldo_total - nuevo_total_salida

    sql_file.write(f"\n-- Total de registros a actualizar: {count}\n\n")
    sql_file.write("-- Si todo está correcto, ejecutar:\n")
    sql_file.write("-- COMMIT TRANSACTION\n\n")
    sql_file.write("-- Si hay errores, ejecutar:\n")
    sql_file.write("-- ROLLBACK TRANSACTION\n")

    sql_file.close()

    print(f"Script SQL generado: UPDATE_CostoInventario_Correccion.sql")
    print(f"Total de registros a actualizar: {count}")

except Exception as e:
    print(f"Error: {str(e)}")
    import traceback
    traceback.print_exc()
