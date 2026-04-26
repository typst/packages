#import "@preview/tdtr:0.4.0": *

#set page(height: auto, width: auto, margin: 1em)

#let root = metadata("root")
#let mark = metadata("mark")
#fibonacci-heap-graph[
  - #root
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
      - 5 #mark
        - 32
        - 7 #mark
          - 13
    - 9
]
