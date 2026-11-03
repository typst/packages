
#import "pra.typ"

#let var = (:
  ..pra.var,
)

#let layout(
  var: var,
  content,
) = {
  show: pra.layout

  set page(
    width: 8.2in,
    height: 11in,
    margin: (
      x: 0.56in,
      top: 0.94in,
      bottom: 0.74in,
    ),
  )

  content
}
