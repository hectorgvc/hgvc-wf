---
fecha: 2026-06-21
tipo: sesion
tags: [branding, qa, api-rest, git, deploy, bugfix]
proyecto: mavelerp
---

# Sesión 2026-06-21 — QA Branding, API REST, Push Git, Fix app_tagline

## Resumen ejecutivo

Sesión de cierre tras la del 2026-06-20. Se finalizó el push a GitHub
(cambio de cuenta), se desplegó el vault en git, y se corrigió un bug
crítico en Settings (migración faltante).

## Lo que se hizo

### Push a GitHub
- Email git actualizado a `promptgramador@gmail.com`.
- Remote corregido a `promptgramador-star/mavelerp` (cuenta actual).
- Commit `6677096` pusheado a rama `dev`: 33 archivos, 2158 inserciones.
  Incluye todo lo de la sesión anterior (Dashboard, API REST, 5 QA points).

### Vault desplegado en git
- `.gitignore` del vault actualizado: patrón `01-Proyectos/*` +
  `!01-Proyectos/mavelerp` (negación de subdirectorio funciona con `*`
  glob, no con `/`).
- 22 archivos de mavelerp (bitácoras, tareas, arquitectura, decisiones)
  commiteados y pusheados a `hectorgvc/hgvc-wf` (rama `main`).

### Bug: "Error del Sistema" al guardar Settings → color secundario
- **Causa raíz:** `app_tagline` se añadió a `SettingsController::update()`
  (línea 97) como columna en `$data`, pero no tenía migración SQL.
  El `UPDATE settings SET app_tagline=...` fallaba con error de columna
  desconocida → excepción PDO → "Error del Sistema".
- **Fix:** migración `035_settings_app_tagline.sql` (idempotente, columna
  `VARCHAR(200) NULL`) creada y aplicada en Hostinger vía one-shot PHP.
- **Lección:** toda columna nueva en `$data` del SettingsController
  necesita su migración, incluso si solo es un campo de texto.

## Pendientes detectados hoy (nuevos)
- `RateLimitMiddleware` solo cableado en API; rutas principales sin él.
- Botón de impresión del panel lateral (`show.php`) vs botón del footer:
  flujos distintos, pendiente unificar.
- Responsive/móvil: sigue como deuda técnica principal post-branding.

## Archivos creados/modificados
```
NUEVO:
  database/migrations/035_settings_app_tagline.sql
VAULT:
  .gitignore (patrón negación mavelerp)
  01-Proyectos/mavelerp/** (22 archivos — primera vez en git)
```

## Estado deploy
- Migración 035: aplicada en Hostinger (one-shot blanqueado).
- Git mavelerp: `dev` en `promptgramador-star/mavelerp` al día.
- Git vault: `main` en `hectorgvc/hgvc-wf` al día.
