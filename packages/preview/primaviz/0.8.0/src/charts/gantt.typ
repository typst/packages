// gantt.typ - Gantt chart (timeline bar chart for project scheduling)
#import "../theme.typ": _resolve-ctx, get-color
#import "../validate.typ": validate-gantt-data
#import "../primitives/container.typ": chart-container
#import "../primitives/layout.typ": density-skip, font-for-space, resolve-size
#import "../primitives/legend.typ": draw-legend

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
/// - extra-legend-separation (length): Extra space between legend and chart
/// -> content
#let gantt-chart(
  data,
  width: auto,
  height: auto,
  title: none,
  bar-height: 14pt,
  gap: 4pt,
  show-grid: true,
  x-label: none,
  show-legend: false,
  today: none,
  theme: none,
  extra-legend-separation: 0pt
) = context {
  layout(size => {
  validate-gantt-data(data, "gantt-chart")
  let t = _resolve-ctx(theme)
  let width = resolve-size(width, 0pt, size, n: 10, theme: t).width
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

  // Label area width for task names — scale with chart width
  let label-area = calc.min(80pt, width * 0.25)
  let timeline-width = width - label-area - 10pt
  let col-width = timeline-width / time-count

  // Group legend
  let legend = none
  if show-legend and has-groups {
      legend = draw-legend(
        group-names.enumerate().map(((i, g)) => (name: g, color: get-color(t, i))),
        t,
      )
    }

  chart-container(width, chart-height, title, t, extra-height: 30pt, legend: legend, extra-legend-separation: extra-legend-separation)[
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

      // Time labels along the bottom — below the axis line
      #let label-font = font-for-space(col-width, t.axis-label-size)
      #let rotate-labels = time-count > t.rotated-threshold
      #let skip-n = density-skip(time-count, timeline-width, min-spacing: if rotate-labels { 18pt } else { 12pt })
      #let axis-y = body-height - 20pt
      #let label-y = axis-y + 4pt  // below the axis line
      #for (i, lbl) in time-labels.enumerate() {
        if i < time-count and calc.rem(i, skip-n) == 0 {
          let x = label-area + i * col-width
          if rotate-labels {
            place(
              left + top,
              dx: x + 2pt,
              dy: label-y,
              rotate(-45deg, origin: top + left,
                text(size: label-font, fill: t.text-color)[#lbl]),
            )
          } else {
            place(
              left + top,
              dx: x,
              dy: label-y,
              box(width: col-width,
                align(center, text(size: label-font, fill: t.text-color)[#lbl])),
            )
          }
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

        // Task name label — right-aligned into label area
        place(
          left + top,
          dx: 0pt,
          dy: y-pos + 1pt,
          box(width: label-area - 6pt, align(right, text(size: t.axis-label-size, fill: t.text-color)[#task.name])),
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

      // X-axis label
      #if x-label != none {
        place(left + top, dx: label-area + timeline-width / 2, dy: body-height,
          move(dx: -3em, box(width: 6em, align(center, text(size: t.axis-title-size, fill: t.text-color)[#x-label]))))
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
            stroke: 1.5pt + get-color(t, calc.max(group-names.len(), 1)),
          ),
        )
      }
    ]

  ]
  })
}
