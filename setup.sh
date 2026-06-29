#!/usr/bin/env bash
# =============================================================
# Team Vault — setup.sh
# Instala el sistema Team Vault en tu máquina.
# Uso: ./setup.sh [ruta-vault]
# =============================================================

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT="${1:-$HOME/ObsidianVault}"
CLAUDE_MD="$HOME/.claude/CLAUDE.md"
CLAUDE_SKILLS="$HOME/.claude/skills"
MODE="fresh"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()    { echo -e "${GREEN}✔${NC} $1"; }
warn()    { echo -e "${YELLOW}⚠${NC}  $1"; }
skip()    { echo -e "  — skipped: $1 (ya existe)"; }
section() { echo -e "\n${GREEN}▸ $1${NC}"; }

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║        Team Vault — Setup               ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "  Vault destino : $VAULT"
echo "  Claude config : $HOME/.claude"
echo ""

[ -d "$VAULT" ] && MODE="integration" && \
  warn "Vault ya existe — modo integración (no se sobreescribe nada)." || \
  info "Instalación nueva en $VAULT"

read -rp "  ¿Continuar? [S/n] " CONFIRM
CONFIRM="${CONFIRM:-S}"
[[ "$CONFIRM" =~ ^[Ss]$ ]] || { echo "Cancelado."; exit 0; }

# ── 1. Estructura del vault ────────────────────────────────
section "1 · Estructura del vault"

dirs=(
  "$VAULT/00-Reglas-Globales"
  "$VAULT/01-Proyectos"
  "$VAULT/02-Plantillas"
  "$VAULT/03-Skills"
  "$VAULT/04-Wiki/tech"
  "$VAULT/04-Wiki/patterns"
)
for d in "${dirs[@]}"; do
  [ ! -d "$d" ] && mkdir -p "$d" && info "Creada: $d" || skip "$d"
done

[ ! -f "$VAULT/.gitignore" ] && cat > "$VAULT/.gitignore" <<'EOF'
.obsidian/workspace*.json
.trash/
EOF
info "Creado .gitignore"

# ── 2. Plantillas ──────────────────────────────────────────
section "2 · Plantillas"

for tpl in "$REPO_DIR/templates/"*.md; do
  DEST="$VAULT/02-Plantillas/$(basename "$tpl")"
  [ ! -f "$DEST" ] && cp "$tpl" "$DEST" && info "Plantilla: $(basename "$tpl")" || skip "$(basename "$tpl")"
done

# Plantilla-Wiki
WIKI_TPL="$VAULT/02-Plantillas/Plantilla-Wiki.md"
if [ ! -f "$WIKI_TPL" ]; then
  cat > "$WIKI_TPL" <<'EOF'
---
tags: []
relacionado: []
proyectos: []
---
# {{Concepto}}

## Qué es

## Cómo lo usamos

## Notas relacionadas
- [[concepto-relacionado]]

## Proyectos que lo usan
- [[proyecto]]

## Referencias
EOF
  info "Plantilla: Plantilla-Wiki.md"
fi

# ── 3. Skills en el vault ──────────────────────────────────
section "3 · Skills del vault"

for skill_dir in "$REPO_DIR/skills/"*/; do
  skill_name="$(basename "$skill_dir")"
  DEST="$VAULT/03-Skills/$skill_name"
  [ ! -d "$DEST" ] && cp -r "$skill_dir" "$DEST" && info "Skill: $skill_name" || skip "skill $skill_name"
done

# README de skills
SKILLS_README="$VAULT/03-Skills/README.md"
if [ ! -f "$SKILLS_README" ]; then
  cat > "$SKILLS_README" <<'EOF'
# Librería Team de Skills

| Skill | Descripción | Depende de | Estado |
|-------|-------------|------------|--------|
| team-onboarding | Entrevista de perfil | — | ✅ |
| team-context | Fundacional | — | ✅ |
| reporte-proyecto | Genera reporte final | team-context | ✅ |
| junior-code-review | Revisión para juniors | team-context | ✅ |
| wiki-connect | Conecta proyectos con la wiki | team-context, obsidian-markdown | ✅ |
| auth-setup | Configura autenticación | team-context | ✅ |
| headroom-learn | Mina sesiones → vault | team-context | ✅ |

## Instalar una skill en un proyecto
./usar-skill.sh nombre --proyecto /ruta/repo
./usar-skill.sh nombre --proyecto /ruta --copia
./usar-skill.sh nombre --global
EOF
  info "Creado 03-Skills/README.md"
fi

# ── 4. Wiki inicial ────────────────────────────────────────
section "4 · Wiki — 04-Wiki/"

WIKI_README="$VAULT/04-Wiki/README.md"
if [ ! -f "$WIKI_README" ]; then
  cat > "$WIKI_README" <<'EOF'
---
tags: [wiki, index]
---
# Wiki — Base de conocimiento

Conceptos técnicos y patrones reutilizables entre proyectos.
Cada nota usa [[wikilinks]] que crean el grafo de conocimiento visible
en el Graph View de Obsidian.

## Cómo agregar una nota
1. Copiar 02-Plantillas/Plantilla-Wiki.md a tech/ o patterns/
2. Agregar [[wikilinks]] a conceptos relacionados
3. Desde el proyecto, linkear con [[nombre-del-concepto]]

