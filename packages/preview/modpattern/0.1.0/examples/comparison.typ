#import "../main.typ": *

#set page(height: auto, width: auto, margin: 10pt)

#let patterncontents = (
  "diagonal line": line(start: (0%,0%), end: (100%, 100%)),
  "weird lines": {
    place(line(start: (0%,0%), end: (100%, 100%)))
    place(line(start: (0%,0%), end: (50%, 100%)))
    place(line(start: (50%,0%), end: (100%, 100%)))
  },
  "circles": circle(),
  "simple math": $x$,
  "explained": box(height: 100%, width: 100%, stroke: red + 0.2pt, $x$),
  "math": $x^n$,
  "fun": $()$,
  "more fun": $sum$,
)
#set text(8pt)
#table(
  columns: 3,
  [], [pattern], [modpattern],
  ..patterncontents.pairs().map(
    ((k, v)) => (k, rect(fill: pattern(size: (10pt, 5pt), v)), rect(fill: modpattern((10pt, 5pt), v)))
  ).flatten()
)