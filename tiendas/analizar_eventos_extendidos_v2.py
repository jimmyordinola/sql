"""
Análisis Completo de Extended Events - SQL Server
Objetivo: Identificar consultas lentas, SPs problemáticos y oportunidades de optimización
"""

import pandas as pd
import numpy as np
import sys
import io
import re
from collections import Counter

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

archivo = r"d:\nuvol\sp\tiendas\eventos.xlsx"

print("=" * 100)
print("ANALISIS DE EXTENDED EVENTS - SQL SERVER")
print("=" * 100)

# Cargar datos
df = pd.read_excel(archivo, sheet_name='Sheet1')

# Convertir duración a milisegundos y segundos
df['Duracion_ms'] = df['Duracion_us'] / 1000
df['Duracion_seg'] = df['Duracion_us'] / 1000000
df['CPU_ms'] = df['CPU_us'] / 1000

print(f"\nTotal de eventos: {len(df):,}")
print(f"Período: {df['Fecha_Hora'].min()} a {df['Fecha_Hora'].max()}")

# ============================================
# RESUMEN GENERAL
# ============================================
print("\n" + "=" * 100)
print("1. RESUMEN GENERAL")
print("=" * 100)

print(f"""
METRICAS TOTALES:
  - Tiempo total de ejecución: {df['Duracion_seg'].sum():,.0f} segundos ({df['Duracion_seg'].sum()/60:,.1f} minutos)
  - CPU total consumido: {df['CPU_ms'].sum()/1000:,.0f} segundos
  - Lecturas lógicas totales: {df['Lecturas_Logicas'].sum():,.0f}
  - Lecturas físicas totales: {df['Lecturas_Fisicas'].sum():,.0f}
  - Escrituras totales: {df['Escrituras'].sum():,.0f}

PROMEDIOS POR EVENTO:
  - Duración promedio: {df['Duracion_ms'].mean():,.0f} ms ({df['Duracion_seg'].mean():,.2f} seg)
  - CPU promedio: {df['CPU_ms'].mean():,.0f} ms
  - Lecturas lógicas promedio: {df['Lecturas_Logicas'].mean():,.0f}
""")

# ============================================
# TOP 30 CONSULTAS MAS LENTAS
# ============================================
print("\n" + "=" * 100)
print("2. TOP 30 CONSULTAS MAS LENTAS (por Duración)")
print("=" * 100)

top_lentas = df.nlargest(30, 'Duracion_us')[['Objeto', 'Duracion_seg', 'CPU_ms', 'Lecturas_Logicas', 'Lecturas_Fisicas', 'Escrituras', 'Filas', 'Fecha_Hora']].copy()

print(f"\n{'#':<3} {'Objeto/SP':<55} {'Dur(seg)':<10} {'CPU(ms)':<12} {'Lecturas':<15} {'Filas':<10}")
print("-" * 115)

for i, (idx, row) in enumerate(top_lentas.iterrows(), 1):
    obj = str(row['Objeto'])[:50] if pd.notna(row['Objeto']) else 'N/A'
    dur = f"{row['Duracion_seg']:,.1f}" if pd.notna(row['Duracion_seg']) else "N/A"
    cpu = f"{row['CPU_ms']:,.0f}" if pd.notna(row['CPU_ms']) else "N/A"
    reads = f"{row['Lecturas_Logicas']:,.0f}" if pd.notna(row['Lecturas_Logicas']) else "N/A"
    rows = f"{row['Filas']:,.0f}" if pd.notna(row['Filas']) else "N/A"
    print(f"{i:<3} {obj:<55} {dur:<10} {cpu:<12} {reads:<15} {rows:<10}")

# ============================================
# TOP 30 CONSULTAS CON MAS LECTURAS
# ============================================
print("\n" + "=" * 100)
print("3. TOP 30 CONSULTAS CON MAS LECTURAS LOGICAS (I/O)")
print("=" * 100)

top_reads = df.nlargest(30, 'Lecturas_Logicas')[['Objeto', 'Lecturas_Logicas', 'Duracion_seg', 'CPU_ms', 'Filas']].copy()

print(f"\n{'#':<3} {'Objeto/SP':<55} {'Lecturas':<18} {'Dur(seg)':<10} {'CPU(ms)':<12} {'Filas':<10}")
print("-" * 115)

