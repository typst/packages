#import "geometry.typ": point
#let add(a, b) = (a.at(0)+b.at(0), a.at(1)+b.at(1))
#let mul(a, n) = (a.at(0)*n, a.at(1)*n)
#let sub(a, b) = add(a, mul(b, -1))
#let distance(a, b) = { let d = sub(a, b); calc.sqrt(d.at(0)*d.at(0)+d.at(1)*d.at(1)) }
#let measure(path, steps: 192) = {
  let points = range(steps+1).map(i => point(path, i/steps))
  let lengths = (0,)
  for i in range(steps) { lengths.push(lengths.last() + distance(points.at(i), points.at(i+1))) }
  assert(lengths.last() > 0.000001, message: "degenerate path")
  (points: points, lengths: lengths, length: lengths.last())
}
#let frame(table, s) = {
  let target = calc.min(1, calc.max(0, s))*table.length
  let j = table.lengths.position(n => n > target)
  if j == none { j = table.points.len()-1 }
  let i = j - 1
  let a = table.points.at(i)
  let b = table.points.at(j)
  let d = distance(a, b)
  assert(d > 0, message: "degenerate path segment")
  let dir = mul(sub(b, a), 1/d)
  (point: add(a, mul(dir, target - table.lengths.at(i))), tangent: dir, normal: (-dir.at(1), dir.at(0)))
}
#let offset-point(table, s, offset) = {
  let f = frame(table, s)
  add(f.point, mul(f.normal, offset))
}
#let boundary(table, center, radius, reverse: false) = {
  if radius == 0 { return if reverse {1} else {0} }
  let sample = range(193).find(i => distance(frame(table, if reverse {1-i/192} else {i/192}).point, center) >= radius)
  assert(sample != none, message: "vertex covers entire edge")
  let lo = calc.max(0, (sample - 1)/192)
  let hi = sample/192
  for _ in range(16) {
    let mid = (lo+hi)/2
    if distance(frame(table, if reverse {1-mid} else {mid}).point, center) < radius { lo = mid } else { hi = mid }
  }
  if reverse {1-hi} else {hi}
}
#let prepare(result) = {
  let routes = result.routes.map(route => {
    let table = measure(route.path)
    let a = result.vertices.find(v => v.id == route.from)
    let b = result.vertices.find(v => v.id == route.to)
    let radius(v) = if ("dot", "circle", "blob").contains(v.marker) {v.size} else {0}
    let start = boundary(table, result.positions.at(a.id), radius(a))
    let end = boundary(table, result.positions.at(b.id), radius(b), reverse: true)
    assert(start < end, message: "vertex boundaries overlap along edge")
    (..route, table: table, start: start, end: end)
  })
  (..result, routes: routes)
}
