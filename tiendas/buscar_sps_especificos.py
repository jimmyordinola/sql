"""
Buscar SPs específicos en Extended Events
"""

import pandas as pd
import sys
import io

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

archivo = r"d:\nuvol\sp\tiendas\eventos.xlsx"

df = pd.read_excel(archivo, sheet_name='Sheet1')
df['Duracion_ms'] = df['Duracion_us'] / 1000
df['Duracion_seg'] = df['Duracion_us'] / 1000000

# SPs a buscar
sps_buscar = [
    'USP_T_ORDEN_PEDIDO_INSERTAR_VALE_VERSION_21',
    'USP_T_ORDEN_PEDIDO_MOVIMIENTOS_DETALLE_LISTAR',
    'USP_T_CLIENTE_SELECCIONAR_NRO_NOMBRE_CLIENTE_POR_TIPO_DOCUMENTO_07'
]

print("=" * 100)
print("BUSQUEDA DE SPs ESPECIFICOS EN EXTENDED EVENTS")
print("=" * 100)

for sp in sps_buscar:
    print(f"\n{'='*80}")
    print(f"SP: {sp}")
    print("=" * 80)

    # Buscar en columna Objeto
    df_sp = df[df['Objeto'].str.contains(sp, case=False, na=False)]

    if len(df_sp) == 0:
        # Buscar parcial
        sp_corto = sp.split('_')[-1] if '_' in sp else sp
        df_sp = df[df['Objeto'].str.contains(sp_corto, case=False, na=False)]

    if len(df_sp) == 0:
        # Buscar en SQL_Con_Parametros
        df_sp = df[df['SQL_Con_Parametros'].str.contains(sp, case=False, na=False)]

    if len(df_sp) > 0:
        print(f"\nEncontrado: {len(df_sp)} ejecuciones")
        print(f"\nEstadísticas:")
        print(f"  - Duración mínima: {df_sp['Duracion_seg'].min():,.2f} seg")
        print(f"  - Duración máxima: {df_sp['Duracion_seg'].max():,.2f} seg")
        print(f"  - Duración promedio: {df_sp['Duracion_seg'].mean():,.2f} seg")
        print(f"  - Duración total: {df_sp['Duracion_seg'].sum():,.1f} seg ({df_sp['Duracion_seg'].sum()/60:,.1f} min)")
        print(f"  - Lecturas promedio: {df_sp['Lecturas_Logicas'].mean():,.0f}")
        print(f"  - Lecturas máximas: {df_sp['Lecturas_Logicas'].max():,.0f}")
        print(f"  - CPU promedio: {df_sp['CPU_us'].mean()/1000:,.0f} ms")

        print(f"\nTop 10 ejecuciones más lentas:")
        top = df_sp.nlargest(10, 'Duracion_us')[['Duracion_seg', 'Lecturas_Logicas', 'CPU_us', 'Fecha_Hora']]
        for i, (idx, row) in enumerate(top.iterrows(), 1):
            print(f"  {i}. {row['Duracion_seg']:,.2f} seg | {row['Lecturas_Logicas']:,.0f} reads | {row['Fecha_Hora']}")
    else:
        print(f"\n*** NO ENCONTRADO en los eventos ***")
        print("  (El SP puede no haberse ejecutado en el período capturado,")
        print("   o puede tener un nombre diferente en la BD)")

# Buscar variantes similares
print("\n" + "=" * 100)
print("BUSQUEDA DE VARIANTES SIMILARES")
print("=" * 100)

patrones = ['ORDEN_PEDIDO', 'CLIENTE_SELECCIONAR', 'INSERTAR_VALE', 'MOVIMIENTOS_DETALLE']

for patron in patrones:
    df_patron = df[df['Objeto'].str.contains(patron, case=False, na=False)]
    if len(df_patron) > 0:
        objetos_unicos = df_patron['Objeto'].unique()
        print(f"\nPatrón '{patron}':")
        for obj in objetos_unicos[:10]:
            count = len(df_patron[df_patron['Objeto'] == obj])
            tiempo = df_patron[df_patron['Objeto'] == obj]['Duracion_seg'].sum()
            print(f"  - {obj}: {count} ejecuciones, {tiempo:,.1f} seg total")
