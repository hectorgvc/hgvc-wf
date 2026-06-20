---
description: >
  Usar al depurar un bug, sobre todo sin pistas claras (comportamiento
  raro sin error visible, regresión difícil de reproducir, "a veces falla").
  Método de análisis de causa raíz en 4 fases. Activar con
  "/depuracion-sistematica". Adaptada de Superpowers (obra/superpowers).
---

# depuracion-sistematica — causa raíz antes que parche

**Ley de hierro: NINGÚN FIX SIN INVESTIGAR LA CAUSA RAÍZ PRIMERO.**
Parchear el síntoma crea problemas en cascada.

## Fase 1 — Investigar la causa raíz
- Leé el mensaje de error **completo** (no lo asumas).
- Reproducí el bug de forma consistente.
- Revisá los cambios recientes (`git log` / `git diff`).
- En sistemas multi-capa, instrumentá cada capa con logs para ubicar
  dónde falla de verdad.

## Fase 2 — Analizar patrones
- Buscá un caso que SÍ funciona y estudialo completo.
- Compará lo que funciona vs lo que rompe: ¿qué difiere?
- Entendé las dependencias involucradas.

## Fase 3 — Hipótesis y prueba (método científico)
- Formulá una hipótesis específica de la causa.
- Probala con el cambio mínimo posible.
- Validá el resultado antes de seguir.

## Fase 4 — Implementar
- Escribí primero un test que falle reproduciendo el bug (ver `tdd`).
- Aplicá un único fix enfocado a la causa raíz.
- Verificá que pasa y que no rompiste otra cosa.

## Banderas rojas — volvé a la Fase 1
- "Fix rápido por ahora, investigo después."
- "Un intento más" (después de varios fallos).
- **Tras 3 intentos fallidos: pará y cuestioná la arquitectura**, no
  sigas parchando.

> Pista de modelo: si el bug no tiene pistas claras, `/fase` recomienda
> Opus. Encaja con el agente `dev-senior` del equipo `vengadores`.
