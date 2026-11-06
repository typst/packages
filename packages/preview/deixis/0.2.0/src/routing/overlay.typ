#import "../core/state.typ": deixis-system
#import "../core/config.typ": _deixis-resolve-typed-param
#import "spec.typ": _deixis-route-spec
#import "../core/query.typ": _deixis-anchor-index, _deixis-pin-index
#import "connections.typ": _deixis-connection-options
#import "notes.typ": _deixis-inset-connection, _deixis-paint-note-connections
#import "explicit.typ": _deixis-explicit-connections
#import "pins.typ": _deixis-has-routing-pins, _deixis-resolve-edge-pins
#import "../render/commands.typ": _deixis-paint-command
#import "../core/visibility.typ": _deixis-is-hidden, _deixis-hidden-identities
#import "fragments.typ": _deixis-margin-endpoint-index
#import "document-groups.typ": _deixis-routing-paint-commands

// Boolean source evidence has no positional dependency. In particular, native
// immediate margin preparation must not make hidden sources' edges visible.
#let _deixis-covered-originals() = {
  _deixis-hidden-identities(selector(<deixis-inline-mark>).or(<deixis-phantom-mark>).or(<deixis-region-mark>))
}

// Both adapters use page overlays for connections, independently of where/how
// the body was painted. Cross-page resolution does not require a foreground.
#let _deixis-connection-paint-commands(layer) = {
  let current-page = here().page()
  let margins = query(<deixis-margin-connection>)
    .filter(m => not _deixis-is-hidden(m.value) and not _deixis-is-hidden(m.value.prepared))
    .map(m => m.value)
  let logical = if margins.len() == 0 { (:) } else { _deixis-margin-endpoint-index(margins.map(m => m.prepared)) }
  let connections = margins.filter(m => m.page == current-page and m.prepared.edge.layer == layer)
    .map(m => { let p = m.prepared; p + (edge: p.edge + (logical: logical.at(str(p.edge.source.identity), default: p.edge.logical))) })
  let covered = if connections.len() > 0 { _deixis-covered-originals() } else { (:) }
  connections = connections.filter(c => str(c.edge.source.identity) not in covered)
  let notes = query(<deixis-inset-note>).filter(n => (
    n.value.at("mark-lbl", default: none) != none
      and n.value.at("link-layer", default: "foreground") == layer
      and not _deixis-is-hidden(n.value)
  ))
  let sys = deixis-system.get()
  let anchors = if notes.len() == 0 { none } else { _deixis-anchor-index() }
  for n in notes {
    let data = n.value
    let route = _deixis-route-spec(data.at("link", default: "none"))
    if route in (none, "none", false) { continue }
    let stroke = data.at("link-stroke", default: _deixis-resolve-typed-param(
      sys, auto, "stroke", "inset-note", component: "connector"))
    let radius = data.at("link-radius", default: _deixis-resolve-typed-param(
      sys, auto, "radius", "inset-note", component: "connector"))
    let marks = data.at("link-marks", default: "none")
    let prepared = _deixis-inset-connection(data, anchors,
      _deixis-connection-options(data, route: route, stroke: stroke, radius: radius, marks: marks))
    if prepared != none { connections.push(prepared) }
  }
  connections += _deixis-explicit-connections(layer: layer)
  let covered-bodies = if connections.any(c => c.edge.origin == "body-shorthand") {
    _deixis-hidden-identities(<deixis-body-visibility>)
  } else { (:) }
  let pin-index = if connections.any(c => _deixis-has-routing-pins(c.edge.options)) { _deixis-pin-index() } else { auto }
  let selected = connections.filter(c => (
    current-page in (c.edge.source.page, c.edge.target.page)
      and c.edge.options.route not in (none, false, "none")
      and not _deixis-is-hidden(c)
      and (c.edge.origin != "body-shorthand" or str(c.edge.target.identity) not in covered-bodies)
  ))
  if selected.any(c => c.edge.options.at("crossings", default: none) != none) {
    selected = selected.enumerate().map(((ordinal, prepared)) => {
      let edge = prepared.edge
      if edge.options.at("crossings", default: none) == none { return prepared }
      prepared + (edge: edge + (routing-context: edge.routing-context +
        (crossing-order: (edge.options.at("z-index", default: 0), ordinal))))
    })
  }
  let ordinary = selected.filter(p => p.at("routing", default: none) == none)
  let collected = selected.filter(p => p.at("routing", default: none) != none)
  ordinary.map(prepared => _deixis-paint-command("connection", prepared.edge.source.identity,
    () => _deixis-paint-note-connections((prepared,), current-page, pin-index: pin-index).join(),
    priority: prepared.edge.options.at("z-index", default: 0))) + _deixis-routing-paint-commands(layer, collected, start-order: selected.len())
}

// Keep missing/ambiguous pin errors outside painting contexts. The metadata
// that owns the edge survives even when its geometry is not yet resolvable.
#let _deixis-validate-note-connection-pins() = {
  let margins = query(<deixis-margin-connection>).filter(item => not _deixis-is-hidden(item.value))
    .map(item => item.value.prepared)
    .filter(item => not _deixis-is-hidden(item) and _deixis-has-routing-pins(item.edge.options))
    .map(item => item.edge)
  let notes = query(<deixis-inset-note>).filter(n => (
    n.value.at("mark-lbl", default: none) != none and
      n.value.at("link", default: "none") not in (none, false, "none") and
      not _deixis-is-hidden(n.value) and
      _deixis-has-routing-pins(_deixis-connection-options(n.value))
  ))
  if margins.len() > 0 or notes.len() > 0 {
    let anchors = _deixis-anchor-index()
    let covered = if margins.len() > 0 { _deixis-covered-originals() } else { (:) }
    let covered-bodies = _deixis-hidden-identities(<deixis-body-visibility>)
    for edge in margins {
      if str(edge.source.identity) not in covered and str(edge.target.identity) not in covered-bodies {
        let _ = _deixis-resolve-edge-pins(edge, index: anchors.pin-index, validate: true)
      }
    }
    for note in notes {
      if str(note.value.internal-id) in covered-bodies { continue }
      let prepared = _deixis-inset-connection(note.value, anchors, _deixis-connection-options(note.value))
      if prepared != none { let _ = _deixis-resolve-edge-pins(prepared.edge, index: anchors.pin-index, validate: true) }
    }
  }
}
