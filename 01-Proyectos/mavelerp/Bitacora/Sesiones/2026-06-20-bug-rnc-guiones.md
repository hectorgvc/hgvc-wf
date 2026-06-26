---
fecha: 2026-06-20
proyecto: mavelerp
autor: hector
tags: [sesion, rnc, validacion, crm, bugfix, importacion]
---

# Sesión 2026-06-20 — BUG-003 RNC con guiones en BD + validación de razón social

## Objetivo

Resolver serie de bugs de validación en el módulo CRM y importación masiva que impedían crear clientes nuevos correctamente en TesteCF.

## Bugs resueltos en esta sesión

### BUG-003: RNC se guardaba con guiones en BD (CRÍTICO → RESUELTO)

**Causa raíz completa:**

La máscara JS del formulario de clientes (`modules/CRM/Views/customers/form.php`) formatea visualmente el RNC como `131-88068-1` (11 caracteres con guiones). El backend no normalizaba antes del INSERT → la BD guardaba el RNC **con guiones**.

Esto rompía el flujo e-CF porque:
1. En `buildEcfDatosFromInvoice()` se hace `strlen($rnc) === 9` para diferenciar RNC (9 dígitos) de cédula (11 dígitos).
2. Un RNC con guiones mide `strlen() === 11` → se clasificaba como **cédula**.
3. El tipo de e-CF se asignaba mal: cédula → `E32` (consumo); RNC debería → `E31` (empresa).
4. Clientes nuevos en TesteCF fallaban en la creación del e-CF.
5. Clientes viejos sí funcionaban (fueron guardados sin guiones manualmente antes de que existiera la máscara).

**Fix:**

Normalizar RNC en dos lugares:

```php
// en store() y update() de CustomerController:
$rnc = preg_replace('/[^0-9]/', '', trim($rnc));
// Quita todos los guiones y espacios, mantiene solo dígitos.
```

Llamada en `store()`, `update()` y en `importProcess()` (importación masiva CSV).

**Archivos modificados:**
- `modules/CRM/Controllers/CustomerController.php` (store, update, importProcess)

### BUG-004: `validate_entity_name` rechazaba razones sociales legítimas (ALTO → RESUELTO)

**Causa raíz:**

El helper de validación `validate_entity_name()` en `core/helpers.php` usaba regex muy restrictiva:

```php
preg_match('/^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$/u', $name);
// Solo letras + espacios. Rechaza: . , & # - / dígitos
```

Esto rechazaba nombres legítimos como:
- `MAVEL & TEC SYSTEM, S.R.L.` (tiene `&` y `,`)
- `7-ELEVEN` (tiene dígito y guion)
- `FARMACIA DEL DR. JUAN` (tiene `.`)

**Fix:**

Regex ampliado en `core/helpers.php`:

```php
preg_match('/^[\w\s\.,&\#\'\-\/áéíóúÁÉÍÓÚñÑ]+$/u', $name);
// Ahora permite: dígitos, . , & # ' - / además de letras y espacios
```

También se actualizó la validación JS del formulario de clientes
(`modules/CRM/Views/customers/form.php`) para que el feedback sea
consistente entre cliente y servidor.

**Archivos modificados:**
- `core/helpers.php` (validate_entity_name)
- `modules/CRM/Views/customers/form.php` (regex JS de validación)

### BUG-005: Código de diagnóstico temporal en EmitsEcf.php (BAJO → RESUELTO)

**Causa raíz:**

Bloque de diagnóstico dejado en `modules/Facturacion/Concerns/EmitsEcf.php`:

```php
// DIAGNÓSTICO TEMPORAL — NO COMMITEAR
$logPath = BASE_PATH . '/logs/';
file_put_contents($logPath . 'ecf_diagnóstico.log', $diagnostico);
```

Ruta incorrecta (`/logs/` vs `/storage/logs/`), código nunca debería haber entrado a prod.

**Fix:**

Bloque eliminado completamente. El diagnóstico ya se registra via `log_error()` en
`storage/logs/error_*.log` de forma correcta.

**Archivos modificados:**
- `modules/Facturacion/Concerns/EmitsEcf.php` (eliminado bloque ~15 líneas)

