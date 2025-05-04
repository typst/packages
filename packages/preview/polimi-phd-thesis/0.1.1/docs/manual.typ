#import "@preview/polimi-phd-thesis:0.1.1": *

#show: polimi-thesis.with(
  title: [`polimi-phd-thesis` manual],
  author: "Vittorio Robecchi",
  language: "en",
)

#show: frontmatter.with()

#include "sections/abstract.typ"

#toc
#list-of-figures
#list-of-tables

#let nomenclature_ = (
  "Polimi": "Politecnico di Milano",
  "CdL": "Corso di Laurea",
  "CCS": "Consigli di Corsi di Studio",
  "CFU": "Crediti Formativi Universitari",
)

#nomenclature(
  nomenclature_,
  indented: false,
)

#show: mainmatter.with()

#include "sections/chapter_1.typ"
#include "sections/chapter_2.typ"

#show: appendix.with()

#include "sections/appendix_1.typ"
#include "sections/appendix_2.typ"

#show: acknowledgements.with()

#include "sections/acknowledgements.typ"

#show: backmatter.with()

#bibliography(
  "../template/Thesis_bibliography.bib",
  full: true,
)
