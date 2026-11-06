#import "@preview/ls3-uni-stuttgart-dissertation:0.1.0": dissertation
#import "@preview/abbr:0.3.1"

// Define every abbreviation once. First use expands to the long form
// with the short form in parentheses; later uses render the short form.
#abbr.make(
  ("UQ", "Uncertainty Quantification"),
  ("MC", "Monte Carlo"),
  ("PDE", "Partial Differential Equation"),
)
#show: abbr.show-rule

#show: dissertation.with(
  title: [On the Optimization and Uncertainty Quantification of Groundwater Models],
  author: "Maxime Mustermann",
  birthplace: "Stuttgart",
  year: "2026",
  language: "english",
  // "a4" for the manuscript submitted to the faculty, "a5" for the
  // printed Mitteilungsheft.
  paper: "a4",
  // "submitted" until the Promotionsausschuss accepts the dissertation,
  // then "accepted" for the print version.
  status: "submitted",
  // "dr-ing-male", "dr-ing-female", "dr-rer-nat-male", or
  // "dr-rer-nat-female". Picks e.g. "eines Doktor-Ingenieurs" or
  // "einer Doktor-Ingenieurin" on the title page.
  degree: "dr-ing-female",
  // true for promotions through SC SimTech, adds "und dem Stuttgart
  // Center for Simulation Science" after the faculty.
  simtech: false,
  hauptberichter: "Prof. Dr.-Ing. Erika Beispiel",
  // All Mitberichter, listed below one "Mitberichter:" label.
  mitberichter: ("Prof. Dr. rer. nat. Max Muster",),
  // Shown on the title page only once status is "accepted".
  exam-date: "24. April 2026",
  // English Abstract and German Zusammenfassung, two to four pages each.
  abstract-en: include "front-matter/abstract.typ",
  abstract-de: include "front-matter/zusammenfassung.typ",
  abbreviations: include "front-matter/abbreviations.typ",
  notation: include "front-matter/notation.typ",
  danksagung: include "front-matter/danksagung.typ",
  // Uncomment for the Mitteilungsheft print publication. Adds a blank
  // page for the series title page from the institute, then the VLB
  // page. Heft number and ISBN come from the institute.
  // vlb: (
  //   heft: "320",
  //   isbn: "978-3-910293-00-0",
  //   printer: "P+K Solutions GmbH & Co. KG, Stuttgart",
  // ),
  declaration: true,
  appendix: include "back-matter/appendix.typ",
  // Printed only while status is "submitted", the published version
  // leaves it out.
  lebenslauf: include "back-matter/lebenslauf.typ",
  bib: bibliography("references.bib", style: "apa"),
)

#include "chapters/01-introduction.typ"
#include "chapters/02-methods.typ"
