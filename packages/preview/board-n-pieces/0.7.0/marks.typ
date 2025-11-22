/// The color used by default for marks.
#let default-color = rgb("#ff4136a5")

/// Fills the entire square background.
#let fill(fill) = {
  rect(width: 100%, height: 100%, fill: fill, stroke: none)
}

/// Marks a square with a circle.
#let circle(paint: default-color, thickness: 15%, margin: 5%) = {
  // Force a (possibly relative) length.
  thickness = thickness + 0pt
  if type(thickness) == relative {
    return layout(((width, ..)) => {
      circle(paint: paint, thickness: thickness.ratio * width + thickness.length, margin: margin)
    })
  }

  std.circle(
    width: 100% - thickness - 2 * margin,
    fill: none,
    stroke: paint + thickness,
  )
}

/// Marks a square with a cross.
#let cross(paint: default-color, thickness: 15%, margin: 10%) = {
  // Force a (possibly relative) length.
  thickness = thickness + 0pt
  if type(thickness) == relative {
    return layout(((width, ..)) => {
      cross(paint: paint, thickness: thickness.ratio * width + thickness.length, margin: margin)
    })
  }

  let offset = thickness / calc.sqrt(8)
  let start = 0%
  let end = 100% - 2 * margin - 2 * offset

  std.curve(
    fill: none,
    stroke: paint + thickness,
    curve.move((start, start)),
    curve.line((end, end)),
    curve.close(),
    curve.move((start, end)),
    curve.line((end, start)),
    curve.close(),
  )
}
