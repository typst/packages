// For local development, replace the import below with:
// #import "../template/lib.typ": *
#import "@preview/cleanified-hpi-thesis:0.2.0": *

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
  professors: ("Prof. Dr. Rosseforp Renttalp", "Prof. Dr. Erika Mustermann"),
  advisors: ("Dr. Karla Musterfrau",),
  abstract: abstract,
  abstract-de: abstract-de,
  acknowledgements: acknowledgements,
  // acronyms: [API -- Application Programming Interface],
  // ai-declaration: [Describe any use of generative AI tools here.],
  type: "Master",
  bibliography: bibliography("references.bib"),
  // lang: "de",  // Switch all labels to German defaults
  // typography: (font: "STIX Two Text", body-text-size: 12pt),
  // layout: (for-print: true, toc-depth: 2),
  // appearance: (accent-color: rgb("#B1063A")),
  // labels: (declaration-city: "Berlin"),
)

= Introduction
#lorem(80)

As shown by Doe and Smith @example2025, this approach is effective.

== In this paper
#lorem(20)

=== Contributions
#lorem(40)

==== Really Small Stuff
#lorem(20)

= Related Work
#lorem(500)
