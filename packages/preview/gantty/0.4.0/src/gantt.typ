#import "@preview/cetz:0.4.1"
#import "normalize.typ": normalize-gantt
#import "sidebar.typ": draw-sidebar
#import "header.typ": draw-headers
#import "task.typ": draw-taskgroups-dividers, task-lines
#import "milestones.typ": draw-milestones

/// Draws the rectangle within which the task(group)s are placed
#let _draw-bars-rect(gantt, size) = {
  import cetz.draw: *
  set-style(..gantt.style.gridlines.table)
  rect(
    name: "bars",
    "sidebar.north-east",
    ((1, 0), "|-", "sidebar.south-east"),
  )
}


/// Renders a gantt chart.
/// -> content
#let gantt(
  /// A gantt chart specifier.
  /// -> dictionary
  gantt,
) = (
  context {
    let gantt = normalize-gantt(gantt)

    layout(size => {
      cetz.canvas(length: size.width, {
        draw-sidebar(gantt)
        _draw-bars-rect(gantt, size)
        draw-headers(gantt)
        draw-taskgroups-dividers(gantt)
        task-lines(gantt, size)
        _draw-bars-rect(gantt, size)
        draw-milestones(gantt)
      })
    })
  }
)
