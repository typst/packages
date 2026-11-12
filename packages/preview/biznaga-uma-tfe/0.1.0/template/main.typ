#import "@preview/biznaga-uma-tfe:0.1.0": *

#show: thesis.with(
  title: "<TÍTULO DEL TRABAJO>",
  title-en: "<TÍTULO DEL TRABAJO EN INGLÉS>",
  author-name: "<AUTOR>",
  supervisor-name: "<TUTOR>",
  degree: "<TITULACIÓN>",
  year: "20XX",
  acronyms: csv("01-ini/acronyms.csv", row-type: dictionary),
  show-todos: true,
)

#set page(numbering: "I")
#counter(page).update(1)

#include "01-ini/cover.typ"
#include "01-ini/abstract-es.typ"
#include "01-ini/abstract.typ"

#include "01-ini/dedication.typ"
#include "01-ini/acknowledgements.typ"

#include "01-ini/acronyms.typ"

#show: index-style
#include "02-toc/toc.typ"
#include "02-toc/tof.typ"
#include "02-toc/tot.typ"
#include "02-toc/todo.typ"

#set page(numbering: "1")
#counter(page).update(1)

#include "03-cap/1-introduction.typ"
#include "03-cap/2-development.typ"

#show: appendices
#include "04-ape/a-appendix.typ"

#include "05-bib/bibliography.typ"
