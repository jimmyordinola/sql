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

    correcciones = []

    print("=" * 150)
    print("CORRECCIONES NECESARIAS EN CostoInventario")
    print("=" * 150)
    print()
    print(f"{'Fila':<5} | {'Cd_Inv':<15} | {'Fecha':<20} | {'Mov':<8} | {'Cant':<6} | {'Costo Actual':<14} | {'Costo Correcto':<14} | {'Diferencia':<12}")
    print("-" * 150)

    for idx, row in df.iterrows():
        fecha = str(row['Fecha Movimiento'])[:19]
        mov = str(row['Movimiento'])
        cant_entrada = row['Cantidad Entrada']
        costo_entrada = row['Costo Entrada']
        total_entrada = row['Total Entrada']
        cant_salida = row['Cantidad Salida']

        # Obtener código de inventario si existe
        cd_inv = row.get('Codigo Inventario', row.get('Cd_Inv', row.get('CodigoInventario', '')))
        if pd.isna(cd_inv):
            cd_inv = f"MOV_{idx}"

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

            if diff > 0.01:  # Solo mostrar si hay diferencia significativa
                print(f"{idx:<5} | {str(cd_inv):<15} | {fecha:<20} | {mov:<8} | {cant_salida:<6.0f} | {costo_salida_original:<14.5f} | {costo_salida_correcto:<14.5f} | {costo_salida_original - costo_salida_correcto:<+12.5f}")

                correcciones.append({
                    'fila': idx,
                    'fecha': fecha,
                    'cantidad': cant_salida,
                    'costo_actual': costo_salida_original,
                    'costo_correcto': costo_salida_correcto,
                    'diferencia': costo_salida_original - costo_salida_correcto
                })

            # Actualizar saldo
            nuevo_total_salida = cant_salida * costo_promedio
            saldo_cantidad = saldo_cantidad - cant_salida
            saldo_total = saldo_total - nuevo_total_salida

    print()
    print("=" * 150)
    print(f"RESUMEN: {len(correcciones)} registros de SALIDA necesitan corrección")
    print("=" * 150)
    print()

    # Mostrar el problema principal
    print("PROBLEMA DETECTADO:")
    print(f"  - Todas las salidas usan costo fijo: 19.82273")
    print(f"  - Deberían usar el costo promedio ponderado que varía según las entradas")
    print()

    # Mostrar ejemplo de UPDATE SQL
    print("EJEMPLO DE UPDATE SQL para CostoInventario:")
    print("-" * 80)
    print("""
-- Para cada salida, el Costo_MN y Costo_ME debe ser el costo promedio
-- calculado ANTES de esa salida, NO el costo fijo 19.82273

-- El UPDATE debe hacerse por cada movimiento de salida:
UPDATE CostoInventario
SET
    Costo_MN = <costo_promedio_correcto>,
    Costo_ME = <costo_promedio_correcto_ME>
WHERE
    RucE = '20603091443'  -- Tu RUC
    AND Cd_Inv = '<codigo_inventario>'
    AND Item = <numero_item>
    AND IC_TipoCostoInventario = 'M'
""")

except Exception as e:
    print(f"Error: {str(e)}")
    import traceback
    traceback.print_exc()
