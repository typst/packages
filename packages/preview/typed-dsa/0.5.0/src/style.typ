// Shared visual defaults for every diagram in the package.
//
// One dict so node sizing, palette, and strokes stay consistent across trees
// and linear structures. Every builder takes a `style:` dict that is merged
// over these defaults with `resolve`, so colors, size, and shape can be
// overridden per call or, via `.with(style: ...)`, document-wide.
//
// This module also owns the schemas for every customization dictionary the
// package accepts, since a customization is resolved into the same drawing
// properties a style key sets. `validate-style` runs at the public boundary;
// `resolve` then assumes a valid dictionary.

#import "validate.typ": (
  check-bool, check-dictionary, check-enum, check-known-keys, check-non-negative,
  check-number, check-positive, check-type, fail, is-number, show-value,
)

#let theme = (
  // Trees
  node-radius: 0.34,
  node-shape: "circle", // circle, square, rounded, capsule, diamond, or hexagon
  x-gap: 1.05,
  y-gap: 1.2,
  node-stroke: 0.6pt + rgb("#333333"),
  node-fill: white,
  edge-stroke: 0.6pt + rgb("#333333"),
  edge-arrow: none, // edge arrowheads: none/false, "end" (or true), "start", "both"
  edge-arrow-fill: none, // graph() directed arrowheads: none (open) or a fill color (solid)
  edge-pattern: "normal", // "normal", "dashed", "dotted", or "wavy"
  edge-wave-amplitude: 0.07,
  edge-wave-step: 0.14,

  // Subtree triangles
  tri-w: 1.2,
  tri-h: 1.4,

  // Linear structures
  box-w: 0.95,
  box-h: 0.7,
  box-shape: "square", // square, rounded, or capsule
  box-gap: 0.55,
  box-stroke: 0.6pt + rgb("#333333"),
  box-fill: white,
  ptr-fill: rgb("#D7ECC9"), // next-pointer cell in the linked-list pointer style
  prev-ptr-fill: rgb("#D7ECC9"), // previous-pointer cell in doubly-linked-list(pointer: true)
  next-ptr-fill: rgb("#D7ECC9"), // next-pointer cell in doubly-linked-list(pointer: true)

  // Shared
  node-text: (size: 9pt),
  value-text: (:), // inherits node-text
  label-text: (color: rgb("#555555")), // annotations: head, front/rear, addresses; inherits size from node-text
  index-text: (size: 7.5pt), // inherits label-text
  pointer-text: (:), // inherits label-text
  operation-text: (size: 8pt), // transition arrow captions
  edge-label-text: (:), // inherits label-text
  algorithm-label-text: (size: 8pt), // sorting and graph trace captions
  scale: 1.0, // uniform scale applied to the whole rendered diagram
  diff-colors: true, // false keeps operation marks but uses the normal fill

  // Diff highlight styles, used by operation transitions. Each is a plain
  // color (shorthand for `(fill: color)`) or a dict of `fill:`, `shape:`,
  // `stroke:`, `node-radius:`, and `text:` overrides for a marked node/cell.
  new-style: rgb("#C8E6C9"),     // node added by the operation
  path-style: rgb("#FFE9A8"),    // nodes on the traversal path
  remove-style: rgb("#FFCDD2"),  // node removed by the operation
  rotate-style: rgb("#BBDEFB"),  // pivot of an AVL rotation

  // Graph-algorithm state roles.
  visited-style: (fill: rgb("#C8E6C9"), stroke: 1pt + rgb("#2E7D32")),
  current-style: (fill: rgb("#BBDEFB"), stroke: 1pt + rgb("#1565C0")),
  queued-style: (fill: rgb("#FFE9A8"), stroke: 1pt + rgb("#F08C00")),
  active-edge-style: (stroke: 2pt + rgb("#1971C2")),
)

// Sparse presets are passed through `style:` and keep the default sizing and
// layout. `theme` remains the default dictionary for backwards compatibility.
#let themes = (
  "default": (:),
  "dark": (
    node-fill: rgb("#20242B"), node-stroke: 0.8pt + rgb("#E9ECEF"),
    edge-stroke: 0.8pt + rgb("#CED4DA"), box-fill: rgb("#20242B"),
    box-stroke: 0.8pt + rgb("#E9ECEF"), ptr-fill: rgb("#364152"),
    prev-ptr-fill: rgb("#364152"), next-ptr-fill: rgb("#364152"),
    node-text: (fill: rgb("#F8F9FA")), label-text: (fill: rgb("#CED4DA")),
  ),
  "print": (
    node-fill: white, node-stroke: 0.9pt + black, edge-stroke: 0.9pt + black,
    box-fill: white, box-stroke: 0.9pt + black, ptr-fill: luma(225),
    prev-ptr-fill: luma(225), next-ptr-fill: luma(225),
    label-text: (fill: black), diff-colors: false,
  ),
  "colorblind": (
    new-style: rgb("#009E73"), path-style: rgb("#F0E442"),
    remove-style: rgb("#D55E00"), rotate-style: rgb("#56B4E9"),
    visited-style: (fill: rgb("#009E73").lighten(65%), stroke: 1pt + rgb("#007A5A")),
    current-style: (fill: rgb("#56B4E9").lighten(55%), stroke: 1pt + rgb("#0072B2")),
    queued-style: (fill: rgb("#F0E442").lighten(45%), stroke: 1pt + rgb("#B28B00")),
    active-edge-style: (stroke: 2pt + rgb("#CC79A7")),
  ),
  "chalkboard": (
    node-fill: rgb("#254B3C"), node-stroke: 1pt + rgb("#173C30"),
    edge-stroke: 1pt + rgb("#254B3C"), box-fill: rgb("#254B3C"),
    box-stroke: 1pt + rgb("#173C30"), ptr-fill: rgb("#315F4D"),
    prev-ptr-fill: rgb("#315F4D"), next-ptr-fill: rgb("#315F4D"),
    node-text: (fill: white), label-text: (fill: rgb("#254B3C")),
  ),
)

