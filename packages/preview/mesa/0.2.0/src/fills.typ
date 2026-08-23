#let _tile(background, size, body) = tiling(
  size: (size, size),
  relative: "self",
  block(
    width: size,
    height: size,
    fill: background,
    clip: true,
    body,
  ),
)

/// Create a diagonal hatch tiling.
#let hatch(
  background: white,
  color: rgb("#6f7c83"),
  spacing: 6pt,
  thickness: .45pt,
  angle: 45deg,
) = _tile(
  background,
  spacing,
  place(
    center + horizon,
    line(
      length: spacing * 1.8,
      angle: angle,
      stroke: thickness + color,
    ),
  ),
)

/// Create a crossed diagonal hatch tiling.
#let crosshatch(
  background: white,
  color: rgb("#6f7c83"),
  spacing: 7pt,
  thickness: .4pt,
) = _tile(
  background,
  spacing,
  {
    place(
      center + horizon,
      line(
        length: spacing * 1.8,
        angle: 45deg,
        stroke: thickness + color,
      ),
    )
    place(
      center + horizon,
      line(
        length: spacing * 1.8,
        angle: -45deg,
        stroke: thickness + color,
      ),
    )
  },
)

/// Create a dotted tiling.
#let dots(
  background: white,
  color: rgb("#6f7c83"),
  spacing: 6pt,
  radius: .65pt,
) = _tile(
  background,
  spacing,
  place(
    center + horizon,
    circle(
      radius: radius,
      fill: color,
      stroke: none,
    ),
  ),
)
