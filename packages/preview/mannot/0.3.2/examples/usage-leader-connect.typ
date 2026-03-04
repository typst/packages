#import "/src/lib.typ": *

#set page(width: auto, height: auto, margin: (x: 0cm, y: .2cm), fill: white)
#set text(16pt)
#show raw: set text(.5em)

#let lab(body) = rect(stroke: silver, inset: 2pt, text(size: .7em, font: "DejaVu Sans Mono", body))
#let annot = annot.with(pos: bottom + right, dy: 1em)

#table(
  columns: (8em, 8em, 8em),
  stroke: none,
  align: center,
  [
    #text(.5em)[(Default)]
  ],
  [],
  [],

  ```typc
  leader-connect: (
    center + horizon,
    ceter + horizon,
  )
  ```,
  ```typc
  leader-connect: (bottom, top)
  ```,
  ```typc
  leader-connect: "elbow"
  ```,

  pad(right: 3em, bottom: 2em)[
    $
      markhl(x, tag: #<1>)
      #annot(<1>)[annotation]
    $
  ],
  pad(right: 3em, bottom: 2em)[
    $
      markhl(x, tag: #<1>)
      #annot(<1>, leader-connect: (bottom, top))[annotation]
    $
  ],
  pad(right: 3em, bottom: 2em)[
    $
      markhl(x, tag: #<1>)
      #annot(<1>, leader-connect: "elbow")[annotation]
    $
  ],
)
