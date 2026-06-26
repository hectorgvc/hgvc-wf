---
fecha: 2026-06-19
proyecto: mavelerp
autor: hector
tags: [sesion, setup, vault]
---

# Sesión 2026-06-19 — Setup estructura del vault

## Objetivo

Centralizar la documentación del proyecto en el vault de Obsidian:
crear la estructura de carpetas (`Arquitectura/`, `Decisiones/`,
`Bugs/`, `Bitacora/Sesiones/`) con contenido inicial extraído de
`CLAUDE.md` y `core-mavelerp.md` del repo.

## Qué se hizo

- Creado `Arquitectura/01-Estructura-General.md` con stack, request
  lifecycle, namespace map, módulos y archivos clave del núcleo fiscal.
- Creado `Decisiones/Decisiones.md` con 4 ADRs retroactivas:
  ADR-0001 (MVC propio), ADR-0002 (XMLDSig), ADR-0003 (módulos por BD),
  ADR-0004 (eNCF quema secuencia — deuda conocida).
- Creado `Bugs/Bugs.md` con BUG-001 (2FA falla) y BUG-002 (NC/ND sin
  document_items).
- Creado este archivo de bitácora.
- El `CLAUDE.md` del proyecto ya importa todos estos con `@import`.

## Decisiones tomadas

- Se usaron las plantillas del vault (`Plantilla-Decision.md`,
  `Plantilla-Sesion.md`) como referencia de formato.
- El contenido se extrajo del `CLAUDE.md` del repo (fuente de verdad
  del código); el vault es la capa de contexto y trazabilidad.

## Pendientes

- [ ] Agregar la nueva tarea que el usuario indicará en esta sesión.
- [ ] Evaluar si `05-Reporte-Final.md` necesita contenido inicial.

## Bloqueadores

- Ninguno.

## Próxima sesión

El usuario tiene una nueva tarea para agregar. Retomar desde acá
con el backlog actualizado.
