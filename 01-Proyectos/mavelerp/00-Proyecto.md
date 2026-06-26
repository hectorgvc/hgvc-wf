---
nombre: mavelerp
creado: 2026-06-18
estado: activo
tags: [proyecto, erp, facturacion-electronica, dgii]
---

# mavelerp

> ERP Propietario RD — Sistema modular de gestión empresarial con
> cumplimiento de facturación electrónica DGII (e-CF) para República
> Dominicana.

## Resumen

ERP propio para empresas dominicanas. Cubre ventas (cotizaciones,
facturas, notas de crédito/débito), compras, inventario, CRM, finanzas,
contabilidad, informes fiscales (606/607) y el flujo completo de
certificación e-CF ante DGII. En etapa activa de **pruebas de
representación impresa** (post-Paso 3 aprobado) previo a producción.

## Stack

- **Lenguaje principal**: PHP 8.0+ con `declare(strict_types=1)`
- **Framework**: MVC propio (sin framework third-party); autoload PSR-4
  custom en `App.php` mapea `Core\`, `App\`, `Modules\`
- **Base de datos**: MySQL 8+ (InnoDB, utf8mb4)
- **Infra / deploy**: Hostinger (PHP built-in para dev en `:8000`);
  migraciones SQL manuales vía `mysql` CLI
- **Otros**: PhpSpreadsheet (importación), robrichards/xmlseclibs
  (firma XMLDSig), Composer
- **Timezone**: America/Santo_Domingo

## Repositorio

- **Path local**: `/var/www/html/mavelerp`
- **Documentación interna del repo**: `CLAUDE.md` (raíz) +
  `core-mavelerp.md` (núcleo fiscal e-CF)

## Estado actual

- **Versión / fase**: Certificación DGII — Pasos 1–3 aprobados
  (2026-06-04). Etapa activa: **Representaciones Impresas en
  evaluación** por DGII (QR ya valida en CerteCF al 2026-06-11).
- **Última sesión**: [[Bitacora/Sesiones/2026-06-20-dashboard-api-rest]] —
  Dashboard de Almacén + API REST v1 en producción. 7 endpoints `/api/v1/*` con
  Bearer token, gestión de tokens, rate limiting funcional (primera vez cableado),
  documentación interactiva en `/public/api-docs.html`. Migración 031 (category) y
  032 (api_tokens) aplicadas en Hostinger.
- **Cerrado en prod (2026-06-20)**: 3 features nuevas — auto-refresh estado DGII
  (E31 Procesando → Aceptado) · selector método de pago (EFECTIVO/TRANSFERENCIA/TARJETA/CHEQUE)
  con insert en `invoice_payments` · sección editable "Políticas y Formas de Pago" impresa en todos
  los documentos. También resuelto BUG-007 (`ecf_status` desincronizado con `estado_dgii`).
- **Cerrado en prod (2026-06-19)**: `customer_type` → e-CF automático ·
  lookup RNC contra DGII (auto-completa cliente) · **2FA arreglado**
  (BUG-001) · **NC/ND** ítems reales + fix inflación ITBIS (BUG-002) ·
  **ambiente test** reactivado en TesteCF (postulación CerteCF cerrada al
  certificar; envío E31 Aceptado).
- **Ambiente e-CF actual**: `TEST` (testecf). Producción pendiente de
  activar rangos `prod` + `ecf_environment=PROD`.
- **Próximo hito**: cerrar Paso 4 / habilitar producción
  - Pendiente pre-producción: NC/ND (E33/E34) — probar end-to-end nuevo contra CerteCF (fix de ITBIS ya aplicado).
  - Pendiente menor: verificar que auto-refresh DGII no dispara múltiples consultas (logging en `storage/logs/`).

## Módulos

- **Facturacion** — Cotizaciones, facturas, notas de entrega (e-CF: E31,
  E32, E33, E34)
- **Compras** — Órdenes de compra
- **Inventario** — Productos y stock
- **CRM** — Clientes y proveedores
- **Finanzas** — Pagos y cobros
- **Contabilidad** — Plan de cuentas, asientos
- **Informes** — Reportes fiscales DGII (606, 607)
- **Certificacion** — Flujo de pruebas DGII 4 pasos
- **Recepcion** — Recepción admin de e-CF + emisión ARECF

## Arquitectura

Ver [[Arquitectura/]]. Acá solo un puntero.

## Decisiones

Todas las ADRs viven en [[Decisiones/]]. Acá un resumen ejecutivo de
las 3-5 más importantes.

## Tareas pendientes

Ver [[Tareas-Pendientes.md]] — backlog vivo priorizado.

## Bugs conocidos

Lista viva en [[Bugs/]]. Acá solo los abiertos críticos.

## Bitácora

Entradas cronológicas en [[Bitacora/Sesiones/]], una por sesión de
trabajo.

## Reporte Final

[[05-Reporte-Final.md]] — síntesis generada por la skill
`reporte-proyecto`. Actualizar al cerrar un hito importante.
