#import "@preview/cetz:0.4.2"
#import "util.typ": (
  foreach-task, id-level, styles-for-id, styles-for-level, task-anchor,
  task-anchor-sidebar,
)

/// Gets the max width of all elements in the sidebar
#let _max-width-from-tasks(formatters, tasks, level) = {
  let formatter = styles-for-level(level, formatters)

  calc.max(
    0pt,
    ..tasks.map(
      task => calc.max(
        measure((formatter)(task)).width,
        _max-width-from-tasks(
          formatters,
          task.subtasks,
          level + 1,
        ),
      ),
    ),
  )
}

#let _task-formatter(style, level) = {
  x => block(
    width: style.max-width,
    (styles-for-level(level, style.formatters))(x),
  )
}

#let _previous-task-south(id) = {
  if id.last() == 0 {
    if id == (0,) {
      (0, 0)
    } else {
      "header.base"
    }
  } else {
    str((id.last() - 1)) + ".base"
  }
}

/// Draws the task header
///
/// It is given the anchor `header`
#let _draw-header(style, id, task) = {
  import cetz.draw: *

  let level = id-level(id)
  let spacing = style.spacing
  let padding = style.padding
  let task-formatter = _task-formatter(style, level)
  let previous-task-south = _previous-task-south(id)

  content(
    name: "header",
    anchor: "north",
    (rel: (0, -spacing), to: previous-task-south),
    (task-formatter)(task),
  )
}

#let _task-divider(style, id) = {
  import cetz.draw: *

  let spacing = style.spacing
  anchor("divider", (rel: (0pt, spacing / 2), to: "header.north"))
}

#let _last-task-anchor(task) = {
  if task.subtasks == () {
    "header"
  } else {
    str(task.subtasks.len() - 1)
  }
}


#let _draw-task(style, id, task) = {
  import cetz.draw: *

  let previous-task-south = _previous-task-south(id)
  let spacing = style.spacing
  group(
    name: str(id.last()),
    {
      _draw-header(style, id, task)
      _task-divider(style, id)
      for (task-idx, task) in task.subtasks.enumerate() {
        _draw-task(style, id + (task-idx,), task)
      }
      anchor("base", _last-task-anchor(task) + ".base")
    },
  )
}

#let _draw-sidebar-content(gantt, style) = {
  import cetz.draw: *

  group(
    name: "tasks",
    {
      for (i, task) in gantt.tasks.enumerate() {
        _draw-task(style, (i,), task)
      }
    },
  )
}


#let _draw-sidebar-stroke(gantt, style) = {
  import cetz.draw: *

  let padding = style.padding

  rect-around(
    name: "rect",
    "tasks",
    padding: padding,
    stroke: style.stroke,
    fill: style.fill,
  )
}

/// The default formatters for tasks' headers.
/// -> array
#let default-task-formatters = (
  x => align(center, strong(x.name)),
  x => align(center, x.name),
  x => align(center, emph(x.name)),
)

/// The default dividers for tasks' headers.
/// -> array
#let default-dividers = (
  (stroke: black),
  none,
)

#let _draw-sidebar-dividers(gantt, style) = {
  import cetz.draw: *
  foreach-task(gantt, (id, task) => line(
    ("tasks." + task-anchor(id) + ".divider", "-|", "rect.east"),
    ("tasks." + task-anchor(id) + ".divider", "-|", "rect.west"),
    ..styles-for-id(id, style.dividers),
  ))
}

/// Draws the sidebar.
/// -> cetz
#let default-sidebar-drawer(
  /// The gantt chart.
  /// -> gantt
  gantt,
  /// Padding the sidebar.
  /// -> length
  padding: 5pt,
  /// Spacing between elements.
  /// -> length
  spacing: 10pt,
  /// An array of formatters for the headers of toplevel tasks, subtasks,
  /// subsubtasks, etc.
  ///
  /// Each formatter should be `task -> content`.
  /// -> array
  formatters: default-task-formatters,
  /// The stroke of the sidebar.
  /// -> stroke
  stroke: black,
  /// The fill of the sidebar.
  /// -> color
  fill: none,
  /// The maximum width of the sidebar.
  /// -> length | auto
  max-width: auto,
  /// Visual dividers of the sidebar
  /// -> array
  dividers: default-dividers,
) = {
  let style = (
    padding: padding,
    spacing: spacing,
    formatters: formatters,
    stroke: stroke,
    fill: fill,
    max-width: _max-width-from-tasks(formatters, gantt.tasks, 0),
    dividers: dividers,
  )

  import cetz.draw: *

  group(
    name: "sidebar",
    anchor: "north-west",
    {
      _draw-sidebar-content(gantt, style)
      _draw-sidebar-stroke(gantt, style)
      _draw-sidebar-dividers(gantt, style)
    },
  )
}
