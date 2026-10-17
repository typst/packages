// pie.typ - Pie and donut charts
#import "../theme.typ": _resolve-ctx, get-color
#import "../util.typ": normalize-data, nonzero
#import "../primitives/layout.typ": resolve-size
#import "../validate.typ": validate-simple-data
#import "../primitives/container.typ": chart-container, container-inset
#import "../primitives/polar.typ": place-wedge, separator-stroke
#import "../primitives/polar-labels.typ": label-ink, fit-wedge-label, place-centred, place-outside-labels, polar-label-extent
#import "../primitives/radial.typ": legend-left, legend-room, side-legend, split-width

/// Renders a pie or donut chart from label-value data.
///
/// Percentages sit inside their slice when they fit (shrinking a little if
/// need be); a slice too small for its label gets it just outside, with a
/// leader line if neighbouring labels push it away.
///
/// - data (dictionary, array): Label-value pairs as dict or array of tuples
/// - size (length): Diameter of the pie
/// - title (none, content): Optional chart title
/// - show-legend (bool): Show category legend beside the chart
/// - show-percentages (bool): Display percentage labels on slices
/// - donut (bool): Cut out the center to create a donut chart
/// - donut-ratio (float): Inner radius as fraction of outer radius (0 to 1)
/// - subtitle (none, content): Optional subtitle below the title
/// - radius (length): Corner radius of the chart container
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
  let (labels, values) = (norm.labels, norm.values)
  let total = nonzero(values.sum())
  let pcts = values.map(v => calc.round(v / total * 100, digits: 1))

  // Each slice's angular span, resolved once for wedges and labels alike.
  // Slices run clockwise from 12 o'clock (-90 in polar degrees, 0 = 3 o'clock).
  let slices = {
    let out = ()
    let cur = -90
    for (i, v) in values.enumerate() {
      let span = v / total * 360
      out.push((i: i, start: cur, span: span, mid: cur + span / 2, pct: pcts.at(i)))
      cur += span
    }
    out
  }

  // Legend column; the pie shrinks first if the container is narrow
  let legend-entries = labels.enumerate().map(((i, lbl)) => [#lbl (#pcts.at(i)%)])
  let legend-on = show-legend and t.legend-position != "none"
  // (dozens of entries flow into columns instead of one column taller than the pie)
  let lg = side-legend(legend-entries, t, enabled: legend-on, max-height: size * 1.3, max-total: legend-room(size, avail.width, t))
  let legend-side = if lg.legend != none { 10pt + lg.width } else { 0pt }
  let (size, side) = split-width(size, legend-side, avail.width, t)
  let lg-widths = (:)
  if side != legend-side {
    lg-widths = (min-width: side - 10pt, max-width: side - 10pt)
    lg = side-legend(legend-entries, t, enabled: legend-on, ..lg-widths, max-height: size * 1.3, max-total: side - 10pt)
  }

  // Percentage labels: inside the slice when they fit, outside when not
  let label-text(s) = if s.pct > 0 and s.pct < 0.1 { "<0.1%" } else { str(s.pct) + "%" }
  let r-hole = if donut { donut-ratio } else { 0 }
  let plan(pie-r) = {
    let inside = ()
    let outside = ()
    if show-percentages {
      for s in slices.filter(s => s.span > 0) {
        let ink = label-ink(get-color(t, s.i), t)
        let make(sz) = text(size: sz, weight: "bold", fill: ink, top-edge: "cap-height", bottom-edge: "baseline")[#label-text(s)]
        let r-in = pie-r * r-hole
        let fit = fit-wedge-label(make, s.mid, s.span / 2, r-in, pie-r, t.value-label-size, t.axis-label-size,
          r-pref: if donut { (r-in + pie-r) / 2 } else { pie-r * 0.7 })
        if fit != none {
          inside.push((s: s, fit: fit, body: make(fit.size)))
        } else {
          outside.push((angle: s.mid, priority: s.span,
            body: text(size: t.value-label-size, weight: "bold", fill: t.text-color, top-edge: "cap-height", bottom-edge: "baseline")[#label-text(s)]))
        }
      }
    }
    // Only the larger of the small slices get an outside label: a dozen of
    // them would shrink the pie to make room, and the legend lists every
    // percentage anyway
    let cap = if legend-on { 8 } else { 14 }
    outside = outside.sorted(key: o => -o.priority).slice(0, calc.min(outside.len(), cap))
    // Room the outside labels need around the pie
    let ms = outside.map(o => measure(o.body))
    let mx = if outside.len() > 0 { calc.max(..ms.map(m => m.width)) + 12pt } else { 0pt }
    // Above / below the pie only where a label actually sits there
    let my-h = if ms.len() > 0 { calc.max(..ms.map(m => m.height)) + 8pt } else { 0pt }
    let my-top = if outside.any(o => calc.sin(o.angle * 1deg) < -0.5) { my-h } else { 0pt }
    let my-bot = if outside.any(o => calc.sin(o.angle * 1deg) > 0.5) { my-h } else { 0pt }
    // Labels of a crowd are fanned along the circle, which can take them
    // somewhere other than where they started: make room for where they land
    if outside.len() > 0 {
      let ext = polar-label-extent(outside, pie-r, gap: 4pt)
      mx = calc.max(mx, ext.x - pie-r + 3pt)
      if ext.top > pie-r + 0.5pt { my-top = calc.max(my-top, ext.top - pie-r + 4pt) }
      if ext.bottom > pie-r + 0.5pt { my-bot = calc.max(my-bot, ext.bottom - pie-r + 4pt) }
    }
    (inside: inside, outside: outside, mx: mx, my-top: my-top, my-bot: my-bot)
  }
  let pl = plan(size / 2)
  if pl.mx > 0pt {
    let (shrunk, _) = split-width(size, side + 2 * pl.mx, avail.width, t)
    if shrunk < size {
      size = shrunk
      pl = plan(size / 2)
    }
  }

  let (box-w, box-h) = (size + 2 * pl.mx, size + pl.my-top + pl.my-bot)
  // A legend flowed into columns before the labels were known: fewer columns
  // if the chart and its labels left less room than that
  if lg.cols > 1 and box-w + 10pt + lg.width > avail.width - 2 * t.at("container-inset", default: container-inset) {
    lg = side-legend(legend-entries, t, enabled: legend-on, ..lg-widths, max-height: size * 1.3, max-total: legend-left(box-w, avail.width, t))
  }
  let (cx, cy) = (box-w / 2, pl.my-top + size / 2)
  let pie-r = size / 2
  // A legend far taller than the pie (dozens of entries) starts level with
  // the pie's top instead of leaving it floating mid-column
  let body-h = if lg.height > 1.5 * box-h { lg.height } else { box-h }

  align(center, chart-container(box-w, body-h, title, lg.theme, legend: lg.legend, legend-width: lg.width, subtitle: subtitle, radius: radius)[
    #box(width: box-w, height: body-h)[
      // Wedges first, then every label on top
      #if values.all(v => v == 0) {
        place(left + top, dx: cx - pie-r, dy: cy - pie-r, circle(radius: pie-r, stroke: t.grid-stroke))
      }
      #for s in slices {
        place-wedge(cx, cy, pie-r * r-hole, pie-r, s.start, s.start + s.span, get-color(t, s.i),
          stroke: separator-stroke(t, thickness: 1pt))
      }
      #for l in pl.inside {
        let (x, y) = (cx + l.fit.r * calc.cos(l.s.mid * 1deg), cy + l.fit.r * calc.sin(l.s.mid * 1deg))
        place-centred(x, y, l.fit.w, l.fit.h, l.body)
      }
      #place-outside-labels(pl.outside, cx, cy, pie-r, (left: 0pt, right: box-w, top: 0pt, bottom: box-h),
        leader-stroke: 0.5pt + t.text-color-light)
    ]
  ])
  })
}
