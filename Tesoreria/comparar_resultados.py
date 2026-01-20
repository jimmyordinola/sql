"""
Comparar resultados entre SP Original y SP Optimizado
Analiza el archivo RESULTADOS.xlsx
"""

import pandas as pd
import sys

def comparar_resultados(archivo_excel):
    print("=" * 60)
    print("COMPARACIÓN DE RESULTADOS: ORIGINAL vs OPTIMIZADO")
    print("=" * 60)
    print()

    # Leer ambas hojas
    try:
        df_original = pd.read_excel(archivo_excel, sheet_name='ORIGINAL')
        df_optimizado = pd.read_excel(archivo_excel, sheet_name='OPTIMIZAO')
    except Exception as e:
        print(f"Error al leer el archivo: {e}")
        return

    # 1. Comparar cantidad de registros
    print("1. CANTIDAD DE REGISTROS")
    print("-" * 40)
    print(f"   Original:   {len(df_original):,} registros")
    print(f"   Optimizado: {len(df_optimizado):,} registros")
    if len(df_original) == len(df_optimizado):
        print("   [OK] - Misma cantidad de registros")
    else:
        print(f"   [ERROR] DIFERENCIA: {abs(len(df_original) - len(df_optimizado)):,} registros")
    print()

    # 2. Comparar columnas
    print("2. COLUMNAS")
    print("-" * 40)
    cols_original = set(df_original.columns)
    cols_optimizado = set(df_optimizado.columns)

    if cols_original == cols_optimizado:
        print(f"   [OK] OK - Mismas {len(cols_original)} columnas")
    else:
        solo_original = cols_original - cols_optimizado
        solo_optimizado = cols_optimizado - cols_original
        if solo_original:
            print(f"   Solo en Original: {solo_original}")
        if solo_optimizado:
            print(f"   Solo en Optimizado: {solo_optimizado}")
    print()

    # 3. Comparar datos fila por fila
    print("3. COMPARACIÓN DE DATOS")
    print("-" * 40)

    # Usar columnas comunes para comparación
    cols_comunes = list(cols_original & cols_optimizado)

    # Ordenar ambos DataFrames por las mismas columnas para comparar
    # Identificar columnas clave para ordenar
    cols_clave = ['Cd_Vou', 'NroCta', 'DR_NDoc', 'Cd_Clt', 'Cd_Prv']
    cols_ordenar = [c for c in cols_clave if c in cols_comunes]

    if cols_ordenar:
        df_orig_sorted = df_original[cols_comunes].sort_values(by=cols_ordenar).reset_index(drop=True)
        df_opt_sorted = df_optimizado[cols_comunes].sort_values(by=cols_ordenar).reset_index(drop=True)
    else:
        df_orig_sorted = df_original[cols_comunes].reset_index(drop=True)
        df_opt_sorted = df_optimizado[cols_comunes].reset_index(drop=True)

    # Comparar si son iguales
    if len(df_orig_sorted) == len(df_opt_sorted):
        # Comparar contenido
        try:
            # Convertir a string para comparación más robusta
            comparison = df_orig_sorted.astype(str).eq(df_opt_sorted.astype(str))
            filas_diferentes = (~comparison.all(axis=1)).sum()

            if filas_diferentes == 0:
                print("   [OK] OK - Todos los datos son idénticos")
            else:
                print(f"   [X] {filas_diferentes:,} filas con diferencias")

                # Mostrar detalle de diferencias por columna
                print()
                print("   Diferencias por columna:")
                for col in cols_comunes:
                    diff_count = (~comparison[col]).sum()
                    if diff_count > 0:
                        print(f"      - {col}: {diff_count:,} valores diferentes")
        except Exception as e:
            print(f"   Error en comparación: {e}")
    else:
        print("   No se puede comparar fila a fila - diferente cantidad de registros")
    print()

    # 4. Comparar totales numéricos
    print("4. COMPARACIÓN DE TOTALES NUMÉRICOS")
    print("-" * 40)

    cols_numericas = ['SaldoS', 'SaldoD', 'MtoD', 'MtoH']
    for col in cols_numericas:
        if col in cols_comunes:
            try:
                total_orig = pd.to_numeric(df_original[col], errors='coerce').sum()
                total_opt = pd.to_numeric(df_optimizado[col], errors='coerce').sum()
                diff = abs(total_orig - total_opt)

                if diff < 0.01:  # Tolerancia para decimales
                    status = "[OK]"
                else:
                    status = "[X]"

                print(f"   {col}:")
                print(f"      Original:   {total_orig:,.2f}")
                print(f"      Optimizado: {total_opt:,.2f}")
                print(f"      Diferencia: {diff:,.2f} {status}")
                print()
            except Exception as e:
                print(f"   {col}: Error al calcular - {e}")

    # 5. Resumen final
    print("=" * 60)
    print("RESUMEN")
    print("=" * 60)

    problemas = []
    if len(df_original) != len(df_optimizado):
        problemas.append(f"Diferencia en cantidad de registros: {abs(len(df_original) - len(df_optimizado))}")

    if cols_original != cols_optimizado:
        problemas.append("Diferencia en columnas")

    if not problemas:
        print("[OK] Los resultados son consistentes")
    else:
        print("[X] Se encontraron diferencias:")
        for p in problemas:
            print(f"   - {p}")

if __name__ == "__main__":
    archivo = r"d:\nuvol\sp\Tesoreria\RESULTADOS.xlsx"
    comparar_resultados(archivo)
