// EXAMPLES OF USE
#import "@preview/nonodraw:1.0.0": *
#import "./examples-matrices.typ": *

#set page(margin: 5mm, width: auto, height: auto)

// Classical sober style
#let style-1 = classical-board.with(
  weak-stroke: (thickness: 0.25pt, paint: black, dash: "solid"),
  strong-stroke: (thickness: 1pt, paint: black, dash: "solid"),
  clue-draw-parallel-weak-strokes: true,
  clue-draw-parallel-strong-strokes: true,
  clue-draw-perpendicular-strokes: false,
  clue-close-opposite-strokes: false,
)

// More modern variation of classical style
#let style-2 = classical-board.with(
  font: "Roboto",
  weak-stroke: (thickness: 0.45pt, paint: navy, dash: "densely-dotted"),
  strong-stroke: (thickness: 1pt, paint: navy, dash: "solid"),
  clue-default-background: navy.lighten(95%).saturate(5%),
  clue-draw-parallel-weak-strokes: true,
  clue-draw-parallel-strong-strokes: true,
  clue-draw-perpendicular-strokes: true,
  clue-close-opposite-strokes: true,
  // Stroke the corner cell to have a more square look
  corner-cell-drawer: (height, width) => grid.cell(
    rowspan: height,
    colspan: width,
    fill: navy.lighten(90%).saturate(10%),
    stroke: (thickness: 1pt, paint: navy, dash: "solid"),
    "",
  ),
  // Navy color instead of black as default
  color-map: (
    ..default-color-map,
    "default": navy,
  ),
  // Crossed cells are replaced with a single diagonal line. Default fill is replaced with a smaller filled block
  content-map: (
    "0": block(height: 100%, width: 100%)[
      #place(center + horizon, rotate(-45deg, line(length: 1em, stroke: (
        thickness: 1pt,
        paint: navy.lighten(50%),
        cap: "round",
      ))))
    ],
    "default": block(height: 70%, width: 70%, radius: 0.1em),
  ),
  // When the cell corresponds to a filled block, we apply the color as fill
  cell-colorizer: (content, color, value) => {
    set text(fill: color)
    if (value != 0) {
      set block(fill: color)
      content
    } else {
      content
    }
  },
  // We make the text for clues a bit smaller
  clue-text-processor: value => text(0.8em, value),
  clue-coloring: "background",
)

// The boards with solution shown

#style-1(
  show-solution: true,
  board-monocolor,
)

#pagebreak()

#style-2(
  show-solution: true,
  board-monocolor,
)

#pagebreak()

#modern-board(
  show-solution: true,
  board-monocolor,
)

#pagebreak()

#style-1(
  show-solution: true,
  clue-omit-default-background: false,
  board-multicolor,
)

#pagebreak()

#style-2(
  clue-omit-default-background: false,
  show-solution: true,
  board-multicolor,
)

#pagebreak()

#modern-board(
  clue-omit-default-background: false,
  show-solution: true,
  board-multicolor,
)

#pagebreak()

// The boards with solution hidden

#style-1(
  show-solution: false,
  board-monocolor,
)

#pagebreak()

#style-2(
  show-solution: false,
  board-monocolor,
)

#pagebreak()

#modern-board(
  show-solution: false,
  board-monocolor,
)

#pagebreak()

// Example of only solution shown, without clues, in a compact manner

#let solution-style = classical-board.with(
  show-solution: true,
  hide-clues: true,
  weak-stroke: none,
  strong-stroke: 1pt + red,
  cell-size: 4pt,
  content-map: (
    "0": none,
    "1": "fill",
  ),
)

// Example of creating the board only from the clues

#solution-style(
  board-monocolor,
)

#pagebreak()

// Example with manual clues and no predefined solution shown.
#classical-board(
  show-solution: false,
  none,
  column-clues: (
    (2, 1),
    (1, 1),
    (1, 3),
    (1, 2),
    (1, 1),
  ),
  row-clues: (
    (2,),
    (1, 2),
    (3,),
    (3,),
    (1, 2),
  ),
)

#pagebreak()

