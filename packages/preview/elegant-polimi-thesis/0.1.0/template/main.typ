#import "@preview/elegant-polimi-thesis:0.1.0": *

#show: polimi-thesis

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

#show: mainmatter.with()

#heading("Introduction", numbering: none)

= First chapter

#lorem(100)

#show: backmatter.with()

// bibliography

#show: appendix.with()

= First appendix

#lorem(100)

#show: acknowledgements.with()

= Acknowledgements

#lorem(100)
