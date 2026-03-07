#import "@preview/sheetstorm:0.4.0": assignment, custom-enum-numbering, task

#show: assignment.with(
  title: "Task Configuration Example",
  authors: "John Doe",
  score-box-enabled: true,
  initial-task-number: 3,
)

// You can customize the task command like so:
#let task = task.with(
  subtask-numbering: custom-enum-numbering("i)", "1.", "(a)"),
)

#task[
  We have our custom numbering pattern enabled by default:
  + Hi
    + Hey
      + Ho
]

#task(counter-show: false, name: "Name")[
  You can disable the task number in the title.
]

#task(hidden: true, counter: 7)[This task is hidden in the score box.]

#task(counter: n => n + 1)[This would be task 8 but now it is task 9.]
