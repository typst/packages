// Generic style schemas and pure resolution helpers. Domain colours and named
// presets live in optional theme modules and are passed to `diagram()`.

#import "shape.typ" as _shapes
#import "geometry.typ": validate-inset, absolute-length, absolute-inset, is-size-length

/// Everything a node style can set, with the value used when it does not.
/// A preset is this dictionary with some entries replaced; a per-node `style:`
/// replaces some more. Custom shape builders may additionally consume
/// their own keys, so this is the built-in schema rather than a closed one.
///
/// - `shape` — an outline-builder function such as `shapes.circle`.
/// - `shape-labelled` — the builder to use *instead* when the node has a
///   label. `auto` means "same shape either way", which is the default: a node
///   does not change form just because you named it. The spiders opt in to
///   `shapes.stadium` in the bundled theme because that is a ZX convention.
/// - `min-width` / `min-height` — the floor, per axis. `min-size` is sugar
///   that sets both.
/// - `inset` — padding between label and outline. A length or number for all
///   four sides, or a dictionary with any of `left`/`right`/`top`/`bottom`/
///   `x`/`y`/`rest`, exactly like Typst's own `inset:`.
/// - `radius` — uniform corner rounding for rectangular builders: a
///   length, percentage, or mixture of both, with Typst's `rect` semantics
///   (`100%` is maximally rounded). Per-corner dictionaries are deliberately
///   outside the outline protocol.
/// - `rotate` / `flip` — orientation knobs consumed by directional polygon
///   builders. A circle is rotation-invariant; built-in axis-aligned
///   ellipse/stadium/rectangle builders reject nonzero rotation rather than
///   silently ignoring it. A custom shape builder may define its own semantics.
/// - `slant` — trapezoid only: how far the top edge rises, as a fraction of
///   the half-height.
/// - `tip` — arrow only: where the body ends and the point begins, as a
///   fraction of the half-width.
/// - `font-size` — overrides the diagram-wide label size for this node.
/// Geometry containing `em` resolves against surrounding text during layout,
/// before zoom; percentage components and unknown extension fields survive.
#let node-defaults = (
  shape: _shapes.empty,
  shape-labelled: auto,
  fill: none,
  stroke: none,
  min-width: 0pt,
  min-height: 0pt,
  inset: 0pt,
  radius: 0pt,
  rotate: 0deg,
  flip: false,
  slant: 0.55,
  tip: 0.32,
  font-size: auto,
)

/// Neutral constructor looks used by the generic renderer. They live with
/// style data—not construction or ZX semantics—so generic box/gate nodes and
/// optional themes can share them without duplicating values.
#let box-base-style = (
  shape: _shapes.rect, fill: none, stroke: 0.6pt + black, inset: 4pt,
)
#let gate-base-style = (
  shape: _shapes.rect, fill: white, stroke: 0.6pt + black,
  min-size: 16pt, inset: 5pt, radius: 1.5pt,
)

/// Everything an edge style can set. Same contract as `node-defaults`: this is
/// the complete list, and a per-edge `style:` replaces entries in it.
///
/// - `stroke` — the wire itself.
/// - `highlight-width` / `highlight-offset` / `highlight-opacity` — the
///   total width, extra centreline separation, and opacity of the two overlay
///   bands `highlight:` draws around the wire.
/// - `label-size` / `label-offset` — the wire label's type size, and how far
///   it sits from the wire (perpendicular, in pt).
/// - `label-fill` / `label-inset` — the label box's background and padding.
/// - `clip` — pull the ends back to each node's true silhouette. Off means the
///   wire runs to the node's centre, which is what you want under a
///   frameless node.
#let edge-defaults = (
  stroke: stroke(
    paint: black, thickness: 0.55pt, cap: "butt", join: "miter",
  ),
  highlight: none,
  highlight-width: 4.0pt,
  highlight-offset: 0pt,
  highlight-opacity: 100%,
  label-size: auto,
  label-offset: 0pt,
  label-fill: white,
  label-inset: 1.5pt,
  clip: true,
)

#let edge-style-keys = edge-defaults.keys()

#let _validate-composite-part-list(parts, source) = {
  assert(
    type(parts) == array or type(parts) == dictionary,
    message: source + " must be an array or dictionary of part specs",
  )
  let entries = if type(parts) == dictionary {
    parts.pairs().map(pair => pair.at(1))
  } else {
    parts
  }
  assert(entries.len() >= 1, message: source + " must contain at least one entry")
  for entry in entries {
    assert(
      type(entry) == function or type(entry) == dictionary,
      message: source + " entries must be builder functions or dictionaries",
    )
    if type(entry) == dictionary and "shape" in entry {
      assert(type(entry.shape) == function, message: source + " entry shape must be a builder function")
    }
  }
}

