#import "../core/query.typ": _deixis-pin-index, _deixis-select-pins
#import "../core/pins.typ": _deixis-routing-pin-spec
#import "../core/utils.typ": resolve-signed-len
#import "../layout/geometry.typ": _deixis-box-bounds, _deixis-box-port
#import "connections.typ": _deixis-connection-node

#let _deixis-routing-pin(index, target, page: none, validate: false) = {
  let matches = _deixis-select-pins(index, target, default: "unique", page: page,
    single: true, required: true, validate: validate)
  if matches.len() == 0 { none } else { matches.first() }
}

#let _deixis-pin-node(index, target, role, validate: false) = {
  let pin = _deixis-routing-pin(index, target, validate: validate)
  if pin == none { return none }
  let pos = pin.location().position()
  let port = (x: pos.x, y: pos.y, dir: "none", id: "pin", normal: (0, 0))
  let node = _deixis-connection-node(role, pos.page, (port,),
    bounds: _deixis-box-bounds(pos.x, pos.y, pos.x, pos.y),
    identity: (pin: pin.value.name, scope: pin.value.at("scope", default: none), location: pin.location()))
  if pin.value.at("hidden", default: false) { node + (hidden: true,) } else { node }
}

#let _deixis-has-routing-pins(options) = {
  let control-pins(route) = (type(route) == dictionary and
    route.at("controls", default: ()).any(p => type(p) == dictionary and "pin" in p))
  if control-pins(options.at("route", default: none)) { return true }
  let ports = options.at("ports", default: auto)
  if type(ports) == dictionary and ports.values().any(p => type(p) == dictionary and "pin" in p) { return true }
  let via = options.at("via", default: none)
  let via = if type(via) == array { via } else { (via,) }
  via.any(p => type(p) == dictionary and ("pin" in p or control-pins(p)))
}

// Resolve native locations once at the document boundary. The path algorithm
// receives only numeric points/ports, never queries or live pin content.
#let _deixis-resolve-edge-pins(edge, index: auto, validate: false) = {
  if not _deixis-has-routing-pins(edge.options) { return edge }
  let index = if index == auto { _deixis-pin-index() } else { index }
  let options = edge.options
  let resolve-controls(route, page, virtual) = {
    if type(route) != dictionary or "controls" not in route { return route }
    let controls = ()
    for point in route.controls {
      if type(point) == dictionary and "pin" in point {
        let spec = _deixis-routing-pin-spec(point, waypoint: true)
        let pin = _deixis-routing-pin(index, spec.pin, page: if virtual { none } else { page }, validate: validate)
        if pin == none { return none }
        let pos = pin.location().position()
        controls.push((relative-to: "page", offset: (pos.x + resolve-signed-len(spec.offset.first()),
          pos.y + resolve-signed-len(spec.offset.last()))))
      } else { controls.push(point) }
    }
    route + (controls: controls)
  }
  let route = resolve-controls(options.route, edge.source.page, edge.source.virtual)
  if route == none { return none }
  options.route = route
  if type(options.ports) == dictionary {
    let ports = options.ports
    for (role, spec) in ports {
      if type(spec) != dictionary or "pin" not in spec { continue }
      spec = _deixis-routing-pin-spec(spec)
      let node = if role == "mark" { edge.source } else { edge.target }
      if node.virtual {
        // Margin spillover relays are continuation boundaries, not the real
        // endpoint. A custom socket cannot move a relay onto the body's page.
        ports.insert(role, auto)
        continue
      }
      let pin = _deixis-routing-pin(index, spec.pin, page: node.page, validate: validate)
      if pin == none { return none }
      let pos = pin.location().position()
      let port = if spec.side == auto {
        (x: pos.x, y: pos.y, dir: "none", id: "pin", normal: (0, 0))
      } else {
        _deixis-box-port(_deixis-box-bounds(pos.x, pos.y, pos.x, pos.y), spec.side,
          gap: resolve-signed-len(spec.gap))
      }
      ports.insert(role, (resolved-pin: port))
    }
    options.insert("ports", ports)
  }
  let via = options.via
  let via = if type(via) == array { via } else if via in (none, auto) { () } else { (via,) }
  let resolved = ()
  let page = edge.source.page
  let virtual = edge.source.virtual
  for wp in via {
    if wp == "split" or (type(wp) == array and wp.len() > 0 and wp.first() == "split") {
      page = edge.target.page
      virtual = edge.target.virtual
    }
    if type(wp) == dictionary and "pin" in wp {
      wp = _deixis-routing-pin-spec(wp, waypoint: true)
      let pin = _deixis-routing-pin(index, wp.pin, page: if virtual { none } else { page }, validate: validate)
      if pin == none { return none }
      let pos = pin.location().position()
      resolved.push((resolved-pin: (pos.x + resolve-signed-len(wp.offset.first()),
        pos.y + resolve-signed-len(wp.offset.last()))))
    } else {
      let value = resolve-controls(wp, page, virtual)
      if value == none { return none }
      resolved.push(value)
    }
  }
  // Retain auto so adapter-generated lane/continuation waypoints still apply.
  if options.via not in (none, auto) { options.insert("via", resolved) }
  // Margin lane offsets were prepared relative to the original attachment.
  // A custom socket uses the generic route unless the user supplies waypoints.
  if (edge.adapter == "margin" and options.via == auto and type(edge.options.ports) == dictionary and
    edge.options.ports.values().any(p => type(p) == dictionary and "pin" in p)) {
    options.insert("via", none)
  }
  edge + (options: options)
}
