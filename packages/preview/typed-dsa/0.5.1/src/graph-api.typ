// Public graph constructor.

#import "style.typ": resolve
#import "graph-render.typ": _render-graph
#import "graph-validation.typ": _validate-graph-arguments

// `adjacency` maps each node label to an array of neighbor labels or
// `(neighbor-label, edge-label)` pairs.
// `directed` draws an arrowhead per declared pair; set it to `false` for an
// undirected graph, where a reciprocal pair collapses to one plain edge.
// `labels` swaps a node's drawn content, keyed by its adjacency label, any
// content: math, an image, styled text. `layout` is `"auto"` for the circular
// layout or "linear" for the row layout, plus optional per-node positions,
// or `"manual"` to require every node in `positions`. `gap` controls the spacing
// between nodes in the linear layout, it has no effect on other layouts. `radius`
// controls the
// automatic circle only. `positions` accepts absolute `(x, y)` anchors or
// `(rel: other-label, offset: (dx, dy))` relative placements.
// `edge-customizations` is an array of `(from, to, options)` tuples restyling
// one edge. Options: `stroke:`, `color:`, `pattern:`, `arrow:`,
// `bend:`, `angle:`. `bend` is `"left"`, `"right"`, or `false` (default),
// and `angle` (default `25deg`) sets how sharply a bent edge curves.
#let graph(
  adjacency,
  directed: true,
  labels: (:),
  positions: (:),
  layout: "auto",
  radius: auto,
  gap: auto,
  edge-customizations: (),
  node-customizations: (),
  node-labels: (:),
  style: (:),
) = {
  let _ = _validate-graph-arguments(
    "graph()", adjacency, directed, labels, positions, layout, radius, gap,
    edge-customizations, node-customizations, node-labels, style,
  )
  (
    diagram: _render-graph(adjacency, directed, labels, positions, layout, radius, gap, edge-customizations, node-customizations, node-labels, resolve(style)),
  )
}
