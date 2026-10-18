// Starting deck for the touying-ufac-unofficial theme. Syntax: package README; every element: example/main.typ.
#import "@preview/touying:0.7.4": *
#import "@preview/touying-ufac-unofficial:0.1.0": *

#show: ufac-theme.with(
  aspect-ratio: "16-9",
  lang: "en",   // "pt-br" (default), "en" or "es"
  config-info(
    title: [Title of the teaching unit],
    subtitle: [Teaching unit I],
    author: [Prof. Dr. Your Name],
    subject: [Subject name],
    subject-code: [CODE or Department],
    counter-prefix: [1.],   // "Exercise 1.N"; none gives "Exercise N"
  ),
)

#title-slide()

== Slide title
=== Subtitle

Text.
