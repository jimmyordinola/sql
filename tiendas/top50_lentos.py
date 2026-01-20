"""
Top 50 SPs más lentos de Extended Events
"""

import pandas as pd
import sys
import io

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

archivo = r"d:\nuvol\sp\tiendas\eventos.xlsx"

df = pd.read_excel(archivo, sheet_name='Sheet1')
df['Duracion_seg'] = df['Duracion_us'] / 1000000
df['CPU_seg'] = df['CPU_us'] / 1000000

# Agrupar por SP
df_sp = df[df['Objeto'].notna()].copy()

resumen = df_sp.groupby('Objeto').agg({
    'Duracion_seg': ['count', 'sum', 'mean', 'max'],
    'Lecturas_Logicas': ['sum', 'mean', 'max'],
    'CPU_seg': 'sum'
}).round(2)

resumen.columns = ['Ejec', 'T_Total_seg', 'T_Prom_seg', 'T_Max_seg',
                   'Lect_Total', 'Lect_Prom', 'Lect_Max', 'CPU_Total_seg']

# Ordenar por tiempo total
resumen = resumen.sort_values('T_Total_seg', ascending=False)

print("=" * 140)
print("TOP 50 STORED PROCEDURES MAS LENTOS (por tiempo total acumulado)")
print("=" * 140)
print(f"\n{'#':<3} {'SP':<60} {'Ejec':<7} {'T.Total':<10} {'T.Prom':<9} {'T.Max':<9} {'Lect.Prom':<12} {'Lect.Max':<12}")
print("-" * 140)

for i, (sp, row) in enumerate(resumen.head(50).iterrows(), 1):
    sp_name = str(sp)[:57]
    t_total = f"{row['T_Total_seg']:,.0f}s"
    t_prom = f"{row['T_Prom_seg']:.1f}s"
    t_max = f"{row['T_Max_seg']:.0f}s"
    lect_prom = f"{row['Lect_Prom']:,.0f}"
    lect_max = f"{row['Lect_Max']:,.0f}"
    print(f"{i:<3} {sp_name:<60} {row['Ejec']:<7.0f} {t_total:<10} {t_prom:<9} {t_max:<9} {lect_prom:<12} {lect_max:<12}")

# Resumen
print("\n" + "=" * 140)
print("RESUMEN TOP 50")
print("=" * 140)
top50 = resumen.head(50)
print(f"Tiempo total acumulado: {top50['T_Total_seg'].sum():,.0f} seg ({top50['T_Total_seg'].sum()/3600:.1f} horas)")
print(f"Lecturas totales: {top50['Lect_Total'].sum():,.0f}")
print(f"Ejecuciones totales: {top50['Ejec'].sum():,.0f}")
