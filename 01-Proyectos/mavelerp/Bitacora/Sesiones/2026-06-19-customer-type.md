---
fecha: 2026-06-19
proyecto: mavelerp
autor: hector
tags: [sesion, crm, facturacion-electronica, customer-type]
---

# Sesión 2026-06-19 — Tipo de cliente y selección automática de e-CF

## Objetivo

Agregar campo `customer_type` a clientes para que el sistema elija
automáticamente el tipo de comprobante electrónico (e-CF) correcto al
facturar, en lugar de depender solo de la heurística por longitud del RNC.

## Contexto

El sistema anterior usaba una heurística frágil:
- RNC de 9 dígitos → E31 (Crédito Fiscal)
- Cualquier otro caso → E32 (Consumo)

Esto dejaba fuera los tipos especiales (E44, E45, E46) que solo se podían
seleccionar manualmente en el dropdown de "Tipo e-CF" al convertir una
cotización. Un cliente del gobierno con RNC de 9 dígitos generaba E31
cuando debería ser E45 (Gubernamental).

**Corrección importante identificada en sesión:** el tipo correcto para
entidades de gobierno es **E45 (Gubernamental)**, no E44. E44 es para
Regímenes Especiales (zonas francas, diplomáticos).

## Qué se hizo

### Migración
- `database/migrations/029_customers_type.sql` — `ALTER TABLE customers
  ADD COLUMN customer_type ENUM(...)`. Clientes existentes quedan como
  `empresa` (sin cambio de comportamiento).

### CRM — Formulario de clientes
- `modules/CRM/Views/customers/form.php` — nuevo dropdown "Tipo de
  cliente" con las 5 opciones y descripción del e-CF asociado.
- JS: si el usuario escribe un RNC de 9 dígitos y el select estaba en
  `persona_fisica`, lo cambia a `empresa` (y viceversa para 11 dígitos).
  No interfiere si el usuario ya eligió un tipo especial.

### CRM — Controller
- `modules/CRM/Controllers/CustomerController.php`:
  - `store()` y `update()` leen y validan `customer_type` (whitelist);
    lo persisten en INSERT/UPDATE.
  - `apiSearch()` devuelve `customer_type` en el JSON (para futuros usos
    en formularios de cotización/factura directa).

### Facturacion — Lógica de tipo e-CF
- `modules/Facturacion/Controllers/FacturacionController.php`:
  - `show()` incluye `c.customer_type` en el JOIN para pasarlo a la vista.
  - `convertToInvoice()`: nueva lógica de prioridad:
    1. `tipo_ecf_forzado` del request (override manual) — igual que antes.
    2. `customer_type` del cliente → mapa directo al número de tipo.
    3. Fallback: heurística RNC (para clientes sin `customer_type` o
       legacy).

### Facturacion — Vista de cotización
- `modules/Facturacion/Views/quotations/show.php` — el dropdown "Tipo
  e-CF" ahora se pre-selecciona automáticamente según el `customer_type`
  del cliente de la cotización. El usuario puede corregirlo antes de
  convertir.

## Mapa customer_type → tipo e-CF

| customer_type     | Tipo e-CF | Descripción |
|-------------------|-----------|-------------|
| `empresa`         | E31       | Crédito Fiscal (empresa privada con RNC) |
| `persona_fisica`  | E32       | Consumo (persona con cédula) |
| `gubernamental`   | E45       | Gubernamental |
| `regimen_especial`| E44       | Regímenes Especiales (zonas francas, etc.) |
| `exportacion`     | E46       | Exportaciones |

## Decisiones tomadas

- Ver [[../Decisiones/Decisiones.md]] → ADR-0005 (agregada hoy).
- El override manual (`tipo_ecf_forzado`) sigue disponible — el tipo del
  cliente es el default, no una restricción.
- No se tocaron NC/ND ni ninguna otra parte del flujo.

## Para activar en producción

```bash
mysql -u user -p database < database/migrations/029_customers_type.sql
```

## Pendientes

- [ ] Actualizar `Tareas-Pendientes.md` marcando la tarea de customer_type
      como completada (fue una sesión ad-hoc, no estaba en el backlog).

## Bloqueadores

Ninguno.

## Próxima sesión

Continuar con las tareas del backlog (2FA, NC/ND, etc.) o lo que
el usuario indique.
