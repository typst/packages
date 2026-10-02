// For local development, replace the import below with:
// #import "../template/lib.typ": *
#import "@preview/cleanified-hpi-thesis:0.3.0": *

#show: project.with(
  title: "My Very Long, Informative, Expressive, and Definitely Fancy Title",
  translation: "Eine adäquate Übersetzung meines Titels",
  name: "Max Mustermann",
  date: "17. Juli, 2025",
  study-program: "IT-Systems Engineering",
  chair: "Data-Intensive Internet Computing",
  professors: ("Prof. Dr. Rosseforp Renttalp", "Prof. Dr. Erika Mustermann"),
  advisors: ("Dr. Karla Musterfrau",),
  type: "Master",
  // lang: "de",  // Switch all labels to German defaults
  // typography: (font: "STIX Two Text", body-text-size: 12pt),
  // layout: (for-print: true, toc-depth: 2),
  // appearance: (accent-color: rgb("#B1063A")),
  // labels: (declaration-city: "Berlin"),
)

#abstract[
  This is a very good abstract.
]

#abstract-de[
  Dies ist eine wirklich gute Zusammenfassung.
]

#acknowledgements[
  Thanks to ...
]

// #acronyms[
//   API -- Application Programming Interface
// ]

// #ai-declaration[
//   Describe any use of generative AI tools here.
// ]

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

#bibliography("references.bib")

#appendix[
  == Additional Results
  #lorem(80)
]
