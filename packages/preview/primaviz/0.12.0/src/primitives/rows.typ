// rows.typ - Row-oriented layout: label column, row geometry, value labels and
// a horizontal value axis.
//
// Horizontal charts (dumbbell, diverging, gantt, bullet, and the horizontal
// bar / lollipop charts) all need the same four things:
//
//   1. a column of row labels whose width is *measured*, not guessed;
//   2. an even row grid beside it;
//   3. value labels that sit beyond the marks without running into the row
//      labels or off the plot;
//   4. a horizontal value axis (ticks, optional grid, title) that looks like
//      the cartesian charts' x axis and thins its labels instead of letting
//      them collide.
//
// Everything here works in the local coordinates of a `box(width, height)`
// whose top-left is (0, 0), like the rest of the chart code. Functions that
// measure text must be called inside `context`.

#import "../theme.typ": *
#import "../util.typ": nice-ticks, format-number
#import "fonts.typ": text-width, text-height, max-text-width, fit-font-size, label-stride, thin-indices, fit-pitch, pin, place-centered
#import "axes.typ": draw-axis-titles, measure-x-tick-height

// ---------------------------------------------------------------------------
// Value formatting and label reservation
// ---------------------------------------------------------------------------

/// Formats a data value for a label: integers stay integers, small floats
/// keep enough decimals to stay distinct (0.0042, not 0), large floats do not
/// trail noise. Honours the theme's `number-format`. Content passes through.
///
/// - v (int, float, content, str): Value
/// - theme (dictionary): Resolved theme
/// -> str, content
#let value-str(v, theme) = {
  if type(v) != int and type(v) != float { return v }
  let a = calc.abs(v)
  let digits = if v == calc.round(v) { 0 } else if a >= 100 { 1 } else if a >= 1 { 2 } else {
    calc.min(6, int(calc.ceil(-calc.log(a, base: 10))) + 1)
  }
  format-number(v, digits: digits, mode: theme.number-format)
}

/// Room to keep beside the two ends of a plot so that labels sitting just
/// beyond the outermost marks fit, without reserving more than needed.
///
/// A mark at fraction `f` of the plot (0 = at that end) has `f × plot` of
/// free room beyond it already; only the shortfall is reserved. Because each
/// reserve shrinks the plot the other end's room depends on, the two are
/// solved together.
///
/// - span (length): Width available for plot plus both reserves
/// - f-lo (float): How far the lowest mark sits from the low end, 0 to 1 of the plot
/// - need-lo (length): Room the label needs beyond that mark (label + gap + marker radius)
/// - f-hi (float): How far the highest mark sits from the high end, 0 to 1
/// - need-hi (length): Room the label needs beyond that mark
/// - floor (length): Reserve at least this much on either end
/// - cap (float): Reserve at most this fraction of `span` on either end
/// -> dictionary with `lo` and `hi` lengths
#let end-reserves(span, f-lo, need-lo, f-hi, need-hi, floor: 0pt, cap: 0.3) = {
  let lo = floor
  let hi = floor
  for _ in range(4) {
    lo = if f-lo >= 0.999 { floor } else {
      calc.max(floor, (need-lo - f-lo * (span - hi)) / (1 - f-lo))
    }
    hi = if f-hi >= 0.999 { floor } else {
      calc.max(floor, (need-hi - f-hi * (span - lo)) / (1 - f-hi))
    }
    lo = calc.min(lo, span * cap)
    hi = calc.min(hi, span * cap)
  }
  (lo: lo, hi: hi)
}

