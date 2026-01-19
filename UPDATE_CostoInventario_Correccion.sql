-- =====================================================
-- SCRIPT DE CORRECCIÓN DE COSTOS EN CostoInventario
-- Producto: CREMOLADA X BOLSA MARACUYA (PD00026)
-- RucE: 20102351038
-- Generado automáticamente
-- =====================================================

USE [ERP_ECHA]
GO

BEGIN TRANSACTION

-- Fila 11: 2025-04-03 06:24:00 | Cant: 3 | Actual: 19.82273 -> Correcto: 18.65872
UPDATE CostoInventario SET Costo_MN = 18.6587200000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000287071' AND IC_TipoCostoInventario = 'M';

-- Fila 12: 2025-04-03 06:29:00 | Cant: 14 | Actual: 19.82273 -> Correcto: 18.65872
UPDATE CostoInventario SET Costo_MN = 18.6587200000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000287062' AND IC_TipoCostoInventario = 'M';

-- Fila 13: 2025-04-03 07:44:31 | Cant: 2 | Actual: 19.82273 -> Correcto: 18.65872
UPDATE CostoInventario SET Costo_MN = 18.6587200000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247030' AND IC_TipoCostoInventario = 'M';

-- Fila 14: 2025-04-03 08:04:03 | Cant: 17 | Actual: 19.82273 -> Correcto: 18.65872
UPDATE CostoInventario SET Costo_MN = 18.6587200000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247033' AND IC_TipoCostoInventario = 'M';

-- Fila 16: 2025-04-03 15:43:00 | Cant: 10 | Actual: 19.82273 -> Correcto: 18.16794
UPDATE CostoInventario SET Costo_MN = 18.1679400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000301307' AND IC_TipoCostoInventario = 'M';

-- Fila 17: 2025-04-03 17:51:00 | Cant: 7 | Actual: 19.82273 -> Correcto: 18.16794
UPDATE CostoInventario SET Costo_MN = 18.1679400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000306650' AND IC_TipoCostoInventario = 'M';

-- Fila 18: 2025-04-04 01:24:00 | Cant: 4 | Actual: 19.82273 -> Correcto: 18.16794
UPDATE CostoInventario SET Costo_MN = 18.1679400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000287063' AND IC_TipoCostoInventario = 'M';

-- Fila 19: 2025-04-04 08:04:24 | Cant: 11 | Actual: 19.82273 -> Correcto: 18.16794
UPDATE CostoInventario SET Costo_MN = 18.1679400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247074' AND IC_TipoCostoInventario = 'M';

-- Fila 20: 2025-04-04 08:06:26 | Cant: 7 | Actual: 19.82273 -> Correcto: 18.16794
UPDATE CostoInventario SET Costo_MN = 18.1679400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247075' AND IC_TipoCostoInventario = 'M';

-- Fila 21: 2025-04-04 08:20:42 | Cant: 7 | Actual: 19.82273 -> Correcto: 18.16794
UPDATE CostoInventario SET Costo_MN = 18.1679400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247076' AND IC_TipoCostoInventario = 'M';

-- Fila 22: 2025-04-04 08:36:07 | Cant: 6 | Actual: 19.82273 -> Correcto: 18.16794
UPDATE CostoInventario SET Costo_MN = 18.1679400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247078' AND IC_TipoCostoInventario = 'M';

-- Fila 23: 2025-04-04 10:22:00 | Cant: 1 | Actual: 19.82273 -> Correcto: 18.16794
UPDATE CostoInventario SET Costo_MN = 18.1679400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000306647' AND IC_TipoCostoInventario = 'M';

-- Fila 24: 2025-04-04 17:07:51 | Cant: 10 | Actual: 19.82273 -> Correcto: 18.16794
UPDATE CostoInventario SET Costo_MN = 18.1679400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000286903' AND IC_TipoCostoInventario = 'M';

-- Fila 25: 2025-04-05 06:43:00 | Cant: 2 | Actual: 19.82273 -> Correcto: 18.16794
UPDATE CostoInventario SET Costo_MN = 18.1679400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000286875' AND IC_TipoCostoInventario = 'M';

-- Fila 26: 2025-04-05 08:51:00 | Cant: 3 | Actual: 19.82273 -> Correcto: 18.16794
UPDATE CostoInventario SET Costo_MN = 18.1679400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000286876' AND IC_TipoCostoInventario = 'M';

-- Fila 27: 2025-04-05 13:24:51 | Cant: 6 | Actual: 19.82273 -> Correcto: 18.16794
UPDATE CostoInventario SET Costo_MN = 18.1679400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000286894' AND IC_TipoCostoInventario = 'M';

-- Fila 28: 2025-04-05 13:28:56 | Cant: 9 | Actual: 19.82273 -> Correcto: 18.16794
UPDATE CostoInventario SET Costo_MN = 18.1679400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000286896' AND IC_TipoCostoInventario = 'M';

