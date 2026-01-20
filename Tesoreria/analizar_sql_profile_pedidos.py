"""
Análisis Completo de SQL Profile - Pedidos
Objetivo: Identificar consultas lentas y generar recomendaciones de optimización
"""

import pandas as pd
import numpy as np
import sys
import io
import re

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

archivo = r"d:\nuvol\sp\tiendas\pedidos.xlsx"

def limpiar_sql(text):
    """Limpia y acorta el texto SQL para mostrar"""
    if pd.isna(text):
        return "N/A"
    text = str(text)
    # Remover saltos de linea extra
    text = re.sub(r'\s+', ' ', text)
    return text[:150] + "..." if len(text) > 150 else text

def extraer_tipo_consulta(text):
    """Extrae el tipo de consulta SQL"""
    if pd.isna(text):
        return "DESCONOCIDO"
    text = str(text).upper().strip()
    if text.startswith("SELECT"):
        return "SELECT"
    elif text.startswith("INSERT"):
        return "INSERT"
    elif text.startswith("UPDATE"):
        return "UPDATE"
    elif text.startswith("DELETE"):
        return "DELETE"
    elif text.startswith("EXEC"):
        return "EXEC SP"
    elif "CREATE" in text:
        return "DDL"
    elif text.startswith("SET"):
        return "SET"
    elif text.startswith("DECLARE"):
        return "DECLARE"
    else:
        return "OTRO"

def extraer_tablas(text):
    """Intenta extraer nombres de tablas del SQL"""
    if pd.isna(text):
        return []
    text = str(text)
    # Patron basico para FROM/JOIN/INTO
    pattern = r'(?:FROM|JOIN|INTO|UPDATE)\s+[\[\"]?(\w+)[\]\"]?'
    matches = re.findall(pattern, text, re.IGNORECASE)
    return list(set(matches))

print("=" * 100)
print("ANALISIS DE SQL PROFILE - OPTIMIZACION DE CONSULTAS")
print("=" * 100)

# Cargar datos
df = pd.read_excel(archivo, sheet_name='Sheet1')

print(f"\nTotal de eventos capturados: {len(df)}")
print(f"Columnas disponibles: {list(df.columns)}")

# Filtrar solo eventos con datos de rendimiento
df_metrics = df[df['Duration'].notna()].copy()
print(f"Eventos con metricas de duracion: {len(df_metrics)}")

# Convertir Duration de microsegundos a milisegundos (SQL Profiler usa microsegundos)
df_metrics['Duration_ms'] = df_metrics['Duration'] / 1000
df_metrics['Duration_seg'] = df_metrics['Duration'] / 1000000

# ============================================
# RESUMEN GENERAL
# ============================================
print("\n" + "=" * 100)
print("1. RESUMEN GENERAL DE METRICAS")
print("=" * 100)

metricas = {
    'CPU (ms)': df_metrics['CPU'].sum() / 1000 if 'CPU' in df_metrics.columns else 0,
    'Reads (total)': df_metrics['Reads'].sum() if 'Reads' in df_metrics.columns else 0,
    'Writes (total)': df_metrics['Writes'].sum() if 'Writes' in df_metrics.columns else 0,
    'Duration Total (seg)': df_metrics['Duration_seg'].sum(),
    'Duration Promedio (ms)': df_metrics['Duration_ms'].mean(),
    'Duration Max (ms)': df_metrics['Duration_ms'].max(),
    'Duration Min (ms)': df_metrics['Duration_ms'].min(),
}

for metric, value in metricas.items():
    print(f"  {metric}: {value:,.2f}")

# ============================================
# TOP 20 CONSULTAS MAS LENTAS
# ============================================
print("\n" + "=" * 100)
print("2. TOP 20 CONSULTAS MAS LENTAS (por Duration)")
print("=" * 100)

top_slow = df_metrics.nlargest(20, 'Duration')[['Duration_ms', 'CPU', 'Reads', 'Writes', 'TextData', 'StartTime']].copy()
top_slow['SQL_Preview'] = top_slow['TextData'].apply(limpiar_sql)
top_slow['Tipo'] = top_slow['TextData'].apply(extraer_tipo_consulta)

print(f"\n{'#':<3} {'Duration(ms)':<12} {'CPU':<10} {'Reads':<12} {'Writes':<8} {'Tipo':<10} {'SQL Preview'}")
print("-" * 120)

