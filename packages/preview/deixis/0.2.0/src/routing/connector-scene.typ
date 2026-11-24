#import "scene-path.typ": _deixis-scene-orthogonal
#import "scene-interactions.typ": _deixis-scene-interactions
#import "numeric.typ": _deixis-numeric-length
#import "sliding.typ": _deixis-sliding-ports

// Value validation is intentionally independent of late scene construction.
#let _deixis-connector-scene-spec(value) = {
  assert(value == none or type(value) == function or (type(value) == dictionary
    and value.at("kind", default: none) == "deixis-routing-scene"),
    message: "deixis: connector.scene must be none, a prepared routing scene, or a function taking the page-fragment record.")
  value
}

#let _deixis-connector-scene(value, document) = {
  let scene = if type(value) == function { value(document) } else { value }
  assert(type(scene) == dictionary and scene.at("kind", default: none) == "deixis-routing-scene",
    message: "deixis: connector.scene callback must return deixis-routing-scene geometry.")
  // An absent physical page is empty, never a request to reuse unpaged nodes.
  let plane = scene.planes.find(p => p.page == document.page)
  if plane == none {
    plane = (page: document.page, nodes: (), originals: (), obstacles: (), bounds: none,
      horizontal: (levels: (), boundary: (), slab: ()), vertical: (levels: (), boundary: (), slab: ()))
  }
  (scene: scene, plane: plane)
}

// Document selectors preserve numeric identity separately from user scene IDs.
// Matching an owner is semantic, never "any rectangle containing this point".
#let _deixis-scene-entity(role, identity) = {
  if identity == none { return none }
  if type(identity) == dictionary and "node" in identity {
    return (role: "node", location: identity.node)
  }
  if type(identity) == dictionary and "pin" in identity {
    return (role: "pin", location: identity.location)
  }
  if type(identity) == dictionary and "annotation" in identity {
    return (role: role, annotation: str(identity.annotation), occurrence: identity.at("occurrence", default: none),
      point: identity.at("point", default: none))
  }
  (role: role, annotation: str(identity), occurrence: none, point: none)
}

#let _deixis-scene-connector-port(plane, point, normal, logical, role) = {
  let owner = none
  let owner-gap = 0pt
  let entity = if logical == none { none } else { _deixis-scene-entity(role, logical.identity) }
  for node in plane.nodes {
    if node.behavior != "avoid" or entity == none or node.at("entity", default: none) != entity { continue }
    let b = node.bounds
    let p = point
    // Preserve ordinary port gaps outside the owned frame. Project only along
    // its outward ray; interior sockets/padded frames receive no exemption.
    let on-border = (((normal == (1, 0) and p.first() >= b.right) or (normal == (-1, 0) and p.first() <= b.left))
      and b.top <= p.last() and p.last() <= b.bottom)
    on-border = on-border or (((normal == (0, 1) and p.last() >= b.bottom) or (normal == (0, -1) and p.last() <= b.top))
      and b.left <= p.first() and p.first() <= b.right)
    if on-border {
      assert(owner == none, message: "deixis: connector.scene registers the same endpoint as multiple avoidance owners; keep one owned node.")
      owner = node.index
      owner-gap = if normal == (1, 0) { p.first() - b.right } else if normal == (-1, 0) { b.left - p.first() }
        else if normal == (0, 1) { p.last() - b.bottom } else { b.top - p.last() }
    }
  }
  (point: point, normal: if normal == (0, 0) { auto } else { normal }, axis: "none", owner: owner, owner-gap: owner-gap)
}

#let _deixis-scene-connector-choices(scene, plane, source, target, visits, document, ports) = {
  let logical = document.fragment.logical
  // Candidate sets come from the adapter after explicit port constraints. Keep
  // the selected port first. Sliding is limited to an already permitted side.
  let candidates(role, preferred, logical, semantic) = {
    let values = (preferred + (sliding: none),) + if ports == none { () } else {
      ports.at(role).map(p => _deixis-scene-connector-port(plane, p.point, p.normal, logical, semantic)
        + (sliding: p.at("sliding", default: none)))
    }
    values.fold((), (out, p) => if p in out { out } else { out + (p,) })
  }
  let sources = candidates("source", source, if document.is-incoming { none } else { logical.source }, "mark")
  let targets = candidates("target", target, if document.is-outgoing { none } else { logical.target }, "body")
  let expanded = _deixis-sliding-ports(sources, targets, plane, visits, scene.clearance, scene.escape)
  // A projected point may leave the registered owner's tangent extent. Never
  // carry its old exemption outside that frame, or into foreign geometry.
  let normalize(p, identity, role) = _deixis-scene-connector-port(plane, p.point,
    if p.normal == auto { (0, 0) } else { p.normal }, identity, role)
  sources = expanded.source.map(p => normalize(p, if document.is-incoming { none } else { logical.source }, "mark"))
  targets = expanded.target.map(p => normalize(p, if document.is-outgoing { none } else { logical.target }, "body"))
  (source: sources, target: targets)
}