-- Fila 29: 2025-04-05 13:38:12 | Cant: 14 | Actual: 19.82273 -> Correcto: 18.16794
UPDATE CostoInventario SET Costo_MN = 18.1679400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000286897' AND IC_TipoCostoInventario = 'M';

-- Fila 30: 2025-04-05 13:41:43 | Cant: 4 | Actual: 19.82273 -> Correcto: 18.16794
UPDATE CostoInventario SET Costo_MN = 18.1679400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000286898' AND IC_TipoCostoInventario = 'M';

-- Fila 31: 2025-04-06 09:06:00 | Cant: 12 | Actual: 19.82273 -> Correcto: 18.16794
UPDATE CostoInventario SET Costo_MN = 18.1679400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000287005' AND IC_TipoCostoInventario = 'M';

-- Fila 32: 2025-04-06 09:21:00 | Cant: 8 | Actual: 19.82273 -> Correcto: 18.16794
UPDATE CostoInventario SET Costo_MN = 18.1679400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000287010' AND IC_TipoCostoInventario = 'M';

-- Fila 33: 2025-04-06 10:17:07 | Cant: 18 | Actual: 19.82273 -> Correcto: 18.16794
UPDATE CostoInventario SET Costo_MN = 18.1679400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000286993' AND IC_TipoCostoInventario = 'M';

-- Fila 34: 2025-04-06 10:31:31 | Cant: 16 | Actual: 19.82273 -> Correcto: 18.16794
UPDATE CostoInventario SET Costo_MN = 18.1679400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000286994' AND IC_TipoCostoInventario = 'M';

-- Fila 35: 2025-04-06 11:02:22 | Cant: 30 | Actual: 19.82273 -> Correcto: 18.16794
UPDATE CostoInventario SET Costo_MN = 18.1679400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000286999' AND IC_TipoCostoInventario = 'M';

-- Fila 36: 2025-04-07 07:35:59 | Cant: 3 | Actual: 19.82273 -> Correcto: 18.16794
UPDATE CostoInventario SET Costo_MN = 18.1679400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000301246' AND IC_TipoCostoInventario = 'M';

-- Fila 37: 2025-04-07 08:08:00 | Cant: 6 | Actual: 19.82273 -> Correcto: 18.16794
UPDATE CostoInventario SET Costo_MN = 18.1679400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247199' AND IC_TipoCostoInventario = 'M';

-- Fila 38: 2025-04-07 08:22:00 | Cant: 6 | Actual: 19.82273 -> Correcto: 18.16794
UPDATE CostoInventario SET Costo_MN = 18.1679400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247198' AND IC_TipoCostoInventario = 'M';

-- Fila 39: 2025-04-07 09:03:00 | Cant: 3 | Actual: 19.82273 -> Correcto: 18.16794
UPDATE CostoInventario SET Costo_MN = 18.1679400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247205' AND IC_TipoCostoInventario = 'M';

-- Fila 40: 2025-04-07 09:49:30 | Cant: 8 | Actual: 19.82273 -> Correcto: 18.16794
UPDATE CostoInventario SET Costo_MN = 18.1679400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000306642' AND IC_TipoCostoInventario = 'M';

-- Fila 42: 2025-04-08 07:47:00 | Cant: 1 | Actual: 19.82273 -> Correcto: 16.68833
UPDATE CostoInventario SET Costo_MN = 16.6883300000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247208' AND IC_TipoCostoInventario = 'M';

-- Fila 43: 2025-04-08 07:56:00 | Cant: 10 | Actual: 19.82273 -> Correcto: 16.68833
UPDATE CostoInventario SET Costo_MN = 16.6883300000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247220' AND IC_TipoCostoInventario = 'M';

-- Fila 44: 2025-04-08 08:13:00 | Cant: 3 | Actual: 19.82273 -> Correcto: 16.68833
UPDATE CostoInventario SET Costo_MN = 16.6883300000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247223' AND IC_TipoCostoInventario = 'M';

-- Fila 45: 2025-04-08 09:34:31 | Cant: 3 | Actual: 19.82273 -> Correcto: 16.68833
UPDATE CostoInventario SET Costo_MN = 16.6883300000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247224' AND IC_TipoCostoInventario = 'M';

-- Fila 47: 2025-04-08 23:36:00 | Cant: 7 | Actual: 19.82273 -> Correcto: 16.45258
UPDATE CostoInventario SET Costo_MN = 16.4525800000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000287065' AND IC_TipoCostoInventario = 'M';

-- Fila 48: 2025-04-09 07:46:00 | Cant: 4 | Actual: 19.82273 -> Correcto: 16.45258
UPDATE CostoInventario SET Costo_MN = 16.4525800000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247273' AND IC_TipoCostoInventario = 'M';

-- Fila 49: 2025-04-09 07:50:00 | Cant: 6 | Actual: 19.82273 -> Correcto: 16.45258
UPDATE CostoInventario SET Costo_MN = 16.4525800000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247274' AND IC_TipoCostoInventario = 'M';

