
#import "aps.typ"

#let var = (
  ..aps.var,
  text-color: rgb("#000000"),
  link-color: rgb("#0000FF"),
)

#let layout(
  var: var,
  content,
) = {
  show: aps.layout.with(var: var)

  show cite: set text(fill: var.text-color)

  content
}