## Estructura
- **tech/** — conceptos técnicos (JWT, Docker, LDAP, frameworks)
- **patterns/** — patrones reutilizables entre proyectos
EOF
  info "Creado 04-Wiki/README.md"
fi

DASHBOARD="$VAULT/04-Wiki/_dashboard.base"
if [ ! -f "$DASHBOARD" ]; then
  cat > "$DASHBOARD" <<'EOF'
{
  "filters": [],
  "order": [{ "property": "file.mtime", "direction": "desc" }],
  "columns": [
    { "id": "file.name", "width": 280 },
    { "id": "tags", "width": 160 },
    { "id": "relacionado", "width": 200 },
    { "id": "file.mtime", "width": 140 }
  ]
}
EOF
  info "Creado 04-Wiki/_dashboard.base"
fi

# ── 5. Scripts ─────────────────────────────────────────────
section "5 · Scripts"

for script in "$REPO_DIR/scripts/"*.sh; do
  DEST="$VAULT/$(basename "$script")"
  [ ! -f "$DEST" ] && cp "$script" "$DEST" && chmod +x "$DEST" && \
    info "Script: $(basename "$script")" || skip "$(basename "$script")"
done

# ── 6. obsidian-skills de kepano ──────────────────────────
section "6 · obsidian-skills (kepano/obsidian-skills)"

VAULT_CLAUDE="$VAULT/.claude"
VAULT_SKILLS="$VAULT_CLAUDE/skills"

if [ ! -d "$VAULT_SKILLS/obsidian-markdown" ]; then
  if command -v git &>/dev/null; then
    echo "  Clonando kepano/obsidian-skills..."
    git clone -q https://github.com/kepano/obsidian-skills.git /tmp/obsidian-skills-install
    mkdir -p "$VAULT_CLAUDE"
    cp -r /tmp/obsidian-skills-install/.claude/* "$VAULT_CLAUDE/" 2>/dev/null || \
    cp -r /tmp/obsidian-skills-install/skills "$VAULT_SKILLS"
    rm -rf /tmp/obsidian-skills-install
    info "obsidian-skills instaladas en $VAULT_SKILLS"
  else
    warn "git no encontrado — instala obsidian-skills manualmente:"
    warn "git clone https://github.com/kepano/obsidian-skills.git /tmp/os"
    warn "cp -r /tmp/os/.claude/* $VAULT_CLAUDE/"
  fi
else
  skip "obsidian-skills (ya instaladas)"
fi

# ── 7. Puente global ~/.claude/CLAUDE.md ──────────────────
section "7 · Puente ~/.claude/CLAUDE.md"

mkdir -p "$HOME/.claude"
BRIDGE_LINE="@$VAULT/00-Reglas-Globales/CLAUDE-global.md"
BRIDGE_MARKER="# Team Vault"

if [ ! -f "$CLAUDE_MD" ]; then
  printf "%s\n%s\n" "$BRIDGE_MARKER" "$BRIDGE_LINE" > "$CLAUDE_MD"
  info "Creado ~/.claude/CLAUDE.md"
elif grep -qF "$BRIDGE_LINE" "$CLAUDE_MD"; then
  skip "bridge en ~/.claude/CLAUDE.md"
else
  printf "\n%s\n%s\n" "$BRIDGE_MARKER" "$BRIDGE_LINE" >> "$CLAUDE_MD"
  info "Bridge añadido a ~/.claude/CLAUDE.md"
fi

# ── 8. Skills globales (symlinks) ──────────────────────────
section "8 · Skills globales (~/.claude/skills/)"

mkdir -p "$CLAUDE_SKILLS"
for skill_dir in "$VAULT/03-Skills/"*/; do
  [ -f "$skill_dir/SKILL.md" ] || continue
  skill_name="$(basename "$skill_dir")"
  DEST="$CLAUDE_SKILLS/$skill_name"
  [ ! -e "$DEST" ] && ln -s "$skill_dir" "$DEST" && \
    info "Symlink global: $skill_name" || skip "symlink $skill_name"
done

# ── 9. Git del vault ───────────────────────────────────────
section "9 · Git del vault"

if [ ! -d "$VAULT/.git" ]; then
  git -C "$VAULT" init -q
  git -C "$VAULT" add .
  git -C "$VAULT" commit -q -m "Setup inicial — Sistema Team Vault"
  info "Repositorio git inicializado"
else
  (cd "$VAULT" && git add . && \
   git commit -q -m "Team Vault setup — $(date +%Y-%m-%d)" 2>/dev/null) || true
  info "Cambios commiteados"
fi

# ── Resumen ────────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════╗"
echo "║           Setup completado ✔            ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "  Vault          : $VAULT"
echo "  Wiki           : $VAULT/04-Wiki/"
echo "  obsidian-skills: $VAULT/.claude/skills/"
echo "  Skills globales: $CLAUDE_SKILLS"
echo ""
echo "  Próximo paso — abre Claude Code y ejecuta:"
echo "  'Ejecuta la skill team-onboarding'"
echo ""
echo "  Para activar la wiki en un proyecto:"
echo "  'Conecta este proyecto con la wiki y crea"
echo "   notas para los conceptos técnicos que usamos'"
echo ""
