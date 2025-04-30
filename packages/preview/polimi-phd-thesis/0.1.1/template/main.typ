#import "@preview/polimi-phd-thesis:0.1.1": *

#show: polimi_thesis.with()

#show: frontmatter.with()

= Abstract

#lorem(100)

= Sommario

#lorem(100)

#toc
#list_of_figures
#list_of_tables
#let nomenclature_ = (
  "Polimi": "Politecnico di Milano",
  "CdL": "Corso di Laurea",
  "CCS": "Consigli di Corsi di Studio",
  "CFU": "Crediti Formativi Universitari"
)
#nomenclature(
  nomenclature_,
  indented: false
)

#show: mainmatter.with()

#heading("Introduction", numbering: none)

= First chapter

#lorem(100)

#show: backmatter.with()

#bibliography(
  "Thesis_bibliography.bib",
  full: true,
)

#show: appendix.with()

= First appendix

#lorem(100)

#show: acknowledgements.with()

= Acknowledgements

#lorem(100)
