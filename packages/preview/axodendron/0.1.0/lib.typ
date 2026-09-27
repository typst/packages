/// Axodendron validates, analyzes, transforms, and renders neuronal
/// morphologies from SWC data inside Typst.
///
/// Load an SWC morphology with `load`, inspect it with `analyze` or `sholl`,
/// derive a new morphology with the transformation functions, and create
/// publication-ready vector output with `render`.

#let _api-version = 1
#let _plugin = plugin("plugin.wasm")

#let _request(value) = cbor.encode((api_version: _api-version, value: value))

#let _required(name, value) = {
  if value == none {
    panic("Axodendron: missing required argument `" + name + "`")
  }
  value
}

#let _positive(name, value) = {
  let value = _required(name, value)
  if (type(value) != int and type(value) != float) or value <= 0 {
    panic("Axodendron: `" + name + "` must be a positive number")
  }
  value
}

#let _nonnegative-length(name, value) = {
  if type(value) != length or value < 0pt {
    panic("Axodendron: `" + name + "` must be a non-negative length")
  }
  value
}

#let _length-offset(name, value) = {
  if type(value) != dictionary or not "x" in value or not "y" in value {
    panic("Axodendron: `" + name + "` must be a dictionary containing `x` and `y`")
  }
  if type(value.at("x")) != length or type(value.at("y")) != length {
    panic("Axodendron: `" + name + ".x` and `" + name + ".y` must be lengths")
  }
  value
}

#let _node-id-array(name, value) = {
  if type(value) != array or not value.all(node => type(node) == int) {
    panic("Axodendron: `" + name + "` must be an array of integer node IDs")
  }
  value
}

#let _unique(values) = values.fold((), (result, value) => {
  if value in result { result } else { result + (value,) }
})

#let _unwrap(raw) = {
  let response = cbor(raw)
  if response.at("api_version") != _api-version {
    panic("Axodendron API version mismatch")
  }
  if not response.at("ok") {
    let error = response.at("error")
    panic("Axodendron " + error.at("code") + ": " + error.at("message"))
  }
  response.at("value")
}

#let _format-diagnostic(item) = {
  let line = item.at("line")
  let column = item.at("column")
  let location = if line == none {
    ""
  } else if column == none {
    " at line " + str(line)
  } else {
    " at line " + str(line) + ", column " + str(column)
  }
  "[" + item.at("code") + "] " + item.at("message") + location
}

#let _parse-bytes(source, profile: "permissive", fail-on-error: true) = {
  let value = _unwrap(_plugin.parse(
    source,
    _request((profile: profile)),
  ))
  if fail-on-error and not value.at("valid") {
    panic(value.at("diagnostics").map(_format-diagnostic).join("\n"))
  }
  (
    payload: if value.at("payload") == none {
      none
    } else {
      cbor.encode(value.at("payload"))
    },
    valid: value.at("valid"),
    diagnostics: value.at("diagnostics"),
    fingerprint: value.at("fingerprint"),
    source-fingerprint: value.at("source_fingerprint"),
    node-count: value.at("node_count"),
    units: value.at("units"),
    metadata: value.at("metadata"),
  )
}

#let _require-payload(cell) = {
  if cell.at("payload") == none {
    panic("Axodendron: this morphology is invalid and has no computational payload")
  }
  cell.at("payload")
}

#let _cell-from-payload(payload) = {
  let morphology = payload.at("morphology")
  (
    payload: cbor.encode(payload),
    valid: true,
    diagnostics: (),
    fingerprint: morphology.at("fingerprint"),
    source-fingerprint: morphology.at("source_fingerprint"),
    node-count: morphology.at("ids").len(),
    units: morphology.at("units"),
    metadata: morphology.at("metadata"),
  )
}

#let _v15-or-later() = sys.version >= version(0, 15, 0)

#let _source-to-bytes(source) = {
  if _v15-or-later() and repr(type(source)) == "path" {
    read(source, encoding: none)
  } else if type(source) == bytes {
    source
  } else {
    bytes(source)
  }
}

