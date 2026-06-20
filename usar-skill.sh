#!/usr/bin/env bash
# usar-skill.sh
# Activa una skill del vault en el destino elegido.
#
# Uso:
#   usar-skill.sh <nombre-skill> --global [--copia]
#   usar-skill.sh <nombre-skill> --proyecto <ruta-repo> [--copia]
#
# Sin --copia: crea un symlink (ediciones en el vault se reflejan de
# inmediato). Con --copia: copia la carpeta entera (útil cuando el
# repo va a ser usado por otra persona sin acceso al vault).
#
# Nunca sobrescribe el destino.

set -euo pipefail

VAULT="${VAULT:-$HOME/ObsidianVault}"

# Requiere al menos <nombre> + un modo.
if [[ $# -lt 2 ]]; then
  echo "Uso:" >&2
  echo "  $0 <nombre-skill> --global [--copia]" >&2
  echo "  $0 <nombre-skill> --proyecto <ruta-repo> [--copia]" >&2
  exit 2
fi

nombre="$1"
shift

# Parsear el modo y sus argumentos. --global y --proyecto son
# mutuamente excluyentes; --copia es opcional en ambos casos.
modo=""
ruta_repo=""
copiar="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --global)
      if [[ -n "$modo" ]]; then
        echo "Error: usá solo un modo (--global o --proyecto)." >&2
        exit 2
      fi
      modo="--global"
      shift
      ;;
    --proyecto)
      if [[ -n "$modo" ]]; then
        echo "Error: usá solo un modo (--global o --proyecto)." >&2
        exit 2
      fi
      modo="--proyecto"
      if [[ $# -lt 2 ]]; then
        echo "Error: --proyecto requiere una ruta como argumento." >&2
        exit 2
      fi
      ruta_repo="$2"
      shift 2
      ;;
    --copia)
      copiar="true"
      shift
      ;;
    -h|--help)
      echo "Uso:" >&2
      echo "  $0 <nombre-skill> --global [--copia]" >&2
      echo "  $0 <nombre-skill> --proyecto <ruta-repo> [--copia]" >&2
      exit 0
      ;;
    *)
      echo "Error: argumento desconocido '$1'." >&2
      exit 2
      ;;
  esac
done

if [[ -z "$modo" ]]; then
  echo "Error: falta el modo. Usá --global o --proyecto <ruta-repo>." >&2
  exit 2
fi

# Validar nombre: igual que en nuevo-proyecto.sh.
if [[ ! "$nombre" =~ ^[a-zA-Z0-9_-]+$ ]]; then
  echo "Error: nombre de skill '$nombre' inválido." >&2
  exit 2
fi

src="$VAULT/03-Skills/$nombre"
if [[ ! -d "$src" ]]; then
  echo "Error: no existe la skill '$src'." >&2
  exit 1
fi

case "$modo" in
  --global)
    dest="$HOME/.claude/skills/$nombre"
    ;;
  --proyecto)
    dest="$ruta_repo/.claude/skills/$nombre"
    mkdir -p "$ruta_repo/.claude/skills"
    ;;
esac

if [[ -e "$dest" || -L "$dest" ]]; then
  echo "Error: ya existe '$dest'. No sobrescribo." >&2
  exit 1
fi

mkdir -p "$(dirname "$dest")"

if [[ "$copiar" == "true" ]]; then
  cp -r "$src" "$dest"
  echo "Copiada skill '$nombre' en $dest"
else
  ln -s "$src" "$dest"
  echo "Symlink $dest -> $src"
fi

echo "Listo. Para usarla en Claude Code: /${nombre}"