#let theme-preset(name) = {
  check-enum("theme-preset()", "theme name", name, themes.keys())
  themes.at(name)
}

// ── Style and customization schemas ──────────────────────────────────────────
//
// One place naming every key the package understands, so a typo in a style
// dictionary or a customization option is reported instead of silently
// dropped. Each list is also the "accepted values" text of its diagnostic.

#let node-shapes = ("circle", "square", "rounded", "capsule", "diamond", "hexagon")
#let box-shapes = ("square", "rounded", "capsule")
#let edge-patterns = (
  "normal", "solid", "dashed", "dotted", "wavy", "wave", "dash", "dot", "dots",
)
#let edge-arrows = (none, false, true, "start", "end", "both")
// `true` is the shorthand spelling of `"right"` that the bend renderer has
// always accepted.
#let bend-directions = (none, false, true, "left", "right")
#let label-positions = ("left", "right", "top", "bottom")

// Typography roles all accept the same `text()` parameters, plus the `color`
// alias `resolve` folds into `fill`.
#let text-style-keys = (
  "size", "color", "fill", "font", "weight", "style", "rotation", "tracking",
  "spacing", "baseline", "stretch", "features", "fallback", "lang", "region",
  "dir", "hyphenate", "number-type", "number-width", "slashed-zero",
  "top-edge", "bottom-edge",
)

#let text-style-roles = (
  "node-text", "value-text", "label-text", "index-text", "pointer-text",
  "operation-text", "edge-label-text", "algorithm-label-text",
)

#let mark-style-roles = (
  "new-style", "path-style", "remove-style", "rotate-style",
  "visited-style", "current-style", "queued-style", "active-edge-style",
)

#let mark-style-keys = ("fill", "shape", "stroke", "node-radius", "text", "stripe-fill")
#let node-customization-keys = ("shape", "fill", "stroke", "node-radius", "text")
#let edge-customization-keys = (
  "stroke", "color", "pattern", "dash", "wave", "arrow", "bend", "angle", "label",
)
#let cell-customization-keys = ("fill", "stroke", "text", "stripe-fill")
#let node-label-keys = ("content", "body", "position", "offset", "gap") + text-style-keys
#let indices-keys = ("enabled", "labels", "offset", "text") + text-style-keys

#let _positive-style-keys = (
  "node-radius", "x-gap", "y-gap", "tri-w", "tri-h", "box-w", "box-h",
  "scale", "edge-wave-step",
)
#let _non-negative-style-keys = ("box-gap", "edge-wave-amplitude")
#let _fill-style-keys = (
  "node-fill", "box-fill", "ptr-fill", "prev-ptr-fill", "next-ptr-fill",
  "edge-arrow-fill",
)
#let _stroke-style-keys = ("node-stroke", "edge-stroke", "box-stroke")

// `edge-dash` and `edge-wave` are legacy spellings `_resolve-edge-pattern`
// still honours; `node-labels` and `indices` are sub-dictionaries with their
// own schema rather than plain theme defaults.
#let style-keys = theme.keys() + ("node-labels", "indices", "edge-dash", "edge-wave")

#let _fill-types = (color, gradient, tiling, type(none))
#let _stroke-types = (stroke, length, color, gradient, dictionary, type(none))

#let check-text-style(where, what, value) = {
  check-known-keys(where, what, value, text-style-keys)
}

#let check-fill(where, what, value) = check-type(
  where, what, value, _fill-types,
  fix: "pass a color, for example " + what + ": rgb(\"#C8E6C9\")",
)

#let check-stroke(where, what, value) = check-type(
  where, what, value, _stroke-types,
  fix: "pass a stroke, for example " + what + ": 1pt + black",
)

// A highlight role is either a plain color (shorthand for `(fill: color)`) or
// a dictionary of drawing overrides for the marked node or cell.
#let check-mark-style(where, what, value) = {
  if type(value) in (color, gradient, tiling) { return }
  if type(value) != dictionary {
    fail(
      where,
      what + " is " + show-value(value),
      expected: "a color, or a dictionary of " + mark-style-keys.map(key => "\"" + key + "\"").join(", "),
      fix: "pass a color, or build one with node-mark-style(...) / cell-mark-style(...)",
    )
  }
  check-known-keys(where, what, value, mark-style-keys)
  if "fill" in value { check-fill(where, what + ".fill", value.fill) }
  if "stroke" in value { check-stroke(where, what + ".stroke", value.stroke) }
  if "shape" in value { check-enum(where, what + ".shape", value.shape, node-shapes) }
  if "node-radius" in value { check-positive(where, what + ".node-radius", value.node-radius) }
  if "text" in value { check-text-style(where, what + ".text", value.text) }
}

