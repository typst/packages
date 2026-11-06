#import "numeric.typ": _deixis-numeric-length, _deixis-numeric-endpoint
#import "scene-index.typ": _deixis-scene-index
#import "document-nodes.typ": _deixis-document-scene-nodes

#let _deixis-scene-id(value) = {
  if type(value) == label { value = str(value) }
  assert(type(value) == str and value != "", message: "deixis: Routing scene node ID must be a nonempty string or label.")
  value
}

#let _deixis-scene-page(value) = {
  assert(value == none or (type(value) == int and value > 0),
    message: "deixis: Routing scene page must be none or a positive physical page integer.")
  value
}

#let _deixis-scene-bounds(value, point: false) = {
  assert(type(value) == dictionary and value.keys().sorted() == ("bottom", "left", "right", "top")
    and value.values().all(_deixis-numeric-length) and value.left <= value.right and value.top <= value.bottom
    and (point or (value.left < value.right and value.top < value.bottom)),
    message: "deixis: Routing scene bounds need finite absolute left/top/right/bottom lengths and positive width/height; only ignore nodes allow zero-area points.")
  value
}

/// Prepares reusable rectangular nodes in independent caller-defined page planes.
/// behavior is avoid (default), ignore, cut, or cross. Cut hides the shaft inside
/// the node; cross reports entry/exit only, without enabling visual decorations.
/// Document mark/body/pin selectors read accepted geometry in a context with
/// setup. Resolved bounds stay query-free. No live content is executed/measured.
#let deixis-routing-scene(
  /// Up to 128 node records with numeric bounds or accepted document selectors, optional IDs and avoid/ignore/cut/cross behavior.
  /// -> array
  nodes: (),
  /// Nonnegative absolute padding around avoidance rectangles; checks centerlines, not full painted ink.
  /// -> length
  clearance: 4pt,
  /// Positive absolute endpoint escape distance for automatic orthogonal sockets.
  /// -> length
  escape: 4pt,
  /// Nonnegative absolute turn penalty in the orthogonal search cost.
  /// -> length
  bend-cost: 12pt,
  /// Optional left/top/right/bottom search rectangle for the default plane.
  /// -> none | dictionary
  bounds: none,
  /// Explicit page-plane records, each with a positive physical page and required bounds rectangle.
  /// -> array
  pages: (),
  /// Positive integer grid-cell budget for each search.
  /// -> int
  max-cells: 65536,
  /// Positive integer search expansion budget.
  /// -> int
  max-expansions: 50000,
) = {
  assert(type(nodes) == array and nodes.len() <= 128,
    message: "deixis: Routing scene nodes must be an array of at most 128 rectangles.")
  assert(_deixis-numeric-length(clearance) and clearance >= 0pt
    and _deixis-numeric-length(escape) and escape > 0pt
    and _deixis-numeric-length(bend-cost) and bend-cost >= 0pt,
    message: "deixis: Routing scene clearance/bend-cost need finite nonnegative absolute lengths; escape must be positive.")
  assert(type(max-cells) == int and max-cells > 0 and type(max-expansions) == int and max-expansions > 0,
    message: "deixis: Routing scene search limits must be positive integers.")
  let document = nodes.any(n => type(n) == dictionary and ("mark", "body", "pin", "pins").any(k => k in n))
  let inferred-pages = ()
  if document {
    let resolved = _deixis-document-scene-nodes(nodes)
    nodes = resolved.nodes
    inferred-pages = resolved.pages
  }
  if bounds != none { bounds = _deixis-scene-bounds(bounds) }
  assert(type(pages) == array, message: "deixis: Routing scene pages must be an array of (page:, bounds:) records.")
  let page-bounds = (:)
  for entry in pages {
    assert(type(entry) == dictionary and entry.keys().sorted() == ("bounds", "page") and entry.page != none,
      message: "deixis: Routing scene pages need exactly page and bounds.")
    let page = str(_deixis-scene-page(entry.page))
    assert(page not in page-bounds, message: "deixis: Routing scene has duplicate page bounds.")
    page-bounds.insert(page, _deixis-scene-bounds(entry.bounds))
  }
  for entry in inferred-pages {
    let page = str(entry.page)
    if page not in page-bounds { page-bounds.insert(page, _deixis-scene-bounds(entry.bounds)) }
  }
  nodes = nodes.enumerate().map(((index, node)) => {
    let keys = ("id", "bounds", "behavior", "page") + if document { ("_hidden", "_entity") } else { () }
    assert(type(node) == dictionary and "bounds" in node and node.keys().all(k => k in keys),
      message: "deixis: Routing scene nodes accept id, bounds, behavior, and page; bounds is required.")
    let id = node.at("id", default: none)
    if id != none {
      id = _deixis-scene-id(id)
    }
    let behavior = node.at("behavior", default: "avoid")
    assert(behavior in ("avoid", "ignore", "cut", "cross"),
      message: "deixis: Routing scene behavior must be avoid, ignore, cut, or cross.")
    let hidden = node.at("_hidden", default: false)
    (id: id, index: index, hidden: hidden, entity: node.at("_entity", default: none),
      bounds: if hidden { none } else { _deixis-scene-bounds(node.bounds, point: behavior == "ignore") }, behavior: behavior,
      page: _deixis-scene-page(node.at("page", default: none)))
  })
  // Build identity lookup in the enclosing scope, outside mapping closures.
  let ids = (:)
  for node in nodes {
    if node.id != none {
      assert(node.id not in ids, message: "deixis: Routing scene has a duplicate node ID: " + repr(node.id))
      ids.insert(node.id, node.index)
    }
  }
  let planes = ()
  let page-keys = ((none,) + nodes.map(n => n.page) + page-bounds.keys().map(int)).sorted(key: repr).dedup()
  for page in page-keys {
    let selected = nodes.filter(n => n.page == page and not n.hidden)
    let originals = selected.filter(n => n.behavior == "avoid").map(n => n.bounds.pairs().fold((id: n.index), (r, pair) => r + ((pair.first()): pair.last().pt())))
    let obstacles = originals.map(r => (id: r.id, left: r.left - clearance.pt(), right: r.right + clearance.pt(),
      top: r.top - clearance.pt(), bottom: r.bottom + clearance.pt()))
    assert(obstacles.all(r => (r.left, r.top, r.right, r.bottom).all(v => v == v and calc.abs(v) < calc.inf)),
      message: "deixis: Routing scene inflated bounds overflow; reduce coordinate magnitudes or clearance.")
    let limit = if page == none { bounds } else { page-bounds.at(str(page), default: none) }
    planes.push((page: page, nodes: selected, originals: originals, obstacles: obstacles,
      bounds: if limit == none { none } else { limit.pairs().fold((:), (r, pair) => r + ((pair.first()): pair.last().pt())) },
      vertical: _deixis-scene-index(obstacles, vertical: true), horizontal: _deixis-scene-index(obstacles)))
  }
  (kind: "deixis-routing-scene", nodes: nodes, ids: ids, planes: planes,
    clearance: clearance.pt(), escape: escape.pt(), bend-cost: bend-cost.pt(),
    max-cells: max-cells, max-expansions: max-expansions)
}

