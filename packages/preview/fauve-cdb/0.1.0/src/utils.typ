#let balanced-cols(n-cols, gutter: 11pt, body) = layout(bounds => context {
  // Measure the height of the container of the text if it was single 
  // column, full width
  let textHeight = measure(box(
    width: (bounds.width - (n-cols - 1) *  gutter) / n-cols,
    body
  )).height

  // Recompute the height of the new container. Add a few points to avoid the 
  // second column being longer than the first one
  let balanced-height = (1/n-cols) * textHeight + 0.5 * text.size

  box(
    height: balanced-height, 
    columns(n-cols, gutter: gutter, body)
  )
})
