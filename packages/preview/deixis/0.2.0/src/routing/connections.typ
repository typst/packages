#import "../layout/geometry.typ": _deixis-port-bounds
#import "fragments.typ": _deixis-logical-endpoints

// Private prepared records, not public endpoint selectors. They contain numeric
// geometry and routing options only: no live body, renderer, or reservation.
#let _deixis-connection-node(role, page, ports, bounds: auto, identity: none, virtual: false) = (
  role: role, identity: identity, page: page, frame: "page", virtual: virtual,
  bounds: if bounds == auto { _deixis-port-bounds(ports) } else { bounds },
  ports: ports,
)

// Bridge the existing body metadata into a connection's own option namespace.
// Values have already passed the public connector/legacy normalization boundary.
#let _deixis-connection-options(data, route: auto, stroke: auto, radius: auto, marks: auto) = ((
  route: if route == auto { data.at("link", default: "none") } else { route },
  stroke: if stroke == auto { data.at("link-stroke", default: none) } else { stroke },
  radius: if radius == auto { data.at("link-radius", default: 0pt) } else { radius },
  marks: if marks == auto { data.at("link-marks", default: "none") } else { marks },
  ports: data.at("link-ports", default: auto),
  via: data.at("link-waypoints", default: auto),
  heads: data.at("link-heads", default: auto),
  render: data.at("link-render", default: none),
  gap-marks: data.at("link-gap-marks", default: none),
  cuts: data.at("link-cuts", default: ()),
  crossings: data.at("link-crossings", default: none),
  continuation: data.at("link-continuation", default: auto),
  spill: data.at("link-spill", default: auto),
  scene: data.at("link-scene", default: none),
  z-index: data.at("link-z-index", default: 0),
) + data.at("routing-options", default: (:)))

#let _deixis-prepared-connection(source, target, options, adapter: "inset", layer: "foreground", origin: "body-shorthand",
  split-default: "source", turn-x: auto, synthetic-waypoints: auto, routing-context: (:), identity: none,
) = (
  source: source, target: target, options: options,
  logical: _deixis-logical-endpoints(source, target),
  origin: origin, adapter: adapter, layer: layer, identity: identity,
  policy: (split-default: split-default, turn-x: turn-x, synthetic-waypoints: synthetic-waypoints),
  routing-context: routing-context,
)
