// Shared visual defaults for every diagram in the package.
//
// One dict so node sizing, palette, and strokes stay consistent across trees
// and linear structures. Every builder takes a `style:` dict that is merged
// over these defaults with `resolve`, so colors, size, and shape can be
// overridden per call or, via `.with(style: ...)`, document-wide.

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
  assert(name in themes, message: "unknown typed-dsa theme: " + name)
  themes.at(name)
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

#let _style(
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
) = _style(
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
) = _style(
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
) = _style(
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
) = _style(
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
) = _style(
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
) = _style(
  box-w: box-w, box-h: box-h, box-shape: box-shape, box-stroke: box-stroke, box-fill: box-fill,
  node-text: node-text, value-text: value-text, label-text: label-text,
  index-text: index-text, pointer-text: pointer-text,
  algorithm-label-text: algorithm-label-text, indices: indices, scale: scale,
)

#let matrix-style(
  box-w: auto, box-h: auto, box-shape: auto, box-stroke: auto, box-fill: auto,
  node-text: auto, value-text: auto, label-text: auto, index-text: auto, scale: auto,
) = _style(
  box-w: box-w, box-h: box-h, box-shape: box-shape, box-stroke: box-stroke, box-fill: box-fill,
  node-text: node-text, value-text: value-text, label-text: label-text,
  index-text: index-text, scale: scale,
)

// Merge a per-call override dict over the defaults.
#let resolve(style) = {
  let res = theme + style
  if "node-text" in style {
    res.node-text = theme.node-text + style.node-text
  }
  
  let label-defaults = theme.label-text
  // If label-text doesn't explicitly specify a size, derive it from node-text
  if "size" not in label-defaults and ("label-text" not in style or "size" not in style.label-text) {
     label-defaults.size = res.node-text.at("size", default: 9pt) * 0.85
  }

  if "label-text" in style {
    res.label-text = label-defaults + style.label-text
  } else {
    res.label-text = label-defaults
  }

  res.value-text = res.node-text + theme.value-text + style.at("value-text", default: (:))
  for key in ("index-text", "pointer-text", "operation-text", "edge-label-text", "algorithm-label-text") {
    res.insert(key, res.label-text + theme.at(key) + style.at(key, default: (:)))
  }
  
  if "color" in res.node-text {
    res.node-text.fill = res.node-text.color
    let _ = res.node-text.remove("color")
  }
  
  if "color" in res.label-text {
    res.label-text.fill = res.label-text.color
    let _ = res.label-text.remove("color")
  }
  for key in ("value-text", "index-text", "pointer-text", "operation-text", "edge-label-text", "algorithm-label-text") {
    let item = res.at(key)
    if "color" in item {
      item.fill = item.color
      let _ = item.remove("color")
      res.insert(key, item)
    }
  }
  
  res
}

// Wraps a rendered diagram in the theme's `scale` factor. `reflow: true` so
// surrounding layout (arrows, stacks, tables) sees the resized box instead of
// a visual-only transform that overlaps its neighbors.
#let scaled(th, body) = if th.scale == 1.0 { body } else { scale(th.scale * 100%, reflow: true, body) }

#let edge-mark(spec, fill: none) = {
  if spec == "both" { (start: ">", end: ">", fill: fill) }
  else if spec == "start" { (start: ">", fill: fill) }
  else if spec == "end" or spec == true { (end: ">", fill: fill) }
  else { none }
}

#let _dash-stroke(stroke, dash) = {
  if dash == none or dash == false { return stroke }
  if type(stroke) == dictionary { return stroke + (dash: dash) }
  if type(stroke) == color { return (paint: stroke, dash: dash) }
  (paint: stroke.paint, thickness: stroke.thickness, dash: dash)
}

#let _edge-pattern(th, custom) = {
  if custom != none and "pattern" in custom { return custom.pattern }
  // Backwards-compatible aliases for the short-lived split API.
  if custom != none and custom.at("wave", default: false) { return "wavy" }
  if custom != none and custom.at("dash", default: none) not in (none, false) { return custom.dash }
  if th.at("edge-wave", default: false) { return "wavy" }
  let dash = th.at("edge-dash", default: none)
  if dash not in (none, false) { return dash }
  th.edge-pattern
}