/// Load and validate SWC input. Typst 0.15.0 and later may pass `path(...)`
/// directly; Typst 0.14.x should pass `read("neuron.swc", encoding: none)` so
/// the path is resolved at the calling document.
///
/// Geometry values remain unitless numbers in the physical unit named by
/// `cell.units` (SWC convention: micrometres). Typst layout lengths are only
/// used by `render`.
///
/// - source (any): SWC input as bytes or text, or a `path` on Typst 0.15.0 and later.
/// - profile (str): Validation profile, either `"permissive"` or `"incf-strict"`.
/// - fail-on-error (bool): Whether validation errors should stop evaluation.
/// -> dictionary
#let load(source, profile: "permissive", fail-on-error: true) = _parse-bytes(
  _source-to-bytes(source),
  profile: profile,
  fail-on-error: fail-on-error,
)

/// Parse and validate SWC source already held in memory.
///
/// - source (str, bytes): SWC source text or its byte representation.
/// - profile (str): Validation profile, either `"permissive"` or `"incf-strict"`.
/// - fail-on-error (bool): Whether validation errors should stop evaluation.
/// -> dictionary
#let from-text(source, profile: "permissive", fail-on-error: true) = _parse-bytes(
  if type(source) == bytes { source } else { bytes(source) },
  profile: profile,
  fail-on-error: fail-on-error,
)

/// Return all validation diagnostics retained by a cell.
///
/// - cell (dictionary): A morphology returned by `load`, `from-text`, or a transformation.
/// -> array
#let diagnostics(cell) = cell.at("diagnostics")

/// Return retained SWC header comments and recognized descriptive fields.
/// Metadata such as scale or shrinkage correction is never applied implicitly.
///
/// - cell (dictionary): A morphology returned by `load`, `from-text`, or a transformation.
/// -> dictionary
#let metadata(cell) = cell.at("metadata")

#let _view(projection) = if type(projection) == str {
  (kind: projection)
} else {
  (
    kind: "orthographic",
    direction: projection.at("direction"),
    up: projection.at("up"),
  )
}

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
      center: center,
      center_node: center-node,
      domain: domain,
      projection: if projection == none { none } else { _view(projection) },
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

/// Construct a Typst-native node label annotation. `offset.x` and `offset.y`
/// shift the label after projection; positive values move right and down.
///
/// - body (content): Label content.
/// - node (int): Node ID to annotate.
/// - offset (dictionary): Typst `x` and `y` length offsets from the projected node.
/// -> dictionary
#let label(body, node: none, offset: (x: 4pt, y: -4pt)) = (
  kind: "label",
  node: _required("node", node),
  body: body,
  offset: offset,
)

/// Construct a node-anchored marker. If `body` is omitted, a circle is drawn.
///
/// - node (int): Node ID to mark.
/// - body (none, content): Optional marker content; `none` draws a circle.
/// - offset (dictionary): Typst `x` and `y` length offsets from the projected node.
/// - size (length): Marker width and height.
/// - fill (any): Circle fill accepted by Typst.
/// - stroke (any): Circle stroke accepted by Typst.
/// -> dictionary
#let marker(
  node: none,
  body: none,
  offset: (x: 0pt, y: 0pt),
  size: 5pt,
  fill: white,
  stroke: 0.8pt + black,
) = (
  kind: "marker",
  node: _required("node", node),
  body: body,
  offset: offset,
  size: size,
  fill: fill,
  stroke: stroke,
)

