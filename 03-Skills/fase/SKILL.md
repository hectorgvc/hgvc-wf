---
description: >
  Usar al iniciar una nueva fase o tarea de desarrollo, cuando el usuario
  pida ayuda para decidir qué modelo usar, o escriba "/fase" o "fase".
  Analiza la tarea y recomienda el modelo óptimo (Sonnet u Opus). NO usar
  a mitad de una tarea ya en curso ni para tareas triviales de una línea.
---

# fase — recomendador de modelo

El usuario está por comenzar una nueva fase de desarrollo. Analizá la
descripción de la tarea y recomendá el modelo más adecuado.

> Esta skill recomienda el modelo de la **sesión principal**. Los
> subagentes del equipo `vengadores` llevan su propio modelo fijo en su
> frontmatter y no se ven afectados por esto.

## Usá **Sonnet** cuando la tarea sea:
- Editar HTML, CSS o JavaScript (ajustes de UI, nuevas secciones, estilos)
- Modificar código existente ya conocido (funciones, rutas/handlers,
  queries ya mapeadas)
- Debug con pistas claras (error visible, log concreto, comportamiento
  conocido)
- Refactoring o renombrado de funciones/variables
- Añadir endpoints/handlers similares a los existentes
- Ajustes de diseño o copy

## Usá **Opus** cuando la tarea sea:
- Diseñar arquitectura nueva desde cero (módulo nuevo, autenticación,
  flujo complejo)
- Debug sin pistas claras (comportamiento extraño sin error visible,
  regresión difícil de reproducir)
- Razonamiento multi-paso con muchas dependencias cruzadas
- Decisiones estratégicas de producto o técnicas con varios trade-offs
- Análisis profundo de datos o lógica de negocio compleja

## Formato de respuesta (siempre)

**Modelo recomendado: [Sonnet / Opus]**

_Razón: [1 frase concisa]_

Para cambiar: `/model [sonnet/opus]`

## Regla

Si la tarea no está clara, pedí al usuario que la describa brevemente
antes de recomendar. No recomiendes a ciegas.
