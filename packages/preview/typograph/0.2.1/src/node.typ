#import "utility.typ": unwrap-node, tight-text
#import "style.typ": (
  resolve-node-style, expand-min-size, scale-stroke, box-base-style, gate-base-style,
)
#import "shape.typ": build-outline
#import "geometry.typ": (
  num, resolve-inset, rounded-rect-radius, ellipse-radius,
  polygon-radius, rotate-point, orient-points,
)

// Multiplies every length in an `inset:` spec, whichever form it took. This
// lives before the part scaler because Typst bindings are not forward-visible.
#let scale-inset(spec, k) = {
  if k == 1 { return spec }
  let scale-value(value) = if type(value) == ratio { value }
    else if type(value) == relative { value.ratio + value.length * k }
    else { value * k }
  if type(spec) == dictionary {
    spec.pairs().fold((:), (d, p) => d + ((p.at(0)): scale-value(p.at(1))))
  } else {
    scale-value(spec)
  }
}

#let _resolve-style-length(value, fallback) = {
  if value == auto { return fallback }
  if type(value) == length { return value }
  if type(value) == ratio { return fallback * value }
  assert(
    type(value) == relative,
    message: "mark size/thickness must be a length, ratio, relative length, or auto",
  )
  value.ratio * fallback + value.length
}

#let _resolve-part-transform(value, scale) = {
  if value == none { return none }
  if type(value) == array {
    assert(
      value.len() == 2 and value.all(component => type(component) == length),
      message: "shape part transform must be a (dx, dy) length pair",
    )
    return (value.at(0) * scale, value.at(1) * scale)
  }
  assert(type(value) == dictionary, message: "shape part transform must be a (dx, dy) pair or a {x:.., y:..} dictionary")
  let dx = value.at("x", default: value.at("dx", default: 0pt))
  let dy = value.at("y", default: value.at("dy", default: 0pt))
  assert(type(dx) == length and type(dy) == length,
    message: "shape part transform requires x/dx and y/dy values to be lengths",
  )
  (dx * scale, dy * scale)
}

#let _scale-part-style(overrides, scale) = {
  let out = overrides
  if scale == 1 { return out }

  if "min-size" in out {
    assert(type(out.min-size) == length, message: "shape part min-size must be a non-negative length")
    out.min-size = out.min-size * scale
  }
  if "min-width" in out { out.min-width *= scale }
  if "min-height" in out { out.min-height *= scale }
  if "inset" in out { out.inset = scale-inset(out.inset, scale) }
  if "radius" in out {
    if type(out.radius) == length {
      out.radius = out.radius * scale
    } else if type(out.radius) == relative {
      out.radius = out.radius.ratio + out.radius.length * scale
    }
  }

  if "stroke" in out {
    out.stroke = scale-stroke(out.stroke, scale)
  }
  if "mark-size" in out {
    let size = out.at("mark-size")
    if type(size) == length { out.mark-size = size * scale }
    if type(size) == relative { out.mark-size = size.ratio + size.length * scale }
  }
  if "mark-thickness" in out {
    let thickness = out.at("mark-thickness")
    if type(thickness) == length { out.mark-thickness = thickness * scale }
    if type(thickness) == relative { out.mark-thickness = thickness.ratio + thickness.length * scale }
  }
  out
}

#let _cross-mark-shape(label, pad, style) = {
  let reference = calc.min(style.min-width, style.min-height)
  let fallback = if reference > 0pt { reference } else { 6pt }
  let size = _resolve-style-length(style.mark-size, fallback)
  if size <= 0pt { return (kind: "empty") }
  let thickness = _resolve-style-length(style.mark-thickness, size / 5)
  if thickness <= 0pt { return (kind: "empty") }
  let half-size = size / 2
  let half-thick = thickness / 2
  let raw = (
    (-half-thick, -half-size),
    (half-thick, -half-size),
    (half-thick, -half-thick),
    (half-size, -half-thick),
    (half-size, half-thick),
    (half-thick, half-thick),
    (half-thick, half-size),
    (-half-thick, half-size),
    (-half-thick, half-thick),
    (-half-size, half-thick),
    (-half-size, -half-thick),
    (-half-thick, -half-thick),
  )
  (kind: "polygon", points: orient-points(raw, style), label-offset: (0pt, 0pt))
}

#let _scaled-mark-length(value, scale) = {
  if type(value) == length { value * scale }
  else if type(value) == relative { value.ratio + value.length * scale }
  else { value }
}

#let _mark-ink(style, scale) = {
  let fill = style.at("mark-fill", default: none)
  let source = style.at("mark-stroke", default: auto)
  let spec = if source == auto { style.stroke } else { scale-stroke(source, scale) }
  let pen = if spec in (none, auto) { none } else { stroke(spec) }
  let paint = if fill != none { fill } else if pen == none or pen.paint == auto { black } else { pen.paint }
  let thickness = if pen == none or pen.thickness == auto { 1pt * scale } else { pen.thickness }
  if fill == none and spec == none { none } else { (paint: paint, thickness: thickness) }
}

