---
fecha: 2026-06-19
proyecto: mavelerp
autor: hector
tags: [sesion, crm, dgii, rnc, api, despliegue]
---

# Sesión 2026-06-19 — Lookup de RNC contra padrón DGII

## Objetivo

Consultar/validar el RNC o cédula de un cliente contra la DGII al darlo
de alta, autocompletando sus datos para no escribirlos a mano.

## Qué se hizo

### Backend
- Nuevo método `CustomerController::rncLookup()` + ruta
  `GET api/rnc-lookup` (con `AuthMiddleware`).
- Consulta la API pública de **MegaPlus**
  (`https://rnc.megaplus.com.do/api/consulta?rnc={rnc}`) vía cURL.
- Acepta RNC (9 díg.) y cédula (11 díg.). Normaliza la respuesta a
  `{rnc, nombre (razón social), nombre_comercial, estado, actividad}`.

### Frontend (`modules/CRM/Views/customers/form.php`)
- Botón "Verificar RNC" + `<small>` de resultado junto al campo.
- **Auto-consulta** al completar el documento (9/11 díg.) — sin clickear.
- **Auto-rellena** el campo Nombre con la razón social oficial y setea
  el tipo de cliente (empresa/persona_física) automáticamente.
- Campo RNC: bloquea teclas no numéricas y limita a 11 dígitos; formatea
  con guiones solo visualmente.

### Despliegue
- Subido por SCP a `/public_html/` (producción) en
  `mavelerp.e-tecsystem.com` + limpieza de OPcache vía HTTP.

## Decisiones tomadas

- ADR-0006 (ver [[../Decisiones/Decisiones]]): usar API MegaPlus como
  fuente del padrón DGII.

## Bugs encontrados y resueltos en el camino

1. **Endpoint DGII muerto** — El primer intento usó
   `api.digital.gob.do/v3/contribuyentes/{rnc}` (404, retirado). El web
   service oficial `dgii.gov.do/wsMovilDGII` redirige 301 (roto desde
   ene-2025). Solución: API MegaPlus (la pasó el usuario; verificada en
   vivo desde local y desde el servidor). El dataset oficial ZIP de la
   DGII (20MB) queda como plan B si MegaPlus falla.
2. **🔑 Bug de despliegue (clave para futuro):** subí 4 archivos a
   `/public_html/dev/` (carpeta de backup) en vez de `/public_html/`
   (sitio real). El sitio en producción sirve desde `/public_html/`
   directamente, **no** desde `/dev/`. Ver
   [[../Arquitectura/Despliegue-Hostinger]].
3. **🔑 Bug del `<script>` descartado (causa raíz real del "botón sin
   eventos"):** en este framework, `View::module()` solo conserva lo que
   está **dentro** de `startSection('content')`. El `<script>` estaba
   **después** de `endSection()` → se descartaba y nunca llegaba al HTML.
   El layout `app/Views/layouts/main.php` solo renderiza
   `section('content')`, no hay sección `scripts`. **Regla:** todo
   `<script>` de una vista de módulo va **dentro** de la sección
   `content`, antes de `endSection()` (igual que `quotations/create.php`).
4. **OPcache:** `php -r 'opcache_reset()'` por SSH (CLI) **no** limpia el
   OPcache de PHP-FPM (web). Hay que llamar
   `https://mavelerp.e-tecsystem.com/opcache_clear.php` vía HTTP.

## Hallazgo sobre la API

La API **no** devuelve dirección ni teléfono — el padrón público DGII
solo expone: razón social, nombre comercial, estado, régimen de pagos,
actividad económica, administración local, facturador electrónico.
→ Dirección y teléfono siguen siendo manuales (no hay fuente).

## Pendientes

- [ ] Replicar el lookup en el form de **proveedores**
      (`SupplierController` + `suppliers/form.php`).
- [ ] Evaluar alta rápida de cliente desde la pantalla de factura con el
      mismo lookup.
- [ ] Cachear localmente respuestas DGII (tabla `dgii_rnc_cache`) para no
      depender 100% de MegaPlus en cada alta (opcional).

## Bloqueadores

Ninguno.

## Próxima sesión

Lo que indique el usuario. Candidatos del backlog: 2FA (crítico),
NC/ND items reales, esquema cot→factura sin quemar secuencia.