/// Places a value label beyond the end of a mark, centred on the row.
///
/// The label goes on the requested `side` of `x`. If it would leave
/// `[lo, hi]` it moves inside the mark when the mark is long enough (using
/// `inside-fill` for contrast), and is otherwise nudged back in bounds, so it
/// never leaves the plot.
///
/// - body (content, str): Label
/// - x (length): End of the mark
/// - y (length): Row centre
/// - side (str): `"right"` or `"left"`: which way from `x` the label sits
/// - size (length): Font size
/// - fill (color): Label colour outside the mark
/// - lo (length): Lowest x the label may reach
/// - hi (length): Highest x the label may reach
/// - gap (length): Space between mark and label
/// - mark-len (none, length): Length of the mark, for the inside fallback
/// - inside-fill (none, color): Label colour inside the mark
/// -> content
#let end-label(body, x, y, side, size, fill, lo: 0pt, hi: 1000pt, gap: 3pt, mark-len: none, inside-fill: none) = {
  let w = text-width(body, size)
  let out-x = if side == "right" { x + gap } else { x - gap - w }
  let fits = out-x >= lo and out-x + w <= hi
  let (lx, color) = if fits { (out-x, fill) } else if mark-len != none and inside-fill != none and mark-len >= w + 2 * gap {
    (if side == "right" { x - gap - w } else { x + gap }, inside-fill)
  } else {
    (calc.max(lo, calc.min(hi - w, out-x)), fill)
  }
  place(left + top, dx: lx, dy: y, pin(text(size: size, fill: color)[#body]))
}

// ---------------------------------------------------------------------------
// Row layout
// ---------------------------------------------------------------------------

/// Lays out a column of row labels beside an even grid of rows.
///
/// The label column is as wide as the widest label *measured* at the label
/// size, never wider than `label-frac` of the chart. A label that is wider
/// shrinks (down to 75% of its size, never under 6pt), then wraps.
///
/// Dense rows follow one policy, in this order, so a label is never dropped
/// while a smaller one would do:
///
/// 1. the row pitch is the caller's (`resolve-size(rows: true)` grows the
///    natural height with the row count, so `height: auto` stays legible);
/// 2. the label size shrinks with the pitch (one line of text per row, room
///    for descenders), down to `min-label-size`;
/// 3. only when even that does not fit are labels thinned: spread evenly
///    over all rows, the first and the last always shown (`thin-indices`).
///
/// Returns a dictionary:
/// - `labels`: content to place at the origin of the chart box, the row labels
///   right-aligned against the column, each centred on its row
/// - `label-w`, `label-size`: what was resolved
/// - `label-stride`: 1 when every row is labelled, else the least number of rows
///   between two labels
/// - `shown`: indices of the rows that are labelled
/// - `x0`, `x1`, `plot-w`: horizontal extent of the plot area (after the label
///   column, the gap and the insets)
/// - `y0`, `y1`, `row-h`: vertical extent of the rows and the height of one row;
///   row `i` is centred on `y0 + (i + 0.5) × row-h` (see `row-y`)
///
/// - width (length): Chart box width
/// - height (length): Chart box height
/// - labels (array): Row labels
/// - theme (dictionary): Resolved theme
/// - label-frac (float): Widest the label column may get, as a fraction of `width`
/// - label-size (auto, length): Preferred label size (`auto` is the theme's `axis-label-size`)
/// - label-weight (str): Label font weight
/// - gap (auto, length): Space between the label column and the plot (`auto` is `axis-label-gap`)
/// - inset-left (length): Extra room between the gap and the plot (value labels, marker radius)
/// - inset-right (length): Room kept at the right of the plot
/// - pad-top (length): Band reserved above the rows (headers)
/// - pad-bottom (length): Band reserved below the rows (axis)
/// - pitch (auto, length): Fixed row height; `auto` shares `height - pad-top - pad-bottom` among the rows
/// - label-fill (auto, color): Label colour (`auto` is the theme's `text-color`)
/// - min-label-size (length): Smallest label size before labels are thinned out
/// -> dictionary
#let row-layout(
  width,
  height,
  labels,
  theme,
  label-frac: 0.35,
  label-size: auto,
  label-weight: "regular",
  gap: auto,
  inset-left: 0pt,
  inset-right: 0pt,
  pad-top: 0pt,
  pad-bottom: 0pt,
  pitch: auto,
  label-fill: auto,
  min-label-size: 5pt,
) = {
  let n = labels.len()
  let gap = if gap == auto { theme.axis-label-gap } else { gap }
  let base = if label-size == auto { theme.axis-label-size } else { label-size }
  let fill = if label-fill == auto { theme.text-color } else { label-fill }
  let row-h = if pitch == auto { (height - pad-top - pad-bottom) / calc.max(n, 1) } else { pitch }

  // A label has to fit its row: shrink with the pitch, thin out past the floor
  let floor-size = min-label-size
  let fit = fit-pitch(row-h, base, floor: floor-size)
  let size = fit.size
  let stride = fit.stride
  let kept = thin-indices(n, stride)

  // Widest shown label, measured; shrink, then wrap
  let shown = labels.enumerate().filter(((i, _)) => i in kept).map(((_, l)) => l)
  let cap = width * label-frac
  let widest = if shown.len() > 0 { shown.fold(shown.first(), (a, b) => if text-width(b, size, weight: label-weight) > text-width(a, size, weight: label-weight) { b } else { a }) } else { "" }
  let w = text-width(widest, size, weight: label-weight)
  if w > cap and cap > 0pt {
    size = fit-font-size(widest, cap, size, min: calc.max(6pt, size * 0.75), weight: label-weight)
    w = text-width(widest, size, weight: label-weight)
  }
  let wraps = w > cap and cap > 0pt
  let label-w = if wraps { cap } else { w }
  if wraps {
    // Two lines have to fit the row too
    size = calc.max(floor-size, calc.min(size, row-h * 0.9 / 2.3))
  }

  let x0 = label-w + gap + inset-left
  let x1 = width - inset-right
  let y0 = pad-top
  let y1 = y0 + n * row-h

  let drawn = for (i, l) in labels.enumerate() {
    if i not in kept { continue }
    place-centered(0pt, y0 + (i + 0.5) * row-h,
      text(size: size, weight: label-weight, fill: fill)[#l], width: label-w, align: right)
  }

  (
    labels: drawn,
    label-w: label-w,
    label-size: size,
    label-stride: stride,
    shown: kept,
    gap: gap,
    x0: x0,
    x1: x1,
    plot-w: x1 - x0,
    y0: y0,
    y1: y1,
    row-h: row-h,
  )
}

/// Vertical centre of row `i` in a layout from `row-layout`.
///
/// - lay (dictionary): Layout from `row-layout`
/// - i (int): Row index
/// -> length
#let row-y(lay, i) = lay.y0 + (i + 0.5) * lay.row-h

/// Size for value labels written beside marks in rows `row-h` apart: the
/// theme's value size, shrunk to the row (digits have no descenders, so a row
/// may be as tall as the size), but never under `floor`, the same floor the
/// row labels use. `none` when the rows are so tight that even `floor` digits
/// would touch (the chart then leaves the values out).
///
/// - theme (dictionary): Resolved theme
/// - row-h (length): Distance between rows
/// - floor (length): Smallest size worth printing
/// -> none, length
#let row-value-size(theme, row-h, floor: 5pt) = {
  if row-h < floor * 0.75 { none } else { calc.max(floor, calc.min(theme.value-label-size, row-h)) }
}

// ---------------------------------------------------------------------------
// Horizontal value axis
// ---------------------------------------------------------------------------

/// Height an x axis occupies below its baseline: tick labels, and the title
/// when there is one. Uses the same offsets as the cartesian charts (labels at
/// `label-offset`, title at `axis-label-gap + tick-h + axis-title-gap`), so
/// charts reserving this and drawing with `draw-x-axis` line up with them.
///
/// - theme (dictionary): Resolved theme
/// - title (none, content): Axis title
/// - marks (bool): Whether tick marks are drawn (pushes the labels down)
/// -> length
#let x-axis-extent(theme, title: none, marks: false) = {
  let tick-h = measure-x-tick-height((), theme)
  let off = if marks { calc.max(theme.label-offset, theme.tick-length + 2pt) } else { theme.label-offset }
  if title == none { off + tick-h } else {
    let title-gap = theme.at("axis-title-gap", default: theme.axis-label-gap)
    theme.axis-label-gap + tick-h + title-gap + measure(text(size: theme.axis-title-size)[#title]).height
  }
}

/// Tick specifications for a linear x axis spanning `lo` to `hi` over
/// `x0` to `x1`: the nice ticks that fall inside the range, with formatted
/// labels. Feed the result to `draw-x-axis`.
///
/// - nt (dictionary): Result of `nice-ticks` for the axis
/// - lo (int, float): Value at `x0`
/// - hi (int, float): Value at `x1`
/// - x0 (length): Left end of the axis
/// - x1 (length): Right end of the axis
/// - theme (dictionary): Resolved theme
/// -> array of dictionaries with `x`, `label` and `value`
#let linear-x-ticks(nt, lo, hi, x0, x1, theme) = {
  let td = theme.at("tick-digits", default: auto)
  let digits = if td != auto { td } else { nt.digits }
  let span = if hi == lo { 1 } else { hi - lo }
  nt.ticks
    .filter(v => v >= lo - 1e-9 * span and v <= hi + 1e-9 * span)
    .map(v => (
      x: x0 + (v - lo) / span * (x1 - x0),
      label: format-number(v, digits: digits, mode: theme.number-format, step: nt.step),
      value: v,
    ))
}

/// Widest tick label, measured: charts reserve half of it beside the axis ends.
///
/// - ticks (array): Ticks from `linear-x-ticks`
/// - theme (dictionary): Resolved theme
/// -> length
#let tick-label-width(ticks, theme) = max-text-width(ticks.map(tk => tk.label), theme.axis-label-size)

/// Draws a horizontal value axis at `y`: optional grid, baseline, tick marks,
/// tick labels and title.
///
/// Labels are centred under their ticks and thinned (never rotated) when they
/// would collide: every Nth tick is labelled, counted from the first tick or,
/// when ticks carry a `k`, by that rank, so a mirrored axis keeps the same
/// labels on both sides.
///
/// - ticks (array): Dictionaries with `x` and `label` (and optionally `k`)
/// - y (length): Baseline
/// - theme (dictionary): Resolved theme
/// - x0 (auto, length): Left end of the baseline (`auto` is the leftmost tick)
/// - x1 (auto, length): Right end of the baseline (`auto` is the rightmost tick)
/// - grid-top (none, length): When set, and the theme shows a grid, vertical
///   grid lines are drawn from here down to the baseline
/// - axis-line (bool): Draw the baseline
/// - marks (bool): Draw small tick marks under the baseline
/// - title (none, content): Axis title, drawn at the cartesian charts' offset
/// - min-gap (length): Clear space wanted between neighbouring labels
/// -> content
#let draw-x-axis(
  ticks,
  y,
  theme,
  x0: auto,
  x1: auto,
  grid-top: none,
  axis-line: true,
  marks: false,
  title: none,
  min-gap: 6pt,
) = {
  if ticks.len() == 0 and title == none { return }
  let ticks = ticks.sorted(key: tk => tk.x)
  let xs = ticks.map(tk => tk.x)
  let x0 = if x0 == auto { xs.first() } else { x0 }
  let x1 = if x1 == auto { xs.last() } else { x1 }
  let size = theme.axis-label-size

  if theme.show-grid and grid-top != none {
    for tk in ticks {
      place(left + top, line(start: (tk.x, grid-top), end: (tk.x, y), stroke: theme.grid-stroke))
    }
  }
  if axis-line {
    place(left + top, line(start: (x0, y), end: (x1, y), stroke: theme.axis-stroke))
  }
  if marks {
    for tk in ticks {
      place(left + top, line(start: (tk.x, y), end: (tk.x, y + theme.tick-length), stroke: theme.axis-stroke))
    }
  }

  // Thin the labels to the tightest tick spacing, measured
  let wmax = max-text-width(ticks.map(tk => tk.label), size)
  let pitch = if xs.len() > 1 {
    xs.slice(1).zip(xs.slice(0, -1)).map(((a, b)) => a - b).fold(1000000pt, calc.min)
  } else { 1000000pt }
  let stride = label-stride(wmax, pitch, gap: min-gap)
  let off = if marks { calc.max(theme.label-offset, theme.tick-length + 2pt) } else { theme.label-offset }
  for (i, tk) in ticks.enumerate() {
    let rank = tk.at("k", default: i)
    if calc.rem(rank, stride) != 0 { continue }
    let w = text-width(tk.label, size)
    place(left + top, dx: tk.x - w / 2, dy: y + off,
      text(size: size, fill: theme.text-color)[#tk.label])
  }

  if title != none {
    draw-axis-titles(title, none, (x0 + x1) / 2, 0pt, theme,
      origin-x: x0, origin-y: y, x-tick-height: measure-x-tick-height((), theme))
  }
}
