---
tipo: backlog
creado: 2026-06-18
estado: activo
tags: [pendientes, backlog]
proyecto: mavelerp
---

# Tareas pendientes — mavelerp

> Backlog vivo. Agregar fecha de captura al lado de cada punto cuando
> se levante. Marcar con `[x]` al cerrar y mover el detalle a una ADR
> o a Bugs/ si corresponde.

## Mantenimiento BD y datos

- [x] **UPDATE correctivo RNC en producción** — ✅ 2026-06-20. Clientes
      históricos normalizados (3 clientes actualizados). Ver detalle en
      [[Bitacora/Sesiones/2026-06-20-bug-rnc-guiones]].

## Facturación electrónica DGII

- [x] **API Rest de DGII para RNC** — ✅ 2026-06-19. Lookup en vivo del
      padrón DGII vía API MegaPlus (`rnc.megaplus.com.do/api/consulta`).
      Auto-rellena razón social + tipo de cliente al completar RNC/cédula
      en el form de clientes. Detalle en
      [[Bitacora/Sesiones/2026-06-19-rnc-lookup]] y ADR-0006.
      **Pendiente menor:** replicar el mismo lookup en el form de
      proveedores y, si se quiere, en alta rápida de cliente desde factura.
- [x] **Esquema cot → factura sin quemar secuencia** — ✅ 2026-06-19.
      `convertToInvoice` ya no asigna e-NCF (encf NULL); se asigna en
      `approveInvoice` al "Validar y Enviar". Anular un borrador no
      consume secuencia. Detalle en
      [[Bitacora/Sesiones/2026-06-19-cotfactura-sellos-print]].
- [x] **Reportes y contabilidad alineados al nuevo esquema** — ✅ 2026-06-19.
      607 excluye borradores sin e-NCF (`ncf IS NOT NULL`). Asiento
      contable se crea al **enviar** (no al convertir), idempotente.
- [x] **Tamaño del sello** — ✅ 2026-06-19. Setting `invoice_stamp_shape`
      (circular 50mm / rectangular 47×18mm) + selector en Configuración;
      aplicado a las 4 vistas de impresión.
- [x] **Imprimir abre Ctrl+P solo** — ✅ 2026-06-19. Auto `window.print()`
      agregado a print_simple/modern/conduce (las otras ya lo tenían).
- [x] **Auto-refrescar estado_dgii (Procesando → Aceptado)** — ✅ 2026-06-20.
      JS `setTimeout(3000)` al cargar factura en "Procesando"; `fetch POST`
      auto al endpoint de consulta de estado. Si cambió a ACCEPTED/REJECTED,
      recarga la página. Sincroniza `documents.ecf_status`. Detalle en
      [[Bitacora/Sesiones/2026-06-20-features-pago-dgii]].

## POS / Cobros

- [x] **Rediseño visual POS terminal** — ✅ 2026-06-20. Layout dos columnas,
      búsqueda con Lucide, cards con avatar inicial, total destacado en color
      primario, modales animados. JS preservado íntegro. Ver
      [[Bitacora/Sesiones/2026-06-20-importaciones-pos-fix]].

- [x] **Método de pago al marcar como pagado** — ✅ 2026-06-20.
      `<select name="payment_method">` en ambos formularios de "Marcar Pagada".
      Inserta fila en `invoice_payments` con método, monto, fecha y user_id.
      Detalle en [[Bitacora/Sesiones/2026-06-20-features-pago-dgii]].
- [ ] **POS con Veryphone / pasarela de tarjeta** — Cuando llegue la
      documentación oficial de Carnet, integrar pago con tarjeta
      Veryphone: referencia de voucher + pasarela vía API de la
      pasarela. **Dos modos coexistiendo**:
  1. Manual (capturar voucher a mano, sin auto-factura).
  2. Integrado (procesar → generar factura + imprimir automático).
- [ ] **Estilo del POS** — Mejora visual del POS una vez cerrado el
      flujo de pagos.

## Branding / QA UI (sesión 2026-06-21)

- [x] **Login dinámico: logo + tagline** — ✅ 2026-06-21. Vista de login
      usa `sidebar_logo_path` como `<img>` (fallback al texto `app_name`).
      Campo `app_tagline` nuevo y editable en Configuración (SUPER_ADMIN);
      se muestra como subtítulo opcional. Migración 035: columna
      `app_tagline VARCHAR(200)` en `settings`. Bug corregido: faltaba
      la migración → "Error del Sistema" al guardar Settings.

