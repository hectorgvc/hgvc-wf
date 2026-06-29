---
description: >
  Conduce la entrevista de onboarding para un usuario nuevo del sistema
  Team. Activar cuando alguien instale el vault por primera vez, o cuando
  diga: "quiero reconfigurar mi perfil", "actualiza mi contexto",
  "cambié de trabajo", "tengo un stack nuevo", "ejecuta el onboarding".
  Genera mi-perfil.md y CLAUDE-global.md desde las respuestas.
depends_on: []
---

# Team Onboarding

## Instrucciones

1. Explicar brevemente qué va a pasar: una entrevista corta en 5 bloques
   para definir el perfil personal. Las respuestas se guardan en
   mi-perfil.md y generan CLAUDE-global.md automáticamente.

2. Hacer las preguntas una a la vez, en conversación natural.
   No presentarlas como formulario. Los bloques:

### Bloque 1 · Identidad y contexto
- ¿Cuál es tu nombre?
- ¿A qué te dedicas? (rol, industria, si es trabajo fijo, freelance o ambos)
- ¿Trabajas solo o en equipo? Si es en equipo, ¿qué rol ocupas?

### Bloque 2 · Stack técnico
- ¿Cuáles son los lenguajes de programación que más usas?
- ¿Qué frameworks, bases de datos o herramientas usas regularmente?
- ¿Tienes infraestructura propia? (servidores, VMs, cloud, contenedores)
- ¿Qué sistema operativo usas como entorno de trabajo principal?

### Bloque 3 · Entorno y conectividad
- ¿Cómo te conectas a internet habitualmente? (wifi, hotspot, cable, VPN)
- ¿Tu máquina de trabajo se conecta directamente a redes de clientes
  o la mantienes aislada?
- ¿Trabajas con ambientes sensibles? (producción, datos de clientes,
  sistemas de gobierno, salud, financiero)

### Bloque 4 · Preferencias con Claude
- ¿En qué idioma prefieres que Claude te responda?
- ¿Prefieres que Claude confirme cada acción antes de ejecutar, o que
  actúe y te informe después?
- ¿Qué tan detalladas quieres las respuestas? (conciso / normal / explicado)
- ¿Quieres que Claude proponga una nota de sesión al cerrar cada sesión?

### Bloque 5 · Seguridad y reglas
- ¿Hay algo que NUNCA debe aparecer en un commit o en el vault?
  (tokens, IPs, credenciales, nombres de clientes)
- ¿Tienes alguna convención de commits que ya usas?
- ¿Hay ambientes donde Claude debe pedir confirmación explícita antes
  de ejecutar cualquier comando?

3. Al terminar, mostrar un resumen del perfil y pedir confirmación.

4. Si el usuario confirma:
   a. Escribir/sobreescribir ~/ObsidianVault/00-Reglas-Globales/mi-perfil.md
   b. Generar/regenerar CLAUDE-global.md desde mi-perfil.md con secciones:
      Contexto, Comunicación, Estándares de código, Seguridad,
      Flujo de trabajo, Regla de vault
   c. La "Regla de vault" debe quedar siempre al final de CLAUDE-global.md
      con este contenido exacto:

```
## Regla de vault

Cada vez que Claude Code se inicie en un directorio sin CLAUDE.md,
o que el usuario diga "iniciar proyecto" o "conectar al vault":

1. Verificar si existe ~/ObsidianVault/01-Proyectos/<nombre-slug>/.
2. Si no existe, ofrecer crearlo con nuevo-proyecto.sh antes de cualquier
   otra acción.
3. Crear el CLAUDE.md del directorio con una sola línea:
   @~/ObsidianVault/01-Proyectos/<slug>/CLAUDE.md
4. NUNCA duplicar documentación dentro del repo — todo va al vault.
5. Al iniciar en un proyecto ya conectado, leer el CLAUDE.md del vault
   antes de cualquier acción.
6. Si el usuario pide reporte, resumen o "¿en qué quedamos?",
   activar la skill reporte-proyecto automáticamente.
```

5. No inventar respuestas. Si una pregunta no aplica, marcar como
   "N/A — {{razón}}" en vez de dejar en blanco.

6. Informar al usuario que puede decir "actualiza mi perfil" en
   cualquier momento para repetir el proceso.