/// Construct a CeTZ leader label. `offset` and every `via` entry are relative
/// to the projected node in Typst screen coordinates: positive x moves right
/// and positive y moves down. Side leaders leave the text at its typographic
/// vertical center. Leaders are straight or follow `via` line segments unless
/// the caller explicitly supplies one or two CeTZ Bezier `controls`. The
/// optional white label fill prevents dense morphology geometry from showing
/// through the text without drawing a frame.
///
/// - body (content): Label content.
/// - node (int): Node ID targeted by the leader.
/// - offset (dictionary): Typst `x` and `y` lengths from the node to the label.
/// - via (array): Optional relative polyline vertices as `x` and `y` length dictionaries.
/// - controls (array): Zero, one, or two relative CeTZ Bezier control points.
/// - anchor (auto, str): Automatic or explicit CeTZ anchor for the label content.
/// - padding (length): Non-negative padding around the label content.
/// - fill (any): Label background fill accepted by CeTZ.
/// - label-stroke (any): Optional label frame stroke accepted by CeTZ.
/// - arrow-stroke (any): Leader stroke accepted by CeTZ.
/// - arrow-fill (any): Arrowhead fill accepted by CeTZ.
/// - mark (none, str): CeTZ end-mark name, or `none` for no arrowhead.
/// - mark-scale (int, float): Positive CeTZ end-mark scale.
/// - target-gap (length): Non-negative gap between the leader endpoint and target node.
/// -> dictionary
#let cetz-label(
  body,
  node: none,
  offset: (x: 16mm, y: -10mm),
  via: (),
  controls: (),
  anchor: auto,
  padding: 2pt,
  fill: white,
  label-stroke: none,
  arrow-stroke: 0.7pt + black,
  arrow-fill: black,
  mark: "stealth",
  mark-scale: 0.7,
  target-gap: 0pt,
) = {
  let offset = _length-offset("cetz-label.offset", offset)
  if type(via) != array {
    panic("Axodendron: `cetz-label.via` must be an array of x/y length dictionaries")
  }
  let via = via.enumerate().map(((index, point)) => {
    _length-offset("cetz-label.via." + str(index), point)
  })
  if type(controls) != array or controls.len() not in (0, 1, 2) {
    panic("Axodendron: `cetz-label.controls` must contain zero, one, or two x/y length dictionaries")
  }
  let controls = controls.enumerate().map(((index, point)) => {
    _length-offset("cetz-label.controls." + str(index), point)
  })
  if controls != () and via != () {
    panic("Axodendron: `cetz-label.controls` and `cetz-label.via` cannot be combined")
  }
  if anchor != auto and type(anchor) != str {
    panic("Axodendron: `cetz-label.anchor` must be `auto` or a CeTZ anchor string")
  }
  if offset.at("x") == 0pt and offset.at("y") == 0pt {
    panic("Axodendron: a CeTZ leader label needs a non-zero offset")
  }
  let route-offsets = (offset,) + via + ((x: 0pt, y: 0pt),)
  for index in range(route-offsets.len() - 1) {
    let current = route-offsets.at(index)
    let next = route-offsets.at(index + 1)
    if current.at("x") == next.at("x") and current.at("y") == next.at("y") {
      panic("Axodendron: consecutive CeTZ leader points must not coincide")
    }
  }
  if (type(mark-scale) != int and type(mark-scale) != float) or mark-scale <= 0 {
    panic("Axodendron: `cetz-label.mark-scale` must be a positive number")
  }
  if mark != none and type(mark) != str {
    panic("Axodendron: `cetz-label.mark` must be a CeTZ mark string or none")
  }
  (
    kind: "cetz-label",
    node: _required("node", node),
    body: body,
    offset: offset,
    via: via,
    controls: controls,
    anchor: anchor,
    padding: _nonnegative-length("cetz-label.padding", padding),
    fill: fill,
    label-stroke: label-stroke,
    arrow-stroke: arrow-stroke,
    arrow-fill: arrow-fill,
    mark: mark,
    mark-scale: mark-scale,
    target-gap: _nonnegative-length("cetz-label.target-gap", target-gap),
  )
}

/// Construct a compact categorical legend.
///
/// - entries (array): Legend entries containing `color` and `label` fields.
/// - position (any): Typst alignment used to place the legend.
/// - inset (length): Distance from the selected render edge.
/// -> dictionary
#let legend(entries: none, position: top + right, inset: 8pt) = (
  entries: _required("entries", entries),
  position: position,
  inset: inset,
)

/// Construct a scalar color bar using the same named palette as the renderer.
/// `label-gap` controls the vertical space between its label and palette strip.
///
/// - min (int, float): Scalar value shown at the low end of the palette.
/// - max (int, float): Scalar value shown at the high end of the palette.
/// - label (none, content, str): Optional color-bar label.
/// - label-gap (length): Non-negative vertical gap below the label.
/// - colormap (str): Named scalar palette, either `"viridis"` or `"magma"`.
/// - position (any): Typst alignment used to place the color bar.
/// - inset (length): Distance from the selected render edge.
/// -> dictionary
#let color-bar(
  min: none,
  max: none,
  label: none,
  label-gap: 4pt,
  colormap: "viridis",
  position: bottom + right,
  inset: 8pt,
) = (
  min: _required("min", min),
  max: _required("max", max),
  label: label,
  label-gap: _nonnegative-length("label-gap", label-gap),
  colormap: colormap,
  position: position,
  inset: inset,
)

