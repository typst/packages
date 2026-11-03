#import "geometry.typ": _deixis-lerp, _deixis-split-segment, _deixis-segment-length, _deixis-distance

#let _deixis-scene-point(segment, t) = {
  if segment.kind == "line" { return _deixis-lerp(segment.start, segment.end, t) }
  let a = _deixis-lerp(segment.start, segment.c1, t)
  let b = _deixis-lerp(segment.c1, segment.c2, t)
  let c = _deixis-lerp(segment.c2, segment.end, t)
  _deixis-lerp(_deixis-lerp(a, b, t), _deixis-lerp(b, c, t), t)
}

// Isolate cubic boundary roots on monotone intervals. This catches loops and
// tangent contacts without flattening/re-fitting the native curve. Unitless
// normalized ordinates keep the quadratic derivative calculation bounded.
#let _deixis-scene-roots(segment, axis, edge) = {
  let controls = if segment.kind == "line" { (segment.start, segment.end) }
    else { (segment.start, segment.c1, segment.c2, segment.end) }
  let values = controls.map(p => (p.at(axis) - edge).pt())
  let scale = calc.max(..values.map(calc.abs))
  if scale == 0 { return () }
  values = values.map(v => v / scale)
  if segment.kind == "line" {
    let d = values.last() - values.first()
    if d == 0 { return () }
    let t = -values.first() / d
    return if 0 < t and t < 1 { (t,) } else { () }
  }
  let (p, q, r, s) = values
  let a = -p + 3*q - 3*r + s; let b = 2*(p - 2*q + r); let c = q - p
  let critical = ()
  if calc.abs(a) < 1e-14 {
    if calc.abs(b) > 1e-14 { critical.push(-c / b) }
  } else {
    let disc = b*b - 4*a*c
    if disc >= 0 {
      // Stable quadratic formula; the other root follows from the product.
      let u = -(b + if b < 0 { -calc.sqrt(disc) } else { calc.sqrt(disc) }) / 2
      if u == 0 { critical.push(-b / (2*a)) }
      else { critical += (u / a, c / u) }
    }
  }
  let ts = (0,) + critical.filter(t => 0 < t and t < 1).sorted().dedup() + (1,)
  let value(t) = {
    let mix(x, y) = x*(1-t) + y*t
    mix(mix(mix(p, q), mix(q, r)), mix(mix(q, r), mix(r, s)))
  }
  let roots = ts.filter(t => value(t) == 0)
  for pair in ts.windows(2) {
    let (lo, hi) = pair; let low = value(lo); let high = value(hi)
    if (low < 0 and high > 0) or (low > 0 and high < 0) {
      for _ in range(42) {
        let mid = (lo + hi) / 2
        if (value(mid) < 0) == (low < 0) { lo = mid } else { hi = mid }
      }
      roots.push((lo + hi) / 2)
    }
  }
  roots
}

#let _deixis-scene-interactions(route, nodes, page) = {
  let events = ()
  for node in nodes.filter(n => n.behavior in ("cut", "cross")) {
    let b = node.bounds
    b = (left: b.left - route.origin.first(), right: b.right - route.origin.first(),
      top: b.top - route.origin.last(), bottom: b.bottom - route.origin.last())
    let inside(p) = b.left < p.first() and p.first() < b.right and b.top < p.last() and p.last() < b.bottom
    let offset = 0pt
    let spans = ()
    for segment in route.segments {
      let length = _deixis-segment-length(segment)
      // Control hull rejection avoids root work for unrelated nodes.
      let points = (segment.start, segment.end) + if segment.kind == "cubic" { (segment.c1, segment.c2) } else { () }
      let outside = (points.all(p => p.first() <= b.left) or points.all(p => p.first() >= b.right)
        or points.all(p => p.last() <= b.top) or points.all(p => p.last() >= b.bottom))
      if not outside {
        let ts = ((0, 1) + _deixis-scene-roots(segment, 0, b.left) + _deixis-scene-roots(segment, 0, b.right)
          + _deixis-scene-roots(segment, 1, b.top) + _deixis-scene-roots(segment, 1, b.bottom)).sorted().dedup()
        let distance(t) = if t == 0 { 0pt } else if t == 1 { length }
          else { _deixis-segment-length(_deixis-split-segment(segment, t).first()) }
        for (a, z) in ts.windows(2) {
          if z - a > 1e-12 and inside(_deixis-scene-point(segment, (a + z) / 2)) {
            let span = (from: offset + distance(a), to: offset + distance(z),
              entry: _deixis-scene-point(segment, a), exit: _deixis-scene-point(segment, z))
            if (spans.len() > 0 and calc.abs(spans.last().to - span.from) < 0.00001pt
              and _deixis-distance(spans.last().exit, span.entry) < 0.00001pt) {
              spans.last().to = span.to; spans.last().exit = span.exit
            } else { spans.push(span) }
          }
        }
      }
      offset += length
    }
    events += spans.map(span => span + (node: node.id, index: node.index, behavior: node.behavior, page: page))
  }
  events.sorted(key: e => (e.from, e.index))
}

// Shared finalization for accepted single/group geometry. Speculative plans
// never prepare cuts, invoke head callbacks or execute user content.
#let _deixis-scene-complete(geometry, prepared, page) = {
  let interactions = _deixis-scene-interactions(geometry, prepared.nodes, page)
  geometry + (interactions: interactions,
    scene-cuts: interactions.filter(e => e.behavior == "cut").map(e => (from: e.from, to: e.to)))
}

