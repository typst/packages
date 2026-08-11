#import "@preview/elegant-polimi-thesis:0.1.1": *

#show: polimi-thesis.with(
  title: [`elegant-polimi-thesis` manual],
  author: "Vittorio Robecchi",
  language: "en",
)

#show: theorems-init

#show: frontmatter

// #include "sections/abstract.typ"

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

#show: mainmatter

#include "sections/chapter_1.typ"
#include "sections/chapter_2.typ"

#show: appendix

#include "sections/appendix_1.typ"

#show: acknowledgements

#include "sections/acknowledgements.typ"

#show: backmatter

#bibliography(
  "Thesis_bibliography.bib",
  full: true,
)
