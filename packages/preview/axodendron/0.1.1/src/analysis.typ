// Morphometrics, topology queries, principal frames, and Sholl analysis.

#import "protocol.typ": _plugin, _request, _required, _unwrap, _require-payload, _view

/// Compute summary metrics, section decomposition, tortuosity, root path
/// distances, and Strahler order in one WASM call.
///
/// - cell (dictionary): The morphology to analyze.
/// - domain (str): Node domain included in cable metrics, typically `"neurites"`.
/// - section-boundaries (str): Rule used to split morphology sections.
/// -> dictionary
#let analyze(
  cell,
  domain: "neurites",
  section-boundaries: "topology-and-type",
) = _unwrap(_plugin.analyze_with(
  _require-payload(cell),
  _request((
    domain: domain,
    section_boundaries: section-boundaries,
  )),
))

#let _selection(domain: "neurites", kinds: (), roots: (), nodes: ()) = (
  domain: domain,
  kinds: kinds,
  root_ids: roots,
  node_ids: nodes,
)

#let _vec3(name, value) = {
  if type(value) == array and value.len() == 3 {
    (x: value.at(0), y: value.at(1), z: value.at(2))
  } else if type(value) == dictionary and "x" in value and "y" in value and "z" in value {
    (x: value.at("x"), y: value.at("y"), z: value.at("z"))
  } else {
    panic("Axodendron: `" + name + "` must be a three-number array or an x/y/z dictionary")
  }
}

#let _vec3-neg(value) = (
  x: -value.at("x"),
  y: -value.at("y"),
  z: -value.at("z"),
)

/// Construct a scientifically versioned metric specification.
///
/// Parameters irrelevant to the selected metric are rejected. Inspect
/// `available-metrics` for accepted parameters, defaults, choices, and bounds.
///
/// - id (str): Stable metric identifier returned by `available-metrics`.
/// - p (none, int, float): Diameter power exponent for Rall/power ratios.
/// - diameter-sampling (none, str): Child diameter rule, `"first-point"` or `"section-mean"`.
/// - taper-quantity (none, str): `"diameter"` or `"radius"`.
/// - taper-method (none, str): `"linear-fit"` or `"endpoint"`.
/// - multifurcation (none, str): `"pairwise"` or `"exclude"`.
/// - weighting (none, str): Spatial weighting, `"cable-length"` or `"nodes"`.
/// - plane (none, str): Coordinate or principal plane for projected hull area.
/// -> dictionary
#let metric(
  id,
  p: none,
  diameter-sampling: none,
  taper-quantity: none,
  taper-method: none,
  multifurcation: none,
  weighting: none,
  plane: none,
) = (
  id: id,
  parameters: (
    p: p,
    diameter_sampling: diameter-sampling,
    taper_quantity: taper-quantity,
    taper_method: taper-method,
    multifurcation: multifurcation,
    weighting: weighting,
    plane: plane,
  ),
)

/// Return the metric registry with definition revisions, entity support,
/// units, summaries, scientific references, and parameter schemas.
///
/// -> array
#let available-metrics() = _unwrap(_plugin.available_metrics())

#let _metric-spec(value) = if type(value) == str {
  metric(value)
} else if type(value) == dictionary and "id" in value {
  value
} else {
  panic("Axodendron: each metric must be an ID string or a value returned by `metric`")
}

/// Compute one or more explicitly versioned morphometrics.
///
/// The result is an array of tagged `MetricResult` dictionaries. A result's
/// `data.kind` identifies morphology, node, section, or bifurcation support;
/// undefined entities are retained in `missing` with a stable reason code.
///
/// - cell (dictionary): Morphology to measure.
/// - metrics (str, dictionary, array): Metric ID/specification or an array thereof.
/// - domain (str): `"neurites"` or `"raw"`.
/// - kinds (array): Optional SWC kinds; selection is an induced forest.
/// - roots (array): Optional subtree root node IDs.
/// - nodes (array): Optional explicit node IDs.
/// - section-boundaries (str): `"topology-and-type"` or `"topology-only"`.
/// -> array
#let measure(
  cell,
  metrics: none,
  domain: "neurites",
  kinds: (),
  roots: (),
  nodes: (),
  section-boundaries: "topology-and-type",
) = {
  let metrics = _required("metrics", metrics)
  let specs = if type(metrics) == array {
    metrics.map(_metric-spec)
  } else {
    (_metric-spec(metrics),)
  }
  _unwrap(_plugin.measure(
    _require-payload(cell),
    _request((
      metrics: specs,
      selection: _selection(domain: domain, kinds: kinds, roots: roots, nodes: nodes),
      section_boundaries: section-boundaries,
    )),
  ))
}

