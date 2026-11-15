#import "config.typ": _deixis-resolve-typed-param
#import "utils.typ" as utils
#import "../routing/spec.typ": _deixis-route-name, _deixis-route-spec, _deixis-route-sections
#import "pins.typ": _deixis-routing-pin-spec
#import "styles.typ": _deixis-edge-stroke
#import "order.typ": _deixis-resolve-z-index
#import "../routing/gaps.typ": _deixis-gap-mark-spec
#import "../routing/cuts.typ": _deixis-cut-specs
#import "../routing/crossings.typ": _deixis-crossing-spec
#import "../routing/connector-scene.typ": _deixis-connector-scene-spec
#import "../routing/continuation-marks.typ": _deixis-continuation-spec
#import "../routing/spill.typ": _deixis-spill-spec

// A route name is shorthand for a connector record with only that route.
#let _deixis-connector-record(value) = {
  if value in (auto, none) or type(value) == dictionary { return value }
  assert(type(value) == str,
    message: "deixis: connector must be auto, none, a route name, or a dictionary.")
  (route: value)
}

// Defaults merge field by field: global and scoped deixis-set levels from the
// outside in, then the call's own record. none at any level disables the edge;
// a later record enables it again with only its own fields.
#let _deixis-connector-config(sys, kind, local) = {
  let levels = if sys == none { () } else {
    (sys.at("connector", default: auto),) + sys.stack.map(level => level.at("connector", default: auto))
  }
  let records = levels.filter(v => v != auto).map(v => (
    _deixis-resolve-typed-param((stack: (), connector: v), auto, "connector", kind)))
  if local != auto { records.push(_deixis-resolve-typed-param((stack: ()), local, "connector", kind)) }
  let merged = auto
  for value in records {
    let record = _deixis-connector-record(value)
    if record == auto { continue }
    if record == none or merged in (auto, none) { merged = record; continue }
    // via and segments are alternative path descriptions: the later one wins.
    for (key, other) in (("via", "segments"), ("segments", "via")) {
      if key in record { let _ = merged.remove(other, default: none) }
    }
    merged += record
  }
  merged
}

// One normalization boundary for every connector. Callers supply only their
// adapter defaults: the fallback route, waypoint policy, styles and priority.
#let _deixis-connector-options(sys, kind, connector,
  route: "none", via: auto, stroke: none, radius: 0pt, z-index: auto, factory-stroke: false,
) = {
  let config = _deixis-connector-config(sys, kind, connector)
  let priority = _deixis-resolve-z-index(sys, z-index, kind, "connector")
  if config == none { return (route: "none", ports: auto, via: none, marks: "none", heads: none, gap-marks: none, cuts: (), crossings: none, continuation: auto, spill: auto, scene: none, stroke: stroke, radius: radius, render: none, layer: "foreground", z-index: priority) }
  if config == auto { config = (:) }
  assert(type(config) == dictionary, message: "deixis: connector must be auto, none, or a dictionary.")
  let keys = ("route", "ports", "via", "heads", "gap-marks", "cuts", "crossings", "continuation", "spill", "scene", "stroke", "radius", "render", "segments", "layer", "z-index")
  assert(config.keys().all(k => k in keys), message: "deixis: Unknown connector option; expected " + repr(keys))
  let local-priority = config.at("z-index", default: auto)
  assert(local-priority == auto or type(local-priority) == int,
    message: "deixis: connector.z-index must be an integer or auto.")
  if local-priority != auto { priority = local-priority }
  let waypoints = config.at("via", default: via)
  if "segments" in config {
    assert("via" not in config, message: "deixis: Use connector.via or connector.segments, not both.")
    waypoints = _deixis-route-sections(config.segments,
      resolve-route: value => _deixis-route-spec(value))
  }
  // Validate pin syntax independently of layout, including disabled routes.
  let check-pin(wp) = if type(wp) == dictionary and "kind" in wp {
    _deixis-route-spec(wp)
  } else if type(wp) == dictionary and "pin" in wp {
    _deixis-routing-pin-spec(wp, waypoint: true)
  } else { wp }
  if type(waypoints) == array { waypoints = waypoints.map(check-pin) }
  else if type(waypoints) == dictionary { waypoints = check-pin(waypoints) }
  let route = _deixis-route-spec(config.at("route", default: route))
  let crossings = _deixis-crossing-spec(config.at("crossings", default: none))
  let scene = _deixis-connector-scene-spec(config.at("scene", default: none))
  assert(scene == none or type(route) != function,
    message: "deixis: connector.scene requires native routing; legacy callbacks do not expose numeric geometry.")
  let continuation = _deixis-continuation-spec(config.at("continuation", default: auto))
  assert(type(continuation) != dictionary or type(route) != function,
    message: "deixis: connector.continuation presets need native routing; use a continuation renderer with a legacy route callback.")
  assert(crossings == none or type(route) != function,
    message: "deixis: connector.crossings requires native routing; legacy route callbacks do not expose numeric geometry.")
  let render = config.at("render", default: none)
  assert(render == none or type(render) == function, message: "deixis: connector.render must be a function.")
  assert(render == none or type(route) != function, message: "deixis: Use either a route callback or connector.render.")
  let layer = config.at("layer", default: auto)
  if layer == auto { layer = "foreground" }
  assert(layer in ("foreground", "background"),
    message: "deixis: connector.layer must be foreground, background, or auto. Body layer and connector painting are independent.")
  let line-stroke = config.at("stroke", default: stroke)
  let line-radius = config.at("radius", default: radius)
  if _deixis-route-name(route) not in ("none", none) {
    assert(not _deixis-edge-stroke(line-stroke),
      message: "deixis: Connector stroke must be a single stroke, not edge strokes. Set stroke: (nodes: ..., connector: ...) or connector.stroke.")
    assert(type(line-radius) != dictionary,
      message: "deixis: Connector radius must be a single length, not corner radii. Set radius: (nodes: ..., connector: ...) or connector.radius.")
  }
  (
    route: route,
    ports: utils._deixis-normalize-ports(config.at("ports", default: auto)),
    via: waypoints,
    marks: "none",
    heads: config.at("heads", default: auto),
    gap-marks: _deixis-gap-mark-spec(config.at("gap-marks", default: none)),
    cuts: _deixis-cut-specs(config.at("cuts", default: none)),
    crossings: crossings,
    continuation: continuation,
    spill: _deixis-spill-spec(config.at("spill", default: auto)),
    scene: scene,
    stroke: line-stroke, radius: line-radius,
    render: render, layer: layer, z-index: priority,
  ) + if factory-stroke and "stroke" not in config { (palette-stroke: true) } else { (:) }
}
