---
description: >
  Revisión de código orientada a aprendizaje para desarrolladores junior.
  Activar automáticamente antes de cualquier commit en sesiones de perfil
  junior, o cuando el usuario diga: "revisa mi código", "está listo para
  commit", "terminé", "¿cómo quedó?", "¿está bien esto?".
  Diferente al code review de producción — el foco es enseñar, no solo
  encontrar errores.
depends_on:
  - team-context
---

# Junior Code Review

## Instrucciones

1. Leer team-context para aplicar los estándares del equipo.

2. Revisar el código modificado buscando:
   - Credenciales, tokens o IPs hardcodeadas → BLOQUEANTE
   - Errores no manejados en flujos críticos → BLOQUEANTE
   - Debug prints sin remover (console.log, print, dd(), var_dump()) → ADVERTENCIA
   - Nombres de variables sin sentido (a, x, temp2, cosa) → SUGERENCIA
   - Funciones de más de 40 líneas → SUGERENCIA de refactor
   - Lógica duplicada que ya existe en el codebase → SUGERENCIA

3. Reportar en este formato exacto:
   🔴 BLOQUEANTE: [qué es] | [dónde está] | [por qué importa] | [cómo arreglarlo]
   🟡 ADVERTENCIA: [qué es] | [por qué importa]
   💡 SUGERENCIA: [qué podría mejorar, no obligatorio]

4. Si hay BLOQUEANTEs:
   No permitir el commit hasta que se resuelvan.
   Ofrecer ayuda para corregirlos.

5. Si solo hay ADVERTENCIAs o SUGERENCIAs:
   Preguntar si el usuario quiere resolverlas ahora o continuar.

6. Si el código está limpio:
   Decirlo explícitamente con una línea de feedback positivo específico.
   No genérico ("bien hecho") — señalar qué parte específica quedó bien.