#let _outline-half-extents-simple(outline) = {
  if outline.kind == "circle" { (outline.radius, outline.radius) }
  else if outline.kind in ("ellipse", "rect", "polygon") {
    (outline.half-width, outline.half-height)
  } else { none }
}

#let _solid-polygon-part(points, paint) = {
  let first = points.first()
  let min-x = first.at(0)
  let max-x = min-x
  let min-y = first.at(1)
  let max-y = min-y
  for point in points {
    min-x = calc.min(min-x, point.at(0))
    max-x = calc.max(max-x, point.at(0))
    min-y = calc.min(min-y, point.at(1))
    max-y = calc.max(max-y, point.at(1))
  }
  let center = ((min-x + max-x) / 2, (min-y + max-y) / 2)
  let centered = points.map(point => (
    point.at(0) - center.at(0),
    point.at(1) - center.at(1),
  ))
  (
    outline: (
      kind: "polygon",
      points: centered,
      half-width: (max-x - min-x) / 2,
      half-height: (max-y - min-y) / 2,
      label-offset: (0pt, 0pt),
    ),
    fill: paint,
    stroke: none,
    transform: center,
  )
}

#let _line-band-points(start, end, thickness) = {
  let dx = num(end.at(0) - start.at(0))
  let dy = num(end.at(1) - start.at(1))
  let magnitude = calc.sqrt(dx * dx + dy * dy)
  assert(magnitude > 0, message: "mark line must have non-zero length")
  let half = thickness / 2
  let normal = (-dy / magnitude * half, dx / magnitude * half)
  (
    (start.at(0) + normal.at(0), start.at(1) + normal.at(1)),
    (end.at(0) + normal.at(0), end.at(1) + normal.at(1)),
    (end.at(0) - normal.at(0), end.at(1) - normal.at(1)),
    (start.at(0) - normal.at(0), start.at(1) - normal.at(1)),
  )
}

// Filled outline of one stroked chevron. Keeping both arrowhead arms in one
// contour gives their tip a true miter join instead of overlapping two
// independently capped rectangles at high mark weights.
#let _chevron-band-points(tip, angle, length, thickness) = {
  let diagonal = length / calc.sqrt(2)
  let offset = thickness / (2 * calc.sqrt(2))
  let miter = thickness / calc.sqrt(2)
  let local = (
    (-diagonal + offset, diagonal + offset),
    (miter, 0pt),
    (-diagonal + offset, -diagonal - offset),
    (-diagonal - offset, -diagonal + offset),
    (-miter, 0pt),
    (-diagonal - offset, diagonal - offset),
  )
  let direction = (calc.cos(angle), calc.sin(angle))
  let normal = (-direction.at(1), direction.at(0))
  local.map(point => (
    tip.at(0) + point.at(0) * direction.at(0) + point.at(1) * normal.at(0),
    tip.at(1) + point.at(0) * direction.at(1) + point.at(1) * normal.at(1),
  ))
}

#let _cross-mark-parts(style, base-outline, scale) = {
  let ink = _mark-ink(style, scale)
  if ink == none { return () }
  let extents = _outline-half-extents-simple(base-outline)
  if extents == none {
    extents = (style.min-width / 2, style.min-height / 2)
  }
  let reference = calc.min(extents.at(0), extents.at(1)) * 2
  let requested-size = style.at("mark-size", default: auto)
  // Percentages are relative to the actual base silhouette, even when it is
  // smaller than the default glyph. Only a genuinely automatic mark keeps the
  // established 6pt fallback (scaled with the diagram).
  let fallback = if requested-size == auto {
    calc.max(reference, 6pt * scale)
  } else {
    reference
  }
  let size = _resolve-style-length(
    _scaled-mark-length(requested-size, scale),
    fallback,
  )
  if size <= 0pt { return () }
  let thickness = _resolve-style-length(
    _scaled-mark-length(style.at("mark-thickness", default: auto), scale),
    ink.thickness,
  )
  if thickness <= 0pt { return () }
  let part-style = expand-min-size(style + (
    shape: _cross-mark-shape,
    fill: ink.paint,
    stroke: none,
    rotate: style.at("mark-angle", default: 45deg),
    min-width: extents.at(0) * 2,
    min-height: extents.at(1) * 2,
    "mark-size": size,
    "mark-thickness": thickness,
  ))
  let part-outline = build-outline(
    _cross-mark-shape,
    (width: 0pt, height: 0pt),
    resolve-inset(part-style.inset, 1pt),
    part-style,
  )
  ((outline: part-outline, fill: part-style.fill, stroke: none, transform: none),)
}

