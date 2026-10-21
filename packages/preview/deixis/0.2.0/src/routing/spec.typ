// Route policy is value data, independent of styles, scopes, layout and paint.
#import "../core/pins.typ": _deixis-routing-pin-spec
#let _deixis-route-aliases = (orthogonal: "right-angle", polyline: "straight-line",
  catmull-rom: "ccr", catmull-rom-centripetal: "ccr", catmull-rom-uniform: "ucr")
#let deixis-link-types = ("none", "straight-line", "right-angle", "chamfer", "curve", "ccr", "ucr", "b-spline", "hobby") + _deixis-route-aliases.keys()
#let _deixis-route-record(value) = type(value) == dictionary and "kind" in value
  and value.kind in deixis-link-types
#let _deixis-route-name(value) = {
  let kind = if type(value) == dictionary { value.at("kind", default: none) } else { value }
  if kind == "catmull-rom" and type(value) == dictionary and value.at("parameterization", default: "centripetal") == "uniform" {
    return "ucr"
  }
  if type(kind) == str { _deixis-route-aliases.at(kind, default: kind) } else { kind }
}

// Deliberately exclude legacy scalar/anchor-string waypoint spellings and route
// switches. A control is a coordinate pair, framed point, or explicit pin target.
#let _deixis-control-spec(value) = {
  let coordinates(v) = type(v) == array and v.len() == 2 and v.all(x => type(x) in (length, ratio, relative))
  if type(value) == array {
    assert(coordinates(value), message: "deixis: connector.route control point needs two coordinates.")
    return value
  }
  assert(type(value) == dictionary, message: "deixis: connector.route control point must be a coordinate pair, framed point, or pin.")
  if "pin" in value { return _deixis-routing-pin-spec(value, waypoint: true) }
  assert(value.keys().all(k => k in ("relative-to", "offset", "anchor")),
    message: "deixis: connector.route control point has an unknown field.")
  let reference = value.at("relative-to", default: "previous")
  assert(reference in ("mark", "body", "page", "previous"),
    message: "deixis: connector.route control point has an unknown reference frame.")
  assert(coordinates(value.at("offset", default: (0pt, 0pt))),
    message: "deixis: connector.route control offset needs two coordinates.")
  if "anchor" in value {
    assert(type(value.anchor) == alignment and reference != "previous",
      message: "deixis: connector.route control anchor needs an alignment and mark/body/page reference.")
  }
  value
}

// Canonical defaults collapse to their historical strings. Nondefault settings
// stay in one idempotent literal record; route sections do not inherit settings.
#let _deixis-route-spec(value) = {
  if value in (none, auto) or type(value) == function { return value }
  let record = type(value) == dictionary
  assert(record or type(value) == str,
    message: "deixis: connector.route must be a route name, a kind/settings dictionary, or a legacy callback.")
  if record {
    assert("kind" in value and type(value.kind) == str,
      message: "deixis: connector.route needs a string kind in every route record.")
  }
  let declared = if record { value.kind } else { value }
  assert(declared in deixis-link-types,
    message: "deixis: connector.route has an unknown kind: " + repr(declared))
  let kind = _deixis-route-name(value)
  if not record { return kind }
  let keys = ("kind",)
  if kind == "b-spline" { keys += ("controls",) }
  if kind in ("curve", "ccr", "ucr", "hobby") { keys += ("tension",) }
  if kind == "hobby" { keys += ("curl",) }
  if declared == "catmull-rom" { keys += ("parameterization",) }
  assert(value.keys().all(k => k in keys),
    message: "deixis: connector.route settings do not apply to " + declared + "; expected " + repr(keys))
  if kind == "b-spline" {
    let controls = value.at("controls", default: ())
    assert(type(controls) == array, message: "deixis: connector.route controls must be an array of control points.")
    let controls = controls.map(_deixis-control-spec)
    return if controls.len() == 0 { kind } else { (kind: kind, controls: controls) }
  }
  if "parameterization" in value {
    assert(value.parameterization in ("centripetal", "uniform"),
      message: "deixis: connector.route parameterization must be centripetal or uniform.")
  }
  let tension = value.at("tension", default: 1)
  assert(type(tension) in (int, float) and tension == tension and tension > 0 and tension < calc.inf,
    message: "deixis: connector.route tension must be a positive finite number; 1 preserves the default handles.")
  assert(1 / tension < calc.inf,
    message: "deixis: connector.route tension is too small to produce finite handles.")
  if kind == "hobby" {
    assert(tension >= 0.75, message: "deixis: connector.route Hobby tension must be at least 0.75.")
    let curl = value.at("curl", default: 1)
    if type(curl) == dictionary {
      assert(curl.keys().all(k => k in ("mark", "body")),
        message: "deixis: connector.route Hobby curl accepts mark/body boundary values.")
      curl = (mark: curl.at("mark", default: 1), body: curl.at("body", default: 1))
    } else { curl = (mark: curl, body: curl) }
    assert(curl.values().all(x => type(x) in (int, float) and x == x and x >= 0 and x < calc.inf),
      message: "deixis: connector.route Hobby curl must be finite nonnegative numbers.")
    let spec = (kind: kind)
    if tension != 1 { spec.tension = tension }
    if curl != (mark: 1, body: 1) { spec.curl = curl }
    return if spec.len() == 1 { kind } else { spec }
  }
  if tension == 1 { kind } else { (kind: kind, tension: tension) }
}

#let _deixis-route-control(value) = type(value) == str or (type(value) == dictionary and "kind" in value)

// Shared section ownership for document connectors and the numeric API. The
// document boundary supplies its existing default resolver; geometry uses only
// literal native records. Via coordinates are resolved by the caller.
#let _deixis-route-sections(value, resolve-route: _deixis-route-spec) = {
  assert(type(value) == array, message: "deixis: connector.segments must be an array.")
  let waypoints = ()
  for section in value {
    assert(type(section) == dictionary and section.keys().all(k => k in ("route", "via")),
      message: "deixis: A connector segment accepts route and via.")
    if "route" in section {
      let policy = resolve-route(section.route)
      assert(type(policy) != function, message: "deixis: Segment routes must be native route names or settings records.")
      waypoints.push(if policy == none { "none" } else { policy })
    }
    let via = section.at("via", default: ())
    assert(type(via) == array, message: "deixis: A connector segment via must be an array.")
    waypoints += via
  }
  waypoints
}
