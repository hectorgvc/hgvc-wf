# Bugs conocidos — mavelerp

> Lista viva. Marcar `[x]` al cerrar e indicar commit/fecha de fix.
> Los críticos que bloquean producción van al tope.

---

## Resueltos

### BUG-001: 2FA da error ✅ RESUELTO (2026-06-19)

- **Detectado**: 2026-06-18 · **Resuelto**: 2026-06-19
- **Síntoma**: La pantalla de configurar 2FA (`/totp/setup`) daba error.
- **Causa raíz**: `TotpController.php:73` llamaba `QrHelper::imgTagFromUrl()`
  sin backslash. El controller está en namespace `App\Controllers` y
  `QrHelper` vive en el namespace global → PHP buscaba
  `App\Controllers\QrHelper` → Fatal "Class not found".
- **Fix**: anteponer `\` → `\QrHelper::imgTagFromUrl(...)`. Una línea.
- **Detalle**: [[../Bitacora/Sesiones/2026-06-19-fix-2fa]].
- **Mejora futura**: mover `QrHelper` a namespace `Core\Helpers` + autoload
  para evitar repetir el patrón.

### BUG-003: RNC se guardaba con guiones en la BD ✅ RESUELTO (2026-06-20)

- **Detectado**: 2026-06-20 · **Resuelto**: 2026-06-20
- **Síntoma**: Clientes nuevos no funcionaban en TesteCF. RNC visualmente enmascarado (`131-88068-1`)
  se guardaba en BD **con guiones** → `strlen($rnc) === 11` en vez de 9 → clasificación errónea
  como cédula en lugar de RNC → asignación de `E32` en vez de `E31`.
- **Causa raíz**: Máscara JS formatea el RNC; backend no normalizaba antes del INSERT.
- **Fix**: `preg_replace('/[^0-9]/', '', trim($rnc))` en `store()`, `update()` e `importProcess()`
  de `CustomerController`.
- **Archivos**: `modules/CRM/Controllers/CustomerController.php`.
- **Detalle**: [[../Bitacora/Sesiones/2026-06-20-bug-rnc-guiones]].
- **Deploy**: 2026-06-20 — confirmado resuelto en producción (Hostinger).
- **Pendiente menor**: UPDATE correctivo en BD de producción para clientes históricos con RNC
  con guiones: `UPDATE customers SET rnc = REPLACE(rnc, '-', '') WHERE rnc LIKE '%-%';`

### BUG-004: `validate_entity_name` rechazaba razones sociales legítimas ✅ RESUELTO (2026-06-20)

- **Detectado**: 2026-06-20 · **Resuelto**: 2026-06-20
- **Síntoma**: Formulario de clientes rechazaba nombres legítimos: `MAVEL & TEC, S.R.L.`, `7-ELEVEN`,
  `FARMACIA DEL DR. JUAN` (con caracteres como `.`, `,`, `&`, `-`, dígitos).
- **Causa raíz**: Regex de `validate_entity_name()` demasiado restrictiva: solo permitía letras
  y espacios.
- **Fix**: Regex ampliado en `core/helpers.php` a `/^[\w\s\.,&\#\'\-\/áéíóúÁÉÍÓÚñÑ]+$/u`.
  Sincronizado en validación JS del form.
- **Archivos**: `core/helpers.php`, `modules/CRM/Views/customers/form.php`.
- **Detalle**: [[../Bitacora/Sesiones/2026-06-20-bug-rnc-guiones]].
- **Deploy**: 2026-06-20 — confirmado resuelto en producción (Hostinger).

### BUG-005: Código de diagnóstico temporal en EmitsEcf.php ✅ RESUELTO (2026-06-20)

- **Detectado**: 2026-06-20 · **Resuelto**: 2026-06-20
- **Síntoma**: Bloque de diagnóstico dejado en `modules/Facturacion/Concerns/EmitsEcf.php`
  escribiendo en ruta incorrecta `/logs/` (vs `/storage/logs/`).
- **Causa raíz**: Código temporal de debug nunca fue removido antes de commit.
- **Fix**: Bloque eliminado completamente. Diagnóstico ya se registra via `log_error()`.
- **Archivos**: `modules/Facturacion/Concerns/EmitsEcf.php`.
- **Detalle**: [[../Bitacora/Sesiones/2026-06-20-bug-rnc-guiones]].
- **Deploy**: 2026-06-20 — confirmado resuelto en producción (Hostinger).

### BUG-006: Importación masiva no normalizaba RNC ni asignaba `customer_type` ✅ RESUELTO (2026-06-20)

- **Detectado**: 2026-06-20 · **Resuelto**: 2026-06-20
- **Síntoma**: CSV importado dejaba clientes sin `customer_type` (NULL) y con RNC sin normalizar.
- **Causa raíz**: `importProcess()` insertaba datos del CSV tal cual sin validación/normalización.
- **Fix**: Normalizar RNC + asignar `customer_type = 'empresa'` por defecto en `importProcess()`.
- **Archivos**: `modules/CRM/Controllers/CustomerController.php`.
- **Detalle**: [[../Bitacora/Sesiones/2026-06-20-bug-rnc-guiones]].
- **Deploy**: 2026-06-20 — confirmado resuelto en producción (Hostinger).

---

## Críticos (bloquean producción)

(ninguno abierto)

---

## Pendientes (no bloquean producción inmediata)

### BUG-002: NC/ND (E33/E34) — document_items / inflación ITBIS ✅ RESUELTO (2026-06-19)

- **Detectado**: 2026-06-18 · **Resuelto**: 2026-06-19
- **Síntoma original**: NC/ND sin `document_items` → línea sintética exenta.
- **Realidad**: el fix de ítems reales ya estaba (`insertNoteItem` +
  `noteItbisBreakdown` en `creditNoteStore`/`debitNoteStore`). Pero las notas
  legacy (0 items) caían en el fallback sintético de `EmitsEcf.php`, que
  inflaba `MontoTotal ×1.18` en notas gravadas (bruto como base + ITBIS
  recalculado) → descuadre y rechazo DGII.
- **Fix**: fallback sintético usa BASE sin ITBIS (`bruto/1.18` si gravada).
- **Detalle**: [[../Bitacora/Sesiones/2026-06-19-nc-nd-itbis]].
- **Pendiente**: probar NC/ND nuevo end-to-end contra CerteCF.

### BUG-007: `documents.ecf_status` desincronizado con `estado_dgii` ✅ RESUELTO (2026-06-20)

- **Detectado**: 2026-06-20 · **Resuelto**: 2026-06-20
- **Síntoma**: Al consultar estado DGII en endpoint `ecfStatus`, se actualizaba `estado_dgii`
  pero **no** `documents.ecf_status` → inconsistencia en reportes y QR.
- **Causa raíz**: `FacturacionController@ecfStatus` guardaba solo `estado_dgii`, dejando
  `ecf_status` sin cambios.
- **Fix**: sincronizar ambos campos en `ecfStatus` (ACCEPTED → ambos ACCEPTED, REJECTED → ambos REJECTED).
- **Archivos**: `modules/Facturacion/Controllers/FacturacionController.php`.
- **Detalle**: [[../Bitacora/Sesiones/2026-06-20-features-pago-dgii]].
- **Deploy**: 2026-06-20 — confirmado en producción (Hostinger).

### BUG-008: `settings.ecf_environment` = CERT accidental → error 1209 DGII ✅ RESUELTO (2026-06-20)

- **Detectado**: 2026-06-20 09:15 · **Resuelto**: 2026-06-20 09:45
- **Severidad**: CRÍTICA (bloquea todas las facturas E31)
- **Síntoma**: Todas las E31 devolvían error 1209 de DGII — "El RNC Emisor no tiene una postulación activa."
  QR mostraba "No fue encontrada la factura (e-CF)".
- **Causa raíz**: Columna `settings.ecf_environment` tenía valor `CERT` (CerteCF — ambiente de certificación cerrado)
  en lugar de `TEST` (TesteCF — sandbox activo). Probablemente alguien guardó la página de Configuración con
  el dropdown seleccionado en CERT durante las pruebas.
- **Fix principal**: `UPDATE settings SET ecf_environment = 'TEST' WHERE id = 1;` en Hostinger.
- **Mejoras de código**: 
  - `ecfStatus()` ahora ignora código 5000002 ("aún procesando") sin sobrescribir `estado_dgii` existente.
  - Auto-refresh delay aumentado de 3s a 10s (E31 son async, DGII tarda varios segundos).
- **Archivos**: `modules/Facturacion/Controllers/FacturacionController.php`.
- **Detalle**: [[../Bitacora/Sesiones/2026-06-20-ecf-ambiente-critico]].
- **Lección**: NUNCA tocar `settings.ecf_environment` sin confirmación explícita del usuario. Agregar aviso
  en dashboard si no es TEST.
- **Nota histórica**: E310000000072 quedó en CERTECF (secuencia no contabilizada); reenviar si usuario lo solicita.
