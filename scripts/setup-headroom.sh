#!/usr/bin/env bash
# setup-headroom.sh — Integración opcional de headroom con Team Vault.
# Correr DESPUÉS de setup.sh. No modifica el flujo principal.
#
# Uso: ./setup-headroom.sh [--modo proxy|mcp|learn]
# Sin argumento: instala solo headroom-learn (recomendado para empezar)

set -euo pipefail

VAULT="${VAULT_PATH:-$HOME/ObsidianVault}"
MODO="${1:-learn}"
MODO="${MODO#--modo=}"
MODO="${MODO#--}"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info() { echo -e "${GREEN}✔${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC}  $1"; }

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║     Headroom → Team Vault               ║"
echo "╚══════════════════════════════════════════╝"
echo "  Modo: $MODO"
echo ""

# ── Verificar Python ───────────────────────────────────────
if ! command -v python3 &>/dev/null; then
  echo "Python 3 no encontrado. Instálalo primero."; exit 1
fi

# ── Instalar headroom ──────────────────────────────────────
echo "▸ Instalando headroom-ai..."
case "$MODO" in
  learn)  pip install "headroom-ai" --break-system-packages -q ;;
  mcp)    pip install "headroom-ai[mcp]" --break-system-packages -q ;;
  proxy)  pip install "headroom-ai[all]" --break-system-packages -q ;;
  *)      echo "Modo inválido. Usa: learn | mcp | proxy"; exit 1 ;;
esac
info "headroom-ai instalado"

# ── Modo learn — feed automático al vault ─────────────────
if [[ "$MODO" == "learn" || "$MODO" == "proxy" || "$MODO" == "mcp" ]]; then
  SKILL_DIR="$VAULT/03-Skills/headroom-learn"
  if [ ! -d "$SKILL_DIR" ]; then
    mkdir -p "$SKILL_DIR"
    cat > "$SKILL_DIR/SKILL.md" << 'SKILL'
---
description: >
  Ejecuta headroom learn para minar la sesión actual, detectar
  patrones de fallo y escribir correcciones al vault. Activar cuando
  el usuario diga: "aprende de esta sesión", "guarda lo que aprendimos",
  "actualiza las reglas con lo de hoy", o al cerrar una sesión larga
  donde hubo errores o retries. También se puede usar al final de
  cualquier sesión de depuración.
depends_on:
  - team-context
---

# Headroom Learn → Vault

## Instrucciones

1. Ejecutar headroom learn apuntando al proyecto actual:
   ```bash
   headroom learn --output /tmp/headroom-learnings.md
   ```

2. Leer /tmp/headroom-learnings.md (patrones detectados de la sesión).

3. Clasificar cada aprendizaje:
   - Si es una regla que aplica a TODOS los proyectos:
     → Agregar al final de ~/ObsidianVault/00-Reglas-Globales/CLAUDE-global.md
       bajo una sección "## Aprendizajes automáticos (headroom learn)"
   - Si aplica solo a este proyecto:
     → Agregar a 02-Decisiones.md del proyecto con tag [AUTO-headroom]
   - Si es un bug recurrente:
     → Agregar a 03-Bugs-Conocidos.md con el patrón de fallo y la corrección

4. Hacer git commit en el vault con mensaje:
   "headroom learn: {{fecha}} — {{n}} aprendizajes aplicados"

5. Informar al usuario qué se escribió y dónde.

## Nota de seguridad
Revisar los aprendizajes antes de confirmar si alguno toca
configuración de seguridad, credenciales o accesos sensibles.
SKILL
    info "Skill headroom-learn creada en el vault"

    # Instalar symlink global
    DEST="$HOME/.claude/skills/headroom-learn"
    [ ! -e "$DEST" ] && ln -s "$SKILL_DIR" "$DEST" && \
      info "Symlink global: headroom-learn"
  else
    echo "  — skill headroom-learn ya existe"
  fi
fi

