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

    print("=" * 140)
    print("RECALCULO DEL KARDEX CON COSTO PROMEDIO PONDERADO CORRECTO")
    print("=" * 140)
    print()

    # Variables para el recálculo
    saldo_cantidad = 0
    saldo_total = 0

    # Listas para guardar los valores recalculados
    recalc_saldo_q = []
    recalc_saldo_costo = []
    recalc_saldo_total = []
    recalc_costo_salida = []
    recalc_total_salida = []
    diferencias = []

    print("Nro | Fecha               | Mov     | Cant.E | Costo.E  | Total.E    | Cant.S | Costo.S  | Total.S    | Saldo.Q | Costo Prom | Saldo.Total  | Estado")
    print("-" * 140)

    for idx, row in df.iterrows():
        fecha = str(row['Fecha Movimiento'])[:19]
        mov = str(row['Movimiento'])
        cant_entrada = row['Cantidad Entrada']
        costo_entrada = row['Costo Entrada']
        total_entrada = row['Total Entrada']
        cant_salida = row['Cantidad Salida']

        # Valores originales del sistema
        orig_costo_salida = row['Costo Salida']
        orig_total_salida = row['Total Salida']
        orig_saldo_q = row['Saldo Cantidad']
        orig_saldo_c = row['Saldo Costo']
        orig_saldo_t = row['Saldo Total']

        if cant_entrada > 0:
            # ENTRADA: Recalcular costo promedio ponderado
            # Fórmula: (Saldo Total Anterior + Total Entrada) / (Cantidad Anterior + Cantidad Entrada)
            saldo_total = saldo_total + total_entrada
            saldo_cantidad = saldo_cantidad + cant_entrada
            costo_promedio = saldo_total / saldo_cantidad if saldo_cantidad > 0 else 0

            nuevo_costo_salida = 0
            nuevo_total_salida = 0

        elif cant_salida > 0:
            # SALIDA: Usar el costo promedio actual
            costo_promedio = saldo_total / saldo_cantidad if saldo_cantidad > 0 else 0

            nuevo_costo_salida = costo_promedio
            nuevo_total_salida = cant_salida * costo_promedio

            saldo_cantidad = saldo_cantidad - cant_salida
            saldo_total = saldo_total - nuevo_total_salida

            # Recalcular costo promedio después de la salida (debería mantenerse igual)
            costo_promedio = saldo_total / saldo_cantidad if saldo_cantidad > 0 else 0
        else:
            costo_promedio = saldo_total / saldo_cantidad if saldo_cantidad > 0 else 0
            nuevo_costo_salida = 0
            nuevo_total_salida = 0

        # Guardar valores recalculados
        recalc_saldo_q.append(saldo_cantidad)
        recalc_saldo_costo.append(costo_promedio)
        recalc_saldo_total.append(saldo_total)
        recalc_costo_salida.append(nuevo_costo_salida)
        recalc_total_salida.append(nuevo_total_salida)

        # Verificar diferencias
        diff_total = abs(saldo_total - orig_saldo_t)
        hay_problema = ""
        if diff_total > 1:
            hay_problema = f"DIFF: {orig_saldo_t - saldo_total:+.2f}"
        if saldo_total < 0 or saldo_cantidad < 0:
            hay_problema = "ERROR NEGATIVO"
        if orig_saldo_t < 0:
            hay_problema = "ORIG NEGATIVO -> CORREGIDO"

        diferencias.append(hay_problema)

        # Imprimir
        costo_sal_mostrar = nuevo_costo_salida if cant_salida > 0 else 0
        total_sal_mostrar = nuevo_total_salida if cant_salida > 0 else 0

        print(f"{idx:3d} | {fecha:19s} | {mov:7s} | {cant_entrada:6.0f} | {costo_entrada:8.4f} | {total_entrada:10.2f} | {cant_salida:6.0f} | {costo_sal_mostrar:8.4f} | {total_sal_mostrar:10.2f} | {saldo_cantidad:7.0f} | {costo_promedio:10.4f} | {saldo_total:12.2f} | {hay_problema}")

    # Crear DataFrame con comparación
    print()
    print("=" * 140)
    print("COMPARACION: VALORES ORIGINALES vs RECALCULADOS")
    print("=" * 140)
    print()

    print("Nro | Fecha               | Orig.Saldo.T | Recalc.Saldo.T | Diferencia  | Orig.Costo.S | Recalc.Costo.S")
    print("-" * 110)

    for idx, row in df.iterrows():
        fecha = str(row['Fecha Movimiento'])[:19]
        orig_saldo_t = row['Saldo Total']
        orig_costo_s = row['Costo Salida']

        diff = orig_saldo_t - recalc_saldo_total[idx]

        if abs(diff) > 0.01 or orig_saldo_t < 0:
            print(f"{idx:3d} | {fecha:19s} | {orig_saldo_t:12.2f} | {recalc_saldo_total[idx]:14.2f} | {diff:+11.2f} | {orig_costo_s:12.4f} | {recalc_costo_salida[idx]:14.4f}")

    print()
    print("=" * 140)
    print("RESUMEN FINAL")
    print("=" * 140)
    print()
    print(f"Saldo Final Cantidad:     {saldo_cantidad:,.0f} unidades")
    print(f"Saldo Final Total:        S/ {saldo_total:,.2f}")
    print(f"Costo Promedio Final:     S/ {saldo_total/saldo_cantidad if saldo_cantidad > 0 else 0:,.4f}")
    print()

    # Comparar con original
    ultimo_orig_q = df['Saldo Cantidad'].iloc[-1]
    ultimo_orig_t = df['Saldo Total'].iloc[-1]
    ultimo_orig_c = df['Saldo Costo'].iloc[-1]

    print("COMPARACION CON ULTIMO REGISTRO ORIGINAL:")
    print(f"  Original  -> Cantidad: {ultimo_orig_q:,.0f} | Costo: {ultimo_orig_c:,.4f} | Total: S/ {ultimo_orig_t:,.2f}")
    print(f"  Recalculo -> Cantidad: {saldo_cantidad:,.0f} | Costo: {saldo_total/saldo_cantidad if saldo_cantidad > 0 else 0:,.4f} | Total: S/ {saldo_total:,.2f}")
    print(f"  Diferencia en Total: S/ {ultimo_orig_t - saldo_total:+,.2f}")

except Exception as e:
    print(f"Error: {str(e)}")
    import traceback
    traceback.print_exc()
