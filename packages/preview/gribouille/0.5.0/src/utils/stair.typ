///! Stair-step point doubling shared by step lines and stepped areas.

/// Double a polyline into a stair: between each pair of points insert the corner, `"hv"` placing it at `(x1, y0)` (horizontal then vertical) and `"vh"` at `(x0, y1)` (vertical then horizontal).
///
/// - pts: Array of `(x, y)` points in draw order.
/// - direction: Corner placement: `"hv"` or `"vh"`.
///
/// Returns: Array of `(x, y)` points with the inserted corners.
#let stair(pts, direction) = {
  if pts.len() < 2 { return pts }
  let out = (pts.first(),)
  for i in range(1, pts.len()) {
    let (x0, y0) = pts.at(i - 1)
    let (x1, y1) = pts.at(i)
    if direction == "hv" {
      out.push((x1, y0))
    } else {
      out.push((x0, y1))
    }
    out.push((x1, y1))
  }
  out
}
