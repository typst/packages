// pie.typ - Pie and donut charts
#import "../theme.typ": _resolve-ctx, get-color
#import "../util.typ": normalize-data
#import "../primitives/layout.typ": font-for-space, try-fit-label
#import "../validate.typ": validate-simple-data
#import "../primitives/container.typ": chart-container
#import "../primitives/legend.typ": draw-legend-vertical
#import "../primitives/polar.typ": pie-slice-points, place-donut-hole, separator-stroke

/// Renders a pie or donut chart from label-value data.
///
/// - data (dictionary, array): Label-value pairs as dict or array of tuples
/// - size (length): Diameter of the pie
/// - title (none, content): Optional chart title
/// - show-legend (bool): Show category legend beside the chart
/// - show-percentages (bool): Display percentage labels on slices
/// - donut (bool): Cut out the center to create a donut chart
/// - donut-ratio (float): Inner radius as fraction of outer radius (0 to 1)
/// - theme (none, dictionary): Theme overrides
/// -> content
#let pie-chart(
  data,
  size: 150pt,
  title: none,
  show-legend: true,
  show-percentages: true,
  donut: false,
  donut-ratio: 0.5,
  theme: none,
) = context {
  validate-simple-data(data, "pie-chart")
  let t = _resolve-ctx(theme)
  let norm = normalize-data(data)
  let labels = norm.labels
  let values = norm.values

  let total = values.sum()
  let n = values.len()
  let radius = size / 2

  // Respect both show-legend param and theme legend-position
  let show-legend = show-legend and t.legend-position != "none"

  // Calculate legend width — ensure enough room for label text + percentages
  let legend-width = if size < 120pt { calc.max(100pt, calc.min(150pt, n * 18pt + 30pt)) } else { calc.max(130pt, calc.min(180pt, n * 20pt + 40pt)) }

  // Total width: pie + gap + legend (if shown)
  let total-width = size + (if show-legend { 20pt + legend-width } else { 0pt })

  // Compute legend height — grow container if legend is taller than pie
  let swatch-size = 10pt
  let legend-height = if show-legend { n * (swatch-size + 4pt) + 10pt } else { 0pt }
  let extra-height = calc.max(40pt, legend-height - size + 40pt)

  chart-container(total-width, size, title, t, extra-height: extra-height)[
    // Use a grid layout to keep pie and legend separate
    #grid(
      columns: if show-legend { (size, legend-width) } else { (size,) },
      column-gutter: 20pt,

      // Pie chart
      box(width: size, height: size)[
        #let center-x = radius
        #let center-y = radius
        #let current-deg = 0

        #for (i, val) in values.enumerate() {
          let slice-deg = (val / total) * 360

          let pts = pie-slice-points(center-x, center-y, radius, current-deg, current-deg + slice-deg)

          place(
            left + top,
            polygon(
              fill: get-color(t, i),
              stroke: separator-stroke(t, thickness: 1pt),
              ..pts,
            )
          )

          // Percentage label — try fitting into slice arc
          if show-percentages {
            let mid-deg = current-deg + slice-deg / 2
            let pct = calc.round((val / total) * 100, digits: 1)
            let pct-text = str(pct) + "%"
            let pct-len = pct-text.len()
            // Approximate available width from arc at label distance
            let label-dist = radius * (if donut { 0.75 } else { 0.6 })
            let arc-w = (label-dist / 1pt) * slice-deg / 360 * 2 * calc.pi * 1pt
            let arc-h = radius * 0.3  // radial height available
            let fit = try-fit-label(arc-w, arc-h, t.value-label-size, pct-len, shrink-min: 5pt)
            if fit.fits {
              let lx = center-x + label-dist * calc.cos(mid-deg * 1deg)
              let ly = center-y + label-dist * calc.sin(mid-deg * 1deg)
              place(
                left + top,
                dx: lx,
                dy: ly,
                move(dx: -1em, dy: -0.5em,
                  text(size: fit.size, fill: t.text-color-inverse, weight: "bold")[#pct-text])
              )
            }
          }

          current-deg = current-deg + slice-deg
        }

        // Donut hole
        #if donut {
          place-donut-hole(center-x, center-y, radius * donut-ratio, t)
        }
      ],

      // Legend (if shown)
      if show-legend {
        let legend-entries = labels.enumerate().map(((i, lbl)) => {
          let pct = calc.round((values.at(i) / total) * 100, digits: 1)
          str(lbl) + " (" + str(pct) + "%)"
        })
        draw-legend-vertical(legend-entries, t, width: legend-width)
      }
    )
  ]
}
