// axes.typ - Axis specs, tick selection, label policy and scales

#import "../theme.typ": *
#import "../util.typ": format-number, nice-ticks

// ── Axis specs ──────────────────────────────────────────────────────────────
//
// An axis is described once (`value-axis`, `category-axis`), resolved against
// the room it gets (`resolve-*`), and from then on every consumer — scale, grid,
// tick marks, tick labels, annotations — reads the same resolved record. Nothing
// re-derives ticks, so grid lines, tick marks and labels cannot disagree.

/// A numeric axis over the data range `lo` to `hi`, snapped outward to a nice
/// tick list.
///
/// - lo (int, float): Lowest value to cover
/// - hi (int, float): Highest value to cover
/// - title (none, content): Axis title
/// - color (auto, color): Tick label and title color; `auto` uses the theme text color
/// - inset (length): Room kept free at both ends of the axis, so marks centred on
///   the extreme values (points, bubbles) stay inside the plot. The ticks stay at
///   their values; the axis line moves out by `inset`.
/// - ticks (auto, dictionary): A ready `nice-ticks`-style record (`min`, `max`,
///   `ticks`, `step`, `digits`, optional `labels`) to use instead of picking one
/// - labelled (bool): Draw the tick labels (the axis keeps its marks and grid)
/// - pad (dictionary): `(lo: length, hi: length)`: room the axis must keep beyond
///   the extreme values, for labels set past the end of a bar. The axis range
///   widens (to the next nice tick) until that room is there.
/// - marks (array): `(value, radius)` pairs: marks centred on `value` that reach
///   `radius` to either side (bubbles). The axis range widens (to the next nice
///   tick) until every mark lies inside it, so the axis line, the ticks and the
///   plot extent stay one and the same.
/// -> dictionary
#let value-axis(lo, hi, title: none, color: auto, inset: 0pt, ticks: auto, labelled: true, pad: (:), marks: ()) = (
  kind: "value", lo: lo, hi: hi, title: title, color: color, inset: inset, ticks: ticks, labelled: labelled,
  pad: pad, marks: marks,
)

/// A categorical axis with one label per category.
///
/// `mode: "slots"` gives every category an equal slot and centres its mark in it
/// (bars). `mode: "points"` spreads marks evenly with just enough room at the
/// ends for the end labels (lines). Labels that do not fit flat are all kept
/// as long as that is possible at a legible size: tilted 45 degrees or upright,
/// whichever keeps the larger type (down to the theme's `category-label-min-size`,
/// 6pt by default), and only then thinned (see `resolve-category-axis`). `overflow: "thin"`
/// skips the tilting and shows every k-th flat label; `rotate` and `auto` both tilt.
///
/// - labels (array): Category labels (strings, numbers or content)
/// - title (none, content): Axis title
/// - mode (str): `"slots"` or `"points"`
/// - overflow (auto, str): `"rotate"` or `"thin"`
/// - inset (length): Minimum room at the ends in `"points"` mode (marker radius)
/// - labelled (bool): Draw the tick labels (the axis keeps its marks and grid)
/// -> dictionary
#let category-axis(labels, title: none, mode: "slots", overflow: auto, inset: 0pt, labelled: true) = (
  kind: "category", labels: labels, title: title, mode: mode,
  overflow: overflow, inset: inset, color: auto, labelled: labelled,
)

// ── Text metrics ────────────────────────────────────────────────────────────

// A tick label as drawn. Metrics below measure exactly this.
#let label-text(body, t, fill: auto, size: auto) = text(
  size: if size == auto { t.axis-label-size } else { size }, fill: if fill == auto { t.text-color } else { fill },
)[#body]

// `label` cut to its longest prefix, closed with an ellipsis, for which
// `fits(candidate)` holds. A label that already fits, and any label that is not
// a string, is returned as it is.
#let _clip-label(label, fits) = {
  if type(label) != str or fits(label) { return label }
  let cs = label.clusters()
  let (lo, hi, best) = (1, cs.len() - 1, 1)
  while lo <= hi {
    let mid = calc.floor((lo + hi) / 2)
    if fits(cs.slice(0, mid).join() + "…") { best = mid; lo = mid + 1 } else { hi = mid - 1 }
  }
  cs.slice(0, best).join().trim() + "…"
}

