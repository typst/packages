/// -> point
#let point(
  /// -> int
  x,
  /// -> int
  y,
) = (x: x, y: y)

/// -> int
#let x(
  /// -> point
  point,
) = point.x

/// -> int
#let y(
  /// -> point
  point,
) = point.y

/// -> dict
#let neighbour(
  /// -> side
  side,
  /// -> point
  pt,
) = (
  left: point(pt.x - 1, pt.y),
  top: point(pt.x, pt.y - 1),
  right: point(pt.x + 1, pt.y),
  bottom: point(pt.x, pt.y + 1),
).at(side)