#let _deixis-connector-scene-plan(prepared, start, end, waypoints, document, route-kind, radius,
  boundary: none, ports: none,
) = {
  let plane = prepared.plane
  let scene = prepared.scene
  assert(_deixis-numeric-length(radius) and radius >= 0pt,
    message: "deixis: connector.scene radius must resolve to a finite nonnegative length.")
  // Scenes without avoid nodes can annotate/cut any native curve after routing.
  if plane.obstacles.len() == 0 { return none }
  assert(route-kind == "right-angle" and radius == 0pt and waypoints.all(wp => type(wp) == array),
    message: "deixis: connector.scene avoidance requires orthogonal routing, radius: 0pt, and point-only active waypoints; curves, smoothing and mixed sections need clearance validation.")
  let logical = document.fragment.logical
  let source = _deixis-scene-connector-port(plane, start.point, start.normal,
    if document.is-incoming { none } else { logical.source }, "mark")
  let target = _deixis-scene-connector-port(plane, end.point, end.normal,
    if document.is-outgoing { none } else { logical.target }, "body")
  let visits = waypoints.map(wp => wp.zip(start.point).map(((v, o)) => (v + o).pt()))
  let route = _deixis-scene-orthogonal(scene, plane, source, target, visits, document.page)
  if route.status not in ("no-path", "endpoint-blocked") { return route }
  let choices = _deixis-scene-connector-choices(scene, plane, source, target, visits, document, ports)
  let sources = choices.source; let targets = choices.target
  let move-source = sources.len() > 1 or (boundary != none and document.is-incoming)
  let move-target = targets.len() > 1 or (boundary != none and document.is-outgoing)
  if not (move-source or move-target) { return route }
  // One shared search over permitted alternatives, never a loop of per-pair
  // searches. Hard visits, exact blocked endpoints and exhausted budgets stay
  // failures. The preferred attempt and fallback share one expansion allowance.
  if not (route.status == "no-path" or (route.status == "endpoint-blocked"
    and ((move-source and route.detail.starts-with("source-")) or (move-target and route.detail.starts-with("target-"))))) {
    return route
  }
  let reverse = boundary != none and document.is-incoming
  let spent = route.stats.at("expanded", default: 0)
  let remaining = scene.max-expansions - spent
  if remaining <= 0 {
    return (kind: "deixis-route-failure", status: "budget", detail: if boundary == none { "port-expansions" } else { "continuation-expansions" },
      page: document.page, stats: route.stats)
  }
  let limit = plane.bounds
  if boundary != none {
    // The terminal interval restricts only spill sockets. A shaft can cross
    // text to reach a margin; its search plane uses the physical page bounds.
    let physical = boundary.at("page-bounds", default:
      (left: boundary.left, right: boundary.right, top: boundary.top, bottom: boundary.bottom))
    if limit == none { limit = physical }
    else {
      limit = (left: calc.max(limit.left, physical.left), right: calc.min(limit.right, physical.right),
        top: calc.max(limit.top, physical.top), bottom: calc.min(limit.bottom, physical.bottom))
    }
  }
  let alternatives(values) = if values.len() > 1 { values } else { none }
  let allocated = _deixis-scene-orthogonal(scene + (max-expansions: remaining), plane + (bounds: limit),
    if reverse { target } else { source }, if reverse { source } else { target },
    if reverse { visits.rev() } else { visits }, document.page, boundary: boundary, reverse: reverse,
    sources: alternatives(if reverse { targets } else { sources }),
    targets: if boundary != none { none } else { alternatives(targets) })
  if reverse and allocated.status == "endpoint-blocked" {
    if allocated.detail.starts-with("source-") { allocated.detail = "target-" + allocated.detail.slice(7) }
    else if allocated.detail.starts-with("target-") { allocated.detail = "source-" + allocated.detail.slice(7) }
  }
  let key = if allocated.status == "ok" { "search" } else { "stats" }
  let stats = allocated.at(key)
  stats.insert("attempts", 2)
  stats.insert("expanded", spent + stats.at("expanded", default: 0))
  stats.insert("queued", route.stats.at("queued", default: 0) + stats.at("queued", default: 0))
  stats.insert("cells", calc.max(route.stats.at("cells", default: 0), stats.at("cells", default: 0)))
  allocated.insert(key, stats)
  allocated
}

#let _deixis-connector-scene-events(route, prepared, page) = {
  let events = _deixis-scene-interactions(route, prepared.plane.nodes, page)
  route + (status: "ok", page: page, search: route.at("search", default: none), interactions: events,
    scene-cuts: events.filter(e => e.behavior == "cut").map(e => (from: e.from, to: e.to)))
}

// Failed fragments emit evidence without executing heads, painters or markers.
// Validation is outside painting, so suppressing output cannot erase the error.
#let _deixis-validate-scene-routes() = {
  for record in query(<deixis-scene-route>) {
    let r = record.value
    if r.status != "ok" {
      panic("deixis: connector.scene routing failed on physical page " + str(r.page)
        + ": " + r.status + " (" + r.detail + "). Adjust the registered geometry, ports, waypoints or scene limits; no unchecked fallback was painted.")
    }
  }
}