// Full line box (ascender to descender) of a tick label.
#let label-line-height(t) = measure(text(size: t.axis-label-size, top-edge: "ascender", bottom-edge: "descender")[Ag]).height

// Height of a row of horizontal labels: cap height plus room for descenders.
#let label-row-height(t) = measure(text(size: t.axis-label-size)[0]).height + 0.3 * t.axis-label-size

// Width of the widest of `strs` set as tick labels.
#let widest-label(strs, t) = strs.fold(0pt, (m, s) => calc.max(m, measure(label-text(s, t)).width))

// ── Value axes ──────────────────────────────────────────────────────────────

// Tick labels for a tick record, formatted once for the whole axis.
#let _tick-labels(nt, t) = {
  if "labels" in nt { return nt.labels }
  let td = t.at("tick-digits", default: auto)
  let digits = if td != auto { td } else { nt.digits }
  // One notation for the whole axis: once any tick needs SI (10k and up), all use it
  let big = nt.ticks.fold(0, (m, v) => calc.max(m, calc.abs(v))) >= 10000
  let mode = if t.number-format == "auto" and big { "si" } else { t.number-format }
  nt.ticks.map(v => format-number(v, digits: digits, mode: mode, step: nt.step))
}

// Distance needed between neighbouring tick labels so they stay clear of each other
// (`tight`: a little closer, still with a clear gap).
#let _label-need(nt, vertical, t, tight: false) = if vertical {
  measure(text(size: t.axis-label-size)[0]).height * if tight { 2.1 } else { 2.6 }
} else if tight {
  widest-label(_tick-labels(nt, t), t) * 1.2 + 0.7 * t.axis-label-size
} else {
  widest-label(_tick-labels(nt, t), t) * 1.4 + t.axis-label-size
}

// Whether the ticks of `nt` spread over `room` leave their labels clear of each other.
#let _ticks-fit(nt, room, vertical, t, tight: false) = {
  let n = nt.ticks.len()
  n < 2 or room / (n - 1) >= _label-need(nt, vertical, t, tight: tight)
}

// Largest nice tick list (up to theme.tick-count targets) whose labels fit.
#let _pick-ticks(lo, hi, room, vertical, t, most: auto) = {
  let nt = nice-ticks(lo, hi, count: 2)
  for c in range(calc.max(if most == auto { t.tick-count } else { most }, 2), 1, step: -1) {
    nt = nice-ticks(lo, hi, count: c)
    if _ticks-fit(nt, room, vertical, t) { break }
  }
  nt
}

// Ticks for an axis whose marks (bubbles) reach past their values. For each nice step
// (1, 2 or 5 times a power of ten) the range runs from the first tick below the data to
// the first tick above it, then grows by single steps at whichever end a mark is still
// short of room. The steps that hold every mark, with labels that stay clear of each
// other and no more than `2 * tick-count + 3` ticks, compete on the length of the range
// (labels set a little closer than usual count as 25% longer): the shortest wins, and
// among near-equal ranges the one nearest the usual tick count. A range is only ever as
// wide as its marks need, never a step more. `none` when no step manages.
#let _cover-ticks(ax, room, vertical, t) = {
  let (pad-lo, pad-hi) = (ax.pad.at("lo", default: 0pt), ax.pad.at("hi", default: 0pt))
  let (lo, hi) = (ax.lo, ax.hi)
  if lo == hi {
    // A flat extent gets a band around the value, as `nice-ticks` does
    let pad = if lo == 0 { 1 } else { calc.abs(lo) * 0.1 }
    (lo, hi) = (lo - pad, hi + pad)
  }
  let cap = 2 * t.tick-count + 3
  let e0 = calc.floor(calc.log(hi - lo, base: 10))
  let found = ()
  for e in range(e0 - 2, e0 + 2) {
    for m in (1, 2, 5) {
      let step = calc.round(m * calc.pow(10, e), digits: 12)
      let a = calc.round(calc.floor(lo / step + 1e-9) * step, digits: 10)
      let b = calc.round(calc.ceil(hi / step - 1e-9) * step, digits: 10)
      if b == a { b = a + step }
      let ok = false
      for _ in range(2 * cap) {
        let span = b - a
        let (short-lo, short-hi) = (pad-lo - (ax.lo - a) / span * room, pad-hi - (b - ax.hi) / span * room)
        for (v, r) in ax.marks {
          short-lo = calc.max(short-lo, r - (v - a) / span * room)
          short-hi = calc.max(short-hi, r - (b - v) / span * room)
        }
        if short-lo < 0.5pt and short-hi < 0.5pt {
          ok = true
          break
        }
        if short-lo >= 0.5pt { a = calc.round(a - step, digits: 10) }
        if short-hi >= 0.5pt { b = calc.round(b + step, digits: 10) }
        if (b - a) / step > cap { break }
      }
      let n = int(calc.round((b - a) / step)) + 1
      if ok and n >= 2 and n <= cap {
        let nt = nice-ticks(a, b, step: step)
        let plain = nice-ticks(a, b, count: t.tick-count).step == step
        if _ticks-fit(nt, room, vertical, t) { found.push((nt: nt, span: b - a, n: n, plain: plain)) }
        else if n <= t.tick-count + 3 and _ticks-fit(nt, room, vertical, t, tight: true) {
          found.push((nt: nt, span: 1.25 * (b - a), n: n, plain: plain))
        }
      }
    }
  }
  if found.len() == 0 { return none }
  let shortest = found.map(c => c.span).fold(found.first().span, calc.min)
  found.filter(c => c.span <= shortest * 1.02).sorted(key: c => (not c.plain, calc.abs(c.n - t.tick-count))).first().nt
}

