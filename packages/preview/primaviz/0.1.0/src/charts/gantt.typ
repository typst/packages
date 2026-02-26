// gantt.typ - Gantt chart (timeline bar chart for project scheduling)
#import "../theme.typ": resolve-theme, get-color
#import "../validate.typ": validate-gantt-data
#import "../primitives/container.typ": chart-container

/// Renders a Gantt chart — a timeline bar chart for project scheduling.
///
/// Tasks are displayed as horizontal bars on a time axis. Tasks can be
/// optionally grouped for color coding.
///
/// - data (dictionary): Must contain `tasks` array. Each task is a dict with
///   `name` (str), `start` (int), `end` (int), and optional `group` (str).
///   Optional `time-labels` array for custom x-axis labels.
/// - width (length): Chart width
/// - height (auto, length): Chart height. If `auto`, computed from task count.
/// - title (none, content): Optional chart title
/// - bar-height (length): Height of each task bar
/// - gap (length): Vertical gap between task bars
/// - show-grid (bool): Whether to draw vertical grid lines
/// - today (none, int): Optional time index to draw a "today" marker line
/// - theme (none, dictionary): Theme overrides
/// -> content
#let gantt-chart(
  data,
  width: 400pt,
  height: auto,
  title: none,
  bar-height: 18pt,
  gap: 4pt,
  show-grid: true,
  today: none,
  theme: none,
) = {
  validate-gantt-data(data, "gantt-chart")
  let t = resolve-theme(theme)
  let tasks = data.tasks

  // Determine time range
  let max-time = calc.max(..tasks.map(task => task.end))
  let time-count = max-time
  let time-labels = if "time-labels" in data { data.time-labels } else {
    array.range(max-time).map(i => str(i))
  }

  // Compute height if auto
  let computed-height = tasks.len() * (bar-height + gap) + 30pt
  let chart-height = if height == auto { computed-height } else { height }

  // Build group-to-color mapping
  let group-names = ()
  for task in tasks {
    if "group" in task {
      if task.group not in group-names {
        group-names.push(task.group)
      }
    }
  }
  let has-groups = group-names.len() > 0

  // Label area width for task names
  let label-area = 100pt
  let timeline-width = width - label-area - 10pt
  let col-width = timeline-width / time-count

  chart-container(width, chart-height, title, t, extra-height: 30pt)[
    #let body-height = chart-height

    #box(width: width, height: body-height)[
      // Vertical grid lines
      #if show-grid {
        for i in array.range(time-count + 1) {
          let x = label-area + i * col-width
          place(
            left + top,
            dx: x,
            dy: 0pt,
            line(
              start: (0pt, 0pt),
              end: (0pt, body-height - 20pt),
              stroke: t.grid-stroke,
            ),
          )
        }
      }

      // Time labels along the bottom
      #for (i, lbl) in time-labels.enumerate() {
        if i < time-count {
          let x = label-area + i * col-width
          place(
            left + top,
            dx: x + 2pt,
            dy: body-height - 18pt,
            text(size: t.axis-label-size, fill: t.text-color)[#lbl],
          )
        }
      }

      // Left axis line
      #place(left + top, line(
        start: (label-area, 0pt),
        end: (label-area, body-height - 20pt),
        stroke: t.axis-stroke,
      ))

      // Bottom axis line
      #place(left + top, dx: label-area, dy: body-height - 20pt, line(
        start: (0pt, 0pt),
        end: (timeline-width, 0pt),
        stroke: t.axis-stroke,
      ))

      // Task bars
      #for (i, task) in tasks.enumerate() {
        let y-pos = i * (bar-height + gap) + 2pt
        let x-start = label-area + task.start * col-width
        let bar-width = (task.end - task.start) * col-width

        // Determine color
        let color-idx = if has-groups {
          let gn = if "group" in task { task.group } else { "" }
          let idx = group-names.position(g => g == gn)
          if idx == none { i } else { idx }
        } else {
          i
        }

        // Task name label
        place(
          left + top,
          dx: 4pt,
          dy: y-pos + 1pt,
          text(size: t.axis-label-size, fill: t.text-color)[#task.name],
        )

        // Task bar
        place(
          left + top,
          dx: x-start,
          dy: y-pos,
          rect(
            width: bar-width,
            height: bar-height,
            fill: get-color(t, color-idx),
            stroke: none,
            radius: 2pt,
          ),
        )
      }

      // "Today" marker line
      #if today != none {
        let today-x = label-area + today * col-width
        place(
          left + top,
          dx: today-x,
          dy: 0pt,
          line(
            start: (0pt, 0pt),
            end: (0pt, body-height - 20pt),
            stroke: 1.5pt + rgb("#e15759"),
          ),
        )
      }
    ]
  ]
}
