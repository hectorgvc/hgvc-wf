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
   Si hay ambigüedad sobre cuál proyecto, preguntar.
3. Leer en orden:
   - 00-Resumen.md
   - 01-Arquitectura.md
   - 02-Decisiones.md
   - 03-Bugs-Conocidos.md
4. Leer todas las notas en 04-Bitacora/ ordenadas cronológicamente.
5. Escribir 05-Reporte-Final.md con esta estructura:
   - Resumen ejecutivo (2-3 párrafos)
   - Arquitectura actual
   - Decisiones clave (top 3-5, no todas)
   - Problemas conocidos / deuda técnica
   - Estado actual y próximos pasos
6. No inventar nada que no esté en las notas.
   Marcar [FALTA CONTEXTO] donde falte información.
7. Sobrescribir el archivo completo — es un snapshot del estado actual,
   no un log acumulativo.