#let _deixis-scene-node(scene, id) = {
  let id = _deixis-scene-id(id)
  assert(id in scene.ids, message: "deixis: Routing scene has no node named " + repr(id))
  scene.nodes.at(scene.ids.at(id))
}

#let _deixis-scene-endpoint(scene, value) = {
  if type(value) in (str, label) { value = (node: value) }
  if type(value) == dictionary and "node" in value {
    assert(value.keys().all(k => k in ("node", "side", "at")),
      message: "deixis: Routing scene node endpoint accepts node, side, and at.")
    let node = _deixis-scene-node(scene, value.node)
    let side = value.at("side", default: auto)
    let at = value.at("at", default: 50%)
    assert(side == auto or side in (left, right, top, bottom),
      message: "deixis: Routing scene endpoint side must be auto, left, right, top, or bottom.")
    assert(type(at) == ratio and 0% <= at and at <= 100%,
      message: "deixis: Routing scene endpoint at must be between 0% and 100%.")
    if node.hidden { return (node: node, center: none) }
    let b = node.bounds
    return (node: node, side: side, at: at, center: ((b.left + b.right) / 2, (b.top + b.bottom) / 2))
  }
  let owner = if type(value) == dictionary { value.at("owner", default: none) } else { none }
  if type(value) == dictionary and "owner" in value { let _ = value.remove("owner") }
  let endpoint = _deixis-numeric-endpoint(value)
  endpoint + (node: if owner == none { none } else { _deixis-scene-node(scene, owner) }, center: endpoint.point)
}

#let _deixis-scene-port(endpoint, toward) = {
  let node = endpoint.node
  if "side" in endpoint {
    let side = endpoint.side; let b = node.bounds
    if side == auto and b.left == b.right and b.top == b.bottom {
      return (point: (b.left, b.top), normal: auto, axis: "none", owner: none)
    }
    if side == auto {
      let dx = toward.first() - endpoint.center.first(); let dy = toward.last() - endpoint.center.last()
      side = if calc.abs(dx) >= calc.abs(dy) { if dx >= 0pt { right } else { left } }
        else if dy >= 0pt { bottom } else { top }
    }
    let at = endpoint.at
    let point = if side in (left, right) { (if side == left { b.left } else { b.right }, b.top + at * (b.bottom - b.top)) }
      else { (b.left + at * (b.right - b.left), if side == top { b.top } else { b.bottom }) }
    endpoint = _deixis-numeric-endpoint((point: point, normal: side))
  }
  (point: endpoint.point, normal: endpoint.normal, axis: endpoint.axis,
    owner: if node != none and node.behavior == "avoid" { node.index } else { none })
}

// Resolve once for both single routes and explicit groups. Native page planes,
// hidden endpoints and automatic side choices have one contract.
#let _deixis-scene-pair(scene, from, to, page) = {
  assert(type(scene) == dictionary and scene.at("kind", default: none) == "deixis-routing-scene",
    message: "deixis: Numeric routing scene must come from deixis-routing-scene.")
  let source = _deixis-scene-endpoint(scene, from)
  let target = _deixis-scene-endpoint(scene, to)
  page = _deixis-scene-page(page)
  if (source.node != none and source.node.hidden) or (target.node != none and target.node.hidden) {
    return (kind: "deixis-route-failure", status: "endpoint-hidden", page: page, stats: (:),
      detail: if source.node != none and source.node.hidden { "source" } else { "target" })
  }
  let node-pages = (source.node, target.node).filter(n => n != none).map(n => n.page).dedup()
  assert(node-pages.len() <= 1 and (node-pages.len() == 0 or page == none or page == node-pages.first()),
    message: "deixis: Numeric scene routing connects one page plane; route separate fragments for cross-page endpoints.")
  if node-pages.len() == 1 { page = node-pages.first() }
  let prepared = scene.planes.find(p => p.page == page)
  assert(prepared != none, message: "deixis: Numeric routing page is absent from the scene; declare its bounds or a node on that page.")
  (kind: "deixis-scene-pair", source: source, target: target, page: page, prepared: prepared,
    start: _deixis-scene-port(source, target.center), end: _deixis-scene-port(target, source.center))
}
