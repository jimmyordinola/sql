import pandas as pd

# Leer CSV
df = pd.read_csv(r"d:\nuvol\sp\kardex_limon_v2.csv", encoding='utf-8-sig')

# Convertir columnas
df['Fecha Movimiento'] = pd.to_datetime(df['Fecha Movimiento'], format='mixed', errors='coerce')
df['Cantidad Entrada'] = pd.to_numeric(df['Cantidad Entrada'], errors='coerce')
df['Costo Entrada'] = pd.to_numeric(df['Costo Entrada'], errors='coerce')
df['Total Entrada'] = pd.to_numeric(df['Total Entrada'], errors='coerce')
df['Cantidad Salida'] = pd.to_numeric(df['Cantidad Salida'], errors='coerce')
df['Costo Salida'] = pd.to_numeric(df['Costo Salida'], errors='coerce')
df['Total Salida'] = pd.to_numeric(df['Total Salida'], errors='coerce')
df['Saldo Cantidad'] = pd.to_numeric(df['Saldo Cantidad'], errors='coerce')
df['Saldo Costo'] = pd.to_numeric(df['Saldo Costo'], errors='coerce')
df['Saldo Total'] = pd.to_numeric(df['Saldo Total'], errors='coerce')
df['Movimiento'] = df['Movimiento'].str.strip()

print("=" * 140)
print("EXPLICACIÓN: ¿CÓMO SE OBTIENE EL COSTO 3.99119?")
print("=" * 140)
print()

# Ver TODOS los almacenes al 29/04/2025 08:05:00
fecha_buscar = pd.to_datetime('2025-04-29 08:05:00')

print("PASO 1: REVISAR EL ESTADO DE *TODOS* LOS ALMACENES ANTES DEL 29/04 08:05")
print("=" * 140)
print()

# Filtrar todos los movimientos antes de esa fecha
df_antes = df[df['Fecha Movimiento'] < fecha_buscar].copy()

# Obtener el último movimiento de cada almacén
almacenes = df_antes['Nom. Almacen'].unique()

print(f"Total de almacenes con stock de limón: {len(almacenes)}")
print()

saldos_por_almacen = []

for almacen in almacenes:
    df_alm = df_antes[df_antes['Nom. Almacen'] == almacen]
    if len(df_alm) > 0:
        ultimo = df_alm.iloc[-1]

        saldos_por_almacen.append({
            'almacen': almacen,
            'cantidad': ultimo['Saldo Cantidad'],
            'costo': ultimo['Saldo Costo'],
            'total': ultimo['Saldo Total']
        })

# Mostrar saldos
print(f"{'Almacén':<35} {'Cantidad':>12} {'Costo Unit':>12} {'Total':>15}")
print("-" * 140)

total_cantidad_global = 0.0
total_valor_global = 0.0

for saldo in saldos_por_almacen:
    print(f"{saldo['almacen']:<35} {saldo['cantidad']:>12.3f} kg {saldo['costo']:>12.5f} {saldo['total']:>15.5f}")
    total_cantidad_global += saldo['cantidad']
    total_valor_global += saldo['total']

print("-" * 140)
print(f"{'TOTAL GLOBAL':<35} {total_cantidad_global:>12.3f} kg {' ':>12} {total_valor_global:>15.5f}")
print()

# Calcular costo promedio global
if total_cantidad_global > 0:
    costo_promedio_global = total_valor_global / total_cantidad_global
    print(f"COSTO PROMEDIO GLOBAL = Total Valor / Total Cantidad")
    print(f"                      = {total_valor_global:.5f} / {total_cantidad_global:.3f}")
    print(f"                      = {costo_promedio_global:.10f}")
    print()

    if abs(costo_promedio_global - 3.99119) < 0.01:
        print("*** AQUI ESTA EL VALOR 3.99119 ***")
        print()
        print("Este es el COSTO PROMEDIO calculado considerando TODOS los almacenes.")
    else:
        print(f"El costo promedio global ({costo_promedio_global:.5f}) NO coincide con 3.99119")
        print("Buscando en otro momento...")
        print()

print()
print("=" * 140)
print("PASO 2: ¿DE DÓNDE VIENE ESTE COSTO EN EL SISTEMA?")
print("=" * 140)
print()

print("En la base de datos, existe una tabla llamada 'CostoInventario' con esta estructura:")
print()
print("  ┌─────────────────────────────────────────────────────────┐")
print("  │ Tabla: CostoInventario                                  │")
print("  ├─────────────────────────────────────────────────────────┤")
print("  │ RucE                    VARCHAR(20)                     │")
print("  │ Cd_Inv                  VARCHAR(20)  ← Código documento │")
print("  │ Item                    INT                             │")
print("  │ Cd_Prod                 VARCHAR(20)  ← PD00534          │")
print("  │ Cantidad                DECIMAL                         │")
print("  │ Costo_MN                DECIMAL      ← 3.99119          │")
print("  │ IC_TipoCostoInventario  CHAR(1)      ← 'M' (Promedio)  │")
print("  └─────────────────────────────────────────────────────────┘")
print()

