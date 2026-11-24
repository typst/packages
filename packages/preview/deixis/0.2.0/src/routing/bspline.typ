#import "geometry.typ": _deixis-add, _deixis-sub, _deixis-scale, _deixis-lerp, _deixis-distance, _deixis-cubic, _deixis-line

// Open uniform, clamped control polygon. Interior controls are influences,
// not interpolation knots; repeated controls intentionally retain multiplicity.
// Port constraints add boundary controls, leaving user influences untouched.
#let _deixis-bspline-cmds(start, end, controls: (), source-dir: "none", target-dir: "none",
  source-normal: auto, target-normal: auto,
) = {
  let polygon = (start,) + controls + (end,)
  if polygon.all(p => p == start) { return () }
  let boundary(point, neighbors, axis, normal, end: false) = {
    if (normal == auto or normal == (0, 0)) and axis == "none" { return () }
    let next = neighbors.find(p => p != point)
    if next == none { return () }
    let distance = calc.max(0.1pt, _deixis-distance(point, next) / 3)
    let direction = normal
    if direction == auto or direction == (0, 0) {
      let index = if axis == "horizontal" { 0 } else { 1 }
      let delta = next.at(index) - point.at(index)
      let sign = if delta == 0pt { if end { -1 } else { 1 } } else if delta > 0pt { 1 } else { -1 }
      direction = if index == 0 { (sign, 0) } else { (0, sign) }
    }
    (_deixis-add(point, _deixis-scale(direction, distance)),)
  }
  let first = boundary(start, polygon.slice(1), source-dir, source-normal)
  let last = boundary(end, polygon.rev().slice(1), target-dir, target-normal, end: true)
  polygon = (start,) + first + controls + last + (end,)
  if polygon.len() == 2 { return (_deixis-line(end),) }
  if polygon.len() == 3 {
    return (_deixis-cubic(_deixis-lerp(start, polygon.at(1), 2 / 3),
      _deixis-lerp(end, polygon.at(1), 2 / 3), end),)
  }
  if polygon.len() == 4 { return (_deixis-cubic(polygon.at(1), polygon.at(2), end),) }

  let spans = polygon.len() - 3
  let knots = (0,) * 4 + range(1, spans) + (spans,) * 4
  // de Boor on a clamped uniform domain; end evaluation uses the last span.
  let evaluate(points, knots, degree, u) = {
    let k = calc.min(points.len() - 1, degree + calc.floor(u))
    let d = points.slice(k - degree, k + 1)
    for r in range(1, degree + 1) {
      for j in range(r, degree + 1).rev() {
        let i = k - degree + j
        let denominator = knots.at(k + 1 + j - r) - knots.at(i)
        let alpha = if denominator == 0 { 0 } else { (u - knots.at(i)) / denominator }
        d.at(j) = _deixis-lerp(d.at(j - 1), d.at(j), alpha)
      }
    }
    d.last()
  }
  let derivatives = polygon.windows(2).enumerate().map(((i, pair)) =>
    _deixis-scale(_deixis-sub(pair.last(), pair.first()), 3 / (knots.at(i + 4) - knots.at(i + 1))))
  let samples = range(spans + 1).map(u => (
    point: evaluate(polygon, knots, 3, u),
    derivative: evaluate(derivatives, knots.slice(1, -1), 2, u),
  ))
  samples.windows(2).map(pair => _deixis-cubic(
    _deixis-add(pair.first().point, _deixis-scale(pair.first().derivative, 1 / 3)),
    _deixis-sub(pair.last().point, _deixis-scale(pair.last().derivative, 1 / 3)), pair.last().point))
}
