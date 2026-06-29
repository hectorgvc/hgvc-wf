#!/usr/bin/env bash
# nuevo-proyecto.sh — Crea la documentación de un proyecto en el vault
# y conecta el repo de código automáticamente.
#
# Uso: ./nuevo-proyecto.sh "Nombre Proyecto" [ruta-al-repo]

set -euo pipefail

VAULT="${VAULT_PATH:-$HOME/ObsidianVault}"
NOMBRE="${1:?Uso: ./nuevo-proyecto.sh \"Nombre\" [ruta-repo]}"
REPO="${2:-}"
SLUG=$(echo "$NOMBRE" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
DEST="$VAULT/01-Proyectos/$SLUG"
FECHA=$(date +%Y-%m-%d)

[ -d "$DEST" ] && { echo "Ya existe: $DEST"; exit 1; }

mkdir -p "$DEST/04-Bitacora"

# Archivos base desde plantillas
sed "s/{{Nombre del Proyecto}}/$NOMBRE/g" \
  "$VAULT/02-Plantillas/Plantilla-Proyecto.md" > "$DEST/00-Resumen.md"

touch "$DEST/01-Arquitectura.md"

sed "s/{{Proyecto}}/$NOMBRE/g; s/{{fecha}}/$FECHA/g" \
  "$VAULT/02-Plantillas/Plantilla-Decision.md" > "$DEST/02-Decisiones.md"

echo "# Bugs Conocidos — $NOMBRE" > "$DEST/03-Bugs-Conocidos.md"
echo "_Generado por reporte-proyecto. No editar a mano._" \
  > "$DEST/05-Reporte-Final.md"

cat > "$DEST/CLAUDE.md" <<EOF
# Proyecto: $NOMBRE
# Sistema Team Vault — editar las notas referenciadas, no este archivo.

@$DEST/00-Resumen.md
@$DEST/01-Arquitectura.md
@$DEST/02-Decisiones.md
@$DEST/03-Bugs-Conocidos.md
EOF

echo "Proyecto creado: $DEST"

# Conectar repo de código si se pasó una ruta
if [ -n "$REPO" ]; then
  if [ ! -d "$REPO" ]; then
    echo "Aviso: $REPO no existe. Conéctalo manualmente después."
  elif [ -f "$REPO/CLAUDE.md" ]; then
    echo "Aviso: $REPO/CLAUDE.md ya existe."
    echo "Agrega manualmente al final: @$DEST/CLAUDE.md"
  else
    echo "@$DEST/CLAUDE.md" > "$REPO/CLAUDE.md"
    echo "Conectado: $REPO/CLAUDE.md → $DEST/CLAUDE.md"
  fi
fi

# Commit en el vault
if [ -d "$VAULT/.git" ]; then
  (cd "$VAULT" && git add . && git commit -m "Nuevo proyecto: $NOMBRE" -q) || true
fi