#let _validate-mark-length(value, source) = {
  if value != auto {
    assert(
      type(value) == length or type(value) == ratio or type(value) == relative,
      message: source + " must be a length, ratio, relative length, or auto",
    )
  }
}

/// Validates the built-in fields of an open node style. Unknown fields remain
/// legal extension data for custom shape builders.
#let validate-node-style(style, source: "node style") = {
  assert(type(style) == dictionary, message: source + " must be a dictionary")
  if "shape" in style {
    assert(type(style.shape) == function, message: source + " shape must be a builder function")
  }
  if "shape-labelled" in style {
    assert(
      style.shape-labelled == auto or type(style.shape-labelled) == function,
      message: source + " shape-labelled must be auto or a builder function",
    )
  }
  if "shape.parts" in style and "parts" in style {
    panic(
      source + " cannot contain both shape.parts and parts; use shape.parts as the canonical key",
    )
  }
  if "shape.parts" in style {
    _validate-composite-part-list(style.at("shape.parts"), "shape.parts")
  }
  if "parts" in style {
    _validate-composite-part-list(style.parts, "parts")
  }
  if "mark" in style {
    assert(
      style.mark == none or style.mark == auto
        or style.mark == "cross" or style.mark == "measurement",
      message: source + " mark must be none, auto, \"cross\", or \"measurement\"",
    )
  }
  if "mark-angle" in style {
    assert(type(style.mark-angle) == angle, message: source + " mark-angle must be an angle")
  }
  if "mark-size" in style {
    _validate-mark-length(style.mark-size, source + " mark-size")
  }
  if "mark-thickness" in style {
    _validate-mark-length(style.mark-thickness, source + " mark-thickness")
  }
  if "mark-fill" in style {
    assert(
      style.mark-fill == none
        or type(style.mark-fill) in (color, gradient, tiling),
      message: source + " mark-fill must be none, a color, gradient, or tiling",
    )
  }
  if "mark-stroke" in style {
    if style.mark-stroke != none and style.mark-stroke != auto {
      let _ = stroke(style.mark-stroke)
    }
  }
  for field in ("min-size", "min-width", "min-height") {
    if field in style {
      let value = style.at(field)
      assert(
        is-size-length(value),
        message: source + " " + field + " must be a non-negative length",
      )
    }
  }
  if "inset" in style {
    let _ = validate-inset(style.inset, source: source + " inset")
  }
  if "radius" in style {
    assert(
      type(style.radius) in (length, ratio, relative),
      message: source + " radius must be a length or percentage",
    )
  }
  if "rotate" in style {
    assert(type(style.rotate) == angle, message: source + " rotate must be an angle")
  }
  if "flip" in style {
    assert(type(style.flip) == bool, message: source + " flip must be a boolean")
  }
  if "slant" in style {
    assert(type(style.slant) in (int, float), message: source + " slant must be a number")
  }
  if "tip" in style {
    assert(type(style.tip) in (int, float), message: source + " tip must be a number")
  }
  if "font-size" in style {
    assert(
      style.font-size == auto or (
        is-size-length(style.font-size, positive: true)
      ),
      message: source + " font-size must be auto or a positive length",
    )
  }
  style
}

