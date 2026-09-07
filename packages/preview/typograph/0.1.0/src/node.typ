#import "utility.typ": unwrap-node, tight-text
#import "style.typ": (
  resolve-node-style, scale-stroke, box-base-style, gate-base-style,
)
#import "shape.typ": build-outline
#import "geometry.typ": (
  num, resolve-inset, rounded-rect-radius, ellipse-radius,
  polygon-radius, rotate-point,
)

// `box()` below shadows the built-in of the same name; keep a handle to it
// under a different name before that happens.
#let std-box = box

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
#let side-port-offset(n, extent, index) = {
  if n == 1 { 0pt }
  else {
    let margin = extent * 0.7
    -margin + 2 * margin * index / (n - 1)
  }
}

#let gate-port-offset(hw, hh, legs, side, index) = {
  let n = legs.at(side, default: 0)
  if side == "left" { (-hw, side-port-offset(n, hh, index)) }
  else if side == "right" { (hw, side-port-offset(n, hh, index)) }
  else if side == "top" { (side-port-offset(n, hw, index), hh) }
  else { (side-port-offset(n, hw, index), -hh) }
}

/// A generic labeled gate box (e.g. for CVQC circuit gates like the
/// displacement, squeezing, or beam-splitter gates). `legs` gives the number
/// of wire attachment points per side; connect to one with `port(g, "left",
/// index: 0)`.
///
/// Sized like every other node: in pt, from the label plus `inset`, floored
/// at a minimum that grows with the leg counts so a many-legged gate has room
/// to fan out. It therefore follows the diagram's `scale` zoom and ignores
/// `scale-edges`, exactly as the spiders do. `size: (width, height)` (lengths)
/// overrides that minimum; `inset:` is the label-to-edge padding.
#let gate(
  x, y, label,
  legs: (left: 1, right: 1),
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
    size: size, legs: legs, port-layout: "box",
  )
}

/// Refers to one wire attachment point on a `gate()`, e.g. `zx.port(g,
/// "left")`, `zx.port(g, "right", 1)` or `zx.port(g, "right", index: 1)`. Usable anywhere an edge
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

#let shape-outline(style, label-body, measured, builder: auto) = {
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
  outline
}

// Distance from a shape outline's origin to its boundary along `angle`
// (Typst screen convention: 0deg = +x, 90deg = +y-down) — used to attach
// an edge to a node's true silhouette instead of its raw center point.
#let shape-radius(outline, angle) = {
  if outline.kind in ("empty", "bare") { 0pt }
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
#let gate-port-on-outline(outline, legs, side, index, rotate: 0deg) = {
  assert(type(rotate) == angle, message: "gate port rotation must be an angle")
  let extents = outline-half-extents(outline)
  assert(
    extents != none,
    message: "port() needs a node shape with a drawable boundary; got " + repr(outline.kind),
  )
  let (hw, hh) = extents
  let target = rotate-point(
    gate-port-offset(hw, hh, legs, side, index),
    rotate,
  )
  let (tx, ty) = (num(target.at(0)), num(target.at(1)))
  let magnitude = calc.sqrt(tx * tx + ty * ty)
  if magnitude == 0 { return target }
  // Typst angles use screen-space +y down, whereas gate offsets use +y up.
  let radius = shape-radius(outline, calc.atan2(tx, -ty))
  (tx / magnitude * radius, ty / magnitude * radius)
}

#let draw-outline(outline, fill, stroke, label-body) = {
  if outline.kind == "empty" {
    []
  } else if outline.kind == "bare" {
    label-body
  } else if outline.kind == "circle" {
    let (label-x, label-y) = outline.label-offset
    circle(radius: outline.radius, fill: fill, stroke: stroke, inset: 0pt,
      align(center + horizon, move(dx: label-x, dy: label-y, label-body)))
  } else if outline.kind == "ellipse" {
    let (label-x, label-y) = outline.label-offset
    ellipse(
      width: 2 * outline.half-width, height: 2 * outline.half-height,
      fill: fill, stroke: stroke, inset: 0pt,
      align(center + horizon, move(dx: label-x, dy: label-y, label-body)),
    )
  } else if outline.kind == "rect" {
    let (width, height) = (
      outline.half-width * 2,
      outline.half-height * 2,
    )
    let (label-x, label-y) = outline.label-offset
    rect(
      width: width, height: height, fill: fill, stroke: stroke,
      radius: outline.radius, inset: 0pt,
      align(center + horizon, move(dx: label-x, dy: label-y, label-body)),
    )
  } else if outline.kind == "polygon" {
    let (half-width, half-height) = (
      outline.half-width,
      outline.half-height,
    )
    let points = outline.points.map(point => (
      point.at(0) + half-width,
      point.at(1) + half-height,
    ))
    let (label-x, label-y) = outline.label-offset
    std-box(width: 2 * half-width, height: 2 * half-height, inset: 0pt, {
      place(top + left, polygon(fill: fill, stroke: stroke, ..points))
      place(center + horizon, dx: label-x, dy: label-y, label-body)
    })
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
// Multiplies every length in an `inset:` spec, whichever form it took.
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
  size: n.at("size", default: auto),
)

#let node-outline(
  n,
  preset: (:),
  override: (:),
  font-size: auto,
  size-factor: 1,
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

  // A gate is a rectangle whose floor grows with its leg counts, so a
  // many-legged gate has room to fan its wires out. That is the *only* thing
  // special about it, and expressing it as a floor rather than as its own
  // geometry means a gate obeys every knob the other kinds do — including a
  // different `shape:` if you want one.
  let style = if n.at("port-layout", default: none) == "box" {
    let legs = n.legs
    let across = calc.max(legs.at("top", default: 0), legs.at("bottom", default: 0))
    let down = calc.max(legs.at("left", default: 0), legs.at("right", default: 0))
    let (w0, h0) = if n.size != auto {
      (n.size.at(0) * k, n.size.at(1) * k)
    } else {
      (
        calc.max(style.min-width, 7pt * across * k + 12pt * k),
        calc.max(style.min-height, 7pt * down * k + 9pt * k),
      )
    }
    style + (min-width: w0, min-height: h0)
  } else {
    style
  }
  let outline = shape-outline(
    style, label-body, measured,
    builder: selected-shape,
  )
  (label-body: label-body, style: style, outline: outline, measured: measured)
}
