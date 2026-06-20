---
description: >
  Usar siempre que se generen o editen interfaces (HTML/CSS/JS) y haga
  falta un icono. Referencia de iconos Lucide por tipo de negocio. Activar
  también con "/lucide". REGLA DURA: siempre Lucide, nunca emojis, nunca
  FontAwesome, nunca heroicons.
---

# Lucide Icons — referencia por negocio

**Siempre usar Lucide. Nunca emojis. Nunca FontAwesome. Nunca heroicons.**

## Setup (siempre este snippet en el `<head>`)

```html
<script src="https://unpkg.com/lucide@latest/dist/umd/lucide.min.js"></script>
```

## Uso en HTML

```html
<!-- En el body, usar el atributo data-lucide -->
<i data-lucide="phone" class="icon"></i>

<!-- Al final del body, inicializar -->
<script>lucide.createIcons();</script>
```

## CSS para iconos

```css
.icon { width: 20px; height: 20px; stroke-width: 1.75; }
.icon-sm { width: 16px; height: 16px; }
.icon-lg { width: 28px; height: 28px; }
.icon-xl { width: 40px; height: 40px; }
```

---

## Iconos por categoría de negocio

### Contacto y ubicación
| Propósito | Icono Lucide |
|---|---|
| WhatsApp / teléfono | `phone` |
| Dirección | `map-pin` |
| Correo | `mail` |
| Horario | `clock` |
| Ubicación general | `navigation` |
| Redes sociales | `share-2` |
| Instagram | `instagram` |
| Facebook | `facebook` |

### Servicios genéricos
| Propósito | Icono Lucide |
|---|---|
| Servicio / solución | `check-circle` |
| Calidad garantizada | `shield-check` |
| Rapidez / delivery | `zap` |
| Precio / costo | `tag` |
| Catálogo / productos | `grid-3x3` |
| Tiempo / experiencia | `timer` |
| Equipo / personal | `users` |
| Atención al cliente | `headphones` |

### Restaurante / Comida
| Propósito | Icono Lucide |
|---|---|
| Menú | `utensils` |
| Delivery | `bike` |
| Reservas | `calendar` |
| Chef / cocina | `chef-hat` |
| Bebidas | `coffee` |
| Ingredientes frescos | `leaf` |
| Takeout | `package` |
| Estrella / rating | `star` |

### Construcción / Ferretería
| Propósito | Icono Lucide |
|---|---|
| Herramientas | `wrench` |
| Materiales | `package` |
| Construcción | `hard-hat` |
| Medidas | `ruler` |
| Pintura | `paintbrush` |
| Electricidad | `zap` |
| Plomería | `droplets` |
| Entrega | `truck` |

### Salud / Belleza / Spa
| Propósito | Icono Lucide |
|---|---|
| Cuidado personal | `heart` |
| Cabello | `scissors` |
| Spa / relajación | `sparkles` |
| Cita / reserva | `calendar-check` |
| Productos | `flask-conical` |
| Higiene | `shield` |
| Bienestar | `sun` |
| Resultados | `trending-up` |

### Gym / Fitness
| Propósito | Icono Lucide |
|---|---|
| Entrenamiento | `dumbbell` |
| Rutinas | `repeat` |
| Progreso | `trending-up` |
| Clases | `users` |
| Nutrición | `apple` |
| Horarios | `clock` |
| Membresía | `badge-check` |
| Fuerza | `flame` |

### Educación / Academia
| Propósito | Icono Lucide |
|---|---|
| Cursos | `book-open` |
| Certificados | `award` |
| Profesores | `graduation-cap` |
| Online | `monitor` |
| Aprendizaje | `lightbulb` |
| Progreso | `bar-chart` |
| Inscripción | `pen-line` |
| Comunidad | `users` |

### Mecánica / Taller
| Propósito | Icono Lucide |
|---|---|
| Reparación | `wrench` |
| Diagnóstico | `scan` |
| Motor | `settings` |
| Llantas | `gauge` |
| Eléctrico | `zap` |
| Garantía | `shield-check` |
| Presupuesto | `receipt` |
| Taller | `hammer` |

### Inmobiliaria
| Propósito | Icono Lucide |
|---|---|
| Casa / propiedad | `home` |
| Apartamento | `building-2` |
| Búsqueda | `search` |
| Precio | `dollar-sign` |
| Área / medidas | `maximize-2` |
| Ubicación | `map-pin` |
| Cita / visita | `calendar` |
| Agente | `user-check` |

### Transporte / Logística
| Propósito | Icono Lucide |
|---|---|
| Camión | `truck` |
| Ruta | `route` |
| Tiempo entrega | `clock` |
| Paquete | `package` |
| Rastreo | `map` |
| Seguro | `shield` |
| Flota | `bus` |
| Carga | `box` |

---

## Iconos para secciones comunes

```
Hero CTA principal    → arrow-right
"Por qué elegirnos"   → check-circle  /  shield-check
WhatsApp flotante     → message-circle
Teléfono              → phone
Ubicación             → map-pin
Horario               → clock
Ver más / expandir    → chevron-down
Cerrar                → x
Menú mobile           → menu
Redes sociales        → share-2
Rating / estrella     → star
Experiencia / años    → award
```

---

## Botón flotante de WhatsApp

```html
<a href="https://wa.me/1XXXXXXXXXX" class="whatsapp-float" target="_blank">
  <i data-lucide="message-circle" style="width:26px;height:26px;fill:white;stroke:white"></i>
</a>
```

```css
.whatsapp-float {
  position: fixed;
  bottom: 24px;
  right: 24px;
  width: 56px;
  height: 56px;
  background: #25D366;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4px 20px rgba(37,211,102,0.4);
  z-index: 999;
  transition: transform 0.2s, box-shadow 0.2s;
  text-decoration: none;
}
.whatsapp-float:hover {
  transform: scale(1.08);
  box-shadow: 0 6px 28px rgba(37,211,102,0.5);
}
```
