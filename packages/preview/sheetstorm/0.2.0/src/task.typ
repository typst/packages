#import "numbering.typ": apply-numbering-pattern, subtask-numbering-pattern
#import "i18n.typ"

/// A task block
///
/// Use this function to create a section for each task.
/// It creates a heading and handles spacing.
///
/// ```typst
/// #task(name: "Pythagorean theorem")[
///   _What is the Pythagorean theorem?_
///
///   $ a^2 + b^2 = c^2 $
/// ]
/// ```
#let task(
  name: none,
  show-counter: true,
  reset-counter: none,
  task-string: none,
  subtask-numbering: false,
  subtask-numbering-pattern: subtask-numbering-pattern,
  points: none,
  show-points: true,
  points-string: none,
  point-string: none,
  above: auto,
  below: 2em,
  content,
) = {
  let task-count = counter("task")
  if reset-counter == none { task-count.step() } else { task-count.update(reset-counter) }

  let points-enabled = type(points) == int
  if points-enabled { counter("points").update(p => p + points) }

  task-string = if task-string == none { context i18n.task() }

  point-string = if point-string == none {
    if points-string != none { points-string }
    else { context i18n.point() }
  } else { point-string }

  points-string = if points-string == none { context i18n.points() } else { points-string }

  let title = {
    task-string
    if show-counter [ #context task-count.display()]
    if name != none [: #emph(name)]
  }

  block(width: 100%, above: above, below: below)[
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
      [= #title]
      if points-enabled and show-points {
        let p-string = if points == 1 { point-string } else { points-string }
        h(1fr)
        [(#points #p-string)]
      }
    })
    #content
  ]
}
