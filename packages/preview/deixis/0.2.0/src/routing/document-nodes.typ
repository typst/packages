#import "endpoints.typ": _deixis-endpoint-index, _deixis-original-node, _deixis-region-node, _deixis-connection-body-node
#import "../core/endpoints.typ": _deixis-endpoint-selector
#import "../core/pins.typ": _deixis-pin-selector
#import "../core/query.typ": _deixis-pin-index, _deixis-select-pins, _deixis-pins-for
#import "../core/visibility.typ": _deixis-is-hidden
#import "../core/utils.typ": resolve-padding, _deixis-padding-spec
#import "../layout/geometry.typ": _deixis-region-bounds
#import "../core/state.typ": deixis-setup-state
#import "connector-scene.typ": _deixis-scene-entity

#let _deixis-scene-note-node(index, spec) = {
  let role = if "mark" in spec { "mark" } else { "body" }
  let selector = _deixis-endpoint-selector(spec.pairs().filter(((key, value)) => key in (role, "point", "occurrence"))
    .fold((:), (out, pair) => out + ((pair.first()): pair.last())), role)
  let uid = index.identities.aliases.at(selector.target, default: none)
  assert(uid != none, message: "deixis: Document scene has an unknown annotation target " + repr(selector.target))
  if role == "body" {
    if uid in index.hidden-bodies { return (hidden: true,) }
    let node = _deixis-connection-body-node(index, selector, uid, validate: true)
    if "page" in spec {
      assert(spec.page == node.page, message: "deixis: Document scene body page does not match its accepted frame or selected live point.")
    }
    return node
  }
  let region = none
  let node = none
  if selector.occurrence == none {
    region = index.anchors.regions.at(uid, default: none)
    let mark = if region != none { region } else { index.anchors.marks.at(uid, default: none) }
    if mark != none and _deixis-is-hidden(mark.value) { return (hidden: true,) }
  } else {
    let site = index.occurrences.at(uid, default: (:)).at(selector.occurrence, default: none)
    assert(site != none, message: "deixis: Document scene has an unknown mark occurrence " + repr(selector.occurrence))
    if _deixis-is-hidden(site.value) { return (hidden: true,) }
    region = index.repeated-regions.at(uid, default: (:)).at(selector.occurrence, default: none)
    node = index.repeated.at(uid, default: (:)).at(selector.occurrence, default: none)
    if (region != none and _deixis-is-hidden(region.value)) or (node != none and _deixis-is-hidden(node)) { return (hidden: true,) }
  }
  if region != none {
    let pins = _deixis-pins-for(index.anchors.pin-index, region.value.pins)
    assert(pins.len() > 0, message: "deixis: Document scene region has no drawable pins.")
    let pages = pins.map(p => p.location().page()).sorted().dedup()
    assert(pages.len() == 1 or "page" in spec,
      message: "deixis: Document scene multi-page region requires an explicit page fragment.")
    let page = spec.at("page", default: pages.first())
    assert(pages.first() <= page and page <= pages.last(), message: "deixis: Document scene region page is outside its painted span.")
    node = _deixis-region-node(index, region, (annotation: uid, occurrence: selector.occurrence), page)
  } else if selector.occurrence == none {
    node = _deixis-original-node(index, uid, none)
  }
  assert(node != none, message: "deixis: Document scene mark needs one drawable frame; empty or fragmented inline occurrences have no rectangular frame.")
  if "page" in spec {
    assert(spec.page == node.page, message: "deixis: Document scene mark page does not match its painted frame.")
  }
  node
}