-- Fila 50: 2025-04-09 07:56:00 | Cant: 4 | Actual: 19.82273 -> Correcto: 16.45258
UPDATE CostoInventario SET Costo_MN = 16.4525800000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247279' AND IC_TipoCostoInventario = 'M';

-- Fila 51: 2025-04-09 08:03:00 | Cant: 8 | Actual: 19.82273 -> Correcto: 16.45258
UPDATE CostoInventario SET Costo_MN = 16.4525800000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247281' AND IC_TipoCostoInventario = 'M';

-- Fila 52: 2025-04-09 08:09:00 | Cant: 3 | Actual: 19.82273 -> Correcto: 16.45258
UPDATE CostoInventario SET Costo_MN = 16.4525800000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247282' AND IC_TipoCostoInventario = 'M';

-- Fila 53: 2025-04-09 10:58:00 | Cant: 9 | Actual: 19.82273 -> Correcto: 16.45258
UPDATE CostoInventario SET Costo_MN = 16.4525800000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000301310' AND IC_TipoCostoInventario = 'M';

-- Fila 54: 2025-04-09 11:25:00 | Cant: 2 | Actual: 19.82273 -> Correcto: 16.45258
UPDATE CostoInventario SET Costo_MN = 16.4525800000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247283' AND IC_TipoCostoInventario = 'M';

-- Fila 56: 2025-04-10 07:09:00 | Cant: 9 | Actual: 19.82273 -> Correcto: 9.20237
UPDATE CostoInventario SET Costo_MN = 9.2023700000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247306' AND IC_TipoCostoInventario = 'M';

-- Fila 57: 2025-04-10 08:01:00 | Cant: 7 | Actual: 19.82273 -> Correcto: 9.20237
UPDATE CostoInventario SET Costo_MN = 9.2023700000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247307' AND IC_TipoCostoInventario = 'M';

-- Fila 58: 2025-04-10 08:17:00 | Cant: 2 | Actual: 19.82273 -> Correcto: 9.20237
UPDATE CostoInventario SET Costo_MN = 9.2023700000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247319' AND IC_TipoCostoInventario = 'M';

-- Fila 59: 2025-04-10 08:22:00 | Cant: 5 | Actual: 19.82273 -> Correcto: 9.20237
UPDATE CostoInventario SET Costo_MN = 9.2023700000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247326' AND IC_TipoCostoInventario = 'M';

-- Fila 60: 2025-04-10 09:32:27 | Cant: 10 | Actual: 19.82273 -> Correcto: 9.20237
UPDATE CostoInventario SET Costo_MN = 9.2023700000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247317' AND IC_TipoCostoInventario = 'M';

-- Fila 61: 2025-04-10 09:55:22 | Cant: 5 | Actual: 19.82273 -> Correcto: 9.20237
UPDATE CostoInventario SET Costo_MN = 9.2023700000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000306643' AND IC_TipoCostoInventario = 'M';

-- Fila 63: 2025-04-11 08:42:00 | Cant: 6 | Actual: 19.82273 -> Correcto: 18.54035
UPDATE CostoInventario SET Costo_MN = 18.5403500000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247379' AND IC_TipoCostoInventario = 'M';

-- Fila 64: 2025-04-11 08:48:15 | Cant: 9 | Actual: 19.82273 -> Correcto: 18.54035
UPDATE CostoInventario SET Costo_MN = 18.5403500000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247376' AND IC_TipoCostoInventario = 'M';

-- Fila 66: 2025-04-11 09:03:00 | Cant: 12 | Actual: 19.82273 -> Correcto: 20.95500
UPDATE CostoInventario SET Costo_MN = 20.9550000000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247382' AND IC_TipoCostoInventario = 'M';

-- Fila 67: 2025-04-11 09:22:00 | Cant: 8 | Actual: 19.82273 -> Correcto: 20.95500
UPDATE CostoInventario SET Costo_MN = 20.9550000000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247384' AND IC_TipoCostoInventario = 'M';

-- Fila 68: 2025-04-11 16:37:40 | Cant: 1 | Actual: 19.82273 -> Correcto: 20.95500
UPDATE CostoInventario SET Costo_MN = 20.9550000000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000287025' AND IC_TipoCostoInventario = 'M';

-- Fila 69: 2025-04-12 08:39:00 | Cant: 8 | Actual: 19.82273 -> Correcto: 20.95500
UPDATE CostoInventario SET Costo_MN = 20.9550000000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247426' AND IC_TipoCostoInventario = 'M';

-- Fila 70: 2025-04-12 09:01:00 | Cant: 4 | Actual: 19.82273 -> Correcto: 20.95500
UPDATE CostoInventario SET Costo_MN = 20.9550000000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247428' AND IC_TipoCostoInventario = 'M';

-- Fila 71: 2025-04-12 09:12:46 | Cant: 8 | Actual: 19.82273 -> Correcto: 20.95500
UPDATE CostoInventario SET Costo_MN = 20.9550000000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247420' AND IC_TipoCostoInventario = 'M';

