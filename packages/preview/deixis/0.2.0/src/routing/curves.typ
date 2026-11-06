#import "geometry.typ": _deixis-distance, _deixis-lerp, _deixis-cubic, _deixis-add, _deixis-sub, _deixis-scale

// Numerical interpolation only: no page queries, measurement, heads, or paint.
// Consecutive duplicate knots are collapsed; returning to an earlier knot is
// intentional. Direction-free endpoints follow the adjacent chord.
#let _deixis-curve-cmds(vertices, kind: "curve", source-dir: "none", target-dir: "none",
  source-normal: auto, target-normal: auto, tension: 1,
) = {
  let points = ()
  for p in vertices { if points.len() == 0 or points.last() != p { points.push(p) } }
  if points.len() < 2 { return () }
  let cmds = ()
  let t-start = points.first()
  let t-end = points.last()
  let C-start = points.first()
  let C-end = points.last()
  let wps = points.slice(1, -1)
  let dx = C-end.at(0) - C-start.at(0)
  let dy = C-end.at(1) - C-start.at(1)
  let eff-s-dir = source-dir
  let eff-t-dir = target-dir

  if wps.len() == 0 {
    t-start = if eff-s-dir == "none" { _deixis-lerp(C-start, C-end, 1 / 3) }
      else if eff-s-dir == "horizontal" { (C-start.at(0) + dx * 0.5, C-start.at(1)) } else {
      (C-start.at(0), C-start.at(1) + dy * 0.5)
    }
    t-end = if eff-t-dir == "none" { _deixis-lerp(C-start, C-end, 2 / 3) }
      else if eff-t-dir == "horizontal" { (C-start.at(0) + dx * 0.5, C-end.at(1)) } else {
      (C-end.at(0), C-start.at(1) + dy * 0.5)
    }
    let handle = calc.max(0.1pt, _deixis-distance(C-start, C-end) / 2)
    if t-start == C-start and source-dir != "none" {
      t-start = if source-dir == "horizontal" { (C-start.first() + handle, C-start.last()) }
        else { (C-start.first(), C-start.last() + handle) }
    }
    if t-end == C-end and target-dir != "none" {
      t-end = if target-dir == "horizontal" { (C-end.first() - handle, C-end.last()) }
        else { (C-end.first(), C-end.last() - handle) }
    }
    if source-normal != auto and source-normal != (0, 0) {
      t-start = (C-start.at(0) + source-normal.at(0) * handle, C-start.at(1) + source-normal.at(1) * handle)
    }
    if target-normal != auto and target-normal != (0, 0) {
      t-end = (C-end.at(0) + target-normal.at(0) * handle, C-end.at(1) + target-normal.at(1) * handle)
    }
    cmds.push(_deixis-cubic(t-start, t-end, C-end))
  } else {
    let before = _deixis-sub(_deixis-scale(points.first(), 2), points.at(1))
    let after = _deixis-sub(_deixis-scale(points.last(), 2), points.at(-2))
    let pts = (before,) + points + (after,)
    let lengths = if kind == "curve" { points.windows(2).map(pair => _deixis-distance(..pair)) } else { () }
    let directions = if kind == "curve" { points.windows(2).enumerate().map(((i, pair)) => {
      let delta = _deixis-sub(pair.last(), pair.first())
      delta.map(v => v / calc.max(0.00001pt, lengths.at(i)))
    }) } else { () }
    let bisectors = directions.windows(2).map(pair => {
      let v = _deixis-add(..pair)
      let norm = calc.max(0.00001, calc.sqrt(v.first() * v.first() + v.last() * v.last()))
      v.map(x => x / norm)
    })
    // Both Catmull-Rom policies share the nonuniform Hermite conversion.
    // Positive intervals need no additive epsilon after duplicate removal.
    let knots = if kind == "ccr" { pts.windows(2).map(pair => calc.sqrt(_deixis-distance(..pair) / 1pt)) }
      else { (1,) * (pts.len() - 1) }
    let constrain(point, control, neighbor, axis, normal, end: false) = {
      let length = _deixis-distance(point, control)
      if normal != auto and normal != (0, 0) {
        return _deixis-add(point, _deixis-scale(normal, calc.max(0.1pt, length)))
      }
      if axis == "none" { return control }
      let index = if axis == "horizontal" { 0 } else { 1 }
      let delta = neighbor.at(index) - point.at(index)
      let sign = if delta == 0pt { if end { -1 } else { 1 } } else if delta > 0pt { 1 } else { -1 }
      let result = point
      result.at(index) += sign * length
      result
    }
    for j in range(points.len() - 1) {
      let p0 = pts.at(j)
      let p1 = pts.at(j + 1)
      let p2 = pts.at(j + 2)
      let p3 = pts.at(j + 3)
      let c1 = p1
      let c2 = p2
      if kind == "curve" {
        let first = if j == 0 { directions.first() }
          else { bisectors.at(j - 1) }
        let last = if j == points.len() - 2 { directions.last() }
          else { bisectors.at(j) }
        c1 = _deixis-add(p1, _deixis-scale(first, lengths.at(j) * 0.25))
        c2 = _deixis-sub(p2, _deixis-scale(last, lengths.at(j) * 0.25))
      } else {
        let d1 = knots.at(j)
        let d2 = knots.at(j + 1)
        let d3 = knots.at(j + 2)
        let v1 = _deixis-add(_deixis-scale(_deixis-sub(p2, p1), d1 * d1),
          _deixis-scale(_deixis-sub(p1, p0), d2 * d2))
        let v2 = _deixis-add(_deixis-scale(_deixis-sub(p3, p2), d2 * d2),
          _deixis-scale(_deixis-sub(p2, p1), d3 * d3))
        c1 = _deixis-add(p1, _deixis-scale(v1, 1 / (3 * d1 * (d1 + d2))))
        c2 = _deixis-sub(p2, _deixis-scale(v2, 1 / (3 * d3 * (d2 + d3))))
      }
      if j == 0 { c1 = constrain(p1, c1, p2, source-dir, source-normal) }
      if j == points.len() - 2 { c2 = constrain(p2, c2, p1, target-dir, target-normal, end: true) }
      cmds.push(_deixis-cubic(c1, c2, p2))
    }
  }
  if tension == 1 { return cmds }
  cmds.enumerate().map(((i, command)) => command + (
    c1: _deixis-lerp(points.at(i), command.c1, 1 / tension),
    c2: _deixis-lerp(command.end, command.c2, 1 / tension)))
}