#let check-label-position(where, what, value) = {
  if type(value) == angle { return }
  check-enum(
    where, what, value, label-positions,
    fix: "use a side name or an angle, for example " + what + ": 45deg",
  )
}

// An `(x, y)` pair in diagram units, used by label offsets and graph positions.
#let check-coordinate-pair(where, what, value) = {
  let is-pair = type(value) == array and value.len() == 2
  if not is-pair {
    fail(
      where,
      what + " is " + show-value(value),
      expected: "an (x, y) pair of numbers",
      fix: "write it as " + what + ": (0, 0)",
    )
  }
  for (axis-index, component) in value.enumerate() {
    if not is-number(component) {
      fail(
        where,
        what + " component " + str(axis-index) + " is " + show-value(component),
        expected: "a number",
      )
    }
  }
}

#let check-node-label-defaults(where, what, value) = {
  check-known-keys(where, what, value, node-label-keys + ("enabled",))
  if "position" in value { check-label-position(where, what + ".position", value.position) }
  if "offset" in value { check-coordinate-pair(where, what + ".offset", value.offset) }
  if "gap" in value { check-number(where, what + ".gap", value.gap) }
}

#let check-indices(where, what, value) = {
  if value in (true, false, none) { return }
  check-dictionary(
    where, what, value,
    fix: "pass true/false, or a dictionary built with indices-style(...)",
  )
  check-known-keys(where, what, value, indices-keys)
  if "enabled" in value { check-bool(where, what + ".enabled", value.enabled) }
  if "offset" in value { check-coordinate-pair(where, what + ".offset", value.offset) }
  if "labels" in value and value.labels != auto {
    check-type(
      where, what + ".labels", value.labels, (array,),
      fix: "pass auto, or one label per cell",
    )
  }
}

#let _check-edge-pattern(where, what, value) = {
  if type(value) == str { return check-enum(where, what, value, edge-patterns) }
  check-type(
    where, what, value, (array, type(none), bool),
    fix: "use a pattern name, or a dash array such as (2pt, 2pt)",
  )
}

// An edge label is either content or a dictionary carrying that content plus
// typography overrides, so both spellings are checked the same way. A graph
// edge may already carry a label from its adjacency entry, so there a
// content-less dictionary legitimately means "restyle the existing label".
#let check-label-override(where, what, value, require-content: false) = {
  if type(value) != dictionary { return }
  check-known-keys(where, what, value, ("content", "body") + text-style-keys)
  if not require-content { return }
  let has-body = "content" in value or "body" in value
  if not has-body {
    fail(
      where,
      what + " sets label typography but no label content, so nothing would be drawn",
      expected: "a \"content\" (or \"body\") entry",
      fix: "write it as " + what + ": (content: [w], color: blue)",
    )
  }
}

// Shared by tree and graph edges: both resolve the same option dictionary.
#let check-edge-customization-options(where, what, options, require-label-content: false) = {
  check-known-keys(where, what, options, edge-customization-keys)
  if "stroke" in options { check-stroke(where, what + ".stroke", options.stroke) }
  if "color" in options { check-fill(where, what + ".color", options.color) }
  if "arrow" in options { check-enum(where, what + ".arrow", options.arrow, edge-arrows) }
  if "bend" in options { check-enum(where, what + ".bend", options.bend, bend-directions) }
  if "wave" in options { check-bool(where, what + ".wave", options.wave) }
  if "pattern" in options { _check-edge-pattern(where, what + ".pattern", options.pattern) }
  if "dash" in options { _check-edge-pattern(where, what + ".dash", options.dash) }
  if "angle" in options {
    check-type(
      where, what + ".angle", options.angle, (angle,),
      fix: "pass an angle, for example angle: 25deg",
    )
  }
  if "label" in options {
    check-label-override(
      where, what + ".label", options.label,
      require-content: require-label-content,
    )
  }
}

#let check-node-customization-options(where, what, options) = {
  check-known-keys(where, what, options, node-customization-keys)
  if "shape" in options { check-enum(where, what + ".shape", options.shape, node-shapes) }
  if "fill" in options { check-fill(where, what + ".fill", options.fill) }
  if "stroke" in options { check-stroke(where, what + ".stroke", options.stroke) }
  if "node-radius" in options { check-positive(where, what + ".node-radius", options.node-radius) }
  if "text" in options { check-text-style(where, what + ".text", options.text) }
}

#let check-cell-customization-options(where, what, options) = {
  check-known-keys(where, what, options, cell-customization-keys)
  if "fill" in options { check-fill(where, what + ".fill", options.fill) }
  if "stroke" in options { check-stroke(where, what + ".stroke", options.stroke) }
  if "stripe-fill" in options { check-fill(where, what + ".stripe-fill", options.stripe-fill) }
  if "text" in options { check-text-style(where, what + ".text", options.text) }
}

