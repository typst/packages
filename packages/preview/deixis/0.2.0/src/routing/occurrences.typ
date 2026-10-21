#import "../core/state.typ": deixis-system, _deixis-registry
#import "../core/occurrences.typ": _deixis-occurrence-target
#import "../layout/geometry.typ": _deixis-box-bounds, _deixis-box-port
#import "connections.typ": _deixis-connection-node

// Painted inline frames and deliberate phantom points are routing nodes. A
// repeat without a marker/passage has a source/backlink identity but no ports.
// Native hiding is tracked separately. This is private infrastructure
// for explicit connections, not a public query interface.
#let _deixis-occurrence-nodes() = {
  let registry = _deixis-registry(deixis-system.final())
  let corners = (:)
  for probe in query(<deixis-occurrence-corner>) {
    let data = probe.value
    let uid = _deixis-occurrence-target(registry, data.target)
    if uid == none { continue }
    if uid not in corners { corners.insert(uid, (:)) }
    if data.name not in corners.at(uid) { corners.at(uid).insert(data.name, ()) }
    corners.at(uid).at(data.name).push(probe)
  }
  let result = (:)
  // Unlike a hidden inline marker, an explicit phantom is a semantic point
  // endpoint. Its native source metadata defines that point without any box.
  for site in query(<deixis-mark-occurrence>) {
    let data = site.value
    if data.at("kind", default: none) != "phantom" or data.name == none { continue }
    let uid = _deixis-occurrence-target(registry, data.targets.first())
    if uid == none { continue }
    if uid not in result { result.insert(uid, (:)) }
    let pos = site.location().position()
    let bounds = _deixis-box-bounds(pos.x, pos.y, pos.x, pos.y)
    let ports = ("top", "bottom", "left", "right").map(side => _deixis-box-port(bounds, side))
    result.at(uid).insert(data.name, _deixis-connection-node("mark", site.location().page(), ports,
      bounds: bounds, identity: (annotation: uid, occurrence: data.name)))
  }
  for (uid, names) in corners {
    if uid not in result { result.insert(uid, (:)) }
    for (name, probes) in names {
      if probes.len() != 4 { continue }
      let page = probes.first().location().page()
      if probes.any(p => p.location().page() != page) { continue }
      let positions = probes.map(p => p.location().position())
      let bounds = _deixis-box-bounds(calc.min(..positions.map(p => p.x)), calc.min(..positions.map(p => p.y)),
        calc.max(..positions.map(p => p.x)), calc.max(..positions.map(p => p.y)))
      let ports = ("top", "bottom", "left", "right").map(side => _deixis-box-port(bounds, side))
      result.at(uid).insert(name, _deixis-connection-node("mark", page, ports, bounds: bounds,
        identity: (annotation: uid, occurrence: name)) + (hidden: probes.first().value.at("hidden", default: false),))
    }
  }
  result
}