for i, (idx, row) in enumerate(top_slow.iterrows(), 1):
    duration = f"{row['Duration_ms']:,.1f}" if pd.notna(row['Duration_ms']) else "N/A"
    cpu = f"{row['CPU']:,.0f}" if pd.notna(row['CPU']) else "N/A"
    reads = f"{row['Reads']:,.0f}" if pd.notna(row['Reads']) else "N/A"
    writes = f"{row['Writes']:,.0f}" if pd.notna(row['Writes']) else "N/A"
    sql_preview = row['SQL_Preview'][:80]
    print(f"{i:<3} {duration:<12} {cpu:<10} {reads:<12} {writes:<8} {row['Tipo']:<10} {sql_preview}")

# ============================================
# TOP 20 CONSULTAS CON MAS LECTURAS (I/O)
# ============================================
print("\n" + "=" * 100)
print("3. TOP 20 CONSULTAS CON MAS LECTURAS (Reads)")
print("=" * 100)

if df_metrics['Reads'].notna().any():
    top_reads = df_metrics.nlargest(20, 'Reads')[['Reads', 'Duration_ms', 'CPU', 'TextData']].copy()
    top_reads['SQL_Preview'] = top_reads['TextData'].apply(limpiar_sql)
    top_reads['Tipo'] = top_reads['TextData'].apply(extraer_tipo_consulta)

    print(f"\n{'#':<3} {'Reads':<15} {'Duration(ms)':<12} {'CPU':<10} {'Tipo':<10} {'SQL Preview'}")
    print("-" * 120)

    for i, (idx, row) in enumerate(top_reads.iterrows(), 1):
        reads = f"{row['Reads']:,.0f}" if pd.notna(row['Reads']) else "N/A"
        duration = f"{row['Duration_ms']:,.1f}" if pd.notna(row['Duration_ms']) else "N/A"
        cpu = f"{row['CPU']:,.0f}" if pd.notna(row['CPU']) else "N/A"
        sql_preview = row['SQL_Preview'][:80]
        print(f"{i:<3} {reads:<15} {duration:<12} {cpu:<10} {row['Tipo']:<10} {sql_preview}")

# ============================================
# ANALISIS POR TIPO DE CONSULTA
# ============================================
print("\n" + "=" * 100)
print("4. ANALISIS POR TIPO DE CONSULTA")
print("=" * 100)

df_metrics['TipoConsulta'] = df_metrics['TextData'].apply(extraer_tipo_consulta)

resumen_tipo = df_metrics.groupby('TipoConsulta').agg({
    'Duration_ms': ['count', 'sum', 'mean', 'max'],
    'Reads': 'sum',
    'CPU': 'sum'
}).round(2)

resumen_tipo.columns = ['Cantidad', 'Duration Total (ms)', 'Duration Prom (ms)', 'Duration Max (ms)', 'Reads Total', 'CPU Total']
resumen_tipo = resumen_tipo.sort_values('Duration Total (ms)', ascending=False)

print(f"\n{'Tipo':<15} {'Cantidad':<10} {'Dur.Total(ms)':<15} {'Dur.Prom(ms)':<15} {'Dur.Max(ms)':<15} {'Reads':<15} {'CPU'}")
print("-" * 100)
for tipo, row in resumen_tipo.iterrows():
    print(f"{tipo:<15} {row['Cantidad']:<10.0f} {row['Duration Total (ms)']:<15,.1f} {row['Duration Prom (ms)']:<15,.1f} {row['Duration Max (ms)']:<15,.1f} {row['Reads Total']:<15,.0f} {row['CPU Total']:<,.0f}")

# ============================================
# ANALISIS DE TABLAS MAS ACCEDIDAS
# ============================================
print("\n" + "=" * 100)
print("5. TABLAS MAS ACCEDIDAS (estimado)")
print("=" * 100)

todas_tablas = []
for text in df_metrics['TextData'].dropna():
    tablas = extraer_tablas(text)
    todas_tablas.extend(tablas)

if todas_tablas:
    from collections import Counter
    conteo_tablas = Counter(todas_tablas)
    print("\nTop 15 tablas mas referenciadas:")
    for tabla, count in conteo_tablas.most_common(15):
        print(f"  {tabla}: {count} veces")

