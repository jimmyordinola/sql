"""
Top 50 SPs - Tiempos Min, Max, Promedio
"""

import pandas as pd
import sys
import io

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

archivo = r"d:\nuvol\sp\tiendas\eventos.xlsx"

df = pd.read_excel(archivo, sheet_name='Sheet1')
df['Duracion_seg'] = df['Duracion_us'] / 1000000

# Agrupar por SP
df_sp = df[df['Objeto'].notna()].copy()

resumen = df_sp.groupby('Objeto').agg({
    'Duracion_seg': ['count', 'sum', 'min', 'max', 'mean'],
    'Lecturas_Logicas': ['min', 'max', 'mean']
}).round(2)

resumen.columns = ['Ejec', 'T_Total', 'T_Min', 'T_Max', 'T_Prom', 'Lect_Min', 'Lect_Max', 'Lect_Prom']

# Ordenar por tiempo total
resumen = resumen.sort_values('T_Total', ascending=False)

print("=" * 160)
print("TOP 50 STORED PROCEDURES - TIEMPOS MINIMO, MAXIMO Y PROMEDIO")
print("=" * 160)
print(f"\n{'#':<3} {'SP':<55} {'Ejec':<6} {'T.Total':<9} {'T.Min':<8} {'T.Max':<8} {'T.Prom':<8} {'Lect.Min':<12} {'Lect.Max':<14} {'Lect.Prom':<12}")
print("-" * 160)

for i, (sp, row) in enumerate(resumen.head(50).iterrows(), 1):
    sp_name = str(sp)[:52]
    t_total = f"{row['T_Total']:,.0f}s"
    t_min = f"{row['T_Min']:.2f}s"
    t_max = f"{row['T_Max']:.1f}s"
    t_prom = f"{row['T_Prom']:.2f}s"
    lect_min = f"{row['Lect_Min']:,.0f}"
    lect_max = f"{row['Lect_Max']:,.0f}"
    lect_prom = f"{row['Lect_Prom']:,.0f}"
    print(f"{i:<3} {sp_name:<55} {row['Ejec']:<6.0f} {t_total:<9} {t_min:<8} {t_max:<8} {t_prom:<8} {lect_min:<12} {lect_max:<14} {lect_prom:<12}")

print("\n" + "=" * 160)
print("LEYENDA:")
print("  T.Total = Tiempo total acumulado (segundos)")
print("  T.Min   = Tiempo mínimo de una ejecución (segundos)")
print("  T.Max   = Tiempo máximo de una ejecución (segundos)")
print("  T.Prom  = Tiempo promedio por ejecución (segundos)")
print("  Lect.*  = Lecturas lógicas (I/O)")
print("=" * 160)
