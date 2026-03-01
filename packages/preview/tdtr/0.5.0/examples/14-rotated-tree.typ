#import "@preview/tdtr:0.5.0": *

#set page(height: auto, width: auto, margin: 1em)
#show: scale.with(125%, reflow: true)

#tidy-tree-graph(
  draw-node: (
    (stroke: none, shape: circle),
    tidy-tree-draws.absolute-draw-node.with(unit: 3em)
  ),
  draw-edge: (marks: "-"),
)[
  - root
    - L #node-attr(rotate: -120deg)
      - L1
      - L2
      - L3 #node-attr(rotate: 120deg)
        - LL
        - LC
        - LR
    - C
      - C1
      - C3
    - R #node-attr(rotate: 120deg)
      - R1 #node-attr(rotate: -60deg)
        - RL #node-attr(rotate: -60deg)
          - RL1 #node-attr(rotate: -60deg)
            - RLL #node-attr(rotate: -60deg)
              - RLL1
              - RLL2
              - RLL3
            - RLC
            - RLR
          - RL2
          - RL3
        - RC
        - RR
      - R2
      - R3
]
