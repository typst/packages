#import "@preview/mantys:0.1.4": *
#import "@preview/timeliney:0.4.0": *

#show: mantys.with(
  ..toml("typst.toml").package,
  examples-scope: (
    group: group,
    headerline: headerline,
    milestone: milestone,
    task: task,
    taskgroup: taskgroup,
    timeline: timeline,
  )
)

#command(
  "timeline",
  arg[body],
  arg(spacing: 5pt),
  arg(show-grid: false),
  arg(grid-style: (stroke: (dash: "dashed", thickness: .5pt, paint: gray))),
  arg(task-vline: true),
  arg(line-style: (stroke: 3pt)),
  arg(milestone-overhang: 5pt),
  arg(milestone-layout: "in-place"),
  arg(box-milestones: true),
  arg(milestone-line-style: ()),
  arg(cell-line-style: (stroke: 1pt + black)),
  arg(offset: 0),
)[
#argument("spacing", types: ("length",), default: 5pt)[
  Spacing between lines
]

#argument("show-grid", types: ("boolean",), default: true)[
  Show a grid behind the timeline
]

#argument(
  "grid-style",
  types: ("dictionary",),
  default: (stroke: (dash: "dashed", thickness: .5pt, paint: gray)),
)[
The style to use for the grid (has no effect if `show-grid` is false)
]

#argument("task-vline", types: ("boolean",), default: true)[
  Show a vertical line next to the task names
]

#argument("line-style", types: ("dictionary",), default: (stroke: 3pt))[
  The style to use for the lines in the timelines
]

#argument(
  "milestone-overhang",
  types: ("length",),
  default: 5pt,
)[
How far the milestone lines should extend past the end of the timeline (only has
an effect if `milestone-layout` is `in-place`)
]

#argument(
  "milestone-layout",
  types: ("string",),
  default: "in-place",
)[
How to lay out the milestone lines. Can be `in-place` or `aligned`.

`in-place` displays the milestones directly below the timeline, and tries to lay
them out as well as possible to avoid colisions.

`aligned` displays the milestones in a separate box, aligned with the task
titles.
]

#argument("box-milestones", types: ("boolean",), default: true)[
Whether to draw a box around the milestones (only has an effect if
`milestone-layout` is `aligned`)
]

#argument("milestone-line-style", types: ("dictionary",), default: ())[
  The style to use for the milestone lines
]

#argument("cell-line-style", types: ("dictionary",), default: (stroke: 1pt + black))[
  The style to use for the cells' border lines
]

#argument("offset", types: ("float",), default: 0)[
  Offset to be automatically added to all the timespans
]

#example[```
  #timeline(
  show-grid: true,
  {
    headerline(group(([*2023*], 4)), group(([*2024*], 4)))
    headerline(
      group(..range(4).map(n => strong("Q" + str(n + 1)))),
      group(..range(4).map(n => strong("Q" + str(n + 1)))),
    )

    taskgroup(title: [*Research*], {
      task("Research the market", (0, 2), style: (stroke: 2pt + gray))
      task("Conduct user surveys", (1, 3), style: (stroke: 2pt + gray))
    })

    taskgroup(title: [*Development*], {
      task("Create mock-ups", (2, 3), style: (stroke: 2pt + gray))
      task("Develop application", (3, 5), style: (stroke: 2pt + gray))
      task("QA", (3.5, 6), style: (stroke: 2pt + gray))
    })

    taskgroup(title: [*Marketing*], {
      task("Press demos", (3.5, 7), style: (stroke: 2pt + gray))
      task("Social media advertising", (6, 7.5), style: (stroke: 2pt + gray))
    })

    milestone(
      at: 3.75,
      style: (stroke: (dash: "dashed")),
      align(center, [
        *Conference demo*\
        Dec 2023
      ])
    )

    milestone(
      at: 6.5,
      style: (stroke: (dash: "dashed")),
      align(center, [
        *App store launch*\
        Aug 2024
      ])
    )
  }
)


  ```]
]

#command("headerline", arg("..titles", is-sink: true))[
#argument("titles", types: ("array",), is-sink: true)[
The titles to display in the header line.

Can be specified in several different formats:

#example[```
    // One column per title
    #headerline("Title 1", "Title 2", "Title 3")
    ```]

#example[```
    // Each title occupies 2 columns
    #headerline(("Title 1", 2), ("Title 2", 2))
    ```]

#example[```
    // Two groups of titles
    #headerline(
      group("Q1", "Q2", "Q3", "Q4"),
      group("Q1", "Q2", "Q3", "Q4"),
    )
    ```]

#example[```
    // Two lines of headers
    #headerline(
      group(("2023", 4), ("2024", 4))
    )
    #headerline(
      group("Q1", "Q2", "Q3", "Q4"),
      group("Q1", "Q2", "Q3", "Q4"),
    )
    ```]
]
]

#command("group", arg("..titles", is-sink: true))[
Defines a group of titles in a header line.

Takes the same options as `#headerline`.
]

#command(
  "task",
  arg([name]),
  arg([style], default: none),
  arg("..lines", is-sink: true),
)[
Defines a task

#argument("name", types: ("content",))[
  The name of the task
]

#argument(
  "style",
  types: ("dictionary",),
  default: none,
)[
  The style to use for the task line. If not specified, the default style will be
  used.
]

#argument(
  "..lines",
  types: ("array",)
)[
The lines to display in the task. Can be specified in several different formats:

#example[```
    // Spans 1 month, starting at the first month of the timeline
    #task("Task", (0, 1))
    ```]

#example[```
    // One red line at month 1, and a line spanning 2 months starting at month 4
    #task("Task", (from: 0, to: 1, style: (stroke: red)), (3, 5))
    ```]
]
]

#command("taskgroup", arg("title", default: none), arg("tasks"))[
Groups tasks together in a box. If `title` is specified, a title will be
displayed, with a line spanning all the inner tasks.

#argument("title", types: ("content",), default: none)[
  The title of the task group
]

#argument("tasks", types: ("content",))[
  The tasks to display in the group
]

#example[```
  #taskgroup(title: "Research", {
    task("Task 1", (0, 1))
    task("Task 2", (3, 5))
  })
  ```]
]

#command(
  "milestone",
  arg("body"),
  arg("at"),
  arg("style"),
  arg("overhang"),
  arg("spacing"),
  arg(anchor: "top"),
)[
Defines a milestone. The way it's displayed depends on the `milestone-layout`
option of the `#timeline` command.

#argument(
  "at",
  types: ("float",),
)[
  The month at which the milestone should be displayed. Can be fractional.
]

#argument("style", types: ("dictionary",), default: ())[
Style for the milestone line. Defaults to `milestone-line-style`.
]

#argument(
  "overhang",
  types: ("length",),
  default: 5pt,
)[
How far the milestone line should extend past the end of the timeline. Defaults
to `milestone-overhang`.
]

#argument("spacing", types: ("length",), default: 5pt)[
Spacing between the milestone line and the text. Defaults to `spacing`.
]

#argument(
  "anchor",
  types: ("string",),
  default: "top",
)[
The anchor point for the milestone text. Can be `top`, `bottom`, `left`,
`right`, `top-left`, `top-right`, `bottom-left`, `bottom-right`, `center`,
`center-left`, `center-right`, `center-top`, `center-bottom`. Defaults to `top`.
]

#argument("body", types: ("content",))[
  The text to display next to the milestone line
]
]
