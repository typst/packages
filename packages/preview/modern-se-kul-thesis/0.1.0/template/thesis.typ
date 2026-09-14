#import "@preview/modern-se-kul-thesis:0.1.0": template
#show: template.with(
  title: "An example title",
  // subtitle: "With a subtitle",
  academic-year: datetime.today().year(),
  authors: ("A guy", "Another guy"),
  promotors: ("Prof. dr. ir. Man",),
  assessors: (
    "Assessor nr 1",
  ),
  supervisors: (
    "A supervisor",
  ),
  // Customize with your own faculty and degree (should be in dutch if you are doing the dutch master)
  degree: (
    elective: "Software engineering",
    master: "Computerwetenschappen",
    color: (0, 0, 1, 0),
  ),
  language: "en",
  english-master: false,
  font-size: 11pt,
  // set to true to remove extra title-page and have non-changing margins
  electronic-version: true,
  // Hayagriva bibliography is the default one, if you want to use a
  // BibTeX file, pass a .bib file instead (e.g. "works.bib")
  bibliography: bibliography("references.bib"),
  preface: include "sections/preface.typ",
  // abstract: include "sections/main-text/abstract.typ",
  // dutch-summary: include "sections/main-text/dutch-abstract.typ",
  list-of-figures: true,
  list-of-listings: false,
  // abbreviations: include "sections/main-text/list-of-abbreviations-and-symbols.typ",
  symbols: none,
  // appendices: include "sections/appendix/appendix.typ",
  // Make sure that this is the correct logo for the correct master (en/nl)!
  logo: [#text(size: 3em, fill: gradient.linear(..color.map.turbo))[Fix logo]],
)

#include "sections/chapter-1.typ"
