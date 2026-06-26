---
titulo: Decisiones de flujo de trabajo (global)
tags: [meta, decisiones, adr, flujo]
---

# Decisiones de flujo de trabajo — global

> ADRs sobre el **sistema de trabajo** (vault, skills, agentes),
> transversales a todos los proyectos. Para decisiones de arquitectura de
> un proyecto puntual, usar su propio `01-Proyectos/<x>/Decisiones/`.
> Formato ADR; las entradas se agregan al final, nunca se borran.

---

### ADR-F0001: Adopción curada de 3 skills de Superpowers (no el pack)

- **Fecha**: 2026-06-20
- **Estado**: Aceptada
- **Contexto**: Se evaluó instalar el plugin Superpowers
  (`obra/superpowers`, v6.0.2, ~20 skills) para robustecer el set.
  Instalarlo entero choca con dos cosas: (1) infla el contexto base de cada
  sesión —todas las `description` se cargan siempre— justo lo contrario del
  objetivo de la skill `hilo`; (2) rompe la filosofía de "todo vive en mi
  vault, curado y versionado". Además se solapa con built-ins
  (`/code-review`, `/security-review`, `/verify`, plan mode) y con el equipo
  `vengadores`.
- **Decisión**: NO instalar el pack. **Cherry-pick:** adaptar al vault solo
  3 skills que llenan huecos reales, traducidas al español e integradas al
  flujo —
  - `depuracion-sistematica` (causa raíz en 4 fases),
  - `brainstorming` (idea → diseño, socrático),
  - `tdd` (RED-GREEN-REFACTOR).
  Y usar `writing-skills` solo como **referencia** para mejorar
  `02-Plantillas/Plantilla-Skill.md` (CSO, economía de tokens, naming,
  tablas de racionalización).
- **Alternativas consideradas**:
  - Instalar el marketplace completo → context bloat + dependencia externa
    sin auditar. Descartado.
  - No adoptar nada → se pierden 3 técnicas con valor real. Descartado.
- **Consecuencias**: Poseemos las 3 skills (cero dependencia externa, cero
  inflado por skills no usadas). Quedan **desincronizadas de upstream**: si
  Superpowers mejora esas skills hay que re-mergear a mano. `tdd` rinde poco
  en mavelerp (sin test runner) → aplica sobre todo a proyectos Python/Node.
  Fuente: `github.com/obra/superpowers`.
