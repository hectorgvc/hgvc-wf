#!/usr/bin/env bash
# usar-skill.sh — Instala una skill del vault en un proyecto o globalmente.
#
# Uso:
#   ./usar-skill.sh nombre-skill --global
#   ./usar-skill.sh nombre-skill --proyecto /ruta/repo [--copia]

set -euo pipefail

VAULT="${VAULT_PATH:-$HOME/ObsidianVault}"
NOMBRE="${1:?Uso: ./usar-skill.sh nombre-skill [--global|--proyecto <ruta>] [--copia]}"
shift

ORIGEN="$VAULT/03-Skills/$NOMBRE"
MODO="" DESTINO_REPO="" COPIA=false

[ ! -d "$ORIGEN" ] && { echo "No existe: $VAULT/03-Skills/$NOMBRE"; exit 1; }

while [ $# -gt 0 ]; do
  case "$1" in
    --global)   MODO="global" ;;
    --proyecto) MODO="proyecto"; DESTINO_REPO="$2"; shift ;;
    --copia)    COPIA=true ;;
  esac; shift
done

if [ "$MODO" = "global" ]; then
  mkdir -p "$HOME/.claude/skills"
  DESTINO="$HOME/.claude/skills/$NOMBRE"
elif [ "$MODO" = "proyecto" ]; then
  [ -z "$DESTINO_REPO" ] || [ ! -d "$DESTINO_REPO" ] && \
    { echo "Ruta inválida: $DESTINO_REPO"; exit 1; }
  mkdir -p "$DESTINO_REPO/.claude/skills"
  DESTINO="$DESTINO_REPO/.claude/skills/$NOMBRE"
else
  echo "Indica --global o --proyecto <ruta>"; exit 1
fi

[ -e "$DESTINO" ] && { echo "Ya existe en $DESTINO. No sobreescribo."; exit 1; }

if [ "$COPIA" = true ]; then
  cp -r "$ORIGEN" "$DESTINO" && echo "Copiada: $DESTINO"
else
  ln -s "$ORIGEN" "$DESTINO" && echo "Symlink: $DESTINO → $ORIGEN"
fi
