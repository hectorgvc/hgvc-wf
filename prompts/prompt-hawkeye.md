# Prompt de incorporación — Hawkeye (dev junior)
# Pegar en Claude Code en el directorio del repo donde va a trabajar.
# Prerequisito: el vault Team ya debe estar desplegado en ~/ObsidianVault.

---

Quiero incorporar a un desarrollador junior al sistema Team Vault.
El desarrollador se llama Hawkeye. Necesito que configures su entorno
de trabajo con restricciones y guías apropiadas para alguien que está
aprendiendo.

Antes de hacer nada, confirma que existe ~/ObsidianVault y que
~/.claude/CLAUDE.md ya importa CLAUDE-global.md del vault.
Si no existe, dime — el vault Team debe estar desplegado primero.

Ejecuta los pasos en orden y confírmame cada uno antes de aplicarlo.

---

## PASO 0 — Onboarding de Hawkeye

Conduce la entrevista de onboarding igual que con cualquier usuario
del sistema Team, pero con estas preguntas adicionales específicas
para un junior:

### Bloque extra · Contexto de aprendizaje
- ¿Con qué lenguajes o tecnologías tienes experiencia básica?
- ¿Hay algo en el stack del equipo que nunca hayas tocado?
- ¿Qué tipo de tareas esperas hacer? (frontend, backend, scripts,
  infra, testing, todo un poco)
- ¿Prefieres que Claude te explique el por qué de cada paso, o solo
  que te diga qué hacer?
- ¿Quieres que Claude te avise cuando estás a punto de hacer algo
  que podría tener impacto en otros? (recomendado: siempre)

Guarda las respuestas en:
~/ObsidianVault/01-Proyectos/hawkeye-onboarding/mi-perfil.md

(Crea el proyecto hawkeye-onboarding en el vault con nuevo-proyecto.sh
si no existe.)

---

## PASO 1 — Perfil de Hawkeye en el vault

Crea ~/ObsidianVault/00-Reglas-Globales/hawkeye-perfil.md con las
respuestas del onboarding. Formato igual a mi-perfil.md pero con
una sección adicional:

```markdown
## Nivel y restricciones
- Nivel: Junior
- Modelo: claude-sonnet-4-6 (no usar opus salvo autorización explícita)
- Puede pushear a: {{ramas permitidas — nunca main/master directo}}
- Requiere revisión antes de: commits que toquen producción,
  cambios en configuración de red/infra, modificaciones a archivos
  de autenticación o seguridad
- Explicaciones detalladas: {{sí/no según respuesta del onboarding}}
- Alertas de impacto: siempre
```

---

## PASO 2 — CLAUDE.md de Hawkeye

Crea ~/.claude/CLAUDE.md para Hawkeye (o agrega al existente sin
sobrescribir) con este contenido al final:

```markdown
# Team Vault — Hawkeye
@~/ObsidianVault/00-Reglas-Globales/CLAUDE-global.md
@~/ObsidianVault/00-Reglas-Globales/hawkeye-perfil.md

## Reglas adicionales para este perfil

### Modelo
Usar siempre claude-sonnet-4-6 para tareas cotidianas.
Opus solo si el líder del equipo lo autoriza explícitamente en
la sesión. Nunca escalar el modelo por iniciativa propia.

### Confirmación obligatoria antes de ejecutar
Pedir confirmación explícita de Hawkeye antes de:
- Cualquier commit (mostrar el diff resumido primero)
- Cualquier push (mostrar a qué rama va)
- Cualquier operación que toque archivos fuera del directorio
  actual del proyecto
- Instalación de dependencias nuevas
- Cambios en archivos de configuración (.env, config.*, docker-compose*)
- Cualquier comando bash que no sea lectura/búsqueda

### Anti-atajos (metronome)
No saltar pasos del flujo de trabajo aunque el usuario lo pida.
Si Hawkeye dice "hazlo rápido" o "sin explicación", ejecutar igual
el proceso completo pero siendo conciso en la comunicación.
Nunca omitir el paso de verificación/test porque "parece que funciona".
Si algo no está claro en los requisitos, PREGUNTAR antes de implementar.

### Explicaciones
{{Si Hawkeye pidió explicaciones detalladas:}}
Antes de cada acción no trivial, explicar brevemente QUÉ se va a hacer
y POR QUÉ. Máximo 2-3 líneas — enseñar, no saturar.

### Alertas de impacto
Si una acción puede afectar a otros miembros del equipo o a ambientes
compartidos, advertirlo explícitamente antes de proceder.
Formato: "⚠️ IMPACTO: [descripción breve] — ¿continuar?"

### Ramas
Antes de cualquier push, verificar la rama actual.
Si es main, master, develop o cualquier rama de integración:
DETENER y preguntar si Hawkeye está seguro. Sugerir crear una
rama de feature primero.

### Revisión de código
Antes de marcar cualquier tarea como completada, ejecutar una
revisión rápida del código producido:
- ¿Hay hardcoded credentials o IPs?
- ¿Se manejan los errores?
- ¿Hay console.log / print de debug sin remover?
Si se encuentra alguno, señalarlo y no marcar como completo.
```