-- Fila 72: 2025-04-12 09:23:10 | Cant: 8 | Actual: 19.82273 -> Correcto: 20.95500
UPDATE CostoInventario SET Costo_MN = 20.9550000000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247423' AND IC_TipoCostoInventario = 'M';

-- Fila 73: 2025-04-12 10:42:44 | Cant: 5 | Actual: 19.82273 -> Correcto: 20.95500
UPDATE CostoInventario SET Costo_MN = 20.9550000000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247429' AND IC_TipoCostoInventario = 'M';

-- Fila 74: 2025-04-12 23:57:00 | Cant: 3 | Actual: 19.82273 -> Correcto: 20.95500
UPDATE CostoInventario SET Costo_MN = 20.9550000000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247460' AND IC_TipoCostoInventario = 'M';

-- Fila 75: 2025-04-13 08:15:00 | Cant: 6 | Actual: 19.82273 -> Correcto: 20.95500
UPDATE CostoInventario SET Costo_MN = 20.9550000000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247484' AND IC_TipoCostoInventario = 'M';

-- Fila 76: 2025-04-13 08:21:00 | Cant: 7 | Actual: 19.82273 -> Correcto: 20.95500
UPDATE CostoInventario SET Costo_MN = 20.9550000000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247487' AND IC_TipoCostoInventario = 'M';

-- Fila 77: 2025-04-13 08:25:34 | Cant: 2 | Actual: 19.82273 -> Correcto: 20.95500
UPDATE CostoInventario SET Costo_MN = 20.9550000000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247455' AND IC_TipoCostoInventario = 'M';

-- Fila 78: 2025-04-13 08:43:50 | Cant: 4 | Actual: 19.82273 -> Correcto: 20.95500
UPDATE CostoInventario SET Costo_MN = 20.9550000000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247456' AND IC_TipoCostoInventario = 'M';

-- Fila 79: 2025-04-14 08:02:00 | Cant: 4 | Actual: 19.82273 -> Correcto: 20.95500
UPDATE CostoInventario SET Costo_MN = 20.9550000000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000287026' AND IC_TipoCostoInventario = 'M';

-- Fila 80: 2025-04-14 08:11:00 | Cant: 1 | Actual: 19.82273 -> Correcto: 20.95500
UPDATE CostoInventario SET Costo_MN = 20.9550000000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247492' AND IC_TipoCostoInventario = 'M';

-- Fila 81: 2025-04-14 08:12:35 | Cant: 3 | Actual: 19.82273 -> Correcto: 20.95500
UPDATE CostoInventario SET Costo_MN = 20.9550000000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247477' AND IC_TipoCostoInventario = 'M';

-- Fila 82: 2025-04-14 08:17:58 | Cant: 2 | Actual: 19.82273 -> Correcto: 20.95500
UPDATE CostoInventario SET Costo_MN = 20.9550000000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247478' AND IC_TipoCostoInventario = 'M';

-- Fila 84: 2025-04-15 07:56:27 | Cant: 2 | Actual: 19.82273 -> Correcto: 22.79931
UPDATE CostoInventario SET Costo_MN = 22.7993100000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000301249' AND IC_TipoCostoInventario = 'M';

-- Fila 85: 2025-04-15 08:17:00 | Cant: 2 | Actual: 19.82273 -> Correcto: 22.79931
UPDATE CostoInventario SET Costo_MN = 22.7993100000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247544' AND IC_TipoCostoInventario = 'M';

-- Fila 86: 2025-04-15 08:23:00 | Cant: 1 | Actual: 19.82273 -> Correcto: 22.79931
UPDATE CostoInventario SET Costo_MN = 22.7993100000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247545' AND IC_TipoCostoInventario = 'M';

-- Fila 87: 2025-04-15 08:29:31 | Cant: 2 | Actual: 19.82273 -> Correcto: 22.79931
UPDATE CostoInventario SET Costo_MN = 22.7993100000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247536' AND IC_TipoCostoInventario = 'M';

-- Fila 88: 2025-04-15 08:52:00 | Cant: 2 | Actual: 19.82273 -> Correcto: 22.79931
UPDATE CostoInventario SET Costo_MN = 22.7993100000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247547' AND IC_TipoCostoInventario = 'M';

-- Fila 89: 2025-04-15 09:16:25 | Cant: 1 | Actual: 19.82273 -> Correcto: 22.79931
UPDATE CostoInventario SET Costo_MN = 22.7993100000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247543' AND IC_TipoCostoInventario = 'M';

-- Fila 91: 2025-04-15 18:18:21 | Cant: 9 | Actual: 19.82273 -> Correcto: 22.29855
UPDATE CostoInventario SET Costo_MN = 22.2985500000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000301315' AND IC_TipoCostoInventario = 'M';

