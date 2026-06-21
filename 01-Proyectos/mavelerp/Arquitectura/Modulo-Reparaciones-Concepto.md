---
tipo: concepto-modulo
creado: 2026-06-19
estado: idea
tags: [modulo-futuro, reparaciones, crm, ordenes-trabajo]
proyecto: mavelerp
---

# Módulo Reparaciones — Concepto

> Idea capturada en sesión con amigo (2026-06-19). Orientado a talleres
> de reparación de celulares, consolas y dispositivos tecnológicos.
> **No implementar todavía.** Registrado para diseño futuro.

## Problema que resuelve

Un taller de reparación necesita:
1. Registrar dispositivos de clientes (IMEI, modelo, marca).
2. Abrir tickets de reparación con el problema reportado.
3. Asignar técnico responsable y hacer seguimiento de estado.
4. Agregar servicios y repuestos consumidos.
5. Cerrar el ticket generando una factura (conecta con **Facturacion**).
6. Notificar al cliente por email.

El CRM actual solo maneja clientes. Este módulo le agrega la dimensión
de dispositivos y órdenes de trabajo.

---

## Flujo principal

```
Cliente → Dispositivo (IMEI/SKU) → Ticket/OT
  → Problema reportado
  → Técnico asignado
  → Servicios + Repuestos (from Inventario)
  → Estado: New → In Progress → Waiting Parts → Finished / Cancel
  → Factura (from Facturacion)
  → Notificación email
```

---

## Pantallas clave (basadas en las fotos de referencia)

### Lista de tickets (`/reparaciones`)

Columnas: **Cliente · Boleto# · Modelo/Marca · Técnico · Problema ·
Creado · Pendiente · Estado · Última actualización**

Filtros: ordenar por (última actualización / fecha creación / #boleto),
estado (Abierto/Cerrado), técnico asignado, búsqueda libre.

Estados (badges de color):
- `New` — verde (recién creado, pendiente de atender)
- `In Progress` — azul
- `Waiting Parts` — amarillo
- `Finished` — gris oscuro
- `Cancel` — rojo

Botón `+ Crear ticket` arriba a la derecha.

### Crear ticket (wizard de 6 pasos)

```
① ¿Para quién? — Buscar cliente existente | + Nuevo cliente
② ¿Qué dispositivo? — Buscar por nombre o IMEI
               └─ lista de dispositivos previos del cliente
               └─ + Nuevo dispositivo (modelo, marca, IMEI/SKU)
③ ¿Cuál es el problema? — select de catálogo | + Nuevo problema
                           (ej: Pantalla rota, No se enciende, etc.)
④ Servicios y repuestos — buscador | Agregar servicio general
                         | Selector de productos (del módulo Inventario)
⑤ Detalles opcionales — notas internas, código de desbloqueo, etc.
⑥ Notificaciones — enviar email al cliente al crear/cerrar
```

---

## Entidades de BD (propuesta inicial)

```sql
-- Dispositivos por cliente
repair_devices (
  id, customer_id FK,
  brand, model, imei, sku,
  color, storage, notes,
  created_at
)

-- Catálogo de problemas
repair_problems (
  id, name, description, is_active
)

-- Tickets / Órdenes de trabajo
repair_tickets (
  id, ticket_number UNIQUE,
  customer_id FK, device_id FK, problem_id FK,
  assigned_to FK(users),
  status ENUM(new, in_progress, waiting_parts, finished, cancelled),
  internal_notes, unlock_code,
  estimated_cost, final_cost,
  document_id FK(documents) NULL,  -- factura generada
  created_at, updated_at, finished_at
)

-- Servicios y repuestos por ticket
repair_ticket_items (
  id, ticket_id FK,
  type ENUM(service, part),
  product_id FK NULL,  -- repuesto del módulo Inventario
  description, quantity, unit_price, total
)
```

---

## Integraciones con módulos existentes

| Módulo | Punto de integración |
|--------|---------------------|
| **CRM** | Reutiliza `customers`. Agrega submenu "Dispositivos" y "Tickets" bajo cada cliente. |
| **Inventario** | `repair_ticket_items` referencia `products` para repuestos. Descontaría stock al cerrar. |
| **Facturacion** | Al marcar ticket como `Finished`, ofrece "Generar Factura" que crea una COT/FAC con los ítems del ticket. |
| **Users** | Campo `assigned_to` referencia la tabla `users` (técnico). |

---

## Impacto en el CRM

El módulo **no reemplaza** al CRM — lo extiende. El menú CRM quedaría:

```
CRM
├── Clientes
├── Proveedores
└── [Reparaciones] ← nuevo submenu (solo si el módulo está activo)
    ├── Tickets
    └── Dispositivos
```

El perfil del cliente (`customers/show`) mostraría un nuevo tab
"Dispositivos" y "Tickets" si el módulo está activado.

---

## Notas de diseño para cuando se implemente

- `ticket_number` autogenerado: secuencial tipo `REP-NNNN` (no usa
  secuencias DGII — no es un comprobante fiscal, sino una OT interna).
- El ticket puede existir sin factura (algunos clientes solo traen para
  diagnóstico / presupuesto).
- Un mismo dispositivo puede tener múltiples tickets históricos.
- Considerar campo `warrany_until` en el ticket cerrado para seguimiento
  de garantía de la reparación.
- Si el cliente acepta el presupuesto se convierte en ticket activo;
  si lo rechaza → `Cancel`.
- El técnico asignado podría recibir notificación interna (flash o email).
- Número de Boleto en la foto de referencia = nuestro `ticket_number`.
- "Tecnología" en la foto = técnico asignado (el campo se llama distinto en
  el sistema de referencia).

---

## Referencias

- Fotos de referencia: sistema tipo RepairDesk/RepairShopr capturadas
  en sesión 2026-06-19.
- Ver [[../Tareas-Pendientes.md]] → sección "Módulos futuros".
