---
titulo: Reconstruir mi estructura de trabajo (Obsidian + Claude Code)
actualizado: 2026-06-20
tags: [meta, backup, blueprint, recuperacion]
---

# Reconstruir mi estructura completa desde cero

> **Qué es esto:** el blueprint para rearmar todo mi sistema de trabajo
> (vault de Obsidian + reglas globales + skills + equipo de agentes
> "Vengadores") en una PC nueva o tras perder los archivos.
>
> **Guardalo fuera de la máquina** (Drive, repo privado, USB).
>
> **El backup #1 NO es este archivo: es `git push` del vault** a un remoto
> privado (ver §7). Este doc es el mapa por si perdés hasta eso.

---

## 1. Filosofía en una frase

Mi "cerebro" vive en `~/ObsidianVault` (un repo git). Claude Code lo
consume vía imports en `~/.claude/CLAUDE.md`. Skills y agentes viven en el
vault (fuente de verdad) y se **activan con symlinks** a `~/.claude/` con
dos scripts (`usar-skill.sh`, `usar-agente.sh`). Nada vive solo en
`~/.claude/`: todo es symlink al vault.

---

## 2. Árbol completo

```
~/ObsidianVault/
├── 00-RECONSTRUIR.md            ← este archivo
├── 00-Reglas-Globales/
│   ├── CLAUDE-global.md         ← cómo me comunica Claude (español, conciso, plan-primero…)
│   └── Decisiones-Flujo.md      ← ADRs de flujo de trabajo (globales, no de un proyecto)
├── 01-Proyectos/
│   └── <proyecto>/
│       ├── 00-Proyecto.md       ← ficha viva (resumen, stack, estado, hitos)
│       ├── CLAUDE.md            ← solo @imports (ensambla el proyecto)
│       ├── Arquitectura/*.md
│       ├── Decisiones/*.md      ← ADRs
│       ├── Bugs/Bugs.md
│       ├── Bitacora/Sesiones/YYYY-MM-DD-tema.md
│       ├── Tareas-Pendientes.md
│       └── 05-Reporte-Final.md  ← lo genera la skill reporte-proyecto
├── 02-Plantillas/
│   ├── Plantilla-Proyecto.md
│   ├── Plantilla-Decision.md
│   ├── Plantilla-Sesion.md
│   └── Plantilla-Skill.md
├── 03-Skills/
│   ├── README.md                ← índice de skills
│   ├── reporte-proyecto/SKILL.md
│   ├── fase/SKILL.md            ← recomienda modelo (Sonnet/Opus)
│   ├── lucide/SKILL.md          ← iconos Lucide, nunca emojis
│   ├── vengadores/SKILL.md      ← orquesta el equipo de agentes
│   ├── hilo/SKILL.md            ← ¿conviene cerrar el hilo e ir a uno nuevo?
│   ├── depuracion-sistematica/  ← debug por causa raíz (adaptada de Superpowers)
│   ├── brainstorming/           ← idea → diseño socrático (adaptada de Superpowers)
│   └── tdd/                     ← RED-GREEN-REFACTOR (adaptada de Superpowers)
├── 04-Agentes/                  ← equipo "Vengadores" (1 archivo .md por agente)
│   ├── README.md
│   ├── Plantilla-Agente.md
│   ├── dev-senior.md       (Opus)
│   ├── ui-ux-designer.md   (Sonnet)
│   ├── qa-bug-hunter.md    (Sonnet)
│   ├── security-analyst.md (Opus)
│   ├── dba.md              (Sonnet)
│   └── documentalista.md   (Haiku)
├── usar-skill.sh                ← activa una skill (symlink a ~/.claude/skills/)
└── usar-agente.sh               ← activa un agente (symlink a ~/.claude/agents/)

~/.claude/
├── CLAUDE.md                    ← importa 00-Reglas-Globales/CLAUDE-global.md
├── skills/  <symlinks>  →  ~/ObsidianVault/03-Skills/<nombre>
└── agents/  <symlinks>  →  ~/ObsidianVault/04-Agentes/<nombre>.md
```

---

## 3. Diferencia clave skill vs agente

- **Skill** = carpeta `03-Skills/<nombre>/SKILL.md`. Frontmatter: solo
  `description`. Se invoca con `/<nombre>`. Corre en la sesión principal.
- **Agente** = un solo archivo `04-Agentes/<nombre>.md`. Frontmatter que
  **Claude Code exige**: `name`, `description`, `model` (y opcional
  `tools`). Se invoca como subagente vía la herramienta Agent. Estar
  definido NO gasta tokens; solo gasta al convocarlo.

---

## 4. El wiring de las reglas globales

`~/.claude/CLAUDE.md` debe contener esta línea (es lo que mete mis reglas
en cada sesión de cualquier proyecto):

```
@import(/home/hector/ObsidianVault/00-Reglas-Globales/CLAUDE-global.md)
```

Para que un repo de código lea la memoria de su proyecto, su
`<repo>/.claude/CLAUDE.md` importa el `CLAUDE.md` del proyecto del vault.

---

## 5. Los dos scripts de activación (recrear si se perdieron)

> Ambos: symlink por defecto; `--copia` para copiar; nunca sobrescriben.
> `chmod +x` después de crearlos.

**`usar-skill.sh`** — activa `03-Skills/<nombre>/` en `~/.claude/skills/<nombre>`:
```
usar-skill.sh <nombre> --global [--copia]
usar-skill.sh <nombre> --proyecto <ruta-repo> [--copia]
```

