#import "@local/plantilla-excelencia-gaite:0.1.0": *

// Escribirmos a partir de aquí

= Capítulo 1 <capitulo_1>

#lorem(200)

#lorem(10). Tal y como aparece en @capitulo_1

== Apartado a

#lorem(50)

#columns(2, gutter: 11pt)[
  #lorem(50)
  #colbreak()
  #lorem(30)
  #figure(
    table(
      columns: 4,
      [t], [1], [2], [3],
      [y], [0.3s], [0.4s], [0.8s],
    ),
    caption: [Resultados de medida],
  )
]

#import "@preview/lilaq:0.4.0" as lq

#figure(
  lq.diagram(
    lq.plot((0, 1, 2, 3, 4), (5, 4, 2, 1, 2))
  ),
  caption: [Resultados de medida],
)

== Apartado b

#lorem(600)

@electronic

@harry

@kinetics
