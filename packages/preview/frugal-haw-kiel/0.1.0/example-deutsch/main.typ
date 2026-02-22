#import "./glossary.typ":glossary
#import "@preview/frugal-haw-kiel:0.1.0": *
#show: thesis.with(
  language: "de",
  title-de: "Wie kann ich das Template nutzen, um meine Thesis einfach zu gestalten?",
  keywords-de: ("HAWK", "HAW", "Kiel", "IuE", "Template"),
  abstract-de: include "./abstract.typ",
  // -en parameter are optional
  author: "Arne Berner",
  faculty: "Informatik und Elektrotechnik",
  study-course: "Bachelor of Science Informatik",
  supervisors: ("Prof. Dr. Musterfrau", "Prof. Dr. Musterman"),
  submission-date: datetime(year: 2026, month: 1, day: 16),
  logo: image("./assets/logo.svg"),
  bib: bibliography("./bibliography.bib"),
  // yaml and typst work for both: abbreviations and glossary
  abbreviations: yaml("abbreviations.yaml"),
  glossary: glossary,
  use-declaration-of-independent-processing: true,
  before-content: include "./acknowledgment.typ",
  // after-content: (),
)

#pagebreak(weak: true)
#include "chapters/01_intro.typ"
#include "chapters/02_ending.typ"
