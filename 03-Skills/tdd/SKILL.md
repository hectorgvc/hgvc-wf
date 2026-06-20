---
description: >
  Usar al implementar cualquier feature o bugfix, ANTES de escribir el
  código de implementación. Ciclo RED-GREEN-REFACTOR: el test primero.
  Activar con "/tdd". OJO: mavelerp no tiene test runner configurado → esta
  skill rinde sobre todo en proyectos Python/Node. Adaptada de Superpowers.
---

# tdd — el test primero

Escribí el test. VELO fallar. Escribí el código mínimo para que pase.

**Principio central:** "Si no viste fallar el test, no sabés si prueba lo
correcto." Violar la letra de la regla es violar su espíritu.

## Ley de hierro
```
NINGÚN CÓDIGO DE PRODUCCIÓN SIN UN TEST QUE FALLE PRIMERO
```
¿Escribiste código antes del test? Borralo y empezá de nuevo. Borrar es
borrar (no lo guardes "de referencia", no lo "adaptes").

Excepciones (pedí permiso al usuario): prototipos descartables, código
generado, archivos de config.

## Ciclo RED-GREEN-REFACTOR

1. **RED — test que falla.** Un test mínimo: nombre claro, una sola
   conducta, código real (mocks solo si es inevitable).
2. **Verificá RED (obligatorio).** Corré el test. Debe **fallar** (no
   errorear) y por la razón esperada (feature ausente, no un typo). ¿Pasa
   de una? Estás probando algo que ya existe → arreglá el test.
3. **GREEN — código mínimo.** Lo más simple que haga pasar el test. Nada
   de features extra ni "mejoras" (YAGNI).
4. **Verificá GREEN (obligatorio).** Pasa el test, los demás siguen verdes,
   salida limpia (sin warnings).
5. **REFACTOR.** Quitá duplicación, mejorá nombres, extraé helpers —
   manteniendo todo verde. No agregues conducta.
6. **Repetí** con el próximo test.

## Racionalizaciones (todas significan: empezá de nuevo con TDD)
| Excusa | Realidad |
|--------|----------|
| "Muy simple para testear" | Lo simple se rompe. El test toma 30s. |
| "Testeo después" | Un test que pasa de una no prueba nada. |
| "Ya lo probé a mano" | Ad-hoc ≠ sistemático. Sin registro, no se re-corre. |
| "Borrar X horas es desperdicio" | Costo hundido. Código sin test es deuda. |
| "TDD es dogmático, soy pragmático" | TDD ES pragmático: caza bugs antes del commit. |

## Banderas rojas — PARÁ
Código antes del test · test después · el test pasa de una · no podés
explicar por qué falló · "lo probé a mano" · "es distinto porque…".

## Cuando te trabás
- No sabés cómo testear → escribí la API que desearías; preguntá.
- Test muy complicado → el diseño es muy complicado, simplificá la interfaz.
- Tenés que mockear todo → código acoplado, usá inyección de dependencias.

## Integración con debugging
¿Bug? Escribí primero un test que lo reproduzca, después seguí el ciclo.
El test prueba el fix y previene la regresión. Ver `depuracion-sistematica`.
