# Prompt de despliegue — Sistema Team Vault
# Pegar completo en Claude Code en una sesión limpia.
# No requiere configuración previa — el onboarding lo define todo.

---

Quiero que construyas un sistema de gestión de proyectos y conocimiento
basado en un vault de Obsidian conectado nativamente a Claude Code.
El sistema se llama "Team" y está diseñado para ser replicable entre
colegas con contextos distintos.

NO hagas preguntas genéricas al inicio. En vez de eso, ejecuta los
pasos en orden. El Paso 0 es el onboarding — ahí se captura todo el
contexto antes de crear nada. Confírmame cada paso antes de aplicarlo.

---

## PASO 0 — Onboarding (antes de crear el vault)

Antes de tocar el sistema de archivos, conduce una entrevista breve
para conocer el contexto de la persona. Hazla una pregunta a la vez,
en conversación natural, no como formulario. Usa las respuestas para
generar el perfil que se usará en los Pasos 2 y 4.

Preguntas obligatorias (adapta el orden según fluya la conversación):

### Bloque 1 · Identidad y contexto
- ¿Cuál es tu nombre?
- ¿A qué te dedicas? (rol, industria, si es trabajo fijo, freelance o ambos)
- ¿Trabajas solo o en equipo? Si es en equipo, ¿qué rol ocupas?

### Bloque 2 · Stack técnico
- ¿Cuáles son los lenguajes de programación que más usas?
- ¿Qué frameworks, bases de datos o herramientas usas regularmente?
- ¿Tienes infraestructura propia? (servidores, VMs, cloud, contenedores)
- ¿Qué sistema operativo usas como entorno de trabajo principal?

### Bloque 3 · Entorno y conectividad
- ¿Cómo te conectas a internet habitualmente? (wifi, hotspot, cable, VPN)
- ¿Tu máquina de trabajo se conecta directamente a redes de clientes
  o la mantienes aislada?
- ¿Trabajas con ambientes sensibles (producción, datos de clientes,
  sistemas de gobierno, salud, financiero)?

### Bloque 4 · Preferencias con Claude
- ¿En qué idioma prefieres que Claude te responda?
- ¿Prefieres que Claude confirme cada acción antes de ejecutar, o que
  actúe y te informe después?
- ¿Qué tan detalladas quieres las respuestas? (conciso vs explicado)
- ¿Quieres que Claude proponga una nota de sesión al cerrar cada
  sesión de trabajo?

### Bloque 5 · Seguridad y reglas
- ¿Hay algo que NUNCA debe aparecer en un commit o en el vault?
  (tokens, IPs, credenciales, nombres de clientes)
- ¿Tienes alguna convención de commits que ya usas?
- ¿Hay ambientes o sistemas donde Claude debe pedir confirmación
  explícita antes de ejecutar cualquier comando?

Al terminar la entrevista, muestra un resumen del perfil generado y
pide confirmación antes de seguir al Paso 1.

---

## PASO 1 — Estructura del vault

Pregunta la ruta del vault (default: ~/ObsidianVault).
Si ya existe una carpeta de Obsidian activa, usar esa.

Crea esta estructura:

    ~/ObsidianVault/
    ├── 00-Reglas-Globales/
    │   ├── CLAUDE-global.md
    │   └── mi-perfil.md          ← respuestas del onboarding en bruto
    ├── 01-Proyectos/
    ├── 02-Plantillas/
    │   ├── Plantilla-Proyecto.md
    │   ├── Plantilla-Sesion.md
    │   ├── Plantilla-Decision.md
    │   └── Plantilla-Skill.md
    ├── 03-Skills/
    │   ├── README.md
    │   ├── team-onboarding/
    │   │   └── SKILL.md
    │   ├── team-context/
    │   │   └── SKILL.md
    │   └── reporte-proyecto/
    │       └── SKILL.md
    └── .gitignore

`.gitignore`:
```
.obsidian/workspace*.json
.trash/
```

---

## PASO 2 — Perfil del onboarding

**00-Reglas-Globales/mi-perfil.md** — guarda las respuestas del
onboarding en formato estructurado. Este archivo es la fuente de
verdad personal; si algo cambia, se edita aquí y CLAUDE-global.md
se regenera.

