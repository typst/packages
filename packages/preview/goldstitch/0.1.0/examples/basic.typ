#import "@preview/goldstitch:0.1.0": goldstone, kallay-label

#set page(width: auto, height: auto, margin: 8mm)
#set text(size: 10pt)

#let labelled(code) = stack(
  dir: ttb,
  spacing: 2mm,
  goldstone(code),
  align(center, text(size: 8pt, kallay-label(code))),
)

#grid(
  columns: (auto, auto),
  gutter: 10mm,
  row-gutter: 8mm,
  align: center + horizon,
  labelled("220 000 000 000 4"),
  labelled("111 220 000 000 7"),
  labelled("111 111 220 000 10"),
  labelled("220 222 000 000 10"),
  labelled(((1, 1, 1), (1, 2, 1), (0, 0, 0), (0, 0, 0), 6)),
  labelled(((1, 1, 0), (1, 2, 1), (3, 1, 1), (0, 0, 0), 10)),
  labelled(((1, 1, 0), (1, 1, 0), (1, 1, 1), (1, 1, 1), 10)),
)
