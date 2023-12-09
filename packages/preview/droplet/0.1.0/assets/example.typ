#import "../src/lib.typ": dropcap

#set text(size: 14pt)
#set page(
  width: 11cm,
  height: auto,
  margin: 1em,
  background: box(
    width: 100%,
    height: 100%,
    radius: 4pt,
    fill: white,
  ),
)

#dropcap(
  height: 3,
  justify: true,
  gap: 4pt,
  hanging-indent: 1em,
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
