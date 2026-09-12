// Fonte ÚNICA da aparência de um nó.
//
// Medir e desenhar precisam produzir exatamente a mesma caixa. Enquanto isso
// viveu em dois arquivos "espelhados à mão", qualquer ajuste de inset ou de
// peso de fonte num deles desalinhava o traço no outro. Aqui a geometria é
// declarada uma vez: `layout.typ` mede este corpo e `draw.typ` desenha ESTE
// mesmo corpo, com as cores por cima.

/// Text colors. `strong` is the label ink, `soft` the ink of deeper labels in
/// the `"outline"` style.
#let default-ink = (
  strong: rgb("#1e293b"),
  soft: rgb("#475569"),
)

/// Role → color. Roles are named by the caller and resolved here, so a document
/// never has to hardcode a hex value to say "this node is a warning".
#let default-emphasis-colors = (
  highlight: rgb("#2a72ae"),
  warning: rgb("#b45309"),
  definition: rgb("#2e7d32"),
  example: rgb("#1769aa"),
)

/// Geometry and typography of a node, by style and depth.
///
/// - `"boxed"`: every node is a rounded box, the root filled with its color.
/// - `"outline"`: no boxes at all. The root is a heading over a baseline rule,
///   a first-level branch is a label resting on a rule in its branch color, and
///   deeper nodes are plain text. Hierarchy comes from size, weight and color.
///
/// `emphasized` belongs HERE, not in the painting step: a role makes the label
/// heavier as well as colored, and weight changes how wide the label is. Left
/// out of the spec, a node would be measured light and drawn heavy — and then
/// the label no longer fits the box the layout reserved for it.
#let node-spec(style, depth, emphasized: false) = {
  let emph(weight) = if emphasized and weight == "regular" { "semibold" } else { weight }

  if style == "outline" {
    if depth == 0 {
      (scale: 1.5, weight: "bold", inset: (x: 2pt, y: 3pt), frame: "underline")
    } else if depth == 1 {
      (scale: 1.1, weight: "semibold", inset: (left: 6pt, rest: 3pt), frame: "side-rule")
    } else {
      (scale: 1.0, weight: emph("regular"), inset: (x: 2pt, y: 2pt), frame: "none")
    }
  } else {
    (
      scale: 1.0,
      weight: emph(if depth == 0 { "bold" } else { "regular" }),
      inset: (x: 8pt, y: 4pt),
      radius: 4pt,
      frame: "box",
    )
  }
}

/// Colors for a node: `(fill, stroke, text)`.
///
/// `color` is the resolved branch color and `emphasis` the resolved role color
/// (`none` when the node has no role). Pass `neutral: true` to get the same
/// shapes with no color — that is how the measuring pass runs, so it produces
/// the exact geometry of the drawing pass.
#let node-paint(spec, depth, color, ink, emphasis, neutral: false) = {
  let frame = spec.frame

  if frame == "box" {
    let root = depth == 0
    return (
      fill: if neutral { none } else if root { color } else { white },
      stroke: if root { none } else { 0.8pt + (if neutral { black } else { color }) },
      text: if neutral { black } else if root { white } else { ink.strong },
    )
  }
  if frame == "underline" {
    return (
      fill: none,
      stroke: (bottom: 1.2pt + (if neutral { black } else { ink.strong })),
      text: if neutral { black } else { ink.strong },
    )
  }
  if frame == "side-rule" {
    return (
      fill: none,
      stroke: (left: 2pt + (if neutral { black } else { color })),
      text: if neutral { black } else if emphasis == none { ink.strong } else { emphasis },
    )
  }
  (
    fill: none,
    stroke: none,
    text: if neutral { black } else if emphasis == none { ink.soft } else { emphasis },
  )
}

/// Thickness of the edge leaving a node at `depth`. In `"outline"` the stroke
/// thins out with depth, which reads as a branch tapering into twigs; in
/// `"boxed"` every edge keeps the same weight.
#let edge-width(style, depth) = {
  if style != "outline" { return 1pt }
  if depth == 0 { 1.4pt } else if depth == 1 { 0.9pt } else { 0.6pt }
}

/// The node body itself — the one box that gets both measured and drawn.
/// `width` is `auto` while measuring the natural size, and a fixed length once
/// the layout knows how wide the node ended up.
#let node-body(content, spec, paint, font, text-size, width: auto) = box(
  width: width,
  fill: paint.fill,
  stroke: paint.stroke,
  radius: spec.at("radius", default: 0pt),
  inset: spec.inset,
  text(
    font: font,
    size: text-size * spec.scale,
    weight: spec.weight,
    fill: paint.text,
  )[#content],
)
