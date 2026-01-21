
#import "@preview/modern-russian-dissertation:0.0.1": *

// Определение шаблона 
#show: template.with(
  // Это может быть удалено, если не используется программный код:
  languages: (
    rust: 
      (name: "Rust", 
      icon: icon(image("images/brand-rust.svg")), 
      color: rgb("#CE412B")),
    python: 
     (name: "Python",
     icon: icon(image("images/brand-python.svg")),
     color: rgb("#3572A5"))
  ),
  logo: image("./images/logo.svg",width: 50%),
)

// Основные части документа 
#include "./parts/intro.typ"
#show heading.where(level:1): set heading(numbering: "Глава 1.")
#include "./parts/part1.typ"
#include "./parts/part2.typ"
#include "./parts/part3.typ"

// Выключить нумерацию выходных данных 
#show heading: set heading(numbering:none)

// Заключение 
#include "./parts/conclusion.typ"

// Выходные данные
= Список сокращений и условных обозначений 
#import "./common/acronyms.typ": acronyms-entries
#import "./common/symbols.typ": symbols-entries
#print-glossary(acronyms-entries+symbols-entries)

= Словарь терминов 
#import "./common/glossary.typ": glossary-entries
#print-glossary(glossary-entries)

#bibliography(title: "Список литературы", ("./common/external.bib","./common/author.bib"), style: "gost-r-705-2008-numeric")

#show outline: set heading(outlined: true)

#outline(title: "Список рисунков", target: figure.where(kind: image))

#outline(title: "Список таблиц", target: figure.where(kind: table))

// Приложения 
#include "./parts/appendix.typ"