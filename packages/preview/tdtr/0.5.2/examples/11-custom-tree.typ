#import "@preview/tdtr:0.5.2": *

#set page(height: auto, width: auto, margin: 1em)
#show: scale.with(125%, reflow: true)

#let custom-tree-graph = tidy-tree-graph.with(
  draw-node: (stroke: .5pt + red),
  draw-edge: (stroke: .5pt + blue, marks: "-}>"),
  spacing: (15pt, 20pt),
  node-width: 2em,
  node-height: 3em,
)
#custom-tree-graph[
  - A
    - B
      - D
      - E
    - C
      - F
      - G
]
