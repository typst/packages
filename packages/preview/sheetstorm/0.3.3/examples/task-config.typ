#import "@preview/sheetstorm:0.3.3" as sheetstorm: task

#show: sheetstorm.setup.with(
  title: "Task Configuration Example",
  authors: "John Doe",
  initial-task-number: 3,
)

#let my-custom-numbering-pattern(depth) = {
  if depth == 1 { "i)" }
  else if depth == 2 { "1." }
  else { "(a)" }
}

// You can customize the task command like so:
#let task = task.with(
  counter-show: false,
  subtask-numbering: true,
  subtask-numbering-pattern: my-custom-numbering-pattern,
)

#task(name: "Unnumbered Task")[
  Now, the task numbers are disabled for the whole document.

  Also, we have our custom numbering pattern enabled by default:
  + Hi
    + Hey
      + Ho
]

#task(counter-show: true)[Unless you explicitely enable the counter.]