---

## PASO 3 — Skill de revisión de código para juniors

Crea ~/ObsidianVault/03-Skills/junior-code-review/SKILL.md:

```markdown
---
description: >
  Revisión de código orientada a aprendizaje para desarrolladores
  junior. Activar automáticamente antes de cualquier commit en
  sesiones de Hawkeye, o cuando el usuario diga: "revisa mi código",
  "está listo para commit", "terminé", "¿cómo quedó?".
  Diferente al code review de producción — el foco es enseñar,
  no solo encontrar errores.
depends_on:
  - team-context
---

# Junior Code Review

## Instrucciones

1. Leer team-context para aplicar los estándares del equipo.

2. Revisar el código modificado buscando:
   - Credenciales, tokens o IPs hardcodeadas → BLOQUEANTE
   - Errores no manejados → BLOQUEANTE si es flujo crítico
   - Debug prints sin remover (console.log, print, dd()) → ADVERTENCIA
   - Nombres de variables sin sentido (a, x, temp2) → SUGERENCIA
   - Funciones de más de 40 líneas → SUGERENCIA de refactor
   - Lógica duplicada que ya existe en el codebase → SUGERENCIA

3. Reportar en este formato:
   🔴 BLOQUEANTE: [qué es, dónde está, por qué importa, cómo arreglarlo]
   🟡 ADVERTENCIA: [qué es, por qué importa]
   💡 SUGERENCIA: [qué podría mejorar, no obligatorio]

4. Si hay BLOQUEANTEs: no permitir el commit hasta que se resuelvan.
   Si solo hay ADVERTENCIAs o SUGERENCIAs: preguntar si Hawkeye
   quiere resolverlas ahora o continuar.

5. Si el código está limpio: decirlo explícitamente con una línea
   de feedback positivo específico ("El manejo de errores en el
   fetch quedó bien estructurado").
```

Instala la skill globalmente para que esté disponible:
```bash
cd ~/ObsidianVault
./usar-skill.sh junior-code-review --global
```

---

## PASO 4 — Proyecto de práctica (opcional)

Si Hawkeye no tiene todavía un proyecto asignado, crear un proyecto
de práctica en el vault para que empiece a trabajar con el sistema:

```bash
cd ~/ObsidianVault
./nuevo-proyecto.sh "Hawkeye Practice" [ruta-repo-si-existe]
```

En 00-Resumen.md del proyecto practice, agregar una sección
"Reglas de práctica":
- Cada tarea debe tener un objetivo claro antes de empezar
- Al cerrar cada sesión, llenar la nota de bitácora
- Si algo no queda claro, documentarlo en 03-Bugs-Conocidos.md
  con el tag [DUDA] para discutirlo con el equipo

---

## PASO 5 — Verificación final

Al terminar, muéstrame:
1. El contenido de ~/.claude/CLAUDE.md de Hawkeye
2. Confirma que la skill junior-code-review está en ~/.claude/skills/
3. Confirma que hawkeye-perfil.md existe en 00-Reglas-Globales/

Y dame un resumen de lo que Hawkeye debe hacer en su primera sesión
de trabajo para verificar que todo funciona:
- Qué comando ejecutar para abrir Claude Code
- Cómo verificar que el vault está conectado
- Cómo crear su primera nota de sesión
