#import "@preview/elegant-polimi-thesis:0.1.1": *

#show: polimi-thesis.with(
  title: "Thesis Title",
  author: "Name Surname",
  advisor: "",
  coadvisor: "",
  tutor: "",
  academic-year: "", // defaults to current one
  cycle: "XXIV",
  chair: none,
  language: "en",
  colored-headings: true,
)

#show: theorems-init // if you don't plan to use theorems, proposition, lemmas or remarks this line can be removed

#show: frontmatter

= Abstract

#lorem(100)

= Sommario

#lorem(100)

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

#heading("Introduction", numbering: none)

#lorem(100)

= First chapter

#lorem(100)

#show: backmatter

// bibliography

#show: appendix

= First appendix

#lorem(100)

#show: acknowledgements

= Acknowledgements

#lorem(100)
