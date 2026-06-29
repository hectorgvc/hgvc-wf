---
description: >
  Conecta notas de proyectos con la wiki de conocimiento en 04-Wiki/.
  Activar cuando el usuario diga: "linkea esto a la wiki", "agrega a
  la wiki", "qué hay en la wiki sobre X", "crea una nota wiki para Y",
  "conecta el proyecto con la wiki", "busca en la wiki", o cuando
  Claude detecte un concepto técnico en un proyecto que no tiene nota
  en 04-Wiki/. También activa al crear notas nuevas de proyecto.
depends_on:
  - team-context
  - obsidian-markdown
---

# Wiki Connect

## Instrucciones

### Al crear o actualizar una nota de proyecto

1. Leer team-context y obsidian-markdown (formato correcto de wikilinks).
2. Identificar conceptos técnicos en la nota del proyecto:
   frameworks, protocolos, patrones de arquitectura, herramientas,
   servicios externos, tecnologías de infra.
3. Para cada concepto encontrado:
   - Buscar si existe `~/ObsidianVault/04-Wiki/tech/{{concepto}}.md`
     o `~/ObsidianVault/04-Wiki/patterns/{{concepto}}.md`
   - Si existe → agregar `[[concepto]]` en la nota del proyecto
   - Si no existe → preguntar al usuario si quiere crear la nota wiki

### Al crear una nota wiki nueva

1. Usar `02-Plantillas/Plantilla-Wiki.md` como base.
2. Guardar en `04-Wiki/tech/` (concepto técnico) o `04-Wiki/patterns/`
   (patrón arquitectónico reutilizable).
3. Llenar "Proyectos que lo usan" con `[[links]]` a proyectos activos.
4. Agregar `[[wikilinks]]` bidireccionales:
   - En la nota nueva → links a conceptos relacionados
   - En las notas de proyectos que ya lo usan → link de vuelta
5. Nombrar el archivo en minúsculas con guiones: `jwt-auth.md`,
   `docker-compose.md`. El título de la nota puede tener mayúsculas.

### Al buscar en la wiki

1. Leer `04-Wiki/README.md` para orientarse.
2. Seguir los `[[wikilinks]]` entre notas para navegar el grafo.
3. Reportar qué notas existen sobre el tema, qué proyectos las usan,
   y qué conexiones faltan.

### Conexiones bidireccionales (regla crítica)

Obsidian solo muestra el grafo si los links existen en los archivos.
Siempre que se cree un link A → B, verificar si B ya linkea a A.
Si no, agregar el link en B también. Sin esto el grafo queda incompleto.

## Formato de wikilinks (requiere obsidian-markdown)

```
[[nombre-del-archivo]]           → link básico
[[nombre-del-archivo|Texto]]     → link con texto alternativo
![[nombre-del-archivo]]          → embed (incluye el contenido)
```

Nunca usar links markdown estándar `[texto](ruta)` para notas
internas del vault — rompen el Graph View.
