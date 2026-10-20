// Pure morphology selection and geometry transformations.

#import "protocol.typ": _plugin, _request, _required, _positive, _unwrap, _require-payload, _cell-from-payload
#import "analysis.typ": _vec3, _selection, principal-frame

#let _transform(cell, operation) = {
  let result = _unwrap(_plugin.transform(
    _require-payload(cell),
    _request(operation),
  ))
  _cell-from-payload(result.at("payload")) + (
    transform-report: result.at("report"),
    mapping: result.at("mapping"),
    lineage: result.at("lineage"),
  )
}

#let _angle-radians(value) = if type(value) == angle {
  value.rad()
} else if type(value) == int or type(value) == float {
  value
} else {
  panic("Axodendron: rotation angle must be an angle or a numeric radian value")
}

/// Translate all SWC coordinates without changing radii or topology.
///
/// - cell (dictionary): Source morphology.
/// - offset (array, dictionary): Three-dimensional translation in morphology units.
/// -> dictionary
#let translate(cell, offset: none) = _transform(cell, (
  operation: "translate",
  offset: _vec3("offset", _required("offset", offset)),
))

/// Apply a right-handed axis-angle rotation about a physical center.
///
/// - cell (dictionary): Source morphology.
/// - axis (array, dictionary): Non-zero rotation axis.
/// - angle (angle, int, float): Typst angle or numeric radians.
/// - center (array, dictionary): Rotation center in morphology coordinates.
/// -> dictionary
#let rotate(cell, axis: none, angle: none, center: (0, 0, 0)) = _transform(cell, (
  operation: "rotate",
  axis: _vec3("axis", _required("axis", axis)),
  angle_radians: _angle-radians(_required("angle", angle)),
  center: _vec3("center", center),
))

/// Uniformly scale coordinates and radii about a physical center.
///
/// - cell (dictionary): Source morphology.
/// - factor (int, float): Positive scale factor.
/// - center (array, dictionary): Fixed point of the scaling operation.
/// -> dictionary
#let uniform-scale(cell, factor: none, center: (0, 0, 0)) = _transform(cell, (
  operation: "uniform-scale",
  factor: _positive("factor", factor),
  center: _vec3("center", center),
))

/// Reflect coordinates across a plane while preserving circular radii.
///
/// - cell (dictionary): Source morphology.
/// - normal (array, dictionary): Non-zero plane normal.
/// - point (array, dictionary): One point on the reflection plane.
/// -> dictionary
#let reflect(cell, normal: none, point: (0, 0, 0)) = _transform(cell, (
  operation: "reflect",
  normal: _vec3("normal", _required("normal", normal)),
  point: _vec3("point", point),
))

/// Apply a general invertible affine map to centerline coordinates.
///
/// Non-similarity affine maps cannot represent transformed circular
/// cross-sections exactly in SWC. `radius-policy` is therefore explicit and
/// the transform report marks the result as radius-lossy.
///
/// - cell (dictionary): Source morphology.
/// - matrix (array): Three rows of three finite numbers.
/// - translation (array, dictionary): Affine translation.
/// - radius-policy (str): `"preserve"` or `"volume-equivalent"`.
/// -> dictionary
#let affine-transform(
  cell,
  matrix: none,
  translation: (0, 0, 0),
  radius-policy: "preserve",
) = _transform(cell, (
  operation: "general-affine",
  affine: (
    matrix: _required("matrix", matrix),
    translation: _vec3("translation", translation),
  ),
  radius_policy: radius-policy,
))

/// Express morphology coordinates in a deterministic principal frame.
///
/// - cell (dictionary): Source morphology.
/// - frame (none, dictionary): Optional precomputed `principal-frame` result.
/// - allow-degenerate (bool): Permit a deterministic but scientifically ambiguous degenerate basis.
/// - weighting (str): Weighting used when a frame is computed automatically.
/// - origin (str): Origin used when a frame is computed automatically.
/// - domain (str): Selection domain for automatic PCA.
/// - kinds (array): Optional SWC kind filter.
/// -> dictionary
#let pca-align(
  cell,
  frame: none,
  allow-degenerate: false,
  weighting: "cable-length",
  origin: "soma",
  domain: "neurites",
  kinds: (),
) = {
  let frame = if frame == none {
    principal-frame(cell, weighting: weighting, origin: origin, domain: domain, kinds: kinds)
  } else {
    frame
  }
  _transform(cell, (
    operation: "principal-align",
    frame: frame,
    allow_degenerate: allow-degenerate,
  ))
}