for i, (idx, row) in enumerate(top_reads.iterrows(), 1):
    obj = str(row['Objeto'])[:50] if pd.notna(row['Objeto']) else 'N/A'
    reads = f"{row['Lecturas_Logicas']:,.0f}" if pd.notna(row['Lecturas_Logicas']) else "N/A"
    dur = f"{row['Duracion_seg']:,.1f}" if pd.notna(row['Duracion_seg']) else "N/A"
    cpu = f"{row['CPU_ms']:,.0f}" if pd.notna(row['CPU_ms']) else "N/A"
    rows = f"{row['Filas']:,.0f}" if pd.notna(row['Filas']) else "N/A"
    print(f"{i:<3} {obj:<55} {reads:<18} {dur:<10} {cpu:<12} {rows:<10}")

# ============================================
# ANALISIS POR STORED PROCEDURE
# ============================================
print("\n" + "=" * 100)
print("4. ANALISIS POR STORED PROCEDURE (Agregado)")
print("=" * 100)

# Filtrar solo los que tienen objeto (SP)
df_sp = df[df['Objeto'].notna()].copy()

resumen_sp = df_sp.groupby('Objeto').agg({
    'Duracion_seg': ['count', 'sum', 'mean', 'max'],
    'Lecturas_Logicas': ['sum', 'mean', 'max'],
    'CPU_ms': ['sum', 'mean'],
    'Filas': 'sum'
}).round(2)

resumen_sp.columns = ['Ejecuciones', 'Tiempo_Total_seg', 'Tiempo_Prom_seg', 'Tiempo_Max_seg',
                       'Lecturas_Total', 'Lecturas_Prom', 'Lecturas_Max',
                       'CPU_Total_ms', 'CPU_Prom_ms', 'Filas_Total']

# Ordenar por tiempo total
resumen_sp = resumen_sp.sort_values('Tiempo_Total_seg', ascending=False)

print("\nTOP 25 SPs POR TIEMPO TOTAL ACUMULADO:")
print("-" * 130)
print(f"{'SP':<60} {'Ejec':<8} {'T.Total(s)':<12} {'T.Prom(s)':<12} {'T.Max(s)':<12} {'Lect.Total':<15} {'Lect.Prom':<12}")
print("-" * 130)

for i, (sp, row) in enumerate(resumen_sp.head(25).iterrows(), 1):
    sp_name = str(sp)[:55]
    print(f"{sp_name:<60} {row['Ejecuciones']:<8.0f} {row['Tiempo_Total_seg']:<12,.1f} {row['Tiempo_Prom_seg']:<12,.2f} {row['Tiempo_Max_seg']:<12,.1f} {row['Lecturas_Total']:<15,.0f} {row['Lecturas_Prom']:<12,.0f}")

# ============================================
# SPs CON MAYOR TIEMPO PROMEDIO
# ============================================
print("\n" + "=" * 100)
print("5. SPs CON MAYOR TIEMPO PROMEDIO (mínimo 5 ejecuciones)")
print("=" * 100)

resumen_sp_filtrado = resumen_sp[resumen_sp['Ejecuciones'] >= 5].sort_values('Tiempo_Prom_seg', ascending=False)

print(f"\n{'SP':<60} {'Ejec':<8} {'T.Prom(s)':<12} {'T.Max(s)':<12} {'Lect.Prom':<15}")
print("-" * 110)

for i, (sp, row) in enumerate(resumen_sp_filtrado.head(20).iterrows(), 1):
    sp_name = str(sp)[:55]
    print(f"{sp_name:<60} {row['Ejecuciones']:<8.0f} {row['Tiempo_Prom_seg']:<12,.2f} {row['Tiempo_Max_seg']:<12,.1f} {row['Lecturas_Prom']:<15,.0f}")

# ============================================
# ANALISIS DE PATRONES PROBLEMATICOS
# ============================================
print("\n" + "=" * 100)
print("6. EVENTOS CRITICOS (>30 segundos o >1M lecturas)")
print("=" * 100)

criticos = df[(df['Duracion_seg'] > 30) | (df['Lecturas_Logicas'] > 1000000)]
print(f"\nEventos críticos encontrados: {len(criticos)}")

if len(criticos) > 0:
    print(f"\n{'Objeto':<50} {'Dur(seg)':<12} {'Lecturas':<15} {'Fecha/Hora'}")
    print("-" * 100)
    for idx, row in criticos.head(30).iterrows():
        obj = str(row['Objeto'])[:45] if pd.notna(row['Objeto']) else 'N/A'
        dur = f"{row['Duracion_seg']:,.1f}"
        reads = f"{row['Lecturas_Logicas']:,.0f}"
        fecha = str(row['Fecha_Hora'])[:19] if pd.notna(row['Fecha_Hora']) else 'N/A'
        print(f"{obj:<50} {dur:<12} {reads:<15} {fecha}")

