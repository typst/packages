// Public graph constructor.

#import "style.typ": resolve
#import "graph-layout.typ": _resolve-graph-layout
#import "graph-render.typ": _render-graph-at-positions
#import "graph-validation.typ": _validate-graph-arguments

// `adjacency` maps each node label to an array of neighbor labels or
// `(neighbor-label, edge-label)` pairs.
// `directed` draws an arrowhead per declared pair; set it to `false` for an
// undirected graph, where a reciprocal pair collapses to one plain edge.
// `labels` swaps a node's drawn content, keyed by its adjacency label, any
// content: math, an image, styled text. `layout` selects circular, linear,
// deterministic force-directed, layered DAG, or fully manual placement.
// `layout-options` configures force and layered placement. `gap` controls the
// linear row, while `radius` controls the automatic circle. `positions`
// accepts absolute `(x, y)` anchors or
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
  layout-options: (:),
  radius: auto,
  gap: auto,
  edge-customizations: (),
  node-customizations: (),
  node-labels: (:),
  style: (:),
) = {
  let _ = _validate-graph-arguments(
    "graph()", adjacency, directed, labels, positions, layout, radius, gap,
    layout-options,
    edge-customizations, node-customizations, node-labels, style,
  )
  let resolved-style = resolve(style)
  let node-positions = _resolve-graph-layout(
    adjacency,
    positions,
    layout,
    radius,
    gap,
    layout-options,
    resolved-style,
    node-customizations,
  )
  (
    diagram: _render-graph-at-positions(
      adjacency,
      directed,
      labels,
      node-positions,
      edge-customizations,
      node-customizations,
      node-labels,
      resolved-style,
    ),
  )
}
