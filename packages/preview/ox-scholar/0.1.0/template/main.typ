#import "@preview/ox-scholar:0.1.0": *

#show: thesis.with(
  title: "Thesis Title",
  author: "Author",
  college: "College",
  degree: "Doctor of Philosophy",
  submission-term: "Submission Term, Year",
  acknowledgements: include "content/acknowledgements.typ",
  abstract: include "content/abstract.typ",
  logo: image("assets/beltcrest.png", width: 4.5cm),
  show-toc: true,
  bib: bibliography(
    "content/bibliography.bib",
    title: "References",
  ),
)

#include "content/section01.typ"
