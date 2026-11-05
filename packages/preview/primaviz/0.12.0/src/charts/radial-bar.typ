// radial-bar.typ - Radial bar chart (bars radiating outward from center in a circle)
#import "../theme.typ": _resolve-ctx, get-color
#import "../util.typ": normalize-data, nice-ticks, clamp
#import "../validate.typ": validate-simple-data
#import "../primitives/container.typ": chart-container, container-inset
#import "../primitives/polar.typ": place-wedge, separator-stroke
#import "../primitives/polar-labels.typ": place-centred, place-outside-labels, polar-fit-radius, polar-label-extent, wrap-label
#import "../primitives/layout.typ": resolve-size

/// Renders a radial bar chart where each category occupies an equal angular
/// slice of a circle and bar length (radius) is proportional to value.
///
/// Concentric hairlines mark a value scale (labelled at 12 o'clock), and each
/// bar's name sits just beyond its own tip. With `show-values` the value is
/// printed under the name.
///
/// - data (dictionary, array): Label-value pairs as dict or array of tuples
/// - size (length): Diameter of the chart
/// - inner-radius (float): Inner hole as a fraction of the total radius (0.0 to 1.0)
/// - title (none, content): Optional chart title
/// - show-labels (bool): Display category labels beside the bar tips
/// - show-values (bool): Display numeric values at the bar tips
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
  layout(avail => {
  validate-simple-data(data, "radial-bar-chart")
  let t = _resolve-ctx(theme)
  let size = resolve-size(size, size, avail).width
  let norm = normalize-data(data)
  let (labels, values) = (norm.labels, norm.values)
  let n = values.len()
  if n == 0 { return }

  // A nice scale, so the hairlines fall on round values
  let scale = if calc.max(..values, 0) > 0 { nice-ticks(0, calc.max(..values), count: 4) } else { (ticks: (0, 1), max: 1) }
  let scale-max = scale.max
  let slice-deg = 360 / n
  let bg = if t.background != none { t.background } else { white }
  let mid-of(i) = -90 + (i + 0.5) * slice-deg
  let frac-of(v) = clamp(v / scale-max, 0, 1)
  let value-text(v) = str(calc.round(v, digits: 1))

  // Name (and value) beside each tip. How far out a tip is depends on the
  // radius, so the labels are first measured, then the circle is sized.
  // With many bars a label at its own tip would land on its neighbours: past
  // ten they sit outside the circle, like a polar axis, and in smaller type
  let at-tip = n <= 10
  let label-size = if n > 16 { t.axis-label-size } else { t.legend-size }
  let tip-body(i) = {
    let parts = ()
    if show-labels {
      parts.push(wrap-label(text(size: label-size, fill: t.text-color, top-edge: "cap-height", bottom-edge: "descender")[#labels.at(i)],
        calc.max(60pt, size * 0.4), mid-of(i)))
    }
    if show-values { parts.push(text(size: label-size, weight: "bold", fill: t.text-color, top-edge: "cap-height", bottom-edge: "baseline")[#value-text(values.at(i))]) }
    stack(dir: ttb, spacing: 2pt, ..parts)
  }
  let wanted = show-labels or show-values
  let measured = if wanted { array.range(n).map(i => (angle: mid-of(i), body: tip-body(i))) } else { () }
  let label-gap = 4pt

  let r-out = size / 2
  let ext = polar-label-extent(measured, r-out, gap: label-gap)
  let avail-w = avail.width - 2 * t.at("container-inset", default: container-inset)
  if type(avail.width) == length and avail.width > 0pt and 2 * ext.x > avail-w {
    r-out = polar-fit-radius(measured, avail-w / 2, avail-w / 2, avail-w, avail-w, gap: label-gap)
    ext = polar-label-extent(measured, r-out, gap: label-gap)
  }
  let (box-w, box-h) = (2 * ext.x, 2 * ext.y)
  let (cx, cy) = (box-w / 2, box-h / 2)
  let r-in = r-out * inner-radius
  let radius-of(v) = r-in + (r-out - r-in) * frac-of(v)

  align(center, chart-container(box-w, box-h, title, t)[
    #box(width: box-w, height: box-h)[
      // Scale: a hairline circle per tick, the first being the baseline
      #for v in scale.ticks {
        let rr = radius-of(v)
        place(left + top, dx: cx - rr, dy: cy - rr, circle(radius: rr, stroke: t.grid-stroke))
      }

      // Bars
      #for (i, v) in values.enumerate() {
        place-wedge(cx, cy, r-in, radius-of(v), mid-of(i) - slice-deg / 2 + gap / 2, mid-of(i) + slice-deg / 2 - gap / 2,
          get-color(t, i), stroke: separator-stroke(t))
      }

      // Scale values, at 12 o'clock just inside their circle, on the page colour
      #for v in scale.ticks.filter(v => v > 0 and v <= scale-max) {
        let label = box(fill: bg, inset: (x: 1.5pt, y: 0.5pt), radius: 1pt,
          text(size: t.axis-label-size, fill: t.text-color-light, top-edge: "cap-height", bottom-edge: "baseline")[#v])
        let m = measure(label)
        place-centred(cx, cy - radius-of(v) + m.height / 2 + 1pt, m.width, m.height, label)
      }

      // Names (and values) beside the tips
      #place-outside-labels(
        measured.enumerate().map(((i, it)) => (..it, r: if at-tip { radius-of(values.at(i)) } else { r-out }, priority: values.at(i))),
        cx, cy, r-out, (left: 0pt, right: box-w, top: 0pt, bottom: box-h),
        gap: label-gap, leader-stroke: 0.5pt + t.text-color-light)
    ]
  ])
  })
}