# ============================================
# CONSULTAS PROBLEMATICAS DETALLADAS
# ============================================
print("\n" + "=" * 100)
print("6. CONSULTAS PROBLEMATICAS - DETALLE COMPLETO")
print("=" * 100)

# Umbral: consultas que toman mas de 1 segundo o mas de 10000 reads
problematicas = df_metrics[(df_metrics['Duration_ms'] > 1000) | (df_metrics['Reads'] > 10000)]

if len(problematicas) > 0:
    print(f"\nConsultas problematicas encontradas: {len(problematicas)}")
    print("\n" + "-" * 100)

    for i, (idx, row) in enumerate(problematicas.head(10).iterrows(), 1):
        print(f"\n[CONSULTA #{i}]")
        print(f"  Duration: {row['Duration_ms']:,.1f} ms ({row['Duration_seg']:.2f} seg)")
        print(f"  CPU: {row['CPU']:,.0f}" if pd.notna(row['CPU']) else "  CPU: N/A")
        print(f"  Reads: {row['Reads']:,.0f}" if pd.notna(row['Reads']) else "  Reads: N/A")
        print(f"  Writes: {row['Writes']:,.0f}" if pd.notna(row['Writes']) else "  Writes: N/A")
        print(f"  StartTime: {row['StartTime']}")
        print(f"  SQL:")
        sql_text = str(row['TextData'])[:500] if pd.notna(row['TextData']) else "N/A"
        print(f"    {sql_text}")
        print("-" * 100)
else:
    print("\nNo se encontraron consultas que excedan los umbrales (>1seg o >10000 reads)")

# ============================================
# RECOMENDACIONES DE OPTIMIZACION
# ============================================
print("\n" + "=" * 100)
print("7. RECOMENDACIONES DE OPTIMIZACION")
print("=" * 100)

print("""
BASADO EN EL ANALISIS DEL SQL PROFILE:

A. CONSULTAS LENTAS (Duration alto):
   - Revisar plan de ejecucion con SET STATISTICS IO ON
   - Verificar indices faltantes con Database Engine Tuning Advisor
   - Considerar OPTION (RECOMPILE) para queries con parametros variables

B. LECTURAS ALTAS (Reads):
   - Crear indices cubrientes (INCLUDE) para evitar Key Lookups
   - Verificar que existan indices en columnas de WHERE y JOIN
   - Evitar SELECT * - usar solo columnas necesarias

C. PATRONES PROBLEMATICOS A BUSCAR:
   - Funciones en columnas del WHERE (rompe uso de indices)
   - LIKE '%texto' (no usa indice)
   - Conversiones implicitas de tipos
   - Subconsultas correlacionadas (reemplazar por JOIN)
   - NOT IN con subconsulta (usar NOT EXISTS)

D. INDICES RECOMENDADOS:
   - Crear indices en columnas de filtro (WHERE)
   - Crear indices en columnas de JOIN
   - Considerar indices filtrados para datos parciales

E. PROCEDIMIENTOS ALMACENADOS:
   - Usar SET NOCOUNT ON al inicio
   - Parametrizar correctamente
   - Evitar cursores - usar operaciones de conjunto
""")

# ============================================
# EXPORTAR REPORTE
# ============================================
print("\n" + "=" * 100)
print("8. EXPORTANDO REPORTE")
print("=" * 100)

try:
    with pd.ExcelWriter(r"d:\nuvol\sp\tiendas\REPORTE_SQL_PROFILE.xlsx", engine='openpyxl') as writer:
        # Top consultas lentas
        top_slow_export = df_metrics.nlargest(50, 'Duration')[['Duration_ms', 'CPU', 'Reads', 'Writes', 'TextData', 'StartTime', 'DatabaseName']].copy()
        top_slow_export.to_excel(writer, sheet_name='Top_Lentas', index=False)

        # Resumen por tipo
        resumen_tipo.to_excel(writer, sheet_name='Resumen_Tipo')

        # Todas las metricas
        df_metrics[['Duration_ms', 'CPU', 'Reads', 'Writes', 'TextData', 'StartTime', 'DatabaseName']].to_excel(
            writer, sheet_name='Todos_Eventos', index=False)

    print("Reporte exportado a: d:\\nuvol\\sp\\tiendas\\REPORTE_SQL_PROFILE.xlsx")
except Exception as e:
    print(f"Error al exportar: {e}")

print("\n" + "=" * 100)
print("ANALISIS COMPLETADO")
print("=" * 100)
