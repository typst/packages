// dual-axis.typ - Dual Y-axis line chart
#import "../theme.typ": resolve-theme, get-color
#import "../validate.typ": validate-dual-axis-data
#import "../primitives/container.typ": chart-container
#import "../primitives/axes.typ": draw-grid, draw-axis-titles
#import "../primitives/legend.typ": draw-legend
#import "../util.typ": format-number

#let dual-axis-chart(
  data,
  width: 400pt,
  height: 250pt,
  title: none,
  show-points: true,
  left-color: none,
  right-color: none,
  left-label: none,
  right-label: none,
  x-label: none,
  show-grid: auto,
  theme: none,
) = {
  validate-dual-axis-data(data, "dual-axis-chart")
  let merged = if theme == none { (:) } else { theme }
  if show-grid != auto {
    merged.insert("show-grid", show-grid)
  }
  let t = resolve-theme(merged)

  let labels = data.labels
  let left-series = data.left
  let right-series = data.right
  let n = labels.len()

  // Resolve colors
  let l-color = if left-color != none { left-color } else { get-color(t, 0) }
  let r-color = if right-color != none { right-color } else { get-color(t, 1) }

  // Compute left axis range
  let l-min = calc.min(..left-series.values)
  let l-max = calc.max(..left-series.values)
  let l-range = l-max - l-min
  if l-range == 0 { l-range = 1 }

  // Compute right axis range
  let r-min = calc.min(..right-series.values)
  let r-max = calc.max(..right-series.values)
  let r-range = r-max - r-min
  if r-range == 0 { r-range = 1 }

  let pad-left = 50pt
  let pad-right = 50pt

  chart-container(width, height, title, t, extra-height: 50pt)[
    #let chart-height = height - 20pt
    #let chart-width = width - pad-left - pad-right

    #box(width: width, height: chart-height)[
      // Grid lines (based on left axis scale)
      #draw-grid(pad-left, 0pt, chart-width, chart-height, t)

      // Left Y-axis line
      #place(left + top, line(start: (pad-left, 0pt), end: (pad-left, chart-height), stroke: t.axis-stroke))
      // Right Y-axis line
      #place(left + top, line(start: (pad-left + chart-width, 0pt), end: (pad-left + chart-width, chart-height), stroke: t.axis-stroke))
      // X-axis line
      #place(left + bottom, line(start: (pad-left, 0pt), end: (pad-left + chart-width, 0pt), stroke: t.axis-stroke))

      // Left Y-axis ticks
      #for i in array.range(t.tick-count) {
        let fraction = if t.tick-count > 1 { i / (t.tick-count - 1) } else { 0 }
        let y-val = l-min + l-range * fraction
        let y-pos = chart-height - fraction * (chart-height - 20pt) - 10pt
        place(
          left + top,
          dx: 5pt,
          dy: y-pos - 5pt,
          text(size: t.axis-label-size, fill: l-color)[#format-number(y-val, digits: 1, mode: t.number-format)]
        )
      }

      // Right Y-axis ticks
      #for i in array.range(t.tick-count) {
        let fraction = if t.tick-count > 1 { i / (t.tick-count - 1) } else { 0 }
        let y-val = r-min + r-range * fraction
        let y-pos = chart-height - fraction * (chart-height - 20pt) - 10pt
        place(
          left + top,
          dx: pad-left + chart-width + 5pt,
          dy: y-pos - 5pt,
          text(size: t.axis-label-size, fill: r-color)[#format-number(y-val, digits: 1, mode: t.number-format)]
        )
      }

      // Compute left series points
      #let l-points = ()
      #for (i, val) in left-series.values.enumerate() {
        let x = if n == 1 { pad-left + chart-width / 2 } else { pad-left + 5pt + (i / (n - 1)) * (chart-width - 10pt) }
        let y = chart-height - ((val - l-min) / l-range) * (chart-height - 20pt) - 10pt
        l-points.push((x, y))
      }

      // Compute right series points (scaled to right axis)
      #let r-points = ()
      #for (i, val) in right-series.values.enumerate() {
        let x = if n == 1 { pad-left + chart-width / 2 } else { pad-left + 5pt + (i / (n - 1)) * (chart-width - 10pt) }
        let y = chart-height - ((val - r-min) / r-range) * (chart-height - 20pt) - 10pt
        r-points.push((x, y))
      }

      // Draw left series line segments
      #for i in array.range(calc.max(n - 1, 0)) {
        let p1 = l-points.at(i)
        let p2 = l-points.at(i + 1)
        place(
          left + top,
          line(
            start: (p1.at(0), p1.at(1)),
            end: (p2.at(0), p2.at(1)),
            stroke: 1.5pt + l-color,
          )
        )
      }

      // Draw right series line segments
      #for i in array.range(calc.max(n - 1, 0)) {
        let p1 = r-points.at(i)
        let p2 = r-points.at(i + 1)
        place(
          left + top,
          line(
            start: (p1.at(0), p1.at(1)),
            end: (p2.at(0), p2.at(1)),
            stroke: 1.5pt + r-color,
          )
        )
      }

      // Draw points
      #if show-points {
        for pt in l-points {
          place(
            left + top,
            dx: pt.at(0) - 3pt,
            dy: pt.at(1) - 3pt,
            circle(radius: 3pt, fill: l-color, stroke: white + 0.5pt)
          )
        }
        for pt in r-points {
          place(
            left + top,
            dx: pt.at(0) - 3pt,
            dy: pt.at(1) - 3pt,
            circle(radius: 3pt, fill: r-color, stroke: white + 0.5pt)
          )
        }
      }

      // X-axis category labels
      #for (i, lbl) in labels.enumerate() {
        let x = if n == 1 { pad-left + chart-width / 2 } else { pad-left + 5pt + (i / (n - 1)) * (chart-width - 10pt) }
        place(
          left + bottom,
          dx: x - 15pt,
          dy: 10pt,
          text(size: t.axis-label-size, fill: t.text-color)[#lbl]
        )
      }

      // Axis labels
      #if left-label != none {
        place(left + top, dx: 2pt, dy: chart-height / 2,
          rotate(-90deg, text(size: t.axis-title-size, fill: l-color)[#left-label])
        )
      }
      #if right-label != none {
        place(left + top, dx: width - 8pt, dy: chart-height / 2,
          rotate(-90deg, text(size: t.axis-title-size, fill: r-color)[#right-label])
        )
      }
      #if x-label != none {
        place(left + top, dx: pad-left + chart-width / 2, dy: chart-height + 18pt,
          align(center, text(size: t.axis-title-size, fill: t.text-color)[#x-label])
        )
      }
    ]

    // Legend
    #draw-legend(
      (
        (name: left-series.name, color: l-color),
        (name: right-series.name, color: r-color),
      ),
      t,
      swatch-type: "line",
    )
  ]
}