/// Compute a deterministic principal coordinate frame.
///
/// Cable-length weighting analytically integrates continuous segment moments,
/// making the result invariant to insertion of collinear SWC samples. Repeated
/// eigenvalue subspaces are reported through `ambiguous_axes`.
///
/// - cell (dictionary): Morphology to analyze.
/// - origin (str): Frame origin: `"centroid"`, `"soma"`, or `"world"`.
/// - weighting (str): `"cable-length"` or `"nodes"`.
/// - domain (str): Selection domain.
/// - kinds (array): Optional SWC kind filter.
/// - roots (array): Optional subtree roots.
/// - nodes (array): Optional explicit node IDs.
/// - relative-tolerance (int, float): Relative eigenvalue degeneracy tolerance.
/// - absolute-tolerance (int, float): Absolute eigenvalue/rank tolerance.
/// -> dictionary
#let principal-frame(
  cell,
  origin: "centroid",
  weighting: "cable-length",
  domain: "neurites",
  kinds: (),
  roots: (),
  nodes: (),
  relative-tolerance: 1e-10,
  absolute-tolerance: 1e-12,
) = _unwrap(_plugin.principal_frame(
  _require-payload(cell),
  _request((
    selection: _selection(domain: domain, kinds: kinds, roots: roots, nodes: nodes),
    weighting: weighting,
    origin: origin,
    relative_tolerance: relative-tolerance,
    absolute_tolerance: absolute-tolerance,
  )),
))

/// Construct a centrifugal branch-order selector. Orders start at one and
/// increase after each selected multifurcation.
///
/// - exact (none, int): Optional exact positive order.
/// - min (none, int): Optional inclusive lower bound.
/// - max (none, int): Optional inclusive upper bound.
/// -> dictionary
#let branch-order(exact: none, min: none, max: none) = (
  kind: "branch-order",
  exact: exact,
  min: min,
  max: max,
)

/// Construct a Strahler-order selector. Terminal branches have order one.
///
/// - exact (none, int): Optional exact positive order.
/// - min (none, int): Optional inclusive lower bound.
/// - max (none, int): Optional inclusive upper bound.
/// -> dictionary
#let strahler-order(exact: none, min: none, max: none) = (
  kind: "strahler-order",
  exact: exact,
  min: min,
  max: max,
)

#let _selector-spec(selector) = if type(selector) == str {
  (kind: selector)
} else if type(selector) == dictionary and "kind" in selector {
  selector
} else {
  panic("Axodendron: `selector` must be a selector name or selector dictionary")
}

/// Return node IDs matching a topology-aware selector without changing the morphology.
///
/// - cell (dictionary): Source morphology.
/// - selector (str, dictionary): Named selector or a value returned by `branch-order` or `strahler-order`.
/// - domain (str): Selection domain.
/// - kinds (array): Optional SWC kind filter.
/// - roots (array): Optional subtree roots.
/// - nodes (array): Optional explicit node IDs.
/// -> array
#let select-node-ids(
  cell,
  selector: "all",
  domain: "neurites",
  kinds: (),
  roots: (),
  nodes: (),
) = _unwrap(_plugin.query_nodes(
  _require-payload(cell),
  _request((
    query: _selection(domain: domain, kinds: kinds, roots: roots, nodes: nodes),
    selector: _selector-spec(selector),
  )),
)).at("node_ids")

/// Return selected branch-point node IDs.
///
/// -> array
#let branch-points(cell, ..args) = select-node-ids(cell, selector: "branch-points", ..args)

/// Return selected terminal node IDs.
///
/// -> array
#let terminals(cell, ..args) = select-node-ids(cell, selector: "terminals", ..args)

