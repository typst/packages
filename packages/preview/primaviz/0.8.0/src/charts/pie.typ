// pie.typ - Pie and donut charts
#import "../theme.typ": _resolve-ctx, get-color
#import "../util.typ": normalize-data
#import "../primitives/layout.typ": font-for-space, try-fit-label, resolve-size
#import "../validate.typ": validate-simple-data
#import "../primitives/container.typ": chart-container, container-inset
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
  donut-ratio: 0.4,
  subtitle: none,
  radius: 0pt,
  theme: none,
) = context {
  layout(avail => {
  validate-simple-data(data, "pie-chart")
  let t = _resolve-ctx(theme)
  let size = resolve-size(size, size, avail).width
  let norm = normalize-data(data)
  let labels = norm.labels
  let values = norm.values

  let total = values.sum()
  let n = values.len()

  // Respect both show-legend param and theme legend-position
  let show-legend = show-legend and t.legend-position != "none"

  // Calculate legend width — ensure enough room for label text + percentages
  let legend-gap = if show-legend { 20pt } else { 0pt }
  let legend-width = if not show-legend { 0pt } else if size < 120pt { calc.max(100pt, calc.min(150pt, n * 18pt + 30pt)) } else { calc.max(130pt, calc.min(180pt, n * 20pt + 40pt)) }

  // Total width: pie + gap + legend — clamp to available width
  // Subtract container inset (2×padding) since chart-container adds it to the outer box
  let container-inset = 2 * container-inset
  let avail-w = if type(avail.width) == length and avail.width > 0pt { avail.width } else { none }
  let total-width = size + legend-gap + legend-width
  if avail-w != none and total-width + container-inset > avail-w {
    let budget = avail-w - container-inset
    // Shrink pie to fit, keeping legend width
    let pie-budget = budget - legend-gap - legend-width
    if pie-budget >= 80pt {
      size = pie-budget
    } else {
      // Both need shrinking — give pie 60% of space
      size = budget * 0.55
      legend-width = budget - size - legend-gap
    }
    total-width = budget
  }

  let radius = size / 2

  // Build legend content
  let legend-entries = if show-legend {
    labels.enumerate().map(((i, lbl)) => {
      let pct = calc.round((values.at(i) / total) * 100, digits: 1)
      str(lbl) + " (" + str(pct) + "%)"
    })
  } else { () }
  let legend-content = if show-legend {
    draw-legend-vertical(legend-entries, t, width: legend-width)
  }

  // Compute legend height — grow container if legend is taller than pie
  let swatch-size = t.legend-swatch-size
  let legend-height = if show-legend { n * (swatch-size + 4pt) + 10pt } else { 0pt }
  let extra-height = calc.max(40pt, legend-height - size + 40pt)

  // Use chart-container's built-in side legend support for proper vertical centering
  let legend-pos-override = if show-legend { "right" } else { "none" }
  let t-with-legend = if show-legend {
    let d = t
    d.insert("legend-position", legend-pos-override)
    d
  } else { t }

  align(center, chart-container(size, size, title, t-with-legend, extra-height: extra-height, legend: if show-legend { legend-content }, legend-width: legend-width, subtitle: subtitle, radius: radius)[
    // Pie chart
    #box(width: size, height: size)[
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
          let label-dist = radius * (if donut { 0.75 } else { 0.7 })
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
    ]
  ])
  })
}