// A per-node annotation: content, or that content plus placement overrides.
#let check-node-label-override(where, what, value) = {
  if type(value) != dictionary { return }
  check-known-keys(where, what, value, node-label-keys)
  if "position" in value { check-label-position(where, what + ".position", value.position) }
  if "offset" in value { check-coordinate-pair(where, what + ".offset", value.offset) }
  if "gap" in value { check-number(where, what + ".gap", value.gap) }
}

#let _check-style-entry(where, key, value) = {
  let what = "style." + key
  if key in _positive-style-keys { return check-positive(where, what, value) }
  if key in _non-negative-style-keys { return check-non-negative(where, what, value) }
  if key in _fill-style-keys { return check-fill(where, what, value) }
  if key in _stroke-style-keys { return check-stroke(where, what, value) }
  if key in text-style-roles { return check-text-style(where, what, value) }
  if key in mark-style-roles { return check-mark-style(where, what, value) }
  if key == "node-shape" { return check-enum(where, what, value, node-shapes) }
  if key == "box-shape" { return check-enum(where, what, value, box-shapes) }
  if key == "edge-arrow" { return check-enum(where, what, value, edge-arrows) }
  if key == "diff-colors" { return check-bool(where, what, value) }
  if key == "node-labels" { return check-node-label-defaults(where, what, value) }
  if key == "indices" { return check-indices(where, what, value) }
  if key in ("edge-pattern", "edge-dash") {
    if type(value) == str { return check-enum(where, what, value, edge-patterns) }
    return check-type(
      where, what, value, (array, type(none), bool),
      fix: "use a pattern name, or a dash array such as (2pt, 2pt)",
    )
  }
  if key == "edge-wave" { return check-bool(where, what, value) }
}

// The single entry point every public builder calls before touching `style:`.
#let validate-style(where, style) = {
  check-dictionary(
    where, "style:", style,
    fix: "pass a dictionary, for example style: (node-radius: 0.4)",
  )
  check-known-keys(where, "style:", style, style-keys)
  for (key, value) in style {
    _check-style-entry(where, key, value)
  }
}

// Named-argument style builders provide editor completion while returning the
// same sparse dictionaries accepted by every public `style:` argument.
#let text-style(
  size: auto,
  color: auto,
  fill: auto,
  font: auto,
  weight: auto,
  rotation: auto,
) = {
  let result = (:)
  if size != auto { result.size = size }
  if color != auto { result.color = color }
  if fill != auto { result.fill = fill }
  if font != auto { result.font = font }
  if weight != auto { result.weight = weight }
  if rotation != auto { result.rotation = rotation }
  result
}

#let label-style(
  size: auto,
  color: auto,
  fill: auto,
  font: auto,
  weight: auto,
  rotation: auto,
) = text-style(
  size: size,
  color: color,
  fill: fill,
  font: font,
  weight: weight,
  rotation: rotation,
)

#let node-mark-style(
  fill: auto,
  shape: auto,
  stroke: auto,
  node-radius: auto,
  text: auto,
) = {
  let result = (:)
  if fill != auto { result.fill = fill }
  if shape != auto { result.shape = shape }
  if stroke != auto { result.stroke = stroke }
  if node-radius != auto { result.node-radius = node-radius }
  if text != auto { result.text = text }
  result
}

#let cell-mark-style(
  fill: auto,
  stroke: auto,
  text: auto,
) = {
  let result = (:)
  if fill != auto { result.fill = fill }
  if stroke != auto { result.stroke = stroke }
  if text != auto { result.text = text }
  result
}

#let node-label-style(
  position: auto,
  offset: auto,
  gap: auto,
  size: auto,
  color: auto,
  font: auto,
  weight: auto,
  rotation: auto,
) = {
  let result = label-style(size: size, color: color, font: font, weight: weight, rotation: rotation)
  if position != auto { result.position = position }
  if offset != auto { result.offset = offset }
  if gap != auto { result.gap = gap }
  result
}

#let indices-style(
  enabled: auto,
  labels: none,
  offset: auto,
  size: auto,
  color: auto,
  font: auto,
  weight: auto,
) = {
  let result = label-style(size: size, color: color, font: font, weight: weight)
  if enabled != auto { result.enabled = enabled }
  if labels != none { result.labels = labels }
  if offset != auto { result.offset = offset }
  result
}

