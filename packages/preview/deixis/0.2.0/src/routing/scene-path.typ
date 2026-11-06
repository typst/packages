#import "avoid.typ": _deixis-avoid
#import "geometry.typ": _deixis-sub

#let _deixis-scene-search-endpoint(e) = {
  assert(e.normal == auto or e.normal in ((1, 0), (0, 1), (-1, 0), (0, -1)),
    message: "deixis: Numeric scene avoidance needs cardinal endpoint normals.")
  (point: e.point.map(v => v.pt()), normal: if e.normal == auto { none } else { e.normal }, owner: e.owner,
    owner-gap: e.at("owner-gap", default: 0pt).pt())
}

// Preserve exact vertices at the one native search/geometry boundary. Group
// repair reuses accepted results without running the search or body code again.
#let _deixis-scene-search-geometry(result, page, boundary: none, reverse: false) = {
  if result.status != "ok" {
    return (kind: "deixis-route-failure", status: result.status, detail: result.detail, page: page, stats: result.stats)
  }
  // Retain exact safe vertices. The ordinary native builder's tiny-segment
  // cleanup and optional rounding are inappropriate for clearance boundaries.
  let points = (if reverse { result.points.rev() } else { result.points }).map(p => p.map(v => v * 1pt))
  let origin = points.first()
  let local = points.map(p => _deixis-sub(p, origin))
  let shaft = local.windows(2).map(((a, b)) => (kind: "line", start: a, end: b))
  let tangent(a, b) = { let delta = _deixis-sub(b, a); let d = calc.abs(delta.first()) + calc.abs(delta.last()); delta.map(v => v / d) }
  let geometry = (kind: "deixis-route", frame: "source-local-x-right-y-down",
    origin: origin, start: (0pt, 0pt), end: local.last(), segments: shaft,
    bounds: (left: calc.min(..local.map(p => p.first())), right: calc.max(..local.map(p => p.first())),
      top: calc.min(..local.map(p => p.last())), bottom: calc.max(..local.map(p => p.last())),
      center-x: (calc.min(..local.map(p => p.first())) + calc.max(..local.map(p => p.first()))) / 2,
      center-y: (calc.min(..local.map(p => p.last())) + calc.max(..local.map(p => p.last()))) / 2),
    length: result.length * 1pt, gaps: (), has-start: shaft.len() > 0, has-end: shaft.len() > 0,
    start-tangent: if shaft.len() == 0 { (0, 0) } else { tangent(shaft.first().start, shaft.first().end) },
    end-tangent: if shaft.len() == 0 { (0, 0) } else { tangent(shaft.last().start, shaft.last().end) })
  let allocation = if boundary == none and "preference" not in result { (:) } else {
    (preference: result.preference * 1pt, allocation-cost: result.allocation-cost * 1pt)
  }
  let selection = if "selection" not in result { (:) } else {
    let port(e) = (point: e.point.map(v => v * 1pt), normal: if e.normal == none { (0, 0) } else { e.normal },
      axis: if e.normal == none { "none" } else if e.normal.first() == 0 { "vertical" } else { "horizontal" })
    let s = result.selection
    (selection: (source: port(if reverse { s.target } else { s.source }), target: port(if reverse { s.source } else { s.target })))
  }
  geometry + (search: result.stats + (bends: result.bends, score: result.score * 1pt) + allocation, status: "ok", page: page) + selection
}

// Shared pure search/geometry boundary for numeric callers and document page
// fragments. Inputs are resolved page-plane ports and prepared scene indexes.
#let _deixis-scene-orthogonal(scene, prepared, start, end, via, page, boundary: none, reverse: false,
  sources: none, targets: none,
) = {
  let result = _deixis-avoid(_deixis-scene-search-endpoint(start), _deixis-scene-search-endpoint(end), prepared, via: via,
    clearance: scene.clearance, escape: scene.escape, bend-cost: scene.bend-cost,
    max-cells: scene.max-cells, max-expansions: scene.max-expansions, boundary: boundary,
    sources: if sources == none { none } else { sources.map(_deixis-scene-search-endpoint) },
    targets: if targets == none { none } else { targets.map(_deixis-scene-search-endpoint) })
  _deixis-scene-search-geometry(result, page, boundary: boundary, reverse: reverse)
}
