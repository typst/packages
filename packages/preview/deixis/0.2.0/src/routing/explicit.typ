#import "endpoints.typ": _deixis-endpoint-index, _deixis-connection-endpoints
#import "connections.typ": _deixis-prepared-connection
#import "pins.typ": _deixis-resolve-edge-pins

#let _deixis-explicit-connection(data, index, validate: false) = {
  let endpoints = _deixis-connection-endpoints(index, data, validate: validate)
  if endpoints == none { return none }
  let options = data.options + data.at("routing-options", default: (:))
  if options.at("palette-stroke", default: false) and endpoints.accent != none {
    options.stroke = 0.5pt + endpoints.accent
  }
  let edge = _deixis-prepared-connection(endpoints.source, endpoints.target, options,
    adapter: "explicit", layer: data.options.layer, origin: "explicit",
    identity: (kind: "connection", location: data.location),
    routing-context: (accent: endpoints.accent, connection: (source: endpoints.source.identity, target: endpoints.target.identity)))
  if validate { let _ = _deixis-resolve-edge-pins(edge, index: index.anchors.pin-index, validate: true) }
  (edge: edge, highlight: none, render-context: data.render-context,
    identity: data.location, routing: data.at("routing", default: none))
}

#let _deixis-explicit-connections(layer: auto, validate: false) = {
  let declarations = query(<deixis-connection>).map(d => d.value + (location: d.location())).filter(d => (
    d.options.route not in (none, false, "none") and (layer == auto or d.options.layer == layer)
  ))
  if declarations.len() == 0 { return () }
  let index = _deixis-endpoint-index()
  let prepared = ()
  for data in declarations {
    let p = _deixis-explicit-connection(data, index, validate: validate)
    if p != none { prepared.push(p) }
  }
  prepared
}

// Validate outside painters so missing geometry cannot erase its own evidence.
#let _deixis-validate-connections() = {
  let _ = _deixis-explicit-connections(validate: true)
}