-- Fila 92: 2025-04-16 08:10:00 | Cant: 3 | Actual: 19.82273 -> Correcto: 22.29855
UPDATE CostoInventario SET Costo_MN = 22.2985500000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247596' AND IC_TipoCostoInventario = 'M';

-- Fila 93: 2025-04-16 08:17:02 | Cant: 7 | Actual: 19.82273 -> Correcto: 22.29855
UPDATE CostoInventario SET Costo_MN = 22.2985500000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247590' AND IC_TipoCostoInventario = 'M';

-- Fila 94: 2025-04-16 08:18:00 | Cant: 3 | Actual: 19.82273 -> Correcto: 22.29855
UPDATE CostoInventario SET Costo_MN = 22.2985500000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247597' AND IC_TipoCostoInventario = 'M';

-- Fila 95: 2025-04-16 08:25:27 | Cant: 2 | Actual: 19.82273 -> Correcto: 22.29855
UPDATE CostoInventario SET Costo_MN = 22.2985500000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247591' AND IC_TipoCostoInventario = 'M';

-- Fila 96: 2025-04-16 09:52:27 | Cant: 4 | Actual: 19.82273 -> Correcto: 22.29855
UPDATE CostoInventario SET Costo_MN = 22.2985500000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247599' AND IC_TipoCostoInventario = 'M';

-- Fila 98: 2025-04-17 08:16:00 | Cant: 6 | Actual: 19.82273 -> Correcto: 23.67354
UPDATE CostoInventario SET Costo_MN = 23.6735400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247649' AND IC_TipoCostoInventario = 'M';

-- Fila 99: 2025-04-17 08:17:20 | Cant: 6 | Actual: 19.82273 -> Correcto: 23.67354
UPDATE CostoInventario SET Costo_MN = 23.6735400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247645' AND IC_TipoCostoInventario = 'M';

-- Fila 100: 2025-04-17 08:22:00 | Cant: 4 | Actual: 19.82273 -> Correcto: 23.67354
UPDATE CostoInventario SET Costo_MN = 23.6735400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247650' AND IC_TipoCostoInventario = 'M';

-- Fila 101: 2025-04-17 08:23:11 | Cant: 8 | Actual: 19.82273 -> Correcto: 23.67354
UPDATE CostoInventario SET Costo_MN = 23.6735400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247646' AND IC_TipoCostoInventario = 'M';

-- Fila 102: 2025-04-17 10:05:37 | Cant: 3 | Actual: 19.82273 -> Correcto: 23.67354
UPDATE CostoInventario SET Costo_MN = 23.6735400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247651' AND IC_TipoCostoInventario = 'M';

-- Fila 103: 2025-04-18 07:42:00 | Cant: 9 | Actual: 19.82273 -> Correcto: 23.67354
UPDATE CostoInventario SET Costo_MN = 23.6735400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247660' AND IC_TipoCostoInventario = 'M';

-- Fila 104: 2025-04-18 07:46:00 | Cant: 5 | Actual: 19.82273 -> Correcto: 23.67354
UPDATE CostoInventario SET Costo_MN = 23.6735400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247658' AND IC_TipoCostoInventario = 'M';

-- Fila 105: 2025-04-18 08:03:27 | Cant: 13 | Actual: 19.82273 -> Correcto: 23.67354
UPDATE CostoInventario SET Costo_MN = 23.6735400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000301250' AND IC_TipoCostoInventario = 'M';

-- Fila 106: 2025-04-18 08:36:31 | Cant: 7 | Actual: 19.82273 -> Correcto: 23.67354
UPDATE CostoInventario SET Costo_MN = 23.6735400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247657' AND IC_TipoCostoInventario = 'M';

-- Fila 107: 2025-04-18 10:05:45 | Cant: 12 | Actual: 19.82273 -> Correcto: 23.67354
UPDATE CostoInventario SET Costo_MN = 23.6735400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000301263' AND IC_TipoCostoInventario = 'M';

-- Fila 108: 2025-04-19 07:43:00 | Cant: 4 | Actual: 19.82273 -> Correcto: 23.67354
UPDATE CostoInventario SET Costo_MN = 23.6735400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247685' AND IC_TipoCostoInventario = 'M';

-- Fila 109: 2025-04-19 07:52:00 | Cant: 10 | Actual: 19.82273 -> Correcto: 23.67354
UPDATE CostoInventario SET Costo_MN = 23.6735400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247686' AND IC_TipoCostoInventario = 'M';

-- Fila 110: 2025-04-19 08:11:28 | Cant: 14 | Actual: 19.82273 -> Correcto: 23.67354
UPDATE CostoInventario SET Costo_MN = 23.6735400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000301251' AND IC_TipoCostoInventario = 'M';

-- Fila 111: 2025-04-19 09:42:21 | Cant: 9 | Actual: 19.82273 -> Correcto: 23.67354
UPDATE CostoInventario SET Costo_MN = 23.6735400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247680' AND IC_TipoCostoInventario = 'M';