- [x] **Ítem activo del sidebar usa color de marca** — ✅ 2026-06-21.
      `.nav-group-items a.active` ahora usa `var(--primary)` inyectado
      en `<head>` (mismo patrón que Tarea 4.1). Ya responde al color
      configurado en Settings.

- [x] **Factura impresa: CANT. sin .00 + Forma de Pago ancho completo**
      — ✅ 2026-06-21. `rtrim(rtrim(number_format(...,2),'0'),'.')` para
      mostrar "1" en vez de "1.00". Bloque Forma de Pago con `flex:1`.
      Aplicado en `print.php`, `print_simple.php`, `print_modern.php`.

- [x] **Color secundario de marca configurable** — ✅ 2026-06-21.
      Nueva columna `brand_color_secondary` (migración 033, default
      `#64748b`). Variable CSS `--color-secondary` inyectada en `<head>`.
      Color picker en Configuración con preview en tiempo real.
      Aplicado en: badges e-CF en índice de facturas, badge "Desc.%"
      en POS terminal.

- [x] **Bloqueo de apertura de caja si sin cierre previo (POS)**
      — ✅ 2026-06-21. Si existe sesión de caja abierta de un día
      anterior, se bloquea la apertura y se registra en `caja_bloqueos`.
      Desbloqueo mediante TOTP del SUPER_ADMIN. Vista de auditoría en
      `/pos/register-locks`. Migración 034: `forced_close` en
      `pos_cash_sessions` + tabla `caja_bloqueos`.

## API Rest global

- [x] **API Rest en todo el ERP** — ✅ 2026-06-21. 7 endpoints REST
      autenticados con Bearer token en `/api/v1/`. Ver sección Inventario.

## Integraciones

- [ ] **Evaluar CRM Plus (Twenty + Salesforce)** — Levantar POC de
      Twenty (open-source Airtable-like) y comparar con Salesforce
      como candidato para el módulo CRM Plus. Decisión antes de
      construir.

## Ambiente y deploy

- [x] **Arreglar ambiente test** — ✅ 2026-06-19. Causa: la postulación
      de **CerteCF** se cerró al completar la certificación → DGII
      rechazaba todo con código 1209. Solución: cambiar a **TesteCF**
      (sandbox permanente) + sembrar rangos `ncf_sequences ambiente=test`
      (base 1000). Validado con envío E31 **Aceptado**. Detalle en
      [[Bitacora/Sesiones/2026-06-19-ambiente-test]].
  - Pendiente: al activar producción → sembrar rangos `ambiente=prod` y
    `ecf_environment=PROD`. Mejora: UI admin para ambiente + rangos NCF.

## Admin

- [x] **Sección de disclaimer / políticas de empresa** — ✅ 2026-06-20.
      Reformulada como "Políticas y Formas de Pago" en Configuración. Campo
      `settings.policies_text` para disclaimer/términos; impreso en 7 vistas
      de impresión. Detalle en [[Bitacora/Sesiones/2026-06-20-features-pago-dgii]].

## Seguridad