```markdown
# Mi Perfil — {{nombre}}
_Generado por team-onboarding. Editar este archivo y pedir
"actualiza mi CLAUDE-global.md" para regenerar las reglas._

## Identidad
- Nombre: {{nombre}}
- Rol: {{rol}}
- Modalidad: {{freelance / empresa / ambos}}
- Trabajo en equipo: {{sí/no — detalle}}

## Stack técnico
- Lenguajes: {{lista}}
- Frameworks / herramientas: {{lista}}
- Infraestructura: {{lista}}
- SO de trabajo: {{SO}}

## Entorno y conectividad
- Conexión habitual: {{hotspot / wifi / cable / VPN}}
- Aislamiento de red: {{descripción}}
- Ambientes sensibles: {{lista o "ninguno"}}

## Preferencias con Claude
- Idioma: {{idioma}}
- Confirmación antes de ejecutar: {{sí / no / solo en producción}}
- Nivel de detalle: {{conciso / normal / explicado}}
- Nota de sesión automática: {{sí / no}}

## Seguridad
- Nunca en commits/vault: {{lista}}
- Convención de commits: {{formato o "ninguna definida"}}
- Confirmación explícita requerida en: {{ambientes / "ninguno"}}
```

Llena este archivo con las respuestas del onboarding.

---

## PASO 3 — Reglas globales (CLAUDE-global.md)

Genera **00-Reglas-Globales/CLAUDE-global.md** usando la información
de mi-perfil.md. Estructura obligatoria:

```markdown
# Reglas Globales — {{nombre}}
_Generado desde mi-perfil.md. Para actualizar, edita mi-perfil.md
y pide "actualiza mi CLAUDE-global.md"._

## Contexto
{{párrafo resumiendo rol, modalidad, stack, entorno}}

## Comunicación
- Idioma: {{idioma}}
- Tono: {{conciso/normal/explicado}}
- {{otras preferencias}}

## Estándares de código
{{convenciones de commits, formato, lo que aplique del perfil}}

## Seguridad
{{reglas de seguridad del perfil, incluyendo aislamiento de red
y ambientes sensibles}}

## Flujo de trabajo
- Confirmación antes de ejecutar: {{sí/no/condición}}
- Nota de sesión al cerrar: {{sí/no}}
- {{otras reglas del flujo}}

## Regla de vault (CRÍTICA — no modificar)

Cada vez que Claude Code se inicie en un directorio sin CLAUDE.md,
o que el usuario diga "iniciar proyecto" o "conectar al vault":

1. Verificar si existe ~/ObsidianVault/01-Proyectos/<nombre-slug>/.
2. Si no existe, ofrecer crearlo con nuevo-proyecto.sh antes de
   hacer cualquier otra cosa.
3. Crear (o actualizar) el CLAUDE.md del directorio actual con
   una sola línea: @~/ObsidianVault/01-Proyectos/<slug>/CLAUDE.md
4. NUNCA duplicar documentación dentro del repo — todo va al vault.
5. Al iniciar sesión en un proyecto ya conectado, leer el CLAUDE.md
   del vault antes de cualquier acción.
6. Si el usuario pide un reporte, resumen o "¿en qué quedamos?",
   activar la skill reporte-proyecto automáticamente.
```

---

## PASO 4 — Plantillas

**Plantilla-Proyecto.md**
```markdown
# {{Nombre del Proyecto}}

## Resumen
Qué es, para quién, por qué existe.

## Stack
Lenguajes, frameworks, infraestructura específica de este proyecto.

## Estado actual
(actualizar en cada sesión relevante)

## Skills activas
| Skill | Para qué se usa aquí |
|-------|----------------------|
| reporte-proyecto | Genera 05-Reporte-Final.md |

## Referencias
- Arquitectura: [[01-Arquitectura]]
- Decisiones: [[02-Decisiones]]
- Bugs conocidos: [[03-Bugs-Conocidos]]
- Bitácora: [[04-Bitacora/]]
- Reporte final: [[05-Reporte-Final]]
```

**Plantilla-Sesion.md**
```markdown
# Sesión {{fecha}}

## Objetivo

## Qué se hizo

## Decisiones tomadas
(si aplica, agregar también a 02-Decisiones.md)

## Pendientes / próximos pasos

## Bloqueadores
```