-- Fila 112: 2025-04-19 10:11:00 | Cant: 9 | Actual: 19.82273 -> Correcto: 23.67354
UPDATE CostoInventario SET Costo_MN = 23.6735400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247689' AND IC_TipoCostoInventario = 'M';

-- Fila 113: 2025-04-19 12:25:44 | Cant: 3 | Actual: 19.82273 -> Correcto: 23.67354
UPDATE CostoInventario SET Costo_MN = 23.6735400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247688' AND IC_TipoCostoInventario = 'M';

-- Fila 114: 2025-04-20 08:24:06 | Cant: 10 | Actual: 19.82273 -> Correcto: 23.67354
UPDATE CostoInventario SET Costo_MN = 23.6735400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000301253' AND IC_TipoCostoInventario = 'M';

-- Fila 115: 2025-04-20 14:49:00 | Cant: 6 | Actual: 19.82273 -> Correcto: 23.67354
UPDATE CostoInventario SET Costo_MN = 23.6735400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247835' AND IC_TipoCostoInventario = 'M';

-- Fila 116: 2025-04-20 14:56:00 | Cant: 6 | Actual: 19.82273 -> Correcto: 23.67354
UPDATE CostoInventario SET Costo_MN = 23.6735400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247829' AND IC_TipoCostoInventario = 'M';

-- Fila 117: 2025-04-20 15:00:00 | Cant: 5 | Actual: 19.82273 -> Correcto: 23.67354
UPDATE CostoInventario SET Costo_MN = 23.6735400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247836' AND IC_TipoCostoInventario = 'M';

-- Fila 118: 2025-04-21 08:18:00 | Cant: 6 | Actual: 19.82273 -> Correcto: 23.67354
UPDATE CostoInventario SET Costo_MN = 23.6735400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247750' AND IC_TipoCostoInventario = 'M';

-- Fila 119: 2025-04-21 10:08:58 | Cant: 3 | Actual: 19.82273 -> Correcto: 23.67354
UPDATE CostoInventario SET Costo_MN = 23.6735400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000301265' AND IC_TipoCostoInventario = 'M';

-- Fila 120: 2025-04-21 10:11:30 | Cant: 1 | Actual: 19.82273 -> Correcto: 23.67354
UPDATE CostoInventario SET Costo_MN = 23.6735400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000301266' AND IC_TipoCostoInventario = 'M';

-- Fila 121: 2025-04-21 10:28:37 | Cant: 5 | Actual: 19.82273 -> Correcto: 23.67354
UPDATE CostoInventario SET Costo_MN = 23.6735400000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000301276' AND IC_TipoCostoInventario = 'M';

-- Fila 123: 2025-04-21 16:00:29 | Cant: 7 | Actual: 19.82273 -> Correcto: 25.42249
UPDATE CostoInventario SET Costo_MN = 25.4224900000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247795' AND IC_TipoCostoInventario = 'M';

-- Fila 124: 2025-04-22 08:35:58 | Cant: 4 | Actual: 19.82273 -> Correcto: 25.42249
UPDATE CostoInventario SET Costo_MN = 25.4224900000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247838' AND IC_TipoCostoInventario = 'M';

-- Fila 125: 2025-04-22 08:38:38 | Cant: 3 | Actual: 19.82273 -> Correcto: 25.42249
UPDATE CostoInventario SET Costo_MN = 25.4224900000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247839' AND IC_TipoCostoInventario = 'M';

-- Fila 126: 2025-04-22 10:14:54 | Cant: 7 | Actual: 19.82273 -> Correcto: 25.42249
UPDATE CostoInventario SET Costo_MN = 25.4224900000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000301268' AND IC_TipoCostoInventario = 'M';

-- Fila 127: 2025-04-22 10:35:27 | Cant: 1 | Actual: 19.82273 -> Correcto: 25.42249
UPDATE CostoInventario SET Costo_MN = 25.4224900000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000301278' AND IC_TipoCostoInventario = 'M';

-- Fila 129: 2025-04-22 15:52:00 | Cant: 8 | Actual: 19.82273 -> Correcto: 27.08491
UPDATE CostoInventario SET Costo_MN = 27.0849100000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000301308' AND IC_TipoCostoInventario = 'M';

-- Fila 130: 2025-04-23 08:18:24 | Cant: 5 | Actual: 19.82273 -> Correcto: 27.08491
UPDATE CostoInventario SET Costo_MN = 27.0849100000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247947' AND IC_TipoCostoInventario = 'M';

-- Fila 131: 2025-04-23 09:00:00 | Cant: 8 | Actual: 19.82273 -> Correcto: 27.08491
UPDATE CostoInventario SET Costo_MN = 27.0849100000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000248015' AND IC_TipoCostoInventario = 'M';

-- Fila 132: 2025-04-23 09:11:09 | Cant: 1 | Actual: 19.82273 -> Correcto: 27.08491
UPDATE CostoInventario SET Costo_MN = 27.0849100000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000247956' AND IC_TipoCostoInventario = 'M';

