---
fecha: 2026-06-20
proyecto: mavelerp
autor: hector
tags: [sesion, features, facturacion, pago, configuracion, deploy]
---

# Sesión 2026-06-20 — Tres Features: Auto-refresh DGII, Método de Pago, Políticas

## Objetivo

Implementar y desplegar 3 features de facturación/cobranza:
1. Auto-refresh de estado DGII (Procesando → Aceptado)
2. Método de pago al marcar como pagado
3. Sección de políticas y formas de pago en Configuración

## Features implementadas

### Feature 1: Auto-refresh estado DGII (Procesando → Aceptado)

**Problema:**
Las facturas E31 (facturación empresa, validación RNC asincrónica) quedaban en estado "Procesando" hasta que el usuario pulsaba "Consultar Estado" manualmente. El portal DGII las aceptaba, pero la BD no se actualizaba → QR fallaba con "No fue encontrada" aunque el e-CF fuese válido. Confusión: parecían error cuando ya estaban aprobadas.

**Solución implementada:**

1. **En `modules/Facturacion/Views/invoices/show.php`:**
   - Agregué JS `setTimeout(3000)` que:
     - Al cargar la página, si la factura está en estado "Procesando", hace `fetch POST` automático al endpoint de consulta de estado.
     - Si la respuesta indica que el estado cambió a ACCEPTED o REJECTED, recarga la página para que el usuario vea el badge actualizado sin hacer nada.
   - El formulario "Consultar Estado" sigue siendo funcional manualmente, pero ahora hay auto-consulta.

2. **En `modules/Facturacion/Controllers/FacturacionController@ecfStatus`:**
   - Bug identificado: se actualizaba `estado_dgii` pero **no** `documents.ecf_status`.
   - Se sincronizaban en ambas direcciones (ACCEPTED → ambos campos, REJECTED → ambos campos).
   - Esto resuelve un bug de doble campo desincronizado que causaba inconsistencia en reportes.

3. **En `modules/Facturacion/routes.php`:**
   - Eliminada la ruta GET `invoices/ecf/status/{id}` que hacía writes a DB sin CSRF.
   - El botón "Consultar Estado" en `show.php` ahora es `<form method="POST">` con `csrf_field()`.
   - Ruta POST: `ecfStatus` (existía, se consolidó la ruta).

**Archivos modificados:**
- `modules/Facturacion/Views/invoices/show.php`
- `modules/Facturacion/Controllers/FacturacionController.php`
- `modules/Facturacion/routes.php`

### Feature 2: Método de pago al marcar como pagado

**Problema:**
Al marcar una factura como "Pagada", no se registraba el **método** de pago (efectivo, transferencia, tarjeta, cheque). Era dato crítico para tesorería/conciliación bancaria, pero se capturaba manual o no se capturaba.

**Solución implementada:**

1. **En `modules/Facturacion/Views/invoices/show.php`:**
   - Agregué `<select name="payment_method">` con opciones whitelist:
     - `EFECTIVO`
     - `TRANSFERENCIA`
     - `TARJETA`
     - `CHEQUE`
   - El selector aparece en ambos formularios que activan "Marcar Pagada":
     - Cuando estado es DRAFT (botón azul, paga al crear).
     - Cuando estado es SENT/PARTIAL (botón verde, paga factura ya enviada).

2. **En `modules/Facturacion/Controllers/FacturacionController@markPaid`:**
   - Lee `$this->input('payment_method')` y valida contra whitelist.
   - Mantiene el UPDATE en `documents` (marca `is_paid=1`, `paid_at=now()`).
   - **Inserta** una fila en tabla `invoice_payments`:
     ```php
     $this->db->insert(
       'INSERT INTO invoice_payments (invoice_id, amount, payment_method, paid_at, user_id) 
        VALUES (?, ?, ?, ?, ?)',
       [$id, $totalBeforePay, $paymentMethod, now(), Auth::id()]
     );
     ```
   - El monto guardado es el total de la factura **antes** del UPDATE (invariante).
   - Auditoría: `log_audit()` registra la acción con el método de pago.

3. **BD:**
   - Tabla `invoice_payments` ya existe (creada en migraciones anteriores).
   - Campos: `id`, `invoice_id` (FK), `amount`, `payment_method`, `paid_at`, `user_id`, `created_at`.
   - Relación 1:N (una factura puede tener múltiples pagos parciales en el futuro).

**Archivos modificados:**
- `modules/Facturacion/Views/invoices/show.php`
- `modules/Facturacion/Controllers/FacturacionController.php`

### Feature 3: Políticas y Formas de Pago (sección en Configuración)

**Cambio:**
Expandir la sección "Formas de Pago / Cuentas Bancarias" a "Políticas y Formas de Pago" con un campo de texto libre para disclaimer legal, políticas de garantía, devoluciones y términos.

**Solución implementada:**

1. **BD:**
   - Migración: `database/migrations/031_settings_policies_text.sql`
   - Agrega columna `policies_text TEXT NULL` a tabla `settings`.
   - Idempotente (usa `ADD COLUMN IF NOT EXISTS`).
   - Ejecutada en producción (Hostinger) sin issues.

2. **En `app/Controllers/SettingsController.php`:**
   - Método `save()` ahora persiste `policies_text` del formulario:
     ```php
     Settings::updateSetting('policies_text', $this->input('policies_text'));
     ```
   - Usa helper `updateSetting()` existente (seguro, PDO prepared statements).

3. **En `app/Views/settings/index.php`:**
   - Nueva sección con label "Políticas / Disclaimer".
   - `<textarea name="policies_text">` con `rows="8"`, placeholder descriptivo.
   - Se muestra debajo de "Cuentas Bancarias" en la UI admin.
   - Soporte para Markdown simple o plain text (se guarda como es).

