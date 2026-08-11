// Private Typst<->WASM seam for the tree backend.
#let _tree-backend = plugin("tree.wasm")

/// Private: Converts a Typst-native layout-kind value to the Rust wire format.
///
/// - layout-kind (str): Typst-native layout kind.
/// -> str
#let _tree-layout-kind-to-backend(layout-kind) = {
  if layout-kind == "equal-angle" {
    "equal_angle"
  } else {
    layout-kind
  }
}

/// Private: Serializes a Typst point dictionary to the Rust pt-based wire form.
///
/// - point (dictionary): Point with length-valued `x` / `y`.
/// -> dictionary
#let _point-to-pt-json(point) = (
  x: point.x / 1pt,
  y: point.y / 1pt,
)

/// Private: Decodes a Rust pt-based wire point to a Typst point dictionary.
///
/// - point (dictionary): Point with numeric `x` / `y` in pt units.
/// -> dictionary
#let _pt-json-to-point(point) = (
  x: point.x * 1pt,
  y: point.y * 1pt,
)

/// Private: Decodes a Rust pt-based bounds dictionary to Typst lengths.
///
/// - bounds (dictionary): Bounds with numeric pt-valued fields.
/// -> dictionary
#let _pt-json-to-bounds(bounds) = (
  min-x: bounds.min_x * 1pt,
  min-y: bounds.min_y * 1pt,
  max-x: bounds.max_x * 1pt,
  max-y: bounds.max_y * 1pt,
  width: bounds.width * 1pt,
  height: bounds.height * 1pt,
)

/// Private: Encodes one prepared line for the Rust fit request.
///
/// - primitive (dictionary): Typst-native prepared line.
/// -> dictionary
#let _encode-fit-line(primitive) = (
  start_anchor: (
    tree: (
      x: primitive.start-anchor.tree.x,
      y: primitive.start-anchor.tree.y,
    ),
    page: _point-to-pt-json(primitive.start-anchor.page),
  ),
  end_anchor: (
    tree: (
      x: primitive.end-anchor.tree.x,
      y: primitive.end-anchor.tree.y,
    ),
    page: _point-to-pt-json(primitive.end-anchor.page),
  ),
  half_stroke_pt: primitive.half-stroke / 1pt,
)

/// Private: Encodes one prepared label for the Rust fit request.
///
/// - primitive (dictionary): Typst-native prepared label.
/// -> dictionary
#let _encode-fit-label(primitive) = (
  anchor_tree: (
    x: primitive.anchor-tree.x,
    y: primitive.anchor-tree.y,
  ),
  anchor_page: _point-to-pt-json(primitive.anchor-page),
  x_align: primitive.x-align,
  y_align: primitive.y-align,
  x_gap_pt: primitive.x-gap / 1pt,
  y_gap_pt: primitive.y-gap / 1pt,
  rotation_deg: primitive.rotation / 1deg,
  placement_frame: primitive.placement-frame,
  branch_angle_half_turn: primitive.branch-angle-half-turn,
  placement_angle_half_turn: primitive.placement-angle-half-turn,
  measure_width_pt: primitive.measure-width / 1pt,
  measure_height_pt: primitive.measure-height / 1pt,
)

/// Private: Converts an optional length to pt-based JSON.
///
/// - value (length, none): Length to convert.
/// -> float, none
#let _optional-to-pt(value) = if value == none { none } else { value / 1pt }

/// Private: Encodes a Typst-native fit payload for the Rust wire schema.
///
/// - payload (dictionary): Typst-native fit payload.
/// -> dictionary
#let _encode-tree-fit-request(payload) = (
  fit_mode: if payload.fit-mode == "independent-axes" {
    "independent_axes"
  } else {
    payload.fit-mode
  },
  layout_kind: _tree-layout-kind-to-backend(payload.layout-kind),
  orientation: payload.orientation,
  prepared_lines: payload.prepared-lines.map(_encode-fit-line),
  prepared_labels: payload.prepared-labels.map(_encode-fit-label),
  root_tree_point: (
    x: payload.root-tree-point.x,
    y: payload.root-tree-point.y,
  ),
  tree_depth: payload.tree-depth,
  tree_height: payload.tree-height,
  width_mode: payload.width-mode,
  viewport_width_pt: _optional-to-pt(payload.viewport-width),
  height_mode: payload.height-mode,
  viewport_height_pt: _optional-to-pt(payload.viewport-height),
  auto_height_floor_pt: payload.auto-height-floor / 1pt,
  fit_band_samples: payload.fit-band-samples,
  fit_max_bands: payload.fit-max-bands,
  optimize_uniform_rotation: payload.optimize-uniform-rotation,
)

/// Private: Decodes a Rust fit response to the Typst-native structure.
///
/// - response (dictionary): Raw fit response decoded from JSON.
/// -> dictionary
#let _decode-tree-fit-response(response) = (
  width-unresolved: response.width_unresolved,
  tree-viewport-width: response.tree_viewport_width_pt * 1pt,
  tree-viewport-height: response.tree_viewport_height_pt * 1pt,
  x-scale: response.x_scale_pt * 1pt,
  y-scale: response.y_scale_pt * 1pt,
  tree-translation: _pt-json-to-point(response.tree_translation_pt),
  tree-occupied-bounds: _pt-json-to-bounds(response.tree_occupied_bounds_pt),
  root-position: _pt-json-to-point(response.root_position_pt),
  tree-lines: response.tree_lines.map(entry => (
    line-index: entry.line_index,
    start: _pt-json-to-point(entry.start_pt),
    end: _pt-json-to-point(entry.end_pt),
  )),
  tree-labels: response.tree_labels.map(entry => (
    label-index: entry.label_index,
    origin: _pt-json-to-point(entry.origin_pt),
    rotation: entry.rotation_deg * 1deg,
  )),
)

/// Private: Parses a Newick string through the tree WASM plugin.
///
/// - data (str): Raw Newick source.
/// -> dictionary
#let _tree-parse-newick(data) = {
  let result = _tree-backend.parse_newick(bytes(data.trim()))
  json(result)
}

/// Private: Prepares a normalized tree layout through the tree WASM plugin.
///
/// - tree-data (dictionary): Parsed or manual tree data.
/// - cladogram (bool): Whether cladogram mode is enabled.
/// - suppress-unrooted (bool): Whether the backend should suppress an
///   artificial rooted binary handle.
/// - hide-internal-labels (bool): Whether internal node labels are omitted
///   from the prepared layout output.
/// - layout-kind (str): Typst-native layout kind.
/// -> dictionary
#let _tree-prepare-layout-backend(
  tree-data,
  cladogram: false,
  suppress-unrooted: false,
  hide-internal-labels: false,
  layout-kind: "rectangular",
) = {
  let result = _tree-backend.prepare_layout(bytes(json.encode((
    tree-data: tree-data,
    cladogram: cladogram,
    suppress-unrooted: suppress-unrooted,
    hide-internal-labels: hide-internal-labels,
    layout-kind: _tree-layout-kind-to-backend(layout-kind),
  ))))
  let decoded = json(result)
  decoded.insert(
    "layout-kind",
    if decoded.layout-kind == "equal_angle" {
      "equal-angle"
    } else {
      decoded.layout-kind
    },
  )
  decoded
}

/// Private: Fits a Typst-native tree payload through the tree WASM plugin.
///
/// - payload (dictionary): Typst-native fit payload with length-valued fields.
/// -> dictionary
#let _tree-fit(payload) = {
  let result = _tree-backend.fit_tree(bytes(json.encode(
    _encode-tree-fit-request(payload),
  )))
  _decode-tree-fit-response(json(result))
}
