---
tipo: arquitectura
creado: 2026-06-19
proyecto: mavelerp
tags: [arquitectura, mvc, estructura]
---

# Arquitectura General — mavelerp

## Stack

| Capa | Tecnología |
|------|-----------|
| Lenguaje | PHP 8.0+ (`declare(strict_types=1)`) |
| Framework | MVC propio (sin third-party) |
| Base de datos | MySQL 8+ (InnoDB, utf8mb4) |
| Firma XML | `robrichards/xmlseclibs` (RSA-SHA256, XMLDSig) |
| Importación | PhpSpreadsheet |
| Timezone | America/Santo_Domingo |
| Deploy | Hostinger; dev en `php -S localhost:8000` |

## Request Lifecycle

```
.htaccess → $_GET['url'] → index.php → App::bootstrap()
  → spl_autoload_register()
  → Session::start()
  → loadRoutes() (app/routes.php)
  → ModuleLoader::loadModules()   ← consulta module_license por módulo
  → Router::dispatch()
      → match URL pattern
      → middleware chain (Middleware::handle())
      → Controller::method()
```

`index.php` verifica `config/installed.lock`; si falta, redirige a `/install/`.
`BASE_PATH` = `__DIR__` definido en `index.php`.

## Namespace Map (autoloader custom en App.php)

| Prefijo | Directorio |
|---------|-----------|
| `Core\` | `core/` |
| `App\Controllers\` | `app/Controllers/` |
| `App\Models\` | `app/Models/` |
| `App\Middleware\` | `app/Middleware/` |
| `Modules\` | `modules/` |

Los controllers de módulos usan `Modules\{NombreModulo}\Controllers\`.

## Estructura de directorios

```
├── core/              # Kernel del framework
├── app/               # Controllers, models, views, middleware base
├── modules/           # Módulos feature (auto-contenidos)
├── config/            # app.php, database.php (generados por installer)
├── database/          # schema.sql, seed.sql, migrations/
└── storage/           # logs/, certificates/ (no público, gitignored)
```

## Sistema de módulos

Cada módulo en `modules/` requiere:
- `module.json` — manifest: `name`, `display_name`, `version`, `description`, `is_premium`
- `routes.php` — recibe `$router` y registra rutas
- `Controllers/`, `Views/`, `Models/` — MVC opcional

`ModuleLoader` escanea `modules/*/module.json`, consulta `module_license` (`is_enabled`)
y carga `routes.php` solo para módulos activos.

## Módulos activos

| Módulo | Función |
|--------|---------|
| Facturacion | Cotizaciones, facturas, NC/ND (e-CF: E31–E34) |
| Compras | Órdenes de compra |
| Inventario | Productos y stock |
| CRM | Clientes y proveedores |
| Finanzas | Pagos y cobros |
| Contabilidad | Plan de cuentas, asientos |
| Informes | Reportes fiscales DGII (606, 607) |
| Certificacion | Flujo pruebas DGII 4 pasos |
| Recepcion | Recepción e-CF + emisión ARECF |

## Archivos clave del núcleo fiscal

| Archivo | Rol |
|---------|-----|
| `core/Fiscal/EcfManager.php` | Motor e-CF: XML, firma, auth token, envío (3086 líneas) |
| `core/Fiscal/NcfManager.php` | Gestión secuencias NCF/e-NCF |
| `core/Fiscal/DgiiLogger.php` | Log estructurado transmisiones DGII |
| `core/Fiscal/ReportGenerator.php` | Generación reportes 606/607 |
| `core/Security/CertificateManager.php` | Storage seguro .p12 (AES-256) |

> Para el detalle completo del núcleo fiscal e-CF ver `core-mavelerp.md` en el repo.