// Example with partially shown board using display mask, and some clues marked.
#classical-board(
  show-solution: true,
  (
    (1, 0, 0, 0, 1),
    (1, 0, 0, 0, 1),
    (1, 1, 1, 0, 0),
    (1, 1, 1, 0, 0),
    (1, 0, 1, 0, 0),
  ),
  display-mask: (
    (1, 1, 1, 0, 0),
    (1, 1, 0, 0, 0),
    (1, 1, 0, 0, 0),
    (1, 1, 0, 0, 0),
    (1, 1, 1, 1, 0),
  ),
  marked-column-clues: ((0,0), (1,0)),
  marked-row-clues: ((0,0), (1,0), (4,0), (4,1)),
)

#pagebreak()

// Example using matrix generated from text.
#classical-board(
  show-solution: true,
  text-to-matrix(
   "11011
    10001
    11100
    11100
    10100"
  ),
)

#pagebreak()

// Example of using text-processor to make numbers with at least two digits more compact. Also, with column and row guides shown.

#classical-board(
  show-solution: false,
  text-to-matrix(
   "1100111111001100000111011
    1100111111011110111111111
    1110111111011111111111111
    1110011111011111111111111
    1011001000000111111111111
    1001111111001100000111011
    1001111111111110111111111
    1111111111111110111111111
    1110011111111110111111111
    1010001000000111111111111
    1000111111001100000111011
    1000111111111110111111111
    1111111111111111111111111
    1110010111111111111111111
    1010001000000111111111111
    1101111111001101000111011
    1000111111111111111111111
    1111111111111111111111111
    1110011111111111111111111
    1010001000100111111111111
    1101111111011100000111011
    1000111111111110111111111
    1111111111001111111111111
    1110011111111110111111111
    1010001000000111111111111
  "
  ),font: "DejaVu Sans Mono",
  show-guide-numbers: true,
  clue-draw-parallel-weak-strokes: true,
  clue-text-processor: t => {
    if int(t) > 9 {
      scale(text(tracking: -1pt, t), x: 75%)
    } else {
      t
    }
  },
)

#pagebreak()

// Example using fully custom clue content drawer.
#classical-board(
  show-solution: true,
  text-to-matrix(
   "0000◢◢0000
    0000◤◤◢◢◢◢
    000◢■■◣■■◤
    00◢◢■■◥◣■◤
    0◢■■■◤◥■◣◤
    0■■00◥◣0◥◣
    0◤◤000◣◥◣■
    000000■◢◥◥
    00000◢■■◣0
    00000◣0■◤0",
    char-to-value: char => if char == "0" { 0 } else { char},
  ),
  // How cells are drawn
  content-map: (
    "0": none,
    "■": "fill",
    "◢": polygon(fill: black,(100%, 0%), (0%, 100%), (100%, 100%)),
    "◣": polygon(fill: black,(0%, 0%), (0%, 100%), (100%, 100%)),
    "◤": polygon(fill: black,(0%, 100%), (0%, 0%), (100%, 0%)),
    "◥": polygon(fill: black,(0%, 0%), (100%, 0%), (100%, 100%)),
  ),
  font: "Dejavu Sans Mono",
  clue-draw-parallel-weak-strokes: true,
  // How clue content is drawn
  clue-content-drawer: (value, count, row, col, additional-info) => {
    // We only display counts greater than 1
    if count == 1 {
      count = ""
    } else if count != none {
      count = str(count)
    }
    set text(0.9em,weight: 999, fill: white, stroke: 0.5pt, font: "Dejavu Sans Mono")
    if value == "■" {
      place(center+horizon, block(width:100%, height: 100%, fill:black, count))
    } else if value == "◢" {
      polygon(fill: black,(100%, 0%), (0%, 100%), (100%, 100%))
      place(center+horizon, count)
    } else if value == "◣" {
      polygon(fill: black,(0%, 0%), (0%, 100%), (100%, 100%))
      place(center+horizon, count)
    } else if value == "◤" {
      polygon(fill: black,(0%, 100%), (0%, 0%), (100%, 0%))
      place(center+horizon, count)
    } else if value == "◥" {
      polygon(fill: black,(0%, 0%), (100%, 0%), (100%, 100%))
      place(center+horizon, count)
    }
  },
)