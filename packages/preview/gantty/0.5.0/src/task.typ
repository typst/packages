#import "@preview/cetz:0.4.2"
#import "util.typ": (
  date-coord, foreach-task, styles-for-id, task-anchor-sidebar, task-end,
  task-start,
)

/// Draws a line between `interval-simple.start` and `interval-simple.end`
#let _simple-interval-line(
  gantt-interval,
  y-coord,
  style,
  interval,
) = {
  import cetz.draw: *

  let start-y-coord = (rel: (0, style.width / 2), to: y-coord)
  let end-y-coord = (rel: (0, -style.width / 2), to: y-coord)
  let start-coord = date-coord(gantt-interval, start-y-coord, interval.start)
  let end-coord = date-coord(gantt-interval, end-y-coord, interval.end)
  rect(start-coord, end-coord, ..style.style)
}

/// Draws a line following the interval
///
/// `style` should contain `completed-late`, `completed-early`, and `uncompleted`
/// keys.
#let _interval-line(gantt-interval, style, y-coord, interval) = {
  import cetz.draw: *

  let done = interval.at("done")
  let simple-interval-line = _simple-interval-line.with(gantt-interval, y-coord)
  if done == none {
    simple-interval-line(style.uncompleted, interval)
  } else {
    let done = done
    if done <= interval.end {
      simple-interval-line(
        style.completed-early.timeframe,
        (start: interval.start, end: done),
      )

      simple-interval-line(
        style.completed-early.body,
        (start: done, end: interval.end),
      )
    } else if done > interval.end {
      simple-interval-line(
        style.completed-late.body,
        interval,
      )

      simple-interval-line(
        style.completed-late.timeframe,
        (start: interval.end, end: done),
      )
    }
  }
}

#let _draw-task-anchors(gantt-interval, id, task) = {
  import cetz.draw: *

  let y-coord = task-anchor-sidebar(id) + ".header.mid-east"
  let start = date-coord(gantt-interval, y-coord, task-start(task))
  let end = date-coord(gantt-interval, y-coord, task-end(task))
  hide(line(start, end, name: "internal-line"))
  copy-anchors("internal-line")
}

#let _draw-task-line(gantt-interval, styles, id, task) = {
  import cetz.draw: *

  let y-coord = task-anchor-sidebar(id) + ".header.mid-east"

  group(name: "line", {
    for interval in task.intervals {
      _interval-line(
        gantt-interval,
        styles-for-id(id, styles),
        y-coord,
        interval,
      )
    }
    _draw-task-anchors(gantt-interval, id, task)
  })
}

#let _draw-task(gantt-interval, styles, id, task) = {
  import cetz.draw: *

  group(
    name: str(id.last()),
    {
      _draw-task-line(gantt-interval, styles, id, task)

      for (i, task) in task.subtasks.enumerate() {
        _draw-task(gantt-interval, styles, (..id, i), task)
      }
    },
  )
}

/// The default style for drawing tasks.
#let default-styles = (
  (
    uncompleted: (style: (fill: black), width: 3pt),
    completed-early: (
      timeframe: (style: (fill: olive), width: 3pt),
      body: (style: (fill: black), width: 3pt),
    ),
    completed-late: (
      timeframe: (style: (fill: orange), width: 3pt),
      body: (style: (fill: black), width: 3pt),
    ),
  ),
  (
    uncompleted: (style: (fill: luma(33%)), width: 2pt),
    completed-early: (
      timeframe: (style: (fill: olive), width: 2pt),
      body: (style: (fill: luma(33%)), width: 2pt),
    ),
    completed-late: (
      timeframe: (style: (fill: orange), width: 2pt),
      body: (style: (fill: luma(33%)), width: 2pt),
    ),
  ),
)

/// The default tasks drawer
/// -> cetz
#let default-tasks-drawer(
  /// The gantt chart.
  /// -> gantt
  gantt,
  /// The `styles` parameter should look like:
  ///
  /// #gantty.task.default-styles
  ///
  /// Each element of the array is to represent first the style of
  /// toplevel tasks, then subtasks, then subsubtasks, etc., etc.
  /// -> array
  styles: default-styles,
) = {
  import cetz.draw: *

  let gantt-interval = (end: gantt.end, start: gantt.start)
  group(
    name: "lines",
    for (i, task) in gantt.tasks.enumerate() {
      _draw-task(gantt-interval, styles, (i,), task)
    },
  )
}
