#import "@preview/cetz:0.5.2"
#import "src/tree.typ": normalize, prune
#import "src/layout.typ": measure-tree, layout-tree
#import "src/draw.typ": draw-mindmap

#let default-palette = (
  rgb("#2563eb"), rgb("#16a34a"), rgb("#dc2626"),
  rgb("#9333ea"), rgb("#ea580c"), rgb("#0891b2"),
)

/// Constrói um nó da árvore. `content` é o rótulo; filhos são variádicos.
#let node(content, ..children) = normalize((
  content: content,
  children: children.pos(),
))

/// Desenha o mapa mental completo (layout + desenho via CeTZ).
#let mindmap(
  root,
  palette: default-palette,
  font: "Inter",
  text-size: 9pt,
  node-max-width: 6cm,
  max-depth: 6,
  h-gap: 40pt,
  v-gap: 10pt,
) = context {
  let t = prune(normalize(root), max-depth)
  let measured = measure-tree(t, node-max-width, font, text-size)
  let placed = layout-tree(measured, h-gap, v-gap)
  cetz.canvas(length: 1pt, draw-mindmap(placed, palette, font, text-size))
}