**Plantilla-Decision.md**
```markdown
# Decisiones — {{Proyecto}}

> Formato ADR. No se borran entradas — solo se agregan al final.

---

## {{fecha}} — {{Título}}

**Contexto:**

**Decisión:**

**Alternativas consideradas:**

**Consecuencias:**

---
```

**Plantilla-Skill.md**
```markdown
---
description: >
  {{Cuándo exactamente se activa esta skill: palabras clave,
  contexto, dependencias. Sé específico — descripción vaga = skill
  que no se dispara.}}
depends_on:
  - team-context
---

# {{Nombre de la Skill}}

## Instrucciones
1.

## Dependencias de archivos
- Lee: ...
- Escribe/actualiza: ...

## Ejemplos de invocación
- "..."
```

---

## PASO 5 — Skills del vault

### 03-Skills/team-onboarding/SKILL.md
```markdown
---
description: >
  Conduce la entrevista de onboarding para un usuario nuevo del
  sistema Team. Activar cuando alguien instale el vault por primera
  vez, o cuando diga: "quiero reconfigurar mi perfil", "actualiza
  mi contexto", "cambié de trabajo", "tengo un stack nuevo".
  Genera mi-perfil.md y CLAUDE-global.md desde las respuestas.
depends_on: []
---

# Team Onboarding

## Instrucciones

1. Explicar brevemente al usuario qué va a pasar: una entrevista
   corta para definir su perfil. Las respuestas se guardan en
   mi-perfil.md y generan CLAUDE-global.md.

2. Hacer las preguntas por bloques, una a la vez, en conversación
   natural — no como formulario. Los bloques son:
   - Bloque 1: Identidad y contexto
   - Bloque 2: Stack técnico
   - Bloque 3: Entorno y conectividad
   - Bloque 4: Preferencias con Claude
   - Bloque 5: Seguridad y reglas

3. Al terminar, mostrar un resumen del perfil y pedir confirmación.

4. Si el usuario confirma:
   a. Escribir/sobreescribir mi-perfil.md con las respuestas.
   b. Generar/regenerar CLAUDE-global.md desde mi-perfil.md.
   c. Informar que el perfil está activo y que puede decir
      "actualiza mi perfil" en cualquier momento para repetir
      el proceso.

5. No inventar respuestas. Si una pregunta no aplica, marcarlo
   en mi-perfil.md como "N/A — {{razón}}" en vez de dejarlo vacío.
```

### 03-Skills/team-context/SKILL.md
```markdown
---
description: >
  Skill fundacional del sistema Team. Se carga al inicio de cualquier
  sesión en un proyecto conectado al vault. Todas las demás skills la
  leen antes de ejecutar. No invocar directamente.
depends_on: []
---

# Team Context

Lee y aplica antes de cualquier acción en un proyecto:
@~/ObsidianVault/00-Reglas-Globales/CLAUDE-global.md

## Regla de composición

Toda skill nueva en 03-Skills/ debe:
1. Declarar depends_on: [team-context] en su frontmatter.
2. Leer CLAUDE-global.md antes de ejecutar cualquier paso.
```

### 03-Skills/reporte-proyecto/SKILL.md
```markdown
---
description: >
  Genera o actualiza el reporte final de un proyecto del vault.
  Activar cuando el usuario diga: "reporte final", "dame el resumen
  del proyecto", "contexto total", "¿en qué quedamos?",
  "actualiza el reporte" o "cierra esta fase".
depends_on:
  - team-context
---

# Reporte de Proyecto

## Instrucciones

1. Leer team-context (CLAUDE-global.md).
2. Localizar la carpeta del proyecto en ~/ObsidianVault/01-Proyectos/.
   Si hay ambigüedad, preguntar.
3. Leer en orden: 00-Resumen.md, 01-Arquitectura.md,
   02-Decisiones.md, 03-Bugs-Conocidos.md.
4. Leer todas las notas en 04-Bitacora/ en orden cronológico.
5. Escribir 05-Reporte-Final.md:
   - Resumen ejecutivo (2-3 párrafos)
   - Arquitectura actual
   - Decisiones clave (top 3-5, no todas)
   - Problemas conocidos / deuda técnica
   - Estado actual y próximos pasos
6. No inventar nada que no esté en las notas.
   Marcar [FALTA CONTEXTO] donde falte información.
7. Sobrescribir completo — es un snapshot, no un log acumulativo.
```

