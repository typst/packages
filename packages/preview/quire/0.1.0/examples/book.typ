// Un libro en castellano, dividido en partes, preparado para imprimir.
#import "@preview/quire:0.1.0": *

#show: quire.with(
  title: [Breve historia del libro],
  subtitle: [Del rollo al códice y del códice a la pantalla],
  authors: "Juana Pérez",
  date: [octubre de 2026],
  version: [v1.0],
  lang: "es",
  top-level: "part",
  output: "print",
  kicker: [Monografía · 2026],
  institution: ([Universidad de Ninguna Parte], [Facultad de Letras], [Departamento de Historia]),
  info: (([Revisión], [Juan Gómez]), ([Edición], [Primera])),
  dedication: [A quienes encuadernan.],
  license: [Esta obra se distribuye bajo la licencia CC BY 4.0.],
  acknowledgments: [
    Gracias a las bibliotecas que conservan los libros de los que habla este libro. #lorem(60)
  ],
  abstract: (
    (lang: "es", body: [#lorem(80)], keywords: ("libro", "códice", "encuadernación")),
    (lang: "en", body: [#lorem(70)], keywords: ("book", "codex", "bookbinding")),
  ),
)

#part([El rollo], epigraph: [Verba volant, scripta manent.], attribution: [Proverbio latino])

#chapter([Los orígenes], epigraph: [El principio es la mitad del todo.], attribution: [Pitágoras])

#lorem(150)

=== El papiro <sec:papiro>

#lorem(200)

#figure(rect(width: 60%, height: 3cm, stroke: 0.5pt), caption: [Esquema de un rollo de papiro.]) <fig:rollo>

#lorem(120) Véase la @fig:rollo.

=== El pergamino

#lorem(250)

= El códice

== Cuadernos y pliegos

#lorem(180)

=== El cuaderno

#definition[Un _cuaderno_ es un conjunto de pliegos doblados y cosidos juntos.]

#lorem(200)

== La imprenta

#lorem(300) Como se vio en #ref-titled(<sec:papiro>), #lorem(40)

#show: appendix

== Glosario

/ Folio: hoja que resulta de doblar un pliego una vez.
/ Cuaderno: conjunto de pliegos doblados y cosidos.

#bibliography("refs.yaml")