/// Resolves a value axis for `extent` of room: picks the tick list (once) and
/// formats its labels.
///
/// - ax (dictionary): From `value-axis`
/// - extent (length): Length of the axis
/// - vertical (bool): Whether the axis runs vertically (labels stack, not side by side)
/// - t (dictionary): Resolved theme
/// -> dictionary
#let resolve-value-axis(ax, extent, vertical, t) = {
  let room = extent - 2 * ax.inset
  let (pad-lo, pad-hi) = (ax.pad.at("lo", default: 0pt), ax.pad.at("hi", default: 0pt))
  // Widens the range by what the ends are short of (a few rounds: the ticks snap
  // outward). Returns the ticks and whether every mark and pad found its room.
  let widen(most) = {
    let nt = _pick-ticks(ax.lo, ax.hi, room, vertical, t, most: most)
    let ok = false
    for _ in range(6) {
      let span = nt.max - nt.min
      let (short-lo, short-hi) = (pad-lo - (ax.lo - nt.min) / span * room, pad-hi - (nt.max - ax.hi) / span * room)
      for (v, r) in ax.marks {
        short-lo = calc.max(short-lo, r - (v - nt.min) / span * room)
        short-hi = calc.max(short-hi, r - (nt.max - v) / span * room)
      }
      if short-lo < 0.5pt and short-hi < 0.5pt {
        ok = true
        break
      }
      nt = _pick-ticks(
        nt.min - calc.max(short-lo, 0pt) / room * span, nt.max + calc.max(short-hi, 0pt) / room * span,
        room, vertical, t, most: most)
    }
    (nt, ok)
  }
  let covered = if ax.ticks == auto and ax.marks.len() > 0 { _cover-ticks(ax, room, vertical, t) }
  let nt = if covered != none { covered } else if ax.ticks == auto {
    // (marks no step could hold fall back to widening the range until they fit)
    let (nt, ok) = widen(auto)
    if ax.marks.len() > 0 {
      for most in (t.tick-count + 2, t.tick-count + 4) {
        let (alt, alt-ok) = widen(most)
        if alt-ok and alt.ticks.len() <= 2 * t.tick-count + 3 and (not ok or alt.max - alt.min < (nt.max - nt.min) * 0.9) {
          (nt, ok) = (alt, alt-ok)
        }
      }
    }
    nt
  } else if ax.ticks.at("thin", default: false) {
    // A fixed tick list (histogram bin edges) shows every k-th tick: the
    // fewest that leaves the labels clear of each other
    let all = ax.ticks.ticks
    let per = room / calc.max(all.len() - 1, 1)
    let k = calc.max(1, calc.ceil(_label-need(ax.ticks, vertical, t) / per))
    (..ax.ticks, ticks: all.enumerate().filter(((i, _)) => calc.rem(i, k) == 0).map(((_, v)) => v))
  } else { ax.ticks }
  (..ax, nt: nt, labels: _tick-labels(nt, t), dlo: nt.min, dhi: nt.max, block: label-row-height(t))
}

