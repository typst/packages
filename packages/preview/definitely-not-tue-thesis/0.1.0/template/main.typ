#import "@preview/definitely-not-tue-thesis:0.1.0": thesis, appendix, backmatter, list-of-todos
#import "@preview/glossarium:0.5.10": make-glossary, register-glossary, print-glossary
#import "@preview/in-dexter:0.7.2": make-index
#import "frontback/glossary.typ": glossary-entries
#import "@preview/retrofit:0.2.0": backrefs

#let draft = true

#show: make-glossary
#register-glossary(glossary-entries)

#show: backrefs.with(
  format: links => text(size: 0.85em, fill: gray.darken(20%))[
    (Cited on #if links.len() == 1 [page] else [pages] #links.join(", ", last: " and ").)
  ],
  read: path => read(path),
)

#show: thesis.with(
  title: [My Thesis Title],
  author: "J. Smith",
  degree: "Doctor of Philosophy",
  university: "Eindhoven University of Technology",
  faculty: "Mathematics and Computer Science",
  department: "Information Systems",
  supervisors: ("prof.dr. First Supervisor", "dr. Second Supervisor"),
  location: "Eindhoven",
  date: datetime.today(),
  keywords: ("keyword1", "keyword2"),
  version: "v0.1-skeleton",
  draft: draft,
  dedication: include "frontback/dedication.typ",
  abstract: include "frontback/abstract.typ",
)

#include "chapters/01_intro.typ"
#include "chapters/02_preliminaries.typ"
#include "chapters/03_chapter_one.typ"
#include "chapters/04_chapter_two.typ"
#include "chapters/05_conclusion.typ"

#show: appendix
#include "chapters/99_appendix.typ"

#show: backmatter

// retrofit's cell counter desyncs when the chapter-opening show rule (with its
// weak pagebreak) transforms the heading inside the bibliography; keep the
// heading outside and suppress the built-in one.
#heading(level: 1, [Bibliography])
#bibliography("refs.bib", style: "ieee", title: none)

#heading(level: 1, [Glossary])
#print-glossary(glossary-entries)

#heading(level: 1, [Index])
#columns(2, make-index(use-page-counter: true))

#include "frontback/summary.typ"
#include "frontback/acknowledgments.typ"
#include "frontback/cv.typ"

#if draft { list-of-todos() }
