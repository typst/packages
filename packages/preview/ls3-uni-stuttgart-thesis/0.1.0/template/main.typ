#import "@preview/ls3-uni-stuttgart-thesis:0.1.0": thesis
#import "@preview/abbr:0.3.1"

// Define every abbreviation once. The first time each appears in the text,
// abbr expands it to the long form with the short form in parentheses;
// subsequent appearances render as the short form only.
#abbr.make(
  ("IS", "Invisible Sandwich", "Invisible Sandwiches"),
  ("ED", "Exact Diagonalisation"),
  ("DMRG", "Density Matrix Renormalization Group"),
  ("MFT", "Mean-Field Theory"),
  ("QM", "Quantum Mechanics"),
)

// Enable the show rule that turns `@KEY` references into abbreviation
// renderings. Non-abbreviation `@` references (bibliography keys, labels)
// continue to work normally.
#show: abbr.show-rule

#show: thesis.with(
  title: [On the Optimization and Uncertainty Quantification of Groundwater Models],
  cover-title: [On the Optimization and \ Uncertainty Quantification of \ Groundwater Models],
  author: "Maxime Mustermann",
  matriculation-number: "1234567",
  degree: "master",
  language: "english",
  date: "April 2026",
  examiners: ("Prof. Dr.-Ing. Erika Beispiel",),
  supervisors: ("M.Sc. Be Treuer",),
  abstract-en: include "front-matter/abstract-en.typ",
  abstract-de: include "front-matter/abstract-de.typ",
  abbreviations: include "front-matter/abbreviations.typ",
  notation: include "front-matter/notation.typ",
  bib: bibliography("references.bib", style: "apa"),
  ai-tools: (
    statements: (informed: true, verified: true, responsible: true),
    activities: (writing: true, coding: true),
  ),
)

#include "chapters/01-first-chapter.typ"
#include "chapters/02-unnumbered-chapter.typ"
