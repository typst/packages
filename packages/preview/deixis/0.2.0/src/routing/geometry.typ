// Resolved page-space path geometry. No document queries or painting.
#let _deixis-add(a, b) = (a.at(0) + b.at(0), a.at(1) + b.at(1))
#let _deixis-sub(a, b) = (a.at(0) - b.at(0), a.at(1) - b.at(1))
#let _deixis-scale(a, t) = (a.at(0) * t, a.at(1) * t)
#let _deixis-lerp(a, b, t) = _deixis-add(a, _deixis-scale(_deixis-sub(b, a), t))
#let _deixis-distance(a, b) = {
  let d = _deixis-sub(a, b)
  calc.sqrt(calc.pow(d.at(0) / 1pt, 2) + calc.pow(d.at(1) / 1pt, 2)) * 1pt
}
#let _deixis-unit(v) = {
  let n = _deixis-distance(v, (0pt, 0pt))
  if n < 0.00001pt { (0.0, 0.0) } else { (v.at(0) / n, v.at(1) / n) }
}

#let _deixis-move(end) = (kind: "move", end: end)
#let _deixis-line(end) = (kind: "line", end: end)
#let _deixis-quad(control, end) = (kind: "quad", control: control, end: end)
#let _deixis-cubic(c1, c2, end) = (kind: "cubic", c1: c1, c2: c2, end: end)

#let _deixis-path-segments(commands) = {
  let result = ()
  let current = (0pt, 0pt)
  for c in commands {
    if c.kind == "move" { current = c.end; continue }
    let segment = c + (start: current)
    if c.kind == "quad" {
      segment = (kind: "cubic", start: current, end: c.end,
        c1: _deixis-lerp(current, c.control, 2 / 3),
        c2: _deixis-lerp(c.end, c.control, 2 / 3))
    }
    let length = _deixis-distance(current, segment.end)
    if segment.kind == "cubic" {
      length += _deixis-distance(current, segment.c1) + _deixis-distance(segment.c2, segment.end)
    }
    if length > 0.00001pt { result.push(segment) }
    current = c.end
  }
  result
}

#let _deixis-split-segment(s, t) = {
  if s.kind == "line" {
    let p = _deixis-lerp(s.start, s.end, t)
    return (s + (end: p), s + (start: p))
  }
  let a = _deixis-lerp(s.start, s.c1, t)
  let b = _deixis-lerp(s.c1, s.c2, t)
  let c = _deixis-lerp(s.c2, s.end, t)
  let d = _deixis-lerp(a, b, t)
  let e = _deixis-lerp(b, c, t)
  let p = _deixis-lerp(d, e, t)
  (s + (c1: a, c2: d, end: p), s + (start: p, c1: e, c2: c))
}

#let _deixis-segment-length(s, depth: 0) = {
  let chord = _deixis-distance(s.start, s.end)
  if s.kind == "line" { return chord }
  let polygon = _deixis-distance(s.start, s.c1) + _deixis-distance(s.c1, s.c2) + _deixis-distance(s.c2, s.end)
  if depth >= 12 or polygon - chord < 0.005pt { return (polygon + chord) / 2 }
  let (a, b) = _deixis-split-segment(s, 0.5)
  _deixis-segment-length(a, depth: depth + 1) + _deixis-segment-length(b, depth: depth + 1)
}

#let _deixis-segment-tangent(s, end: false) = {
  let candidates = if s.kind == "line" { (_deixis-sub(s.end, s.start),) }
    else if end { (_deixis-sub(s.end, s.c2), _deixis-sub(s.end, s.c1), _deixis-sub(s.end, s.start)) }
    else { (_deixis-sub(s.c1, s.start), _deixis-sub(s.c2, s.start), _deixis-sub(s.end, s.start)) }
  let vector = candidates.find(v => _deixis-distance(v, (0pt, 0pt)) > 0.00001pt)
  if vector == none { (0.0, 0.0) } else { _deixis-unit(vector) }
}

#let _deixis-cut-segment(s, distance) = {
  let length = _deixis-segment-length(s)
  if s.kind == "line" { return _deixis-split-segment(s, calc.clamp(distance / length, 0, 1)) }
  let lo = 0.0
  let hi = 1.0
  for i in range(20) {
    let mid = (lo + hi) / 2
    let (a, b) = _deixis-split-segment(s, mid)
    if _deixis-segment-length(a) < distance { lo = mid } else { hi = mid }
  }
  _deixis-split-segment(s, (lo + hi) / 2)
}

// Remove distance along the real curve, preserving control points by de
// Casteljau subdivision. Consumed short paths disappear; a shaft never reverses.
#let _deixis-trim-start(segments, distance) = {
  let result = segments
  let remaining = distance
  while result.len() > 0 and remaining > 0.00001pt {
    let s = result.first()
    let length = _deixis-segment-length(s)
    if remaining >= length - 0.00001pt {
      let removed = result.remove(0)
      remaining -= length
      if result.len() > 0 and _deixis-distance(s.end, result.first().start) > 0.00001pt { break }
    } else {
      let (a, b) = _deixis-cut-segment(s, remaining)
      result.at(0) = b
      remaining = 0pt
    }
  }
  result
}
#let _deixis-reverse-segments(segments) = segments.rev().map(s => if s.kind == "line" {
  s + (start: s.end, end: s.start)
} else { s + (start: s.end, end: s.start, c1: s.c2, c2: s.c1) })
#let _deixis-trim-path(segments, start: 0pt, end: 0pt) = {
  let result = _deixis-trim-start(segments, start)
  _deixis-reverse-segments(_deixis-trim-start(_deixis-reverse-segments(result), end))
}

#let _deixis-native-path(segments) = {
  let commands = ()
  let current = none
  for s in segments {
    if current == none or s.start != current { commands.push(curve.move(s.start)) }
    commands.push(if s.kind == "line" { curve.line(s.end) } else { curve.cubic(s.c1, s.c2, s.end) })
    current = s.end
  }
  commands
}
