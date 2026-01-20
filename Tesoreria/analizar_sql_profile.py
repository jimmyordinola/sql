"""
Análisis de SQL Profile para Optimización de Consultas
Autor: Claude AI
Objetivo: Analizar métricas de rendimiento SQL y generar recomendaciones de optimización
"""

import pandas as pd
import numpy as np
from tabulate import tabulate
import warnings
import sys
import io

# Configurar salida para UTF-8
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
warnings.filterwarnings('ignore')

# Configuración
archivo = r"d:\nuvol\sp\Tesoreria\RESULTADOS.xlsx"

def cargar_datos():
    """Carga ambas hojas del archivo Excel"""
    print("=" * 80)
    print("ANÁLISIS DE SQL PROFILE - OPTIMIZACIÓN DE CONSULTAS")
    print("=" * 80)

    df_original = pd.read_excel(archivo, sheet_name='ORIGINAL')
    df_optimizado = pd.read_excel(archivo, sheet_name='OPTIMIZAO')

    print(f"\n📊 Datos cargados:")
    print(f"   - ORIGINAL: {len(df_original)} registros, {len(df_original.columns)} columnas")
    print(f"   - OPTIMIZADO: {len(df_optimizado)} registros, {len(df_optimizado.columns)} columnas")

    return df_original, df_optimizado

def mostrar_estructura(df, nombre):
    """Muestra la estructura del DataFrame"""
    print(f"\n{'='*80}")
    print(f"ESTRUCTURA DE {nombre}")
    print("=" * 80)

    print(f"\nColumnas disponibles ({len(df.columns)}):")
    for i, col in enumerate(df.columns, 1):
        dtype = df[col].dtype
        nulls = df[col].isnull().sum()
        print(f"  {i:2}. {col:<40} | Tipo: {str(dtype):<15} | Nulos: {nulls}")

    return df.columns.tolist()

def analizar_metricas_rendimiento(df, nombre):
    """Analiza métricas clave de rendimiento SQL"""
    print(f"\n{'='*80}")
    print(f"ANÁLISIS DE RENDIMIENTO - {nombre}")
    print("=" * 80)

    # Identificar columnas de métricas comunes en SQL Profiles
    metricas_posibles = {
        'tiempo': ['duration', 'elapsed', 'time', 'cpu', 'wait', 'tiempo', 'duracion'],
        'lecturas': ['read', 'logical', 'physical', 'io', 'lectura', 'lecturas'],
        'escrituras': ['write', 'escritura', 'escrituras'],
        'filas': ['row', 'rows', 'fila', 'filas', 'count'],
        'ejecuciones': ['execution', 'exec', 'ejecucion', 'ejecuciones', 'calls']
    }

    columnas_numericas = df.select_dtypes(include=[np.number]).columns.tolist()

    print(f"\nColumnas numéricas encontradas: {len(columnas_numericas)}")

    # Estadísticas de columnas numéricas
    if columnas_numericas:
        print("\n📈 ESTADÍSTICAS DE MÉTRICAS NUMÉRICAS:")
        print("-" * 80)

        stats = df[columnas_numericas].describe().T
        stats['sum'] = df[columnas_numericas].sum()

        # Mostrar top métricas por suma total
        print("\nTop 15 métricas por suma total:")
        top_metricas = stats.nlargest(15, 'sum')[['count', 'mean', 'std', 'min', 'max', 'sum']]
        print(tabulate(top_metricas, headers='keys', tablefmt='grid', floatfmt='.2f'))

    return columnas_numericas

def identificar_consultas_problematicas(df, nombre):
    """Identifica las consultas más costosas"""
    print(f"\n{'='*80}")
    print(f"CONSULTAS PROBLEMÁTICAS - {nombre}")
    print("=" * 80)

    # Buscar columnas que típicamente indican costo
    columnas_costo = []
    for col in df.columns:
        col_lower = col.lower()
        if any(x in col_lower for x in ['duration', 'time', 'cpu', 'read', 'cost', 'elapsed', 'wait']):
            if df[col].dtype in ['int64', 'float64', 'int32', 'float32']:
                columnas_costo.append(col)

    if not columnas_costo:
        # Usar todas las columnas numéricas
        columnas_costo = df.select_dtypes(include=[np.number]).columns.tolist()[:5]

    print(f"\nColumnas de costo identificadas: {columnas_costo[:5]}")

    # Buscar columna de identificación de query
    col_query = None
    for col in df.columns:
        col_lower = col.lower()
        if any(x in col_lower for x in ['query', 'text', 'statement', 'sql', 'procedure', 'object', 'name']):
            col_query = col
            break

    if col_query is None:
        col_query = df.columns[0]  # Usar primera columna

    print(f"Columna de identificación: {col_query}")

    # Para cada métrica de costo, mostrar top 10
    for col_costo in columnas_costo[:3]:
        if col_costo in df.columns:
            print(f"\n🔴 Top 10 por {col_costo}:")
            top_10 = df.nlargest(10, col_costo)[[col_query, col_costo]].head(10)
            print(tabulate(top_10, headers='keys', tablefmt='grid', showindex=False))

