
#let place-anchor(x, y, name) = {
  (
    label: none,
    plot: (plot, transform) => {
      let (x, y) = transform(x, y)
      place(
        dx: x, dy: y, [#box()#label(name)]
      )
    },
    xlimits: () => none,
    ylimits: () => none,
    legend-handle: (..) => none
  )
}