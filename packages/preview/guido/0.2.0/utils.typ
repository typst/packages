// ************
// Utility functions
// ************

// Bar element for headers and footers
#let bar(
  color: auto,
) = rect(width: 100%, height: .3em, radius: .25em, stroke: none, fill: if color == auto { red.lighten(60%) } else {
  color
})

#let resized-title = layout(size => {
  let body = title()
  let font_size = text.size
  let max_width = size.width // Account for padding;

  let width = measure(text(size: font_size, body)).width

  while width > max_width and font_size > 14pt {
      font_size -= 0.2pt
      width = measure(text(size: font_size, body)).width
  }

  text(size: font_size, body)
})

#let cover(
  logo: emoji.book,
  subtitle: none,
  outline-depth: 2,
  font: "Days One",
) = page(header: none)[
  #align(center)[
    // Logo or title image
    #box(height: 5cm)[
      #if type(logo) == image {
        logo
      } else {
        text(4cm, logo)
      }
    ]

    // Title and subtitle
    #set text(32pt, font: font)
    #resized-title
    #if subtitle != none {
      block(above: 2em, text(14pt, weight: "regular")[#subtitle])
    }
  ]

  #v(1fr)
  #outline(depth: outline-depth)
]

#let card(
  title: "",
  color: gray,
  width: 100%,
  body
) = box(
  radius: 0.275em,
  stroke: 0.5pt + color,
  inset: 0pt,
  clip: true
)[
  #grid(
    columns: (width),
    grid.cell(
      fill: color.lighten(80%),
      inset: 0.8em,
      stroke: (bottom: 0.3pt + color),
      text(weight: 700, title)
    ),
    grid.cell(inset: 1em ,body)
  )
]


#let side-by-side(split: (1fr, 1fr), gap: 2em, ..parts) = grid(
  columns: split,
  gutter: gap,
  row-gutter: 0.5em,
  ..parts
)