#let _measurement-mark-parts(style, base-outline, scale) = {
  let ink = _mark-ink(style, scale)
  if ink == none { return () }
  let extents = _outline-half-extents-simple(base-outline)
  if extents == none { return () }
  let (half-width, half-height) = extents
  let fallback = calc.max(calc.min(half-width * 1.35, 16pt * scale), 8pt * scale)
  let size = _resolve-style-length(
    _scaled-mark-length(style.at("mark-size", default: auto), scale),
    fallback,
  )
  if size <= 0pt { return () }
  let thickness = _resolve-style-length(
    _scaled-mark-length(style.at("mark-thickness", default: auto), scale),
    ink.thickness,
  )
  if thickness <= 0pt { return () }

  let top = -half-height
  let radius = size * 0.38
  let outer = radius + thickness / 2
  // One cubic is visually indistinguishable from a semicircle at mark scale
  // and avoids constructing a sampled polygon for every distinct mark style.
  let curve-start = (thickness / 2, outer)
  let curve-end = (2 * outer - thickness / 2, outer)
  let control-y = thickness / 2 - radius / 3
  let arc = (
    outline: (
      kind: "rect",
      half-width: outer,
      half-height: outer / 2,
      label-offset: (0pt, 0pt),
    ),
    fill: none,
    stroke: none,
    transform: (0pt, top - outer / 2),
    body: curve(
      stroke: (paint: ink.paint, thickness: thickness, cap: "butt"),
      curve.move(curve-start),
      curve.cubic(
        (curve-start.at(0), control-y),
        (curve-end.at(0), control-y),
        curve-end,
      ),
    ),
  )

  let angle = style.at("mark-angle", default: -45deg)
  let start = (0pt, top)
  let end = (
    start.at(0) + size * calc.cos(angle),
    start.at(1) + size * calc.sin(angle),
  )
  let head = calc.max(size * 0.28, thickness * 2)
  (
    arc,
    _solid-polygon-part(_line-band-points(start, end, thickness), ink.paint),
    _solid-polygon-part(_chevron-band-points(end, angle, head, thickness), ink.paint),
  ).map(part => part + (layer: "behind"))
}

#let _collect-shape-parts(style, selected-shape, measured, scale) = {
  let source = if "shape.parts" in style {
    style.at("shape.parts")
  } else {
    style.at("parts", default: none)
  }
  if source == none { return () }

  let entries = if type(source) == dictionary {
    source.pairs().map(p => p.at(1))
  } else {
    source
  }
  assert(type(entries) == array, message: "shape parts must be an array or dictionary of part specs")
  assert(entries.len() >= 1, message: "shape.parts requires at least one entry")

  let out = ()
  for entry in entries {
    let part = if type(entry) == function { (shape: entry) } else {
      assert(
        type(entry) == dictionary,
        message: "shape parts entries must be a builder function or a dictionary",
      )
      entry
    }
    let part-shape = part.at("shape", default: selected-shape)
    assert(type(part-shape) == function, message: "shape part `shape` must be a shape builder function")

    let part-overrides = _scale-part-style(part + (shape: part-shape), scale)
    // Expand the part layer before merging it. The resolved base style already
    // has explicit axes, and expanding afterward would make those inherited
    // keys incorrectly defeat a part-local `min-size` shorthand.
    let part-style = expand-min-size(style) + expand-min-size(part-overrides)
    let part-outline = build-outline(
      part-shape,
      measured,
      resolve-inset(part-style.inset, 1pt),
      part-style,
    )
    let transform = _resolve-part-transform(part.at("transform", default: none), scale)
    let layer = part.at("layer", default: "front")
    assert(layer in ("behind", "front"), message: "shape part layer must be \"behind\" or \"front\"")
    out.push((outline: part-outline, fill: part-style.fill, stroke: part-style.stroke, transform: transform, layer: layer))
  }
  out
}

#let _collect-mark-parts(style, base-outline, scale) = {
  let mark = style.at("mark", default: none)
  if mark == "cross" { _cross-mark-parts(style, base-outline, scale) }
  else if mark == "measurement" { _measurement-mark-parts(style, base-outline, scale) }
  else { () }
}

// Single-outline rendering shared with the composite case below.
#let _outline-size-simple(outline, measured) = {
  if outline.kind == "empty" {
    return (
      left: 0pt, right: 0pt, top: 0pt, bottom: 0pt,
      width: 0pt, height: 0pt,
    )
  }
  if outline.kind == "bare" {
    let (half-width, half-height) = (measured.width / 2, measured.height / 2)
    return (
      left: -half-width, right: half-width,
      top: -half-height, bottom: half-height,
      width: measured.width, height: measured.height,
    )
  }
  let (half-width, half-height) = if outline.kind == "circle" {
    (outline.radius, outline.radius)
  } else {
    (outline.half-width, outline.half-height)
  }
  let left = -half-width
  let right = half-width
  let top = -half-height
  let bottom = half-height
  if measured.width > 0pt or measured.height > 0pt {
    let (label-x, label-y) = outline.at("label-offset", default: (0pt, 0pt))
    left = calc.min(left, label-x - measured.width / 2)
    right = calc.max(right, label-x + measured.width / 2)
    top = calc.min(top, label-y - measured.height / 2)
    bottom = calc.max(bottom, label-y + measured.height / 2)
  }
  (
    left: left, right: right, top: top, bottom: bottom,
    width: right - left, height: bottom - top,
  )
}


