// Auto-fit columns: the densest layout that nothing overflows or wraps into.
#import "@preview/taskize:0.2.10": tasks

#set page(width: 11cm, height: auto, margin: 6mm)
#set text(size: 11pt)

#let ratio(v) = table(
  columns: 4,
  align: center,
  inset: (x: 4pt, y: 3pt),
  stroke: 0.5pt,
  [Souris], [$6$], [$9$], [$7$],
  [Prix], [], [$#v$], [],
)

*Short items pack as tightly as they fit:*
#tasks(columns: "auto-fit")[
  + $2x = 8$
  + $x^2 = 49$
  + $sqrt(5)$
  + $pi$
]

*Rigid content keeps its natural width — two tables per row, not four:*
#tasks(columns: "auto-fit")[
  + #ratio("31,5")
  + #ratio("45,5")
  + #ratio("14,4")
  + #ratio("8")
]

*`"fill"` (default) — the wide item auto-spans, the answers stay dense:*
#tasks(columns: "auto-fit", max-columns: 4)[
  + Choose the correct answer for each question below.
  + Paris
  + London
  + Berlin
]

*`"uniform"` — every item must fit one plain column, so all rows back off:*
#tasks(columns: "auto-fit", auto-fit-mode: "uniform", max-columns: 4)[
  + Choose the correct answer for each question below.
  + Paris
  + London
  + Berlin
]