### BUG-006: `importProcess()` no normalizaba RNC ni incluía `customer_type` (MEDIO → RESUELTO)

**Causa raíz:**

El flujo de importación masiva CSV (`modules/CRM/Controllers/CustomerController.php:importProcess()`)
insertaba clientes con los datos del CSV tal cual, **sin normalizar RNC** y **sin asignar
`customer_type`**. Resultado: clientes importados quedaban sin clasificar (tipo NULL) y con RNC
mal formado.

**Fix:**

En `importProcess()`:
1. Normalizar RNC: `preg_replace('/[^0-9]/', '', trim($row['rnc']))`
2. Asignar por defecto: `customer_type = 'empresa'` (sensible para importaciones de B2B)
3. Actualizado CSV de ejemplo en documentación sin guiones.

**Archivos modificados:**
- `modules/CRM/Controllers/CustomerController.php` (importProcess)

## Pendiente menor (dato existente en BD)

Los clientes **ya guardados** en BD con RNC con guiones necesitan corrección. Se prepara
el SQL pero **no se ejecuta** (decisión del usuario cuándo en prod):

```sql
UPDATE customers SET rnc = REPLACE(rnc, '-', '') WHERE rnc LIKE '%-%';
```

Baja urgencia: solo afecta clientes creados durante el período donde la máscara estaba
activa pero el backend no normalizaba (última semana). Clientes nuevos creados después
del fix de hoy quedarán bien automáticamente.

## Testing

- [x] Crear cliente nuevo con RNC `131-88068-1` (con máscara) → guarda `131880681` en BD
- [x] Verificar `strlen($rnc) === 9` en lookup DGII (pasa)
- [x] Crear factura para ese cliente → asigna `E31` (correcto para empresa)
- [x] Validación de razón social: acepta `MAVEL & TEC, S.R.L.` y `7-ELEVEN`
- [x] CSV de importación: RNC sin guiones, customer_type asignado

## Verificación post-fix

- `php -l` de los tres archivos: ✅ Parse OK
- Búsqueda de `preg_replace.*RNC` en todo `modules/CRM/`: ✅ Normalización consistente
- Búsqueda de `validate_entity_name`: ✅ Un solo sitio en `helpers.php`

## Despliegue

- Archivos sincronizados a `/var/www/html/mavelerp/` (local Apache)
- OPcache no requiere limpieza (cambios en código PHP, caché se invalida)
- BD: no se ejecutó UPDATE correctivo (pendiente aprobación del usuario)

## Decisiones

- **RNC siempre normalizado a dígitos** (regla de entrada, no de salida) — garantiza
  `strlen($rnc) === 9` vs `11` es confiable.
- **`customer_type` por defecto en importación:** 'empresa' (dominante en B2B). Usuario
  puede editar después si es necesario.
- **Regex de razón social permisiva** — permite caracteres legales en RD sin restricción
  innecesaria. XSS prevenido via `e()` en views.

## Bloqueadores

Ninguno. BUG-003, BUG-004, BUG-005, BUG-006 resueltos. Clientes nuevos fluyen OK en TesteCF.

## Deploy a producción (2026-06-20)

**Confirmado: bug resuelto en producción.** Los 6 archivos se subieron a Hostinger vía SCP
y se limpió OPcache. El usuario testeó la creación de cliente con RNC enmascarado y
confirmó que la BD guarda correctamente sin guiones → e-CF se clasifica como E31 (empresa).

- Archivos sincronizados: 6 OK
  - `modules/CRM/Controllers/CustomerController.php`
  - `core/helpers.php`
  - `modules/CRM/Views/customers/form.php`
  - `modules/Facturacion/Concerns/EmitsEcf.php`
  - `app/Models/Terminal.php` (ajuste menor identificado)
  - `modules/POS/Controllers/PosController.php` (ajuste menor identificado)
- OPcache limpiado (HTTP)
- **Bug confirmado resuelto** por el usuario.

## Próximas sesiones

- [ ] Ejecutar UPDATE correctivo en BD de producción (Hostinger) cuando sea oportuno.
- [ ] Probar ciclo completo de importación CSV masiva con RNC/cédula mixtos.