#let _build-style-dictionary(
  node-radius: auto,
  node-shape: auto,
  x-gap: auto,
  y-gap: auto,
  node-stroke: auto,
  node-fill: auto,
  edge-stroke: auto,
  edge-arrow: auto,
  edge-arrow-fill: auto,
  edge-pattern: auto,
  edge-wave-amplitude: auto,
  edge-wave-step: auto,
  tri-w: auto,
  tri-h: auto,
  box-w: auto,
  box-h: auto,
  box-shape: auto,
  box-gap: auto,
  box-stroke: auto,
  box-fill: auto,
  ptr-fill: auto,
  prev-ptr-fill: auto,
  next-ptr-fill: auto,
  node-text: auto,
  value-text: auto,
  label-text: auto,
  index-text: auto,
  pointer-text: auto,
  operation-text: auto,
  edge-label-text: auto,
  algorithm-label-text: auto,
  node-labels: auto,
  indices: auto,
  scale: auto,
  diff-colors: auto,
  new-style: auto,
  path-style: auto,
  remove-style: auto,
  rotate-style: auto,
  visited-style: auto,
  current-style: auto,
  queued-style: auto,
  active-edge-style: auto,
) = {
  let result = (:)
  if node-radius != auto { result.node-radius = node-radius }
  if node-shape != auto { result.node-shape = node-shape }
  if x-gap != auto { result.x-gap = x-gap }
  if y-gap != auto { result.y-gap = y-gap }
  if node-stroke != auto { result.node-stroke = node-stroke }
  if node-fill != auto { result.node-fill = node-fill }
  if edge-stroke != auto { result.edge-stroke = edge-stroke }
  if edge-arrow != auto { result.edge-arrow = edge-arrow }
  if edge-arrow-fill != auto { result.edge-arrow-fill = edge-arrow-fill }
  if edge-pattern != auto { result.edge-pattern = edge-pattern }
  if edge-wave-amplitude != auto { result.edge-wave-amplitude = edge-wave-amplitude }
  if edge-wave-step != auto { result.edge-wave-step = edge-wave-step }
  if tri-w != auto { result.tri-w = tri-w }
  if tri-h != auto { result.tri-h = tri-h }
  if box-w != auto { result.box-w = box-w }
  if box-h != auto { result.box-h = box-h }
  if box-shape != auto { result.box-shape = box-shape }
  if box-gap != auto { result.box-gap = box-gap }
  if box-stroke != auto { result.box-stroke = box-stroke }
  if box-fill != auto { result.box-fill = box-fill }
  if ptr-fill != auto { result.ptr-fill = ptr-fill }
  if prev-ptr-fill != auto { result.prev-ptr-fill = prev-ptr-fill }
  if next-ptr-fill != auto { result.next-ptr-fill = next-ptr-fill }
  if node-text != auto { result.node-text = node-text }
  if value-text != auto { result.value-text = value-text }
  if label-text != auto { result.label-text = label-text }
  if index-text != auto { result.index-text = index-text }
  if pointer-text != auto { result.pointer-text = pointer-text }
  if operation-text != auto { result.operation-text = operation-text }
  if edge-label-text != auto { result.edge-label-text = edge-label-text }
  if algorithm-label-text != auto { result.algorithm-label-text = algorithm-label-text }
  if node-labels != auto { result.node-labels = node-labels }
  if indices != auto { result.indices = indices }
  if scale != auto { result.scale = scale }
  if diff-colors != auto { result.diff-colors = diff-colors }
  if new-style != auto { result.new-style = new-style }
  if path-style != auto { result.path-style = path-style }
  if remove-style != auto { result.remove-style = remove-style }
  if rotate-style != auto { result.rotate-style = rotate-style }
  if visited-style != auto { result.visited-style = visited-style }
  if current-style != auto { result.current-style = current-style }
  if queued-style != auto { result.queued-style = queued-style }
  if active-edge-style != auto { result.active-edge-style = active-edge-style }
  result
}

#let tree-style(
  node-radius: auto, node-shape: auto, x-gap: auto, y-gap: auto,
  node-stroke: auto, node-fill: auto, edge-stroke: auto,
  edge-arrow: auto, edge-arrow-fill: auto, edge-pattern: auto,
  edge-wave-amplitude: auto, edge-wave-step: auto,
  tri-w: auto, tri-h: auto, node-text: auto, value-text: auto, label-text: auto,
  index-text: auto, pointer-text: auto, operation-text: auto,
  edge-label-text: auto, algorithm-label-text: auto,
  node-labels: auto, scale: auto, diff-colors: auto,
  new-style: auto, path-style: auto, remove-style: auto, rotate-style: auto,
  visited-style: auto, current-style: auto, queued-style: auto, active-edge-style: auto,
) = _build-style-dictionary(
  node-radius: node-radius, node-shape: node-shape, x-gap: x-gap, y-gap: y-gap,
  node-stroke: node-stroke, node-fill: node-fill, edge-stroke: edge-stroke,
  edge-arrow: edge-arrow, edge-arrow-fill: edge-arrow-fill, edge-pattern: edge-pattern,
  edge-wave-amplitude: edge-wave-amplitude, edge-wave-step: edge-wave-step,
  tri-w: tri-w, tri-h: tri-h, node-text: node-text, value-text: value-text, label-text: label-text,
  index-text: index-text, pointer-text: pointer-text, operation-text: operation-text,
  edge-label-text: edge-label-text, algorithm-label-text: algorithm-label-text,
  node-labels: node-labels, scale: scale, diff-colors: diff-colors,
  new-style: new-style, path-style: path-style,
  remove-style: remove-style, rotate-style: rotate-style,
  visited-style: visited-style, current-style: current-style,
  queued-style: queued-style, active-edge-style: active-edge-style,
)

