#import "@preview/cetz:0.4.2"

/// A very small float
///
/// This is used internally in milestone placement
/// -> float
#let EPSILON = 0.0000000000001

/// Checks if two rects intersect
/// -> bool
#let rects-intersect(
  /// -> rect
  rect1,
  /// -> rect
  rect2,
) = {
  import calc: max, min
  let r1a = (
    x: min(rect1.x, rect1.x + rect1.width),
    y: min(rect1.y, rect1.y + rect1.height),
  )
  let r1b = (
    x: max(rect1.x, rect1.x + rect1.width),
    y: max(rect1.y, rect1.y + rect1.height),
  )

  let r2a = (
    x: min(rect2.x, rect2.x + rect2.width),
    y: min(rect2.y, rect2.y + rect2.height),
  )
  let r2b = (
    x: max(rect2.x, rect2.x + rect2.width),
    y: max(rect2.y, rect2.y + rect2.height),
  )

  let c1 = r1a.x < r2b.x
  let c2 = r1b.x > r2a.x
  let c3 = r1a.y < r2b.y
  let c4 = r1b.y > r2a.y
  c1 and c2 and c3 and c4
}

/// Displays a content between two coördinates if there is sufficent space
#let content-if-fits(c1, c2, ctn) = {
  import cetz.draw: *
  import cetz.util: measure
  import cetz.vector
  import cetz.coordinate: resolve

  get-ctx(ctx => {
    let measured = measure(ctx, ctn)
    let c1 = resolve(ctx, c1).at(1)
    let c2 = resolve(ctx, c2).at(1)
    let size = vector.sub(c2, c1)
    if measured.at(0) < size.at(0) and measured.at(1) < size.at(1) {
      content(c1, c2, ctn)
    }
  })
}

/// Get a partial anchor to a task from its id.
/// -> string
#let task-anchor(
  /// -> task-id
  id,
) = {
  id.map(str).join(".")
}

/// Get the CeTZ anchor to the task's line.
/// -> coordinate
#let task-anchor-line(
  /// -> task-id
  id,
) = {
  "lines." + task-anchor(id) + ".line"
}

/// Get the CeTZ anchor to the task in the sidebar
/// -> coordinate
#let task-anchor-sidebar(
  /// -> task-id
  id,
) = {
  "sidebar.tasks." + task-anchor(id)
}

/// Gets the `level` from an id
///
/// A toplevel task is level `0`, a subtask is level `1`, a subsubtask is level
/// `2`, etc.
///
/// -> integer
#let id-level(
  /// -> task-id
  id,
) = {
  id.len() - 1
}


/// Same as @styles-for-id but for id's levels.
#let styles-for-level(
  /// -> integer
  level,
  /// -> array
  styles,
) = {
  styles.at(calc.min(level, styles.len() - 1))
}

/// Gets an array element corresponding to the id's level, or else the last element.
///
/// ```typc
/// let styles = ((stroke: black), (stroke: red), (stroke: green))
/// assert.eq(styles-for-id((0,), styles), (stroke: black))
/// assert.eq(styles-for-id((1,), styles), (stroke: red))
/// assert.eq(styles-for-id((2,), styles), (stroke: green))
/// ```
#let styles-for-id(
  /// -> task-id
  id,
  /// -> array
  styles,
) = {
  styles-for-level(id-level(id), styles)
}

#let _foreach-task-in-task(id, task, f) = {
  f(id, task)
  for (i, task) in task.subtasks.enumerate() {
    _foreach-task-in-task((..id, i), task, f)
  }
}

/// Calls a function on every $("sub"^(n))"task"$, joining their result.
///
/// The function must be of signature `(id, task) → any`
#let foreach-task(
  /// -> gantt
  gantt,
  /// -> function
  f,
) = {
  for (i, task) in gantt.tasks.enumerate() {
    _foreach-task-in-task((i,), task, f)
  }
}

/// Gets the start date of a task
///
/// -> datetime
#let task-start(
  /// -> task
  task,
) = {
  calc.min(..task.intervals.map(x => x.start))
}

/// Gets the end date of a task
///
/// -> datetime
#let task-end(
  /// -> task
  task,
) = {
  calc.max(..task.intervals.map(x => x.end))
}

/// Gets the range of the gantt chart
/// -> duration
#let gantt-range(
  /// -> gantt
  gantt,
) = {
  gantt.end - gantt.start
}

/// Gets % through the gantt chart's timespan of a date
/// -> ratio
#let date-ratio(
  /// Must contain a `start` and `end` key
  /// -> dictionary
  gantt,
  /// -> datetime
  date,
) = {
  (date - gantt.start) / gantt-range(gantt) * 100%
}

/// Gets a coördinate whose x-value corresponds to that date in the field
/// -> coordinate
#let date-x-coord(
  /// Must contain a `start` and `end` key
  /// -> dictionary
  gantt,
  /// -> datetime
  date,
) = {
  ("field.west", date-ratio(gantt, date), "field.east")
}

/// Gets a coördinate whose x-value corresponds to that date in the field
/// -> coordinate
#let date-coord(
  /// Must contain a `start` and `end` key
  /// -> dictionary
  gantt,
  /// A coördinate whose vertical component is used
  /// -> coordinate
  y-coord,
  /// -> datetime
  date,
) = {
  (y-coord, "-|", date-x-coord(gantt, date))
}
