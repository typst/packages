// radar.typ - Radar/spider charts
#import "../theme.typ": _resolve-ctx, get-color
#import "../validate.typ": validate-series-data
#import "../primitives/container.typ": chart-container, container-inset
#import "../primitives/legend.typ": draw-legend-vertical
#import "../primitives/layout.typ": font-for-space, resolve-size

/// Renders a radar (spider) chart for comparing series across multiple axes.
///
/// - data (dictionary): Dict with `labels` (axis names) and `series` (each with `name` and `values`)
/// - size (length): Diameter of the radar chart
// - axis-max-value (none, number): The maximum value of the chart’s axes
/// - title (none, content): Optional chart title
/// - show-legend (bool): Show series legend
/// - show-value-labels (bool): Display scale values and data point labels
/// - fill-opacity (ratio): Opacity of the filled data area
/// - theme (none, dictionary): Theme overrides
/// -> content
#let radar-chart(
  data,
  size: 200pt,
  axis-max-value: none,
  title: none,
  show-legend: true,
  show-value-labels: true,
  fill-opacity: 15%,
  theme: none,
) = context {
  layout(avail => {
  validate-series-data(data, "radar-chart")
  let t = _resolve-ctx(theme)
  let size = resolve-size(size, size, avail).width
  let labels = data.labels
  let series = data.series
  let n = labels.len()

  // Find max value across all series
  let all-values = series.map(s => s.values).flatten()
  let max-val = if axis-max-value == none { calc.max(..all-values) } else { axis-max-value }

  // Respect both show-legend param and theme legend-position
  let show-legend = show-legend and t.legend-position != "none"

  // Calculate legend width — compact to leave room for the chart
  let legend-width = if show-legend and series.len() > 1 { calc.min(80pt, size * 0.4) } else { 0pt }

  // Shrink legend then chart if total width exceeds available space
  let container-inset = 2 * container-inset
  let avail-w = if type(avail.width) == length and avail.width > 0pt { avail.width } else { none }
  let total-width = size + legend-width
  if avail-w != none and total-width + container-inset > avail-w {
    let budget = avail-w - container-inset
    // First try shrinking legend to minimum 60pt
    legend-width = calc.max(60pt, budget - size)
    if size + legend-width > budget {
      // Still too wide — shrink chart proportionally
      size = budget - legend-width
    }
    total-width = size + legend-width
  }

  // Recompute radius after potential resize — leave margin for axis labels
  let radius = size / 2 - calc.max(16pt, size * 0.2)
  let cx = size / 2
  let cy = size / 2

  // Build legend content for chart-container's built-in side legend support
  let legend-content = if show-legend and legend-width > 0pt {
    draw-legend-vertical(series.map(s => s.name), t, width: legend-width)
  }
  let t-with-legend = if legend-content != none {
    let d = t
    d.insert("legend-position", "right")
    d
  } else { t }

  align(center, chart-container(size, size, title, t-with-legend, extra-height: 40pt, legend: legend-content, legend-width: legend-width)[
    #box(width: size, height: size)[
        // Draw grid polygons with value labels
        #for level in array.range(1, 5) {
          let r = radius * level / 4
          let pts = ()
          for i in array.range(n) {
            let angle = -90deg + (i / n) * 360deg
            pts.push((
              cx + r * calc.cos(angle),
              cy + r * calc.sin(angle)
            ))
          }
          pts.push(pts.at(0))

          place(
            left + top,
            polygon(
              fill: none,
              stroke: t.grid-stroke,
              ..pts.map(p => (p.at(0), p.at(1)))
            )
          )

          // Value label on first axis (top)
          if show-value-labels {
            let val = calc.round(max-val * level / 4, digits: 0)
            let grid-label-size = font-for-space(size, t.axis-label-size * 0.85, ratio: 0.04)
            place(
              left + top,
              dx: cx + 2pt,
              dy: cy - r - 3pt,
              text(size: grid-label-size, fill: t.text-color-light)[#val]
            )
          }
        }

        // Draw axis lines and labels
        #for (i, lbl) in labels.enumerate() {
          let angle = -90deg + (i / n) * 360deg
          let x-end = cx + radius * calc.cos(angle)
          let y-end = cy + radius * calc.sin(angle)

          // Axis line
          place(
            left + top,
            line(
              start: (cx, cy),
              end: (x-end, y-end),
              stroke: t.grid-stroke
            )
          )

          // Label positioning - push labels outward, clamped to chart bounds
          let label-size = font-for-space(size, t.value-label-size, min-size: 5pt, ratio: 0.055)
          let lbl-content = text(size: label-size, fill: t.text-color, weight: "medium")[#lbl]
          let lbl-w = measure(lbl-content).width + 4pt
          let lbl-h = measure(lbl-content).height
          let label-r = radius + 8pt
          let cos-val = calc.cos(angle)
          let sin-val = calc.sin(angle)
          let lx = cx + label-r * cos-val
          let ly = cy + label-r * sin-val

          // Determine alignment based on quadrant
          let (dx-adj, h-align) = if cos-val < -0.1 { (-lbl-w, right) }
            else if cos-val > 0.1 { (0pt, left) }
            else { (-lbl-w / 2, center) }
          let dy-adj = if sin-val < -0.1 { 0pt }
            else if sin-val > 0.1 { -lbl-h }
            else { -lbl-h / 2 }

          // Clamp so label stays within the chart box
          let final-x = calc.min(calc.max(0pt, lx + dx-adj), size - lbl-w)
          let final-y = calc.min(calc.max(0pt, ly + dy-adj), size - lbl-h)

          place(left + top, dx: final-x, dy: final-y,
            box(width: lbl-w, align(h-align, lbl-content)))
        }

        // Draw data series
        #for (si, s) in series.enumerate() {
          let pts = ()
          for (i, val) in s.values.enumerate() {
            let angle = -90deg + (i / n) * 360deg
            let r = (val / max-val) * radius
            pts.push((
              cx + r * calc.cos(angle),
              cy + r * calc.sin(angle)
            ))
          }

          let color = get-color(t, si)

          // Filled area — scale stroke with chart size
          let stroke-w = calc.max(0.4pt, size / 250)
          let dot-r = calc.max(1pt, size / 100)
          place(
            left + top,
            polygon(
              fill: color.transparentize(100% - fill-opacity),
              stroke: color + stroke-w,
              ..pts.map(p => (p.at(0), p.at(1)))
            )
          )

          // Points with value labels
          for (i, pt) in pts.enumerate() {
            place(
              left + top,
              dx: pt.at(0) - dot-r,
              dy: pt.at(1) - dot-r,
              circle(radius: dot-r, fill: color, stroke: t.marker-stroke)
            )

            // Show value near point (offset based on angle to avoid overlap)
            if show-value-labels and series.len() == 1 {
              let angle = -90deg + (i / n) * 360deg
              let offset-x = 8pt * calc.cos(angle)
              let offset-y = 8pt * calc.sin(angle)
              place(
                left + top,
                dx: pt.at(0) + offset-x,
                dy: pt.at(1) + offset-y,
                move(dx: -1em, dy: -0.5em,
                  text(size: t.axis-label-size, fill: color, weight: "bold")[#s.values.at(i)])
              )
            }
          }
        }
      ]
  ])
  })
}
