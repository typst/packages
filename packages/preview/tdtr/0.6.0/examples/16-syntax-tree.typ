#import "@preview/tdtr:0.6.0": *

#set page(height: auto, width: auto, margin: 1em)
#show: scale.with(125%, reflow: true)

#tidy-tree-graph(
  draw-node: (
    stroke: none,
    defocus: 0, // set to 0 to force the edge to start exactly from south
  ),
  draw-edge: (
    tidy-tree-draws.south-north-draw-edge,
    (marks: "-"),
  ),
)[
  #let sink(n) = node-attr(sink: n)
  - S
    - NP
      - Det
        - The #sink(2)
      - Adj
        - big #sink(2)
      - N
        - dog #sink(2)
    - VP
      - V
        - barked #sink(2)
      - PP
        - P
          - at #sink(1)
        - NP
          - Det
            - the
          - N
            - mailman
]
