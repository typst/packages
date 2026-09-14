#import "util.typ": is-some, to-content

/// The "score box" widget.
///
/// This function creates an empty table for each task where the scores can be filled in.
/// By default, it reads the number of tasks from the `task` counter,
/// but you can set the task values manually.
///
/// Usually you just want to use the score box that is automatically available in the `assignment` layout.
/// It uses this implementation internally but all configuration is done in the `assignment` function.
///
/// -> content
#let score-box(
  /// Set the score box task list manually.
  ///
  /// If #auto is set, figure out the tasks from the context.
  ///
  /// -> array | auto
  tasks: auto,
  /// Whether to show the points per task. -> bool
  show-points: true,
  /// Whether the points of bonus tasks count into the sum. -> bool
  bonus-show-star: true,
  /// Whether to mark bonus tasks in the score box with a star. -> bool
  bonus-counts-for-sum: false,
  /// Whether to fill all available horizontal space. -> bool
  fill-space: false,
  /// The `inset` value of the score box. -> length
  cell-width: 4.5em,
  /// The `cell-width` value of the score box. -> length
  inset: 0.7em,
) = context {
  let empty = v(1em)

  let display-tasks
  let display-points

  if tasks == auto {
    let task-query = query(<sheetstorm-task>)
    let task-counter = counter("sheetstorm-task")
    let hidden-task-state = state("sheetstorm-hidden-task")
    let points-state = state("sheetstorm-points")
    let bonus-state = state("sheetstorm-bonus")

    let task-query = task-query.filter(t => {
      not hidden-task-state.at(t.location())
    })

    let task-list = task-query.map(t => task-counter.at(t.location()).first())
    let point-list = task-query.map(t => points-state.at(t.location()))
    let bonus-task-list = task-query.map(t => bonus-state.at(t.location()))

    display-tasks = task-list
      .zip(bonus-task-list, exact: true)
      .map(((t, b)) => if b and bonus-show-star [*#t\**] else [*#t*])

    let counting-points = point-list
      .zip(bonus-task-list, exact: true)
      .map(((p, b)) => if not b or bonus-counts-for-sum { p })
      .filter(is-some)

    let points-sum = if counting-points.len() > 0 { counting-points.sum() }

    display-points = (point-list + (points-sum,)).map(p => if show-points
      and p != none [\/ #p] else { empty })
  } else if type(tasks) != array {
    return none
  } else {
    display-tasks = tasks.map(to-content)
    display-points = tasks.map(_ => empty)
  }

  if display-tasks.len() == 0 {
    return none
  }

  table(
    columns: if fill-space {
      display-tasks.map(_ => 1fr) + (1.3fr,)
    } else {
      display-tasks.map(_ => cell-width) + (1.3 * cell-width,)
    },
    inset: inset,
    align: (_, row) => if row == 1 { right } else { center },
    table.header(..(display-tasks + ([$sum$],))),
    ..display-points
  )
}

/// The "info box" widget.
///
/// This function creates a box with information about the authors of the document.
/// You need to provide the names of the authors and optionally student IDs and/or email addresses.
///
/// Usually you just want to use the info box that is automatically available in the `assignment` layout.
/// It uses this implementation internally but all configuration is done in the `assignment` function.
///
/// -> content
#let info-box(
  /// The authors names. -> array
  names,
  /// The IDs of the authors. -> array | none
  student-ids: none,
  /// The emails of the authors. -> array | none
  emails: none,
  /// The `inset` value of the info box. -> length
  inset: 0.7em,
  /// The `gutter` value of the info box. -> length
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
