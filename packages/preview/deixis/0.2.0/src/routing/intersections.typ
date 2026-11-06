#import "geometry.typ": _deixis-distance, _deixis-sub, _deixis-unit, _deixis-split-segment, _deixis-segment-length

// Detection only: painting and arc-length cuts retain the original cubics.
// Control hull bounds enclose each subcurve. Flat leaves have at most 0.01pt
// polygon/chord excess, including collinear reversal and closed-loop cases.
#let _deixis-intersection-tree(s, lo: 0.0, hi: 1.0, depth: 0, budget: 1024) = {
  let points = if s.kind == "line" { (s.start, s.end) } else { (s.start, s.c1, s.c2, s.end) }
  let bounds = (left: calc.min(..points.map(p => p.first())), right: calc.max(..points.map(p => p.first())),
    top: calc.min(..points.map(p => p.last())), bottom: calc.max(..points.map(p => p.last())))
  let chord = _deixis-distance(s.start, s.end)
  let polygon = points.windows(2).map(pair => _deixis-distance(..pair)).fold(0pt, (a, b) => a + b)
  // Bound control-point distance from the chord as well as length excess.
  let deviation = 0pt
  if s.kind == "cubic" {
    let direction = _deixis-unit(_deixis-sub(s.end, s.start))
    deviation = calc.max(..(s.c1, s.c2).map(p => {
      let v = _deixis-sub(p, s.start)
      calc.abs(v.first() * direction.last() - v.last() * direction.first())
    }))
  }
  let flat = polygon - chord <= 0.01pt and deviation <= 0.01pt
  if flat or depth >= 12 or budget <= 1 {
    return (bounds: bounds, lo: lo, hi: hi, children: (), resolved: flat, leaves: 1)
  }
  let (a, b) = _deixis-split-segment(s, 0.5)
  let mid = (lo + hi) / 2
  let first = _deixis-intersection-tree(a, lo: lo, hi: mid, depth: depth + 1, budget: budget - 1)
  let children = (first,
    _deixis-intersection-tree(b, lo: mid, hi: hi, depth: depth + 1, budget: budget - first.leaves))
  (bounds: bounds, lo: lo, hi: hi, children: children,
    resolved: children.all(c => c.resolved) and children.map(c => c.leaves).sum() <= 1024,
    leaves: children.map(c => c.leaves).sum())
}

#let _deixis-segment-point(s, t) = _deixis-split-segment(s, t).first().end
#let _deixis-segment-derivative(s, t) = {
  if s.kind == "line" { return _deixis-sub(s.end, s.start).map(v => v / 1pt) }
  let a = _deixis-sub(s.c1, s.start)
  let b = _deixis-sub(s.c2, s.c1)
  let c = _deixis-sub(s.end, s.c2)
  (0, 1).map(i => 3 * ((1 - t) * (1 - t) * a.at(i) + 2 * (1 - t) * t * b.at(i) + t * t * c.at(i)) / 1pt)
}
#let _deixis-cross-product(a, b) = a.first() * b.last() - a.last() * b.first()

// Refine against the original polynomials, not their approximating chords.
// Inclusive leaf intervals retain intersections at artificial subdivision joins.
#let _deixis-refine-intersection(a, b, x, y) = {
  let t = (x.lo + x.hi) / 2
  let u = (y.lo + y.hi) / 2
  for i in range(14) {
    let delta = _deixis-sub(_deixis-segment-point(b, u), _deixis-segment-point(a, t)).map(v => v / 1pt)
    if calc.max(..delta.map(calc.abs)) < 0.00000001 { break }
    let da = _deixis-segment-derivative(a, t)
    let db = _deixis-segment-derivative(b, u)
    let den = _deixis-cross-product(da, db)
    if calc.abs(den) < 0.000000000001 { return none }
    t = calc.clamp(t + _deixis-cross-product(delta, db) / den, x.lo, x.hi)
    u = calc.clamp(u + _deixis-cross-product(delta, da) / den, y.lo, y.hi)
  }
  t = calc.clamp(t, 0, 1)
  u = calc.clamp(u, 0, 1)
  let p = _deixis-segment-point(a, t)
  if _deixis-distance(p, _deixis-segment-point(b, u)) > 0.000001pt { return none }
  let da = _deixis-segment-derivative(a, t)
  let db = _deixis-segment-derivative(b, u)
  let norm = calc.sqrt(da.map(v => v * v).sum() * db.map(v => v * v).sum())
  let sine = if norm == 0 { 0 } else { calc.abs(_deixis-cross-product(da, db)) / norm }
  if sine <= 0.00001 { return none }
  // A tangent contact can converge numerically with a small nonzero angle.
  // Require both curves to cross the other's local tangent on either side.
  let crosses(s, v, direction) = {
    let step = calc.min(0.001, 0.01 / calc.max(0.00001, calc.sqrt(_deixis-segment-derivative(s, v).map(x => x * x).sum())))
    let side(w) = _deixis-cross-product(_deixis-sub(_deixis-segment-point(s, w), p).map(x => x / 1pt), direction)
    side(v - step) * side(v + step) < 0
  }
  if not crosses(a, t, db) or not crosses(b, u, da) { return none }
  (point: p, t: t, u: u, sine: sine,
    cosine: calc.abs(da.first() * db.first() + da.last() * db.last()) / norm)
}

#let _deixis-tree-intersections(a, b, x, y) = {
  let p = x.bounds
  let q = y.bounds
  if p.right < q.left or q.right < p.left or p.bottom < q.top or q.bottom < p.top { return () }
  if x.children.len() == 0 and y.children.len() == 0 {
    let hit = _deixis-refine-intersection(a, b, x, y)
    return if hit == none { () } else { (hit,) }
  }
  if x.children.len() > 0 and (y.children.len() == 0 or x.hi - x.lo >= y.hi - y.lo) {
    return x.children.map(child => _deixis-tree-intersections(a, b, child, y)).flatten()
  }
  y.children.map(child => _deixis-tree-intersections(a, b, x, child)).flatten()
}

#let _deixis-segment-intersections(a, b) = {
  let shape(s) = if s.kind == "line" { (kind: "line", start: s.start, end: s.end) }
    else { (kind: "cubic", start: s.start, end: s.end, c1: s.c1, c2: s.c2) }
  let sa = shape(a)
  let sb = shape(b)
  let hits = _deixis-tree-intersections(sa, sb, a.tree, b.tree).sorted(key: h => (h.t, h.u))
  let result = ()
  for hit in hits {
    if result.any(h => calc.abs(h.t - hit.t) <= 0.0000001 and calc.abs(h.u - hit.u) <= 0.0000001) { continue }
    let ad = if hit.t <= 0 { 0pt } else if hit.t >= 1 { a.length }
      else { _deixis-segment-length(_deixis-split-segment(sa, hit.t).first()) }
    let bd = if hit.u <= 0 { 0pt } else if hit.u >= 1 { b.length }
      else { _deixis-segment-length(_deixis-split-segment(sb, hit.u).first()) }
    if (ad <= 0.00001pt and not a.smooth-start or a.length - ad <= 0.00001pt and not a.smooth-end or
      bd <= 0.00001pt and not b.smooth-start or b.length - bd <= 0.00001pt and not b.smooth-end) { continue }
    result.push(hit + (a: a.at + ad, b: b.at + bd))
  }
  result
}
