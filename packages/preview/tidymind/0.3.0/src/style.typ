// Single source of how a node looks.
//
// Measuring and drawing must produce exactly the same box. `layout.typ`
// measures THIS body and `draw.typ` draws THIS body, with the colors on top.

/// Text colors: `strong` for the root and branches, `soft` for points,
/// `faint` for details (depth 3 and deeper).
#let default-ink = (
  strong: rgb("#1e293b"),
  soft: rgb("#475569"),
  faint: rgb("#64748b"),
)

/// Role → color. Roles are named by the caller and resolved here.
#let default-emphasis-colors = (
  highlight: rgb("#2a72ae"),
  warning: rgb("#b45309"),
  definition: rgb("#2e7d32"),
  example: rgb("#1769aa"),
)

/// Role → the short tag drawn in front of the label when `markers: "role"`.
#let default-emphasis-labels = (
  highlight: "key",
  warning: "warn",
  definition: "def.",
  example: "e.g.",
)

#let styles = ("boxed", "outline", "technical", "bar", "block")

/// Depth class: 0 root, 1 branch, 2 point, 3 detail (and everything deeper).
#let level(depth) = calc.min(depth, 3)

/// Top inset of a node, whatever shape `inset` was given in.
#let inset-top(inset) = {
  if type(inset) == length { return inset }
  inset.at("top", default: inset.at("y", default: inset.at("rest", default: 0pt)))
}

/// Geometry and typography of a node, by style and depth.
///
/// - `"boxed"`: every node is a rounded box, the root filled with its color.
/// - `"outline"`: the root over a rule, a branch beside a capsule in its color,
///   deeper nodes plain text.
/// - `"technical"`: the root over a rule, a branch numbered (01, 02) over a rule
///   in its color, points with a square marker, details with a hollow one.
/// - `"bar"`: the root and branches over thick rules; pairs with `edge: "tapered"`.
/// - `"block"`: the root and branches filled, deeper nodes plain text.
///
/// `emphasized` belongs here: a role makes the label heavier, and weight
/// changes how wide the label is. `surfaced` turns the node into a tinted card.
#let node-spec(style, depth, emphasized: false, surfaced: false) = {
  let emph(weight) = if emphasized and weight == "regular" { "semibold" } else { weight }
  let lv = level(depth)
  let plain = (radius: 0pt, frame: "none", rule: none, capsule: false, prefix: none)
  let point = (..plain, scale: 1.0, weight: emph("regular"), inset: (x: 2pt, y: 2pt), ink: "soft")
  let detail = (..point, scale: 0.92, ink: "faint")

  let spec = if style == "boxed" {
    (..plain, scale: 1.0, weight: emph(if depth == 0 { "bold" } else { "regular" }),
      inset: (x: 8pt, y: 4pt), radius: 4pt, frame: "box", ink: "strong")
  } else if style == "outline" {
    if lv == 0 { (..plain, scale: 1.5, weight: "bold", inset: (x: 2pt, top: 3pt, bottom: 4pt), rule: 1.2pt, ink: "strong") }
    else if lv == 1 { (..plain, scale: 1.1, weight: emph("semibold"), inset: (left: 8pt, rest: 3pt), capsule: true, ink: "strong") }
    else if lv == 2 { point } else { detail }
  } else if style == "technical" {
    if lv == 0 { (..plain, scale: 1.5, weight: "bold", inset: (x: 2pt, top: 2pt, bottom: 6pt), rule: 1.6pt, ink: "strong") }
    else if lv == 1 { (..plain, scale: 1.05, weight: emph("semibold"), inset: (x: 3pt, top: 2pt, bottom: 6pt), rule: 1.4pt, prefix: "number", ink: "strong") }
    else if lv == 2 { (..point, prefix: "square") } else { (..detail, prefix: "square-hollow") }
  } else if style == "bar" {
    if lv == 0 { (..plain, scale: 1.5, weight: "bold", inset: (x: 3pt, top: 2pt, bottom: 7pt), rule: 3.4pt, ink: "strong") }
    else if lv == 1 { (..plain, scale: 1.1, weight: emph("semibold"), inset: (x: 4pt, top: 2pt, bottom: 5pt), rule: 1.8pt, ink: "strong") }
    else if lv == 2 { point } else { detail }
  } else {
    if lv == 0 { (..plain, scale: 1.3, weight: "bold", inset: (x: 9pt, y: 5pt), radius: 4pt, frame: "filled", ink: "on-fill") }
    else if lv == 1 { (..plain, scale: 1.0, weight: "semibold", inset: (x: 7pt, y: 3.5pt), radius: 4pt, frame: "filled", prefix: "number", ink: "on-fill") }
    else if lv == 2 { point } else { detail }
  }

  // A surface is a tinted card. It replaces the rule (the card already marks
  // the node), keeps the capsule inside, and never applies to a filled node.
  if surfaced and spec.frame in ("none", "box") {
    spec = (..spec, frame: "surface", rule: none, radius: 4pt,
      inset: (left: if spec.capsule { 10pt } else { 7pt }, right: 7pt, y: 3.5pt))
  }
  spec
}