// `box()` below shadows the built-in of the same name; keep a handle to it
// under a different name before that happens.
#let std-box = box

// Layers content over a base without letting overlays change the base's
// measured bounds. Composite shape parts and labels share this primitive.
#let overlay(base, ..layers) = std-box(inset: 0pt, {
  base
  for layer in layers.pos() {
    place(center + horizon, layer)
  }
})

// ---------------------------------------------------------------------
// Construction
// ---------------------------------------------------------------------

#let make-node(
  kind, x, y,
  label: none,
  name: none,
  style: (:),
  base-style: (:),
  size-scale: 1,
  ..extra,
) = {
  assert(type(kind) == str, message: "node kind must be a string, got " + repr(kind))
  assert(type(x) in (int, float) and type(y) in (int, float), message: "node coordinates must be numbers")
  assert(name == none or type(name) == str, message: "node name must be a string or none")
  assert(type(style) == dictionary, message: "node style must be a dictionary, got " + repr(style))
  assert(type(base-style) == dictionary, message: "node base-style must be a dictionary, got " + repr(base-style))
  assert(type(size-scale) in (int, float) and size-scale > 0, message: "node size-scale must be positive")
  assert(extra.pos().len() == 0, message: "make-node() accepts extra fields only by name")
  let reserved = ("type", "kind", "x", "y", "label", "name", "style", "base-style", "size-scale")
  let overlap = extra.named().keys().filter(key => key in reserved)
  assert(
    overlap.len() == 0,
    message: "make-node() extra fields cannot replace reserved field(s): " + overlap.join(", "),
  )
  (
    (
      ..extra.named(),
      type: "node",
      kind: kind,
      x: x,
      y: y,
      label: label,
      name: name,
      style: style,
      base-style: base-style,
      size-scale: size-scale,
    ),
  )
}

/// Creates a reusable node constructor with a semantic `kind` and optional
/// themeable factory defaults. The returned function has the same common
/// `(x, y, label:, name:, style:)` interface as the built-in node kinds.
///
/// `flippable: true` additionally exposes a top-level `flip: auto` argument
/// that forwards into `style.flip` (an explicit `flip:` wins over any
/// `flip` already in `style:`) — the declarative equivalent of hand-writing
/// a wrapper that mutates `style` before calling through, for any kind whose
/// shape is directional and benefits from a per-call mirror.
#let node-type(kind, base-style: (:), flippable: false) = {
  assert(type(kind) == str, message: "node-type() kind must be a string, got " + repr(kind))
  assert(type(base-style) == dictionary, message: "node-type() base-style must be a dictionary")
  assert(type(flippable) == bool, message: "node-type() flippable must be a boolean")
  if flippable {
    (x, y, label: none, flip: auto, name: none, style: (:)) => {
      if flip != auto { style.flip = flip }
      make-node(kind, x, y, label: label, name: name, style: style, base-style: base-style)
    }
  } else {
    (x, y, label: none, name: none, style: (:)) => make-node(
      kind, x, y, label: label, name: name, style: style, base-style: base-style,
    )
  }
}

/// A fully general node: styleable via `style:` like any other, but
/// invisible by default (`shape` resolves to `shapes.empty`) — the escape hatch for
/// a one-off shape, or an invisible routing waypoint for `edge()` (its
/// original purpose: participates in edge routing and the diagram's
/// bounding box, but draws nothing unless you give it a `shape:`).
#let node(x, y, label: none, name: none, style: (:), kind: "node", base-style: (:)) = {
  make-node(kind, x, y, label: label, name: name, style: style, base-style: base-style)
}

/// A generic styleable box: a labeled rectangle with `fill:`/`stroke:`/
/// `inset:`/`radius:` exposed directly (each defaults to the package's
/// plain-box look; pass `style:` for anything not covered by those, e.g.
/// `min-size`). Useful for scalars-with-a-border, annotated groupings, or
/// any other "just a labeled box" shape that isn't one of the named kinds.
#let box(x, y, label: none, fill: auto, stroke: auto, inset: auto, radius: auto, name: none, style: (:)) = {
  if fill != auto { style.fill = fill }
  if stroke != auto { style.stroke = stroke }
  if inset != auto { style.inset = inset }
  if radius != auto { style.radius = radius }
  make-node(
    "box", x, y, label: label, name: name,
    base-style: box-base-style, style: style,
  )
}

// Resolves one evenly-spaced offset in O(1). Building every side's full array
// for each endpoint made port-heavy circuits needlessly quadratic in the
// number of legs.
#let side-port-offset(n, extent, index, spacing: auto) = {
  if n == 1 { 0pt }
  else if spacing != auto { (index - (n - 1) / 2) * spacing }
  else {
    let margin = extent * 0.7
    -margin + 2 * margin * index / (n - 1)
  }
}

