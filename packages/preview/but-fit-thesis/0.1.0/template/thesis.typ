#import "@preview/but-fit-thesis:0.1.0": appendix, fit-thesis
#import "common.typ": *

#show: fit-thesis.with(
  // One of "bachelor", "master", "phd", "habilitation", or "term".
  type: "master",
  lang: "en",
  title: (
    en: [Thesis Title],
    cs: [Název práce],
  ),
  // Degrees, if wanted on the title page: before: "…", after: "…".
  author: (name: "Name", surname: "Surname"),
  supervisor: (name: "Name", surname: "Surname", before: "Ing.", after: "Ph.D."),
  // One of "UIFS", "UPSY", "UITS", "UPGM", or (en: [...], cs: [...]).
  department: "UIFS",
  year: 2026,
  abstract: (
    en: [The abstract in English.],
    cs: [Abstrakt v češtině.],
  ),
  keywords: (
    en: [keyword, keyword, keyword],
    cs: [klíčové slovo, klíčové slovo, klíčové slovo],
  ),
  declaration: [I hereby declare that this thesis was prepared as an original work by the author under the supervision of … I have listed all the literary sources, publications and other sources, which were used during the preparation of this thesis.],
  // acknowledgement: [I would like to thank …],
)

// Uncomment for the final version to hide all margin and inline notes.
// #set-margin-note-defaults(hidden: true)

#include "chapters/01-introduction.typ"
#include "chapters/02-abstract.typ"
#include "chapters/03-drafting-the-basic-thesis-structure.typ"
#include "chapters/04-individual-thesis-chapters.typ"
#include "chapters/05-rules-for-bibliographic-citations.typ"
#include "chapters/06-formal-aspect-of-a-thesis.typ"
#include "chapters/07-thesis-submission.typ"
#include "chapters/08-conclusion.typ"

// template.bib holds the references of the sample chapters; drop it with them.
#bibliography(
  ("bib/bibliography.yaml", "bib/template.bib"),
  style: "bib/iso-690-2022-numeric-ntk.csl",
)

// Appendices: chapters after this line are "Appendix A", "Appendix B", …
// #show: appendix
// #include "chapters/a1-something.typ"
