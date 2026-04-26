#import "@preview/tdtr:0.4.3": *

#set page(height: auto, width: auto, margin: 1em)

#fibonacci-heap-graph[
  - R <root>
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
