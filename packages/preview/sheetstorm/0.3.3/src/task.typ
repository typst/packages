#import "numbering.typ": apply-numbering-pattern, subtask-numbering-pattern
#import "i18n.typ"

/// A task block
///
/// Use this function to create a section for each task.
/// It supports customized task numbers, points and bonus tasks.
/// ```typst
/// #task(name: "Pythagorean theorem")[
///   _What is the Pythagorean theorem?_
///
///   $ a^2 + b^2 = c^2 $
/// ]
/// ```
#let task(
  name: none,
  task-string: none,
  counter-show: true,
  counter-reset: none,
  subtask-numbering: false,
  subtask-numbering-pattern: subtask-numbering-pattern,
  points: none,
  points-show: true,
  points-string: none,
  bonus: false,
  bonus-show-star: true,
  hidden: false,
  space-above: auto,
  space-below: 2em,
  content,
) = {
  let task-count = counter("sheetstorm-task")
  if counter-reset == none { task-count.step() } else { task-count.update(counter-reset) }

  let points-enabled = false
  let current-points
  let display-points

  if type(points) == int {
    points-enabled = true
    current-points = points
    display-points = [#points]

  // multiple points specified, e.g. `points: (1, 3, 1)`, gets rendered as "1 + 3 + 1"
  } else if type(points) == array and points.map(p => type(p) == int).reduce((a, b) => a and b) {
    points-enabled = true
    current-points = points.sum()
    display-points = points.map(str).intersperse(" + ").sum()
  }

  state("sheetstorm-points").update(if points-enabled { current-points })
  state("sheetstorm-bonus").update(bonus)
  state("sheetstorm-hidden-task").update(hidden)

  task-string = if task-string == none { context i18n.task() } else { task-string }
  points-string = if points-string == none { context i18n.points() } else { points-string }

  let title = {
    task-string
    if counter-show {
      if task-string != "" [ ]
      context task-count.display()
    }
    if name != none [: #emph(name)]
    if bonus and bonus-show-star [\*]
  }

  block(width: 100%, above: space-above, below: space-below)[
    #set enum(
      full: true,
      numbering: if subtask-numbering {
        apply-numbering-pattern.with(numbering-pattern: subtask-numbering-pattern)
      } else {
        apply-numbering-pattern
      }
    )

    #block({
      show heading: box
      [= #title <sheetstorm-task>]
      if points-enabled and points-show {
        h(1fr)
        [(#display-points #points-string)]
      }
    })
    #content
  ]
}
