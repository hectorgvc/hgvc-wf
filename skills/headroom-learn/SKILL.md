---
description: >
  Ejecuta headroom learn para minar la sesión actual, detectar patrones
  de fallo y escribir correcciones al vault. Activar cuando el usuario
  diga: "aprende de esta sesión", "guarda lo que aprendimos", "actualiza
  las reglas con lo de hoy", o al cerrar una sesión larga con errores o
  retries. También al final de sesiones de depuración complejas.
  Requiere headroom-ai instalado (pip install headroom-ai).
depends_on:
  - team-context
---

# Headroom Learn → Vault

## Instrucciones

1. Verificar que headroom está instalado:
   ```bash
   headroom --version || echo "FALTA: pip install headroom-ai"
   ```
   Si no está instalado, informar al usuario y detenerse.

2. Ejecutar headroom learn sobre la sesión:
   ```bash
   headroom learn --output /tmp/headroom-learnings.md
   ```

3. Leer /tmp/headroom-learnings.md y clasificar cada aprendizaje:

   - Regla que aplica a TODOS los proyectos:
     → Agregar al final de ~/ObsidianVault/00-Reglas-Globales/CLAUDE-global.md
       bajo sección "## Aprendizajes automáticos (headroom learn)"

   - Aplica solo al proyecto actual:
     → Agregar a 02-Decisiones.md con tag [AUTO-headroom] y fecha

   - Bug o patrón de fallo recurrente:
     → Agregar a 03-Bugs-Conocidos.md con el patrón y la corrección

4. Hacer git commit en el vault:
   ```bash
   cd ~/ObsidianVault && git add . && \
   git commit -m "headroom learn: $(date +%Y-%m-%d) — N aprendizajes"
   ```

5. Informar al usuario qué se escribió y dónde.

## Nota de seguridad
Si algún aprendizaje detectado toca configuración de seguridad,
credenciales o accesos, mostrarlo al usuario para revisión manual
antes de escribirlo al vault.