/// Construct a physical scale bar. `value` is in the morphology's units.
///
/// - value (int, float): Positive physical length represented by the bar.
/// - label (none, content, str): Optional replacement for the generated unit label.
/// - inset (length): Distance from the bottom-left render edges.
/// - stroke (any): Scale-bar line stroke accepted by Typst.
/// -> dictionary
#let scale-bar(value: none, label: none, inset: 8pt, stroke: 1pt) = (
  value: _positive("value", value),
  label: label,
  inset: inset,
  stroke: stroke,
)

/// Package and plugin protocol version.
///
/// -> str
#let version = str(_plugin.version())

#let _color(color-by, colormap, minimum, maximum) = if color-by == "type" {
  (mode: "by-type")
} else if type(color-by) == str {
  (mode: "uniform", color: color-by)
} else {
  (
    mode: "scalar",
    node_ids: color-by.at("node_ids"),
    values: color-by.at("values"),
    minimum: minimum,
    maximum: maximum,
    colormap: colormap,
    fingerprint: color-by.at("fingerprint", default: none),
  )
}

#let _display-unit(unit) = if unit == "um" { "µm" } else { unit }

#let _overlay-dx(position, inset) = {
  if position == left or position == top + left or position == bottom + left {
    inset
  } else {
    -inset
  }
}

#let _overlay-dy(position, inset) = {
  if position == bottom or position == bottom + left or position == bottom + right {
    -inset
  } else {
    inset
  }
}

#let _palette-stops(name) = if name == "magma" {
  ("#000004", "#51127c", "#b73779", "#fc8961", "#fcfdbf")
} else {
  ("#440154", "#3b528b", "#21918c", "#5ec962", "#fde725")
}

#let _projected-anchor(node, width, height, canvas-width, canvas-height) = (
  node: node.at("node_id"),
  x: width * node.at("x") / canvas-width,
  y: height * node.at("y") / canvas-height,
  x-ratio: node.at("x") / canvas-width,
  y-ratio: node.at("y") / canvas-height,
  screen-x: node.at("x"),
  screen-y: node.at("y"),
  depth: node.at("depth"),
)

/// Return one projected node from a render result. Coordinates `x` and `y`
/// are Typst lengths measured from the render block's top-left corner.
///
/// - render-result (dictionary): Result of `render` with `return-report: true`.
/// - node (int): Requested node ID included in `anchor-nodes` or an annotation.
/// -> dictionary
#let node-anchor(render-result, node: none) = {
  let node = _required("node", node)
  if type(render-result) != dictionary or not "node-anchors" in render-result {
    panic("Axodendron: `node-anchor` requires `render(..., return-report: true)`")
  }
  let found = render-result.at("node-anchors").find(anchor => anchor.at("node") == node)
  if found == none {
    panic("Axodendron: node " + str(node) + " is not present in this render result; request it with `anchor-nodes`")
  }
  found
}

#let _cetz-point(render-result, anchor, length) = (
  anchor.at("x") / length,
  (render-result.at("height") - anchor.at("y")) / length,
)

#let _cetz-relative(point, offset, length) = (
  point.at(0) + offset.at("x") / length,
  point.at(1) - offset.at("y") / length,
)

#let _cetz-auto-anchor(offset) = {
  let x = offset.at("x")
  let y = offset.at("y")
  if x > 0pt and y > 0pt {
    "north-west"
  } else if x > 0pt and y < 0pt {
    "south-west"
  } else if x < 0pt and y > 0pt {
    "north-east"
  } else if x < 0pt and y < 0pt {
    "south-east"
  } else if x > 0pt {
    "west"
  } else if x < 0pt {
    "east"
  } else if y > 0pt {
    "north"
  } else if y < 0pt {
    "south"
  } else {
    "center"
  }
}