-- Fila 133: 2025-04-23 10:18:24 | Cant: 1 | Actual: 19.82273 -> Correcto: 27.08491
UPDATE CostoInventario SET Costo_MN = 27.0849100000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000301270' AND IC_TipoCostoInventario = 'M';

-- Fila 134: 2025-04-23 10:24:17 | Cant: 2 | Actual: 19.82273 -> Correcto: 27.08491
UPDATE CostoInventario SET Costo_MN = 27.0849100000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000301275' AND IC_TipoCostoInventario = 'M';

-- Fila 136: 2025-04-24 08:48:55 | Cant: 5 | Actual: 19.82273 -> Correcto: 29.33218
UPDATE CostoInventario SET Costo_MN = 29.3321800000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000248024' AND IC_TipoCostoInventario = 'M';

-- Fila 137: 2025-04-24 08:52:06 | Cant: 8 | Actual: 19.82273 -> Correcto: 29.33218
UPDATE CostoInventario SET Costo_MN = 29.3321800000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000248026' AND IC_TipoCostoInventario = 'M';

-- Fila 138: 2025-04-24 09:16:00 | Cant: 7 | Actual: 19.82273 -> Correcto: 29.33218
UPDATE CostoInventario SET Costo_MN = 29.3321800000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000248033' AND IC_TipoCostoInventario = 'M';

-- Fila 139: 2025-04-24 09:23:00 | Cant: 7 | Actual: 19.82273 -> Correcto: 29.33218
UPDATE CostoInventario SET Costo_MN = 29.3321800000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000248034' AND IC_TipoCostoInventario = 'M';

-- Fila 140: 2025-04-24 09:29:00 | Cant: 5 | Actual: 19.82273 -> Correcto: 29.33218
UPDATE CostoInventario SET Costo_MN = 29.3321800000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000248035' AND IC_TipoCostoInventario = 'M';

-- Fila 142: 2025-04-25 08:07:00 | Cant: 11 | Actual: 19.82273 -> Correcto: 27.48463
UPDATE CostoInventario SET Costo_MN = 27.4846300000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000248124' AND IC_TipoCostoInventario = 'M';

-- Fila 143: 2025-04-25 08:24:49 | Cant: 3 | Actual: 19.82273 -> Correcto: 27.48463
UPDATE CostoInventario SET Costo_MN = 27.4846300000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000248126' AND IC_TipoCostoInventario = 'M';

-- Fila 144: 2025-04-25 08:26:00 | Cant: 5 | Actual: 19.82273 -> Correcto: 27.48463
UPDATE CostoInventario SET Costo_MN = 27.4846300000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000248144' AND IC_TipoCostoInventario = 'M';

-- Fila 145: 2025-04-25 08:30:00 | Cant: 1 | Actual: 19.82273 -> Correcto: 27.48463
UPDATE CostoInventario SET Costo_MN = 27.4846300000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000248145' AND IC_TipoCostoInventario = 'M';

-- Fila 146: 2025-04-25 09:10:21 | Cant: 10 | Actual: 19.82273 -> Correcto: 27.48463
UPDATE CostoInventario SET Costo_MN = 27.4846300000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000248143' AND IC_TipoCostoInventario = 'M';

-- Fila 148: 2025-04-26 08:30:58 | Cant: 3 | Actual: 19.82273 -> Correcto: 28.42319
UPDATE CostoInventario SET Costo_MN = 28.4231900000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000248221' AND IC_TipoCostoInventario = 'M';

-- Fila 149: 2025-04-26 10:42:02 | Cant: 3 | Actual: 19.82273 -> Correcto: 28.42319
UPDATE CostoInventario SET Costo_MN = 28.4231900000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000301279' AND IC_TipoCostoInventario = 'M';

-- Fila 150: 2025-04-26 10:44:50 | Cant: 5 | Actual: 19.82273 -> Correcto: 28.42319
UPDATE CostoInventario SET Costo_MN = 28.4231900000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000301280' AND IC_TipoCostoInventario = 'M';

-- Fila 151: 2025-04-26 10:50:41 | Cant: 2 | Actual: 19.82273 -> Correcto: 28.42319
UPDATE CostoInventario SET Costo_MN = 28.4231900000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000301281' AND IC_TipoCostoInventario = 'M';

-- Fila 152: 2025-04-26 10:55:49 | Cant: 4 | Actual: 19.82273 -> Correcto: 28.42319
UPDATE CostoInventario SET Costo_MN = 28.4231900000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000301282' AND IC_TipoCostoInventario = 'M';

-- Fila 153: 2025-04-27 07:42:00 | Cant: 13 | Actual: 19.82273 -> Correcto: 28.42319
UPDATE CostoInventario SET Costo_MN = 28.4231900000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000248319' AND IC_TipoCostoInventario = 'M';

-- Fila 154: 2025-04-27 07:47:00 | Cant: 4 | Actual: 19.82273 -> Correcto: 28.42319
UPDATE CostoInventario SET Costo_MN = 28.4231900000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000248320' AND IC_TipoCostoInventario = 'M';

