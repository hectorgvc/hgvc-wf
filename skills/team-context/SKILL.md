---
description: >
  Skill fundacional del sistema Team. Se carga al inicio de cualquier
  sesión en un proyecto conectado al vault. Todas las demás skills la
  leen antes de ejecutar. No invocar directamente — otras skills la
  importan con @.
depends_on: []
---

# Team Context

Lee y aplica antes de cualquier acción en un proyecto conectado:
@~/ObsidianVault/00-Reglas-Globales/CLAUDE-global.md

## Regla de composición

Toda skill nueva en 03-Skills/ debe:
1. Declarar `depends_on: [team-context]` en su frontmatter.
2. Leer CLAUDE-global.md antes de ejecutar cualquier paso.
