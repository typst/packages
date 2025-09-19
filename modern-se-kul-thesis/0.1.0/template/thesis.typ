#import "@preview/modern-se-kul-thesis:0.1.0": template
#show: template.with(
  // Your title goes here
  title: "An example title",

  // subtitle: "With a subtitle",

  // Give or only the year you started in (eg: 2024), or a tuple with the start and end year (eg: (2024, 2040))
  academic-year: datetime.today().year(),

  // "Master's Thesis", "PhD Thesis", etc.
  // subtitle: "Master's Thesis",

  // Change to the name(s) of the author(s)
  authors: ("A guy", "Another guy"),

  // Change to the name(s) of the promotor(s)
  promotors: ("Prof. dr. ir. Man",),

  // Add as many co-supervisors as you needthe entry
  // if none are needed
  assessors: (
    "Assessor nr 1",
  ),

  // Change to your supervisor's name
  // remove if none are needed
  supervisors: (
    "A supervisor",
  ),

  // Customize with your own faculty and degree (should be in dutch if you are doing the dutch master)
  degree: (
    elective: "Software engineering",
    master: "Computerwetenschappen",
    color: (0, 0, 1, 0),
  ),

  // Change to "nl" for the Dutch template
  language: "en",
  english-master: false,
  font-size: 11pt,

  // set to true to remove extra title-page and have non-changing margins
  electronic-version: true,

  // Hayagriva bibliography is the default one, if you want to use a
  // BibTeX file, pass a .bib file instead (e.g. "works.bib")
  bibliography: bibliography("references.bib"),

  // Preface text
  preface: include "sections/preface.typ",
  // Abstract text
  // abstract: include "sections/main-text/abstract.typ",
  // dutch-summary: include "sections/main-text/dutch-abstract.typ",
  list-of-figures: true,
  list-of-listings: false,
  // abbreviations: include "sections/main-text/list-of-abbreviations-and-symbols.typ",
  symbols: none,

  // appendices: include "sections/appendix/appendix.typ",

  // pre-body-page:true,
)

#include "sections/chapter-1.typ"
