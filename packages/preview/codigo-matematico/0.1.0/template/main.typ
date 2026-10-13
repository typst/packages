// SPDX-License-Identifier: MIT-0
#import "@preview/codigo-matematico:0.1.0": *

// Edit these fields, then replace the sample content with your own notes.
// Use sheet: "a4" for a standard page or "tablet" for a compact A5 page.
#show: templ.with(
  sheet: "tablet",
  lang: "es",
  title: [Código Matemático],
  authors: (),
  abstract: [
    Apuntes de matemáticas para leer en PDF y en la web.
    Definiciones, resultados y demostraciones en un mismo documento.
  ],
  outline_depth: 2,
)

= Distancias y continuidad

#definition(title: [Distancia usual])[
  Para $x, y in RR$, definimos $d(x, y) = abs(x - y)$.
  Esta distancia mide la separación entre dos puntos de la recta real.
] <def-distancia>

#theorem(title: [Desigualdad triangular])[
  Para cualesquiera $x, y, z in RR$, se cumple
  $ d(x, z) <= d(x, y) + d(y, z). $
] <thm-triangular>

#proof(ref: [@thm-triangular])[
  Por la desigualdad triangular del valor absoluto,
  $ abs(x - z) = abs((x - y) + (y - z)) <= abs(x - y) + abs(y - z). $
  Aplicando la @def-distancia obtenemos el resultado.
]

#example[
  Si $x = 1$, $y = 3$ y $z = 6$, entonces
  $ d(1, 6) = 5 = 2 + 3 = d(1, 3) + d(3, 6). $
]

#exercise[
  Demuestra que $abs(d(x, z) - d(y, z)) <= d(x, y)$
  usando dos veces el @thm-triangular.
]

#remark[
  En la salida web, activa el triángulo para desplegar la demostración.
  En PDF, la demostración se muestra completa.
]
