#import "@preview/taskize:0.2.6": tasks

#set page(width: 14cm, height: auto, margin: 1cm)

= Column Spanning

Basic spanning in 3 columns:

#tasks(columns: 3)[
  + Item A
  + Item B
  + Item C
  +(2) This spans 2 columns
  + Item F
  +() This item spans all 3 columns
  + Item G
  + Item H
]

Multiple choice with explanation:

#tasks(columns: 2, label: "A)")[
  + Paris
  + London
  + Berlin
  + Rome
  +() *Explanation:* Paris is the capital and largest city of France, known for the Eiffel Tower and as a global center of art and culture.
]

Exercise with full-width notes:

#tasks(columns: 3, label: "1)")[
  + $x + 2 = 5$
  + $3x = 12$
  + $2x - 1 = 7$
  +() *Hint:* Isolate the variable on one side of the equation
  + $x^2 = 16$
  + $5x + 3 = 18$
  + $4x - 2 = 10$
]