/// Resolves two vertical value axes that share one set of grid lines: finds a
/// tick count for which both land on the same number of ticks, so every tick of
/// one axis lines up with a tick of the other. Falls back to independent ticks
/// when no common count exists (`aligned: false`).
///
/// -> array (left axis, right axis)
#let resolve-value-pair(a, b, extent, t) = {
  let tc = calc.max(t.tick-count, 2)
  for c in (..range(tc, 1, step: -1), ..range(tc + 1, tc + 4)) {
    let na = nice-ticks(a.lo, a.hi, count: c)
    let nb = nice-ticks(b.lo, b.hi, count: c)
    if na.ticks.len() == nb.ticks.len() and _ticks-fit(na, extent - 2 * a.inset, true, t) {
      return (
        resolve-value-axis((..a, ticks: na), extent, true, t),
        resolve-value-axis((..b, ticks: nb), extent, true, t),
      )
    }
  }
  (resolve-value-axis(a, extent, true, t), resolve-value-axis(b, extent, true, t))
}

// ── Category axes ───────────────────────────────────────────────────────────

/// Resolves a horizontal category axis over `len`: slot geometry and the label
/// policy. Every label is shown whenever that is physically possible at a legible
/// size, and thins only at the very end:
///
/// 1. flat, at full size, when it fits;
/// 2. otherwise the tilted layout (45 degrees, or upright) that holds every label in
///    the largest type, down to a floor; at equal size the less rotated one;
/// 3. when even the floor does not hold them all, upright at the floor, thinned
///    evenly (first and last always kept).
///
/// The floor is the theme key `category-label-min-size` (6pt unless set; never
/// above the axis label size). `overflow: "thin"` skips the tilted steps and keeps
/// the fewest flat labels that stay clear of each other, measured pair by pair
/// (one long label does not thin the short ones). Tilted labels never take more
/// than `max-block` of height: longer text is cut with an ellipsis.
///
/// Adds `n`, `pitch` (distance between marks), `inset`, `dlo`/`dhi` (index
/// domain), `rotate` (whether tilted), `angle` (0, 45 or 90), `size` (type size
/// of the labels), `skip`, `shown` (indices of the labels drawn), `texts` (the
/// labels as drawn, clipped where needed), `block` (height the label row needs)
/// and `over-left` (how far a tilted first label reaches left of the plot).
#let resolve-category-axis(ax, len, t, max-block: none) = {
  let n = ax.labels.len()
  let size0 = t.axis-label-size
  let width-of(l) = measure(label-text(l, t)).width
  let natural = ax.labels.map(width-of)
  let lh0 = label-line-height(t)
  // A single point has nothing to spread: it takes the middle, like a lone slot
  let slots = ax.mode == "slots" or n == 1
  let pitch-for(inset) = if slots { len / n } else if n > 1 { (len - 2 * inset) / (n - 1) } else { len }
  // Flat end labels are centred on the end marks, so the marks move in by half their width
  let flat-inset = if slots { 0pt } else {
    calc.min(calc.max(ax.inset, calc.max(natural.first(), natural.last()) / 2 + 1pt), len * 0.3)
  }
  let gap = 0.6 * size0
  // Whether every s-th label, set flat, stays clear of its neighbour
  let clear(s) = range(0, n, step: s).windows(2).all(ij => {
    let (a, b) = ij
    (natural.at(a) + natural.at(b)) / 2 + gap <= (b - a) * pitch-for(flat-inset)
  })
  let flat = clear(1)
  let thin-skip = if flat { 1 } else { range(2, n + 1).find(clear) }

  // Tilted labels end at their mark and reach left, not right: only the marker needs room
  let tilt-inset = if slots { 0pt } else { calc.min(ax.inset, len * 0.3) }
  let tilt-pitch = pitch-for(tilt-inset)
  // Fraction of the full size at which tilted labels, `k` line heights apart, fit the pitch
  let floor = calc.min(t.at("category-label-min-size", default: 6pt), size0)
  let fit-at(k) = calc.min(1, tilt-pitch / (k * lh0))
  let (k45, k90) = (1.6, 1.15)
  // Of the layouts that hold every label, the one with the largest type wins; at (nearly)
  // equal size the least rotation does. Only when none fits at the floor are labels thinned.
  let (s45, s90) = (size0 * fit-at(k45), size0 * fit-at(k90))
  let (angle, size, skip) = if flat { (0, size0, 1) }
    else if ax.overflow == "thin" { (0, size0, thin-skip) }
    else if s90 < floor { (90, floor, calc.ceil(k90 * lh0 * (floor / size0) / tilt-pitch)) }
    else if s45 >= floor and s45 >= s90 - 0.05pt { (45, s45, 1) }
    else { (90, s90, 1) }
  let rotate = angle != 0
  let inset = if rotate { tilt-inset } else { flat-inset }
  let pitch = pitch-for(inset)
  let lh = lh0 * (size / size0)
  let width-at(l) = measure(label-text(l, t, size: size)).width
  let wcap = if rotate and max-block != none {
    if angle == 45 { calc.max(max-block / 0.7071 - lh, 3 * lh) } else { calc.max(max-block, 3 * lh) }
  }
  let texts = if wcap == none { ax.labels } else {
    ax.labels.map(l => _clip-label(l, c => width-at(c) <= wcap))
  }
  let ws = if size == size0 and wcap == none { natural } else { texts.map(width-at) }
  // Thinned upright labels are spread evenly with both ends kept; flat ones keep the pairs that were measured
  let shown = if skip == 1 { range(n) }
    else if angle == 90 {
      let m = calc.floor((n - 1) / skip) + 1
      if m >= 2 { range(m).map(j => int(calc.round((n - 1) * j / (m - 1)))) } else { (0,) }
    } else { range(0, n, step: skip) }
  let wshown = shown.map(i => ws.at(i)).fold(0pt, calc.max)
  let first-x = if slots { pitch / 2 } else { inset }
  (
    ..ax, n: n, ws: ws, texts: texts, pitch: pitch, inset: inset, rotate: rotate, angle: angle, size: size,
    skip: skip, shown: shown,
    dlo: if slots { -0.5 } else { 0 }, dhi: if slots { n - 0.5 } else { calc.max(n - 1, 1) },
    block: if angle == 45 { 0.7071 * (wshown + lh) } else if angle == 90 { wshown + 0.2 * lh } else { label-row-height(t) },
    over-left: if angle == 45 { calc.max(0pt, 0.7071 * ws.first() + 0.354 * lh - first-x) }
      else if angle == 90 { calc.max(0pt, lh / 2 - first-x) } else { 0pt },
  )
}

