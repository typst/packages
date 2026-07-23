// Shared visual defaults for every diagram in the package.
//
// One dict so node sizing, palette, and strokes stay consistent across trees
// and linear structures. Every builder takes a `style:` dict that is merged
// over these defaults with `resolve`, so colors, size, and shape can be
// overridden per call or, via `.with(style: ...)`, document-wide.

#let theme = (
  // Trees
  node-radius: 0.34,
  node-shape: "circle", // "circle" or "square"
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
  box-gap: 0.55,
  box-stroke: 0.6pt + rgb("#333333"),
  box-fill: white,
  ptr-fill: rgb("#D7ECC9"), // next-pointer cell in the linked-list pointer style
  prev-ptr-fill: rgb("#D7ECC9"), // previous-pointer cell in doubly-linked-list(pointer: true)
  next-ptr-fill: rgb("#D7ECC9"), // next-pointer cell in doubly-linked-list(pointer: true)

  // Shared
  node-text: (size: 9pt),
  label-text: (color: rgb("#555555")), // annotations: head, front/rear, addresses; inherits size from node-text
  scale: 1.0, // uniform scale applied to the whole rendered diagram
  diff-colors: true, // false keeps operation marks but uses the normal fill

  // Diff highlight styles, used by operation transitions. Each is a plain
  // color (shorthand for `(fill: color)`) or a dict of `fill:`, `shape:`,
  // `stroke:`, `node-radius:`, and `text:` overrides for a marked node/cell.
  new-style: rgb("#C8E6C9"),     // node added by the operation
  path-style: rgb("#FFE9A8"),    // nodes on the traversal path
  remove-style: rgb("#FFCDD2"),  // node removed by the operation
  rotate-style: rgb("#BBDEFB"),  // pivot of an AVL rotation
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
  
  if "color" in res.node-text {
    res.node-text.fill = res.node-text.color
    let _ = res.node-text.remove("color")
  }
  
  if "color" in res.label-text {
    res.label-text.fill = res.label-text.color
    let _ = res.label-text.remove("color")
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
)

// Resolves `th`'s `<kind>-style` value (a color, or a dict of `fill:`,
// `shape:`, `stroke:`, `node-radius:`, `text:`) into a complete per-node style. A
// plain color is shorthand for `(fill: color)`. With `diff-colors: false`,
// fills stay at `base-fill`, while shape/stroke/radius overrides still apply.
#let mark-style(th, kind, base-fill: auto) = {
  let value = th.at(kind + "-style")
  let d = if type(value) == color { (fill: value) } else { value }
  let normal-fill = if base-fill == auto { th.node-fill } else { base-fill }
  let text-style = th.node-text + d.at("text", default: (:))
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