/// Validates the intentionally closed edge-style schema. Node styles remain
/// open because custom shape builders may consume custom keys; edge rendering
/// has no equivalent extension point, so accepting a misspelling would only
/// hide a mistake.
#let validate-edge-style(style, source: "edge style") = {
  assert(type(style) == dictionary, message: source + " must be a dictionary")
  if style.len() == 0 { return style }
  let unknown = style.keys().filter(key => key not in edge-style-keys)
  assert(
    unknown.len() == 0,
    message: source + " has unknown key(s): " + unknown.join(", ")
      + " — available: " + edge-style-keys.join(", "),
  )
  if "highlight" in style {
    let value = style.highlight
    assert(
      value == none or type(value) == color or (
        type(value) == array and value.len() in (0, 1, 2)
          and value.all(item => type(item) == color)
      ),
      message: source + " highlight must be none, a color, or an array of zero to two colors",
    )
  }
  if "clip" in style {
    assert(type(style.clip) == bool, message: source + " clip must be a boolean")
  }
  if "highlight-width" in style {
    assert(
      is-size-length(style.highlight-width),
      message: source + " highlight-width must be a non-negative length",
    )
  }
  if "highlight-offset" in style {
    assert(
      type(style.highlight-offset) == length,
      message: source + " highlight-offset must be a length",
    )
  }
  if "highlight-opacity" in style {
    assert(
      type(style.highlight-opacity) == ratio
        and style.highlight-opacity >= 0% and style.highlight-opacity <= 100%,
      message: source + " highlight-opacity must be a percentage from 0% to 100%",
    )
  }
  if "label-size" in style {
    assert(
      style.label-size == auto or (
        is-size-length(style.label-size, positive: true)
      ),
      message: source + " label-size must be auto or a positive length",
    )
  }
  if "label-offset" in style {
    assert(
      type(style.label-offset) == length,
      message: source + " label-offset must be a length",
    )
  }
  if "label-inset" in style {
    let _ = validate-inset(
      style.label-inset,
      source: source + " label-inset",
      allow-number: false,
      allow-relative: true,
    )
  }
  if "label-fill" in style {
    assert(
      style.label-fill == none
        or type(style.label-fill) in (color, gradient, tiling),
      message: source + " label-fill must be none, a color, gradient, or tiling",
    )
  }
  style
}

/// An edge's final style: shared defaults, factory `base-style`, named preset,
/// per-diagram overrides, then the edge's own `style:` and direct arguments.
///
/// The edge itself is passed in rather than its parts, because `stroke:` and
/// `highlight:` are also spellable as direct arguments; funnelling them here
/// keeps a single definition of which wins.
#let _resolve-edge-style(e, overrides, presets, defaults, validate) = {
  if validate {
    let _ = validate-edge-style(overrides, source: "edge style overrides")
    assert(type(presets) == dictionary, message: "edge presets must be a dictionary")
    let _ = validate-edge-style(defaults, source: "theme edge defaults")
  }
  let out = edge-defaults
  if defaults.len() > 0 { out = out + defaults }
  let base = e.at("base-style", default: (:))
  if validate { let _ = validate-edge-style(base, source: "edge base-style") }
  if base != none and base != auto and base.len() > 0 { out = out + base }
  let name = e.at("preset", default: none)
  if name != none {
    assert(
      name in presets,
      message: "unknown edge preset " + repr(name) + " — available: "
        + presets.keys().map(repr).join(", "),
    )
    let preset = presets.at(name)
    if validate {
      let _ = validate-edge-style(preset, source: "edge preset " + repr(name))
    }
    out = out + preset
  }
  for layer in (overrides, e.at("style", default: (:))) {
    if layer != none and layer != auto {
      if validate { let _ = validate-edge-style(layer) }
      if layer.len() > 0 { out = out + layer }
    }
  }
  // Direct constructor arguments are the most specific layer.
  let direct = e.at("stroke", default: auto)
  if direct != auto { out.stroke = direct }
  let highlight = e.at("highlight", default: auto)
  if highlight != auto { out.highlight = highlight }
  let clip = e.at("clip", default: auto)
  if clip != auto { out.clip = clip }
  out
}

/// Validated public resolver for standalone use and advanced integrations.
#let resolve-edge-style(e, overrides, presets: (:), defaults: (:)) = {
  _resolve-edge-style(e, overrides, presets, defaults, true)
}

// Diagram construction has already validated theme/diagram layers once, and
// edge()/edge-type() validate instance/factory layers at construction. Avoid
// repeating those invariant checks for every edge in a large diagram.
#let resolve-edge-style-unchecked(e, overrides, presets: (:), defaults: (:)) = {
  _resolve-edge-style(e, overrides, presets, defaults, false)
}

// Shallow-merges a base style dictionary with zero or more overrides,
// skipping `none`/`auto` overrides so callers can pass those as "no-op".
#let merge-style(base, ..overrides) = {
  assert(type(base) == dictionary, message: "base style must be a dictionary")
  let result = base
  for ov in overrides.pos() {
    // An empty override is a no-op; skipping it avoids rebuilding the dict,
    // which matters because this sits on the per-edge and per-node paths.
    if ov != none and ov != auto {
      assert(type(ov) == dictionary, message: "style override must be a dictionary, got " + repr(ov))
      if ov.len() > 0 { result = result + ov }
    }
  }
  result
}

