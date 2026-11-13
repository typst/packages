#import "@preview/versatile-apa:7.2.0": abstract-page, appendix, title-page, versatile-apa as apa-style

#set document(
  title: [El título de esta propuesta de tesis es «Esperanza»],
  author: "Jassiel Ovando",
  description: lorem(100),
  keywords: ("UPSA", "tesis"),
)

#set text(lang: "es", region: "bo", font: "Reforma 1918")

#show: apa-style.with(
  font-size: 12pt,
)

#title-page(
  affiliations: [Facultad de Ingeniería, Universidad Privada de Santa Cruz de la Sierra],
  course: [MG550: Modalidad de Grado],
  instructor: [Ing. Nombre Apellido],
)

#include "chapter/intro.typ"

#pagebreak()
#bibliography("ref.haya.yaml", title: [Fuentes de información], full: true)

#show: appendix

= Costos
