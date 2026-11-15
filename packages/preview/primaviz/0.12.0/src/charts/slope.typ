// slope.typ - Slope chart (two-period comparison)
#import "../theme.typ": _resolve-ctx, get-color
#import "../util.typ": nonzero
#import "../validate.typ": validate-slope-data
#import "../primitives/container.typ": chart-container
#import "../primitives/layout.typ": resolve-size, pin, text-width, text-height, fit-font-size, spread-labels
#import "../primitives/rows.typ": value-str

/// Renders a slope chart showing changes between two time periods.
///
/// Each item is drawn as a line connecting its start-value (left axis)
/// to its end-value (right axis), with dots and labels at both endpoints.
/// Labels of values that are close are spread apart (with a short leader to
/// their dot) so that none overlaps another.
///
/// - data (dictionary): Must contain `labels`, `start-values`, `end-values`,
///   and optionally `start-label` and `end-label`.
/// - width (length): Chart width
/// - height (length): Chart height
/// - title (none, content): Optional chart title
/// - dot-size (auto, length): Diameter of endpoint dots; `auto` scales with the theme's `base-size` (0.75x, 6pt in the default theme)
/// - line-width (auto, length): Stroke width of connecting lines; `auto` uses the theme's `stroke-thick`
/// - show-values (bool): Display numeric values next to dots
/// - theme (none, dictionary): Theme overrides
/// -> content
#let slope-chart(
  data,
  width: auto,
  height: auto,
  title: none,
  dot-size: auto,
  line-width: auto,
  show-values: true,
  theme: none,
) = context {
  layout(size => {
  validate-slope-data(data, "slope-chart")
  let t = _resolve-ctx(theme)
  let dot-size = if dot-size == auto { 0.75 * t.base-size } else { dot-size }
  let line-width = if line-width == auto { t.stroke-thick } else { line-width }
  let labels = data.labels
  let n = labels.len()
  let (width, height) = resolve-size(width, height, size, n: n, theme: t, rows: true, row-pitch: t.cell-size * 1.5)

  let start-values = data.start-values
  let end-values = data.end-values
  let start-label = if "start-label" in data { data.start-label } else { "Start" }
  let end-label = if "end-label" in data { data.end-label } else { "End" }

  let all-values = start-values + end-values
  let max-val = calc.max(..all-values)
  let min-val = calc.min(..all-values)
  let val-range = max-val - min-val

  // Endpoint texts: "name value" on the left, "value name" on the right
  let left-text(i) = if show-values { [#labels.at(i) #value-str(start-values.at(i), t)] } else { [#labels.at(i)] }
  let right-text(i) = if show-values { [#value-str(end-values.at(i), t) #labels.at(i)] } else { [#labels.at(i)] }
  let dot-r = dot-size / 2
  let stem = dot-r + 6pt  // dot centre to label edge; the leader crosses it

  // Column headers over each axis
  let head-size = t.axis-title-size
  let head-h = text-height(start-label, head-size, weight: "bold")
  let pad-top = head-h + t.axis-label-gap * 1.5

  // Label size: shrink so each side's longest label takes at most 30% of the chart,
  // and so that all the rows fit the height (a label is 1.05 em at its tightest)
  let side-cap = width * 0.34 - stem
  let widest(side) = array.range(n).fold(none, (best, i) => {
    let cur = side(i)
    if best == none or text-width(cur, t.axis-label-size) > text-width(best, t.axis-label-size) { cur } else { best }
  })
  let w-left = widest(left-text)
  let w-right = widest(right-text)
  let lbl-size = calc.min(
    fit-font-size(w-left, side-cap, t.axis-label-size, min: 6.5pt),
    fit-font-size(w-right, side-cap, t.axis-label-size, min: 6.5pt),
    calc.max(5.5pt, (height - pad-top) / (1.06 * n + 0.3)),
  )
  let left-w = calc.min(text-width(w-left, lbl-size), side-cap)
  let right-w = calc.min(text-width(w-right, lbl-size), side-cap)
  let axis-x-left = left-w + stem
  let axis-x-right = width - right-w - stem

  // One label's height, with leading: the tallest of all, so that labels which
  // wrap in a narrow gutter still clear each other
  let tall = calc.max(0pt, ..array.range(n).map(i => calc.max(
    measure(box(width: left-w + 1pt, text(size: lbl-size)[#left-text(i)])).height,
    measure(box(width: right-w + 1pt, text(size: lbl-size)[#right-text(i)])).height,
  )))
  let lh = calc.max(lbl-size * 1.3, tall * 1.15)
  // Crowded labels may close up to their ink and a hair (a line of text is about 1.05 em)
  // before any is left out (more names than the height holds)
  let lh-min = calc.max(lbl-size * 1.05, tall * 1.05)
  let y-top = pad-top + lh / 2
  let y-bot = height - lh / 2
  let y-of(v) = if val-range == 0 { (y-top + y-bot) / 2 } else {
    y-top + (1 - (v - min-val) / val-range) * (y-bot - y-top)
  }
  let ys-start = start-values.map(y-of)
  let ys-end = end-values.map(y-of)
  let ly-start = spread-labels(ys-start, sizes: lh, min-gap: lh-min - lh, lo: pad-top, hi: height)
  let ly-end = spread-labels(ys-end, sizes: lh, min-gap: lh-min - lh, lo: pad-top, hi: height)

  let axis-stroke = t.stroke-thin + t.text-color-light.transparentize(50%)

  chart-container(width, height, title, t)[
    #box(width: width, height: height)[
      // Headers
      #for (x, name) in ((axis-x-left, start-label), (axis-x-right, end-label)) {
        let w = text-width(name, head-size, weight: "bold")
        place(left + top, dx: calc.max(0pt, calc.min(width - w, x - w / 2)), dy: 0pt,
          text(size: head-size, weight: "bold", fill: t.text-color)[#name])
      }

      // Light axes: the dots carry the data
      #place(left + top, line(start: (axis-x-left, pad-top), end: (axis-x-left, height), stroke: axis-stroke))
      #place(left + top, line(start: (axis-x-right, pad-top), end: (axis-x-right, height), stroke: axis-stroke))

      #for (i, lbl) in labels.enumerate() {
        let color = get-color(t, i)
        let (y0, y1) = (ys-start.at(i), ys-end.at(i))
        place(left + top, line(start: (axis-x-left, y0), end: (axis-x-right, y1), stroke: line-width + color))
        place(left + top, dx: axis-x-left - dot-r, dy: y0 - dot-r, circle(radius: dot-r, fill: color, stroke: t.marker-stroke))
        place(left + top, dx: axis-x-right - dot-r, dy: y1 - dot-r, circle(radius: dot-r, fill: color, stroke: t.marker-stroke))

        // Left label, right-aligned against its axis
        let (yl, yr) = (ly-start.at(i), ly-end.at(i))
        if yl != none and calc.abs(yl - y0) > 0.5pt {
          place(left + top, line(start: (axis-x-left - dot-r, y0), end: (axis-x-left - stem + 1pt, yl), stroke: 0.5pt + color))
        }
        if yl != none {
          place(left + top, dx: axis-x-left - stem - left-w - 1pt, dy: yl,
            box(width: left-w + 1pt, height: 0pt, align(right + horizon, text(size: lbl-size, fill: t.text-color)[#left-text(i)])))
        }
        // Right label
        if yr != none and calc.abs(yr - y1) > 0.5pt {
          place(left + top, line(start: (axis-x-right + dot-r, y1), end: (axis-x-right + stem - 1pt, yr), stroke: 0.5pt + color))
        }
        if yr != none {
          place(left + top, dx: axis-x-right + stem, dy: yr,
            box(width: right-w + 1pt, height: 0pt, align(left + horizon, text(size: lbl-size, fill: t.text-color)[#right-text(i)])))
        }
      }
    ]
  ]
  })
}
