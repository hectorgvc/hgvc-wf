---
description: >
  Usar cuando el usuario pida un reporte, status, cierre de proyecto o
  resumen consolidado de un proyecto del vault de Obsidian (por
  ejemplo: "armame el reporte de mavelerp", "status del proyecto
  veterinaria", "cerrá el proyecto demo"). Activar también cuando el
  usuario pida explícitamente la skill /reporte-proyecto. NO usar para
  tareas que no pidan síntesis: editar notas individuales, crear
  proyectos nuevos, decisiones sueltas o resúmenes cortos en chat.
---

# reporte-proyecto

Sintetiza toda la documentación de un proyecto del vault en un único
`05-Reporte-Final.md`. **Solo lee notas existentes; nunca inventa
información que no esté en el vault.**

## Instrucciones

1. **Identificar el proyecto**.
   - Si el usuario pasó un nombre, usarlo.
   - Si no, mirar el `cwd` o el repo activo y buscar su import
     `@/home/hector/ObsidianVault/01-Proyectos/<nombre>/CLAUDE.md`.
   - Si no hay forma de identificarlo, **preguntar antes de seguir**.
2. **Localizar la carpeta** del proyecto en
   `~/ObsidianVault/01-Proyectos/<nombre>/`. Si no existe, decir
   "no encontré el proyecto X en el vault" y parar.
3. **Leer en este orden**, saltando los que no existan (no inventar):
   - `00-Proyecto.md`
   - `Arquitectura/*.md`
   - `Decisiones/*.md`
   - `Bugs/*.md`
   - `Bitacora/Sesiones/*.md` (de más reciente a más vieja)
   - `05-Reporte-Final.md` si existe (para no pisarlo sin avisar)
4. **Sintetizar** las siguientes secciones:
   - **Resumen ejecutivo**: 2-4 frases. Solo a partir del Resumen de
     `00-Proyecto.md` y, si hace falta, del último resumen de sesión.
   - **Arquitectura actual**: a partir de `Arquitectura/*.md`. Si no
     hay archivos, escribir `Sin datos en las notas`.
   - **Decisiones clave**: las 3-5 ADRs más relevantes (no la lista
     completa). Citar `ADR-NNNN: título`.
   - **Problemas conocidos**: lista de bugs abiertos, agrupada por
     severidad si hay datos suficientes.
   - **Estado**: fase/versión + última sesión registrada.
   - **Próximos pasos**: pendientes de la última sesión + bloqueadores
     activos.
5. **Regla de honestidad**: si una sección no tiene material en las
   notas, escribir literalmente `Sin datos en las notas` en esa
   sección. **Prohibido inferir**.
6. **Escribir o actualizar** `01-Proyectos/<nombre>/05-Reporte-Final.md`.
   - Si ya existe un reporte previo, **preguntar al usuario** antes
     de sobrescribir (mostrarle un diff resumido o el reporte actual).
   - Si no existe, crearlo con frontmatter:
     `fecha: YYYY-MM-DD` (la fecha del día, no inventar) y `tags: [reporte]`.
7. **Confirmar al usuario** qué archivo se creó/actualizó y en qué ruta.

## Ejemplos

### Ejemplo 1 — proyecto nuevo, notas mínimas

**Input**: "armame el reporte del proyecto demo-app"

**Pasos**:

1. Localizar `01-Proyectos/demo-app/`.
2. Leer `00-Proyecto.md`. No hay `Arquitectura/`, `Decisiones/`,
   `Bugs/` ni bitácora todavía.
3. Escribir `05-Reporte-Final.md` con:
   - Resumen ejecutivo: el del `00-Proyecto.md`.
   - Arquitectura: `Sin datos en las notas`.
   - Decisiones clave: `Sin datos en las notas`.
   - Problemas conocidos: ninguno.
   - Estado: el de `00-Proyecto.md`.
   - Próximos pasos: `Sin datos en las notas`.

**Output esperado**:

```
01-Proyectos/demo-app/05-Reporte-Final.md creado.
```

### Ejemplo 2 — proyecto maduro, reporte previo existe

**Input**: "refrescame el reporte de mavelerp"

**Pasos**:

1. Localizar `01-Proyectos/mavelerp/`. Existe `05-Reporte-Final.md` previo.
2. **Preguntar**: "Hay un reporte previo del 2026-05-01. ¿Lo
   reescribo entero o solo actualizo lo que cambió?".
3. Tras confirmación, leer todas las notas nuevas desde la fecha del
   reporte previo, sintetizar y reescribir el archivo completo.

**Output esperado**:

- Diff resumido de qué cambió sección por sección, o
  "Reporte actualizado: 3 sesiones nuevas, 1 ADR nueva, 0 bugs
  nuevos".

### Ejemplo 3 — proyecto que no existe

**Input**: "armame el reporte de veterinaria-v2"

**Pasos**:

1. `01-Proyectos/veterinaria-v2/` no existe (solo está
   `veterinaria`).

**Output esperado**:

- Mensaje: "No encontré el proyecto `veterinaria-v2` en el vault.
  ¿Quisiste decir `veterinaria`?"
