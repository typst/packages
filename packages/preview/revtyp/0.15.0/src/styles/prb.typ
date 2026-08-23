
#import "pra.typ"

#let var = (
  ..pra.var,
  // Layout
  first-header-dy: 0.03in,
  // Spacings
  title-spacing: 17.5pt,
  date-spacing: 11pt,
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
      inside: 0.6in,
      outside: 0.54in,
      top: 0.84in,
      bottom: 0.68in,
    ),
  )

  content
}
