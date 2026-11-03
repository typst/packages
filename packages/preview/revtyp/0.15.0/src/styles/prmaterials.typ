
#import "pra.typ"

#let var = (:
  ..pra.var,
)

#let layout(
  var: var,
  content,
) = {
  show: pra.layout

  content
}
