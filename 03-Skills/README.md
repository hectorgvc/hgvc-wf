# Skills

Skills personalizadas que viven en el vault y se activan con symlink
o copia desde `~/.claude/skills/` o desde `<repo>/.claude/skills/`.

## Índice

| Skill | Cuándo se activa | Ubicación real |
|-------|------------------|----------------|
| `reporte-proyecto` | El usuario pide un reporte / status / cierre de un proyecto del vault. | [[reporte-proyecto/SKILL.md]] |
| `fase` | Al iniciar una fase/tarea: recomienda modelo (Sonnet u Opus). | [[fase/SKILL.md]] |
| `lucide` | Al generar/editar UI: referencia de iconos Lucide (nunca emojis). | [[lucide/SKILL.md]] |
| `vengadores` | Convoca al equipo de agentes para una misión autónoma. | [[vengadores/SKILL.md]] |
| `hilo` | Evalúa si conviene cerrar el hilo e iniciar uno nuevo (tokens/contexto). | [[hilo/SKILL.md]] |
| `depuracion-sistematica` | Debug por causa raíz en 4 fases (adaptada de Superpowers). | [[depuracion-sistematica/SKILL.md]] |
| `brainstorming` | Idea → diseño por método socrático (adaptada de Superpowers). | [[brainstorming/SKILL.md]] |
| `tdd` | Ciclo RED-GREEN-REFACTOR, el test primero (adaptada de Superpowers). | [[tdd/SKILL.md]] |

## Agregar una skill nueva

1. Crear la carpeta `03-Skills/<nombre>/SKILL.md` siguiendo
   [[../02-Plantillas/Plantilla-Skill.md]].
2. Activarla con:
   - `~/ObsidianVault/usar-skill.sh <nombre> --global` (symlink en
     `~/.claude/skills/`, disponible en todos los proyectos).
   - `~/ObsidianVault/usar-skill.sh <nombre> --proyecto <repo>`
     (symlink en `<repo>/.claude/skills/`, solo para ese repo).
   - Con `--copia` en lugar de symlink, si el repo va a ser usado por
     alguien más sin acceso al vault.
3. Agregar fila a la tabla de arriba.
