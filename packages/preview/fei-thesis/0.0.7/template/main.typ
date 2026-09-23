#import "@preview/fei-thesis:0.0.7": *

#show: fei-thesis.with(language: "sk")

#show: fei-setup.with((
  title: [Rozšírená šablóna záverečnej práce na FEI STU v~Bratislave v systéme Typst],
  author: "RNDr. Juraj Chlpík, PhD.",
  reg-nr: [FEI-xxxx-xxxx],
  date: [31. decembra 2024],
  year: [2024],
  thesis-type: [Bakalárska práca],
  study-programme: [názov študijného programu],
  study-field: [názov študijného odboru],
  school: [Slovenská technická univerzita v Bratislave],
  faculty: [Fakulta elektrotechniky a informatiky],
  supervisor: [tituly Meno Priezvisko, tituly],
  consultant: [tituly Meno Priezvisko, tituly],
  training-workplace: [Názov školiaceho pracoviska],
))

#fei-cover-page()
#fei-title-page()
#fei-assignment(read("includes/assignment.pdf", encoding: none), pages: 2)


#fei-thanks[#include "includes/thanks.typ"]

#fei-abstract(
  [
    #include "includes/abstractSK.typ"
  ],
  lang: "sk",
  [záverečná práca, šablóna, Typst, formátovanie textu, citácie],
)

#fei-abstract(
  [
    #include "includes/abstractEN.typ"
  ],
  lang: "en",
  [Final thesis, template, Typst, text formatting, citations],
)

#show: start-numbering.with()

#fei-outline()
#fei-list-of-glossaries[#abbr.load("includes/glossary.csv")]
#fei-outline-code()
#fei-outline-figures-tables()
// #fei-list-of-manual-glossaries[#include "includes/manual_glossary.typ"]


#fei-introduction[#include "includes/introduction.typ"]

#fei-core[#include "includes/core.typ"]
#fei-conclusion[#include "includes/conclusion.typ"]

#bibliography("bibliography.bib")
#fei-ai-declaration[#include "includes/ai_declaration.typ"]

#fei-appendix[
  #include "includes/appendixA.typ"
  #include "includes/appendixB.typ"
  #include "includes/appendixC.typ"
]
