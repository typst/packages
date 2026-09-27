// `flex-caption` da a una figura una leyenda larga (mostrada debajo de ella) y
// un título corto (mostrado en el Índice de Figuras / Tablas). Impórtalo en
// cada capítulo que tenga figuras — los capítulos se `#include`n y no heredan
// los imports de main.typ.
#import "@preview/classic-uni-thesis:0.1.0": flex-caption

= Metodología

Describe lo que hiciste con suficiente detalle como para que un lector
competente pueda reproducirlo. Este capítulo es un buen lugar para mostrar los
dos estilos de figura que soporta la plantilla: una imagen común y una figura de
varios paneles.

== Materiales

Presenta los datos, muestras o entradas de tu estudio, y cita sus fuentes
@lee2022. Cuando te refieras a una figura o tabla, usa una referencia cruzada
para que el número siga siendo correcto si reordenas las cosas: el diseño
general se resume en @fig:method-overview.

#figure(
  image("../figures/placeholder.svg", width: 80%),
  caption: flex-caption(
    [Un esquema general del método. Esta es la leyenda larga que aparece debajo
     de la figura; debería explicar lo que muestra la figura con suficiente
     claridad como para sostenerse por sí sola, sin repetir el texto del cuerpo.
     Reemplaza la imagen de ejemplo por tu propio diagrama o gráfico.],
    [Esquema general del método],
  ),
) <fig:method-overview>

== Procedimiento

Expón los pasos de tu método en orden. Los comandos cortos y los identificadores
se pueden escribir en línea, como ejecutar `typst compile main.typ`, mientras que
los listados más largos van en un bloque de código delimitado, que la plantilla
renderiza sobre un fondo sombreado:

```python
def rollup(records, ranks):
    """Aggregate raw records up a taxonomic (or any) hierarchy."""
    totals = {}
    for record in records:
        for rank in ranks:
            totals.setdefault(rank, 0)
            totals[rank] += record.count
    return totals
```

Las figuras de varios paneles se construyen colocando varias imágenes (o
paneles) en una `grid` dentro de una sola `#figure`, de modo que comparten un
número y una leyenda (@fig:two-panel).

#figure(
  grid(
    columns: 2,
    column-gutter: 6pt,
    image("../figures/placeholder.svg", width: 100%),
    image("../figures/placeholder.svg", width: 100%),
  ),
  caption: flex-caption(
    [Una figura de dos paneles. *(A)* El primer panel. *(B)* El segundo panel.
     Refiérete a los paneles individuales como @fig:two-panel\A y
     @fig:two-panel\B en el texto.],
    [Una figura de dos paneles],
  ),
) <fig:two-panel>

== Análisis

Explica cómo se procesaron y analizaron los datos. Las tablas usan reglas estilo
booktabs (una regla más gruesa bajo el encabezado, reglas finas entre filas) y, a
diferencia de las figuras, colocan su leyenda encima de la tabla:

#figure(
  table(
    columns: (auto, 1fr, auto),
    align: (left, left, right),
    table.header([*Parámetro*], [*Descripción*], [*Valor*]),
    [`threshold`], [Puntuación mínima para conservar un registro], [0.80],
    [`window`], [Tamaño de la ventana deslizante], [50],
    [`seed`], [Semilla aleatoria para la reproducibilidad], [42],
    [`workers`], [Número de trabajadores en paralelo], [8],
  ),
  caption: flex-caption(
    [Parámetros usados en el análisis. Los valores son ilustrativos; documenta
     la configuración necesaria para reproducir tus resultados.],
    [Parámetros del análisis],
  ),
) <tab:parameters>

Declara cualquier supuesto y cómo validaste los resultados, para que el lector
pueda juzgar su fiabilidad @nakamura2023.
