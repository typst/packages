#import "@preview/taskize:0.2.0": tasks

#set page(width: 12cm, height: auto, margin: 1cm)

= Bold Labels

Regular weight labels (default):

#tasks[
  + First item
  + Second item
  + Third item
  + Fourth item
]

Bold weight labels for emphasis:

#tasks(label-weight: "bold")[
  + Important task
  + Critical item
  + Key point
  + Must-do action
]

Bold labels with different formats:

#tasks(label: "1)", label-weight: "bold")[
  + Complete assignment
  + Review notes
  + Submit project
]

#tasks(columns: 3, label: "A)", label-weight: "bold")[
  + Option A
  + Option B
  + Option C
  + Option D
  + Option E
  + Option F
]
