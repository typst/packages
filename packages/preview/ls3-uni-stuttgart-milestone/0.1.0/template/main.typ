#import "@preview/ls3-uni-stuttgart-milestone:0.1.0": milestone
#import "@preview/abbr:0.3.1"

// Define every abbreviation once. First use expands to the long form
// with the short form in parentheses; later uses render the short form.
#abbr.make(
  ("UQ", "Uncertainty Quantification"),
  ("MCMC", "Markov Chain Monte Carlo"),
  ("PDE", "Partial Differential Equation", "Partial Differential Equations"),
)

#show: abbr.show-rule

#show: milestone.with(
  title: [Towards Efficient Uncertainty Quantification of Groundwater Models],
  // Optional title with manual line breaks for the title page.
  cover-title: [Towards Efficient Uncertainty \ Quantification of \ Groundwater Models],
  author: "Maxime Mustermann",
  language: "english",
  presentation-date: "15 April 2026",
  supervisor: "Prof. Dr.-Ing. Erika Beispiel",
  co-supervisor: "Dr. Max Muster",
  // Institute and chair default to IWS and LS3. Set them for another
  // department.
  // institute: "Institute of ...",
  // chair: "Department of ...",
  // A project or partner logo, centered on the title page.
  // additional-logo: image("assets/my-logo.png", width: 60mm),
  abstract: include "front-matter/abstract.typ",
  abbreviations: include "front-matter/abbreviations.typ",
  notation: include "front-matter/notation.typ",
  bib: bibliography("references.bib", style: "apa"),
)

#include "chapters/01-introduction.typ"
#include "chapters/02-work-completed.typ"