#let heap-style(
  node-radius: auto, node-shape: auto, x-gap: auto, y-gap: auto,
  node-stroke: auto, node-fill: auto, edge-stroke: auto,
  edge-arrow: auto, edge-arrow-fill: auto, edge-pattern: auto,
  edge-wave-amplitude: auto, edge-wave-step: auto,
  node-text: auto, value-text: auto, label-text: auto, operation-text: auto,
  edge-label-text: auto, scale: auto, diff-colors: auto,
  new-style: auto, path-style: auto, remove-style: auto,
) = _build-style-dictionary(
  node-radius: node-radius, node-shape: node-shape, x-gap: x-gap, y-gap: y-gap,
  node-stroke: node-stroke, node-fill: node-fill, edge-stroke: edge-stroke,
  edge-arrow: edge-arrow, edge-arrow-fill: edge-arrow-fill, edge-pattern: edge-pattern,
  edge-wave-amplitude: edge-wave-amplitude, edge-wave-step: edge-wave-step,
  node-text: node-text, value-text: value-text, label-text: label-text,
  operation-text: operation-text, edge-label-text: edge-label-text,
  scale: scale, diff-colors: diff-colors,
  new-style: new-style, path-style: path-style, remove-style: remove-style,
)

#let graph-style(
  node-radius: auto, node-shape: auto, node-stroke: auto, node-fill: auto,
  edge-stroke: auto, edge-arrow: auto, edge-arrow-fill: auto, edge-pattern: auto,
  edge-wave-amplitude: auto, edge-wave-step: auto,
  node-text: auto, value-text: auto, label-text: auto, edge-label-text: auto,
  algorithm-label-text: auto, node-labels: auto, scale: auto,
  visited-style: auto, current-style: auto, queued-style: auto, active-edge-style: auto,
) = _build-style-dictionary(
  node-radius: node-radius, node-shape: node-shape,
  node-stroke: node-stroke, node-fill: node-fill, edge-stroke: edge-stroke,
  edge-arrow: edge-arrow, edge-arrow-fill: edge-arrow-fill, edge-pattern: edge-pattern,
  edge-wave-amplitude: edge-wave-amplitude, edge-wave-step: edge-wave-step,
  node-text: node-text, value-text: value-text, label-text: label-text,
  edge-label-text: edge-label-text, algorithm-label-text: algorithm-label-text,
  node-labels: node-labels, scale: scale,
  visited-style: visited-style, current-style: current-style,
  queued-style: queued-style, active-edge-style: active-edge-style,
)

#let list-style(
  box-w: auto, box-h: auto, box-shape: auto, box-gap: auto, box-stroke: auto, box-fill: auto,
  ptr-fill: auto, prev-ptr-fill: auto, next-ptr-fill: auto,
  node-text: auto, value-text: auto, label-text: auto, pointer-text: auto,
  operation-text: auto, scale: auto, diff-colors: auto,
  new-style: auto, path-style: auto, remove-style: auto,
) = _build-style-dictionary(
  box-w: box-w, box-h: box-h, box-shape: box-shape, box-gap: box-gap,
  box-stroke: box-stroke, box-fill: box-fill,
  ptr-fill: ptr-fill, prev-ptr-fill: prev-ptr-fill, next-ptr-fill: next-ptr-fill,
  node-text: node-text, value-text: value-text, label-text: label-text,
  pointer-text: pointer-text, operation-text: operation-text,
  scale: scale, diff-colors: diff-colors,
  new-style: new-style, path-style: path-style, remove-style: remove-style,
)

#let stack-style(
  box-w: auto, box-h: auto, box-shape: auto, box-gap: auto, box-stroke: auto, box-fill: auto,
  node-text: auto, value-text: auto, label-text: auto, pointer-text: auto,
  operation-text: auto, scale: auto, diff-colors: auto,
  new-style: auto, remove-style: auto,
) = _build-style-dictionary(
  box-w: box-w, box-h: box-h, box-shape: box-shape, box-gap: box-gap,
  box-stroke: box-stroke, box-fill: box-fill,
  node-text: node-text, value-text: value-text, label-text: label-text,
  pointer-text: pointer-text, operation-text: operation-text,
  scale: scale, diff-colors: diff-colors,
  new-style: new-style, remove-style: remove-style,
)

#let queue-style(
  box-w: auto, box-h: auto, box-shape: auto, box-gap: auto, box-stroke: auto, box-fill: auto,
  node-text: auto, value-text: auto, label-text: auto, pointer-text: auto,
  operation-text: auto, scale: auto, diff-colors: auto,
  new-style: auto, remove-style: auto,
) = stack-style(
  box-w: box-w, box-h: box-h, box-shape: box-shape, box-gap: box-gap,
  box-stroke: box-stroke, box-fill: box-fill,
  node-text: node-text, value-text: value-text, label-text: label-text,
  pointer-text: pointer-text, operation-text: operation-text,
  scale: scale, diff-colors: diff-colors,
  new-style: new-style, remove-style: remove-style,
)

#let array-style(
  box-w: auto, box-h: auto, box-shape: auto, box-stroke: auto, box-fill: auto,
  node-text: auto, value-text: auto, label-text: auto, index-text: auto,
  pointer-text: auto, algorithm-label-text: auto, indices: auto, scale: auto,
) = _build-style-dictionary(
  box-w: box-w, box-h: box-h, box-shape: box-shape, box-stroke: box-stroke, box-fill: box-fill,
  node-text: node-text, value-text: value-text, label-text: label-text,
  index-text: index-text, pointer-text: pointer-text,
  algorithm-label-text: algorithm-label-text, indices: indices, scale: scale,
)