/// Return selected soma node IDs. Use `domain: "raw"` because the default
/// neurite domain intentionally excludes soma geometry.
///
/// -> array
#let soma-nodes(cell, ..args) = select-node-ids(cell, selector: "soma", ..args)

/// Return nodes matching a centrifugal branch-order constraint.
///
/// -> array
#let branch-order-nodes(cell, exact: none, min: none, max: none, ..args) = select-node-ids(
  cell,
  selector: branch-order(exact: exact, min: min, max: max),
  ..args,
)

/// Return nodes matching a Strahler-order constraint.
///
/// -> array
#let strahler-order-nodes(cell, exact: none, min: none, max: none, ..args) = select-node-ids(
  cell,
  selector: strahler-order(exact: exact, min: min, max: max),
  ..args,
)

/// Explicitly map a section- or bifurcation-supported field onto nodes.
///
/// - cell (dictionary): Morphology from which the field was measured.
/// - field (dictionary): One `MetricResult` returned by `measure`.
/// - placement (str): Entity-to-node placement rule.
/// - reducer (str): Collision rule; the default `"error"` prevents ambiguity.
/// -> dictionary
#let field-to-nodes(cell, field: none, placement: none, reducer: "error") = _unwrap(
  _plugin.field_to_nodes(
    _require-payload(cell),
    _request((
      field: _required("field", field),
      options: (
        placement: _required("placement", placement),
        reducer: reducer,
      ),
    )),
  ),
)

#let _principal-view(frame, plane) = {
  let axes = frame.at("axes")
  if plane == "xy" {
    (kind: "orthographic", direction: axes.at(2), up: axes.at(1))
  } else if plane == "xz" {
    (kind: "orthographic", direction: _vec3-neg(axes.at(1)), up: axes.at(2))
  } else if plane == "yz" {
    (kind: "orthographic", direction: axes.at(0), up: axes.at(2))
  } else {
    panic("Axodendron: principal projection plane must be `xy`, `xz`, or `yz`")
  }
}

#let _resolved-view(cell, projection) = if type(projection) == str and projection.starts-with("principal-") {
  _principal-view(principal-frame(cell), projection.slice(10))
} else if type(projection) == dictionary and projection.at("kind", default: none) == "principal" {
  _principal-view(
    projection.at("frame", default: principal-frame(cell)),
    projection.at("plane", default: "xy"),
  )
} else {
  _view(projection)
}

/// Exact 3D Sholl intersections. Radii and center use `cell.units`.
///
/// - cell (dictionary): The morphology to analyze.
/// - radii (array): Positive Sholl radii in the morphology's physical unit.
/// - center (none, array): Optional three-dimensional center coordinate.
/// - center-node (none, int): Optional node ID used as the center.
/// - domain (str): Node domain included in the intersection count.
/// - projection (none, str, dictionary): Optional orthographic projection for two-dimensional analysis.
/// -> dictionary
#let sholl(
  cell,
  radii: none,
  center: none,
  center-node: none,
  domain: "neurites",
  projection: none,
) = {
  let radii = _required("radii", radii)
  _unwrap(_plugin.sholl(
    _require-payload(cell),
    _request((
      radii: radii,
      center: if center == none { none } else { _vec3("center", center) },
      center_node: center-node,
      domain: domain,
      projection: if projection == none { none } else { _resolved-view(cell, projection) },
    )),
  ))
}

/// Exact 2D circle/segment Sholl intersections after physical orthographic projection.
///
/// - cell (dictionary): The morphology to analyze.
/// - radii (array): Positive Sholl radii in the morphology's physical unit.
/// - projection (str, dictionary): Named or custom orthographic projection.
/// - center (none, array): Optional three-dimensional center coordinate.
/// - center-node (none, int): Optional node ID used as the center.
/// - domain (str): Node domain included in the intersection count.
/// -> dictionary
#let sholl-2d(
  cell,
  radii: none,
  projection: "xy",
  center: none,
  center-node: none,
  domain: "neurites",
) = sholl(
  cell,
  radii: radii,
  center: center,
  center-node: center-node,
  domain: domain,
  projection: projection,
)