def comparar_versiones(df_orig, df_opt):
    """Compara el rendimiento entre versión original y optimizada"""
    print(f"\n{'='*80}")
    print("COMPARACIÓN: ORIGINAL vs OPTIMIZADO")
    print("=" * 80)

    # Obtener columnas numéricas comunes
    cols_num_orig = set(df_orig.select_dtypes(include=[np.number]).columns)
    cols_num_opt = set(df_opt.select_dtypes(include=[np.number]).columns)
    cols_comunes = list(cols_num_orig.intersection(cols_num_opt))

    if not cols_comunes:
        print("No se encontraron columnas numéricas comunes para comparar")
        return

    print(f"\n📊 Columnas numéricas comparables: {len(cols_comunes)}")

    # Calcular mejoras
    comparacion = []
    for col in cols_comunes:
        suma_orig = df_orig[col].sum()
        suma_opt = df_opt[col].sum()

        if suma_orig != 0:
            mejora_pct = ((suma_orig - suma_opt) / suma_orig) * 100
        else:
            mejora_pct = 0

        comparacion.append({
            'Métrica': col,
            'Original': suma_orig,
            'Optimizado': suma_opt,
            'Diferencia': suma_orig - suma_opt,
            'Mejora %': mejora_pct
        })

    df_comp = pd.DataFrame(comparacion)
    df_comp = df_comp.sort_values('Mejora %', ascending=False)

    print("\n✅ MÉTRICAS CON MEJORA (reducción):")
    mejoras = df_comp[df_comp['Mejora %'] > 0].head(15)
    if not mejoras.empty:
        print(tabulate(mejoras, headers='keys', tablefmt='grid', showindex=False, floatfmt='.2f'))
    else:
        print("No se encontraron mejoras significativas")

    print("\n⚠️ MÉTRICAS SIN MEJORA O EMPEORADAS:")
    empeoradas = df_comp[df_comp['Mejora %'] <= 0].head(10)
    if not empeoradas.empty:
        print(tabulate(empeoradas, headers='keys', tablefmt='grid', showindex=False, floatfmt='.2f'))

    return df_comp

def analizar_patrones(df, nombre):
    """Analiza patrones en los datos para identificar oportunidades de optimización"""
    print(f"\n{'='*80}")
    print(f"ANÁLISIS DE PATRONES - {nombre}")
    print("=" * 80)

    # Buscar columnas de texto que podrían contener nombres de queries/procedimientos
    cols_texto = df.select_dtypes(include=['object']).columns.tolist()

    print(f"\nColumnas de texto: {cols_texto[:10]}")

    for col in cols_texto[:3]:
        if col in df.columns:
            valores_unicos = df[col].nunique()
            print(f"\n📋 Análisis de '{col}': {valores_unicos} valores únicos")

            # Mostrar distribución de los top valores
            if valores_unicos <= 50:
                distribucion = df[col].value_counts().head(15)
                print(tabulate(
                    distribucion.reset_index().rename(columns={'index': col, col: 'Frecuencia'}),
                    headers='keys', tablefmt='grid', showindex=False
                ))

