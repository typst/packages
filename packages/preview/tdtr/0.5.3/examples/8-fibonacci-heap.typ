#import "@preview/tdtr:0.5.3": *

#set page(height: auto, width: auto, margin: 1em)
#show: scale.with(125%, reflow: true)

#fibonacci-heap-graph[
  - R <root> #node-attr(forest: true)
    - 10
      - 11
    - 20
      - 34
        - 35
      - 23
    - 3
      - 14
      - 21
        - 25
      - 5 <mark>
        - 32
        - 7 <mark>
          - 13
    - 9
]
