---
fecha: 2026-06-20
proyecto: mavelerp
autor: hector
tags: [sesion, ecf, ambiente, crítico, producción, error1209, dgii, bugfix]
---

# Sesión 2026-06-20 — Incidente crítico: ecf_environment = CERT accidental

## Objetivo

Registrar y resolver incidente crítico que bloqueaba todas las facturas E31 en producción.

## Síntoma

Las facturas E31 enviadas a DGII devolvían error:
- Código DGII: **1209** — "El RNC Emisor 133398176, no tiene una postulación activa."
- QR impreso mostraba: "No fue encontrada la factura (e-CF)".
- El estado en la BD quedaba en "Rechazado" aunque localmente decía "Aceptado".

## Causa raíz

La columna `settings.ecf_environment` tenía el valor **`CERT`** (CerteCF — ambiente de certificación) en lugar de `TEST` (TesteCF — sandbox activo).

**Por qué pasó:** Probablemente alguien guardó la página de Configuración con el dropdown de ambiente seleccionado en CERT durante las pruebas del día. CerteCF se cerró tras completar los Pasos 1-3 de certificación. Todas las facturas E31 se enviaban al ambiente equivocado.

**Por qué el error 1209:** DGII rechaza cualquier envío a CerteCF si el RNC no tiene una postulación **activa** en ese ambiente (ya expiró, se cerró, etc.).

## Resolución — tres partes

### 1. Fix de configuración (urgente)
```sql
UPDATE settings SET ecf_environment = 'TEST' WHERE id = 1;
```
Ejecutado en producción (Hostinger) a las 2026-06-20 09:45. Todas las facturas nuevas ahora se envían a TesteCF correctamente.

### 2. Mejora en `ecfStatus()` — no sobrescribir estado anterior
**Archivo:** `modules/Facturacion/Controllers/FacturacionController.php`

**El problema:** Código 5000002 de DGII significa "aún procesando" (no "rechazado"). Las E31 son asíncronas; DGII puede tardar 2–10 segundos antes de registrar el e-CF. Nuestro endpoint `/api/ecfStatus` lo interpretaba mal y sobrescribía `estado_dgii` con "No encontrado." → confundía el flujo (el usuario recargaba y veía "Rechazado" en lugar de esperar).

**Fix:** Ahora `ecfStatus()` ignora el código 5000002 **sin cambiar el estado existente**. Si DGII no encontró el e-CF aún, dejamos el estado anterior intacto.

**Verificación:** Las facturas históricas que fallaron (ej. E310000000072) quedaron en CerteCF con `secuenciaUtilizada=false` (DGII no las contabilizó). Pero la secuencia de TesteCF continúa correctamente desde 1012+.

### 3. Auto-refresh de estado — delay aumentado
**De:** 3 segundos  
**A:** 10 segundos

E31 son asíncronas. DGII puede tardar varios segundos antes de devolver el estado. Un delay de 3 segundos es insuficiente y genera falsos positivos (5000002 prematuro → confusion en UI).

## Qué se documentó

1. **BUG-008** agregado en `Bugs/Bugs.md` (nuevo BUG crítico).
2. **Regla de oro** agregada en `CLAUDE.md` del proyecto (3 reglas para evitar repetir el patrón).

## Archivos tocados

- `modules/Facturacion/Controllers/FacturacionController.php` — `ecfStatus()` mejorado
- `CLAUDE.md` (del proyecto) — "Reglas de oro — e-CF crítico" sección nueva
- `Bugs/Bugs.md` — BUG-008 registrado como resuelto

## Nota sobre ambiente

La regla es simple:
- **TEST** (TesteCF) = sandbox activo, usado para desarrollo y pruebas de certificación
- **CERT** (CerteCF) = ambiente de certificación cerrado tras Pasos 1-3 (no usar)
- **PROD** (eCF) = producción real, solo cuando el usuario apruebe explícitamente

**NUNCA** tocar `settings.ecf_environment` sin confirmación explícita del usuario. Es el "interruptor de ambiente".

## Pendientes

- [ ] Historial de facturas que fallaron con error 1209 (E310000000072 y potencialmente otras).
      Opción: reenviar la E31 000000072 si el usuario lo solicita (la secuencia continúa desde 1012+).
- [ ] UI: Avisar al usuario si `ecf_environment` NO es TEST (banner rojo en dashboard si está en CERT/PROD).

## Bloqueadores

Ninguno. El incidente se resolvió 2026-06-20 09:45. Todas las nuevas E31 van a TesteCF.
