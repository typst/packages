#import "./glossary.typ":glossary
#import "@preview/frugal-haw-kiel:0.1.0": *
#show: thesis.with(
  language: "en",
  title-en: "How Can I Use This Template to Easily Style My Thesis?",
  keywords-en: ("HAWK", "Kiel", "University of Applied Science", "IuE", "Template"),
  abstract-en: include "./abstract.typ",
  // -en parameter are optional
  author: "Arne Berner",
  faculty: "Computer Science and Electrical Engineering",
  study-course: "Bachelor of Science Computer Science",
  supervisors: ("Prof. Dr. Musterwoman", "Prof. Dr. Musterman"),
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
