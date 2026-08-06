#import "@preview/tdtr:0.6.0": *

#set page(height: auto, width: auto, margin: 1em)
#show: scale.with(125%, reflow: true)

#tidy-tree-graph(
  draw-node: (stroke: none, defocus: 0),
  draw-edge: (
    tidy-tree-draws.south-north-draw-edge,
    (marks: "-"),
  ),
  spacing: (0pt, 15pt),
)[
  #let leaf = node-attr(layer: "leaves")
  - S
    - NP
      - NP
        - Det
          - The #leaf
        - Adj
          - old #leaf
        - N
          - man #leaf
      - PP
        - P
          - with #leaf
        - NP
          - Det
            - a #leaf
          - Adj
            - walking #leaf
          - N
            - stick #leaf
    - VP
      - AdvP
        - Adv
          - suddenly #leaf
      - V
        - realized #leaf
      - S'
        - Comp
          - that #leaf
        - S
          - NP
            - Det
              - his #leaf
            - N
              - dog #leaf
          - VP
            - Aux
              - had #leaf
            - Aux
              - been #leaf
            - V
              - chasing #leaf
            - NP
              - Det
                - a #leaf
              - N
                - squirrel #leaf
            - PP
              - P
                - in #leaf
              - NP
                - Det
                  - the #leaf
                - N
                  - park #leaf
]
