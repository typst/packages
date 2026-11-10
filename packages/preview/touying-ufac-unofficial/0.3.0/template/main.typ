// Starting deck for the touying-ufac-unofficial theme. Syntax: the manual, docs/manual.pdf; whole decks: example/ (a
// lecture, coursework, a thesis defense), both at https://github.com/lucaslrodri/touying-ufac-unofficial/tree/v0.3.0
#import "@preview/touying:0.7.4": *
#import "@preview/touying-ufac-unofficial:0.3.0": *

#show: ufac-theme.with(
  aspect-ratio: "16-9",
  lang: "en",   // "pt-br" (default), "en" or "es"
  config-info(
    flavor: "lecture",   // or "coursework", "tcc", "dissertation", "thesis": start from example/coursework.typ, tcc.typ
    subject: [Subject name],                  // or Touying's `title:`
    subject-code: [CODE or Department],       // or `short-title:`
    unit-title: [Title of the teaching unit], // or `subtitle:`
    unit: [Teaching unit I],                  // or `short-subtitle:`
    author: [Prof. Dr. Your Name],
    // counter-prefix: [2.],   // "Exercise 2.N" in the second unit; the flavor "lecture" gives [1.]
  ),
)

#title-slide()

== Slide title
=== Subtitle

Text.