/// Expands the `min-size` shorthand into the two axes it stands for, so
/// everything downstream can read `min-width`/`min-height` and never has to
/// know the shorthand existed.
#let expand-min-size(style) = {
  assert(type(style) == dictionary, message: "node style must be a dictionary, got " + repr(style))
  if "min-size" not in style { return style }
  let size = style.min-size
  assert(
    is-size-length(size),
    message: "node style min-size must be a non-negative length",
  )
  let out = style
  let _ = out.remove("min-size")
  // An explicit axis wins over the shorthand, whichever order they were given
  // in — `(min-size: 20pt, min-width: 30pt)` reads as "20 tall, 30 wide".
  if "min-width" not in style { out.min-width = size }
  if "min-height" not in style { out.min-height = size }
  out
}

/// A node style resolver for the shared defaults, a preset table, and any
/// later layers supplied by the caller. `node-outline` uses it to order factory
/// defaults before kind presets, then diagram and instance overrides.
#let resolve-node-style(kind, presets, ..overrides) = {
  assert(type(presets) == dictionary, message: "node presets must be a dictionary")
  let out = node-defaults
  for layer in (presets.at(kind, default: (:)),) + overrides.pos() {
    if layer != none and layer != auto {
      assert(type(layer) == dictionary, message: "node style layer must be a dictionary")
      if layer.len() > 0 { out = out + expand-min-size(layer) }
    }
  }
  validate-node-style(out)
}

// Merges two `(kind: style, ..)` dictionaries one level deeper than
// `merge-style`, so a document-wide `(z: (fill: ..))` and a per-diagram
// `(z: (stroke: ..))` combine instead of clobbering each other.
#let merge-per-kind(base, over) = {
  assert(type(base) == dictionary and type(over) == dictionary, message: "node styles must be dictionaries keyed by kind")
  let out = base
  for (kind, style) in over {
    assert(type(style) == dictionary, message: "node style for " + repr(kind) + " must be a dictionary")
    // Expand each precedence layer independently. Otherwise a lower layer's
    // explicit axis can incorrectly defeat a higher layer's `min-size`.
    let later = expand-min-size(style)
    out.insert(
      kind,
      if kind in out { expand-min-size(out.at(kind)) + later } else { later },
    )
  }
  out
}

// Resolve thickness without changing the stroke's other settings or the
// representation of already-absolute specs. Dash lengths are consumed by
// Typst itself in the same surrounding context, not by our geometry math.
#let absolute-stroke(spec) = {
  if spec == none or spec == auto { return spec }
  if type(spec) == length { return absolute-length(spec) }
  let s = stroke(spec)
  if s.thickness == auto or s.thickness.em == 0 { return spec }
  stroke(
    paint: s.paint, thickness: s.thickness.to-absolute(),
    cap: s.cap, join: s.join, dash: s.dash, miter-limit: s.miter-limit,
  )
}

// These layout-boundary normalizers deliberately leave extension fields and
// part collections untouched. Part-local overrides are normalized separately
// before inheriting the already-scaled base style.
#let absolute-node-style(style) = {
  let out = style
  for key in ("min-size", "min-width", "min-height", "radius", "font-size", "mark-size", "mark-thickness") {
    if key in out { out.insert(key, absolute-length(out.at(key))) }
  }
  if "inset" in out { out.inset = absolute-inset(out.inset) }
  for key in ("stroke", "mark-stroke") {
    if key in out { out.insert(key, absolute-stroke(out.at(key))) }
  }
  validate-node-style(out)
}

#let absolute-edge-style(style) = {
  let out = style
  for key in ("highlight-width", "highlight-offset", "label-size", "label-offset") {
    if key in out { out.insert(key, absolute-length(out.at(key))) }
  }
  if "label-inset" in out { out.label-inset = absolute-inset(out.label-inset) }
  if "stroke" in out { out.stroke = absolute-stroke(out.stroke) }
  // All input layers were validated before edge preparation. Only changed
  // lengths need another pass to reject contextually negative dimensions.
  if out == style { out } else { validate-edge-style(out) }
}

/// Scales a stroke's thickness by `factor`, leaving paint, dash and caps
/// alone. Accepts anything Typst accepts as a stroke — a `stroke`, a
/// dictionary, a bare length or colour, `none`, `auto` — so it can be applied
/// to package defaults and user-supplied strokes alike. A stroke with no
/// explicit thickness scales from Typst's 1pt default.
#let scale-stroke(spec, factor) = {
  if factor == 1 or spec == none or spec == auto { return spec }
  if type(spec) == length { return spec * factor }
  let s = stroke(spec)
  let thickness = if s.thickness == auto { 1pt } else { s.thickness }
  stroke(
    paint: s.paint,
    thickness: thickness * factor,
    cap: s.cap,
    join: s.join,
    dash: s.dash,
    miter-limit: s.miter-limit,
  )
}
