#import "meta.typ" as meta
#import "@preview/modern-whs-thesis:0.6.0": *
#import "chapters/00_abstract.typ" as abstract
#import "chapters/99_appendix.typ" as appendix
#import "acronyms.typ" as acronyms

#show: whs-thesis.with(
  title: meta.title,
  title-size: meta.title-size,
  thesis-type: meta.thesis-type,
  author: meta.author,
  first-name: meta.first-name,
  last-name: meta.last-name,
  date: meta.date,
  date-of-submission: meta.date-of-submission,
  place-location: meta.place-location,
  place-birth: meta.place-birth,
  keywords: meta.keywords,
  degree: meta.degree,
  study-course: meta.study-course,
  department: meta.department,
  first-examiner: meta.first-examiner,
  second-examiner: meta.second-examiner,
  signature: image("images/signature.png", height: 75pt), // none to disable
  abstract: [#abstract], // none to disable
  appendix: [#appendix], // none to disable
  bibliography: meta.bibliography, // none to disable
  acronyms: acronyms.acronyms, // none to disable
  language: meta.language,
  citation-style: meta.citation-style,
  // background: "default", "gray", or a custom image()
  // font: "TeX Gyre Heros",
  // math-font: "New Computer Modern Math",
  // raw-font: "Fira Code",
)

// ---------------- Main ------------------

#include "chapters/01_introduction.typ"
#include "chapters/02_definitions.typ"
#include "chapters/03_concept.typ"
#include "chapters/04_implementation.typ"
#include "chapters/05_conclusion.typ"