**`usar-agente.sh`** — activa `04-Agentes/<nombre>.md` en `~/.claude/agents/<nombre>.md`:
```
usar-agente.sh <nombre> --global [--copia]
usar-agente.sh <nombre> --proyecto <ruta-repo> [--copia]
```

Si perdiste el contenido de los scripts, están versionados en el git del
vault. Si tampoco tenés el git, pedile a Claude: *"recrea usar-skill.sh y
usar-agente.sh según 00-RECONSTRUIR.md"* — la firma de uso de arriba
alcanza para regenerarlos.

---

## 6. Skills y agentes — qué es cada uno

### Skills
| Skill | Qué hace |
|-------|----------|
| `reporte-proyecto` | Sintetiza un proyecto del vault en `05-Reporte-Final.md`. Solo lee, no inventa. |
| `fase` | Al empezar una tarea, recomienda modelo: **Sonnet** (UI, código conocido, debug con pistas, refactor) u **Opus** (arquitectura nueva, debug sin pistas, razonamiento multi-paso, decisiones con trade-offs). |
| `lucide` | Iconos Lucide por tipo de negocio. **Regla dura: siempre Lucide, nunca emojis / FontAwesome / heroicons.** |
| `vengadores` | Orquesta al equipo de `04-Agentes/`. Plan-primero → autónomo. |
| `hilo` | Evalúa señales (compactación, commits, mensajes) y recomienda si cerrar el hilo e iniciar uno nuevo para ahorrar contexto/tokens. |
| `depuracion-sistematica` | Debug por causa raíz en 4 fases. Adaptada de Superpowers (ver `00-Reglas-Globales/Decisiones-Flujo.md` ADR-F0001). |
| `brainstorming` | Idea → diseño por método socrático. Adaptada de Superpowers. |
| `tdd` | Ciclo RED-GREEN-REFACTOR. Adaptada de Superpowers (rinde en Python/Node; mavelerp no tiene test runner). |

### Agentes (equipo "Vengadores")
| Agente | Modelo | Rol |
|--------|--------|-----|
| `dev-senior` | Opus | Implementa features y repara bugs. |
| `ui-ux-designer` | Sonnet | Front-end HTML/CSS/JS; usa Lucide, nada de emojis. |
| `qa-bug-hunter` | Sonnet | Caza y **reporta** bugs (no repara). |
| `security-analyst` | Opus | Audita y **corrige** vulnerabilidades. |
| `dba` | Sonnet | Migraciones SQL, esquema, queries. |
| `documentalista` | Haiku | Al cerrar, registra la misión en el vault. |

**Cómo funciona `/vengadores <misión>`:** la sesión principal (Nick Fury)
analiza la misión, elige solo los agentes necesarios (no los 6 siempre),
te muestra el **plan de batalla**, espera tu OK, y recién ahí los corre en
secuencia con handoffs (ej: QA encuentra → Dev repara → Security audita →
Documentalista registra).

---

## 7. Backup real: git push del vault

Esto es lo que de verdad te salva. Una sola vez:

```bash
cd ~/ObsidianVault
git add -A
git commit -m "chore: estructura completa (skills + agentes vengadores)"
# crear un repo PRIVADO en GitHub/GitLab y:
git remote add origin <URL-REPO-PRIVADO>
git push -u origin main
```

> ⚠️ El vault puede tener notas con datos sensibles → **repo privado**.
> Revisá que no haya secretos (.env, .p12, tokens) antes del primer push.

De ahí en más, después de cada sesión importante: `git add -A && git
commit && git push`.

---

## 8. Reconstrucción desde cero (PC nueva)

```bash
# 1. Traer el vault
git clone <URL-REPO-PRIVADO> ~/ObsidianVault
cd ~/ObsidianVault
chmod +x usar-skill.sh usar-agente.sh

# 2. Wiring de reglas globales
mkdir -p ~/.claude
#   asegurar que ~/.claude/CLAUDE.md tenga la línea @import del §4
echo '@import(/home/$USER/ObsidianVault/00-Reglas-Globales/CLAUDE-global.md)' # ajustar ruta

# 3. Activar skills
for s in reporte-proyecto fase lucide vengadores hilo \
         depuracion-sistematica brainstorming tdd; do ./usar-skill.sh "$s" --global; done

# 4. Activar agentes
for a in dev-senior ui-ux-designer qa-bug-hunter security-analyst dba documentalista; do
  ./usar-agente.sh "$a" --global
done

# 5. Verificar
ls -l ~/.claude/skills ~/.claude/agents
```

En Claude Code, validá con `/fase`, `/lucide`, `/vengadores`. Listo: tu
estructura completa quedó rearmada.

---

## 9. Cómo extender

- **Proyecto nuevo:** `nuevo-proyecto.sh` (si existe) o copiar
  `02-Plantillas/Plantilla-Proyecto.md`.
- **Skill nueva:** `03-Skills/<nombre>/SKILL.md` (ver Plantilla-Skill) →
  `usar-skill.sh <nombre> --global` → fila en `03-Skills/README.md`.
- **Agente nuevo:** `04-Agentes/<nombre>.md` (ver Plantilla-Agente, ojo
  con el frontmatter `name`/`description`/`model`) → `usar-agente.sh
  <nombre> --global` → fila en `04-Agentes/README.md` y en la tabla de la
  skill `vengadores`.
