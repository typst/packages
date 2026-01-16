#import "@preview/tdtr:0.5.0": *

#set page(height: auto, width: auto, margin: 1em)
#show: scale.with(125%, reflow: true)

#let huffman-tree-graph = tree-graph-wrapper(
  tree-graph-fn: binary-tree-graph,
  draw-node: ((label,)) => (stroke: none, label: $#label$),
  draw-edge: (_, (pos,), _) => (label: $pos.k$),
)

#huffman-tree-graph[
  - (5)
    - (2)
      - A (1)
      - B (1)
    - (3)
      - C (1)
      - D (2)
]

