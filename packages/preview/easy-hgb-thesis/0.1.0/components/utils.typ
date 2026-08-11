/// Sets the line spacing to the given spacing.
///  - spacing (length, number): The spacing to use. If a length is provided, the top-edge to top-edge distance will be set to this value. If a number is provided, top-edge to top-edge distance will be set to this multiple of the line height.
#let line-spacing(spacing, doc) = context {
  let line-height = measure(text("x")).height
  let line-height = (line-height / 1em.to-absolute()) * 1em
  set par(leading: if type(spacing) == length {
    spacing - line-height
  } else {
    line-height * (spacing - 1)
  })
  doc
}