### 03-Skills/README.md
```markdown
# Librería Team de Skills

| Skill | Descripción | Depende de | Estado |
|-------|-------------|------------|--------|
| team-onboarding | Entrevista de perfil — genera mi-perfil.md y CLAUDE-global.md | — | ✅ |
| team-context | Fundacional — todas las demás la leen | — | ✅ |
| reporte-proyecto | Genera 05-Reporte-Final.md desde la bitácora | team-context | ✅ |

## Agregar una skill nueva
1. Copiar Plantilla-Skill.md a 03-Skills/nombre-skill/SKILL.md
2. Llenar description con precisión (esto es lo que la dispara)
3. Declarar depends_on: [team-context]
4. Agregar fila a esta tabla
5. git commit en el vault

## Instalar una skill en un proyecto
```bash
# Enlace (edición centralizada desde el vault):
./usar-skill.sh nombre-skill --proyecto /ruta/repo

# Copia (repo independiente, para compartir con otros):
./usar-skill.sh nombre-skill --proyecto /ruta/repo --copia

# Global (disponible en todos tus proyectos):
./usar-skill.sh nombre-skill --global
```
```

---

## PASO 6 — Puente global con Claude Code

Verificar si existe `~/.claude/CLAUDE.md`.
Si no existe, crearlo. Si ya existe, agregar al final sin sobrescribir:

```
# Team Vault
@~/ObsidianVault/00-Reglas-Globales/CLAUDE-global.md
```

---

## PASO 7 — Scripts de automatización

### nuevo-proyecto.sh
```bash
#!/usr/bin/env bash
# Crea la documentación de un proyecto en el vault
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
# Sistema Team Vault — editar notas referenciadas, no este archivo.

@$DEST/00-Resumen.md
@$DEST/01-Arquitectura.md
@$DEST/02-Decisiones.md
@$DEST/03-Bugs-Conocidos.md
EOF

echo "Proyecto creado: $DEST"

if [ -n "$REPO" ]; then
  if [ ! -d "$REPO" ]; then
    echo "Aviso: $REPO no existe. Conéctalo manualmente luego."
  elif [ -f "$REPO/CLAUDE.md" ]; then
    echo "Aviso: $REPO/CLAUDE.md ya existe."
    echo "Agrega manualmente al final: @$DEST/CLAUDE.md"
  else
    echo "@$DEST/CLAUDE.md" > "$REPO/CLAUDE.md"
    echo "Conectado: $REPO/CLAUDE.md → $DEST/CLAUDE.md"
  fi
fi

if [ -d "$VAULT/.git" ]; then
  (cd "$VAULT" && git add . && git commit -m "Nuevo proyecto: $NOMBRE" -q) || true
fi
```

### usar-skill.sh
```bash
#!/usr/bin/env bash
# Instala una skill del vault en un proyecto o globalmente.
#
# Uso:
#   ./usar-skill.sh nombre-skill --global
#   ./usar-skill.sh nombre-skill --proyecto /ruta [--copia]

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
```

Da permisos de ejecución:
```bash
chmod +x ~/ObsidianVault/nuevo-proyecto.sh
chmod +x ~/ObsidianVault/usar-skill.sh
```

Instala las skills base como globales:
```bash
cd ~/ObsidianVault
./usar-skill.sh team-context --global
./usar-skill.sh reporte-proyecto --global
./usar-skill.sh team-onboarding --global
```

---

## PASO 8 — Git

```bash
cd ~/ObsidianVault
git init
git add .
git commit -m "Setup inicial — Sistema Team Vault"
```

---

## VERIFICACIÓN FINAL

Al terminar, confirma que:

- [ ] mi-perfil.md está lleno con las respuestas del onboarding
- [ ] CLAUDE-global.md fue generado desde mi-perfil.md
- [ ] ~/.claude/CLAUDE.md importa CLAUDE-global.md
- [ ] Las 3 skills base están instaladas globalmente
- [ ] nuevo-proyecto.sh y usar-skill.sh tienen permisos de ejecución
- [ ] El vault tiene su primer commit git

Muéstrame el árbol de ~/ObsidianVault y el contenido de
~/.claude/CLAUDE.md para confirmar.
