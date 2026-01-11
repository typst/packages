#import "@preview/tasks:0.1.0": tasks, tasks-reset

#set page(width: 12cm, height: auto, margin: 1cm)

= Resume Numbering

First block:
#tasks[
  + First
  + Second
  + Third
]

Some text between blocks...

Second block (resumed):
#tasks(resume: true)[
  + Fourth
  + Fifth
  + Sixth
]

After reset:
#tasks-reset()

#tasks[
  + Back to one
  + Two again
]
