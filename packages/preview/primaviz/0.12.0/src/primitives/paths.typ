// paths.typ - Shared path helpers

/// A copy of `stroke` with round joins and caps, so a sharp turn in a thick
/// line closes in an arc instead of a mitre spike that pokes past the data point.
///
/// - stroke (stroke, length, color): Stroke to round
/// -> stroke
#let round-stroke(stroke) = {
  let s = std.stroke(stroke)
  std.stroke(paint: s.paint, thickness: s.thickness, dash: s.dash, cap: "round", join: "round")
}

/// Draws a connected polyline through `points` as a single stroked curve.
///
/// Emitting one curve instead of one `line()` per segment keeps the corners
/// joined (independent segments meet with butt caps, leaving notches on thick
/// strokes) and keeps dash patterns continuous across the whole series.
///
/// - points (array): Array of `(x, y)` length tuples
/// - stroke (stroke): Stroke applied to the path
/// -> content
#let draw-polyline(points, stroke) = {
  if points.len() < 2 {
    return
  }
  place(
    left + top,
    curve(
      stroke: round-stroke(stroke),
      fill: none,
      curve.move(points.first()),
      ..points.slice(1).map(p => curve.line(p)),
    )
  )
}