#let gate-port-offset(hw, hh, legs, side, index, spacing: auto) = {
  let n = legs.at(side, default: 0)
  if side == "left" { (-hw, side-port-offset(n, hh, index, spacing: spacing)) }
  else if side == "right" { (hw, side-port-offset(n, hh, index, spacing: spacing)) }
  else if side == "top" { (side-port-offset(n, hw, index, spacing: spacing), hh) }
  else { (side-port-offset(n, hw, index, spacing: spacing), -hh) }
}

/// A generic labeled gate box (e.g. for CVQC circuit gates like the
/// displacement, squeezing, or beam-splitter gates). `legs` gives the number
/// of wire attachment points per side; connect to one with `port(g, "left",
/// index: 0)`.
///
/// Sized like every other node: in pt, from the label plus `inset`, floored
/// at a minimum that grows when an axis has multiple legs so a many-legged
/// gate has room to fan out; a lone port adds no size floor. It therefore
/// follows the diagram's `scale` zoom and ignores
/// `scale-edges`, exactly as the spiders do. `size: (width, height)` (lengths)
/// overrides that minimum; `inset:` is the label-to-edge padding.
#let gate(
  x, y, label,
  legs: (left: 1, right: 1),
  max-legs-per-side: none,
  port-spacing: auto,
  size: auto,
  inset: auto,
  name: none,
  style: (:),
  kind: "gate",
) = {
  let sides = ("left", "right", "top", "bottom")
  assert(type(legs) == dictionary, message: "gate legs must be a dictionary")
  assert(legs.keys().all(side => side in sides), message: "gate legs accepts only left/right/top/bottom")
  assert(
    legs.values().all(count => type(count) == int and count >= 0),
    message: "gate leg counts must be non-negative integers",
  )
  if max-legs-per-side != none {
    assert(
      type(max-legs-per-side) == int and max-legs-per-side >= 0,
      message: "max-legs-per-side must be a non-negative integer",
    )
    assert(
      legs.values().all(count => count <= max-legs-per-side),
      message: "gate legs exceed max-legs-per-side",
    )
  }
  assert(
    port-spacing == auto or (type(port-spacing) == length and port-spacing > 0pt),
    message: "gate port-spacing must be auto or a positive length",
  )
  assert(
    size == auto or (
      type(size) == array and size.len() == 2
        and size.all(value => type(value) == length and value >= 0pt)
    ),
    message: "gate size must be auto or a (width, height) pair of non-negative lengths",
  )
  if inset != auto { style.inset = inset }
  make-node(
    kind, x, y, label: label, name: name, style: style,
    base-style: gate-base-style,
    size: size, legs: legs, port-layout: "box", port-spacing: port-spacing,
  )
}

/// Refers to one wire attachment point on a `gate()`, e.g. `typ.port(g,
/// "left")`, `typ.port(g, "right", 1)` or `typ.port(g, "right", index: 1)`. Usable anywhere an edge
/// endpoint is expected, and it carries `g` along, so the gate is drawn
/// automatically just as `edge(g, ..)` would draw it.
///
/// The exact coordinate is resolved when the diagram is laid out — only then
/// is the box's rendered size known — so ports sit on the outline at every
/// scale and for every label.
#let port(node-ref, side, ..args) = {
  // The index may be given positionally (`port(g, "left", 1)`) or by name
  // (`port(g, "left", index: 1)`), and defaults to the first port.
  assert(
    args.pos().len() <= 1
      and args.named().keys().all(k => k == "index")
      and not (args.pos().len() == 1 and "index" in args.named()),
    message: "port() takes a node, a side, and optionally an index — got " + repr(args),
  )
  let index = if args.pos().len() > 0 { args.pos().first() } else { args.named().at("index", default: 0) }
  let n = unwrap-node(node-ref)
  assert(n != none, message: "port() expects a node value, e.g. the result of gate(..)")
  if n.at("port-layout", default: none) != "box" {
    assert(false, message: "port() expects a port-capable node such as gate(), got " + repr(n.kind))
  }
  assert(
    side in ("left", "right", "top", "bottom"),
    message: "port side must be \"left\", \"right\", \"top\" or \"bottom\", got " + repr(side),
  )
  let count = n.legs.at(side, default: 0)
  assert(
    type(index) == int and index >= 0 and index < count,
    message: "gate has no port #" + str(index) + " on side \"" + side + "\" (it has " + str(count) + ")",
  )
  (type: "port", node: n, side: side, index: index)
}

// ---------------------------------------------------------------------
// Sizing: turn a style plus a measured label into an outline.
//
// The geometry itself lives in `shape.typ`; this is only the part that knows
// about labels and insets. Keeping the two apart is what lets a builder be
// reused by any kind, and a kind switch builders without touching geometry.
// ---------------------------------------------------------------------