#let matrix-style(
  box-w: auto, box-h: auto, box-shape: auto, box-stroke: auto, box-fill: auto,
  node-text: auto, value-text: auto, label-text: auto, index-text: auto, scale: auto,
) = _build-style-dictionary(
  box-w: box-w, box-h: box-h, box-shape: box-shape, box-stroke: box-stroke, box-fill: box-fill,
  node-text: node-text, value-text: value-text, label-text: label-text,
  index-text: index-text, scale: scale,
)

// Merge a per-call override dict over the defaults.
#let resolve(style) = {
  let resolved-style = theme + style
  if "node-text" in style {
    resolved-style.node-text = theme.node-text + style.node-text
  }

  let label-defaults = theme.label-text
  let label-size-is-unspecified = "size" not in label-defaults and (
    "label-text" not in style or "size" not in style.label-text
  )
  // Annotation text scales from node text unless the theme or caller supplies
  // an explicit label size.
  if label-size-is-unspecified {
    label-defaults.size = (
      resolved-style.node-text.at("size", default: 9pt) * 0.85
    )
  }

  if "label-text" in style {
    resolved-style.label-text = label-defaults + style.label-text
  } else {
    resolved-style.label-text = label-defaults
  }

  resolved-style.value-text = (
    resolved-style.node-text
      + theme.value-text
      + style.at("value-text", default: (:))
  )
  let label-text-roles = (
    "index-text",
    "pointer-text",
    "operation-text",
    "edge-label-text",
    "algorithm-label-text",
  )
  for text-role in label-text-roles {
    resolved-style.insert(
      text-role,
      resolved-style.label-text
        + theme.at(text-role)
        + style.at(text-role, default: (:)),
    )
  }

  if "color" in resolved-style.node-text {
    resolved-style.node-text.fill = resolved-style.node-text.color
    let _ = resolved-style.node-text.remove("color")
  }

  if "color" in resolved-style.label-text {
    resolved-style.label-text.fill = resolved-style.label-text.color
    let _ = resolved-style.label-text.remove("color")
  }
  for text-role in ("value-text",) + label-text-roles {
    let role-style = resolved-style.at(text-role)
    if "color" in role-style {
      role-style.fill = role-style.color
      let _ = role-style.remove("color")
      resolved-style.insert(text-role, role-style)
    }
  }

  resolved-style
}

// Wraps a rendered diagram in the theme's `scale` factor. `reflow: true` so
// surrounding layout (arrows, stacks, tables) sees the resized box instead of
// a visual-only transform that overlaps its neighbors.
#let scaled(th, body) = {
  let resolved-style = th
  if resolved-style.scale == 1.0 {
    body
  } else {
    scale(resolved-style.scale * 100%, reflow: true, body)
  }
}

#let edge-mark(spec, fill: none) = {
  let arrow-specification = spec
  if arrow-specification == "both" { (start: ">", end: ">", fill: fill) }
  else if arrow-specification == "start" { (start: ">", fill: fill) }
  else if arrow-specification == "end" or arrow-specification == true { (end: ">", fill: fill) }
  else { none }
}

#let _apply-dash-to-stroke(stroke, dash) = {
  if dash == none or dash == false { return stroke }
  if type(stroke) == dictionary { return stroke + (dash: dash) }
  if type(stroke) == color { return (paint: stroke, dash: dash) }
  (paint: stroke.paint, thickness: stroke.thickness, dash: dash)
}

#let _resolve-edge-pattern(resolved-style, customization) = {
  if customization != none and "pattern" in customization {
    return customization.pattern
  }
  if customization != none and customization.at("wave", default: false) {
    return "wavy"
  }
  let custom-dash = if customization == none {
    none
  } else {
    customization.at("dash", default: none)
  }
  if custom-dash not in (none, false) { return custom-dash }
  if resolved-style.at("edge-wave", default: false) { return "wavy" }
  let style-dash = resolved-style.at("edge-dash", default: none)
  if style-dash not in (none, false) { return style-dash }
  resolved-style.edge-pattern
}

#let _resolve-pattern-dash(pattern) = {
  if pattern in (none, false, "normal", "solid", "wavy", "wave") { return none }
  if pattern == "dash" { return "dashed" }
  if pattern in ("dot", "dots") { return "dotted" }
  pattern
}

#let edge-stroke(th, custom: none) = {
  let resolved-style = th
  let base-stroke = if custom != none and "stroke" in custom {
    custom.stroke
  } else if custom != none and "color" in custom {
    custom.color
  } else {
    resolved-style.edge-stroke
  }
  let edge-pattern = _resolve-edge-pattern(resolved-style, custom)
  _apply-dash-to-stroke(base-stroke, _resolve-pattern-dash(edge-pattern))
}

#let edge-arrow(th, directed, custom: none) = {
  let resolved-style = th
  let arrow-specification = if custom != none and "arrow" in custom {
    custom.arrow
  } else if resolved-style.edge-arrow not in (none, false) {
    resolved-style.edge-arrow
  } else if directed {
    "end"
  } else {
    none
  }
  edge-mark(arrow-specification, fill: resolved-style.edge-arrow-fill)
}

