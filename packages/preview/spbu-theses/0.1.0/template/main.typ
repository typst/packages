#import "@preview/spbu-theses:0.1.0": template, toc, special-section, glossary, print-glossary, appendix

#let acronyms = (
  "НИР": (
    long: "научно-исследовательская работа",
    твор: "научно-исследовательской работой",
  ),
  "СУБД": (
    long: "система управления базами данных",
    твор: "системой управления базами данных",
  ),
)

#show: template.with(
  title: [Пример оформления отчёта о научно-исследовательской работе],
  author: "Иванов Иван Иванович, группа 00.Б00-ПУ",
  organization: "САНКТ-ПЕТЕРБУРГСКИЙ ГОСУДАРСТВЕННЫЙ УНИВЕРСИТЕТ",
  doc-type: "ОТЧЁТ О НАУЧНО-ИССЛЕДОВАТЕЛЬСКОЙ РАБОТЕ",
  direction: "00.03.00 Направление подготовки",
  program: "Образовательная программа",
  supervisor: "Петров Пётр Петрович",
  supervisor-degree: "доцент",
  supervisor-department: "кафедра информатики",
  city: "Санкт-Петербург",
  year: "2026",
  acronyms: acronyms,
)

#special-section[ВВЕДЕНИЕ]

#include "sections/intro.typ"

#pagebreak()

#special-section[Постановка задачи]

#include "sections/task.typ"

#pagebreak()

#include "sections/body/_init.typ"

#pagebreak()

#special-section[ЗАКЛЮЧЕНИЕ]

#include "sections/conclusion.typ"

#pagebreak()

#special-section[СПИСОК ИСПОЛЬЗОВАННЫХ ИСТОЧНИКОВ]

#include "sections/biblio.typ"

#appendix("А", "Дополнительные материалы")[
  #include "sections/appendix-a.typ"
]