#let _pattern-dash(pattern) = {
  if pattern in (none, false, "normal", "solid", "wavy", "wave") { return none }
  if pattern == "dash" { return "dashed" }
  if pattern in ("dot", "dots") { return "dotted" }
  pattern
}

#let edge-stroke(th, custom: none) = {
  let stroke = if custom != none and "stroke" in custom { custom.stroke }
    else if custom != none and "color" in custom { custom.color }
    else { th.edge-stroke }
  _dash-stroke(stroke, _pattern-dash(_edge-pattern(th, custom)))
}

#let edge-arrow(th, directed, custom: none) = {
  let spec = if custom != none and "arrow" in custom { custom.arrow }
    else if th.edge-arrow != none and th.edge-arrow != false { th.edge-arrow }
    else if directed { "end" }
    else { none }
  edge-mark(spec, fill: th.edge-arrow-fill)
}

#let edge-wave(th, custom: none) = _edge-pattern(th, custom) in ("wavy", "wave")

#let wavy-parts(p, q, th, start-tip: false, end-tip: false) = {
  let dx = q.at(0) - p.at(0)
  let dy = q.at(1) - p.at(1)
  let len = calc.sqrt(dx * dx + dy * dy)
  if len == 0 { return (points: (p, q), start-cap: p, end-cap: q) }
  let ux = dx / len
  let uy = dy / len
  let node-cap = th.node-radius * 0.35
  let tip-cap = th.node-radius * 0.8
  let start-cap = if start-tip { tip-cap } else { node-cap }
  let end-cap = if end-tip { tip-cap } else { node-cap }
  let cap-scale = calc.min(1, len * 0.7 / (start-cap + end-cap))
  let start = start-cap * cap-scale
  let end = end-cap * cap-scale
  let t0 = start / len
  let t1 = 1 - end / len
  let usable = len - start - end
  let waves = calc.max(1, calc.floor(usable / th.edge-wave-step + 0.5))
  let steps = calc.max(8, calc.ceil(waves * 10))
  let start-point = (p.at(0) + dx * t0, p.at(1) + dy * t0)
  let end-point = (p.at(0) + dx * t1, p.at(1) + dy * t1)
  let points = if start-tip { (start-point,) } else { (p, start-point) }
  for i in range(1, steps) {
    let u = i / steps
    let t = t0 + (t1 - t0) * u
    let x = p.at(0) + dx * t
    let y = p.at(1) + dy * t
    let off = calc.sin(360deg * waves * u) * th.edge-wave-amplitude
    points.push((x - uy * off, y + ux * off))
  }
  points.push(end-point)
  if not end-tip { points.push(q) }
  (points: points, start-cap: start-point, end-cap: end-point)
}

#let wavy-points(p, q, th, start-tip: false, end-tip: false) = {
  wavy-parts(p, q, th, start-tip: start-tip, end-tip: end-tip).points
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

// Resolves `th`'s `<kind>-style` value (a color, or a dict of `fill:`,
// `shape:`, `stroke:`, `node-radius:`, `text:`) into a complete per-node style. A
// plain color is shorthand for `(fill: color)`. With `diff-colors: false`,
// fills stay at `base-fill`, while shape/stroke/radius overrides still apply.
#let resolve-mark-style(th, kind, base-fill: auto) = {
  let value = th.at(kind + "-style")
  let d = if type(value) == color { (fill: value) } else { value }
  let normal-fill = if base-fill == auto { th.node-fill } else { base-fill }
  let text-style = th.value-text + d.at("text", default: (:))
  if "color" in text-style {
    text-style.fill = text-style.color
    let _ = text-style.remove("color")
  }
  (
    fill: if th.diff-colors { d.at("fill", default: mark-defaults.at(kind)) } else { normal-fill },
    shape: d.at("shape", default: th.node-shape),
    stroke: d.at("stroke", default: th.node-stroke),
    node-radius: d.at("node-radius", default: th.node-radius),
    text: text-style,
  )
}