/// Colors for a node. `color` is the branch color; `emphasis` the role color
/// that recolors the label (`markers: "none"`), or `none`; `role` the color of
/// the role tag (`markers: "role"`), or `none`. `neutral: true` gives the same
/// shapes with no color: that is how the measuring pass runs.
#let node-paint(spec, depth, color, ink, emphasis, role: none, neutral: false) = {
  let k(c) = if neutral { black } else { c }
  let frame = spec.frame
  let base = if spec.ink == "on-fill" { white } else { ink.at(spec.ink) }
  let label = if emphasis != none and depth > 0 and frame not in ("box", "filled") { emphasis } else { base }
  let common = (
    rule: if spec.rule == none { none } else if depth == 0 { k(ink.strong) } else { k(color) },
    prefix: if frame == "filled" { if neutral { black } else { white.transparentize(25%) } } else { k(color) },
    capsule: k(color),
    tag: if role == none { k(black) } else { k(role) },
    tag-fill: if neutral or role == none { none } else { role.lighten(88%) },
  )
  if frame == "box" {
    let root = depth == 0
    return (..common,
      fill: if neutral { none } else if root { color } else { white },
      stroke: if root { none } else { 0.8pt + k(color) },
      text: if neutral { black } else if root { white } else { ink.strong })
  }
  if frame == "filled" {
    return (..common, fill: k(if depth == 0 { ink.strong } else { color }), stroke: none, text: k(white))
  }
  if frame == "surface" {
    return (..common,
      fill: if neutral { none } else { color.lighten(90%) },
      stroke: 0.6pt + (if neutral { black } else { color.lighten(68%) }),
      text: k(label))
  }
  (..common, fill: none, stroke: none, text: k(label))
}

/// Thickness of the edge leaving a node at `depth`.
#let edge-width(style, depth) = {
  if style == "boxed" { return 1pt }
  if style == "bar" { return if depth == 0 { 1.8pt } else if depth == 1 { 0.9pt } else { 0.7pt } }
  if depth == 0 { 1.4pt } else if depth == 1 { 0.9pt } else { 0.6pt }
}

/// The node body: the one box that gets both measured and drawn. `width` is
/// `auto` while measuring the natural size, and a fixed length once the layout
/// knows how wide the node ended up. `side` is where the node sits: on the left
/// (`-1`) the label is right-aligned, so a wrapped label ends where its edge
/// arrives. Alignment never changes the box, so measuring needs no side.
#let node-body(content, spec, paint, font, text-size, width: auto, number: none, tag: none, mono-font: "DejaVu Sans Mono", side: 1) = {
  let size = text-size * spec.scale
  let marks = ()
  if spec.prefix == "number" and number != none {
    marks.push(text(font: mono-font, size: size * 0.78, weight: "bold", fill: paint.prefix, number))
  } else if spec.prefix in ("square", "square-hollow") {
    let s = size * 0.4
    marks.push(box(width: s, height: s, radius: s * 0.2, baseline: -(size * 0.3 - s / 2),
      fill: if spec.prefix == "square" { paint.prefix } else { none },
      stroke: if spec.prefix == "square" { none } else { 0.7pt + paint.prefix }))
  }
  if tag != none {
    // The vertical padding is an outset: the tag text sits on the line's
    // baseline and the tint does not make the line taller. The tag's own text
    // stays left-aligned: inherited right alignment shifts it off-center in
    // its tint on the left side.
    marks.push(box(fill: paint.tag-fill, radius: 2pt, inset: (x: 2.2pt), outset: (y: 1.2pt), {
      set align(left)
      text(font: mono-font, size: size * 0.72, weight: "bold", fill: paint.tag, tag)
    }))
  }
  // Marks go inline at the start of the label's first paragraph, so a mark
  // and the first line share one baseline whatever the label's font or size.
  // A hanging indent as wide as the marks keeps a wrapped label aligned after
  // them. It only applies to a real paragraph, which the closing `parbreak`
  // makes; an explicit `par(..)` would drop block content (lists, display
  // math, paragraph breaks). (`measure` needs context: both passes have one.)
  let label = if marks.len() == 0 { content } else {
    let lead = marks.join(h(size * 0.35)) + h(size * 0.45)
    {
      set par(hanging-indent: measure(lead).width)
      lead + content
      parbreak()
    }
  }
  box(
    width: width,
    fill: paint.fill,
    stroke: paint.stroke,
    radius: spec.radius,
    inset: spec.inset,
    {
      // A node label is a label, not a document paragraph: the document's
      // justification, first-line indent and hyphenation must not leak into
      // it, including the paragraph that carries marks. Nor does its
      // alignment: a map in a centered figure keeps its labels flush.
      set par(justify: false, first-line-indent: 0pt)
      set align(if side < 0 { right } else { left })
      set text(hyphenate: false)
      text(font: font, size: size, weight: spec.weight, fill: paint.text, label)
    },
  )
}
