// Finite visibility projections for existing side intervals. All coordinates are
// resolved lengths; ownership is rechecked by the document adapter after moving.
// This expands permitted sockets, never changes their side, gap or body frame.
#let _deixis-sliding-ports(sources, targets, prepared, via, clearance, escape) = {
  let options = sources + targets
  let strip(e) = { let _ = e.remove("sliding"); e }
  let anchors = ()
  for e in options {
    let points = (e.point,)
    if e.sliding != none {
      let s = e.sliding
      for value in (s.min, s.max) {
        let p = e.point; p.at(s.axis) = value; points.push(p)
      }
    }
    let length = if e.owner == none { escape * 1pt } else {
      calc.max(escape * 1pt, clearance * 1pt - e.at("owner-gap", default: 0pt))
    }
    anchors += points
    if e.normal != auto { anchors += points.map(p => p.zip(e.normal).map(((v, n)) => v + n * length)) }
  }
  anchors += via.map(p => p.map(v => v * 1pt))
  let rails = (0, 1).map(axis => {
    let values = anchors.map(p => (p.at(axis) - escape * 1pt, p.at(axis), p.at(axis) + escape * 1pt)).flatten()
    values += (prepared.obstacles + prepared.originals).map(r => if axis == 0 { (r.left * 1pt, r.right * 1pt) }
      else { (r.top * 1pt, r.bottom * 1pt) }).flatten()
    values.sorted().dedup()
  })
  let expand(choices) = choices.fold((), (out, e) => {
    let clean = strip(e)
    let values = (clean,)
    if e.sliding != none {
      let s = e.sliding
      assert(s.axis in (0, 1) and e.normal != auto and e.normal.at(s.axis) == 0,
        message: "deixis: Internal sliding ports need a tangent interval and cardinal outward normal.")
      let lo = s.min; let hi = s.max
      if prepared.bounds != none {
        let b = prepared.bounds
        lo = calc.max(lo, (if s.axis == 0 { b.left } else { b.top }) * 1pt)
        hi = calc.min(hi, (if s.axis == 0 { b.right } else { b.bottom }) * 1pt)
      }
      if lo <= hi {
        let coordinates = ((lo, hi) + rails.at(s.axis)).sorted().dedup().filter(v => lo <= v and v <= hi)
        // Exact rails alone can force a reversing departure at the only useful
        // bend. Include a representative inside each open visibility band.
        coordinates += coordinates.windows(2).map(((a, b)) => a + (b - a) / 2)
        for coordinate in coordinates.sorted().dedup() {
          let p = e.point; p.at(s.axis) = coordinate
          values.push(clean + (point: p))
        }
      }
    }
    for value in values { if value not in out { out.push(value) } }
    out
  })
  (source: expand(sources), target: expand(targets))
}
