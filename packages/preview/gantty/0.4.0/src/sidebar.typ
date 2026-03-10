#import "@preview/cetz:0.4.1"

/// Gets the list of contents for the sidebar
/// -> array
#let sidebar-items(gantt) = {
  gantt.taskgroups.map(group => (
    if group.name == none {
      ()
    } else { (align(center, strong(group.name)),) }
      + (
        ..group.tasks.map(task => align(center, stack(dir: ttb, task.name))),
      )
  ))
}

// #let sidebar-content(gantt) = {
//   block(
//     inset: 5pt,
//     stack(
//       dir: ttb,
//       spacing: 10pt,
//       ..sidebar-items(gantt).flatten(),
//     ),
//   )
// }

#let sidebar-heights(gantt) = {
  sidebar-items(gantt).map(x => x.map(y => measure(y).height))
}

#let incredibly-anchored-dot(c, name: "") = {
  import cetz.draw: *

  let arr = (
    "north",
    "north-east",
    "east",
    "south-east",
    "south",
    "south-west",
    "west",
    "north-west",
    "base",
    "base-west",
    "base-east",
    "mid",
    "mid-west",
    "mid-east",
    "text",
    "text-east",
    "text-west",
  )
  group(
    name: name,
    {
      for i in arr {
        anchor(i, c)
      }
    },
  )
}

/// Draws the sidebar.
///
/// In a group named `sidebar`
///
/// Each taskgroup is drawn within a group
/// called `taskgroups.i` where `i` is the 0-based index of the
/// taskgroup.
///
/// Within that, each task is called `task-j`
#let draw-sidebar(gantt) = {
  import cetz.draw: *

  let taskgroups = sidebar-items(gantt)

  let spacing = gantt.style.sidebar.spacing
  let padding = gantt.style.sidebar.padding
  group(
    name: "sidebar",
    anchor: "north-west",
    {
      group(
        name: "taskgroups",
        {
          let previous_taskgroup_south = (0, 0)
          for (i, taskgroup) in gantt.taskgroups.enumerate() {
            let name = str(i)
            group(
              name: name,
              {
                if taskgroup.name != none {
                  content(
                    name: "header",
                    anchor: "north",
                    (rel: (0pt, -spacing), to: previous_taskgroup_south),
                    strong(taskgroup.name),
                  )
                } else {
                  incredibly-anchored-dot(
                    previous_taskgroup_south,
                    name: "header",
                  )
                }

                let previous_task_south = "header.base"
                for (j, task) in taskgroup.tasks.enumerate() {
                  let task-name = "task-" + str(j)
                  content(
                    name: task-name,
                    anchor: "north",
                    (rel: (0pt, -spacing), to: previous_task_south),
                    task.name,
                  )
                  previous_task_south = task-name + ".base"
                }
              },
            )
            previous_taskgroup_south = name + ".south"
          }
        },
      )
      rect(
        name: "rect",
        (rel: (-padding, padding), to: "taskgroups.north-west"),
        (rel: (padding, -padding), to: "taskgroups.south-east"),
      )
    },
  )
}
