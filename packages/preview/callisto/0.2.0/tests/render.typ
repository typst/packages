#import "/src/callisto.typ" as callisto: *

= Julia notebook
#let (Cell, In, Out) = callisto.config(
  nb: "/tests/notebooks/julia.ipynb",
)

== Cell 2
#Cell(2)

=== Rendered input
#In(2, template: "plain")

=== Rendered output (framed)
#block(stroke: 1pt, Out(2))

==  Cell with execution count = 3

=== Rendered error
#Out(3, count: "execution", output-type: "error")

=== Same but with `plain` template
#Out(3, count: "execution", output-type: "error", template: "plain")

#pagebreak()

= Julia notebook: Markdown and code cells\ (only source and result, no display)
#v(1em)
#render(
  nb: "/tests/notebooks/julia.ipynb",
  cell-type: ("markdown", "code"),
  output-type: "execute_result",
)
#pagebreak()

= Python notebook
#render(nb: "/tests/notebooks/python.ipynb")

#pagebreak()

= Python notebook with `plain` template, styled raw blocks

#let (render,) = callisto.config(
  nb: "/tests/notebooks/python.ipynb",
  template: "plain",
)
#[
  #show raw.where(block: true, lang: "python"): set block(
    inset: (left: 1.2em, y: 1em),
    stroke: (left: 3pt+luma(96%)),
  )
  #render()
]
#pagebreak()

= Python notebook with custom template for `code` cells

#render(template: (
  code: (c, ..args) => block(inset: (left: 1em), spacing: 2em)[
    [cell #c.index]
    #raw(block: true, c.source)
  ],
  markdown: "plain",
  raw: none,
))