print("Esta tabla almacena el costo que se debe usar para cada salida.")
print("El problema es que almacena UN SOLO COSTO GLOBAL para el producto,")
print("sin distinguir entre almacenes.")
print()

print("=" * 140)
print("PASO 3: ¿CÓMO SE CALCULA ESE COSTO?")
print("=" * 140)
print()

print("El sistema hace este cálculo GLOBAL:")
print()
print("  1. Suma el VALOR TOTAL de todos los almacenes")
print(f"     Total Valor = {total_valor_global:.5f} soles")
print()
print("  2. Suma la CANTIDAD TOTAL de todos los almacenes")
print(f"     Total Cantidad = {total_cantidad_global:.3f} kg")
print()
print("  3. Divide: Costo = Valor / Cantidad")
print(f"     Costo = {total_valor_global:.5f} / {total_cantidad_global:.3f} = {costo_promedio_global:.10f}")
print()
print("  4. Guarda este valor en CostoInventario.Costo_MN")
print()

print("=" * 140)
print("PASO 4: ¿POR QUÉ ESTO ES UN PROBLEMA?")
print("=" * 140)
print()

print("Ejemplo ilustrativo:")
print()
print("  Supongamos 3 almacenes:")
print()
print("  ┌──────────────────┬──────────┬───────────┬────────────┐")
print("  │ Almacén          │ Cantidad │ Costo/kg  │ Valor Total│")
print("  ├──────────────────┼──────────┼───────────┼────────────┤")
print("  │ FABRICA(INSUMOS) │  22.4 kg │  2.66 S/  │  59.70 S/  │  ← Costo bajo")
print("  │ PLAZA            │  10.0 kg │  4.50 S/  │  45.00 S/  │  ← Costo alto")
print("  │ MEGA             │   5.0 kg │  5.00 S/  │  25.00 S/  │  ← Costo muy alto")
print("  ├──────────────────┼──────────┼───────────┼────────────┤")
print("  │ TOTAL GLOBAL     │  37.4 kg │  3.46 S/  │ 129.70 S/  │  ← Costo promedio global")
print("  └──────────────────┴──────────┴───────────┴────────────┘")
print()
print("  Costo Global = 129.70 / 37.4 = 3.46 S/kg")
print()
print("  Si hacemos una SALIDA de FABRICA(INSUMOS):")
print("    - Costo correcto (del almacén):  2.66 S/kg")
print("    - Costo que usa el sistema:      3.46 S/kg  ← GLOBAL, INCORRECTO")
print("    - Error por kg:                  0.80 S/kg")
print()
print("  Esto genera SOBRECOSTOS en las salidas.")
print()

print("=" * 140)
print("PASO 5: ¿CÓMO DEBERÍA FUNCIONAR?")
print("=" * 140)
print()

print("El costo promedio ponderado debe calcularse POR ALMACÉN:")
print()
print("  Para ALMACEN FABRICA(INSUMOS) el 29/04 08:05:")
print()

# Buscar el saldo en FABRICA antes de la salida INV000297367
df_fabrica = df[df['Nom. Almacen'].str.strip() == 'ALMACEN FABRICA(INSUMOS)'].copy()
df_fabrica_antes = df_fabrica[df_fabrica['Fecha Movimiento'] < fecha_buscar]

if len(df_fabrica_antes) > 0:
    ultimo_fabrica = df_fabrica_antes.iloc[-1]

    print(f"    Saldo Cantidad:  {ultimo_fabrica['Saldo Cantidad']:.3f} kg")
    print(f"    Saldo Total:     {ultimo_fabrica['Saldo Total']:.5f} soles")
    print(f"    Saldo Costo:     {ultimo_fabrica['Saldo Costo']:.10f} soles/kg")
    print()
    print("    Este SALDO COSTO ({:.5f}) es el que debería usarse en la salida,".format(ultimo_fabrica['Saldo Costo']))
    print("    NO el costo global (3.99119).")
    print()

print()
print("=" * 140)
print("RESUMEN")
print("=" * 140)
print()
print("El costo 3.99119 se obtiene así:")
print()
print("  1. El sistema suma el VALOR de TODOS los almacenes")
print("  2. El sistema suma la CANTIDAD de TODOS los almacenes")
print("  3. Divide: Costo Global = Valor Total / Cantidad Total")
print("  4. Guarda este costo en CostoInventario.Costo_MN")
print("  5. Al registrar una salida, usa este costo GLOBAL")
print()
print("PROBLEMA: Debería usar el costo ESPECÍFICO de cada almacén,")
print("          no un promedio global.")
print()
