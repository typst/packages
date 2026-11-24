// Example dissertation using the kaodiss template. For a book, set
// degree-type and degree to none and leave out supervisors, abstract etc.
// Compile with:  typst compile main.typ
// (requires the fonts TeX Gyre Pagella, Pagella Math and Heros, see README)
#import "@preview/kaodiss:0.1.0": *

#show: kaodiss.with(
  lang: "en",
  title: [The Title of the Thesis \ in Two Lines],
  subtitle: [A Subtitle That Explains \ What the Work Is About],
  author: "Jane Doe",
  degree: "Doctor of Philosophy (Ph.D.)",
  university: "Example University",
  department: "Department of Computer Science",
  chair: "Research Group on Example Systems",
  place: "Example City",
  date: datetime(year: 2026, month: 10, day: 1),
  // The first logo is placed in the middle of the title page.
  // logos: (image("figures/logo.pdf", height: 40mm),),
  supervisors: (
    [Prof. Ada Lovelace \ Department of Computer Science \ Example University],
  ),
  advisors: (
    [Prof. Alan Turing \ Department of Computer Science \ Example University],
    [Prof. Grace Hopper \ Institute of Software Engineering \ Another University],
  ),
  defense: datetime(year: 2026, month: 12, day: 19),
  transparency: [The readability of this text has been improved with the support of AI technologies.],
  abstract: include "chapters/abstract.typ",
  // second abstract in another language (set with its hyphenation and quotes)
  abstract-2: include "chapters/zusammenfassung.typ",
  abstract-2-lang: "de",
  acknowledgements: include "chapters/acknowledgements.typ",
  bibliography: bibliography("references.bib"),
  // "nature-authoryear" (default), "alphadin" or "ieee"
  citation-style: "nature-authoryear",
  abbreviations: (
    pdf: ("PDF", "Portable Document Format"),
    ui: ("UI", "User Interface"),
    api: (short: "API", long: "Application Programming Interface"),
    csv: (short: "CSV", long: "Comma-separated Values"),
  ),
  glossary: (
    kerning: (name: "Kerning", description: [The adjustment of the space between two particular letters.]),
  ),
  // Colours: none = black/grey (default); a palette
  // ("ocean", "forest", "berry"); or your own colours for the five roles:
  // colors: (
  //   primary: rgb("#1d4e89"),    // chapter/section numbers, rules, list markers
  //   link: rgb("#1f78a8"),       // citation years, cross-references, URLs
  //   challenge: rgb("#b5403a"),  // Challenge boxes
  //   objective: rgb("#2f7d5b"),  // Objective boxes
  //   definition: rgb("#1d4e89"), // Definition, theorem, example boxes
  // ),
  colors: none,
  box-style: "tinted", // or "bar", "banner"
  // "front" (after the table of contents, as in kaobook) or "back" (after the bibliography)
  lists-position: "front",
  appendix: include "chapters/appendix.typ",
  declaration: include "chapters/declaration.typ",
)

#part[Introduction and Foundations]
#include "chapters/introduction.typ"
#include "chapters/foundations.typ"

#part[Contribution][A Second Line for the Part]
#include "chapters/features.typ"
