---
nombre: {{nombre}}
creado: {{fecha}}
estado: activo
tags: [proyecto]
---

# {{nombre}}

> Esta es la nota raíz del proyecto. Su `CLAUDE.md` la importa con `@`,
> así que es el primer lugar que se lee al iniciar una sesión sobre
> este proyecto.

## Resumen

Una o dos frases: qué hace el proyecto, para quién, por qué existe.

## Stack

- Lenguaje principal:
- Framework:
- Base de datos:
- Infra / deploy:
- Otros:

## Estado actual

- **Versión / fase**: (idea / MVP / beta / producción / mantenimiento)
- **Última sesión**: [[Bitacora/Sesiones/]] → última entrada
- **Próximo hito**: (lo que viene después)

## Arquitectura

Ver [[Arquitectura/]]. Acá solo un puntero.

## Decisiones

Todas las ADRs viven en [[Decisiones/]]. Acá un resumen ejecutivo de
las 3-5 más importantes.

## Bugs conocidos

Lista viva en [[Bugs/]]. Acá solo los abiertos críticos.

## Bitácora

Entradas cronológicas en [[Bitacora/Sesiones/]], una por sesión de
trabajo.

## Reporte Final

[[05-Reporte-Final.md]] — síntesis generada por la skill
`reporte-proyecto`. Actualizar al cerrar un hito importante.
