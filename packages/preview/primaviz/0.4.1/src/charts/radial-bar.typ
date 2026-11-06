// radial-bar.typ - Radial bar chart (bars radiating outward from center in a circle)
#import "../theme.typ": _resolve-ctx, get-color
#import "../util.typ": normalize-data, nonzero
#import "../validate.typ": validate-simple-data
#import "../primitives/container.typ": chart-container
#import "../primitives/polar.typ": annular-wedge-points, place-polar-label, place-donut-hole, separator-stroke
#import "../primitives/layout.typ": font-for-space

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
) = context {
  validate-simple-data(data, "radial-bar-chart")
  let t = _resolve-ctx(theme)
  let norm = normalize-data(data)
  let labels = norm.labels
  let values = norm.values

  let n = values.len()
  if n == 0 { return }

  let max-val = nonzero(calc.max(..values))

  let radius = size / 2
  let r-inner = radius * inner-radius

  // Each category gets an equal angular slice
  let slice-deg = 360 / n
  let half-gap = gap / 2

  // Line-segment resolution: ~72 segments per full circle
  let samples-per-circle = 72

  // When labels are shown, expand the box to give room for perimeter text
  let label-pad = if show-labels { calc.max(20pt, size * 0.2) } else { 0pt }
  let box-size = size + label-pad * 2
  let total-width = box-size

  chart-container(total-width, box-size, title, t, extra-height: 20pt)[
    #box(width: box-size, height: box-size)[
      // Center of chart — offset by label padding
      #let cx = box-size / 2
      #let cy = box-size / 2

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

        let pts = annular-wedge-points(cx, cy, r-inner, r-outer, start-deg, end-deg)

        place(
          left + top,
          polygon(
            fill: bar-color,
            stroke: separator-stroke(t),
            ..pts,
          )
        )

        // ── Value label (at midpoint of bar) ────────────────────────
        if show-values {
          let mid-angle-deg = (start-deg + end-deg) / 2
          let mid-r = (r-inner + r-outer) / 2
          place-polar-label(cx, cy, mid-angle-deg, mid-r,
            text(size: t.value-label-size, fill: t.text-color-inverse, weight: "bold")[#calc.round(val, digits: 1)])
        }
      }

      // ── Inner circle (aesthetic hole) ─────────────────────────────
      #if inner-radius > 0 {
        place-donut-hole(cx, cy, r-inner, t)
      }

      // ── Labels around the perimeter ───────────────────────────────
      #if show-labels {
        let lbl-size = font-for-space(size, t.legend-size, min-size: 5pt, ratio: 0.05)
        for (i, lbl) in labels.enumerate() {
          let mid-angle-deg = i * slice-deg + slice-deg / 2 - 90
          place-polar-label(cx, cy, mid-angle-deg, radius + calc.max(6pt, size * 0.06),
            text(size: lbl-size, fill: t.text-color)[#lbl])
        }
      }
    ]
  ]
}
