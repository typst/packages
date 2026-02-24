/// for two given circles, gives the tangent touching both. Since there are (potentially) four
/// tangents between the circles, the returned tangent is actually identified by the sign of the
/// circles' radii. If the signs match, the tangent is one of the convex connections between the two
/// circles. If any radius is zero, this collapses to giving a circle/point tangent, or line between
/// two points.
///
/// The return value is an array of two points, or `none` in the following cases:
/// - the circles are the same, and therefore there are infinitely many tangents
/// - one circle is enclosed by the other and not touching
/// - the circles are intersecting and the signs of the radii differ
/// - one circle is enclosed by the other and touching, and the signs of the radii differ
///
/// In the touching cases, two of the tangents will have length zero. When touching from the
/// outside, those are the non-convex tangents; when touching from the inside, these are the convex
/// ones and no non-convex tangents exist.
///
/// -> array
#let tangent(
  /// the first circle's center, as a two-element array
  /// -> array
  c1,
  /// the first circle's radius; may be negative or zero
  /// -> float | int
  r1,
  /// the second circle's center, as a two-element array
  /// -> array
  c2,
  /// the second circle's radius; may be negative or zero
  /// -> float | int
  r2,
) = {
  let (cx1, cy1) = c1
  let (cx2, cy2) = c2

  let (cx, cy, r) = (cx2 - cx1, cy2 - cy1, r2 - r1)
  let tmp = cx*cx + cy*cy - r*r
  if tmp < 0 { return }
  let tmp = calc.sqrt(tmp)
  let denom = cx*cx + cy*cy
  if denom == 0 { return }

  let a = (cy*tmp + cx*r2 - cx*r1) / denom
  let b = -(cx*tmp - cy*r2 + cy*r1) / denom
  let c = -((cx1*cy2 - cx2*cy1)*tmp + (cy1*cy2 - cy1*cy1 + cx1*cx2 - cx1*cx1)*r2 + (-cy2*cy2 + cy1*cy2 - cx2*cx2 + cx1*cx2)*r1) / denom
  let c1 = -((cy1*cy2 - cy1*cy1 + cx1*cx2 - cx1*cx1)*tmp + (cx2*cy1 - cx1*cy2)*r2 + (cx1*cy2 - cx2*cy1)*r1) / denom
  let c2 = -((cy2*cy2 - cy1*cy2 + cx2*cx2 - cx1*cx2)*tmp + (cx2*cy1 - cx1*cy2)*r2 + (cx1*cy2 - cx2*cy1)*r1) / denom

  let x1 = -(a*c - b*c1)/(a*a + b*b)
  let y1 = -(a*c1 + b*c)/(a*a + b*b)
  let x2 = -(a*c - b*c2)/(a*a + b*b)
  let y2 = -(a*c2 + b*c)/(a*a + b*b)
  ((x1, y1), (x2, y2))
}
