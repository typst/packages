#import "@preview/tdtr:0.5.2": *

#set page(height: auto, width: auto, margin: 1em)
#show: scale.with(125%, reflow: true)

#let custom-tree-graph = tidy-tree-graph.with(
  draw-node: (
    ((label,)) => (label: text(blue)[#label]),
    (shape: circle, fill: yellow),
    (width: 2em),
  ),
  draw-edge: (
    (.., edge-label) => if edge-label != none { (label: text(green)[#edge-label]) },
    (marks: "|-o", stroke: color.red + .5pt),
  ),
  spacing: (15pt, 25pt),
)
#custom-tree-graph[
  - A
    + 1
    - B
      + 2
      - D
      - E
    + 3
    - C
      + 4
      - F
      - G
]
