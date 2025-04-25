#let tapestry(
  title: [],
  year: [],
  doc,
) = {
  set document(
    title: title,
  )

  set page(
    paper: "a5",
    margin: (x: 1.25cm, y: 1.75cm),
    header: [
      #set text(
      size: 9pt,
    )
      _ #title _
      #h(1fr)
      #year
    ],
    header-ascent: 42.5%
  )

  set heading(
    numbering: "1.",
  )
  show heading: set block(below: 1em)
  show heading: smallcaps

  set text(
    font: "New Computer Modern",
    size: 11pt
  )

  set math.equation(
    numbering: "(1)",
    supplement: "Eq."
  )
  show math.equation: it => {
    if it.block and not it.has("label") [
      #counter(math.equation).update(v => v - 1)
      #math.equation(it.body, block: true, numbering: none)#label("")
    ] else {
      it
    }  
  }

  outline()

  linebreak()

  doc
}
