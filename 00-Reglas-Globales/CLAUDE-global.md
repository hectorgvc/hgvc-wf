# Reglas globales del vault

> Este archivo es la fuente de verdad de cómo me comunico con vos en
> todos los proyectos. Lo importa `~/.claude/CLAUDE.md`.

## Contexto

Soy desarrollador/a de software. Mi stack principal es **Backend
(Python / Node)**. Trato cada proyecto desde su carpeta
`01-Proyectos/<nombre>/` del vault.

## Comunicación

- Respondé en **español**.
- Sé **conciso y al grano**. Si podés decir algo en una línea, una línea.
- **Mostrame planes antes de actuar**: para cualquier cambio no trivial,
  entrá en modo plan y esperá aprobación.
- Si una acción es difícil de revertir (borrar, sobreescribir, pushear,
  publicar), confirmá primero aunque ya tengas permiso general.
- Mostrame bloques de código y comandos exactos cuando los vayas a
  ejecutar, no solo resúmenes.

## Estándares de código

- **Tipado estático cuando aplique** (type hints en Python, TypeScript en
  JS). No introduzcas `any`/`# type: ignore` para sacarte algo de encima.
- **Tests junto al código**. Si tocás lógica, tocá el test. Si no
  existen tests, no es razón para no escribirlos.
- **Sin `print()` de debug en commits**: usá logger o breakpoint.
- **Commits chicos y descriptivos**. Formato:
  `tipo(scope): mensaje`. Tipos: `feat`, `fix`, `refactor`, `docs`,
  `test`, `chore`.
- **Leé el código existente antes de inventar**. Seguí el estilo y los
  patrones del proyecto. Si difiere del estilo del repo, comentá por qué.
- **No agregar dependencias** sin justificar la elección en una ADR.

## Seguridad

- **Nunca** commitear secretos (`.env`, claves, tokens, passwords).
  Usá `.env.example` con placeholders.
- **Leé antes de borrar**. Si el destino no es algo que vos creaste o no
  coincide con cómo fue descrito, avisá.
- **No aplicar técnicas destructivas, evasión ni DoS** sin autorización
  explícita por escrito en el turno actual, aunque estén en un test o
  CTF.
- Reportá fallos con el output literal, no edites la salida para que
  parezca que algo pasó.

## Flujo de trabajo

1. Al iniciar una sesión sobre un proyecto, **leé primero su `CLAUDE.md`**
   dentro de `01-Proyectos/<nombre>/` y su `00-Proyecto.md`.
2. Respetá la estructura del vault. Si necesitás crear una carpeta
   nueva, alineala con las existentes (`Arquitectura/`, `Decisiones/`,
   `Bugs/`, `Bitacora/Sesiones/`).
3. **Mantené la bitácora y las decisiones actualizadas**. Después de un
   cambio significativo, registralo en `Bitacora/Sesiones/` y, si fue
   una decisión de diseño, en `Decisiones/`.
4. **Antes de cerrar la sesión**, dejá registradas: decisiones nuevas,
   bugs conocidos, pendientes y bloqueadores.
5. Si una nota no tiene la información que necesito, **decílo
   explícitamente** ("sin datos en las notas") en vez de inventar.