#let edge-wave(th, custom: none) = {
  let resolved-style = th
  _resolve-edge-pattern(resolved-style, custom) in ("wavy", "wave")
}

#let wavy-parts(p, q, th, start-tip: false, end-tip: false) = {
  let from-position = p
  let to-position = q
  let resolved-style = th
  let delta-x = to-position.at(0) - from-position.at(0)
  let delta-y = to-position.at(1) - from-position.at(1)
  let edge-length = calc.sqrt(delta-x * delta-x + delta-y * delta-y)
  if edge-length == 0 {
    return (
      points: (from-position, to-position),
      start-cap: from-position,
      end-cap: to-position,
    )
  }
  let unit-x = delta-x / edge-length
  let unit-y = delta-y / edge-length
  let node-cap-length = resolved-style.node-radius * 0.35
  let arrow-tip-cap-length = resolved-style.node-radius * 0.8
  let requested-start-cap = if start-tip {
    arrow-tip-cap-length
  } else {
    node-cap-length
  }
  let requested-end-cap = if end-tip {
    arrow-tip-cap-length
  } else {
    node-cap-length
  }
  let cap-scale = calc.min(
    1,
    edge-length * 0.7 / (requested-start-cap + requested-end-cap),
  )
  let start-cap-length = requested-start-cap * cap-scale
  let end-cap-length = requested-end-cap * cap-scale
  let start-ratio = start-cap-length / edge-length
  let end-ratio = 1 - end-cap-length / edge-length
  let usable-length = edge-length - start-cap-length - end-cap-length
  let wave-count = calc.max(
    1,
    calc.floor(usable-length / resolved-style.edge-wave-step + 0.5),
  )
  let sample-count = calc.max(8, calc.ceil(wave-count * 10))
  let start-cap-position = (
    from-position.at(0) + delta-x * start-ratio,
    from-position.at(1) + delta-y * start-ratio,
  )
  let end-cap-position = (
    from-position.at(0) + delta-x * end-ratio,
    from-position.at(1) + delta-y * end-ratio,
  )
  let points = if start-tip {
    (start-cap-position,)
  } else {
    (from-position, start-cap-position)
  }
  for sample-index in range(1, sample-count) {
    let sample-ratio = sample-index / sample-count
    let edge-ratio = (
      start-ratio + (end-ratio - start-ratio) * sample-ratio
    )
    let x = from-position.at(0) + delta-x * edge-ratio
    let y = from-position.at(1) + delta-y * edge-ratio
    let perpendicular-offset = (
      calc.sin(360deg * wave-count * sample-ratio)
        * resolved-style.edge-wave-amplitude
    )
    points.push((
      x - unit-y * perpendicular-offset,
      y + unit-x * perpendicular-offset,
    ))
  }
  points.push(end-cap-position)
  if not end-tip { points.push(to-position) }
  (
    points: points,
    start-cap: start-cap-position,
    end-cap: end-cap-position,
  )
}

#let wavy-points(p, q, th, start-tip: false, end-tip: false) = {
  wavy-parts(
    p,
    q,
    th,
    start-tip: start-tip,
    end-tip: end-tip,
  ).points
}

// Fallback highlight colors, used when a `<kind>-style` override dict omits
// `fill`. A marked node stays visually distinct even when you only override
// its shape or stroke, instead of quietly falling back to `node-fill`.
#let mark-defaults = (
  new: rgb("#C8E6C9"),
  path: rgb("#FFE9A8"),
  remove: rgb("#FFCDD2"),
  rotate: rgb("#BBDEFB"),
  visited: rgb("#C8E6C9"),
  current: rgb("#BBDEFB"),
  queued: rgb("#FFE9A8"),
)

// Resolves `resolved-style`'s `<kind>-style` value (a color, or a dict of `fill:`,
// `shape:`, `stroke:`, `node-radius:`, `text:`) into a complete per-node style. A
// plain color is shorthand for `(fill: color)`. With `diff-colors: false`,
// fills stay at `base-fill`, while shape/stroke/radius overrides still apply.
#let resolve-mark-style(th, kind, base-fill: auto) = {
  let resolved-style = th
  let mark-value = resolved-style.at(kind + "-style")
  let mark-overrides = if type(mark-value) == color {
    (fill: mark-value)
  } else {
    mark-value
  }
  let normal-fill = if base-fill == auto {
    resolved-style.node-fill
  } else {
    base-fill
  }
  let text-style = (
    resolved-style.value-text + mark-overrides.at("text", default: (:))
  )
  if "color" in text-style {
    text-style.fill = text-style.color
    let _ = text-style.remove("color")
  }
  (
    fill: if resolved-style.diff-colors {
      mark-overrides.at("fill", default: mark-defaults.at(kind))
    } else {
      normal-fill
    },
    shape: mark-overrides.at("shape", default: resolved-style.node-shape),
    stroke: mark-overrides.at("stroke", default: resolved-style.node-stroke),
    node-radius: mark-overrides.at(
      "node-radius",
      default: resolved-style.node-radius,
    ),
    text: text-style,
  )
}
