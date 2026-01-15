#import "@preview/tasks:0.2.0": tasks

#set page(width: 12cm, height: auto, margin: 1cm)

= Flow Directions

== Horizontal Flow (default)
Items fill rows first: a b | c d | e f

#tasks(columns: 2, flow: "horizontal")[
  + a
  + b
  + c
  + d
  + e
  + f
]

== Vertical Flow
Items fill columns first: a c e | b d f

#tasks(columns: 2, flow: "vertical")[
  + a
  + b
  + c
  + d
  + e
  + f
]
