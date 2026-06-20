# Agentes — equipo "Vengadores"

Subagentes de Claude Code que viven en el vault (fuente de verdad,
git-tracked) y se activan con symlink a `~/.claude/agents/` vía
`../usar-agente.sh`. Se convocan con la skill `vengadores`
(Nick Fury = la sesión principal orquesta; no hay agente "arquitecto"
aparte).

> A diferencia de las skills (carpeta con `SKILL.md`), cada agente de
> Claude Code es **un solo archivo** `.md` con frontmatter
> `name` / `description` / `model` (y opcional `tools`).

## Índice

| Agente | subagent_type | Modelo | Rol |
|--------|---------------|--------|-----|
| Dev Senior | `dev-senior` | Opus | Implementa y repara código |
| UI/UX Designer | `ui-ux-designer` | Sonnet | Front-end, Lucide, nada de emojis |
| QA / Bug Hunter | `qa-bug-hunter` | Sonnet | Caza y reporta bugs |
| Security Analyst | `security-analyst` | Opus | Audita y corrige seguridad |
| DBA | `dba` | Sonnet | Migraciones SQL y esquema |
| Documentalista | `documentalista` | Haiku | Registra la misión en el vault |

## Activar un agente

```bash
~/ObsidianVault/usar-agente.sh <nombre> --global
~/ObsidianVault/usar-agente.sh <nombre> --proyecto <ruta-repo>
```

Con `--copia` en vez de symlink si el repo lo va a usar alguien sin el
vault.

## Agregar un agente nuevo

1. Crear `04-Agentes/<nombre>.md` siguiendo
   [[Plantilla-Agente.md]] (ojo: el frontmatter `name` / `description` /
   `model` es el que Claude Code exige).
2. Activarlo con `usar-agente.sh`.
3. Agregar fila a la tabla de arriba y al equipo de la skill `vengadores`.
