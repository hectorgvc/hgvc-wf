---
description: >
  <¿Cuándo se activa? Específico y orientado a la acción. Arrancá con
  "Usar cuando…" y describí el PROBLEMA/síntoma, no solo el tema. Incluí
  los disparadores y la barra "/nombre". Cerrá con "NO usar para…".>
---

# nombre-de-la-skill

> **Buenas prácticas de autoría** (de la skill `writing-skills` de
> Superpowers, adaptadas). Borrá esta cita al crear la skill real.
>
> - **Descripción rica (CSO):** Claude lee la `description` para decidir si
>   cargar la skill. Poné síntomas, errores y sinónimos que buscarías
>   ("flaky", "se cuelga", "rechazo DGII"), no abstracciones.
> - **Nombre en voz activa, verbo primero:** `depuracion-sistematica`,
>   `creando-x` — no `x-creacion`.
> - **Económica en tokens:** la `description` se carga en CADA sesión.
>   Apuntá a <200 palabras en skills de uso frecuente, <500 en el resto.
>   El detalle pesado va a un archivo aparte o a `--help`, no inline.
> - **Repetí los conceptos clave** (en description, título, headers): más
>   chances de que el grep futuro la encuentre.

## Instrucciones

Pasos concretos, numerados, en imperativo. Cada uno ejecutable sin
ambigüedad.

1. ...
2. ...
3. ...

## (Solo si es una skill de disciplina/regla) Racionalizaciones y banderas rojas

Las skills que imponen una regla (TDD, "no fix sin causa raíz") necesitan
resistir excusas bajo presión. Agregá una tabla y una lista de banderas
rojas para cerrar loopholes:

| Excusa | Realidad |
|--------|----------|
| "..." | "..." |

**Banderas rojas — PARÁ:** señales de que estás por violar la regla.

## Ejemplos

### Ejemplo 1

**Input**: lo que dice o hace el usuario.

**Output esperado**: qué debería entregar la skill.

### Ejemplo 2

**Input**: ...

**Output esperado**: ...
