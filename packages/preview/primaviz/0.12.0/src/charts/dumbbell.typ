// dumbbell.typ - Dumbbell chart (before/after or range comparison)
#import "../theme.typ": _resolve-ctx, get-color
#import "../util.typ": nonzero, nice-ticks
#import "../validate.typ": validate-dumbbell-data
#import "../primitives/container.typ": chart-container
#import "../primitives/legend.typ": draw-legend-auto, legend-max-width
#import "../primitives/layout.typ": resolve-size, max-text-width
#import "../primitives/rows.typ": row-layout, row-y, end-reserves, end-label, row-value-size, value-str, linear-x-ticks, draw-x-axis, x-axis-extent, tick-label-width

/// Renders a dumbbell chart showing range or before/after comparisons.
///
/// Each category is drawn as a horizontal row with two dots (start and end
/// values) connected by a thin line. Categories appear on the Y-axis (left)
/// and values on the X-axis (bottom).
///
/// - data (dictionary): Must contain `labels`, `start-values`, `end-values`,
///   and optionally `start-label` and `end-label`.
/// - width (length): Chart width
/// - height (length): Chart height
/// - title (none, content): Optional chart title
/// - dot-size (auto, length): Diameter of endpoint dots; `auto` scales with the theme's `base-size` (1.25x, 10pt in the default theme)
/// - line-width (auto, length): Stroke width of connecting lines; `auto` uses the theme's `stroke-thick`
/// - show-values (bool): Display numeric values next to dots
/// - theme (none, dictionary): Theme overrides
/// - extra-legend-separation (length): Extra space between legend and chart
/// -> content
#let dumbbell-chart(
  data,
  width: auto,
  height: auto,
  title: none,
  dot-size: auto,
  line-width: auto,
  show-values: false,
  theme: none,
  extra-legend-separation: 0pt
) = context {
  layout(size => {
  validate-dumbbell-data(data, "dumbbell-chart")
  let t = _resolve-ctx(theme)
  let line-width = if line-width == auto { t.stroke-thick } else { line-width }
  let labels = data.labels
  let n = labels.len()
  let (width, height) = resolve-size(width, height, size, n: n, theme: t, rows: true)

  let start-values = data.start-values
  let end-values = data.end-values
  let start-label = if "start-label" in data { data.start-label } else { "Start" }
  let end-label-name = if "end-label" in data { data.end-label } else { "End" }

  // Nice step-aligned axis range
  let all-values = start-values + end-values
  let nt = nice-ticks(calc.min(..all-values), calc.max(..all-values), count: t.tick-count)
  let (lo, hi) = (nt.min, nt.max)
  let span = nonzero(hi - lo)

  // Rows: measured label column, with the axis band below
  let axis-h = x-axis-extent(t)
  let probe = row-layout(width, height, labels, t, pad-bottom: axis-h)
  let dot-d = calc.min(if dot-size == auto { 1.25 * t.base-size } else { dot-size }, probe.row-h * 0.7)
  let dot-r = dot-d / 2
  let v-size = row-value-size(t, probe.row-h)
  let show-values = show-values and v-size != none
  let v-size = if v-size == none { 5pt } else { v-size }
  let v-gap = t.axis-label-gap / 2

  // Room beside the plot ends for the dots, their value labels and the
  // outermost tick labels, solved from where the extreme dots actually sit
  let tick-half = tick-label-width(linear-x-ticks(nt, lo, hi, 0pt, 1pt, t), t) / 2
  let v-w = if show-values {
    max-text-width(all-values.map(v => value-str(v, t)), v-size)
  } else { 0pt }
  let need = dot-r + if show-values { v-gap + v-w } else { 0pt }
  let reserve = end-reserves(
    width - probe.label-w - probe.gap,
    (calc.min(..all-values) - lo) / span, need,
    (hi - calc.max(..all-values)) / span, need,
    floor: calc.max(dot-r, tick-half),
  )
  let lay = row-layout(width, height, labels, t, pad-bottom: axis-h, inset-left: reserve.lo, inset-right: reserve.hi)
  let (x0, x1) = (lay.x0, lay.x1)
  let val-to-x(v) = x0 + (v - lo) / span * lay.plot-w

  let start-color = get-color(t, 0)
  let end-color = get-color(t, 1)

  // The legend keys the marks, so its swatches are the dots' size (the theme's
  // `legend-swatch-size`; `legend-swatch-size()` caps it at 3/4 of the legend text)
  let legend-content = draw-legend-auto(
    ((name: start-label, color: start-color), (name: end-label-name, color: end-color)),
    (..t, legend-swatch-size: dot-d), swatch-type: "circle", fit-width: true, max-width: legend-max-width(width, t),
  )

  chart-container(width, height, title, t, legend: legend-content, extra-legend-separation: extra-legend-separation)[
    #box(width: width, height: height)[
      // Light row guides carry the eye from label to dots
      #for i in range(n) {
        place(left + top, line(start: (x0, row-y(lay, i)), end: (x1, row-y(lay, i)), stroke: t.grid-stroke))
      }

      #draw-x-axis(linear-x-ticks(nt, lo, hi, x0, x1, t), lay.y1, t, x0: x0, x1: x1, grid-top: lay.y0)
      #lay.labels

      #for i in range(n) {
        let y = row-y(lay, i)
        let sv = start-values.at(i)
        let ev = end-values.at(i)
        let xs = val-to-x(sv)
        let xe = val-to-x(ev)

        place(left + top, line(start: (xs, y), end: (xe, y), stroke: line-width + t.text-color-light))
        place(left + top, dx: xs - dot-r, dy: y - dot-r, circle(radius: dot-r, fill: start-color, stroke: t.marker-stroke))
        place(left + top, dx: xe - dot-r, dy: y - dot-r, circle(radius: dot-r, fill: end-color, stroke: t.marker-stroke))

        // Value labels sit on the outer side of each dot: the lower value to the
        // left, the higher to the right (equal values share one label)
        if show-values {
          let lo-x = lay.label-w + lay.gap / 2
          let (x-lo, x-hi) = if sv <= ev { (xs, xe) } else { (xe, xs) }
          let (v-lo, v-hi) = if sv <= ev { (sv, ev) } else { (ev, sv) }
          if v-lo != v-hi {
            end-label(value-str(v-lo, t), x-lo - dot-r, y, "left", v-size, t.text-color, lo: lo-x, hi: width, gap: v-gap)
          }
          end-label(value-str(v-hi, t), x-hi + dot-r, y, "right", v-size, t.text-color, lo: lo-x, hi: width, gap: v-gap)
        }
      }
    ]
  ]
  })
}
