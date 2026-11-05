#import "routing/spec.typ": _deixis-route-spec, _deixis-route-control, _deixis-route-sections, _deixis-route-name
#import "routing/path.typ": _deixis-waypoint-route, _deixis-prepare-connector-request
#import "routing/geometry.typ": _deixis-sub

#import "routing/numeric.typ": _deixis-numeric-length, _deixis-numeric-point, _deixis-numeric-endpoint
#import "routing/scene.typ": _deixis-scene-endpoint, _deixis-scene-port, _deixis-scene-page, _deixis-scene-pair
#import "routing/scene-path.typ": _deixis-scene-orthogonal
#import "routing/scene-interactions.typ": _deixis-scene-complete

#let _deixis-numeric-policy(value, origin: (0pt, 0pt)) = {
  assert(value == none or type(value) in (str, dictionary),
    message: "deixis: Numeric routing requires a native route name or settings record; auto and routing callbacks need a document adapter.")
  let policy = _deixis-route-spec(value)
  if policy == none { return "none" }
  if type(policy) == dictionary and "controls" in policy {
    policy.controls = policy.controls.map(p => _deixis-sub(_deixis-numeric-point(p), origin))
  }
  policy
}

// Constructs native line/cubic geometry without setup, layout context, queries,
// measurement, head callbacks or painting. All input points/controls use one
// caller-defined x-right/y-down plane and finite absolute lengths.
//
// from/to accept (x, y) or (point: (x, y), normal: right). Normals point outward
// at both ends; a target curve arrives opposite its normal. A nonzero numeric
// vector also works. Orthogonal routes require cardinal endpoint normals.
// via visits exact points; segments groups route/via sections just as connectors
// do. B-spline controls influence the curve without becoming exact visits.
//
// Returns source-local geometry: origin is from, start is (0pt, 0pt), end and
// segments are relative to origin. Bounds conservatively include control handles;
// length is approximate drawable arc length. Styles, pages and bodies are absent.
#let _deixis-basic-route(from: none, to: none, route: "straight-line", via: none, segments: none, radius: 0pt) = {
  assert(_deixis-numeric-length(radius) and radius >= 0pt,
    message: "deixis: Numeric routing radius must be a finite nonnegative absolute length.")
  assert(segments == none or via == none,
    message: "deixis: Use numeric routing via or segments, not both.")
  let source = _deixis-numeric-endpoint(from)
  let target = _deixis-numeric-endpoint(to)
  let points = if segments == none { if via == none { () } else { via } }
    else { _deixis-route-sections(segments, resolve-route: _deixis-numeric-policy) }
  assert(type(points) == array, message: "deixis: Numeric routing via must be an array of points and route switches.")
  points = points.map(value => {
    if _deixis-route-control(value) { return _deixis-numeric-policy(value, origin: source.point) }
    _deixis-sub(_deixis-numeric-point(value), source.point)
  })
  let fixed = points.filter(value => type(value) == array)
  let geometry = _deixis-waypoint-route(..source.point, ..target.point,
    link-type: _deixis-numeric-policy(route, origin: source.point), waypoints: points, fixed-waypoints: fixed,
    link-radius: radius, source-dir: source.axis, target-dir: target.axis,
    source-normal: source.normal, target-normal: target.normal)
  let coordinates = (geometry.end,) + geometry.segments.map(s => (s.start, s.end)
    + if s.kind == "cubic" { (s.c1, s.c2) } else { () }).flatten()
  assert(_deixis-numeric-length(geometry.length) and coordinates.flatten().all(_deixis-numeric-length),
    message: "deixis: Numeric routing geometry is not representable; reduce coordinate magnitudes or route settings.")
  geometry + (kind: "deixis-route", frame: "source-local-x-right-y-down")
}

#let _deixis-route-in-scene(scene, from, to, route, via, segments, radius, page) = {
  let pair = _deixis-scene-pair(scene, from, to, page)
  if pair.kind == "deixis-route-failure" { return pair }
  let (start, end, prepared) = (pair.start, pair.end, pair.prepared)
  page = pair.page
  let stats = none
  let geometry = none
  let policy = _deixis-numeric-policy(route)
  let sharp = (_deixis-route-name(policy) == "right-angle" and radius == 0pt and segments == none
    and (via == none or (type(via) == array and via.all(v => type(v) == array))))
  if prepared.obstacles.len() > 0 or sharp {
    assert(_deixis-route-name(_deixis-numeric-policy(route)) == "right-angle" and radius == 0pt and segments == none,
      message: "deixis: Numeric scene avoidance requires route: orthogonal, radius: 0pt, and point-only via; smoothing and mixed sections are not clearance-safe.")
    let via = if via == none { () } else { via }
    assert(type(via) == array, message: "deixis: Numeric scene avoidance via must be an array of absolute points.")
    let via = via.map(_deixis-numeric-point).map(p => p.map(v => v.pt()))
    geometry = _deixis-scene-orthogonal(scene, prepared, start, end, via, page)
    if geometry.status != "ok" { return geometry }
    stats = geometry.search
  } else {
    geometry = _deixis-basic-route(from: (point: start.point, normal: start.normal), to: (point: end.point, normal: end.normal),
      route: route, via: via, segments: segments, radius: radius)
  }
  _deixis-scene-complete(geometry + (status: "ok", page: page, search: stats), prepared, page)
}

