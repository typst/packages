// radial-bar.typ - Radial bar chart (bars radiating outward from center in a circle)
#import "../theme.typ": resolve-theme, get-color
#import "../util.typ": normalize-data
#import "../validate.typ": validate-simple-data
#import "../primitives/container.typ": chart-container

/// Renders a radial bar chart where each category occupies an equal angular
/// slice of a circle and bar length (radius) is proportional to value.
///
/// - data (dictionary, array): Label-value pairs as dict or array of tuples
/// - size (length): Diameter of the chart
/// - inner-radius (float): Inner hole as a fraction of the total radius (0.0 to 1.0)
/// - title (none, content): Optional chart title
/// - show-labels (bool): Display category labels around the perimeter
/// - show-values (bool): Display numeric values on bars
/// - gap (float): Angular gap between bars in degrees
/// - theme (none, dictionary): Theme overrides
/// -> content
#let radial-bar-chart(
  data,
  size: 250pt,
  inner-radius: 0.3,
  title: none,
  show-labels: true,
  show-values: false,
  gap: 2,
  theme: none,
) = {
  validate-simple-data(data, "radial-bar-chart")
  let t = resolve-theme(theme)
  let norm = normalize-data(data)
  let labels = norm.labels
  let values = norm.values

  let n = values.len()
  if n == 0 { return }

  let max-val = calc.max(..values)
  if max-val == 0 { max-val = 1 }

  let radius = size / 2
  let r-inner = radius * inner-radius

  // Each category gets an equal angular slice
  let slice-deg = 360 / n
  let half-gap = gap / 2

  // Line-segment resolution: ~72 segments per full circle
  let samples-per-circle = 72

  // Legend width when labels shown
  let legend-width = if show-labels { 100pt } else { 0pt }
  let total-width = size + legend-width

  chart-container(total-width, size, title, t, extra-height: 20pt)[
    #box(width: total-width, height: size)[
      // Center of chart
      #let cx = size / 2
      #let cy = size / 2

      // ── Draw bars as filled arc wedges ──────────────────────────────
      #for (i, val) in values.enumerate() {
        let bar-color = get-color(t, i)

        // Angular range for this bar
        let start-deg = i * slice-deg + half-gap - 90
        let end-deg = (i + 1) * slice-deg - half-gap - 90
        let sweep-deg = end-deg - start-deg
        if sweep-deg <= 0 { continue }

        // Outer radius proportional to value
        let r-outer = r-inner + (radius - r-inner) * (val / max-val)

        // Build polygon points: inner arc -> outer arc -> close
        // Number of segments for this arc
        let seg-count = calc.max(int(sweep-deg / 360 * samples-per-circle), 2)

        let pts = ()

        // Inner arc (start to end)
        for j in array.range(seg-count + 1) {
          let angle = start-deg + (j / seg-count) * sweep-deg
          let x = cx + r-inner * calc.cos(angle * 1deg)
          let y = cy + r-inner * calc.sin(angle * 1deg)
          pts.push((x, y))
        }

        // Outer arc (end back to start)
        for j in array.range(seg-count + 1) {
          let angle = end-deg - (j / seg-count) * sweep-deg
          let x = cx + r-outer * calc.cos(angle * 1deg)
          let y = cy + r-outer * calc.sin(angle * 1deg)
          pts.push((x, y))
        }

        place(
          left + top,
          polygon(
            fill: bar-color,
            stroke: (if t.background != none { t.background } else { white }) + 0.5pt,
            ..pts.map(p => (p.at(0), p.at(1)))
          )
        )

        // ── Value label (at midpoint of bar) ────────────────────────
        if show-values {
          let mid-angle-deg = (start-deg + end-deg) / 2
          let mid-r = (r-inner + r-outer) / 2
          let lx = cx + mid-r * calc.cos(mid-angle-deg * 1deg) - 10pt
          let ly = cy + mid-r * calc.sin(mid-angle-deg * 1deg) - 5pt
          place(
            left + top,
            dx: lx,
            dy: ly,
            text(size: t.value-label-size, fill: t.text-color-inverse, weight: "bold")[#calc.round(val, digits: 1)]
          )
        }
      }

      // ── Inner circle (aesthetic hole) ─────────────────────────────
      #if inner-radius > 0 {
        let hole-fill = if t.background != none { t.background } else { white }
        place(
          left + top,
          dx: cx - r-inner,
          dy: cy - r-inner,
          circle(radius: r-inner, fill: hole-fill, stroke: none)
        )
      }

      // ── Labels around the perimeter ───────────────────────────────
      #if show-labels {
        for (i, lbl) in labels.enumerate() {
          let mid-angle-deg = i * slice-deg + slice-deg / 2 - 90
          let label-r = radius + 8pt
          let lx = cx + label-r * calc.cos(mid-angle-deg * 1deg)
          let ly = cy + label-r * calc.sin(mid-angle-deg * 1deg)

          // Adjust text anchor based on position
          let dx-offset = -12pt
          let dy-offset = -5pt

          place(
            left + top,
            dx: lx + dx-offset,
            dy: ly + dy-offset,
            text(size: t.legend-size, fill: t.text-color)[#lbl]
          )
        }
      }
    ]
  ]
}