/// Translate a soma or selected centroid to a requested target coordinate.
///
/// - cell (dictionary): Source morphology.
/// - by (str): `"soma"` or `"centroid"`.
/// - target (array, dictionary): Desired center coordinate.
/// - weighting (str): Centroid weighting.
/// - domain (str): Centroid selection domain.
/// - kinds (array): Optional SWC kind filter.
/// -> dictionary
#let center-morphology(
  cell,
  by: "soma",
  target: (0, 0, 0),
  weighting: "cable-length",
  domain: "neurites",
  kinds: (),
) = {
  let point = _unwrap(_plugin.center_point(
    _require-payload(cell),
    _request((
      center: by,
      selection: _selection(domain: domain, kinds: kinds),
      weighting: weighting,
    )),
  ))
  let target = _vec3("target", target)
  translate(cell, offset: (
    target.at("x") - point.at("x"),
    target.at("y") - point.at("y"),
    target.at("z") - point.at("z"),
  ))
}

/// Select exactly the listed nodes as an induced forest over original edges.
///
/// - cell (dictionary): The source morphology.
/// - nodes (array): Integer node IDs to retain.
/// -> dictionary
#let select-nodes(cell, nodes: none) = _transform(cell, (
  operation: "select-nodes",
  node_ids: _required("nodes", nodes),
))

/// Select nodes of the listed SWC kinds without inventing bridging edges.
///
/// - cell (dictionary): The source morphology.
/// - kinds (array): Integer SWC type codes to retain.
/// -> dictionary
#let select-kinds(cell, kinds: none) = _transform(cell, (
  operation: "select-kinds",
  kinds: _required("kinds", kinds),
))

/// Extract a node and all of its descendants.
///
/// - cell (dictionary): The source morphology.
/// - node (int): Root node ID of the extracted subtree.
/// -> dictionary
#let subtree(cell, node: none) = _transform(cell, (
  operation: "subtree",
  node_id: _required("node", node),
))

/// Extract the unique undirected path between two nodes in one component.
///
/// - cell (dictionary): The source morphology.
/// - start (int): Node ID at one end of the path.
/// - end (int): Node ID at the other end of the path.
/// -> dictionary
#let path(cell, start: none, end: none) = _transform(cell, (
  operation: "path",
  from_id: _required("start", start),
  to_id: _required("end", end),
))

/// Reverse the parent chain so `node` becomes the root of its component.
///
/// - cell (dictionary): The source morphology.
/// - node (int): Node ID that becomes the new component root.
/// -> dictionary
#let reroot(cell, node: none) = _transform(cell, (
  operation: "reroot",
  node_id: _required("node", node),
))

/// Remove nodes of the listed SWC kinds and their descendant subtrees.
///
/// - cell (dictionary): The source morphology.
/// - kinds (array): Integer SWC type codes whose subtrees should be removed.
/// -> dictionary
#let prune(cell, kinds: none) = _transform(cell, (
  operation: "drop-kinds",
  kinds: _required("kinds", kinds),
))

/// Topology-preserving 3D Ramer–Douglas–Peucker simplification.
///
/// - cell (dictionary): The source morphology.
/// - tolerance (int, float): Maximum spatial deviation in `cell.units`.
/// - preserve-type-changes (bool): Whether nodes at SWC type transitions must be retained.
/// - preserve-soma (bool): Whether soma nodes must be retained.
/// - protected-nodes (array): Additional integer node IDs that must be retained.
/// -> dictionary
#let simplify(
  cell,
  tolerance: none,
  preserve-type-changes: true,
  preserve-soma: true,
  protected-nodes: (),
) = {
  let tolerance = _required("tolerance", tolerance)
  _transform(cell, (
    operation: "simplify",
    options: (
      tolerance: tolerance,
      preserve_type_changes: preserve-type-changes,
      preserve_soma: preserve-soma,
      protected_ids: protected-nodes,
    ),
  ))
}

/// Equal-arc-length resampling within topology- and type-bounded sections.
///
/// - cell (dictionary): The source morphology.
/// - step (int, float): Positive target spacing in `cell.units`.
/// - protected-nodes (array): Integer node IDs that must survive resampling.
/// -> dictionary
#let resample(cell, step: none, protected-nodes: ()) = _transform(cell, (
  operation: "resample",
  options: (
    step: _positive("step", step),
    protected_ids: protected-nodes,
  ),
))

/// Export deterministic SWC with topological row order and sequential IDs.
/// Single-root cells satisfy the strict profile; forests preserve all roots.
///
/// - cell (dictionary): The morphology to serialize.
/// -> str
#let export-swc(cell) = _unwrap(_plugin.export_swc(_require-payload(cell))).at("source")