// Which builder to use: `shape`, or `shape-labelled` when the node has a
// label and has opted in. Opt-in on purpose — a node keeping its form whether
// or not it is labelled is the least surprising default, and the spiders'
// circle-to-pill habit is a ZX convention rather than a general rule.
#let effective-shape(style, labelled) = {
  let alt = style.at("shape-labelled", default: auto)
  assert(
    alt == auto or type(alt) == function,
    message: "shape-labelled must be auto or a builder function",
  )
  if labelled and alt != auto { alt } else { style.shape }
}

#let shape-outline(style, label-body, measured, builder: auto, part-scale: 1) = {
  let pad = resolve-inset(style.inset, 1pt, source: "node inset")
  let shape = if builder == auto {
    effective-shape(style, label-body != [])
  } else {
    builder
  }
  let outline = build-outline(shape, measured, pad, style)
  // `fit-box` sizes from the sum of opposite insets. Shift the label into
  // that inset-defined content area as Typst's own shapes do: extra left
  // inset moves it right, and extra top inset moves it down. Polygonal
  // builders can add their own intrinsic nudge through `label-offset`.
  if outline.kind not in ("empty", "bare") {
    let intrinsic = outline.at("label-offset", default: (0pt, 0pt))
    outline.label-offset = (
      intrinsic.at(0) + (pad.left - pad.right) / 2,
      intrinsic.at(1) + (pad.top - pad.bottom) / 2,
    )
  }

  let parts = _collect-shape-parts(
    style, shape, (width: 0pt, height: 0pt), part-scale,
  ) + _collect-mark-parts(style, outline, part-scale)
  if parts.len() == 0 {
    return outline
  }

  return (
    kind: "parts",
    base: (outline: outline, fill: style.fill, stroke: style.stroke),
    parts: parts,
  )
}

// Distance from a shape outline's origin to its boundary along `angle`
// (Typst screen convention: 0deg = +x, 90deg = +y-down) — used to attach
// an edge to a node's true silhouette instead of its raw center point.
#let shape-radius(outline, angle) = {
  if outline.kind in ("empty", "bare") { 0pt }
  else if outline.kind == "parts" { shape-radius(outline.base.outline, angle) }
  else if outline.kind == "circle" { outline.radius }
  else if outline.kind == "ellipse" {
    ellipse-radius(outline.half-width, outline.half-height, angle)
  } else if outline.kind == "rect" {
    rounded-rect-radius(
      outline.half-width,
      outline.half-height,
      outline.radius,
      angle,
    )
  } else if outline.kind == "polygon" {
    polygon-radius(outline.points, angle)
  }
}

// ---------------------------------------------------------------------
// Drawing
// ---------------------------------------------------------------------

/// The visual bounds a `draw-outline` result will occupy, relative to its node
/// origin. The silhouette already knows its extents, while `measured` lets us
/// union a shifted label without another layout pass. Returning signed sides
/// as well as width/height preserves asymmetric `label-offset` bounds.
#let outline-size(outline, measured) = {
  if outline.kind == "parts" {
    let size = _outline-size-simple(outline.base.outline, measured)
    let out = (left: size.left, right: size.right, top: size.top, bottom: size.bottom)
    let measured-part = (width: 0pt, height: 0pt)
    for part in outline.parts {
      let p = _outline-size-simple(part.outline, measured-part)
      let shift = if part.transform == none { (0pt, 0pt) } else { part.transform }
      let pl = p.left + shift.at(0)
      let pr = p.right + shift.at(0)
      let pt = p.top + shift.at(1)
      let pb = p.bottom + shift.at(1)
      if pl < out.left { out.left = pl }
      if pr > out.right { out.right = pr }
      if pt < out.top { out.top = pt }
      if pb > out.bottom { out.bottom = pb }
    }
    return (
      left: out.left, right: out.right,
      top: out.top, bottom: out.bottom,
      width: out.right - out.left, height: out.bottom - out.top,
    )
  }

  if outline.kind == "empty" {
    return (
      left: 0pt, right: 0pt, top: 0pt, bottom: 0pt,
      width: 0pt, height: 0pt,
    )
  }
  if outline.kind == "bare" {
    let (half-width, half-height) = (measured.width / 2, measured.height / 2)
    return (
      left: -half-width, right: half-width,
      top: -half-height, bottom: half-height,
      width: measured.width, height: measured.height,
    )
  }
  let (half-width, half-height) = if outline.kind == "circle" {
    (outline.radius, outline.radius)
  } else {
    (outline.half-width, outline.half-height)
  }
  let left = -half-width
  let right = half-width
  let top = -half-height
  let bottom = half-height
  if measured.width > 0pt or measured.height > 0pt {
    let (label-x, label-y) = outline.at("label-offset", default: (0pt, 0pt))
    left = calc.min(left, label-x - measured.width / 2)
    right = calc.max(right, label-x + measured.width / 2)
    top = calc.min(top, label-y - measured.height / 2)
    bottom = calc.max(bottom, label-y + measured.height / 2)
  }
  (
    left: left, right: right, top: top, bottom: bottom,
    width: right - left, height: bottom - top,
  )
}

