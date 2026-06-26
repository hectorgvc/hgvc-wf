---
fecha: 2026-06-19
proyecto: mavelerp
autor: hector
tags: [sesion, facturacion-electronica, encf, secuencia, sellos, impresion]
---

# Sesión 2026-06-19 — cot→factura sin quemar secuencia, sellos, auto-print

## 1. Esquema cot → factura sin quemar secuencia ✅

**Problema:** al convertir cotización→factura se asignaba el e-NCF de
inmediato; si la factura se anulaba antes de enviar, el número quedaba
"quemado".

**Cambios** (`FacturacionController` + `ReportGenerator`):
- `convertToInvoice()` (ELECTRONIC): ya **no** llama `nextEcfFromRange()`.
  La factura DRAFT se crea con `encf/ncf/fecha_vencimiento = NULL`, solo
  guarda `tipo_ecf`. Tampoco crea asiento contable. (LEGACY sin cambios.)
- `approveInvoice()` ("Validar y Enviar"): si `encf` está vacío, asigna el
  e-NCF del rango **ahora**, persiste, firma/envía; al éxito crea el
  asiento (helper idempotente `createSalesAccountingIfAbsent`).
- 607 (`reportSale`): `AND d.ncf IS NOT NULL AND d.ncf != ''` para excluir
  borradores sin e-NCF.
- **Decisión (ADR):** asiento contable al ENVIAR, no al convertir.
- Anular un borrador no enviado ya **no consume secuencia** ni deja asiento.
- Las vistas ya mostraban "Sin asignar" / ocultaban el QR sin e-NCF → sin
  cambios de UI.

## 2. Tamaño del sello según forma ✅

- Nueva columna `settings.invoice_stamp_shape` ENUM('circular','rectangular')
  (migración 030, default circular).
- Selector circular/rectangular en Configuración (`settings/index.php`) +
  persistencia en `SettingsController`.
- Tamaños impresos: **circular 50mm** / **rectangular 47×18mm** (Shiny S-853).
  Aplicado en `print.php`, `print_simple.php`, `print_modern.php` con
  `max-width/max-height` en mm (conserva proporción); en `pdf.php` (dompdf)
  con `width` fija (47/50mm, alto auto).

## 3. Botón imprimir → Ctrl+P automático ✅

`print.php`, `quotations/print.php` y `credit_notes/print.php` ya
auto-disparaban `window.print()` al cargar. Faltaba en `print_simple.php`,
`print_modern.php` y `print_conduce.php` → se les agregó
`window.addEventListener('load', () => window.print())`. Ahora al abrir la
impresión sale el diálogo del navegador directamente.

## Despliegue

7 archivos + migración 030 a producción (checksums OK, OPcache limpiado).

## 4. QR "No fue encontrada" — NO era bug (desfase del portal)

El usuario probó una factura **nueva** (FAC26-00114, `E310000001003`): estado
local "Aceptado" pero al escanear el QR → "No fue encontrada la factura (e-CF)".

**Diagnóstico (todo verificado en vivo):**
- Todos los params del QR coinciden EXACTO con el XML firmado: FechaFirma
  `19-06-2026 21:49:19` = `<FechaHoraFirma>`; CodigoSeguridad `CMoHJH` =
  `SignatureValue[0:6]`; FechaEmision, MontoTotal, RncComprador (`131734154`, 9 díg).
- Consulté el portal ConsultaTimbre de **testecf** con esos params → devuelve
  **"MAVEL E TEC SYSTEM SRL · Aceptado"**. El QR **sí valida**.
- Causa: **desfase entre el "Aceptado" local y la indexación del portal DGII**.
  El QR se imprime apenas hay firma+código; si se escanea antes de que el portal
  indexe el e-CF, da "No fue encontrada" temporalmente. No es bug.
- Confirmado además que **TesteCF expone ConsultaTimbre** (no solo CerteCF).
- Documentado en `core-mavelerp.md` → sección QR, regla #6.

## 5. "Cliente MANA AUTO PARTS da error" — NO era el cliente (para probar mañana)

El usuario reportó que facturas con **MANA AUTO PARTS SRL** (recién agregado)
"daban error", mientras "algoritmo" y otra funcionaban.

**Verificado (en vivo):**
- RNC `131734154` de MANA es **real y ACTIVO** en el padrón DGII. Válido.
- Sus 2 facturas (`E310000001003`, `E310000001005`) están **Aceptadas** en DGII
  (checkStatus real). No hay rechazo.

**Causa del "error" percibido:**
- MANA es **E31** (lleva RNC comprador → DGII valida el RNC → procesamiento
  async más lento). "algoritmo" probablemente **E32 consumo** (RFCE síncrono →
  Aceptado instantáneo). Por eso MANA se queda "Procesando" más tiempo.
- El **estado local NO se auto-refresca**: FAC26-00116 sigue mostrando
  "Procesando" en local aunque DGII ya la aceptó. Hay que pulsar "Consultar
  estado". Y el QR da "No fue encontrada" si se escanea durante el "Procesando"
  (desfase del portal, regla #6 de core-mavelerp).

**Para mañana:**
- [ ] Confirmar el patrón E31 (async, tarda) vs E32 (síncrono) con clientes nuevos.
- [ ] **Mejora UX:** auto-refrescar el estado_dgii (polling o al abrir la factura)
      para que no quede "Procesando" colgado y confunda. Hoy exige clic manual.
- [ ] Verificar que el QR de FAC26-00116 valida una vez pasa a Aceptado.

## Pendiente de validar por el usuario (UI)

- [ ] Convertir cot→factura: debe decir e-NCF "Sin asignar"; anularla NO
      avanza la secuencia. Otra: "Validar y Enviar" asigna e-NCF y va a testecf.
- [ ] Configuración → elegir forma del sello, subir cuño, imprimir y verificar
      tamaño físico (50mm / 47×18mm).
- [ ] Imprimir cualquier doc → debe salir el diálogo de impresión solo.
