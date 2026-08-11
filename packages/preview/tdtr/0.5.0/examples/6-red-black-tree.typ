#import "@preview/tdtr:0.5.0": *

#set page(height: auto, width: auto, margin: 1em)
#show: scale.with(125%, reflow: true)

#red-black-tree-graph[
  - M
    - E
      - N <red>
      - P <red>
    - Q <red>
      - O
        - N <red>
        - P <nil>
      - Y
        - X <red>
        - Z <red>
]
