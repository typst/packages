// frame.typ - The frame every cartesian chart is drawn in
//
// A chart describes its axes (`value-axis`, `category-axis`) and a `body` that
// draws the marks; the frame does the rest, measuring as it goes:
//
//   container -> title -> [ y title | y tick labels | PLOT | y2 ... ]
//                         [           x tick labels            ]
//                         [           x title                  ] -> legend
//
// Margins come from the text that has to fit in them (tick label widths, the
// rotated title's thickness, the label row's height), never from fixed padding,
// so tick labels, axis titles, legends and container edges keep the same
// measured offsets in every chart and theme. The grid, tick marks, tick labels
// and the scale all read one resolved tick list.

#import "../theme.typ": *
#import "container.typ": chart-container, legend-gap
#import "annotations.typ": draw-annotations, annotation-reserve
#import "axes.typ": *
#import "fonts.typ": pin

/// Draws a cartesian chart: container, title, legend, axes, grid, tick labels,
/// axis titles and annotations around the marks `body` draws.
///
/// `body` is called with the plot record `p`:
///   - `p.x0`, `p.y0`, `p.x1`, `p.y1`, `p.w`, `p.h`: the plot rectangle, in the
///     coordinates of the `width` x `height` box `body` draws into
///   - `p.px(v)`, `p.py(v)`, `p.py2(v)`: data value (category index on a
///     category axis) to position; `p.t` is the theme
///   - `p.X`, `p.Y`, `p.Y2`: the resolved axes (`nt` tick record, `pitch`, ...)
/// Marks are placed with `place(left + top, dx: .., dy: .., ..)`.
///
/// - width (length): Width of the chart box (axes and titles included)
/// - height (length): Height of the chart box
/// - t (dictionary): Resolved theme
/// - x (dictionary): x axis (`value-axis` or `category-axis`)
/// - y (dictionary): y axis (`value-axis`; horizontal bars use the row primitives, `row-chart`)
/// - y2 (none, dictionary): Optional second value axis on the right, aligned to
///   the grid of `y` when the two can share one
/// - title (none, content): Chart title
/// - subtitle (none, content): Chart subtitle
/// - radius (length): Container corner radius
/// - legend (none, content): Legend, placed per `theme.legend-position`
/// - extra-legend-separation (length): Extra space between legend and chart
/// - show-ticks (bool): Draw tick marks on the axis lines
/// - show-minor-grid (bool): Draw lighter grid lines between the major ones
/// - axis-lines (dictionary): `(x: bool, y: bool)`: which axis lines to draw
/// - baseline (dictionary): `(y: v)` or `(x: v)`: draw the axis line at
///   that value instead of at the plot edge (bars: zero)
/// - reserve (dictionary): Extra room `left`/`right`/`top`/`bottom` inside the
///   box for marks that stick out of the plot (value labels, end labels)
/// - annotations (none, array): Annotation descriptors, drawn over the marks
/// - body (function): `p => content`
/// -> content
#let cartesian-frame(
  width, height, t,
  x: none, y: none, y2: none,
  title: none, subtitle: none, radius: 0pt,
  legend: none, extra-legend-separation: 0pt,
  show-ticks: false, show-minor-grid: false,
  axis-lines: (x: true, y: true),
  baseline: (:),
  reserve: (:),
  annotations: none,
  body,
) = {
  // A legend beside the chart takes its room out of `width`, so the chart is as
  // wide as asked (plus the container's padding) wherever the legend goes
  let side-legend = legend != none and (t.legend-position == "right" or t.legend-position == "left")
  let legend-w = if side-legend { calc.min(measure(legend).width, 0.4 * width) } else { 0pt }
  let width = if side-legend { width - legend-w - legend-gap } else { width }

  let ts = t.axis-title-size
  // Gap between an axis and its tick labels, and between tick labels and the title
  let g = t.label-offset + if show-ticks { t.tick-length * 0.6 } else { 0pt }
  let tg = t.axis-title-gap
  let rsv(key) = reserve.at(key, default: 0pt)
  let ann = annotation-reserve(annotations, t)
  let pad-top = calc.max(t.axis-padding-top, rsv("top"), ann.top)

  let title-of(ax) = if ax == none or ax.title == none { none } else {
    text(
      size: ts, fill: if ax.color == auto { t.text-color } else { ax.color },
      top-edge: "ascender", bottom-edge: "descender",
    )[#ax.title]
  }
  let thick(c) = if c == none { 0pt } else { measure(c).height }
  let label-w(ax) = if ax == none or not ax.labelled { 0pt } else { widest-label(ax.labels, t) }
  let text-of(ax, i) = ax.at("texts", default: ax.labels).at(i)

  // ── y axes: their tick labels and titles set the side margins ──────────────
  let x-title = title-of(x)
  let x-title-h = if x-title == none { 0pt } else { tg + thick(x-title) }
  // Room for the y tick budget before the row of x labels is known
  let est = calc.max(height - pad-top - g - label-row-height(t) - x-title-h, 40pt)
  let (ya, y2a) = if y.kind == "value" and y2 != none {
    resolve-value-pair(y, y2, est, t)
  } else {
    (resolve-value-axis(y, est, true, t),
     if y2 == none { none } else { resolve-value-axis(y2, est, true, t) })
  }
  let y-title = title-of(ya)
  let y2-title = title-of(y2a)
  let y-w = label-w(ya)
  let y2-w = label-w(y2a)
  let side(w, ttl) = (if w > 0pt { w + g } else { 0pt }) + (if ttl == none { 0pt } else { thick(ttl) + tg })
  let pad-left0 = side(y-w, y-title) + rsv("left")
  let pad-right0 = (if y2a != none { side(y2-w, y2-title) } else { t.label-offset }) + rsv("right") + ann.right

  // ── x axis: resolved over the plot width; end labels may widen the margins ──
  let corner = x.kind == "value" and x.inset == 0pt and ya.kind == "value" and ya.inset == 0pt
  let layout-x(pl, pr) = {
    let w = calc.max(width - pl - pr, 24pt)
    let xa = if x.kind == "value" { resolve-value-axis(x, w, false, t) } else { resolve-category-axis(x, w, t, max-block: 0.34 * height) }
    let (over-l, over-r) = if xa.kind == "value" {
      let ws = xa.labels.map(l => measure(label-text(l, t)).width)
      (if corner { 0pt } else { calc.max(0pt, ws.first() / 2 - xa.inset) },
       calc.max(0pt, ws.last() / 2 - xa.inset))
    } else { (xa.over-left, 0pt) }
    (xa: xa, w: w, over-l: over-l, over-r: over-r)
  }
  let first = layout-x(pad-left0, pad-right0)
  let pad-left = calc.max(pad-left0, first.over-l)
  let pad-right = calc.max(pad-right0, first.over-r)
  let lx = if pad-left == pad-left0 and pad-right == pad-right0 { first } else { layout-x(pad-left, pad-right) }
  let (xa, plot-w) = (lx.xa, lx.w)

  let pad-bottom = g + xa.block + x-title-h + rsv("bottom")
  let plot-h = calc.max(height - pad-top - pad-bottom, 24pt)

  let (x0, y0) = (pad-left, pad-top)
  let (x1, y1) = (x0 + plot-w, y0 + plot-h)
  let xs = axis-scale(xa, x0, plot-w)
  let ys = axis-scale(ya, y0, plot-h, flip: ya.kind == "value")
  let y2s = if y2a != none { axis-scale(y2a, y0, plot-h, flip: true) }
  let (px, py) = (xs.pos, ys.pos)

  let p = (
    t: t, x0: x0, y0: y0, x1: x1, y1: y1, w: plot-w, h: plot-h,
    X: xa, Y: ya, Y2: y2a, px: px, py: py, py2: if y2s != none { y2s.pos },
    dom: (x: xs.dom, y: ys.dom),
  )

  // ── drawing helpers ────────────────────────────────────────────────────────
  let rule(a, b, stroke) = place(left + top, line(start: a, end: b, stroke: stroke))
  let row-h = label-row-height(t)
  let axis-color(ax) = if ax.color == auto { t.text-color } else { ax.color }

  // y tick labels: right-aligned against the axis (left) or left-aligned (right)
  let y-labels(ax, pos, left-side) = if ax.labelled {
    let w = label-w(ax)
    for (i, v) in ax.nt.ticks.enumerate() {
      place(left + top, dx: if left-side { x0 - g - w } else { x1 + g }, dy: pos(v),
        pin(width: w, align: (if left-side { right } else { left }) + horizon,
          label-text(text-of(ax, i), t, fill: axis-color(ax))))
    }
  }

  // x tick labels: flat and centred, or tilted so the text ends at its mark
  let x-labels() = if xa.labelled {
    let ticks = if xa.kind == "value" { xa.nt.ticks } else { xa.shown }
    for (k, v) in ticks.enumerate() {
      let i = if xa.kind == "value" { k } else { v }
      let cx = px(v)
      let lbl = label-text(text-of(xa, i), t, size: if xa.kind == "category" { xa.size } else { auto })
      let w = measure(lbl).width
      if xa.kind == "category" and xa.angle == 90 {
        // Upright: reads upward and ends at its mark, centred on it
        let lh = label-line-height(t) * (xa.size / t.axis-label-size)
        place(left + top, dx: cx - w, dy: y1 + g - lh / 2,
          rotate(-90deg, origin: right + horizon, box(width: w, height: lh, lbl)))
      } else if xa.kind == "category" and xa.rotate {
        let lh = label-line-height(t) * (xa.size / t.axis-label-size)
        place(left + top, dx: cx - w, dy: y1 + g - 0.15 * lh,
          rotate(-45deg, origin: right + horizon, box(width: w, height: lh, lbl)))
      } else {
        // At the origin corner the first label starts at the axis so it clears the y labels
        let dx = if corner and k == 0 { x0 } else { cx - w / 2 }
        place(left + top, dx: dx, dy: y1 + g, box(width: w, height: row-h, align(center + top, lbl)))
      }
    }
  }

  let tick-marks() = if show-ticks {
    let tl = t.tick-length
    for v in ya.nt.ticks { rule((x0 - tl, py(v)), (x0, py(v)), t.axis-stroke) }
    if y2s != none { for v in y2a.nt.ticks { rule((x1, y2s.pos(v)), (x1 + tl, y2s.pos(v)), t.axis-stroke) } }
    let xs-ticks = if xa.kind == "value" { xa.nt.ticks } else { xa.shown }
    for v in xs-ticks { rule((px(v), y1), (px(v), y1 + tl), t.axis-stroke) }
  }

  let grid() = if t.show-grid != false {
    let minor = t.at("minor-grid-stroke", default: 0.25pt + t.text-color-light.transparentize(60%))
    // Lines run across the plot for every value axis; category axes have none
    let lines(ax, pos, horizontal) = {
      let at(c, stroke) = if horizontal { rule((x0, pos(c)), (x1, pos(c)), stroke) } else { rule((pos(c), y0), (pos(c), y1), stroke) }
      if show-minor-grid {
        for (a, b) in ax.nt.ticks.windows(2) {
          for j in range(1, 4) { at(a + (b - a) * j / 4, minor) }
        }
      }
      for v in ax.nt.ticks { at(v, t.grid-stroke) }
    }
    if ya.kind == "value" { lines(ya, py, true) }
    if xa.kind == "value" { lines(xa, px, false) }
  }

  let axes() = {
    let base-y = baseline.at("y", default: none)
    let base-x = baseline.at("x", default: none)
    let inside(ax, v) = v != none and ax.kind == "value" and v > ax.dlo and v < ax.dhi
    let line-y = if inside(ya, base-y) { py(base-y) } else { y1 }
    let line-x = if inside(xa, base-x) { px(base-x) } else { x0 }
    if axis-lines.at("x", default: true) { rule((x0, line-y), (x1, line-y), t.axis-stroke) }
    if axis-lines.at("y", default: true) {
      rule((line-x, y0), (line-x, y1), t.axis-stroke)
      if y2a != none { rule((x1, y0), (x1, y1), t.axis-stroke) }
    }
  }

  let titles() = {
    if x-title != none {
      place(left + top, dx: x0 + plot-w / 2 - measure(x-title).width / 2, dy: y1 + g + xa.block + tg, x-title)
    }
    // Rotated titles: the text box is placed so its centre lands on the
    // centre of the strip they occupy
    let side-title(ttl, strip-x) = if ttl != none {
      let (tw, th) = (measure(ttl).width, measure(ttl).height)
      place(left + top, dx: strip-x + th / 2 - tw / 2, dy: y0 + plot-h / 2 - th / 2, rotate(-90deg, ttl))
    }
    side-title(y-title, x0 - rsv("left") - side(y-w, none) - tg - thick(y-title))
    side-title(y2-title, x1 + g + y2-w + tg)
  }

  chart-container(
    width, height, title, t, legend: legend, legend-width: legend-w,
    extra-legend-separation: extra-legend-separation, subtitle: subtitle, radius: radius,
    box(width: width, height: height, {
      grid()
      body(p)
      axes()
      tick-marks()
      y-labels(ya, py, true)
      if y2a != none { y-labels(y2a, y2s.pos, false) }
      x-labels()
      titles()
      draw-annotations(annotations, x0, y0, plot-w, plot-h, xs.dom.lo, xs.dom.hi, ys.dom.lo, ys.dom.hi, t)
    }),
  )
}
