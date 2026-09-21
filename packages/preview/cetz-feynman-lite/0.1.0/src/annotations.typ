#import "paths.typ": frame, offset-point, sub, mul, distance
// at/span use normalized arc length of the complete centerline.
// side is always relative to from -> to, independent of momentum direction.
#let momentum-data(route) = {
  if route.momentum == none { return none }
  let m = route.momentum
  let offset = m.offset * if m.side == "left" {1} else {-1}
  let points = range(33).map(i => offset-point(route.table, m.at - m.span/2 + m.span*i/32, offset))
  if m.direction == "backward" { points = points.rev() }
  let d = sub(points.last(), points.at(-2))
  let length = distance(points.last(), points.at(-2))
  assert(length > 0.000001, message: "degenerate momentum arrow")
  (points: points, tip: points.last(), direction: mul(d, 1/length), label: m.label,
    label-position: offset-point(route.table, m.at, offset + if offset > 0 {m.label-offset} else {-m.label-offset}))
}
#let arrow-data(route, at: 0.5) = {
  let f = frame(route.table, route.start + at*(route.end - route.start))
  (tip: f.point, direction: mul(f.tangent, if route.arrow == "backward" {-1} else {1}))
}
