
#import "aps.typ"

#let var = (
  ..aps.var,
  // Colors
  text-color: rgb("#000000"),
  link-color: rgb("#0000FF"),
  // Spacings
  abstract-spacing: 9pt,
  abstract-leading: 5.7pt,
  frontmatter-spacing: 22pt,
)

#let layout(
  var: var,
  content,
) = {
  show: aps.layout.with(var: var)

  show cite: set text(fill: var.text-color)

  content
}
