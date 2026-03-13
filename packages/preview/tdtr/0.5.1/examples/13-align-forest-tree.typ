#import "@preview/tdtr:0.5.1": *

#set page(height: auto, width: auto, margin: 1em)
#show: scale.with(125%, reflow: true)

#tidy-tree-graph(
  default-node-attr: node-attr(align-to: "middle"),
)[
  - A
    - B #node-attr(forest: true)
      - E
        - G
        - H
        - I
        - K
      - D
    - C #node-attr(align-to: "first")
      - F
      - G #node-attr(align-to: 2)
        - L
        - O
        - P
      - M
      - N
]
