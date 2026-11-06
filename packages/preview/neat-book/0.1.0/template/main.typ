#import "@preview/neat-book:0.1.0": *

#show: neat-book.with(
  title: "数学之美",
  subtitle: "从清晰的思想，到优雅的书页",
  author: ("张三", "李四"),
  institution: "开放知识研究所",
  date: datetime(year: 2026, month: 10, day: 20),
  logo: image("assets/logo.svg", width: 22mm),
  // Partial font overrides are merged with the defaults.
  fonts: (
    chinese: "Noto Serif CJK SC",
    english: "Libertinus Serif",
    japanese: "Noto Serif CJK JP",
    mono: "DejaVu Sans Mono",
  ),
  references: bibliography("references.bib", title: [参考文献]),
  appendix: include "chapters/appendix.typ",
)

#include "chapters/foundations.typ"
#include "chapters/computation.typ"
