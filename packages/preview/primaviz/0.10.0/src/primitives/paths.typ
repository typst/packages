// paths.typ - Shared path helpers

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
      stroke: stroke,
      fill: none,
      curve.move(points.first()),
      ..points.slice(1).map(p => curve.line(p)),
    )
  )
}
