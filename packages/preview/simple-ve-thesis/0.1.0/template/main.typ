#import "@preview/simple-ve-thesis:0.1.0": template

#let bib = bibliography("./refs.bib")

#show: template.with(
  title: "Title",
  candidate: (
    name: "Nome Cognome",
    number: "123456",
  ),
  date: "202x/202x",
  course: "Course name",
  logo: image("images/Unive.svg", width: 20%),
  is-master: false, // Change the title if it is a bachelor's or master's thesis
  supervisor: "Prof. Nome Cognome",
  co-supervisor: "Prof. Nome Cognome",
  abstract: "./abstract.typ",
  lang: "it",
  bib: bib, // Pass the bibliography object instead of a file path
)

= Introduzione
#lorem(100)

== Parte uno
#lorem(100)

== Parte due
#lorem(300)

= Background
#lorem(100)

== Parte uno
#lorem(100)

=== Parte extra

#lorem(100)

== Parte due
#lorem(150)

== Parte tre
#lorem(100)

= Terzo capitolo
#lorem(50)

= Riconoscimenti
#lorem(100)