- [x] **2FA da error** — ✅ 2026-06-19. Fix: `QrHelper` sin namespace
      requerí anteponer `\` en la llamada (`\QrHelper::imgTagFromUrl()`).
      Detalle en [[Bitacora/Sesiones/2026-06-19-fix-2fa]] y [[Bugs/Bugs#BUG-001]].

## Importación masiva

- [x] **Importación de productos y clientes con clave única + modo de
      resolución** — ✅ 2026-06-20. Upsert por RNC (clientes/proveedores)
      o SKU (productos). Modos: `insertar_nuevos` (default) u
      `actualizar_existentes`. Flash al terminar con recuento
      (creados/actualizados/omitidos). Fix RNC normalización en
      proveedores (guiones removidos). Detalle en
      [[Bitacora/Sesiones/2026-06-20-importacion-masiva]].

- [x] **Importaciones — validación y robustez** — ✅ 2026-06-20.
  - [x] Validación de plantilla: cabeceras del archivo comparadas contra
        las esperadas; se aborta si no coinciden. ✅
  - [x] Whitelist de extensiones (csv/xlsx), límite 5 MB, check fopen(). ✅
  - [x] `customer_type` inferido del RNC (11 dígitos → persona_fisica). ✅
  - [x] `is_taxable` en template e INSERT de productos (`es_gravado`). ✅
  - [x] Selector modo insertar/actualizar en modal de products/index. ✅
  - [x] **Paginado** — ✅ 2026-06-20. 20 por página en productos, clientes y proveedores. Filtro por búsqueda respetado.
  - [x] **Categorías de productos** — ✅ 2026-06-20. Columna `category` (migración 033), filtro en listado, campo en form, soporte en importación/exportación.
  - [x] **Campos dinámicos (solo SUPER_ADMIN)** — ✅ 2026-06-20. `CustomFieldsController` + `custom_fields` (migración 034). ALTER TABLE con whitelist de tipos y prefijo `cf_`. Link en menú solo para SUPER_ADMIN.
  - [x] **Exportar CSV** — ✅ 2026-06-20. Botón Exportar en productos, clientes y proveedores. Respeta filtros activos, BOM UTF-8.
  Detalle en [[Bitacora/Sesiones/2026-06-20-importaciones-pos-fix]].

## Exportación de datos

- [x] **Botón Exportar en listados** — ✅ 2026-06-20. CSV con BOM UTF-8 en
      productos, clientes y proveedores. Respeta filtros activos (búsqueda +
      categoría). Ver [[Bitacora/Sesiones/2026-06-20-importaciones-pos-fix]].

## Inventario

- [x] **Dashboard de Almacén** — ✅ 2026-06-20. Panel de estadísticas en módulo
      Inventario (ruta `/inventario/dashboard`). KPIs (total productos, unidades,
      sin stock, valor total, stock bajo), gráficos Chart.js por categoría / top 10
      vendidos / entradas-salidas 6 meses, tablas alertas stock bajo y sin movimiento
      30 días. Migración 031: columna `category` en products. Detalle en
      [[Bitacora/Sesiones/2026-06-20-dashboard-api-rest]].

- [x] **API Rest global** — ✅ 2026-06-20. 7 endpoints REST autenticados con Bearer
      token (`/api/v1/products`, `customers`, `invoices`, `payments`). Gestión de
      tokens en `/api-tokens` (crear/revocar, solo ADMIN). Rate limiting (60 req/min)
      cableado por primera vez a la API. Documentación interactiva HTML en
      `/public/api-docs.html` (Try-it-out, dark mode). Migración 032: `api_tokens`.
      **Hallazgo:** `RateLimitMiddleware` nunca había sido cableado en ninguna ruta
      pese a estar documentado como activo — corregido ahora. Detalle en
      [[Bitacora/Sesiones/2026-06-20-dashboard-api-rest]].

- [x] **📱 Responsive / móvil de toda la plataforma** — ✅ Implementado
      (fecha exacta pendiente de confirmar). Pendiente: hacer un barrido de
      revisión para verificar que no quedó nada mal o que se pueda mejorar.
      Dashboard, tablas, sidebar, POS, formularios, facturas/RI.

- [x] **Botón de impresión lateral en factura (show.php)** — ✅ Corregido.
      El panel lateral sticky y el botón del footer ya usan el mismo flujo.

- [ ] **Mejora seguridad: hashear tokens API en BD** — Tokens almacenados
      en texto plano (entropía alta, acceso controlado). Mejora futura:
      hashear con `password_hash()` + lookup por prefix (8 chars) +
      `hash_equals()`. Requiere rediseño de la tabla `api_tokens`.

- [ ] **Scopes en tokens API** — Capturado 2026-06-21. Hoy todos los
      tokens tienen acceso completo a los 4 endpoints (`/products`,
      `/customers`, `/invoices`, `/payments`). Se necesita control por
      scope (ej. `read:products`, `read:invoices`) para poder otorgar
      acceso mínimo necesario a cada integración. Diseñar junto con el
      punto de hasheo (afecta la misma tabla `api_tokens`).

- [ ] **RateLimitMiddleware global** — Solo cableado en rutas `/api/v1/`.
      El resto del ERP (incluyendo `/login`) lo tiene en código pero nunca
      conectado a las rutas. Agendar hardening global.

## Módulos futuros

- [ ] **Módulo Reparaciones** (talleres técnicos) — Ver concepto completo
      en [[Arquitectura/Modulo-Reparaciones-Concepto.md]]. Resumen:
  - Tickets de reparación con cliente, dispositivo (IMEI/SKU), problema,
    técnico asignado y estado (New → In Progress → Waiting Parts →
    Finished / Cancel).
  - CRM se extiende: submenú "Reparaciones" con vista de dispositivos y
    tickets por cliente.
  - Se conecta con **Inventario** (repuestos) y **Facturacion** (genera
    factura al cerrar el ticket).
  - Flujo de 6 pasos para crear ticket (cliente → dispositivo → problema
    → servicios/repuestos → detalles opcionales → notificaciones).
  - BD nueva: `repair_devices`, `repair_problems`, `repair_tickets`,
    `repair_ticket_items`.
