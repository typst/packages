#import "../lib.typ": qfd
#set page(width: auto, height: auto, margin: 8mm)
#set text(font: ("IBM Plex Sans", "New Computer Modern"), size: 9pt)
#text(size: 16pt, weight: "bold")[A first House of Quality]
#v(3mm)
#qfd(
  whats: ([Easy to prepare], [Easy to clean]),
  hows: ([Guide the sequence], [Collect the drips]),
  importance: (5, 3), relations: ((1, 1, "S"), (1, 2, "W"), (2, 2, "S")),
  directions: ("minimize", "maximize"),
  targets: ([Few steps], [Three drinks]),
  correlations: ((1, 2, "+"),),
  width: auto,
)
#v(2mm)
Illustrative judgments: S = 9, M = 3, W = 1.