# ============================================
# DISTRIBUCION POR RANGO DE TIEMPO
# ============================================
print("\n" + "=" * 100)
print("7. DISTRIBUCION DE EVENTOS POR RANGO DE DURACION")
print("=" * 100)

bins = [0, 1, 2, 5, 10, 30, 60, 120, 300, 600, float('inf')]
labels = ['0-1s', '1-2s', '2-5s', '5-10s', '10-30s', '30-60s', '1-2min', '2-5min', '5-10min', '>10min']

df['Rango_Duracion'] = pd.cut(df['Duracion_seg'], bins=bins, labels=labels)

distribucion = df.groupby('Rango_Duracion', observed=True).agg({
    'Duracion_seg': ['count', 'sum'],
    'Lecturas_Logicas': 'sum'
}).round(0)

distribucion.columns = ['Cantidad', 'Tiempo_Total_seg', 'Lecturas_Total']
distribucion['Pct_Eventos'] = (distribucion['Cantidad'] / len(df) * 100).round(1)
distribucion['Pct_Tiempo'] = (distribucion['Tiempo_Total_seg'] / df['Duracion_seg'].sum() * 100).round(1)

print(f"\n{'Rango':<12} {'Cantidad':<12} {'% Eventos':<12} {'Tiempo(seg)':<15} {'% Tiempo':<12} {'Lecturas':<18}")
print("-" * 90)
for rango, row in distribucion.iterrows():
    print(f"{rango:<12} {row['Cantidad']:<12,.0f} {row['Pct_Eventos']:<12.1f} {row['Tiempo_Total_seg']:<15,.0f} {row['Pct_Tiempo']:<12.1f} {row['Lecturas_Total']:<18,.0f}")

# ============================================
# RECOMENDACIONES
# ============================================
print("\n" + "=" * 100)
print("8. RECOMENDACIONES DE OPTIMIZACION")
print("=" * 100)

# Identificar SPs más problemáticos
top_problematicos = resumen_sp.head(10).index.tolist()

print(f"""
STORED PROCEDURES PRIORITARIOS PARA OPTIMIZAR:
""")

for i, sp in enumerate(top_problematicos, 1):
    row = resumen_sp.loc[sp]
    print(f"""
{i}. {sp}
   - Ejecuciones: {row['Ejecuciones']:,.0f}
   - Tiempo total: {row['Tiempo_Total_seg']:,.1f} seg ({row['Tiempo_Total_seg']/60:,.1f} min)
   - Tiempo promedio: {row['Tiempo_Prom_seg']:,.2f} seg
   - Tiempo máximo: {row['Tiempo_Max_seg']:,.1f} seg
   - Lecturas promedio: {row['Lecturas_Prom']:,.0f}
   - ACCION: Revisar plan de ejecución y optimizar índices""")

print("""

ACCIONES GENERALES RECOMENDADAS:
================================

1. INDICES: Verificar que existan índices adecuados para los SPs más lentos
2. ESTADISTICAS: Actualizar estadísticas de las tablas involucradas
3. PLANES: Revisar planes de ejecución con SET STATISTICS IO ON
4. CODIGO: Buscar patrones anti-SARGABLE (funciones en WHERE, OR, etc.)
5. BLOQUEOS: Monitorear bloqueos durante horas pico
""")

# ============================================
# EXPORTAR REPORTE
# ============================================
print("\n" + "=" * 100)
print("9. EXPORTANDO REPORTE")
print("=" * 100)

try:
    with pd.ExcelWriter(r"d:\nuvol\sp\tiendas\REPORTE_EVENTOS_EXTENDIDOS.xlsx", engine='openpyxl') as writer:
        # Top eventos lentos
        df.nlargest(100, 'Duracion_us')[['Objeto', 'Duracion_seg', 'CPU_ms', 'Lecturas_Logicas', 'Escrituras', 'Filas', 'Fecha_Hora', 'SQL_Con_Parametros']].to_excel(
            writer, sheet_name='Top_100_Lentos', index=False)

        # Resumen por SP
        resumen_sp.to_excel(writer, sheet_name='Resumen_SP')

        # Eventos críticos
        criticos.to_excel(writer, sheet_name='Eventos_Criticos', index=False)

        # Distribución
        distribucion.to_excel(writer, sheet_name='Distribucion_Tiempo')

    print("Reporte exportado a: d:\\nuvol\\sp\\tiendas\\REPORTE_EVENTOS_EXTENDIDOS.xlsx")
except Exception as e:
    print(f"Error al exportar: {e}")

print("\n" + "=" * 100)
print("ANALISIS COMPLETADO")
print("=" * 100)