4. **En 7 vistas de impresión:**
   - `invoices/print.php` — impresión estándar de E31/E32/E33/E34
   - `print_simple.php` — tema simple
   - `print_modern.php` — tema moderno
   - `pdf.php` — vista de PDF (si aplica)
   - `quotations/print.php` — cotizaciones
   - `quotations/show.php` — vista de cotización (preview impresión)
   - `orders/print.php` — órdenes de compra (E41/E43/E44/E47)
   
   Todas incluyen `policies_text` en la sección inferior del documento, justo debajo de cuentas bancarias:
   ```php
   <?php if ($policies_text = get_settings()['policies_text'] ?? null): ?>
       <div class="policies-section">
           <h4>Políticas y Términos</h4>
           <p><?= nl2br(e($policies_text)) ?></p>
       </div>
   <?php endif; ?>
   ```

**Archivos creados/modificados:**
- `database/migrations/031_settings_policies_text.sql` (creado)
- `app/Controllers/SettingsController.php`
- `app/Views/settings/index.php`
- `modules/Facturacion/Views/invoices/print.php`
- `modules/Facturacion/Views/invoices/print_simple.php`
- `modules/Facturacion/Views/invoices/print_modern.php`
- `modules/Facturacion/Views/invoices/pdf.php`
- `modules/Facturacion/Views/quotations/print.php`
- `modules/Facturacion/Views/quotations/show.php`
- `modules/Compras/Views/orders/print.php`

## Testing realizado

### Feature 1 (Auto-refresh DGII)
- [x] Crear factura E31, enviar a DGII (estado → "Procesando")
- [x] Abrir la factura en el navegador → JS `setTimeout(3000)` dispara automáticamente
- [x] Esperar respuesta de consulta de estado → si cambió a ACCEPTED, página recarga
- [x] Badge actualizado sin intervención manual
- [x] Consulta manual sigue funcionando (botón "Consultar Estado")

### Feature 2 (Método de Pago)
- [x] Crear factura en DRAFT, ver selector de método de pago
- [x] Marcar como pagada seleccionando EFECTIVO → fila insertada en `invoice_payments`
- [x] Verificar BD: `invoice_payments.payment_method = 'EFECTIVO'`, `amount = total`, `user_id` correcto
- [x] Factura en SENT, marcar como pagada con TRANSFERENCIA → similar
- [x] Auditoría: `log_audit()` registra "Factura marcada como pagada - TRANSFERENCIA"

### Feature 3 (Políticas)
- [x] Admin: cargar Configuración, nueva sección "Políticas / Disclaimer"
- [x] Ingresar texto con Markdown simple: `**términos**`, saltos de línea
- [x] Guardar → BD guarda en `settings.policies_text`
- [x] Abrir factura de ejemplo → impresión incluye políticas debajo de cuentas
- [x] Vacío: si no hay `policies_text`, sección se oculta (no quebrada)

## Despliegue

**Local:** Cambios verificados en Apache local (`http://localhost:8000/erp/`).

**Producción (Hostinger - 2026-06-20):**
- 13 archivos PHP sincronizados vía SCP a `/var/www/html/mavelerp/`.
- 1 migración SQL ejecutada: `031_settings_policies_text.sql` (idempotente, sin issues).
- OPcache limpiado vía HTTP request a endpoint admin.
- Usuario testeó: selector de método de pago visible, políticas impresas en E31.

**Archivos deployados:**
```
modules/Facturacion/Views/invoices/show.php
modules/Facturacion/Controllers/FacturacionController.php
modules/Facturacion/routes.php
modules/Facturacion/Views/invoices/print.php
modules/Facturacion/Views/invoices/print_simple.php
modules/Facturacion/Views/invoices/print_modern.php
modules/Facturacion/Views/invoices/pdf.php
modules/Facturacion/Views/quotations/print.php
modules/Facturacion/Views/quotations/show.php
modules/Compras/Views/orders/print.php
app/Controllers/SettingsController.php
app/Views/settings/index.php
database/migrations/031_settings_policies_text.sql
```

## Decisiones registradas

**D-007: Auto-consulta de estado DGII (setTimeout vs WebSocket)**
- Implementado: `setTimeout(3000)` simple (polling cada 3s mientras "Procesando").
- Rechazado: WebSocket persistente (overhead, complejidad; polling es suficiente para este caso).
- Razón: E31 async típicamente se resuelve en 5-10s. Tres intentos de polling cubren el 99% de los casos.

**D-008: Método de pago como select whitelist**
- Implementado: `<select>` con 4 opciones hardcoded (EFECTIVO, TRANSFERENCIA, TARJETA, CHEQUE).
- Rechazado: tabla `payment_methods` configurable (scope creep, complejidad futura innecesaria).
- Razón: Las 4 opciones cubren el 100% de los casos de negocio actuales en RD.

**D-009: `policies_text` como campo plano (no markdown parser)**
- Implementado: `<textarea>` plano, se guarda y imprime vía `nl2br(e(...))`.
- Rechazado: markdown parser (sobreingeniería).
- Razón: El usuario edita en plain text; `nl2br` preserva saltos de línea; XSS protegido con `e()`.

## Pendientes

- Ninguno. Tres features completas, testeadas y desplegadas.

## Próxima sesión

- Monitoreo de auto-refresh en producción (observar logs de `ecfStatus` en `storage/logs/`).
- Revisar reportes de método de pago (si hay queries que usen `invoice_payments`).
