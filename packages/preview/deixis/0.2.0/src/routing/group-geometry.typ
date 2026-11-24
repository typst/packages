#import "lane-cost.typ": reserve, exposure

#let endpoint(e) = {
  if type(e) == array { (point: e, normal: none, owner: none, junction: none) }
  else {
    let e = (normal: none, owner: none, junction: none) + e
    if type(e.junction) == label { e.junction = str(e.junction) }
    e
  }
}
#let pair-points(s) = {
  if s.axis == 0 { ((s.low, s.fixed), (s.high, s.fixed)) }
  else { ((s.fixed, s.low), (s.fixed, s.high)) }
}
#let on(p, s) = p.at(1 - s.axis) == s.fixed and s.low <= p.at(s.axis) and p.at(s.axis) <= s.high
#let overlap(a, b) = calc.max(0, calc.min(a.high, b.high) - calc.max(a.low, b.low))
#let union(lanes) = {
  let merged = ()
  for s in lanes.sorted(key: s => (s.axis, s.fixed, s.low, s.high)) {
    if merged.len() > 0 and merged.last().axis == s.axis and merged.last().fixed == s.fixed and s.low <= merged.last().high {
      merged.last().high = calc.max(merged.last().high, s.high)
    } else { merged.push(s) }
  }
  merged
}

#let ports(scene, edge) = (edge.from, edge.to).map(endpoint).map(e => {
  let length = if e.owner == none { scene.escape } else { calc.max(scene.clearance - e.at("owner-gap", default: 0), scene.escape) }
  e + (stub: if e.normal == none { e.point } else { e.point.zip(e.normal).map(((p, n)) => p + length * n) })
})

// A name identifies one literal point on one page. Different outward normals
// may meet there; only actual common mandatory stub intervals are shareable.
#let validate-junctions(scene, edges) = {
  let seen = ()
  for edge in edges {
    if "failure" in edge { continue }
    for port in ports(scene, edge) {
      if port.junction == none { continue }
      let name = port.junction
      assert(type(name) == array or (type(name) == str and name != ""),
        message: "deixis: Internal routing junction needs a socket identity.")
      let page = edge.at("page", default: none)
      let prior = seen.find(p => p.name == name and p.page == page)
      assert(prior == none or prior.point == port.point, message: "deixis: One routing junction must use the same point on a page.")
      seen.push((name: name, page: page, point: port.point))
    }
  }
}

#let zones(scene, a, b) = {
  let points = (); let lanes = ()
  if a.at("page", default: none) != b.at("page", default: none) { return (points: points, lanes: lanes) }
  for p in ports(scene, a) {
    for q in ports(scene, b) {
      if p.junction == none or q.junction == none or p.junction != q.junction { continue }
      assert.eq(p.point, q.point)
      if p.point not in points { points.push(p.point) }
      let left = reserve((p.point, p.stub)); let right = reserve((q.point, q.stub))
      if left.len() == 0 or right.len() == 0 { continue }
      let x = left.first(); let y = right.first()
      if x.axis == y.axis and x.fixed == y.fixed and overlap(x, y) > 0 {
        lanes.push((axis: x.axis, fixed: x.fixed, low: calc.max(x.low, y.low), high: calc.min(x.high, y.high)))
      }
    }
  }
  (points: points, lanes: union(lanes))
}

#let lanes-against(scene, edge, other, record) = {
  let shared = zones(scene, edge, other).lanes
  reserve(record.points).map(s => s + (exempt: shared.filter(z => z.axis == s.axis and z.fixed == s.fixed)))
}

#let pair-metrics(scene, a, ar, b, br, spacing) = {
  let left = reserve(ar.points); let right = reserve(br.points)
  let permitted = zones(scene, a, b)
  let tagged = lanes-against(scene, a, b, br)
  let raw = 0; let accidental = 0; let proximity = 0
  let contacts = (); let proper = (); let allowed = ()
  let contact(p, crossing, contacts, proper, allowed) = {
    if p in permitted.points or permitted.lanes.any(s => on(p, s)) {
      if p not in allowed { allowed.push(p) }
    } else {
      if p not in contacts { contacts.push(p) }
      if crossing and p not in proper { proper.push(p) }
    }
    (contacts, proper, allowed)
  }
  // Count real route endpoints even when the two shafts are collinear there.
  // Otherwise a fully coincident baseline hides its endpoint contacts, and a
  // harmless separating detour appears to introduce them for the first time.
  if left.len() > 0 and right.len() > 0 {
    for p in (ar.points.first(), ar.points.last()) {
      if right.any(s => on(p, s)) { (contacts, proper, allowed) = contact(p, false, contacts, proper, allowed) }
    }
    for p in (br.points.first(), br.points.last()) {
      if left.any(s => on(p, s)) { (contacts, proper, allowed) = contact(p, false, contacts, proper, allowed) }
    }
  }
  for x in left {
    proximity += exposure(..pair-points(x), tagged, spacing)
    accidental += exposure(..pair-points(x), tagged.filter(y => x.axis == y.axis and x.fixed == y.fixed), spacing)
    for y in right {
      if x.axis == y.axis {
        if x.fixed != y.fixed { continue }
        raw += overlap(x, y)
        if calc.min(x.high, y.high) == calc.max(x.low, y.low) {
          let p = if x.axis == 0 { (calc.max(x.low, y.low), x.fixed) } else { (x.fixed, calc.max(x.low, y.low)) }
          (contacts, proper, allowed) = contact(p, false, contacts, proper, allowed)
        }
      } else {
        let p = if x.axis == 0 { (y.fixed, x.fixed) } else { (x.fixed, y.fixed) }
        if on(p, x) and on(p, y) {
          let crossing = x.low < p.at(x.axis) and p.at(x.axis) < x.high and y.low < p.at(y.axis) and p.at(y.axis) < y.high
          (contacts, proper, allowed) = contact(p, crossing, contacts, proper, allowed)
        }
      }
    }
  }
  (overlap: accidental, raw-overlap: raw, shared: calc.max(0, raw - accidental), exposure: proximity,
    contacts: contacts.len(), crossings: proper.len(), touches: contacts.len() - proper.len(), junction-contacts: allowed.len())
}

#let metrics(scene, edges, records, spacing: 3, weight: 4) = {
  let result = (missing: 0, overlap: 0, raw-overlap: 0, shared: 0, exposure: 0, length: 0, score: 0,
    contacts: 0, crossings: 0, touches: 0, junction-contacts: 0)
  for (i, r) in records.enumerate() {
    if r.status != "ok" { result.missing += 1; continue }
    result.length += r.length; result.score += r.score
    for j in range(i) {
      if records.at(j).status != "ok" or r.page != records.at(j).page { continue }
      let pair = pair-metrics(scene, edges.at(i), r, edges.at(j), records.at(j), spacing)
      for (k, v) in pair { result.at(k) += v }
    }
  }
  let energy = result.score + weight * result.exposure
  assert((result.length, result.score, result.exposure, result.overlap, result.shared, energy)
    .all(v => v == v and calc.abs(v) < calc.inf),
    message: "deixis: Routing group costs overflow; reduce coordinate magnitudes or weight.")
  result + (energy: energy)
}
