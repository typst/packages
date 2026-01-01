#import "./abstract.typ":abstract
#import "./acknowledgment.typ":acknowledgment
#import "./abbreviations.typ":abbreviations
#import "./glossary.typ":glossary
#import "@preview/frugal-haw-kiel:0.1.0": *
#show: thesis.with(
  language: "de",
  title-de: "Wie kann ich das Template nutzen, um meine Thesis einfach zu gestalten?",
  keywords-de: ("HAW", "Kiel", "IuE", "Template"),
  abstract-de: abstract,
  title-en: lorem(12),
  keywords-en: ("CCN", "Kiel", "Science", "Applied"),
  abstract-en: ("Another lorem ipsum that might be to long as it is it's worth a try at least."),
  author: lorem(3),
  faculty: "Informatik und Elektrotechnik",
  study-course: "Bachelor of Science Informatik",
  supervisors: ("Prof.Dr. Musterfrau", "Prof.Dr. Musterman"),
  submission-date: datetime(year: 2026, month: 1, day: 16),
  logo: image("./assets/logo.svg"),
  bib: bibliography("./bibliography.bib"),
  abbreviations: abbreviations,
  glossary: glossary,
  use-declaration-of-independent-processing: true,
  before-content: acknowledgment,
  // after-content: (),
)

#pagebreak(weak: true)
#include "chapters/01_intro.typ"
#include "chapters/02_ending.typ"
