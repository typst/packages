#import "util.typ": is-some

/// Score Box widget
///
/// This function creates an empty table for each task where the scores can be filled in.
/// By default, it reads the number of tasks from the `task` counter,
/// but you can set the task values manually.
#let score-box(
  first-task: none,
  last-task: none,
  tasks: none,
  show-points: true,
  fill-space: false,
  cell-width: 4.5em,
  inset: 0.7em,
  align: center,
) = context {
  let tasks = if tasks != none { tasks } else {
    let first-task = if first-task == none { 1 } else { first-task }
    let last-task = if last-task == none { counter("task").final().first() } else { last-task }
    range(first-task, last-task + 1)
  }

  let points = counter("points").final().first()
  let points-sum = if show-points and points != none and points > 0 [#h(3em) \/ #points] else { v(1em) }

  table(
    columns: if fill-space {
      tasks.map(_ => 1fr) + (1.3fr,)
    } else {
      tasks.map(_ => cell-width) + (1.3 * cell-width,)
    },
    inset: inset,
    align: align,
    table.header(..(tasks.map(i => [*#i*]) + ([$sum$],))),
    ..(tasks).map(_ => v(1em)) + (points-sum,),
  )
}

/// Info Box widget
///
/// This function creates a box with information about the authors of the document.
/// You need to provide the names of the authors and optionally student IDs and/or email addresses.
#let info-box(
  names,
  student-ids: none,
  emails: none,
  inset: 0.7em,
  gutter: 1em,
) = {
  let info = (student-ids, emails).filter(is-some)
  let entries = names.zip(..info).flatten()

  box(stroke: black, inset: inset, grid(
    columns: info.len() + 1,
    gutter: gutter,
    align: left,
    ..entries,
  ))
}
