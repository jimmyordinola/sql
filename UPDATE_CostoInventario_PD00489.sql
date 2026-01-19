-- =====================================================
-- SCRIPT DE CORRECCIÓN DE COSTOS EN CostoInventario
-- Producto: PD00489
-- Generado: 2026-01-16 10:15:43.833894
-- =====================================================

USE [ERP_ECHA]
GO

BEGIN TRANSACTION

-- Fecha: 2025-04-01 14:58:42.720000 | Cant: 6.00 | Actual: 19.82273 -> Correcto: 0.00000
UPDATE CostoInventario
SET Costo_MN = 0.0000000000
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000301300'
  AND Item = 35
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-01 15:03:01 | Cant: 4.00 | Actual: 19.82273 -> Correcto: 49.55683
UPDATE CostoInventario
SET Costo_MN = 49.5568250000
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000301304'
  AND Item = 23
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-02 05:23:00 | Cant: 11.00 | Actual: 19.82273 -> Correcto: 0.00000
UPDATE CostoInventario
SET Costo_MN = 0.0000000000
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000306653'
  AND Item = 43
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-02 09:10:34.970000 | Cant: 13.00 | Actual: 19.82273 -> Correcto: 0.00000
UPDATE CostoInventario
SET Costo_MN = 0.0000000000
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000247006'
  AND Item = 45
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-02 09:15:46.740000 | Cant: 2.00 | Actual: 19.82273 -> Correcto: 0.00000
UPDATE CostoInventario
SET Costo_MN = 0.0000000000
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000247008'
  AND Item = 31
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-02 15:29:00 | Cant: 10.00 | Actual: 19.82273 -> Correcto: 71.36183
UPDATE CostoInventario
SET Costo_MN = 71.3618280000
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000301306'
  AND Item = 33
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-03 06:24:00 | Cant: 3.00 | Actual: 19.82273 -> Correcto: 17.08389
UPDATE CostoInventario
SET Costo_MN = 17.0838884212
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000287071'
  AND Item = 33
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-03 06:29:00 | Cant: 14.00 | Actual: 19.82273 -> Correcto: 17.48330
UPDATE CostoInventario
SET Costo_MN = 17.4833028181
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000287062'
  AND Item = 43
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-03 07:44:31.587000 | Cant: 2.00 | Actual: 19.82273 -> Correcto: 17.53900
UPDATE CostoInventario
SET Costo_MN = 17.5390034653
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000247030'
  AND Item = 49
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-03 08:04:03.187000 | Cant: 17.00 | Actual: 19.82273 -> Correcto: 17.93116
UPDATE CostoInventario
SET Costo_MN = 17.9311585268
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000247033'
  AND Item = 41
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-03 15:43:00 | Cant: 10.00 | Actual: 19.82273 -> Correcto: 17.58503
UPDATE CostoInventario
SET Costo_MN = 17.5850305287
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000301307'
  AND Item = 35
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-03 17:51:00 | Cant: 7.00 | Actual: 19.82273 -> Correcto: 17.69692
UPDATE CostoInventario
SET Costo_MN = 17.6969155022
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000306650'
  AND Item = 15
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-04 01:24:00 | Cant: 4.00 | Actual: 19.82273 -> Correcto: 17.69692
UPDATE CostoInventario
SET Costo_MN = 17.6969155022
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000287063'
  AND Item = 33
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-04 08:04:24.133000 | Cant: 11.00 | Actual: 19.82273 -> Correcto: 17.91835
UPDATE CostoInventario
SET Costo_MN = 17.9183545124
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000247074'
  AND Item = 41
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-04 08:06:26.280000 | Cant: 7.00 | Actual: 19.82273 -> Correcto: 17.91835
UPDATE CostoInventario
SET Costo_MN = 17.9183545124
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000247075'
  AND Item = 47
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-04 08:20:42.477000 | Cant: 7.00 | Actual: 19.82273 -> Correcto: 18.01858
UPDATE CostoInventario
SET Costo_MN = 18.0185848012
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000247076'
  AND Item = 43
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-04 08:36:07.130000 | Cant: 6.00 | Actual: 19.82273 -> Correcto: 18.18732
UPDATE CostoInventario
SET Costo_MN = 18.1873178054
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000247078'
  AND Item = 25
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-04 10:22:00 | Cant: 1.00 | Actual: 19.82273 -> Correcto: 18.19952
UPDATE CostoInventario
SET Costo_MN = 18.1995223740
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000306647'
  AND Item = 5
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-04 17:07:51.750000 | Cant: 10.00 | Actual: 19.82273 -> Correcto: 18.19952
UPDATE CostoInventario
SET Costo_MN = 18.1995223740
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000286903'
  AND Item = 43
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-05 06:43:00 | Cant: 2.00 | Actual: 19.82273 -> Correcto: 18.32157
UPDATE CostoInventario
SET Costo_MN = 18.3215680602
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000286875'
  AND Item = 7
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-05 08:51:00 | Cant: 3.00 | Actual: 19.82273 -> Correcto: 18.34414
UPDATE CostoInventario
SET Costo_MN = 18.3441419240
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000286876'
  AND Item = 7
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-05 13:24:51.600000 | Cant: 6.00 | Actual: 19.82273 -> Correcto: 18.37749
UPDATE CostoInventario
SET Costo_MN = 18.3774935347
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000286894'
  AND Item = 49
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-05 13:28:56.277000 | Cant: 9.00 | Actual: 19.82273 -> Correcto: 18.44269
UPDATE CostoInventario
SET Costo_MN = 18.4426921722
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000286896'
  AND Item = 51
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-05 13:38:12.760000 | Cant: 14.00 | Actual: 19.82273 -> Correcto: 18.65862
UPDATE CostoInventario
SET Costo_MN = 18.6586164582
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000286897'
  AND Item = 55
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-05 13:41:43.660000 | Cant: 4.00 | Actual: 19.82273 -> Correcto: 18.69261
UPDATE CostoInventario
SET Costo_MN = 18.6926051748
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000286898'
  AND Item = 39
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-06 09:06:00 | Cant: 12.00 | Actual: 19.82273 -> Correcto: 18.69261
UPDATE CostoInventario
SET Costo_MN = 18.6926051748
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000287005'
  AND Item = 49
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-06 09:21:00 | Cant: 8.00 | Actual: 19.82273 -> Correcto: 18.79457
UPDATE CostoInventario
SET Costo_MN = 18.7945713244
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000287010'
  AND Item = 33
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-06 10:17:07.990000 | Cant: 18.00 | Actual: 19.82273 -> Correcto: 18.85642
UPDATE CostoInventario
SET Costo_MN = 18.8564154553
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000286993'
  AND Item = 49
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-06 10:31:31.313000 | Cant: 16.00 | Actual: 19.82273 -> Correcto: 18.98719
UPDATE CostoInventario
SET Costo_MN = 18.9871948673
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000286994'
  AND Item = 39
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-06 11:02:22.593000 | Cant: 30.00 | Actual: 19.82273 -> Correcto: 19.22299
UPDATE CostoInventario
SET Costo_MN = 19.2229900581
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000286999'
  AND Item = 51
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-07 07:35:59.450000 | Cant: 3.00 | Actual: 19.82273 -> Correcto: 19.22299
UPDATE CostoInventario
SET Costo_MN = 19.2229900581
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000301246'
  AND Item = 37
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-07 08:08:00 | Cant: 6.00 | Actual: 19.82273 -> Correcto: 19.26182
UPDATE CostoInventario
SET Costo_MN = 19.2618221407
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000247199'
  AND Item = 23
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-07 08:22:00 | Cant: 6.00 | Actual: 19.82273 -> Correcto: 19.26182
UPDATE CostoInventario
SET Costo_MN = 19.2618221407
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000247198'
  AND Item = 31
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-07 09:03:00 | Cant: 3.00 | Actual: 19.82273 -> Correcto: 19.28713
UPDATE CostoInventario
SET Costo_MN = 19.2871262547
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000247205'
  AND Item = 35
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-07 09:49:30.027000 | Cant: 8.00 | Actual: 19.82273 -> Correcto: 19.32891
UPDATE CostoInventario
SET Costo_MN = 19.3289109440
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000306642'
  AND Item = 33
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-08 07:47:00 | Cant: 1.00 | Actual: 19.82273 -> Correcto: 18.48428
UPDATE CostoInventario
SET Costo_MN = 18.4842754101
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000247208'
  AND Item = 45
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-08 07:56:00 | Cant: 10.00 | Actual: 19.82273 -> Correcto: 18.48428
UPDATE CostoInventario
SET Costo_MN = 18.4842754101
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000247220'
  AND Item = 43
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-08 08:13:00 | Cant: 3.00 | Actual: 19.82273 -> Correcto: 18.57305
UPDATE CostoInventario
SET Costo_MN = 18.5730504594
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000247223'
  AND Item = 31
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-08 09:34:31.383000 | Cant: 3.00 | Actual: 19.82273 -> Correcto: 18.59218
UPDATE CostoInventario
SET Costo_MN = 18.5921782075
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000247224'
  AND Item = 19
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-08 23:36:00 | Cant: 7.00 | Actual: 19.82273 -> Correcto: 18.29437
UPDATE CostoInventario
SET Costo_MN = 18.2943681759
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000287065'
  AND Item = 33
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-09 07:46:00 | Cant: 4.00 | Actual: 19.82273 -> Correcto: 18.29437
UPDATE CostoInventario
SET Costo_MN = 18.2943681759
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000247273'
  AND Item = 41
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-09 07:50:00 | Cant: 6.00 | Actual: 19.82273 -> Correcto: 18.36082
UPDATE CostoInventario
SET Costo_MN = 18.3608186900
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000247274'
  AND Item = 41
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-09 07:56:00 | Cant: 4.00 | Actual: 19.82273 -> Correcto: 18.36082
UPDATE CostoInventario
SET Costo_MN = 18.3608186900
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000247279'
  AND Item = 39
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-09 08:03:00 | Cant: 8.00 | Actual: 19.82273 -> Correcto: 18.38692
UPDATE CostoInventario
SET Costo_MN = 18.3869242491
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000247281'
  AND Item = 33
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-09 08:09:00 | Cant: 3.00 | Actual: 19.82273 -> Correcto: 18.43820
UPDATE CostoInventario
SET Costo_MN = 18.4382030260
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000247282'
  AND Item = 25
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-09 10:58:00 | Cant: 9.00 | Actual: 19.82273 -> Correcto: 18.45675
UPDATE CostoInventario
SET Costo_MN = 18.4567457979
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000301310'
  AND Item = 19
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-09 11:25:00 | Cant: 2.00 | Actual: 19.82273 -> Correcto: 18.51163
UPDATE CostoInventario
SET Costo_MN = 18.5116290918
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000247283'
  AND Item = 3
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-09 11:42:00 | Cant: 2.00 | Actual: 19.82273 -> Correcto: 18.52334
UPDATE CostoInventario
SET Costo_MN = 18.5233353499
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000306686'
  AND Item = 2
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-10 07:09:00 | Cant: 9.00 | Actual: 19.82273 -> Correcto: 16.55268
UPDATE CostoInventario
SET Costo_MN = 16.5526789487
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000247306'
  AND Item = 41
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-10 08:01:00 | Cant: 7.00 | Actual: 19.82273 -> Correcto: 16.55268
UPDATE CostoInventario
SET Costo_MN = 16.5526789487
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000247307'
  AND Item = 35
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-10 08:17:00 | Cant: 2.00 | Actual: 19.82273 -> Correcto: 16.64388
UPDATE CostoInventario
SET Costo_MN = 16.6438755916
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000247319'
  AND Item = 39
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-10 08:22:00 | Cant: 5.00 | Actual: 19.82273 -> Correcto: 16.66921
UPDATE CostoInventario
SET Costo_MN = 16.6692051088
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000247326'
  AND Item = 31
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-10 09:32:27.730000 | Cant: 10.00 | Actual: 19.82273 -> Correcto: 16.85044
UPDATE CostoInventario
SET Costo_MN = 16.8504421715
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000247317'
  AND Item = 43
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-10 09:55:22.370000 | Cant: 5.00 | Actual: 19.82273 -> Correcto: 16.85044
UPDATE CostoInventario
SET Costo_MN = 16.8504421715
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000306643'
  AND Item = 19
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-11 08:42:00 | Cant: 6.00 | Actual: 19.82273 -> Correcto: 18.08908
UPDATE CostoInventario
SET Costo_MN = 18.0890802818
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000247379'
  AND Item = 43
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-11 08:48:15.240000 | Cant: 9.00 | Actual: 19.82273 -> Correcto: 18.11727
UPDATE CostoInventario
SET Costo_MN = 18.1172697081
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000247376'
  AND Item = 43
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-11 09:03:00 | Cant: 12.00 | Actual: 19.82273 -> Correcto: 19.22825
UPDATE CostoInventario
SET Costo_MN = 19.2282471984
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000247382'
  AND Item = 51
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-11 09:22:00 | Cant: 8.00 | Actual: 19.82273 -> Correcto: 19.23954
UPDATE CostoInventario
SET Costo_MN = 19.2395437837
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000247384'
  AND Item = 35
  AND IC_TipoCostoInventario = 'M';

-- Fecha: 2025-04-11 16:37:40.440000 | Cant: 1.00 | Actual: 19.82273 -> Correcto: 19.24095
UPDATE CostoInventario
SET Costo_MN = 19.2409524461
WHERE RucE = '20102351038'
  AND Cd_Inv = 'INV000287025'
  AND Item = 31
  AND IC_TipoCostoInventario = 'M';


-- Total de registros a actualizar: 59

-- Si todo está correcto, ejecutar:
COMMIT TRANSACTION

-- Si hay errores, ejecutar:
-- ROLLBACK TRANSACTION
