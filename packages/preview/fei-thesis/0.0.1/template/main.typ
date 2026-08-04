#import "@preview/fei-thesis:0.0.1": *

#show: fei-thesis.with()

#set-variables((
  title: "Rozšírená šablóna záverečnej práce na FEI STU v Bratislave v systéme Typst",
  author: "RNDr. Juraj Chlpík, PhD.",
  reg-nr: "FEI-xxxx-xxxx",
  date: "31. decembra 2024",
  year: "2024",
  thesis-type: "Bakalárska práca",
  keywords: [záverečná práca, šablóna, Typst, formátovanie textu, citácie],
  keywords-en: [Final thesis, template, Typst, text formatting, citations],
  study-programme: "názov študijného programu",
  study-field: "názov študijného odboru",
  school: "Slovenská technická univerzita v Bratislave",
  faculty: "Fakulta elektrotechniky a informatiky",
  supervisor: "tituly Meno Priezvisko, tituly",
  consultant: "tituly Meno Priezvisko, tituly",
  training-workplace: "Názov školiaceho pracoviska",
))

#cover-page()
#title-page()
#fei-assignment(read("includes/assignment.pdf", encoding: none), pages: 2)


#fei-thanks[#include "includes/thanks.typ"]

#abstract(
  [
    #include "includes/abstractSK.typ"
  ],
  lang: "sk",
)

#abstract(
  [
    #include "includes/abstractEN.typ"
  ],
  lang: "en",
)

#fei-outline()
#fei-outline-tables()
#fei-outline-image()
#fei-list-of-glossaries[#abbr.load("includes/glossary.csv")]
// #fei-list-of-manual-glossaries[#include "includes/manual_glossary.typ"]
#fei-outline-code()

#show: start-numbering.with()

#introduction[#include "includes/introduction.typ"]

#main-matter[#include "includes/core.typ"]
#fei-conclusion[#include "includes/conclusion.typ"]

#bibliography("bibliography.bib")
#fei-ai-declaration[#include "includes/ai_declaration.typ"]

#appendix([#include "includes/appendixA.typ"], [Algoritmus])
#appendix([#include "includes/appendixB.typ"], [Výpis dlhého kódu])
#appendix([#include "includes/appendixC.typ"], [Slovníček pojmov])
