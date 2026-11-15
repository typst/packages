// diverging.typ - Diverging bar chart (bars extend left/right from center axis)
#import "../theme.typ": _resolve-ctx, get-color
#import "../util.typ": nonzero, nice-ticks, contrast-text
#import "../validate.typ": validate-diverging-data
#import "../primitives/container.typ": chart-container
#import "../primitives/layout.typ": resolve-size, text-width, text-height, fit-font-size, max-text-width
#import "../primitives/rows.typ": row-layout, row-y, end-label, row-value-size, value-str, linear-x-ticks, draw-x-axis, x-axis-extent, tick-label-width

/// Renders a horizontal diverging bar chart where bars extend left and right
/// from a central vertical axis. Useful for survey results (agree/disagree),
/// sentiment analysis, and population pyramids.
///
/// The two sides are named directly above their halves of the chart (a legend
/// would only repeat that), when `left-label` / `right-label` are given.
///
/// - data (dictionary): Dictionary with keys:
///   - `labels` (array): Category labels for each row
///   - `left-values` (array): Numeric values for the left side
///   - `right-values` (array): Numeric values for the right side
///   - `left-label` (string, optional): Name of the left side
///   - `right-label` (string, optional): Name of the right side
/// - width (length): Chart width
/// - height (length): Chart height
/// - title (none, content): Optional chart title
/// - show-values (bool): Display value labels at bar ends
/// - bar-height (auto, float): Bar thickness as fraction of slot (0 to 1), auto = 0.6
/// - x-label (none, content): X-axis title
/// - theme (none, dictionary): Theme overrides
/// - extra-legend-separation (length): Extra space between title block and chart
/// -> content
#let diverging-bar-chart(
  data,
  width: auto,
  height: auto,
  title: none,
  show-values: true,
  bar-height: auto,
  x-label: none,
  theme: none,
  extra-legend-separation: 0pt
) = context {
  layout(size => {
  validate-diverging-data(data, "diverging-bar-chart")
  let t = _resolve-ctx(theme)
  let labels = data.labels
  let n = labels.len()
  let (width, height) = resolve-size(width, height, size, n: n, theme: t, rows: true)

  let left-values = data.left-values.map(calc.abs)
  let right-values = data.right-values.map(calc.abs)
  let left-label = if "left-label" in data { data.left-label } else { none }
  let right-label = if "right-label" in data { data.right-label } else { none }
  let bar-frac = if bar-height == auto { 0.6 } else { bar-height }

  // Scale to the top tick (not the raw max) so bars and tick labels agree
  let max-raw = calc.max(..left-values, ..right-values)
  let nt = nice-ticks(0, nonzero(max-raw), count: t.tick-count)
  let max-val = nt.max

  // Side names: direct labels in a band above the rows
  let label-size = t.axis-label-size
  let swatch = label-size * 0.8
  let has-names = (left-label != none or right-label != none) and t.legend-position != "none"
  let header-h = if has-names { text-height("Mg", label-size) + t.axis-label-gap * 1.5 } else { 0pt }
  let axis-h = x-axis-extent(t, title: x-label)

  let probe = row-layout(width, height, labels, t, pad-top: header-h, pad-bottom: axis-h)
  let v-size = row-value-size(t, probe.row-h)
  let show-values = show-values and v-size != none
  let v-size = if v-size == none { 5pt } else { v-size }
  let v-gap = t.axis-label-gap / 2
  let v-str(v) = value-str(v, t)

  // The axis is symmetric, so both sides keep the same margin: whatever the
  // side with the longest labels needs beyond its longest bar
  let ticks-probe = linear-x-ticks(nt, 0, max-val, 0pt, 1pt, t)
  let tick-half = tick-label-width(ticks-probe, t) / 2
  let span = width - probe.label-w - probe.gap
  let side-reserve(vals) = {
    let f = calc.max(..vals) / max-val
    if not show-values or f < 0.001 { 0pt } else {
      let need = max-text-width(vals.map(v => v-str(v)), v-size) + v-gap
      calc.max(0pt, (need - span / 2 * (1 - f)) / f)
    }
  }
  let reserve = calc.min(
    calc.max(tick-half, side-reserve(data.left-values), side-reserve(data.right-values)),
    span * 0.2,
  )
  let lay = row-layout(width, height, labels, t, pad-top: header-h, pad-bottom: axis-h, inset-left: reserve, inset-right: reserve)
  let (x0, x1) = (lay.x0, lay.x1)
  let cx = (x0 + x1) / 2
  let half = (x1 - x0) / 2
  let bar-h = lay.row-h * bar-frac
  let left-color = get-color(t, 0)
  let right-color = get-color(t, 1)

  // Mirrored ticks: the same ranks on both sides keep the same labels
  let ticks = ()
  for (k, tk) in linear-x-ticks(nt, 0, max-val, cx, cx + half, t).enumerate() {
    ticks.push((..tk, k: k))
    if tk.value > 0 { ticks.push((x: 2 * cx - tk.x, label: tk.label, value: -tk.value, k: k)) }
  }

  chart-container(width, height, title, t, extra-legend-separation: extra-legend-separation)[
    #box(width: width, height: height)[
      #draw-x-axis(ticks, lay.y1, t, x0: x0, x1: x1, grid-top: lay.y0, title: x-label)
      #place(left + top, line(start: (cx, lay.y0), end: (cx, lay.y1), stroke: t.axis-stroke))
      #lay.labels

      // Side names above their halves, keyed by the bar colour
      #if has-names {
        let name-y = lay.y0 - header-h / 2 - t.axis-label-gap / 4
        let avail = half - t.axis-label-gap - swatch - 4pt
        // One size for both names: the smaller of what each needs
        let sz = calc.min(..(left-label, right-label).filter(l => l != none)
          .map(l => fit-font-size(l, avail, label-size, min: 6pt, weight: "bold")))
        if left-label != none {
          let w = text-width(left-label, sz, weight: "bold")
          place(left + top, dx: cx - t.axis-label-gap - w, dy: name-y,
            box(height: 0pt, align(horizon, text(size: sz, weight: "bold", fill: t.text-color)[#left-label])))
          place(left + top, dx: cx - t.axis-label-gap - w - 4pt - swatch, dy: name-y - swatch / 2,
            rect(width: swatch, height: swatch, fill: left-color, radius: 1pt))
        }
        if right-label != none {
          place(left + top, dx: cx + t.axis-label-gap, dy: name-y - swatch / 2,
            rect(width: swatch, height: swatch, fill: right-color, radius: 1pt))
          place(left + top, dx: cx + t.axis-label-gap + swatch + 4pt, dy: name-y,
            box(height: 0pt, align(horizon, text(size: sz, weight: "bold", fill: t.text-color)[#right-label])))
        }
      }

      #for i in range(n) {
        let y = row-y(lay, i)
        let l-val = left-values.at(i)
        let r-val = right-values.at(i)
        let l-w = l-val / max-val * half
        let r-w = r-val / max-val * half
        place(left + top, dx: cx - l-w, dy: y - bar-h / 2, rect(width: l-w, height: bar-h, fill: left-color, stroke: none))
        place(left + top, dx: cx, dy: y - bar-h / 2, rect(width: r-w, height: bar-h, fill: right-color, stroke: none))
        if show-values {
          let lo-x = lay.label-w + lay.gap / 2
          end-label(v-str(data.left-values.at(i)), cx - l-w, y, "left", v-size, t.text-color,
            lo: lo-x, hi: width, gap: v-gap, mark-len: l-w, inside-fill: contrast-text(left-color, theme: t))
          end-label(v-str(data.right-values.at(i)), cx + r-w, y, "right", v-size, t.text-color,
            lo: lo-x, hi: width, gap: v-gap, mark-len: r-w, inside-fill: contrast-text(right-color, theme: t))
        }
      }
    ]
  ]
  })
}