def generar_recomendaciones(df_comp, df_orig, df_opt):
    """Genera recomendaciones de optimización basadas en el análisis"""
    print(f"\n{'='*80}")
    print("🎯 RECOMENDACIONES DE OPTIMIZACIÓN")
    print("=" * 80)

    recomendaciones = []

    # Analizar basado en las métricas
    if df_comp is not None and not df_comp.empty:
        # Métricas con mayor impacto
        top_mejoras = df_comp[df_comp['Mejora %'] > 10].head(5)

        for _, row in top_mejoras.iterrows():
            metrica = row['Métrica']
            mejora = row['Mejora %']

            if 'read' in metrica.lower() or 'io' in metrica.lower():
                recomendaciones.append(
                    f"✅ Lecturas ({metrica}): Mejora del {mejora:.1f}%. "
                    "La optimización de índices está funcionando. Considerar índices cubrientes."
                )
            elif 'cpu' in metrica.lower() or 'time' in metrica.lower():
                recomendaciones.append(
                    f"✅ CPU/Tiempo ({metrica}): Mejora del {mejora:.1f}%. "
                    "Las optimizaciones de queries están siendo efectivas."
                )
            elif 'wait' in metrica.lower():
                recomendaciones.append(
                    f"✅ Esperas ({metrica}): Mejora del {mejora:.1f}%. "
                    "Se han reducido los bloqueos y esperas."
                )

        # Métricas que empeoraron
        empeoradas = df_comp[df_comp['Mejora %'] < -5].head(3)
        for _, row in empeoradas.iterrows():
            metrica = row['Métrica']
            empeoramiento = abs(row['Mejora %'])
            recomendaciones.append(
                f"⚠️ {metrica}: Empeoró {empeoramiento:.1f}%. Revisar esta área."
            )

    # Recomendaciones generales basadas en SQL Server
    print("\n📌 RECOMENDACIONES GENERALES PARA OPTIMIZACIÓN SQL SERVER:")
    print("-" * 80)

    rec_generales = [
        "1. ÍNDICES:",
        "   - Crear índices en columnas usadas en WHERE, JOIN y ORDER BY",
        "   - Usar índices cubrientes (INCLUDE) para evitar lookups",
        "   - Evitar índices sobre columnas con baja selectividad",
        "   - Revisar fragmentación de índices (>30% = reorganizar, >50% = rebuild)",
        "",
        "2. CONSULTAS:",
        "   - Evitar SELECT * - especificar solo columnas necesarias",
        "   - Usar EXISTS en lugar de IN para subconsultas grandes",
        "   - Evitar funciones en columnas del WHERE (rompe uso de índices)",
        "   - Usar UNION ALL en lugar de UNION cuando no hay duplicados",
        "",
        "3. PROCEDIMIENTOS ALMACENADOS:",
        "   - Usar SET NOCOUNT ON al inicio",
        "   - Evitar cursores - usar operaciones de conjunto",
        "   - Parametrizar correctamente para reutilizar planes",
        "   - Considerar OPTION (RECOMPILE) para parámetros variables",
        "",
        "4. TABLAS TEMPORALES:",
        "   - Usar tablas temporales (#temp) para conjuntos grandes",
        "   - Variables de tabla (@table) para conjuntos pequeños (<1000 filas)",
        "   - Crear índices en tablas temporales si se usan múltiples veces",
        "",
        "5. JOINS:",
        "   - Verificar que existen índices en columnas de JOIN",
        "   - Preferir INNER JOIN sobre OUTER cuando sea posible",
        "   - Filtrar datos ANTES del JOIN cuando sea posible"
    ]

    for rec in rec_generales:
        print(rec)

    if recomendaciones:
        print("\n📊 RECOMENDACIONES BASADAS EN SUS DATOS:")
        print("-" * 80)
        for rec in recomendaciones:
            print(rec)

def exportar_analisis(df_orig, df_opt, df_comp):
    """Exporta el análisis a un archivo"""
    archivo_salida = r"d:\nuvol\sp\Tesoreria\ANALISIS_SQL_PROFILE.xlsx"

    with pd.ExcelWriter(archivo_salida, engine='openpyxl') as writer:
        if df_comp is not None:
            df_comp.to_excel(writer, sheet_name='Comparacion', index=False)

        # Estadísticas originales
        stats_orig = df_orig.describe().T
        stats_orig.to_excel(writer, sheet_name='Stats_Original')

        # Estadísticas optimizado
        stats_opt = df_opt.describe().T
        stats_opt.to_excel(writer, sheet_name='Stats_Optimizado')

    print(f"\n📁 Análisis exportado a: {archivo_salida}")

def main():
    """Función principal"""
    try:
        # Cargar datos
        df_orig, df_opt = cargar_datos()

        # Mostrar estructura
        mostrar_estructura(df_orig, "ORIGINAL")

        # Análisis de rendimiento
        analizar_metricas_rendimiento(df_orig, "ORIGINAL")
        analizar_metricas_rendimiento(df_opt, "OPTIMIZADO")

        # Identificar consultas problemáticas
        identificar_consultas_problematicas(df_orig, "ORIGINAL")

        # Comparar versiones
        df_comp = comparar_versiones(df_orig, df_opt)

        # Analizar patrones
        analizar_patrones(df_orig, "ORIGINAL")

        # Generar recomendaciones
        generar_recomendaciones(df_comp, df_orig, df_opt)

        # Exportar análisis
        try:
            exportar_analisis(df_orig, df_opt, df_comp)
        except Exception as e:
            print(f"\n⚠️ No se pudo exportar: {e}")

        print("\n" + "=" * 80)
        print("ANÁLISIS COMPLETADO")
        print("=" * 80)

    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()