// Shared structural validation is query-free. Routing scopes can validate an
// unused/manual specification without requiring its eventual painted geometry.
#let _deixis-scene-node-selector(spec) = {
  assert(type(spec) == dictionary, message: "deixis: Document scene nodes must be dictionaries.")
  let selectors = ("bounds", "mark", "body", "pin", "pins").filter(k => k in spec)
  assert(selectors.len() == 1, message: "deixis: Document scene node needs exactly one bounds, mark, body, pin, or pins selector.")
  let selector = selectors.first()
  let keys = ("id", "page", "behavior", selector)
  if selector != "bounds" { keys += ("padding",) }
  if selector == "mark" { keys += ("occurrence",) }
  if selector == "body" { keys += ("point",) }
  assert(spec.keys().all(k => k in keys), message: "deixis: Document scene node has an unsupported field for its selector.")
  if "page" in spec {
    assert((selector == "bounds" and spec.page == none) or (type(spec.page) == int and spec.page > 0), message: "deixis: Document scene page must be a positive physical page integer.")
  }
  if selector in ("mark", "body") {
    let _ = _deixis-endpoint-selector(spec.pairs().filter(((k, v)) => k in (selector, "point", "occurrence"))
      .fold((:), (out, pair) => out + ((pair.first()): pair.last())), selector)
  }
  if "id" in spec {
    assert(spec.id == none or (type(spec.id) in (str, label) and str(spec.id) != ""),
      message: "deixis: Routing scene node ID must be a nonempty string or label.")
  }
  if "behavior" in spec {
    assert(spec.behavior in ("avoid", "ignore", "cut", "cross"),
      message: "deixis: Routing scene behavior must be avoid, ignore, cut, or cross.")
  }
  if selector != "bounds" { let _ = _deixis-padding-spec(spec.at("padding", default: 0pt)) }
  if selector == "pins" {
    assert(type(spec.pins) == array and spec.pins.len() > 0,
      message: "deixis: Document scene pins must be a nonempty array of pin targets.")
  }
  if selector in ("pin", "pins") {
    for target in (if selector == "pin" { (spec.pin,) } else { spec.pins }) {
      let _ = _deixis-pin-selector(target, default: "unique")
    }
  }
  selector
}

// Resolve the complete request batch once, without replaying content or applying
// style callbacks. Only callers using document selectors incur these queries.
#let _deixis-document-scene-nodes(specs) = {
  assert(deixis-setup-state.final(), message: "deixis: Document scene selectors require deixis-setup-notes; resolved numeric bounds need no setup.")
  let notes = specs.any(s => type(s) == dictionary and ("mark" in s or "body" in s))
  let pins = specs.any(s => type(s) == dictionary and ("pin" in s or "pins" in s))
  let index = if notes { _deixis-endpoint-index() } else { none }
  let pin-index = if notes { index.anchors.pin-index } else if pins { _deixis-pin-index() } else { none }
  let nodes = ()
  for spec in specs {
    let selector = _deixis-scene-node-selector(spec)
    if selector == "bounds" { nodes.push(spec); continue }
    let node = none
    let entity = none
    if selector in ("mark", "body") {
      node = _deixis-scene-note-node(index, spec)
      if not _deixis-is-hidden(node) { entity = _deixis-scene-entity(selector, node.identity) }
    } else {
      let targets = if selector == "pin" { (spec.pin,) } else { spec.pins }
      assert(type(targets) == array and targets.len() > 0, message: "deixis: Document scene pins must be a nonempty array of pin targets.")
      let selected = targets.map(t => _deixis-select-pins(pin-index, t, default: "unique", page: spec.at("page", default: none),
        single: true, required: true).first())
      if selected.any(p => _deixis-is-hidden(p.value)) { node = (hidden: true,) }
      else {
        let page = selected.first().location().page()
        assert(selected.all(p => p.location().page() == page),
          message: "deixis: Document scene pin bounds cannot merge different page planes; select a single page fragment.")
        let pos = selected.first().location().position()
        if selector == "pin" { entity = (role: "pin", location: selected.first().location()) }
        node = (page: page, bounds: if selector == "pin" { (left: pos.x, top: pos.y, right: pos.x, bottom: pos.y) }
          else { _deixis-region-bounds(selected, page) })
      }
    }
    let hidden = _deixis-is-hidden(node)
    let pad = resolve-padding(spec.at("padding", default: 0pt))
    let bounds = none
    if not hidden {
      let b = node.bounds
      bounds = (left: b.left - pad.left, top: b.top - pad.top, right: b.right + pad.right, bottom: b.bottom + pad.bottom)
    }
    let point = hidden or (bounds.left == bounds.right or bounds.top == bounds.bottom)
    nodes.push((id: spec.at("id", default: none), bounds: bounds, page: if hidden { none } else { node.page },
      behavior: spec.at("behavior", default: if point { "ignore" } else { "avoid" }), _hidden: hidden, _entity: entity))
  }
  let pages = query(<deixis-page-frame>).filter(f => nodes.any(n => n.at("page", default: none) == f.value.page)).map(f => (
    page: f.value.page, bounds: (left: 0pt, top: 0pt, right: f.value.width, bottom: f.value.height)))
  (nodes: nodes, pages: pages)
}
