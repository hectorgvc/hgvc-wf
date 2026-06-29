# Prompt de integración — vault existente
# Usar cuando el vault ya existe y solo se quieren agregar piezas nuevas.
# Pegar en Claude Code en cualquier directorio.

Quiero integrar nuevas piezas al sistema Team Vault que ya tengo.
NO sobrescribas nada que ya exista. Antes de modificar cualquier
archivo, léelo y dime qué encontraste.

PASO 0 — Auditoría previa (obligatorio antes de tocar nada)

Lee y dime el contenido actual de:
1. ~/.claude/CLAUDE.md
2. ~/ObsidianVault/00-Reglas-Globales/CLAUDE-global.md
3. ~/ObsidianVault/03-Skills/ (árbol, no contenido)
4. Scripts existentes en ~/ObsidianVault/ (*.sh)

Con eso dime:
- Qué de lo nuevo ya existe (no tocar)
- Qué falta y propones agregar
- Si hay algún conflicto

Espera mi confirmación antes de cualquier cambio.

PASO 1 — Solo agregar lo que falta

Una vez confirme, agrega únicamente lo que no existe:
a) Skills faltantes en ~/ObsidianVault/03-Skills/
b) Flags faltantes en scripts existentes (ej. --copia en usar-skill.sh)
c) Líneas faltantes en ~/.claude/CLAUDE.md — solo al FINAL
d) Sección "Regla de vault" en CLAUDE-global.md — solo si no existe

PASO 2 — Instalar skills nuevas globalmente

Solo las que se agregaron en el Paso 1.

PASO 3 — Verificación

Muéstrame el árbol final de ~/ObsidianVault/03-Skills/ y
~/.claude/skills/, y confirma que nada de lo previo fue modificado.
