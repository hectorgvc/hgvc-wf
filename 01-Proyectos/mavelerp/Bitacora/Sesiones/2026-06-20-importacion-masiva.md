---
fecha: 2026-06-20
tema: Importación masiva con clave única y modo de resolución
tags: [importacion, crm, inventario, features]
relacionado: []
---

# Sesión — Importación masiva (2026-06-20)

## Resumen

Implementación de importación masiva de datos con **clave única** y **modo de resolución de duplicados** en 3 módulos: CRM (Clientes, Proveedores) e Inventario (Productos). La feature permite importar la misma lista múltiples veces sin duplicar registros ni romper datos existentes, seleccionando el comportamiento deseado al momento de subir el archivo.

## Qué se hizo

### 1. Controllers modificados

#### `modules/CRM/Controllers/CustomerController@importProcess`
- Lógica: upsert por **RNC como clave única**
- Lectura de `POST['modo']` con whitelist: `insertar_nuevos` (default) o `actualizar_existentes`
- Si RNC ya existe:
  - `insertar_nuevos`: omitir fila, `$skipped++`
  - `actualizar_existentes`: UPDATE de campos de datos (no modifica RNC), `$updated++`
- Si RNC vacío: siempre INSERT (sin forma de identificar)
- Flash: `"{n} creados, {n} actualizados, {n} omitidos"` (solo muestra partes > 0)

#### `modules/CRM/Controllers/SupplierController@importProcess`
- Idem a clientes, con **fix crítico de normalización RNC**:
  - Antes: `trim()` solamente → RNC con guiones no deduplicaba
  - Ahora: `preg_replace('/[^0-9]/', '', trim(...))` → normaliza a dígitos puros
  - Ej: `130-23456-7` → `130234567` (deduplica contra histórico)
- Lógica de modo idéntica a clientes

#### `modules/Inventario/Controllers/ProductController@importProcess`
- Upsert por **SKU como clave única**
- Lógica de modo: `insertar_nuevos` / `actualizar_existentes` idéntica
- Flash al terminar con recuento

### 2. Vistas modificadas

#### `modules/CRM/Views/customers/index.php`
- Agregado selector de modo en modal de importación
- Dos radio buttons: "Insertar nuevos (ignorar duplicados)" / "Actualizar existentes"
- Pasa `POST['modo']` al controller

#### `modules/CRM/Views/suppliers/index.php`
- Ídem a clientes

#### `modules/Inventario/Views/products/import.php`
- Selector de modo en la página de importación (no modal)
- Habilitado `.xlsx` como formato de entrada (antes solo CSV)
- **Reemplazados emojis por iconos Lucide** para consistencia visual (✅ → `<i class="lucide lucide-check"></i>`, etc.)

### 3. Bug corregido de paso (BUG-008)

**Proveedores con RNC normalizado incorrecto**

En `SupplierController`, el RNC importado no se normalizaba (no se removían guiones), causando que un proveedor con `RNC=130-23456-7` no deduplicara contra `RNC=130234567` en BD. Cada importación duplicaba.

**Fix:** Usar `preg_replace('/[^0-9]/', '', trim(...))` en lugar de solo `trim()` para extraer dígitos puros al leer el archivo.

## Archivos tocados

- `/modules/CRM/Controllers/CustomerController.php` — método `importProcess()`
- `/modules/CRM/Controllers/SupplierController.php` — método `importProcess()` + fix RNC
- `/modules/Inventario/Controllers/ProductController.php` — método `importProcess()`
- `/modules/CRM/Views/customers/index.php` — modal de importación
- `/modules/CRM/Views/suppliers/index.php` — modal de importación
- `/modules/Inventario/Views/products/import.php` — página de importación + iconos

## Testeo realizado

- Importación dual de archivo CSV/XLSX en los 3 módulos
- Verificación de deduplicación en modo `insertar_nuevos`
- Verificación de actualización en modo `actualizar_existentes`
- Normalización de RNC en proveedores (guiones removidos)
- Flash messages mostrando recuento correcto

## Resultado

Feature lista para usar. El flujo es:
1. Subir archivo (CSV o XLSX)
2. Seleccionar modo (insertar nuevos o actualizar existentes)
3. Ver flash con resumen: "X creados, Y actualizados, Z omitidos"

Agiliza importaciones de datos masivos sin riesgo de duplicación.

## Pendientes

Ninguno.
