/// some pre-defined variants for tidy-tree-graph
#import "core.typ" : tidy-tree-graph, tidy-tree-draws, fletcher.shapes
#import "utils.typ" : list-from-content

/// convert content into a tree graph
/// suitable for debugging or visualizing the content structure
#let content-tree-graph(body, ..args) = tidy-tree-graph(list-from-content(body), ..args)

/// suitable for the trees whose nodes and edges have simple and short content, e.g., a binary tree
/// use #metadata("nil") to mark nil nodes which only affect layout but do not be drawn
#let binary-tree-graph = tidy-tree-graph.with(
  node-inset: 4pt,
  node-width: 1.6em,
  spacing: (15pt, 15pt),
  draw-node: (
    tidy-tree-draws.circle-draw-node,
    tidy-tree-draws.metadata-match-draw-node.with(
      matches: (
        nil: (post: x => none)
      )
    ),
    tidy-tree-draws.label-match-draw-node.with(
      matches: (
        nil: (post: x => none)
      )
    ),
    (stroke: .5pt)
  ),
  draw-edge: (
    tidy-tree-draws.metadata-match-draw-edge.with(
      to-matches: (
        nil: (post: x => none),
      )
    ),
    tidy-tree-draws.label-match-draw-edge.with(
      to-matches: (
        nil: (post: x => none)
      )
    ),
    (marks: "-", stroke: .5pt),
  )
)

/// specialized for red-black trees, with color-coded nodes and hidden nil edges
/// use #metadata("red") to mark red nodes whose fill color is red and #metadata("nil") to mark nil nodes which only affect layout but do not be drawn
#let red-black-tree-graph = tidy-tree-graph.with(
  node-inset: 4pt,
  node-width: 1.6em,
  spacing: (15pt, 15pt),
  draw-node: (
    tidy-tree-draws.circle-draw-node,
    tidy-tree-draws.metadata-match-draw-node.with(
      matches: (
        red: (fill: color.rgb("#bb3e03")),
        nil: (post: x => none)
      ),
      default: (fill: color.rgb("#001219"))
    ),
    tidy-tree-draws.label-match-draw-node.with(
      matches: (
        red: (fill: color.rgb("#bb3e03")),
        nil: (post: x => none)
      ),
      default: (fill: color.rgb("#001219"))
    ),
    ((label, )) => (label: text(color.white)[#label], stroke: none),
  ),
  draw-edge: (
    tidy-tree-draws.metadata-match-draw-edge.with(
      to-matches: (
        nil: (post: x => none),
      )
    ),
    tidy-tree-draws.label-match-draw-edge.with(
      to-matches: (
        nil: (post: x => none)
      )
    ),
    (marks: "-", stroke: .6pt),
  )
)

/// suitable for the trees whose node are relatively not short, e.g., B-trees
/// use #metadata("nil") to mark nil nodes which only affect layout but do not be drawn
#let b-tree-graph = tidy-tree-graph.with(
  node-inset: 4pt,
  spacing: (15pt, 15pt),
  draw-node: (
    tidy-tree-draws.default-draw-node,
    tidy-tree-draws.metadata-match-draw-node.with(
      matches: (
        nil: (post: x => none)
      )
    ),
    tidy-tree-draws.label-match-draw-node.with(
      matches: (
        nil: (post: x => none)
      )
    ),
    // if the width of the label is less than its height, 
    // it will look like a thin pill, and I think this is unpleasant
    // so to prevent this, we make the width at least equal to the height
    ((label, )) => (
      label: context {
        let (width, height) = measure([#label])
        if width < height {
          box(width: height)[#label]
        } else {
          [#label]
        }
      }
    ),
    (stroke: .5pt, shape: shapes.pill)
  ),
  draw-edge: (
    tidy-tree-draws.metadata-match-draw-edge.with(
      to-matches: (
        nil: (post: x => none),
      )
    ),
    tidy-tree-draws.label-match-draw-edge.with(
      to-matches: (
        nil: (post: x => none)
      )
    ),
    (marks: "-", stroke: .5pt),
  )
)

/// specialized for Fibonacci heaps, with color-coded marked nodes and additional connections between root nodes
/// use #metadata("root") to mark root nodes and #metadata("mark") to mark marked nodes
#let fibonacci-heap-graph = tidy-tree-graph.with(
  node-inset: 4pt,
  node-width: 1.6em,
  spacing: (15pt, 15pt),
  draw-node: (
    tidy-tree-draws.circle-draw-node,
    tidy-tree-draws.metadata-match-draw-node.with(
      matches: (
        // override position to prevent blank area above the diagram
        root: (post: x => none, pos: (0, 1)),
        mark: ((label, )) => (
          label: text(white)[#label], 
          fill: color.rgb("#001219"), 
          stroke: color.rgb("#001219")
        )
      )
    ),
    tidy-tree-draws.label-match-draw-node.with(
      matches: (
        root: (post: x => none, pos: (0, 1)),
        mark: ((label, )) => (
          label: text(white)[#label], 
          fill: color.rgb("#001219"), 
          stroke: color.rgb("#001219")
        )
      )
    )
  ),
  draw-edge: (
    tidy-tree-draws.metadata-match-draw-edge.with(
      from-matches: (
        root: (post: x => none)
      )
    ),
    tidy-tree-draws.label-match-draw-edge.with(
      from-matches: (
        root: (post: x => none)
      )
    ),
    (marks: "-")
  ),
  additional-draw: (nodes, (node, edge)) => {
    // add connections between root nodes
    let tops = nodes.filter(n => n.pos.i == 1);
    let conns = tops.slice(0, tops.len() - 1).zip(tops.slice(1))
      .map(((f, t)) => edge(
        vertices: (f.name, t.name),
        marks: "--"
      ));
    conns
  }
)
