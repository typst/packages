#import "@preview/cetz:0.4.2"

#let drawmatrix(
  scale: 1,
  width: 1,
  height: 1,
  stroke: black,
  fill: none,
  upper: false,
  lower: false,
  diagonal: false,
  x,
) = {
  if int(upper) + int(lower) + int(diagonal) > 1 {
    panic("At most one of upper/lower/diagonal can be enabled.")
  }
  // Dimensions:
  let total-width = scale * width
  let total-height = scale * height
  let min-dim = calc.min(total-height, total-width)
  // Coordinates:
  let north-west = (0, 0)
  let south-west = (0, -total-height)
  let diag-end = (min-dim, -(min-dim))
  let south-east = if upper and total-height > total-width {
    (total-width, -(min-dim))
  } else if lower and total-height < total-width {
    diag-end
  } else {
    (total-width, -total-height)
  }
  let north-east = (total-width, 0)
  cetz.canvas(
    baseline: "label.base",
    {
      import cetz.draw: content, rect, line
      // Bounding box:
      rect(
        stroke: none,
        fill: none,
        north-west, south-east,
        name: "matrix",
      )
      // Shape:
      let points = if upper {
        (north-west, diag-end, south-east, north-east)
      } else if lower {
        (north-west, south-west, south-east, diag-end)
      } else if diagonal {
        (north-west, diag-end)
      } else {
        (north-west, south-west, south-east, north-east)
      }
      line(
        stroke: stroke,
        fill: fill,
        close: true,
        ..points,
      )
      // User-supplied text:
      content("matrix", [#x], name: "label")
    },
  )
}
