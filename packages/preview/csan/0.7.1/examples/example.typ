// Example document for the csan Typst package.
// `just typst figures` renders it to examples/example.png, which the README
// shows; `just typst examples-check` compiles it against the bundle.

#import "@preview/csan:0.7.1": cutter-loc, cutter-sanborn

#set page(width: auto, height: auto, margin: 1cm, fill: white)

= Cutter call numbers with csan

// @typstyle off: a row of the table to a line
#table(
  columns: 4,
  table.header([*Author*], [*Title*], [*Cutter-Sanborn*], [*LoC*]),
  [Charles Dickens], [Oliver Twist],
  [#cutter-sanborn(
      forename: "Charles",
      surname: "Dickens",
      title: "Oliver Twist",
    )],
  [#cutter-loc(surname: "Dickens")],

  [Jorge Luis Borges], [Ficciones],
  [#cutter-sanborn(surname: "Borges", title: "Ficciones")],
  [#cutter-loc(surname: "Borges")],

  [—], [100 best hamburger recipes],
  [#cutter-sanborn(title: "100 best hamburger recipes")],
  [#cutter-loc(title: "100 best hamburger recipes")],
)

A spine label for _Oliver Twist_, classed at Dewey 823.8:

#box(stroke: 0.5pt, inset: 8pt, align(center, text(font: "DejaVu Sans Mono")[
  823.8 \
  #cutter-sanborn(
    forename: "Charles",
    surname: "Dickens",
    title: "Oliver Twist",
  )
]))
