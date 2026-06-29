# Team Vault — hgvc-wf/code-team

Sistema plug-and-play de gestión de proyectos y contexto para Claude Code,
basado en un vault de Obsidian como única fuente de verdad.

## Instalación rápida

```bash
git clone git@github.com:hectorgvc/hgvc-wf.git
cd hgvc-wf/code-team
chmod +x setup.sh
./setup.sh
```

El script pregunta si continuar, crea el vault, instala skills y
conecta Claude Code. Al terminar te indica el siguiente paso.

**Ruta de vault personalizada:**
```bash
./setup.sh ~/MiVaultPersonal
```

**Si ya tienes un vault y solo quieres agregar piezas nuevas:**
Abre Claude Code y pega el contenido de `prompts/prompt-integracion.md`.

---

## Qué hace el setup

1. Crea la estructura del vault (`~/ObsidianVault/` por defecto)
2. Copia las plantillas y skills al vault
3. Copia los scripts `nuevo-proyecto.sh` y `usar-skill.sh`
4. Agrega el bridge en `~/.claude/CLAUDE.md` (sin sobrescribir)
5. Instala las skills como symlinks globales en `~/.claude/skills/`
6. Inicializa el vault como repositorio git

---

## Primer paso después del setup

Abre Claude Code en cualquier directorio y escribe:

```
Ejecuta la skill team-onboarding para configurar mi perfil personal.
```

La skill te hace una entrevista en 5 bloques y genera tu `CLAUDE-global.md`
automáticamente. Ese archivo define cómo Claude Code se comporta contigo
en todos tus proyectos.

---

## Estructura del vault resultante

```
~/ObsidianVault/
├── 00-Reglas-Globales/
│   ├── CLAUDE-global.md     ← generado por team-onboarding
│   └── mi-perfil.md         ← respuestas del onboarding
├── 01-Proyectos/            ← un folder por proyecto
├── 02-Plantillas/           ← plantillas de proyecto, sesión, decisión, skill
├── 03-Skills/               ← tu librería de skills
│   ├── team-onboarding/
│   ├── team-context/
│   ├── reporte-proyecto/
│   └── junior-code-review/
├── nuevo-proyecto.sh
└── usar-skill.sh
```

---

## Uso diario

**Proyecto nuevo:**
```bash
cd ~/ObsidianVault
./nuevo-proyecto.sh "Nombre del Proyecto" [/ruta/al/repo]
```

**Reportar estado de un proyecto:**
```
¿en qué quedamos con el proyecto X?
```
La skill `reporte-proyecto` lee la bitácora y genera el reporte.

**Agregar una skill al vault:**
```bash
# Copiar la plantilla
cp 02-Plantillas/Plantilla-Skill.md 03-Skills/mi-skill/SKILL.md
# Editar SKILL.md en Obsidian
# Instalar globalmente
./usar-skill.sh mi-skill --global
```

**Instalar una skill en un proyecto específico:**
```bash
./usar-skill.sh nombre-skill --proyecto /ruta/repo
# O como copia independiente (para repos de equipo):
./usar-skill.sh nombre-skill --proyecto /ruta/repo --copia
```

---

## Incorporar un junior al equipo

Después de que el junior haga el setup, abre Claude Code en su
directorio de trabajo y pega el contenido de:

```
prompts/prompt-hawkeye.md
```

Reemplaza "Hawkeye" por el nombre real del junior si quieres.

---

## Prompts de referencia

| Archivo | Cuándo usarlo |
|---------|---------------|
| `prompts/prompt-team-vault.md` | Setup manual completo via Claude Code (alternativa a setup.sh) |
| `prompts/prompt-hawkeye.md` | Incorporar un dev junior |
| `prompts/prompt-integracion.md` | Agregar piezas a un vault existente sin romper nada |

---

## Requisitos

| Herramienta | Versión | Necesario para |
|-------------|---------|----------------|
| Node.js | 18+ | Claude Code |
| Claude Code | última | `npm install -g @anthropic-ai/claude-code` |
| Obsidian | cualquiera | Editor del vault (opcional pero recomendado) |
| Git | cualquiera | Versionar el vault |
| Python 3 | 3.8+ | Skills que usen scripts Python (opcional) |
| bash | 3.2+ | Scripts del vault |

---

## Compatibilidad

- macOS, Linux, WSL2
- Windows nativo: los symlinks requieren modo desarrollador activo.
  Usar `--copia` en `usar-skill.sh` como alternativa.

---

## Opcional: integración con headroom (compresión de tokens)

[headroom](https://github.com/headroomlabs-ai/headroom) comprime tool outputs,
logs y archivos antes de que lleguen al LLM. La pieza más útil para el vault
es `headroom learn`, que mina sesiones fallidas y escribe los aprendizajes
directamente en el vault.

```bash
# Instalar solo el modo learn (recomendado para empezar)
cd hgvc-wf/code-team
./scripts/setup-headroom.sh --learn

# O con MCP (comprimir puntualmente, sin afectar contexto)
./scripts/setup-headroom.sh --mcp
```

**⚠️ No usar `headroom wrap claude` como launcher por defecto** — limita el
contexto a 200k en vez de 1M (limitación conocida del proxy con Claude Code).
Úsalo solo para proyectos pequeños o sesiones de Hawkeye donde el ahorro de
tokens vale más que la ventana grande.

| Modo | Cuándo |
|------|--------|
| `claude` (sin headroom) | Proyectos grandes, trabajo normal |
| `headroom learn` (skill) | Al cerrar sesiones largas o de depuración |
| `claude-hr` alias | Proyectos pequeños / Hawkeye |
| MCP `headroom_compress` | Comprimir texto puntualmente |