/// Half-extents for an outline with a drawable boundary. Used by generic
/// rectangular port distribution; unlike direct field access this also works
/// for circles and ellipses.
#let outline-half-extents(outline) = {
  if outline.kind == "parts" {
    return outline-half-extents(outline.base.outline)
  }
  if outline.kind == "circle" { (outline.radius, outline.radius) }
  else if outline.kind in ("ellipse", "rect", "polygon") {
    (outline.half-width, outline.half-height)
  }
  else { none }
}

/// Resolves one rectangularly distributed gate port onto the node's actual
/// silhouette. A rectangle is unchanged; for a circle, ellipse or
/// polygon the candidate direction is projected with the same radius query
/// used for edge clipping. Returned y follows diagram convention (+y up).
#let gate-port-on-outline(outline, legs, side, index, rotate: 0deg, port-spacing: auto) = {
  assert(type(rotate) == angle, message: "gate port rotation must be an angle")
  assert(
    port-spacing == auto or (type(port-spacing) == length and port-spacing > 0pt),
    message: "gate port spacing must be auto or a positive length",
  )
  if outline.kind == "parts" {
    outline = outline.base.outline
  }
  let extents = outline-half-extents(outline)
  assert(
    extents != none,
    message: "port() needs a node shape with a drawable boundary; got " + repr(outline.kind),
  )
  let (hw, hh) = extents
  let target = rotate-point(
    gate-port-offset(hw, hh, legs, side, index, spacing: port-spacing),
    rotate,
  )
  let (tx, ty) = (num(target.at(0)), num(target.at(1)))
  let magnitude = calc.sqrt(tx * tx + ty * ty)
  if magnitude == 0 { return target }
  // Typst angles use screen-space +y down, whereas gate offsets use +y up.
  let radius = shape-radius(outline, calc.atan2(tx, -ty))
  (tx / magnitude * radius, ty / magnitude * radius)
}

#let _draw-outline-simple(outline, fill, stroke, label-body, include-label: true) = {
  if outline.kind == "empty" {
    []
  } else if outline.kind == "bare" {
    if include-label { label-body } else { [] }
  } else if outline.kind == "circle" {
    let (label-x, label-y) = outline.at("label-offset", default: (0pt, 0pt))
    let body = circle(radius: outline.radius, fill: fill, stroke: stroke, inset: 0pt)
    if include-label {
      if label-body == [] { body } else { overlay(
        body,
        align(center + horizon, move(dx: label-x, dy: label-y, label-body)),
      ) }
    } else { body }
  } else if outline.kind == "ellipse" {
    let (label-x, label-y) = outline.at("label-offset", default: (0pt, 0pt))
    let body = ellipse(
      width: 2 * outline.half-width, height: 2 * outline.half-height,
      fill: fill, stroke: stroke, inset: 0pt,
    )
    if include-label {
      overlay(
        body,
        align(center + horizon, move(dx: label-x, dy: label-y, label-body)),
      )
    } else { body }
  } else if outline.kind == "rect" {
    let (width, height) = (
      outline.half-width * 2,
      outline.half-height * 2,
    )
    let (label-x, label-y) = outline.at("label-offset", default: (0pt, 0pt))
    let body = rect(
      width: width, height: height, fill: fill, stroke: stroke,
      radius: outline.radius, inset: 0pt,
    )
    if include-label {
      overlay(
        body,
        align(center + horizon, move(dx: label-x, dy: label-y, label-body)),
      )
    } else { body }
  } else if outline.kind == "polygon" {
    let (half-width, half-height) = (
      outline.half-width,
      outline.half-height,
    )
    let points = outline.points.map(point => (
      point.at(0) + half-width,
      point.at(1) + half-height,
    ))
    let (label-x, label-y) = outline.at("label-offset", default: (0pt, 0pt))
    std-box(width: 2 * half-width, height: 2 * half-height, inset: 0pt, {
      place(top + left, polygon(fill: fill, stroke: stroke, ..points))
      if include-label {
        place(center + horizon, dx: label-x, dy: label-y, label-body)
      }
    })
  } else {
    []
  }
}

#let draw-outline(outline, fill, stroke, label-body) = {
  if outline.kind == "parts" {
    let base = _draw-outline-simple(
      outline.base.outline,
      outline.base.fill,
      outline.base.stroke,
      label-body,
    )
    let draw-part(part) = {
      let part-body = if "body" in part {
        part.body
      } else {
        _draw-outline-simple(part.outline, part.fill, part.stroke, [])
      }
      if part.transform == none {
        part-body
      } else {
        move(dx: part.transform.at(0), dy: part.transform.at(1), part-body)
      }
    }
    let behind = ()
    let front = ()
    for part in outline.parts {
      let layer = part.at("layer", default: "front")
      if layer == "behind" {
        behind.push(part)
      } else if layer == "front" {
        front.push(part)
      }
    }
    if behind.len() == 0 {
      outline.parts.fold(base, (output, part) => overlay(output, draw-part(part)))
    } else {
      let layers = ()
      for part in behind {
        layers.push(draw-part(part))
      }
      layers.push(base)
      for part in front {
        layers.push(draw-part(part))
      }
      // The hidden base fixes the node's local frame while allowing selected
      // parts to paint before the visible body and label.
      overlay(hide(base), ..layers)
    }
  } else {
    _draw-outline-simple(outline, fill, stroke, label-body)
  }
}

