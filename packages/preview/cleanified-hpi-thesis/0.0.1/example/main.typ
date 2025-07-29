#import "@preview/cleanified-hpi-thesis:0.0.1": *

#let abstract = [
  This is a very good abstract.
]

#let abstract-de = [
  Die ist eine wirklich gute Zusammenfassung.
]

#let acknowledgements = [
  Thanks to ...
]

#show: project.with(
  title: "My Very Long, Informative, Expressive, and Definitely Fancy Title",
  translation: "Eine adäquate Übersetzung meines Titels",
  name: "Max Mustermann",
  date: "17. Juli, 2025",
  study-program: "IT-Systems Engineering",
  chair: "Data-Intensive Internet Computing",
  professor: "Prof. Dr. Rosseforp Renttalp",
  advisors: ("This person", "Someone Else"),
  abstract: abstract,
  abstract-de: abstract_de,
  acknowledgements: acknowledgements,
  type: "Master",
  for-print: false
)

= Introduction
#lorem(80)

== In this paper
#lorem(20)

=== Contributions
#lorem(40)

==== Really Small Stuff
#lorem(20)

===== 5th Level
Are you sure you want to use this?

= Related Work
#lorem(500)