// ── Scales ──────────────────────────────────────────────────────────────────

/// Linear scale of a resolved axis laid over `len` starting at `start`.
/// Returns `(pos, dom)`: `pos(v)` maps a value (or category index) to a length
/// along the axis; `dom` is the `(lo, hi)` the full length spans, for overlays
/// that work in data coordinates. With `flip`, larger values sit nearer `start`'s
/// far end (vertical value axes, where values grow upward).
#let axis-scale(ax, start, len, flip: false) = {
  let inner = len - 2 * ax.inset
  let span = if ax.dhi == ax.dlo { 1 } else { ax.dhi - ax.dlo }
  let pos = v => if flip {
    start + len - ax.inset - (v - ax.dlo) / span * inner
  } else {
    start + ax.inset + (v - ax.dlo) / span * inner
  }
  let e = ax.inset / inner * span
  (pos: pos, dom: (lo: ax.dlo - e, hi: ax.dhi + e))
}

/// Largest font size, at most `size`, at which every label in `strs` fits a slot
/// `slot` wide with a little air between neighbours; `none` when they would need
/// to go below `min-size`. Direct labels (value labels above bars) use this to
/// shrink, then drop, instead of overlapping.
#let fit-label-size(strs, slot, size, min-size: 5.5pt) = {
  let w = strs.fold(0pt, (m, s) => calc.max(m, measure(text(size: size)[#s]).width))
  if w <= 0pt { return size }
  let fitted = calc.min(size, size * ((slot * 0.94) / w))
  // A theme whose labels are small already keeps them down to 80% of that size
  if fitted >= calc.min(min-size, size * 0.8) { fitted } else { none }
}

/// Font size, at most `size`, for labels in rows `pitch` apart so neighbouring
/// rows never touch; `none` when that would go below `min-size`.
#let fit-row-size(pitch, size, min-size: 5.5pt) = {
  let fitted = calc.min(size, pitch * 0.9)
  if fitted >= calc.min(min-size, size * 0.8) { fitted } else { none }
}

/// Compact text for a data value shown beside a mark: values from 10 000 up
/// are abbreviated the way the axis ticks are (`15k`, `1.5M`); smaller values
/// are shown as given.
#let value-text(v, t) = {
  if (type(v) == int or type(v) == float) and calc.abs(v) >= 10000 and t.number-format == "auto" {
    format-number(v, digits: 1, mode: "auto")
  } else { v }
}
/// A data value in as few characters as `sig` significant digits allow, for labels
/// that are short of room: `12.3456` becomes `12.3` (3 digits) or `12` (2), `85200`
/// becomes `85.2k` or `85k`, `0.012345` becomes `0.0123` or `0.012`. Whole numbers
/// below 10 000 are kept whole, whatever `sig` says. Values that are not numbers
/// are returned as they are.
///
/// - v (int, float, any): The value
/// - t (dictionary): Resolved theme
/// - sig (int): Significant digits to keep
/// -> str, any
#let compact-text(v, t, sig: 3) = {
  if type(v) != int and type(v) != float { return v }
  let a = calc.abs(v)
  if a == 0 { return "0" }
  let (scale, suffix) = if t.number-format != "auto" and t.number-format != "si" { (1, "") }
    else if a >= 1000000000 { (1000000000, "B") }
    else if a >= 1000000 { (1000000, "M") }
    else if a >= 10000 { (1000, "k") }
    else { (1, "") }
  let x = v / scale
  let digits = calc.max(0, sig - 1 - int(calc.floor(calc.log(calc.abs(x), base: 10) + 1e-9)))
  str(calc.round(x, digits: digits)) + suffix
}

