---
description: >
  Usar cuando el usuario describe una idea de feature o proyecto, ANTES de
  escribir código o un plan. Refina la idea en un diseño con método
  socrático (una pregunta a la vez, explorar alternativas, validar por
  partes). Activar con "/brainstorming". Adaptada de Superpowers.
---

# brainstorming — de idea a diseño

Transformá una idea cruda en un diseño formado, con preguntas y
exploración de alternativas. **Anunciá al inicio:** "Uso brainstorming
para refinar tu idea en un diseño."

## Fase 1 — Entender
- Mirá el estado actual del proyecto (cwd / vault).
- Hacé **una sola pregunta por mensaje**. Preferí opción múltiple.
- Recogé: propósito, restricciones, criterio de éxito.

## Fase 2 — Explorar
- Proponé 2-3 enfoques distintos.
- Por cada uno: arquitectura central, trade-offs, complejidad.
- Preguntá cuál le resuena al usuario.

## Fase 3 — Presentar el diseño
- En secciones de 200-300 palabras.
- Cubrí: arquitectura, componentes, flujo de datos, manejo de errores, tests.
- Tras cada sección: "¿Va bien hasta acá?"

## Fase 4 — Handoff a implementación
Cuando el diseño está aprobado:
- Si es no trivial → entrá en **plan mode** o convocá `/vengadores`.
- Registrá las decisiones de diseño en `Decisiones/` (ADR), vía el agente
  `documentalista`.

## Volvé atrás cuando haga falta
Si aparece una restricción nueva o un hueco en los requisitos, regresá a
la Fase 1 o 2. Flexibilidad > avanzar en línea recta.

## Recordá
- Una pregunta por mensaje en la Fase 1.
- Aplicá YAGNI sin piedad.
- Explorá 2-3 alternativas antes de elegir.
- Presentá incremental, validá sobre la marcha.
