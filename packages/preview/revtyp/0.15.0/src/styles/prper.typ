
#import "aps.typ"

#let var = (:
  ..aps.var,
)

#let layout(
  var: var,
  content,
) = {
  show: aps.layout.with(var: var)

  content
}
