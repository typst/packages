#import "geometry.typ": _deixis-add, _deixis-sub, _deixis-lerp, _deixis-distance, _deixis-segment-length, _deixis-segment-tangent
#import "intersections.typ": _deixis-intersection-tree, _deixis-segment-intersections
#import "cuts.typ": _deixis-prepare-cuts, _deixis-cut-path
#import "gaps.typ": _deixis-path-gaps
#import "../core/utils.typ": resolve-signed-len
#import "../core/visibility.typ": _deixis-is-hidden

#let _deixis-crossing-spec(value) = {
  if value == none { return none }
  let spec = if value == "gap" { (:) } else { value }
  assert(type(spec) == dictionary and spec.keys().all(k => k in ("mode", "group", "gap", "clearance")),
    message: "deixis: connector.crossings must be none, gap, or a mode/group/gap/clearance dictionary.")
  assert(spec.at("mode", default: "gap") == "gap",
    message: "deixis: connector.crossings currently supports mode: gap only.")
  let group = spec.at("group", default: "default")
  assert(type(group) in (str, label) and str(group).len() > 0,
    message: "deixis: connector.crossings group must be a nonempty string or label.")
  let gap = spec.at("gap", default: 8pt)
  let clearance = spec.at("clearance", default: 4pt)
  assert(type(gap) == length and type(clearance) == length,
    message: "deixis: connector.crossings gap/clearance must be lengths, without percentages.")
  gap = resolve-signed-len(gap)
  clearance = resolve-signed-len(clearance)
  assert(gap > 0pt and clearance >= 0pt,
    message: "deixis: connector.crossings gap must be positive and clearance nonnegative.")
  (mode: "gap", group: str(group), gap: gap, clearance: clearance)
}

// Merge straight-through lines, retaining original cubics, real turns, and gaps.
// Every segment gets its actual arc distance and continuous visible fragment.
#let _deixis-crossing-path(segments) = {
  let merged = ()
  for s in segments {
    if _deixis-segment-length(s) <= 0.00001pt { continue }
    if s.kind == "line" and merged.len() > 0 and merged.last().kind == "line" and _deixis-distance(merged.last().end, s.start) <= 0.00001pt {
      let a = _deixis-sub(merged.last().end, merged.last().start).map(v => v / 1pt)
      let b = _deixis-sub(s.end, s.start).map(v => v / 1pt)
      let cross = a.first() * b.last() - a.last() * b.first()
      let dot = a.first() * b.first() + a.last() * b.last()
      if calc.abs(cross) <= 0.00000001 * calc.max(1, dot) and dot > 0 {
        merged.last().end = s.end
        continue
      }
    }
    merged.push(s)
  }
  let fragments = ()
  for s in merged {
    if fragments.len() == 0 or _deixis-distance(fragments.last().last().end, s.start) > 0.00001pt {
      fragments.push((s,))
    } else { fragments.last().push(s) }
  }
  let result = ()
  let distance = 0pt
  for fragment in fragments {
    let start = distance
    let length = fragment.map(_deixis-segment-length).fold(0pt, (a, b) => a + b)
    let smooth(a, b) = {
      let x = _deixis-segment-tangent(a, end: true)
      let y = _deixis-segment-tangent(b)
      (x.first() * y.first() + x.last() * y.last() > 0 and
        calc.abs(x.first() * y.last() - x.last() * y.first()) < 0.000001)
    }
    for (i, s) in fragment.enumerate() {
      let size = _deixis-segment-length(s)
      result.push(s + (at: distance, length: size, fragment-start: start, fragment-end: start + length,
        smooth-start: i > 0 and smooth(fragment.at(i - 1), s),
        smooth-end: i + 1 < fragment.len() and smooth(s, fragment.at(i + 1)), tree: _deixis-intersection-tree(s)))
      distance += size
    }
  }
  result
}

// Proper interior intersections only. Shared endpoints, corners, tangencies,
// parallel lines, and collinear overlap do not create a crossing gap.
#let _deixis-line-crossing(a, b) = {
  let r = _deixis-sub(a.end, a.start).map(v => v / 1pt)
  let s = _deixis-sub(b.end, b.start).map(v => v / 1pt)
  let q = _deixis-sub(b.start, a.start).map(v => v / 1pt)
  let cross(a, b) = a.first() * b.last() - a.last() * b.first()
  let den = cross(r, s)
  let norm = a.length / 1pt * (b.length / 1pt)
  if calc.abs(den) <= 0.00000001 * norm { return none }
  let t = cross(q, s) / den
  let u = cross(q, r) / den
  if (t * a.length <= 0.00001pt or (1 - t) * a.length <= 0.00001pt or
    u * b.length <= 0.00001pt or (1 - u) * b.length <= 0.00001pt) { return none }
  (point: _deixis-lerp(a.start, a.end, t), a: a.at + t * a.length,
    b: b.at + u * b.length, sine: calc.abs(den) / norm,
    cosine: calc.abs(r.first() * s.first() + r.last() * s.last()) / norm)
}