// ---------------------------------------------------------------------
// Putting it together for `diagram()`: prepares a node's label/style once,
// derives its outline, and can answer both "draw yourself" and "what's
// your radius at this angle" from that *same* preparation (no re-measuring
// per edge that touches it).
// ---------------------------------------------------------------------

// `font-size` is the diagram-wide label size (`auto` = inherit the
// document's); a node's own `style: (font-size: ..)` wins over it.
// `size-factor` is the diagram's zoom, applied to shape sizes and label text
// alike. Everything here is in pt — no coordinate unit is involved, which is
// what makes node sizes independent of `scale-edges`.
// Only fields that can affect node preparation. Coordinates, names and custom
// metadata are placement concerns; excluding them lets Typst memoize identical
// labels/styles across nodes at different positions.
#let node-visual-spec(n) = (
  kind: n.kind,
  label: n.label,
  style: n.style,
  base-style: n.at("base-style", default: (:)),
  size-scale: n.size-scale,
  port-layout: n.at("port-layout", default: none),
  legs: n.at("legs", default: (:)),
  port-spacing: n.at("port-spacing", default: auto),
  size: n.at("size", default: auto),
)

#let node-outline(
  n,
  preset: (:),
  override: (:),
  font-size: auto,
  size-factor: 1,
  port-spacing: auto,
) = {
  // Factory defaults deliberately sit below the theme preset, so a document
  // can restyle a reusable type. Per-diagram and per-instance styles remain
  // above both.
  let factory = n.at("base-style", default: (:))
  let style = resolve-node-style(
    n.kind, (:), factory, preset, override, n.style,
  )
  // A node's own size multiplier (from `group(scale: ..)`) composes with the
  // diagram-wide zoom, so both shape and label track the diagram's size.
  let k = n.size-scale * size-factor
  style.min-width *= k
  style.min-height *= k
  style.inset = scale-inset(style.inset, k)
  style.radius = if type(style.radius) == length { style.radius * k }
    else if type(style.radius) == relative { style.radius.ratio + style.radius.length * k }
    else { style.radius }
  style.stroke = scale-stroke(style.stroke, k)

  // Fail stale string-based styles before paying for label measurement.
  let selected-shape = effective-shape(style, n.label != none)
  assert(
    type(selected-shape) == function,
    message: "node shape must be a builder function such as shapes.circle",
  )

  let own-size = style.at("font-size", default: auto)
  let base-size = if own-size != auto { own-size } else if font-size != auto { font-size } else { 1em }
  let label-body = if n.label == none { [] } else { tight-text(text(size: base-size * k, n.label)) }
  // Avoid a contextual layout operation for the overwhelmingly common
  // unlabeled node; its ink box is known exactly.
  let measured = if n.label == none { (width: 0pt, height: 0pt) } else { measure(label-body) }

  let resolved-port-spacing = n.at("port-spacing", default: auto)
  if resolved-port-spacing == auto { resolved-port-spacing = port-spacing }
  if resolved-port-spacing != auto { resolved-port-spacing *= k }

  // A gate is a rectangle whose floor grows when an axis has multiple ports,
  // so a many-legged gate has room to fan its wires out. A lone port needs no
  // fan-out floor and therefore leaves compact marker sizes authoritative.
  // That is the *only* thing
  // special about it, and expressing it as a floor rather than as its own
  // geometry means a gate obeys every knob the other kinds do — including a
  // different `shape:` if you want one.
  let style = if n.at("port-layout", default: none) == "box" {
    let legs = n.legs
    let across = calc.max(legs.at("top", default: 0), legs.at("bottom", default: 0))
    let down = calc.max(legs.at("left", default: 0), legs.at("right", default: 0))
    let spacing = if resolved-port-spacing == auto { 7pt * k } else { resolved-port-spacing }
    let port-floor(count, margin) = if count > 1 {
      (count - 1) * spacing + margin * k
    } else {
      0pt
    }
    let (w0, h0) = if n.size != auto {
      (n.size.at(0) * k, n.size.at(1) * k)
    } else {
      (
        calc.max(style.min-width, port-floor(across, 12pt)),
        calc.max(style.min-height, port-floor(down, 9pt)),
      )
    }
    style + (min-width: w0, min-height: h0)
  } else {
    style
  }
  let outline = shape-outline(
    style, label-body, measured,
    builder: selected-shape,
    part-scale: k,
  )
  (label-body: label-body, style: style, outline: outline, measured: measured)
}
