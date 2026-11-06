#import "@preview/droplet:0.3.1": dropcap

#set par(justify: true)
#set text(size: 14pt)
#set page(
  width: 11cm + 16pt,
  height: auto,
  margin: (x: 1em + 8pt, y: 1em),
  fill: none,
  background: pad(0.5pt, box(
    width: 100%,
    height: 100%,
    radius: 4pt,
    fill: white,
    stroke: white.darken(10%),
  )),
)

#dropcap(
  height: 3,
  gap: 4pt,
  hanging-indent: 1em,
  overhang: 8pt,
  font: "Curlz MT",
)[
  *Typst* is a new markup-based typesetting system that is designed to be as _powerful_ as LaTeX while being _much easier_ to learn and use. Typst has:

  - Built-in markup for the most common formatting tasks
  - Flexible functions for everything else
  - A tightly integrated scripting system
  - Math typesetting, bibliography management, and more
  - Fast compile times thanks to incremental compilation
  - Friendly error messages in case something goes wrong
]