# ── Modo MCP — agregar a Claude Code ──────────────────────
if [[ "$MODO" == "mcp" ]]; then
  warn "Modo MCP: agrega headroom como tool, no como proxy."
  warn "No afecta la ventana de contexto (sin cap de 200k)."
  echo ""
  echo "  Para activarlo en Claude Code, ejecuta:"
  echo "  headroom mcp install && claude"
  echo ""
  echo "  Tools disponibles:"
  echo "  - headroom_compress  → comprimir texto grande antes de pasarlo"
  echo "  - headroom_retrieve  → recuperar contenido comprimido"
  echo "  - headroom_stats     → ver ahorros de la sesión"
fi

# ── Modo proxy — alias para uso selectivo ─────────────────
if [[ "$MODO" == "proxy" ]]; then
  warn "Modo proxy: limita el contexto a 200k (conocido en headroom)."
  warn "Úsalo solo en proyectos pequeños o con Hawkeye."
  echo ""

  # Agregar alias al shell del usuario (sin sobrescribir)
  SHELL_RC="$HOME/.bashrc"
  [ -f "$HOME/.zshrc" ] && SHELL_RC="$HOME/.zshrc"

  ALIAS_LINE='alias claude-hr="headroom wrap claude"'
  ALIAS_SAFE='alias claude-hr-safe="ANTHROPIC_BASE_URL=http://localhost:8787 claude"'

  if ! grep -qF "claude-hr" "$SHELL_RC" 2>/dev/null; then
    {
      echo ""
      echo "# Headroom — Team Vault (agregado por setup-headroom.sh)"
      echo "$ALIAS_LINE"
      echo "$ALIAS_SAFE"
    } >> "$SHELL_RC"
    info "Aliases agregados en $SHELL_RC:"
    echo "  claude-hr       → headroom wrap claude (200k ctx, comprimido)"
    echo "  claude-hr-safe  → proxy manual (requiere headroom proxy corriendo)"
  else
    echo "  — alias claude-hr ya existe en $SHELL_RC"
  fi

  echo ""
  echo "  Para iniciar el proxy en background:"
  echo "  headroom proxy --port 8787 &"
fi

# ── Documentar en el vault ────────────────────────────────
HEADROOM_NOTE="$VAULT/00-Reglas-Globales/headroom-config.md"
if [ ! -f "$HEADROOM_NOTE" ]; then
  cat > "$HEADROOM_NOTE" << NOTE
# Headroom — Configuración

Modo instalado: $MODO
Fecha: $(date +%Y-%m-%d)

## Cuándo usar qué

| Situación | Comando |
|-----------|---------|
| Sesión normal (proyectos grandes) | \`claude\` (sin headroom) |
| Aprender de la sesión y actualizar el vault | skill headroom-learn |
| Proyecto pequeño / Hawkeye | \`claude-hr\` (ctx 200k) |
| Comprimir texto puntualmente | MCP tool headroom_compress |

## Limitación conocida

\`headroom wrap claude\` y el proxy limitan el contexto a 200k.
Para proyectos grandes usar \`claude\` directamente.
La skill headroom-learn funciona igual independiente del modo de inicio.

## headroom learn

Mina sesiones fallidas y escribe aprendizajes al vault.
Invocar al cerrar sesiones largas o de depuración.
NOTE
  info "Nota de configuración creada: 00-Reglas-Globales/headroom-config.md"
fi

# ── Git commit ────────────────────────────────────────────
if [ -d "$VAULT/.git" ]; then
  (cd "$VAULT" && git add . && \
   git commit -q -m "Integración headroom — modo $MODO" 2>/dev/null) || true
fi

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║       Headroom integrado ✔              ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "  Modo instalado : $MODO"
echo "  Skill activa   : headroom-learn (global)"
echo ""
echo "  Próximo uso → en Claude Code:"
echo "  'Aprende de esta sesión y actualiza el vault'"
echo ""
