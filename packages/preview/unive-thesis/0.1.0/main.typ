#import "./lib.typ": template

// Create bibliography object first
#let bib = bibliography("./refs.bib")

#show: template.with(
  title: "Title",
  candidate: (
    name: "Nome Cognome",
    number: "123456",
  ),
  date: "202x/202x",
  course: "Course name",
  logo: image("images/UNIVE.png", width: 20%),
  is_master: false,
  supervisor: "Prof. Nome Cognome",
  co-supervisor: "Prof. Nome Cognome",
  abstract: "./abstract.typ",
  lang: "it",
  bib: bib, // Pass the bibliography object instead of a file path
)

= Introduzione
#lorem(100)
== Part one
#lorem(100)

== Part two
#lorem(300)
= Background
#lorem(100)

== Part one
#lorem(100)

=== Part one on one

#lorem(100)

==== Part extra

== Part two
#lorem(150)

== Part three
#lorem(100)

= Technical Part
#lorem(50)

== First Part
#lorem(150)

=== First subpart
#lorem(150)

==== First subsubpart
#lorem(150)

== Second part
#lorem(150)

= Riconoscimenti // Ringraziamenti This is a special title name
#lorem(100)