/// Constructs native line/cubic geometry without setup, layout context, queries,
/// measurement, head callbacks or painting. All input points/controls use one
/// caller-defined x-right/y-down plane and finite absolute lengths.
///
/// from/to accept (x, y) or (point: (x, y), normal: right). Normals point outward
/// at both ends; a target curve arrives opposite its normal. A nonzero numeric
/// vector also works. Orthogonal routes require cardinal endpoint normals.
/// via visits exact points; segments groups route/via sections just as connectors
/// do. B-spline controls influence the curve without becoming exact visits.
///
/// Returns source-local geometry: origin is from, start is (0pt, 0pt), end and
/// segments are relative to origin. Bounds conservatively include control handles;
/// length is approximate drawable arc length. Without a scene, styles, pages
/// and bodies are absent. Scene routes additionally carry status/page/search data.
///
/// Builds resolved numeric geometry, optionally against a reusable page-local
/// scene. With avoid nodes use sharp orthogonal routing. Scene routes return
/// status: ok or an explicit non-drawable failure; see docs/guides/routing-scenes.
#let deixis-route(
  /// Source point (x, y), or point/normal record; with scene, a node/socket selector also works.
  /// -> array | dictionary | str | label
  from: none,
  /// Target in the same x-right/y-down plane. Endpoint normals point outward at both ends.
  /// -> array | dictionary | str | label
  to: none,
  /// Native route name or complete algorithm record. Scene avoidance requires sharp orthogonal routing.
  /// -> str | dictionary | none
  route: "straight-line",
  /// Exact absolute visits, optionally interleaved with native route switches; exclusive with segments.
  /// -> none | array
  via: none,
  /// Typed route/via sections; exclusive with via. B-spline controls influence rather than visit points.
  /// -> none | array
  segments: none,
  /// Finite nonnegative absolute corner radius; searched scene routes require zero.
  /// -> length
  radius: 0pt,
  /// Prepared routing scene. Numeric bounds need no setup; document-derived scene selectors need setup/context when resolved.
  /// -> none | dictionary
  scene: none,
  /// Positive physical page plane within a scene; omit for automatic unambiguous selection.
  /// -> none | int
  page: none,
) = {
  assert(_deixis-numeric-length(radius) and radius >= 0pt,
    message: "deixis: Numeric routing radius must be a finite nonnegative absolute length.")
  assert(segments == none or via == none, message: "deixis: Use numeric routing via or segments, not both.")
  if scene != none { return _deixis-route-in-scene(scene, from, to, route, via, segments, radius, page) }
  assert(page == none, message: "deixis: Numeric routing page requires a scene.")
  _deixis-basic-route(from: from, to: to, route: route, via: via, segments: segments, radius: radius)
}

/// Prepares a deixis-route result for native or custom painting. Routing is not
/// repeated. Head callbacks run once here; their returned content runs when painted.
/// Styles/font lengths/custom heads can require a Typst context. No page/layer,
/// registration, automatic crossings or state defaults are consulted.
/// Paint with deixis-render-connector(request), placed at route.origin yourself.
#let deixis-prepare-connector(
  /// Successful source-local geometry returned by deixis-route or an accepted route-group entry.
  /// -> dictionary
  route,
  /// One shaft stroke, or none. A disabled shaft may still have independently styled heads.
  /// -> stroke | color | length | dictionary | none
  stroke: black + 1pt,
  /// Native head name, reusable head record/callback, or (mark: ..., body: ...); a single head selects the target.
  /// -> none | str | dictionary | function
  heads: none,
  /// Optional original-route arc-length cut records. Cutting preserves the underlying curve.
  /// -> none | array | dictionary
  cuts: none,
  /// Optional slash/bar marks or settings record for surviving internal gaps; separate from page continuations.
  /// -> none | str | dictionary
  gap-marks: none,
) = {
  assert(type(route) != dictionary or route.at("kind", default: none) != "deixis-route-failure",
    message: "deixis: Numeric routing failed; inspect status/detail and adjust the scene before preparing a connector.")
  assert(type(route) == dictionary and route.at("kind", default: none) == "deixis-route"
    and route.at("frame", default: none) == "source-local-x-right-y-down"
    and ("origin", "start", "end", "segments", "length", "has-start", "has-end", "start-tangent", "end-tangent").all(k => k in route),
    message: "deixis: Prepare a geometry result from deixis-route before painting a numeric connector.")
  _deixis-prepare-connector-request(route, link-stroke: stroke, link-heads: heads,
    link-cuts: cuts, link-gap-marks: gap-marks, route-context: none)
}
