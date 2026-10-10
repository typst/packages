#import "@preview/cetz:0.5.2"
#import "src/tree.typ": normalize, prune
#import "src/options.typ": make-opts
#import "src/layout.typ": measure-tree, layout-tree
#import "src/draw.typ": draw-mindmap
#import "src/style.typ": default-emphasis-colors, default-emphasis-labels, default-ink, styles

/// "Slate": six muted colors, each at least 3.8:1 against white, so a branch
/// color stays readable as text and as a thin rule. Pass `palette:` to change it.
#let default-palette = (
  rgb("#3d6fb6"), rgb("#2b8576"), rgb("#b8732a"),
  rgb("#7d5aa6"), rgb("#b0466a"), rgb("#5a7a2c"),
)

/// Builds a tree node. `content` is the label and the remaining positional
/// arguments are its children.
///
/// - `branch`: index (1..n) into the palette, overriding the color the node
///   would inherit from its position. Its whole subtree takes the same color,
///   unless a descendant sets its own `branch`.
/// - `emphasis`: the role of the node, a key of `emphasis-colors` (and of
///   `emphasis-labels`), by default `highlight`, `warning`, `definition` or
///   `example`.
///
/// Both are given by NAME: the map resolves the color, so a document never has
/// to carry a hex value to say what a node means.
#let node(content, ..children, branch: none, emphasis: none) = normalize((
  content: content,
  children: children.pos(),
  branch: branch,
  emphasis: emphasis,
))

#let _one-of(value, allowed, name) = assert(
  value in allowed,
  message: "tidymind: unknown " + name + " \"" + str(value) + "\", expected one of " + allowed.join(", "),
)

/// Draws a complete mind map: measure, tidy layout, then CeTZ drawing.
///
/// - `style`: `"boxed"` (default), `"outline"`, `"technical"`, `"bar"`, `"block"`.
/// - `palette`: one color per first-level branch, cycled. The default is
///   `default-palette` ("Slate": blue, teal, amber, violet, rose, olive).
/// - `ink` / `emphasis-colors` / `emphasis-labels`: overridable label colors,
///   role colors and role tags; partial dictionaries are merged over the
///   defaults.
/// - `surface`: `"none"`, `"branches"` or `"all"` turn nodes into tinted cards.
/// - `markers`: `"none"` (a role recolors the label) or `"role"` (a short tag
///   from `emphasis-labels` in front of the label, in `mono-font`).
/// - `root-max-width`: the root's wrap width; `auto` is twice `node-max-width`.
/// - `edge`: `"curved"` (default), `"straight"` or `"tapered"` (a filled
///   ribbon that thins from the parent to the child).
/// - `direction`: `"right"` (default), `"left"` or `"both"` (the first
///   branches go right, the rest left, balanced by size).
/// - `align-levels`: every depth starts at one column per side.
#let mindmap(
  root,
  style: "boxed",
  palette: default-palette,
  font: "Inter",
  text-size: 9pt,
  node-max-width: 6cm,
  root-max-width: auto,
  max-depth: 6,
  h-gap: 40pt,
  v-gap: 10pt,
  ink: (:),
  emphasis-colors: (:),
  surface: "none",
  markers: "none",
  emphasis-labels: (:),
  mono-font: "DejaVu Sans Mono",
  edge: "curved",
  direction: "right",
  align-levels: false,
) = context {
  _one-of(style, styles, "style")
  _one-of(surface, ("none", "branches", "all"), "surface")
  _one-of(markers, ("none", "role"), "markers")
  _one-of(edge, ("curved", "straight", "tapered"), "edge")
  _one-of(direction, ("right", "left", "both"), "direction")
  let opts = make-opts(style: style, font: font, text-size: text-size,
    node-max-width: node-max-width, root-max-width: root-max-width, mono-font: mono-font,
    markers: markers, surface: surface, emphasis-labels: emphasis-labels, ink: ink,
    emphasis-colors: emphasis-colors, edge: edge)
  let t = prune(normalize(root), max-depth)
  let placed = layout-tree(measure-tree(t, opts), h-gap, v-gap, direction: direction, align-levels: align-levels)
  cetz.canvas(length: 1pt, draw-mindmap(placed, palette, opts))
}
