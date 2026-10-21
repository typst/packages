#import "../core/visibility.typ": _deixis-metadata, _deixis-is-hidden
#import "../layout/geometry.typ": _deixis-box-bounds
#import "frames.typ": _deixis-frame-node

// Probes surround the one live native frame. They do not measure/replay its
// payload and acquire hidden ancestry through setup's ordinary metadata rules.
#let _deixis-attached-corners(node) = {
  for (corner, anchor) in (("tl", top + left), ("tr", top + right),
    ("bl", bottom + left), ("br", bottom + right)) {
    place(anchor, _deixis-metadata((instance: node.instance, corner: corner), <deixis-attached-corner>))
  }
}

#let _deixis-attached-nodes() = {
  let probes = query(<deixis-attached-corner>)
  let nodes = ()
  let keys = ()
  for declaration in query(<deixis-attached-node>) {
    let data = declaration.value
    let page = declaration.location().page()
    let key = (data.id, data.scope, page)
    if data.id != none {
      assert(key not in keys, message: "deixis: Duplicate attached node ID in the same scope and physical page: " + repr(data.id))
      keys.push(key)
    }
    let corners = probes.filter(p => p.value.instance == data.instance)
    assert(corners.len() == 4 and corners.map(c => c.value.corner).dedup().len() == 4
      and corners.all(c => c.location().page() == page),
      message: "deixis: An attached routing node needs one complete frame on one physical page.")
    let hidden = _deixis-is-hidden(data) or corners.any(c => _deixis-is-hidden(c.value))
    let pos = corners.map(c => c.location().position())
    let bounds = if hidden { none } else { _deixis-box-bounds(
      calc.min(..pos.map(p => p.x)), calc.min(..pos.map(p => p.y)),
      calc.max(..pos.map(p => p.x)), calc.max(..pos.map(p => p.y))) }
    nodes.push((id: data.id, scope: data.scope, page: page, hidden: hidden, bounds: bounds,
      behavior: data.behavior, identity: (node: data.instance)))
  }
  nodes
}

#let _deixis-attached-endpoint(nodes, spec, page, role, validate: false) = {
  let fail(message) = { if validate { panic("deixis: " + message) }; none }
  let found = nodes.filter(n => n.id == spec.node and n.scope == spec.scope
    and (spec.page == none or n.page == spec.page))
  // Replayed slide objects reuse their names on different physical pages. A
  // declaration on one of those pages selects that instance; unique endpoints
  // elsewhere remain forward/cross-page selectable without positional ordering.
  if found.len() > 1 and spec.page == none {
    let local = found.filter(n => n.page == page)
    if local.len() == 1 { found = local }
  }
  if found.len() != 1 {
    return fail("Connection attached node " + repr(spec.node) + " must select one instance; check its ID/scope or supply page.")
  }
  let node = found.first()
  if node.hidden { return (hidden: true,) }
  _deixis-frame-node(role, node.page, node.bounds, node.identity)
}

#let _deixis-validate-attached-nodes() = { let _ = _deixis-attached-nodes() }
