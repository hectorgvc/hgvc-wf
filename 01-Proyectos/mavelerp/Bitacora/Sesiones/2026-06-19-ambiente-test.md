---
fecha: 2026-06-19
proyecto: mavelerp
autor: hector
tags: [sesion, dgii, ambiente, testecf, certecf, postulacion, critico]
---

# Sesión 2026-06-19 — Ambiente test: facturas no llegaban (RESUELTO)

## Síntoma (crítico)

"No están llegando las facturas al ambiente de pruebas." Hipótesis del
usuario: se removió algo del test sin analizar las implicaciones.

## Diagnóstico (con datos de producción)

1. Config correcta: `ecf_mode=ELECTRONIC`, `ecf_environment=CERT`,
   certificado presente.
2. Las facturas SÍ se enviaban a certecf (http 200, trackId emitido →
   estructura y firma válidas).
3. **DGII las rechazaba TODAS** (canal normal E31/E45 Y RFCE E32) con
   código **1209**: *"El RNC Emisor 133398176, no tiene una postulación
   activa."* (confirmado con `checkStatus` real sobre E310000000071).
4. Timeline: 22 facturas **Aceptadas** del 04→06 jun; desde ~06 jun todo
   queda atascado en `Procesando`/`Rechazado`. Coincide con la entrada a
   la fase **Simulación / Representación Impresa**.

## Causa raíz (NO es código)

La **postulación de certificación** del RNC 133398176 en **CerteCF** se
cerró al completarse la certificación (el usuario ya solicitó los rangos
de producción). CerteCF deja de aceptar envíos API cuando la postulación
ya no está activa. Ninguno de los cambios del día (customer_type, RNC
lookup, 2FA, NC/ND) tocó el envío e-CF.

**Lo "removido como test":** en `ncf_sequences` solo quedaban rangos
`ambiente=cert`; los `test` se habían borrado → el ambiente TEST no podía
ni asignar e-NCF (`nextEcfFromRange` filtra por ambiente).

## Solución (el amigo tenía razón: usar TesteCF)

**TesteCF** (`https://ecf.dgii.gov.do/testecf`) es el sandbox permanente
que **no depende** de la postulación de certificación. Sigue disponible
para pruebas aunque la certificación esté completa.

Cambios aplicados en producción (solo lo de test, NO se tocó cert/prod):
1. **Sembrados 10 rangos `ncf_sequences` de `ambiente=test`** (tipos
   31,32,33,34,41,43,44,45,46,47).
2. **`settings.ecf_environment = 'TEST'`** (revertir: `='CERT'`).
3. Las secuencias test se chocaban con números ya usados antes en testecf
   (*"Este número de secuencia ya ha sido utilizado"*) → se subió la base
   de todos los rangos test a **1000** (next = 1001).

## Validación end-to-end (cerrado el loop)

- Handshake auth contra testecf → **token OK** (cert firma, RNC con acceso).
- Envío e-CF E31 de prueba (`E310000001001`) → **estado DGII: Aceptado** ✓.

## Estado final

- Ambiente: **TEST** (testecf). Generación + firma + envío + aceptación
  funcionan. El usuario puede generar y validar facturas de nuevo.
- Rangos: `cert` (10, intactos) + `test` (10, base 1000). Sin rangos prod.
- Cuando lleguen/activen los rangos de **producción** → cambiar
  `ecf_environment` a `PROD` (irá al ambiente real `ecf.dgii.gov.do/ecf`).

## Pendientes

- [ ] Las 71 facturas viejas en `Procesando` (rechazadas por cert/1209)
      quedan huérfanas en ese estado. Limpieza opcional (marcarlas
      Rechazado/Anulado) — no crítico.
- [ ] Al pasar a producción: sembrar rangos `ambiente=prod` con la
      secuencia autorizada por DGII y cambiar `ecf_environment=PROD`.
- [ ] (Mejora) UI en admin para cambiar ambiente + ver/gestionar rangos
      NCF por ambiente, en vez de SQL manual.

## Bloqueadores

Ninguno. Ambiente de pruebas operativo.
