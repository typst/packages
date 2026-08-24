#import "@preview/cetz:0.5.2"
#import "src/tree.typ": normalize, prune
#import "src/layout.typ": measure-tree, layout-tree
#import "src/draw.typ": draw-mindmap
#import "src/style.typ": default-emphasis-colors, default-ink

#let default-palette = (
  rgb("#2563eb"), rgb("#16a34a"), rgb("#dc2626"),
  rgb("#9333ea"), rgb("#ea580c"), rgb("#0891b2"),
)

#let styles = ("boxed", "outline")

/// Builds a tree node. `content` is the label and the remaining positional
/// arguments are its children.
///
/// - `branch`: index (1..n) into the palette, overriding the color the node
///   would inherit from its position.
/// - `emphasis`: the role of the node — a key of `emphasis-colors`, by default
///   `highlight`, `warning`, `definition` or `example`.
///
/// Both are given by NAME: the map resolves the color, so a document never has
/// to carry a hex value to say what a node means.
#let node(content, ..children, branch: none, emphasis: none) = normalize((
  content: content,
  children: children.pos(),
  branch: branch,
  emphasis: emphasis,
))

/// Draws a complete mind map: measure, tidy layout, then CeTZ drawing.
///
/// - `style`: `"boxed"` (default) draws every node as a rounded box;
///   `"outline"` drops the boxes and builds hierarchy out of type — a root over
///   a baseline rule, branches on a side rule in their color, plain-text leaves.
/// - `palette`: one color per first-level branch, cycled.
/// - `ink` / `emphasis-colors`: overridable color roles; partial dictionaries
///   are merged over the defaults.
#let mindmap(
  root,
  style: "boxed",
  palette: default-palette,
  font: "Inter",
  text-size: 9pt,
  node-max-width: 6cm,
  max-depth: 6,
  h-gap: 40pt,
  v-gap: 10pt,
  ink: (:),
  emphasis-colors: (:),
) = context {
  assert(
    style in styles,
    message: "tidymind: unknown style \"" + style + "\", expected one of "
      + styles.join(", "),
  )
  let ink = default-ink + ink
  let emphasis-colors = default-emphasis-colors + emphasis-colors

  let t = prune(normalize(root), max-depth)
  let measured = measure-tree(t, node-max-width, font, text-size, style)
  let placed = layout-tree(measured, h-gap, v-gap)
  cetz.canvas(
    length: 1pt,
    draw-mindmap(placed, palette, style, font, text-size, ink, emphasis-colors),
  )
}
