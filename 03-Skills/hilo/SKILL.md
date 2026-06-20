---
description: >
  Evalúa si conviene cerrar esta conversación e iniciar un hilo nuevo para
  preservar contexto y eficiencia de tokens. Activar con "/hilo" o cuando
  el usuario pregunte si conviene arrancar una conversación nueva. NO usar
  en medio de una tarea sin terminar.
allowed-tools: Bash
---

# hilo — ¿conviene un hilo nuevo?

El usuario quiere saber si conviene cerrar esta conversación e iniciar una
nueva. Evaluá señales objetivas y dá una recomendación clara y corta.

## Paso 1 — Recoger señales

Ejecutá en silencio (sin mostrar los comandos). Detectá el repo desde el
cwd; si no es un repo git, saltá las señales de git sin romper:

```bash
if git rev-parse --show-toplevel >/dev/null 2>&1; then
  echo "REPO: $(git rev-parse --show-toplevel)"
  git log --oneline -10
  echo "---"
  git status --short
else
  echo "Sin repo git en el cwd"
fi
```

## Paso 2 — Evaluar

**Señales de que SÍ conviene hilo nuevo:**
- El contexto ya fue comprimido automáticamente (lo ves porque hay un
  "Summary:" al inicio) → señal fuerte.
- 3+ commits en esta sesión → sesión larga.
- Cambiamos de área/módulo de trabajo (ej. de Facturación a otro módulo
  distinto).
- Hay cambios sin commit que complican el estado.
- La conversación lleva más de ~40 mensajes.

**Señales de que NO conviene:**
- Estamos en medio de una tarea sin terminar.
- Acabamos de hacer un commit limpio y seguimos en el mismo módulo.
- La sesión es corta y el contexto está fresco.

## Paso 3 — Responder

Si recomendás hilo nuevo:

```
✦ Buen momento para un nuevo hilo

Por qué: [razón principal en 1 frase]

Antes de cerrar:
□ git commit (si hay cambios pendientes)
□ Registrar la sesión en el vault: 01-Proyectos/<proyecto>/Bitacora/Sesiones/
  (o convocá al documentalista del equipo Vengadores)
□ [cualquier otra cosa específica del estado actual]

Para continuar en el nuevo hilo, empezá con:
"Continuamos <proyecto>. Leé su CLAUDE.md y la última nota en
Bitacora/Sesiones/ para el contexto."
```

Si NO recomendás hilo nuevo:

```
✦ Podemos seguir acá

Por qué: [razón en 1 frase]
Tokens: sesión corta, contexto fresco.
```

Sé directo. No expliques el proceso de evaluación, solo el resultado.