#let _cetz-leader-start(label-name, offset) = {
  let x = offset.at("x")
  let y = offset.at("y")
  label-name + "." + if x > 0pt {
    "mid-west"
  } else if x < 0pt {
    "mid-east"
  } else if y > 0pt {
    "north"
  } else {
    "south"
  }
}

#let _shorten-cetz-target(previous, target, gap, length) = {
  if gap == 0pt {
    target
  } else {
    let dx = target.at(0) - previous.at(0)
    let dy = target.at(1) - previous.at(1)
    let distance = calc.sqrt(dx * dx + dy * dy)
    if distance == 0 {
      panic("Axodendron: the last CeTZ leader segment has zero length")
    }
    let amount = gap / length
    if amount >= distance {
      panic("Axodendron: `cetz-label.target-gap` must be shorter than the last leader segment")
    }
    (
      target.at(0) - dx * amount / distance,
      target.at(1) - dy * amount / distance,
    )
  }
}

/// Overlay CeTZ leader labels on a completed render result. The CeTZ module is
/// injected by the caller so Axodendron remains usable without that package.
///
/// - render-result (dictionary): Result of `render` with `return-report: true`.
/// - cetz (module): Imported CeTZ module.
/// - labels (array): Annotations returned by `cetz-label`.
/// - length (length): Positive CeTZ canvas coordinate unit.
/// - strict (bool): Whether a missing target node should stop evaluation.
/// -> content
#let cetz-annotate(
  render-result,
  cetz: none,
  labels: (),
  length: 1pt,
  strict: true,
) = {
  let cetz = _required("cetz", cetz)
  if type(render-result) != dictionary or not "body" in render-result or not "node-anchors" in render-result {
    panic("Axodendron: `cetz-annotate` requires `render(..., return-report: true)`")
  }
  if type(labels) != array {
    panic("Axodendron: `cetz-annotate.labels` must be an array")
  }
  if type(length) != std.length or length <= 0pt {
    panic("Axodendron: `cetz-annotate.length` must be a positive length")
  }
  let commands = ()
  let width = render-result.at("width") / length
  let height = render-result.at("height") / length
  commands += cetz.draw.on-layer(-2, cetz.draw.content(
    (0, 0),
    (width, height),
    render-result.at("body"),
    padding: 0,
  ))

  for anchor in render-result.at("node-anchors") {
    commands += cetz.draw.anchor(
      "axodendron-node-" + str(anchor.at("node")),
      _cetz-point(render-result, anchor, length),
    )
  }

  for ((index, annotation)) in labels.enumerate() {
    if type(annotation) != dictionary or annotation.at("kind", default: none) != "cetz-label" {
      panic("Axodendron: `cetz-annotate.labels` accepts only values returned by `cetz-label`")
    }
    let anchor = render-result.at("node-anchors").find(item => item.at("node") == annotation.at("node"))
    if anchor == none {
      if strict {
        panic("Axodendron: CeTZ label node " + str(annotation.at("node")) + " is not present in this render result")
      }
    } else {
      let target = _cetz-point(render-result, anchor, length)
      let label-point = _cetz-relative(target, annotation.at("offset"), length)
      let label-name = "axodendron-label-" + str(index)
      let label-anchor = if annotation.at("anchor") == auto {
        _cetz-auto-anchor(annotation.at("offset"))
      } else {
        annotation.at("anchor")
      }
      commands += cetz.draw.on-layer(1, cetz.draw.content(
        label-point,
        annotation.at("body"),
        name: label-name,
        anchor: label-anchor,
        padding: annotation.at("padding"),
        frame: "rect",
        fill: annotation.at("fill"),
        stroke: annotation.at("label-stroke"),
      ))
      let via = annotation.at("via").map(point => _cetz-relative(target, point, length))
      let controls = annotation.at("controls").map(point => _cetz-relative(target, point, length))
      let previous = if controls != () {
        controls.last()
      } else if via == () {
        label-point
      } else {
        via.last()
      }
      let endpoint = _shorten-cetz-target(
        previous,
        target,
        annotation.at("target-gap"),
        length,
      )
      let leader-start = _cetz-leader-start(label-name, annotation.at("offset"))
      let leader-end = if endpoint == target {
        "axodendron-node-" + str(annotation.at("node"))
      } else {
        endpoint
      }
      let mark = if annotation.at("mark") == none {
        none
      } else {
        (
          end: annotation.at("mark"),
          scale: annotation.at("mark-scale"),
          fill: annotation.at("arrow-fill"),
          transform-shape: false,
        )
      }
      let leader = if controls == () {
        cetz.draw.line(
          ..((leader-start,) + via + (leader-end,)),
          stroke: annotation.at("arrow-stroke"),
          mark: mark,
        )
      } else {
        cetz.draw.bezier(
          leader-start,
          leader-end,
          ..controls,
          stroke: annotation.at("arrow-stroke"),
          mark: mark,
        )
      }
      commands += cetz.draw.on-layer(0, leader)
    }
  }
  cetz.canvas(commands, length: length)
}

