---
fecha: 2026-06-20
tipo: sesion
tags: [importacion, pos, bugfix, ui]
proyecto: mavelerp
---

# Sesión 2026-06-20 — Fixes importación masiva + rediseño POS

## Importación masiva — 11 bugs corregidos

QA auditó los 3 controllers de importación (`ProductController`, `CustomerController`, `SupplierController`) y encontró 11 bugs + 5 gaps. Se corrigieron en esta sesión:

### Bugs críticos
- **BUG-001** — Whitelist de extensiones: solo `csv`/`xlsx` aceptados. Antes, cualquier archivo pasaba al parser.
- **BUG-002** — Validación de cabeceras: si la primera fila no coincide exactamente con los headers esperados, se aborta con mensaje claro.

### Bugs altos
- **BUG-003** — XLSX rich text: `parseXlsx()` ahora concatena todos los `<r><t>` (no solo el primero).
- **BUG-004** — Off-by-one en relleno de columnas XLSX: `$i < 6` → `$i < 9` (ProductController).
- **BUG-005** — Missing `return` tras `$this->json([])` en `CustomerController::apiSearch()`.
- **BUG-006** — `$limit` no se bindeaba en SQL de búsqueda de productos. Fix: `:limit` con tope 100.
- **BUG-007** — Sin check de `fopen()` en `parseCsv()`: `if ($handle === false) return []`.
- **BUG-008** — `customer_type` siempre `'empresa'` al importar. Fix: inferir desde longitud RNC (11 dígitos = persona_fisica).
- **BUG-009** — `is_taxable` ausente en importación de productos. Fix: columna `es_gravado` en plantilla + INSERT/UPDATE.
- **BUG-011** — Modal de importación en `products/index.php` sin selector de modo. Fix: radios insertar/actualizar añadidos.

### Gap implementado
- **GAP-3** — Límite de 5 MB en los 3 controllers.

### Archivos modificados
- `modules/Inventario/Controllers/ProductController.php`
- `modules/CRM/Controllers/CustomerController.php`
- `modules/CRM/Controllers/SupplierController.php`
- `modules/Inventario/Views/products/index.php`
- `modules/Inventario/Views/products/import.php`

### Nota breaking change
Plantilla de proveedores: header `rnc` → `rnc_cedula`. Plantillas viejas guardadas no pasarán la nueva validación.

### Pendiente (próxima sesión)
- Paginado en listados
- Categorías de productos
- Exportar CSV/Excel
- Campos dinámicos SUPER_ADMIN

---

## POS terminal — rediseño visual completo

Archivo: `modules/POS/Views/terminal.php`

- Layout dos columnas: catálogo (izq) / carrito (der)
- Búsqueda con icono Lucide `search` dentro del input
- Product cards con avatar de inicial, animación hover, badge out-of-stock
- Carrito: botón `trash-2` por fila, estado vacío con feedback visual
- Totales: bloque con fondo color primario / texto blanco, legible de lejos
- Modales con animación de entrada, clases CSS semánticas para errores
- Todo el JS preservado íntegro

---

## Segunda ronda — Paginado, Categorías, Exportar, Campos Dinámicos (misma sesión)

### Migraciones aplicadas en producción
- **033_products_category.sql** — columna `category VARCHAR(100) NULL` + índice en `products`
- **034_custom_fields.sql** — tabla `custom_fields` (entity, column_name, label, field_type, created_by)

### Paginado
20 registros por página en productos, clientes y proveedores. Filtros activos (búsqueda + categoría) se preservan al paginar. Fix cosmético: botón "Anterior" tenía `btn` sin color → ahora `btn btn-primary` igual que "Siguiente".

### Categorías de productos
Campo `category` en form de producto, filtro desplegable en listado, incluida en importación (columna 5 del template) y exportación CSV.

### Exportar CSV
Botón en los 3 listados. Respeta filtros activos, BOM UTF-8 para compatibilidad con Excel. Rutas: `GET products/export`, `GET customers/export`, `GET suppliers/export`.

### Campos dinámicos SUPER_ADMIN
- `app/Controllers/Admin/CustomFieldsController.php` — nuevo controller con `index/store/destroy`
- Whitelist: entidades `products`/`customers`; tipos `VARCHAR(255)`, `TEXT`, `INT`, `DECIMAL(15,4)`
- Prefijo obligatorio `cf_` en todos los column_name generados
- `destroy` elimina solo el registro en `custom_fields` — no hace DROP COLUMN (irreversible, requiere intervención manual)
- Link "Campos Personalizados" en menú principal visible solo para SUPER_ADMIN
- Campos custom se renderizan dinámicamente en forms de producto y cliente

### Archivos nuevos
- `app/Controllers/Admin/CustomFieldsController.php`
- `app/Views/admin/custom_fields/index.php`
- `app/Views/partials/_custom_fields.php`