// ── For charts that lay out their own rows ──────────────────────────────────
//
// The row-oriented charts (dumbbell, diverging, gantt, bullet, ...) draw their
// own axes with the helpers below; cartesian charts use `cartesian-frame` instead.

// Height of a row of x tick labels; rotated (45 degrees) labels take their
// widest label's diagonal.
#let measure-x-tick-height(values, theme, rotated: false) = {
  if not rotated { return measure(text(size: theme.axis-label-size)[0]).height }
  values.fold(0pt, (m, v) => calc.max(m, measure(text(size: theme.axis-label-size)[#v]).width * calc.sqrt(2) / 2))
}

// Axis titles: the x title below the tick labels (centred on `x-center`), the y
// title rotated left of the tick labels (centred on `y-center`). `origin-x` and
// `origin-y` are the axis corner; `y-tick-width` and `x-tick-height` the measured
// tick label extents.
#let draw-axis-titles(
  x-label, y-label, x-center, y-center, theme,
  origin-x: none, origin-y: none, y-tick-width: 0pt, x-tick-height: 0pt,
) = {
  let gap = theme.axis-label-gap
  let title-gap = theme.at("axis-title-gap", default: gap)
  let title(body) = text(size: theme.axis-title-size, fill: theme.text-color)[#body]
  if x-label != none {
    let lbl = title(x-label)
    let tick-h = if x-tick-height != 0pt { x-tick-height } else { measure(text(size: theme.axis-label-size)[0]).height }
    let ox-y = if origin-y != none { origin-y } else { y-center * 2 }
    place(left + top, dx: x-center - measure(lbl).width / 2, dy: ox-y + gap + tick-h + title-gap, lbl)
  }
  if y-label != none {
    // The rotated box is placed by its centre: measure() of a rotated box is the unrotated size
    let lbl = title(y-label)
    let (tw, th) = (measure(lbl).width, measure(lbl).height)
    let ox-x = if origin-x != none { origin-x } else { theme.axis-padding-left }
    let strip-x = ox-x - gap / 2 - y-tick-width - title-gap - th
    place(left + top, dx: strip-x + th / 2 - tw / 2, dy: y-center - th / 2, rotate(-90deg, lbl))
  }
}
