// gantt.typ - Gantt chart (timeline bar chart for project scheduling)
#import "../theme.typ": _resolve-ctx, get-color
#import "../validate.typ": validate-gantt-data
#import "../primitives/container.typ": chart-container
#import "../primitives/layout.typ": resolve-size, text-width, text-height, label-stride, max-text-width, place-centered
#import "../primitives/legend.typ": draw-legend-auto, legend-max-width
#import "../primitives/rows.typ": row-layout, row-y, draw-x-axis, x-axis-extent

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
/// - bar-height (auto, length): Height of each task bar; `auto` scales with the theme's `base-size` (1.75x, 14pt in the default theme)
/// - gap (auto, length): Vertical gap between task bars; `auto` scales with the theme's `base-size` (0.5x, 4pt in the default theme)
/// - show-grid (bool): Whether to draw vertical grid lines
/// - x-label (none, content): X-axis title
/// - show-legend (bool): Name the task groups and their colors: beside the first bar of each
///   group when there is room for it, else in a legend
/// - color-by-task (bool): Give every task without a group its own palette colour. By default
///   such tasks share the first palette colour (grouped tasks keep one colour per group): a
///   colour per task would encode nothing
/// - today (none, int): Optional time index to draw a "today" marker line
/// - theme (none, dictionary): Theme overrides
/// - extra-legend-separation (length): Extra space between legend and chart
/// -> content
#let gantt-chart(
  data,
  width: auto,
  height: auto,
  title: none,
  bar-height: auto,
  gap: auto,
  show-grid: true,
  x-label: none,
  show-legend: false,
  color-by-task: false,
  today: none,
  theme: none,
  extra-legend-separation: 0pt
) = context {
  layout(size => {
  validate-gantt-data(data, "gantt-chart")
  let t = _resolve-ctx(theme)
  let bar-height = if bar-height == auto { 1.75 * t.base-size } else { bar-height }
  let gap = if gap == auto { 0.5 * t.base-size } else { gap }
  let width = resolve-size(width, 0pt, size, n: 10, theme: t).width
  let tasks = data.tasks
  let n = tasks.len()

  // Columns are whole time units; round a fractional end up to include it
  let time-count = int(calc.ceil(calc.max(..tasks.map(task => task.end))))
  let time-labels = if "time-labels" in data { data.time-labels } else {
    array.range(time-count).map(i => str(i))
  }
  let shown-labels = time-labels.slice(0, calc.min(time-count, time-labels.len()))

  // Group colours
  let group-names = ()
  for task in tasks {
    if "group" in task and task.group not in group-names { group-names.push(task.group) }
  }
  let has-groups = group-names.len() > 0

  // The "Today" caption needs a band above the rows
  let size-lbl = t.axis-label-size
  let today-h = if today != none { text-height("Today", size-lbl) + t.axis-label-gap * 1.5 } else { 0pt }
  let axis-h = x-axis-extent(t, title: x-label)

  // Rows: auto height keeps the old pitch (bar + gap); a given height shares it out
  let auto-height = height == auto
  let body-height = if auto-height { n * (bar-height + gap) + today-h + axis-h } else { height }
  let pitch = if auto-height { bar-height + gap } else { (body-height - today-h - axis-h) / n }
  let bar-h = if auto-height { bar-height } else {
    calc.max(pitch * 0.4, calc.min(bar-height, pitch - gap))
  }

  // Overhang of the last, centred label past the plot
  let probe = row-layout(width, body-height, tasks.map(task => task.name), t, label-frac: 0.3, pad-top: today-h, pad-bottom: axis-h, pitch: pitch)
  let wmax = max-text-width(shown-labels, size-lbl)
  let est-col = (width - probe.label-w - probe.gap) / time-count
  let lay = row-layout(width, body-height, tasks.map(task => task.name), t, label-frac: 0.3,
    pad-top: today-h, pad-bottom: axis-h, pitch: pitch,
    inset-right: calc.max(0pt, wmax / 2 - est-col / 2))
  let (x0, x1) = (lay.x0, lay.x1)
  let col-w = lay.plot-w / time-count

  // Group names go beside the first bar of each group when they fit there (in
  // the room right of the bar, else left of it) and the rows are tall enough
  // for the type; otherwise a legend carries them
  let name-size = calc.min(size-lbl, lay.row-h)
  let sw = name-size * 0.8
  let direct = if show-legend and has-groups and name-size >= 6pt {
    let spots = group-names.enumerate().map(((gi, g)) => {
      let fi = tasks.position(task => task.at("group", default: none) == g)
      let w = sw + 3pt + text-width(g, name-size, weight: "bold")
      let (xs, xe) = (x0 + tasks.at(fi).start * col-w, x0 + tasks.at(fi).end * col-w)
      let x = if xe + 4pt + w <= width { xe + 4pt } else if xs - 4pt - w >= x0 { xs - 4pt - w } else { none }
      (g: g, color: get-color(t, gi), y: row-y(lay, fi), x: x)
    })
    if spots.all(sp => sp.x != none) { spots } else { none }
  } else { none }
  let legend = if show-legend and has-groups and direct == none {
    draw-legend-auto(group-names.enumerate().map(((i, g)) => (name: g, color: get-color(t, i))), t, fit-width: true, max-width: legend-max-width(width, t))
  } else { none }

  chart-container(width, body-height, title, t, legend: legend, extra-legend-separation: extra-legend-separation)[
    #box(width: width, height: body-height)[
      // Column boundaries as light grid lines, thinned when columns are narrow
      #if show-grid {
        let g-stride = label-stride(1pt, col-w, gap: 5pt)
        for i in array.range(time-count + 1) {
          if calc.rem(i, g-stride) != 0 and i != time-count { continue }
          place(left + top, line(
            start: (x0 + i * col-w, lay.y0),
            end: (x0 + i * col-w, lay.y1),
            stroke: t.grid-stroke,
          ))
        }
      }

      // Time axis: labels centred in their columns, thinned (never rotated)
      #draw-x-axis(
        shown-labels.enumerate().map(((i, l)) => (x: x0 + (i + 0.5) * col-w, label: l)),
        lay.y1, t, x0: x0, x1: x1, title: x-label,
      )
      #lay.labels

      #for (i, task) in tasks.enumerate() {
        let color-idx = if has-groups {
          let idx = group-names.position(g => g == task.at("group", default: ""))
          if idx == none { i } else { idx }
        } else if color-by-task { i } else { 0 }
        place(left + top, dx: x0 + task.start * col-w, dy: row-y(lay, i) - bar-h / 2,
          rect(width: (task.end - task.start) * col-w, height: bar-h,
            fill: get-color(t, color-idx), stroke: none, radius: 2pt))
      }

      // Group names, set beside the first bar of their group
      #if direct != none {
        for sp in direct {
          place-centered(sp.x, sp.y, grid(columns: (auto, auto), column-gutter: 3pt, align: horizon,
            rect(width: sw, height: sw, fill: sp.color, radius: 1pt),
            text(size: name-size, weight: "bold", fill: t.text-color)[#sp.g]))
        }
      }

      // "Today" marker, named in a caption above the rows
      #if today != none {
        let tx = x0 + today * col-w
        place(left + top, line(start: (tx, lay.y0 - 3pt), end: (tx, lay.y1),
          stroke: (paint: t.text-color, thickness: 1pt, dash: "dashed")))
        let w = text-width("Today", size-lbl)
        place(left + top, dx: calc.max(0pt, calc.min(width - w, tx - w / 2)), dy: lay.y0 - 3pt - text-height("Today", size-lbl) - 2pt,
          text(size: size-lbl, fill: t.text-color)[Today])
      }
    ]
  ]
  })
}
