#!/usr/bin/env bash
# nuevo-proyecto.sh
# Crea la estructura de un proyecto nuevo dentro del vault de Obsidian,
# a partir de las plantillas, y opcionalmente deja el repo de código
# apuntando al CLAUDE.md del vault.
#
# Uso:
#   nuevo-proyecto.sh <nombre> [ruta-repo]
#
# Ejemplos:
#   nuevo-proyecto.sh demo-app
#   nuevo-proyecto.sh demo-app ~/code/demo-app

set -euo pipefail

VAULT="${VAULT:-$HOME/ObsidianVault}"

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Uso: $0 <nombre> [ruta-repo]" >&2
  exit 2
fi

nombre="$1"
ruta_repo="${2:-}"

# Validar nombre: solo letras, dígitos, guion y guion bajo.
if [[ ! "$nombre" =~ ^[a-zA-Z0-9_-]+$ ]]; then
  echo "Error: el nombre '$nombre' solo puede tener letras, dígitos, '-' y '_'." >&2
  exit 2
fi

proy="$VAULT/01-Proyectos/$nombre"

if [[ -e "$proy" ]]; then
  echo "Error: ya existe '$proy'. No sobrescribo." >&2
  exit 1
fi

if [[ ! -d "$VAULT/02-Plantillas" ]]; then
  echo "Error: no encuentro el vault en '$VAULT'. Definí VAULT o usá la ruta por defecto." >&2
  exit 1
fi

# --- Crear carpetas del proyecto ---
mkdir -p "$proy/Arquitectura" \
         "$proy/Decisiones" \
         "$proy/Bugs" \
         "$proy/Bitacora/Sesiones"

# --- 00-Proyecto.md desde la plantilla, sustituyendo {{nombre}} ---
fecha="$(date +%Y-%m-%d)"
tmp="$(mktemp)"
sed -e "s/{{nombre}}/$nombre/g" \
    -e "s/{{fecha}}/$fecha/g" \
    "$VAULT/02-Plantillas/Plantilla-Proyecto.md" > "$tmp"
mv "$tmp" "$proy/00-Proyecto.md"

# --- ADR y sesión de ejemplo, para que la estructura sea visible ---
tmp="$(mktemp)"
sed -e "s/{{nombre}}/$nombre/g" \
    -e "s/{{fecha}}/$fecha/g" \
    "$VAULT/02-Plantillas/Plantilla-Decision.md" \
    | awk 'BEGIN{count=0} /^## Entradas$/{count++; print; print ""; print "### ADR-0001: ejemplo de decisión"; print ""; print "- **Fecha**: '"$fecha"'"; print "- **Estado**: Aceptada"; print "- **Contexto**: placeholders hasta que se cree la primera ADR real."; print "- **Decisión**: placeholder — reemplazar al registrar la primera decisión real."; print "- **Alternativas consideradas**: (ninguna por ahora)."; print "- **Consecuencias**: (ninguna por ahora)."; next} {print}' \
    > "$tmp"
mv "$tmp" "$proy/Decisiones/0001-ejemplo.md"

tmp="$(mktemp)"
sed -e "s/{{nombre}}/$nombre/g" \
    -e "s/{{fecha}}/$fecha/g" \
    "$VAULT/02-Plantillas/Plantilla-Sesion.md" \
    > "$tmp"
mv "$tmp" "$proy/Bitacora/Sesiones/${fecha}-ejemplo.md"

# --- CLAUDE.md del proyecto en el vault, con @imports a cada nota ---
cat > "$proy/CLAUDE.md" <<EOF
# ${nombre}

> Este es el \`CLAUDE.md\` del proyecto dentro del vault. Si estás
> trabajando en el repo de código y querés que Claude lea todo esto,
> importá este archivo desde \`<repo>/.claude/CLAUDE.md\`.

@import($proy/00-Proyecto.md)
@import($proy/Arquitectura/)
@import($proy/Decisiones/)
@import($proy/Bugs/)
@import($proy/Bitacora/Sesiones/)
@import($proy/05-Reporte-Final.md)
EOF

echo "Proyecto creado: $proy"

# --- Opcional: CLAUDE.md en el repo de código, de una sola línea ---
if [[ -n "$ruta_repo" ]]; then
  mkdir -p "$ruta_repo/.claude"
  repo_claude="$ruta_repo/.claude/CLAUDE.md"

  if [[ -e "$repo_claude" ]]; then
    echo "Aviso: ya existe '$repo_claude'. No lo sobrescribo." >&2
  else
    cat > "$repo_claude" <<EOF
@import($proy/CLAUDE.md)
EOF
    echo "Creado: $repo_claude (importa $proy/CLAUDE.md)"
  fi
fi
