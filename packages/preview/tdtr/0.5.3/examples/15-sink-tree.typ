#import "@preview/tdtr:0.5.3": *

#set page(height: auto, width: auto, margin: 1em)
#show: scale.with(125%, reflow: true)

#tidy-tree-graph[
  - DP
    - D #node-attr(sink: 6)
    - NP
      - CP
        - C #node-attr(sink: 4)
        - TP
          - vP
            - v #node-attr(sink: 2)
            - VP
              - V'
                - V
                - DP
              - DP #node-attr(sink: 1)
          - T #node-attr(sink: 3)
      - N #node-attr(sink: 5)
]
