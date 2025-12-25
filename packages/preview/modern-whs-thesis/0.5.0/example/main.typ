#import "meta.typ" as meta
#import "@preview/modern-whs-thesis:0.4.0": *
#import "chapters/00_abstract.typ" as abstract
#import "chapters/99_appendix.typ" as appendix
#import "acronyms.typ" as acronyms

#show: whs-thesis.with(
  meta.title,
  meta.title-size,
  meta.author,
  meta.first-name,
  meta.last-name,
  meta.date,
  meta.keywords,
  [#abstract],
  [#appendix],
  meta.bibliography,
  acronyms.acronyms,
  meta.degree,
  meta.place-location,
  meta.thesis-type,
  meta.study-course,
  meta.department,
  meta.first-examiner,
  meta.second-examiner,
  meta.date-of-submission,
  meta.language,
  meta.citation-style,
  image("images/signature.png", height: 75pt),
)

// ---------------- Main ------------------

#include "chapters/01_introduction.typ"
#include "chapters/02_definitions.typ"
#include "chapters/03_concept.typ"
#include "chapters/04_implementation.typ"
#include "chapters/05_conclusion.typ"
