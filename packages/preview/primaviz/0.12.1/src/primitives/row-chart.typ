// row-chart.typ - Scaffold of the horizontal bar and lollipop charts
//
// Both draw one mark per row, from a zero line to the datum, with the value
// beside the mark's end. Everything around the marks comes from the row
// primitives (rows.typ): the measured label column and the dense-row policy
// (`row-layout`), the value axis (`draw-x-axis`), the value labels
// (`end-label`) and the natural size of a row chart (`resolve-size(rows: true)`).
// A chart only says how a mark looks.

#import "../theme.typ": get-color
#import "../util.typ": nice-ticks, nonzero
#import "container.typ": chart-container
#import "layout.typ": resolve-size, max-text-width
#import "rows.typ": row-layout, row-y, end-reserves, end-label, linear-x-ticks, draw-x-axis, x-axis-extent, tick-label-width
#import "axes.typ": value-text, fit-row-size, draw-axis-titles
#import "annotations.typ": draw-annotations, annotation-reserve

/// Lays out and draws a row chart; call inside `context` and `layout`.
///
/// Every row gets its category label: the row pitch grows with the row count
/// when `height` is `auto`; with a fixed height the label size shrinks to
/// `category-label-min-size` (theme key, 5pt unless set) and only then are labels
/// thinned out, evenly, the first and the last always shown.
///
/// - labels (array): Row labels
/// - values (array): One value per row
/// - width (auto, length, ratio, relative): Chart width
/// - height (auto, length, ratio, relative): Chart height
/// - size (dictionary): Available region from `layout(size => ...)`
/// - t (dictionary): Resolved theme
/// - title (none, content): Chart title
/// - x-label (none, content): Value axis title
/// - y-label (none, content): Category axis title
/// - annotations (none, array): Annotation descriptors
/// - extra-legend-separation (length): Extra space between legend and chart
/// - show-values (bool): Write each value beside the end of its mark
/// - reach (length): How far a mark sticks out beyond its value (a dot's radius)
/// - draw-mark (function): `(i, y, x-from, x-to, color, row-h) => content`, the mark of
///   row `i` centred on `y`, from the zero line to the value
/// -> content
#let row-chart(
  labels,
  values,
  width,
  height,
  size,
  t,
  title: none,
  x-label: none,
  y-label: none,
  annotations: none,
  extra-legend-separation: 0pt,
  show-values: true,
  reach: 0pt,
  draw-mark,
) = {
  let n = values.len()
  let (width, height) = resolve-size(width, height, size, n: n, theme: t, rows: true)
  let strs = values.map(v => value-text(v, t))
  let (lo, hi) = (calc.min(0, ..values), calc.max(0, ..values))
  let nt = nice-ticks(lo, if lo == hi { 1 } else { hi }, count: t.tick-count)
  let (alo, ahi) = (nt.min, nt.max)
  let span = nonzero(ahi - alo)

  // A rotated category title takes a band at the far left
  let band = if y-label == none { 0pt } else { measure(text(size: t.axis-title-size)[#y-label]).height + t.axis-title-gap }
  let inner-w = width - band

  // Rows: the measured label column, the axis band below, room above for annotation labels
  let ann = annotation-reserve(annotations, t)
  let pad-top = if annotations != none { calc.max(t.axis-padding-top, ann.top) } else { t.label-offset }
  let axis-h = x-axis-extent(t, title: x-label)
  let layout-with(inset-l, inset-r) = row-layout(inner-w, height, labels, t,
    label-frac: 0.38, pad-top: pad-top, pad-bottom: axis-h, inset-left: inset-l, inset-right: inset-r,
    min-label-size: t.at("category-label-min-size", default: 5pt))
  let probe = layout-with(0pt, 0pt)

  // Room past the extreme marks for their value labels and the end tick labels,
  // solved from where the extreme marks sit
  let value-w = if show-values { max-text-width(strs, t.value-label-size) + t.label-offset } else { 0pt }
  let (need-lo, need-hi) = ((if lo < 0 { value-w } else { 0pt }) + reach, (if hi > 0 { value-w } else { 0pt }) + reach)
  let tick-half = tick-label-width(linear-x-ticks(nt, alo, ahi, 0pt, 1pt, t), t) / 2
  let reserve = end-reserves(
    inner-w - probe.label-w - probe.gap, (lo - alo) / span, need-lo, (ahi - hi) / span, need-hi,
    floor: tick-half)
  let lay = layout-with(reserve.lo, reserve.hi + ann.right)
  let (x0, x1) = (lay.x0, lay.x1)
  let x-of(v) = x0 + (v - alo) / span * lay.plot-w
  let vsize = if show-values { fit-row-size(lay.row-h, t.value-label-size) }

  chart-container(width, height, title, t, extra-legend-separation: extra-legend-separation,
    box(width: width, height: height, place(left + top, dx: band, box(width: inner-w, height: height, {
      draw-x-axis(linear-x-ticks(nt, alo, ahi, x0, x1, t), lay.y1, t, x0: x0, x1: x1, grid-top: lay.y0, title: x-label)
      // The zero line is the category axis
      place(left + top, line(start: (x-of(0), lay.y0), end: (x-of(0), lay.y1), stroke: t.axis-stroke))
      lay.labels
      if y-label != none {
        draw-axis-titles(none, y-label, 0pt, (lay.y0 + lay.y1) / 2, t,
          origin-x: lay.label-w + lay.gap / 2, y-tick-width: lay.label-w)
      }
      for (i, val) in values.enumerate() {
        let y = row-y(lay, i)
        draw-mark(i, y, x-of(0), x-of(val), get-color(t, i), lay.row-h)
        if vsize != none {
          let after = val >= 0
          end-label(strs.at(i), x-of(val) + if after { reach } else { -reach }, y, if after { "right" } else { "left" },
            vsize, t.text-color, lo: lay.label-w + lay.gap / 2, hi: inner-w, gap: t.label-offset)
        }
      }
      draw-annotations(annotations, x0, lay.y0, lay.plot-w, lay.y1 - lay.y0, alo, ahi, -0.5, n - 0.5, t)
    }))),
  )
}
