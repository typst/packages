// dual-axis.typ - Dual Y-axis line chart
#import "../theme.typ": _resolve-ctx, get-color
#import "../validate.typ": validate-dual-axis-data
#import "../primitives/container.typ": chart-container
#import "../primitives/axes.typ": cartesian-layout, draw-grid, draw-axis-titles, draw-x-even-labels, draw-y-ticks, measure-y-tick-width
#import "../primitives/legend.typ": draw-legend-auto
#import "../primitives/annotations.typ": draw-annotations
#import "../util.typ": nonzero, nice-ticks
#import "../primitives/layout.typ": resolve-size

#let dual-axis-chart(
  data,
  width: auto,
  height: auto,
  title: none,
  show-points: true,
  line-width: 1.5pt,
  point-size: 3pt,
  left-color: none,
  right-color: none,
  left-label: none,
  right-label: none,
  x-label: none,
  show-grid: auto,
  annotations: none,
  theme: none,
  extra-legend-separation: 0pt
) = context {
  layout(size => {
  validate-dual-axis-data(data, "dual-axis-chart")
  let grid-overrides = if show-grid != auto { (show-grid: show-grid) } else { none }
  let t = _resolve-ctx(theme, overrides: grid-overrides)
  let (width, height) = resolve-size(width, height, size, n: data.labels.len(), theme: t)

  let labels = data.labels
  let left-series = data.left
  let right-series = data.right
  let n = labels.len()

  // Resolve colors
  let l-color = if left-color != none { left-color } else { get-color(t, 0) }
  let r-color = if right-color != none { right-color } else { get-color(t, 1) }

  // Compute left axis range
  let l-nt = nice-ticks(calc.min(..left-series.values), calc.max(..left-series.values), count: t.tick-count)
  let l-min = l-nt.min
  let l-max = l-nt.max
  let l-range = nonzero(l-max - l-min)

  // Compute right axis range
  let r-nt = nice-ticks(calc.min(..right-series.values), calc.max(..right-series.values), count: t.tick-count)
  let r-min = r-nt.min
  let r-max = r-nt.max
  let r-range = nonzero(r-max - r-min)

  // Both sides need room for ticks + rotated title
  let cl = cartesian-layout(width, height, t, extra-left: 10pt, extra-right: t.axis-padding-left - t.axis-padding-right)
  let legend-content = draw-legend-auto(
      ((name: left-series.name, color: l-color), (name: right-series.name, color: r-color)),
      t, swatch-type: "line",
    )

  chart-container(width, height, title, t, extra-height: 50pt, legend: legend-content, extra-legend-separation: extra-legend-separation)[
    #let pad-top = cl.pad-top
    #let chart-height = cl.chart-height
    #let chart-width = cl.chart-width
    #let origin-x = cl.origin-x
    #let origin-y = cl.origin-y

    #box(width: width, height: height)[
      // Grid lines (based on left axis scale)
      #draw-grid(origin-x, pad-top, chart-width, chart-height, t, num-ticks: l-nt.ticks.len())

      // Left Y-axis line
      #place(left + top, line(start: (origin-x, pad-top), end: (origin-x, origin-y), stroke: t.axis-stroke))
      // Right Y-axis line
      #place(left + top, line(start: (origin-x + chart-width, pad-top), end: (origin-x + chart-width, origin-y), stroke: t.axis-stroke))
      // X-axis line
      #place(left + top, line(start: (origin-x, origin-y), end: (origin-x + chart-width, origin-y), stroke: t.axis-stroke))

      // Left Y-axis ticks — right-aligned into left padding
      #draw-y-ticks(l-min, l-max, chart-height, pad-top, origin-x, t, color: l-color)

      // Right Y-axis ticks — left-aligned after right axis
      #draw-y-ticks(r-min, r-max, chart-height, pad-top, origin-x + chart-width, t, color: r-color, side: "right")

      // Compute left series points
      #let l-points = ()
      #for (i, val) in left-series.values.enumerate() {
        let x = if n == 1 { origin-x + chart-width / 2 } else { origin-x + (i / (n - 1)) * chart-width }
        let y = pad-top + chart-height - ((val - l-min) / l-range) * chart-height
        l-points.push((x, y))
      }

      // Compute right series points (scaled to right axis)
      #let r-points = ()
      #for (i, val) in right-series.values.enumerate() {
        let x = if n == 1 { origin-x + chart-width / 2 } else { origin-x + (i / (n - 1)) * chart-width }
        let y = pad-top + chart-height - ((val - r-min) / r-range) * chart-height
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
            stroke: line-width + l-color,
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
            stroke: line-width + r-color,
          )
        )
      }

      // Draw points
      #if show-points {
        for pt in l-points {
          place(
            left + top,
            dx: pt.at(0) - point-size,
            dy: pt.at(1) - point-size,
            circle(radius: point-size, fill: l-color, stroke: t.marker-stroke)
          )
        }
        for pt in r-points {
          place(
            left + top,
            dx: pt.at(0) - point-size,
            dy: pt.at(1) - point-size,
            circle(radius: point-size, fill: r-color, stroke: t.marker-stroke)
          )
        }
      }

      // X-axis category labels — spread evenly across chart width
      #draw-x-even-labels(labels, n, origin-x, chart-width, origin-y, t)

      // Axis labels
      #let y-center = pad-top + chart-height / 2
      #let title-gap = t.at("axis-title-gap", default: t.axis-label-gap)
      #if left-label != none {
        let lbl = text(size: t.axis-title-size, fill: l-color)[#left-label]
        let rotated = rotate(-90deg, lbl)
        let rot-size = measure(rotated)
        let l-tw = measure-y-tick-width(l-min, l-max, t)
        // Left ticks right-edge is at origin-x - gap/2; title snug against ticks
        let dx = origin-x - t.axis-label-gap / 2 - l-tw - rot-size.width
        place(left + top, dx: dx, dy: y-center - rot-size.height / 2, rotated)
      }
      #if right-label != none {
        let lbl = text(size: t.axis-title-size, fill: r-color)[#right-label]
        let rotated = rotate(-90deg, lbl)
        let rot-size = measure(rotated)
        let r-tw = measure-y-tick-width(r-min, r-max, t)
        // Right ticks right-edge is at origin-x + chart-width + gap + r-tw; title snug against ticks
        let dx = origin-x + chart-width + t.axis-label-gap / 2 + r-tw
        place(left + top, dx: dx, dy: y-center - rot-size.height / 2, rotated)
      }
      #if x-label != none {
        let lbl = text(size: t.axis-title-size, fill: t.text-color)[#x-label]
        let lbl-size = measure(lbl)
        place(left + top, dx: origin-x + chart-width / 2 - lbl-size.width / 2, dy: origin-y + t.axis-label-gap + t.axis-label-size,
          lbl
        )
      }

      // Annotations — x is point index [0, n-1], y defaults to left-axis range
      #draw-annotations(annotations, origin-x, pad-top, chart-width, chart-height, 0, calc.max(n - 1, 1), l-min, l-max, t)
    ]
  ]
  })
}
