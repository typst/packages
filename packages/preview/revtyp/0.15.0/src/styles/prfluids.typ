
#import "pra.typ"

#let var = (
  ..pra.var,
  abstract-width: 4.48in,
)

#let layout(
  var: var,
  content,
) = {
  show: pra.layout

  set page(
    width: 7in,
    height: 10in,
    margin: (
      x: 0.76in,
    ),
    columns: 1,
  )

  content
}