// Highest painted routes are solved first. Lower lines see their actual visible
// pieces, avoiding phantom cuts beneath a higher line's own automatic gap.
#let _deixis-crossing-plans(records) = {
  let result = (:)
  let higher = ()
  for record in records.filter(r => r.supported and r.thickness > 0pt).sorted(key: r => r.order).rev() {
    let lines = record.at("path", default: none)
    if lines == none { lines = _deixis-crossing-path(record.shaft) }
    let intervals = ()
    let hits = ()
    let skipped = ()
    let seen = ()
    for upper in higher {
      if (record.page, record.layer, record.spec.group) != (upper.page, upper.layer, upper.spec.group) { continue }
      for a in lines {
        for b in upper.lines {
          let candidates = if a.kind == "line" and b.kind == "line" {
            let h = _deixis-line-crossing(a, b)
            if h == none { () } else { (h,) }
          } else { _deixis-segment-intersections(a, b) }
          for hit in candidates {
            // Smooth segment joins and subdivision boundaries may report one
            // physical crossing twice; retain distinct close roots on loops.
            if seen.any(h => h.over == upper.order and calc.abs(h.at - hit.a) < 0.00001pt) { continue }
            seen.push((over: upper.order, at: hit.a))
            let cap = if record.cap in ("round", "square") { record.thickness } else { 0pt }
            let width = calc.max(record.spec.gap,
              (upper.thickness + record.thickness * hit.cosine) / hit.sine + cap)
            let left = hit.a - width / 2
            let right = hit.a + width / 2
            if (left < a.fragment-start + record.spec.clearance or
              right > a.fragment-end - record.spec.clearance or
              hit.b < b.fragment-start + upper.spec.clearance or
              hit.b > b.fragment-end - upper.spec.clearance) {
              skipped.push((point: hit.point, over: upper.order, reason: "clearance"))
              continue
            }
            intervals.push((from: left, to: right))
            hits.push((point: hit.point, over: upper.order, from: left, to: right))
          }
        }
      }
    }
    let length = lines.map(s => s.length).fold(0pt, (a, b) => a + b)
    let cuts = _deixis-prepare-cuts(intervals, length)
    result.insert(str(record.order.last()), (cuts: cuts, hits: hits, skipped: skipped))
    let visible = _deixis-cut-path(record.shaft, cuts)
    higher.push(record + (lines: if cuts.len() == 0 { lines } else { _deixis-crossing-path(visible) }))
  }
  result
}

#let _deixis-crossing-record(request, spec) = {
  let doc = request.route.document
  assert("crossing-order" in doc,
    message: "deixis: connector.crossings requires the Deixis page overlay; direct layout hooks do not collect crossing groups.")
  let origin = request.route.origin
  let thickness = if request.stroke == none { 0pt } else { resolve-signed-len(request.stroke.thickness) }
  let shaft = request.shaft.map(s => {
    let s = s + (start: _deixis-add(origin, s.start), end: _deixis-add(origin, s.end))
    if s.kind == "cubic" { s += (c1: _deixis-add(origin, s.c1), c2: _deixis-add(origin, s.c2)) }
    s
  })
  let path = if thickness > 0pt { _deixis-crossing-path(shaft) } else { () }
  (page: doc.page, layer: doc.layer, order: doc.crossing-order, spec: spec,
    supported: path.all(s => s.tree.resolved), path: path, thickness: thickness,
    cap: if request.stroke == none { "butt" } else { request.stroke.cap },
    shaft: shaft)
}

#let _deixis-apply-crossings(request, record) = {
  let origin = request.route.origin
  let records = query(<deixis-crossing-route>).map(m => m.value).filter(r => (
    not _deixis-is-hidden(r) and (r.page, r.layer, r.spec.group) == (record.page, record.layer, record.spec.group)
  ))
  let plan = _deixis-crossing-plans(records).at(str(record.order.last()), default: (cuts: (), hits: (), skipped: ()))
  let shaft = _deixis-cut-path(request.shaft, plan.cuts)
  let local-plan = plan + (
    hits: plan.hits.map(h => h + (point: _deixis-sub(h.point, origin))),
    skipped: plan.skipped.map(h => h + (point: _deixis-sub(h.point, origin))))
  request + (shaft: shaft, gaps: _deixis-path-gaps(shaft),
    crossings: record.spec + local-plan + (order: record.order, frame: "source-local-x-right-y-down"))
}

#let _deixis-validate-crossings() = {
  for item in query(<deixis-crossing-route>) {
    if _deixis-is-hidden(item.value) { continue }
    assert(item.value.supported,
      message: "deixis: connector.crossings curve precision limit exceeded (0.01pt, depth 12, 1024 leaves per segment). Simplify the geometry, reduce its scale, or use explicit cuts.")
  }
}
