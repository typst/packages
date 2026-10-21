// A material's fill is described rather than built. The renderer draws a scene
// in one piece and needs the parts of a repeating fill — its spacing, its rule
// thickness, its colours — not a finished tiling it cannot look inside. The
// places that still draw through Typst, such as cross-sections and the debug
// views, call `resolve` to turn a description back into a real tiling.

#let _tile(background, size, body) = tiling(
  size: (size, size),
  relative: "parent",
  block(
    width: size,
    height: size,
    fill: background,
    clip: true,
    body,
  ),
)

/// Describe a diagonal hatch tiling.
#let hatch(
  background: white,
  color: rgb("#6f7c83"),
  spacing: 6pt,
  thickness: .45pt,
  angle: 45deg,
) = (
  mesa-fill: "hatch",
  background: background,
  color: color,
  spacing: spacing,
  thickness: thickness,
  angle: angle,
)

/// Describe a crossed diagonal hatch tiling.
#let crosshatch(
  background: white,
  color: rgb("#6f7c83"),
  spacing: 7pt,
  thickness: .4pt,
) = (
  mesa-fill: "crosshatch",
  background: background,
  color: color,
  spacing: spacing,
  thickness: thickness,
)

/// Describe a dotted tiling.
#let dots(
  background: white,
  color: rgb("#6f7c83"),
  spacing: 6pt,
  radius: .65pt,
) = (
  mesa-fill: "dots",
  background: background,
  color: color,
  spacing: spacing,
  radius: radius,
)

/// Whether a value is one of the descriptions above.
#let is-spec(value) = type(value) == dictionary and "mesa-fill" in value

/// Reject the fills Mesa cannot describe, with a message that says what to use.
#let check(value) = {
  assert(
    value == none or type(value) == color or is-spec(value),
    message: "a material fill must be a color or one of semi.hatch, "
      + "semi.crosshatch, and semi.dots; a tiling or gradient built directly "
      + "cannot be rendered",
  )
  value
}

/// Build the tiling a description stands for.
#let resolve(value) = {
  if not is-spec(value) {
    return value
  }
  let spacing = value.spacing
  let color = value.color
  if value.mesa-fill == "dots" {
    return _tile(value.background, spacing, place(
      center + horizon,
      circle(radius: value.radius, fill: color, stroke: none),
    ))
  }
  let rule(angle) = place(
    center + horizon,
    line(length: spacing * 1.8, angle: angle, stroke: value.thickness + color),
  )
  if value.mesa-fill == "crosshatch" {
    _tile(value.background, spacing, {
      rule(45deg)
      rule(-45deg)
    })
  } else {
    _tile(value.background, spacing, rule(value.angle))
  }
}

/// Whether a fill covers what is behind it.
#let is-opaque(value) = {
  if value == none {
    false
  } else if is-spec(value) {
    value.background.components().last() == 100%
  } else if type(value) == color {
    value.components().last() == 100%
  } else {
    true
  }
}
