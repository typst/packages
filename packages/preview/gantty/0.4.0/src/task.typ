#import "@preview/cetz:0.4.1"
#import "sidebar.typ": sidebar-heights
#import "lines.typ": interval-line

#let draw-taskgroup-line(gantt, i, taskgroup) = {
  import cetz.draw: *

  let anchor = "sidebar.taskgroups." + str(i) + ".header.mid-east"
  let start = (horizontal: "sidebar.east", vertical: anchor)
  let end = (horizontal: (1, 0), vertical: anchor)

  for interval in taskgroup.intervals {
    interval-line(
      gantt,
      interval,
      gantt.style.groups,
      start,
      end,
    )
  }
}

#let draw-task-line(gantt, i, j, task) = {
  import cetz.draw: *

  let anchor = "sidebar.taskgroups." + str(i) + ".task-" + str(j) + ".mid-east"
  let start = (horizontal: "sidebar.east", vertical: anchor)
  let end = (horizontal: (1, 0), vertical: anchor)

  for interval in task.intervals {
    interval-line(
      gantt,
      interval,
      gantt.style.tasks,
      start,
      end,
    )
  }
}

#let task-lines(gantt, size) = {
  import cetz.draw: *

  for (i, taskgroup) in gantt.taskgroups.enumerate() {
    if taskgroup.name != none {
      draw-taskgroup-line(gantt, i, taskgroup)
    }

    for (j, task) in taskgroup.tasks.enumerate() {
      draw-task-line(gantt, i, j, task)
    }
  }
}

#let draw-taskgroups-dividers(gantt) = {
  import cetz.draw: *
  let spacing = gantt.style.sidebar.spacing
  for (i, taskgroup) in gantt.taskgroups.enumerate() {
    let anchor = "sidebar.taskgroups." + str(i) + ".north-east"
    line(
      (rel: (0, spacing / 2), to: ((0, 0), "|-", anchor)),
      (rel: (0, spacing / 2), to: ((1, 0), "|-", anchor)),
      style: (gantt.style.gridlines.table),
    )

    for j in range(taskgroup.tasks.len()) {
      let anchor = (
        "sidebar.taskgroups." + str(i) + ".task-" + str(j) + ".north-east"
      )
      let spacing = gantt.style.sidebar.spacing
      line(
        (rel: (0, spacing / 2), to: ("sidebar.east", "|-", anchor)),
        (rel: (0, spacing / 2), to: ((1, 0), "|-", anchor)),
        ..(gantt.style.gridlines.task-dividers),
      )
    }
  }
}
