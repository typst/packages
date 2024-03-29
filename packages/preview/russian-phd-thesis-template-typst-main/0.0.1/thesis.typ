
#import "./thesis/template.typ": *

#include "./thesis/parts/title.typ"

// Определение шаблона 
#show: phd-template.with(
  // Это может быть удалено, если не используется программный код:
  languages: (
    rust: 
      (name: "Rust", 
      icon: icon("../images/brand-rust.svg"), 
      color: rgb("#CE412B")),
    python: 
     (name: "Python",
     icon: icon("../images/brand-python.svg"),
     color: rgb("#3572A5"))
  ),
)


// Содержание 
// #align(right)[Стр.]
#outline(title: "Содержание", indent: 1.5em, depth: 3,)

// Основные части документа 
#include "./thesis/parts/intro.typ"
#show heading.where(level:1): set heading(numbering: "Глава 1.")
#include "./thesis/parts/part1.typ"
#include "./thesis/parts/part2.typ"
#include "./thesis/parts/part3.typ"

// Выключить нумерацию выходных данных 
#show heading: set heading(numbering:none)

// Заключение 
#include "./thesis/parts/conclusion.typ"

// Выходные данные
= Список сокращений и условных обозначений 
#import "./common/acronyms.typ": acronyms-entries
#import "./common/symbols.typ": symbols-entries
#print-glossary(acronyms-entries+symbols-entries)

= Словарь терминов 
#import "./common/glossary.typ": glossary-entries
#print-glossary(glossary-entries)

#bibliography(title: "Список литературы", ("./common/external.bib","./common/author.bib"), style: "ieee")

#show outline: set heading(outlined: true)

#outline(title: "Список рисунков", target: figure.where(kind: image))

#outline(title: "Список таблиц", target: figure.where(kind: table))

// Приложения 
#include "./thesis/parts/appendix.typ"