#import "@preview/tdtr:0.5.6": *

#set page(height: auto, width: auto, margin: 1em)
#show: scale.with(125%, reflow: true)

#tidy-tree-graph(
  draw-node: (defocus: 0), // set to 0 to force the edge ends exactly to north
  draw-edge: tidy-tree-draws.horizontal-vertical-draw-edge,
)[
  - Hello
    - World
      - How
        - Whats
          - Day
        - the
          - Nest
        - Time
          - World
            - Whats
              - Day
            - the
            - Time
              - Hello
            - Today
            - Something
              - Interesting
      - This
      - Day
        - Hello
      - People
    - Things
    - Become
    - Somehow
    - are
      - People
      - Hello
        - World
        - Day
          - Hello
          - World
          - Fine
          - I'm
          - Very
            - Happy
            - That
            - They
            - have
            - what
        - you
        - Byte
        - integer
        - Today
      - you
      - Among
]