-- Fila 155: 2025-04-27 08:19:45 | Cant: 6 | Actual: 19.82273 -> Correcto: 28.42319
UPDATE CostoInventario SET Costo_MN = 28.4231900000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000248313' AND IC_TipoCostoInventario = 'M';

-- Fila 156: 2025-04-27 08:22:29 | Cant: 7 | Actual: 19.82273 -> Correcto: 28.42319
UPDATE CostoInventario SET Costo_MN = 28.4231900000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000248314' AND IC_TipoCostoInventario = 'M';

-- Fila 157: 2025-04-27 09:59:18 | Cant: 1 | Actual: 19.82273 -> Correcto: 28.42319
UPDATE CostoInventario SET Costo_MN = 28.4231900000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000248321' AND IC_TipoCostoInventario = 'M';

-- Fila 158: 2025-04-28 08:10:00 | Cant: 1 | Actual: 19.82273 -> Correcto: 28.42319
UPDATE CostoInventario SET Costo_MN = 28.4231900000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000250719' AND IC_TipoCostoInventario = 'M';

-- Fila 159: 2025-04-28 08:14:17 | Cant: 4 | Actual: 19.82273 -> Correcto: 28.42319
UPDATE CostoInventario SET Costo_MN = 28.4231900000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000250706' AND IC_TipoCostoInventario = 'M';

-- Fila 160: 2025-04-28 08:30:00 | Cant: 3 | Actual: 19.82273 -> Correcto: 28.42319
UPDATE CostoInventario SET Costo_MN = 28.4231900000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000250729' AND IC_TipoCostoInventario = 'M';

-- Fila 161: 2025-04-28 09:09:47 | Cant: 5 | Actual: 19.82273 -> Correcto: 28.42319
UPDATE CostoInventario SET Costo_MN = 28.4231900000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000250725' AND IC_TipoCostoInventario = 'M';

-- Fila 162: 2025-04-28 11:08:39 | Cant: 3 | Actual: 19.82273 -> Correcto: 28.42319
UPDATE CostoInventario SET Costo_MN = 28.4231900000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000301284' AND IC_TipoCostoInventario = 'M';

-- Fila 164: 2025-04-29 08:18:00 | Cant: 2 | Actual: 19.82273 -> Correcto: 29.83915
UPDATE CostoInventario SET Costo_MN = 29.8391500000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000251808' AND IC_TipoCostoInventario = 'M';

-- Fila 165: 2025-04-29 08:19:01 | Cant: 1 | Actual: 19.82273 -> Correcto: 29.83915
UPDATE CostoInventario SET Costo_MN = 29.8391500000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000251802' AND IC_TipoCostoInventario = 'M';

-- Fila 167: 2025-04-30 07:42:49 | Cant: 2 | Actual: 19.82273 -> Correcto: 30.51972
UPDATE CostoInventario SET Costo_MN = 30.5197200000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000255094' AND IC_TipoCostoInventario = 'M';

-- Fila 168: 2025-04-30 08:27:00 | Cant: 7 | Actual: 19.82273 -> Correcto: 30.51972
UPDATE CostoInventario SET Costo_MN = 30.5197200000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000255671' AND IC_TipoCostoInventario = 'M';

-- Fila 169: 2025-04-30 08:46:24 | Cant: 6 | Actual: 19.82273 -> Correcto: 30.51972
UPDATE CostoInventario SET Costo_MN = 30.5197200000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000255631' AND IC_TipoCostoInventario = 'M';

-- Fila 171: 2025-04-30 09:21:00 | Cant: 5 | Actual: 19.82273 -> Correcto: 30.98858
UPDATE CostoInventario SET Costo_MN = 30.9885800000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000256056' AND IC_TipoCostoInventario = 'M';

-- Fila 172: 2025-04-30 10:07:00 | Cant: 12 | Actual: 19.82273 -> Correcto: 30.98858
UPDATE CostoInventario SET Costo_MN = 30.9885800000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000256057' AND IC_TipoCostoInventario = 'M';

-- Fila 173: 2025-04-30 16:04:00 | Cant: 4 | Actual: 19.82273 -> Correcto: 30.98858
UPDATE CostoInventario SET Costo_MN = 30.9885800000 WHERE RucE = '20102351038' AND Cd_Inv = 'INV000301309' AND IC_TipoCostoInventario = 'M';


-- =====================================================
-- Total de registros a actualizar: 146
-- =====================================================

-- VERIFICAR ANTES DE CONFIRMAR:
-- SELECT COUNT(*) FROM CostoInventario WHERE RucE = '20102351038' AND Cd_Inv IN ('INV000287071','INV000287062',...) AND IC_TipoCostoInventario = 'M'

-- Si todo está correcto, ejecutar:
COMMIT TRANSACTION

-- Si hay errores, ejecutar:
-- ROLLBACK TRANSACTION
