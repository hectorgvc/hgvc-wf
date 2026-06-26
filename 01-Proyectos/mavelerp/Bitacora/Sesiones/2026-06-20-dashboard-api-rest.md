---
fecha: 2026-06-20
tipo: sesion
tags: [dashboard, api-rest, inventario, seguridad]
proyecto: mavelerp
---

# Sesión 2026-06-20 — Dashboard de Almacén + API REST v1

## Resumen ejecutivo

Sesión de desarrollo completa ejecutada con el equipo Vengadores (DBA + Dev Senior ×2 + UI/UX Designer + Security Analyst). Se entregaron dos features grandes en producción: el Dashboard de Almacén del módulo Inventario y la capa de API REST v1 con autenticación Bearer token.

## Lo que se implementó

### Dashboard de Almacén
- Ruta: `GET /inventario/dashboard`
- Controller: `modules/Inventario/Controllers/DashboardController.php`
- Vista: `modules/Inventario/Views/dashboard/index.php` (665 líneas, Chart.js desde `cdn.jsdelivr.net`)
- **KPI cards:** total productos, unidades en stock, sin stock, valor total (`cost × stock`), stock bajo
- **Gráficos:** barras por categoría (Chart.js, color `--primary` dinámico), top 10 más vendidos (barras CSS sin canvas), líneas entradas/salidas 6 meses desde `inventory_movements`
- **Tablas:** alertas stock bajo (rojo si `stock=0`), productos sin movimiento 30 días
- Migración 031: columna `category VARCHAR(100)` en `products` (en Hostinger ya existía → omitida)
- Campo `category` añadido al form y controller de Productos (`store()` + `update()`)

### API REST v1
- Endpoints: `GET /api/v1/products`, `/customers`, `/invoices`, `/payments` + show por `{id}`
- Auth: `Authorization: Bearer {token}` validado contra tabla `api_tokens`
- Paginación: `?page=N` con meta `{page, per_page, total, total_pages}`
- Filtros: `?search`, `?category`, `?type`, `?date_from`, `?date_to`, `?status`, `?method`
- Gestión de tokens: `/api-tokens` (ADMIN only) — crear con `bin2hex(random_bytes(32))`, revocar
- Migración 032: tabla `api_tokens` aplicada en Hostinger

### Documentación interactiva
- `public/api-docs.html` (1128 líneas) — Try-it-out con `fetch()`, dark mode, sidebar con endpoints, colores extraídos de `app.css`

## Correcciones de seguridad (Security Analyst)

| Fix | Archivo |
|-----|---------|
| `hash_equals()` anti timing-attack en comparación de token | `ApiAuthMiddleware.php` |
| Log de intentos fallidos `API_AUTH_FAIL` con IP+UA | `ApiAuthMiddleware.php` |
| Validación formato `Y-m-d` en fechas de filtros | `BaseApiController.php` |
| Cast `(int)` + `min(100)` en LIMIT/OFFSET | `BaseApiController.php` |
| `RateLimitMiddleware` conectado a las 7 rutas API | `routes.php` |

## Hallazgo crítico

**`RateLimitMiddleware` nunca estuvo cableado en ninguna ruta del ERP**, pese a estar documentado en CLAUDE.md como "60 req/min activo". Existía el archivo pero no se usaba. Hoy es la primera vez que funciona — conectado a las rutas `/api/v1/`. El resto de la app (incluido `/login`) sigue sin rate limiting: agendar.

## Decisión documentada

**Tokens en texto plano:** se decidió NO hashear en esta iteración porque rompería el lookup `WHERE token = ?` y requiere rediseño (prefix + hash). La entropía es alta (256 bits). Registrado como mejora futura en Tareas-Pendientes.

## Archivos creados/modificados

```
NUEVOS:
  database/migrations/031_products_category.sql
  database/migrations/032_api_tokens.sql
  app/Middleware/ApiAuthMiddleware.php
  app/Controllers/Api/BaseApiController.php
  app/Controllers/Api/ProductsApiController.php
  app/Controllers/Api/CustomersApiController.php
  app/Controllers/Api/InvoicesApiController.php
  app/Controllers/Api/PaymentsApiController.php
  app/Controllers/ApiTokensController.php
  app/Views/api_tokens/index.php
  modules/Inventario/Controllers/DashboardController.php
  modules/Inventario/Views/dashboard/index.php
  public/api-docs.html

MODIFICADOS:
  app/routes.php                                    (rutas API + tokens)
  modules/Inventario/routes.php                     (ruta dashboard)
  modules/Inventario/Controllers/ProductController.php  (category en store/update)
  modules/Inventario/Views/products/form.php        (campo category)
```

## Estado deploy

- Todos los archivos desplegados en Hostinger vía FTP (2026-06-20)
- Migración 031: ya existía → omitida
- Migración 032: aplicada correctamente
- OPcache reset ejecutado
