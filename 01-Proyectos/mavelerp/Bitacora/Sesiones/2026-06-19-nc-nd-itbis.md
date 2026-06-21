---
fecha: 2026-06-19
proyecto: mavelerp
autor: hector
tags: [sesion, facturacion-electronica, nc-nd, e33, e34, itbis, bugfix]
---

# Sesión 2026-06-19 — NC/ND: ítems reales + fix inflación ITBIS

## Objetivo

Cerrar el pendiente pre-producción de NC/ND (E33/E34): `document_items`
no se creaba → línea sintética exenta en el e-CF.

## Hallazgo 1 — el bug documentado YA estaba resuelto

`creditNoteStore()` y `debitNoteStore()` ya insertan un ítem real vía
`insertNoteItem()` con desglose base+ITBIS (`noteItbisBreakdown()`),
heredando gravado/exento de la factura referenciada. La nota del
`CLAUDE.md` quedó desactualizada. Producción == local (checksum).

## Hallazgo 2 — bug latente REAL (encontrado en datos de prod)

Consultando la BD de producción: **las 10 NC/ND existentes tienen 0
`document_items`** (legacy, anteriores al fix) → todas usan el **fallback
sintético** de `buildEcfDatosFromInvoice()` (en `EmitsEcf.php`).

Ese fallback usaba `documents.total` (monto BRUTO con ITBIS) como base
del ítem, y luego el motor recalcula ITBIS desde el ítem y lo suma →
`MontoTotal = bruto × 1.18`. Una ND gravada de RD$500 viajaba a la DGII
como **590**. Explica las 2 ND `Rechazado` (ND26-00006, ND26-00009) por
descuadre de monto. (El motivo exacto no quedó en `dgii_transmission_logs`.)

## Fix

En `EmitsEcf.php`, el fallback sintético ahora usa la **base sin ITBIS**
(`bruto/1.18` si gravada), igual que `insertNoteItem()`. Verificado
aritméticamente:

| Bruto | Gravada | Antes | Ahora |
|------:|:-------:|------:|------:|
| 500.00 | sí | 590.00 ✗ | 500.00 ✓ |
| 544.98 | sí | 643.08 ✗ | 544.98 ✓ |
| 300.00 | no | 300.00   | 300.00 ✓ |

La corrección de la rama exenta (forzar MontoExento/MontoTotal desde
`documents.total` cuando `gravado<=0`) ya existía y sigue intacta.

## Estado del flujo NC/ND (completo y correcto)

1. Creación de nota → ítem real con base+ITBIS (`insertNoteItem`).
2. `buildEcfDatosFromInvoice` lee ítems reales → totales correctos.
   Fallback sintético (legacy, 0 items) ya endurecido.
3. `InformacionReferencia` con `NCFModificado` + `CodigoModificacion='3'`
   (verificado contra aprobado Paso 2 `132114981E330000000001.xml`).

## Despliegue

- `EmitsEcf.php` → prod (checksum OK) + OPcache HTTP.
- `CLAUDE.md` (repo) actualizado: nota marcada RESUELTA + sincronizado a prod.

## Pendiente

- [ ] **Probar un NC/ND nuevo end-to-end contra CerteCF** (no se pudo
      desde acá sin generar datos en cert). Debe: (a) tener su
      `document_item` real, (b) cuadrar `MontoTotal`.
- [ ] (Opcional) Las notas legacy en prod (ids ≤196) tienen 0 items; al
      reenviarlas usan el fallback ya corregido.
- [ ] (Mejora) Notas con detalle multi-ítem real (hoy es 1 línea por
      monto único; el form captura `amount`, no ítems).

## Bloqueadores

Ninguno.
