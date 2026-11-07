#import "@preview/upsa-thesis:0.1.0": back-matter, front-matter, main-matter, settings
#import "@preview/versatile-apa:7.2.0": abstract-page, appendix, title-page, versatile-apa as apa-style

#set document(
  title: [El título de esta propuesta de tesis es «Esperanza»],
  author: "Jassiel Ovando",
  description: lorem(100),
  keywords: ("UPSA", "tesis"),
)

#set text(lang: "es", region: "bo", font: "Alegreya")

#show: apa-style.with(
  font-size: 12pt,
)

#title-page(
  affiliations: [Facultad de Ingenieria, Universidad Privada de Santa Cruz de la Sierra],
  course: [MG550: Modalidad de Grado],
  instructor: [Ing. Nombre Apellido],
)
= Definición del problema
= Objetivos
= Metodología
= Alcance
= Contenido
= Cronograma
= Conclusiones

#pagebreak()
#bibliography("bibliography/ref.haya.yaml", title: [Fuentes de información], full: true)

#show: appendix

= Costos
