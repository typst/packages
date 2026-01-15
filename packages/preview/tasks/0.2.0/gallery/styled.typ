#import "@preview/tasks:0.2.0": tasks, tasks-setup

#set page(width: 12cm, height: auto, margin: 1cm)

= Styled Tasks

#tasks-setup(
  columns: 3,
  label-format: "1)",
  column-gutter: 1.5em,
  row-gutter: 0.8em,
)

== Global Configuration

#tasks[
  + Item 1
  + Item 2
  + Item 3
  + Item 4
  + Item 5
  + Item 6
]

== Four Columns

#tasks(columns: 4)[
  + A
  + B
  + C
  + D
  + E
  + F
  + G
  + H
]

== With Indentation

#tasks(indent: 2em, columns: 2)[
  + Indented item
  + Another one
  + Third item
  + Fourth item
]