/// Render a radius-aware morphology as one WASM-generated SVG, then add labels
/// and a scale bar as native Typst content. `width` and `height` are page units;
/// all canvas and morphology values are unitless numbers.
///
/// - cell (dictionary): The morphology to render.
/// - projection (str, dictionary): Named or custom orthographic projection.
/// - color-by (str, dictionary): Compartment coloring, a uniform color, or scalar node data.
/// - colormap (str): Named scalar palette, either `"viridis"` or `"magma"`.
/// - minimum (none, int, float): Optional lower bound for scalar coloring.
/// - maximum (none, int, float): Optional upper bound for scalar coloring.
/// - width (length): Positive Typst width of the render block.
/// - height (length): Positive Typst height of the render block.
/// - canvas-width (int): Positive SVG viewport width in unitless pixels.
/// - canvas-height (int): Positive SVG viewport height in unitless pixels.
/// - padding (int, float): Non-negative SVG viewport padding.
/// - geometry (str): Segment geometry mode, such as `"tapered"` or `"skeleton"`.
/// - radius-mode (str): Radius display policy applied to neurites.
/// - soma-mode (str): Soma display policy.
/// - stroke-width (int, float): Skeleton or centerline width in SVG pixels.
/// - minimum-radius (int, float): Lower display-radius clamp in SVG pixels.
/// - maximum-radius (int, float): Upper neurite display-radius clamp in SVG pixels.
/// - maximum-soma-radius (int, float): Upper soma display-radius clamp in SVG pixels.
/// - radius-scale (int, float): Positive multiplier applied to neurite radii.
/// - radius-exponent (int, float): Positive exponent applied to neurite radii.
/// - soma-scale (int, float): Positive multiplier applied to soma radii.
/// - background (none, str): Optional SVG background color.
/// - outline-color (none, str): Optional segment-outline color.
/// - outline-width (int, float): Non-negative segment-outline width in SVG pixels.
/// - display-tolerance (none, int, float): Optional display-only simplification tolerance in `cell.units`.
/// - include-nodes (bool): Whether the generated SVG should include node elements.
/// - anchor-nodes (array): Additional integer node IDs whose projected positions are returned.
/// - labels (array): Typst-native annotations returned by `label`.
/// - markers (array): Typst-native annotations returned by `marker`.
/// - cetz (none, module): Imported CeTZ module required by `cetz-labels`.
/// - cetz-labels (array): Leader annotations returned by `cetz-label`.
/// - legend (none, dictionary): Optional categorical legend returned by `legend`.
/// - color-bar (none, dictionary): Optional scalar color bar returned by `color-bar`.
/// - scale-bar (none, dictionary): Optional physical scale bar returned by `scale-bar`.
/// - strict-node-ids (bool): Whether missing annotation and anchor node IDs should stop evaluation.
/// - return-report (bool): Whether to return geometry metadata with the rendered content.
/// -> content, dictionary
#let render(
  cell,
  projection: "xy",
  color-by: "type",
  colormap: "viridis",
  minimum: none,
  maximum: none,
  width: 120mm,
  height: 90mm,
  canvas-width: 800,
  canvas-height: 600,
  padding: 24,
  geometry: "tapered",
  radius-mode: "readable",
  soma-mode: "equivalent-sphere",
  stroke-width: 2,
  minimum-radius: 1,
  maximum-radius: 18,
  maximum-soma-radius: 96,
  radius-scale: 1,
  radius-exponent: 0.5,
  soma-scale: 1,
  background: none,
  outline-color: none,
  outline-width: 1,
  display-tolerance: none,
  include-nodes: false,
  anchor-nodes: (),
  labels: (),
  markers: (),
  cetz: none,
  cetz-labels: (),
  legend: none,
  color-bar: none,
  scale-bar: none,
  strict-node-ids: true,
  return-report: false,
) = {
  if width <= 0pt or height <= 0pt {
    panic("Axodendron: render width and height must be positive lengths")
  }
  if calc.abs(width / height - canvas-width / canvas-height) > 0.000001 {
    panic("Axodendron: page and SVG canvas aspect ratios must match")
  }
  let anchor-nodes = _node-id-array("anchor-nodes", anchor-nodes)
  if type(labels) != array or type(markers) != array or type(cetz-labels) != array {
    panic("Axodendron: labels, markers, and cetz-labels must be arrays")
  }
  if not cetz-labels.all(annotation => {
    type(annotation) == dictionary and annotation.at("kind", default: none) == "cetz-label"
  }) {
    panic("Axodendron: `cetz-labels` accepts only values returned by `cetz-label`")
  }
  if cetz-labels != () and cetz == none {
    panic("Axodendron: pass the imported CeTZ module as `cetz` when using `cetz-labels`")
  }
  let overlay-node-ids = _unique(
    (labels + markers + cetz-labels).map(annotation => annotation.at("node")) + anchor-nodes,
  )
  let options = (
    width: canvas-width,
    height: canvas-height,
    padding: padding,
    stroke_width: stroke-width,
    geometry: geometry,
    radius_mode: radius-mode,
    soma_mode: soma-mode,
    minimum_radius: minimum-radius,
    maximum_radius: maximum-radius,
    maximum_soma_radius: maximum-soma-radius,
    radius_scale: radius-scale,
    radius_exponent: radius-exponent,
    soma_scale: soma-scale,
    background: background,
    outline_color: outline-color,
    outline_width: outline-width,
    view: _view(projection),
    color: _color(color-by, colormap, minimum, maximum),
    display_tolerance: display-tolerance,
    include_nodes: include-nodes,
    overlay_node_ids: overlay-node-ids,
    strict_overlay_ids: strict-node-ids,
  )
  let document = _unwrap(_plugin.render(_require-payload(cell), _request(options)))
  let projected = document.at("nodes")
  let node-anchors = projected.map(node => _projected-anchor(
    node,
    width,
    height,
    canvas-width,
    canvas-height,
  ))

  let native-body = block(width: width, height: height, clip: true)[
    #image(bytes(document.at("svg")), format: "svg", width: 100%, height: 100%, fit: "stretch")

    #for annotation in labels {
      let node = projected.find(item => item.at("node_id") == annotation.at("node"))
      if node == none {
        if strict-node-ids {
          panic("Axodendron: label node " + str(annotation.at("node")) + " was not rendered")
        }
      } else {
        let offset = annotation.at("offset")
        place(
          top + left,
          dx: width * node.at("x") / canvas-width + offset.at("x"),
          dy: height * node.at("y") / canvas-height + offset.at("y"),
          annotation.at("body"),
        )
      }
    }

    #for annotation in markers {
      let node = projected.find(item => item.at("node_id") == annotation.at("node"))
      if node == none {
        if strict-node-ids {
          panic("Axodendron: marker node " + str(annotation.at("node")) + " was not rendered")
        }
      } else {
        let offset = annotation.at("offset")
        let body = annotation.at("body")
        place(
          top + left,
          dx: width * node.at("x") / canvas-width + offset.at("x") - annotation.at("size") / 2,
          dy: height * node.at("y") / canvas-height + offset.at("y") - annotation.at("size") / 2,
          if body == none {
            circle(
              radius: annotation.at("size") / 2,
              fill: annotation.at("fill"),
              stroke: annotation.at("stroke"),
            )
          } else {
            box(
              width: annotation.at("size"),
              height: annotation.at("size"),
              align(center + horizon, body),
            )
          },
        )
      }
    }

    #if legend != none {
      place(
        legend.at("position"),
        dx: _overlay-dx(legend.at("position"), legend.at("inset")),
        dy: _overlay-dy(legend.at("position"), legend.at("inset")),
        block(
          inset: 4pt,
          fill: white.transparentize(8%),
          stroke: 0.4pt + luma(70%),
          radius: 2pt,
          stack(
            dir: ttb,
            spacing: 2pt,
            ..legend.at("entries").map(entry => grid(
              columns: (7pt, auto),
              column-gutter: 4pt,
              rect(width: 7pt, height: 7pt, fill: rgb(entry.at("color"))),
              text(size: 8pt, entry.at("label")),
            )),
          ),
        ),
      )
    }

    #if color-bar != none {
      let stops = _palette-stops(color-bar.at("colormap"))
      let bar-width = stops.len() * 9pt
      let palette = grid(
        columns: stops.map(_ => 9pt),
        ..stops.map(color => rect(width: 9pt, height: 6pt, fill: rgb(color))),
      )
      let labeled-palette = if color-bar.at("label") == none {
        palette
      } else {
        stack(
          dir: ttb,
          spacing: color-bar.at("label-gap", default: 4pt),
          text(size: 8pt, color-bar.at("label")),
          palette,
        )
      }
      place(
        color-bar.at("position"),
        dx: _overlay-dx(color-bar.at("position"), color-bar.at("inset")),
        dy: _overlay-dy(color-bar.at("position"), color-bar.at("inset")),
        block(
          inset: 4pt,
          fill: white.transparentize(8%),
          stroke: 0.4pt + luma(70%),
          radius: 2pt,
          stack(
            dir: ttb,
            spacing: 2pt,
            labeled-palette,
            grid(
              columns: (bar-width / 2, bar-width / 2),
              align(left, text(size: 7pt, str(color-bar.at("min")))),
              align(right, text(size: 7pt, str(color-bar.at("max")))),
            ),
          ),
        ),
      )
    }

    #if scale-bar != none {
      let value = _positive("scale-bar.value", scale-bar.at("value"))
      let bar-width = width * value * document.at("pixels_per_unit") / canvas-width
      let bar-label = if scale-bar.at("label") == none {
        str(value) + " " + _display-unit(cell.at("units"))
      } else {
        scale-bar.at("label")
      }
      place(
        bottom + left,
        dx: scale-bar.at("inset"),
        dy: -scale-bar.at("inset"),
        stack(
          dir: ttb,
          spacing: 2pt,
          line(length: bar-width, stroke: scale-bar.at("stroke")),
          align(center, text(size: 8pt, bar-label)),
        ),
      )
    }
  ]
  let render-result = (
    body: native-body,
    width: width,
    height: height,
    canvas-width: canvas-width,
    canvas-height: canvas-height,
    node-anchors: node-anchors,
    report: document.at("report"),
    pixels-per-unit: document.at("pixels_per_unit"),
    source-node-count: document.at("source_node_count"),
    rendered-node-count: document.at("rendered_node_count"),
  )
  let body = if cetz-labels == () {
    native-body
  } else {
    cetz-annotate(
      render-result,
      cetz: cetz,
      labels: cetz-labels,
      strict: strict-node-ids,
    )
  }
  if return-report { render-result + (body: body,) } else { body }
}

/// Functional public API dictionary for selective imports. Prefer importing the
/// package itself as a module (`#import "..." as swc`) so `swc.analyze(cell)` is
/// directly callable. Dictionary-stored functions require `(swc.analyze)(cell)`.
///
/// -> dictionary
#let swc = (
  load: load,
  from-text: from-text,
  diagnostics: diagnostics,
  metadata: metadata,
  analyze: analyze,
  sholl: sholl,
  sholl-2d: sholl-2d,
  select-nodes: select-nodes,
  select-kinds: select-kinds,
  subtree: subtree,
  path: path,
  reroot: reroot,
  prune: prune,
  simplify: simplify,
  resample: resample,
  export-swc: export-swc,
  label: label,
  marker: marker,
  cetz-label: cetz-label,
  legend: legend,
  color-bar: color-bar,
  scale-bar: scale-bar,
  node-anchor: node-anchor,
  cetz-annotate: cetz-annotate,
  render: render,
  version: version,
)
