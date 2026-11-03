// fonts.typ - Font fitting, label placement, and deconfliction utilities

/// Checks whether a text label fits inside a given rectangular area.
///
/// Uses a heuristic based on character width ratio to estimate text width.
///
/// - available-width (length): Width of the container
/// - available-height (length): Height of the container
/// - text-size (length): Font size of the label
/// - text-len (int): Number of characters in the label
/// -> bool
#let label-fits-inside(available-width, available-height, text-size, text-len) = {
  let estimated-width = text-size * 0.6 * text-len
  let estimated-height = text-size * 1.2
  estimated-width <= available-width and estimated-height <= available-height
}

/// Largest font size, at or below `base-size`, whose label fits `available-width`.
///
/// Inverts the width heuristic `label-fits-inside` uses, so a label sized by
/// this function is one `label-fits-inside` accepts. Results are clamped to
/// `min-size` — a label that cannot fit stays readable rather than fitting.
///
/// - available-width (length): Width the label has to fit into
/// - base-size (length): Preferred/maximum font size
/// - text-len (int): Number of characters in the label
/// - min-size (length): Floor font size
/// -> length
#let font-to-fit-width(available-width, base-size, text-len, min-size: 4pt) = {
  if text-len <= 0 { return base-size }
  calc.max(min-size, calc.min(base-size, available-width / (0.6 * text-len)))
}

/// Returns a skip factor N so that showing every Nth label maintains min-spacing.
///
/// - count (int): Total number of labels
/// - available-length (length): Total available length for all labels
/// - min-spacing (length): Minimum spacing between label centers
/// -> int
#let density-skip(count, available-length, min-spacing: 12pt) = {
  if count <= 0 { return 1 }
  let per-label = available-length / count
  if per-label >= min-spacing { 1 } else { calc.ceil(min-spacing / per-label) }
}

/// Computes a font size that fits within the available space.
///
/// Returns `min(base-size, max(min-size, available * ratio))`.
///
/// - available (length): Available space (width or height)
/// - base-size (length): Preferred/maximum font size
/// - min-size (length): Floor font size
/// - ratio (float): Fraction of available space to use
/// -> length
#let font-for-space(available, base-size, min-size: 4pt, ratio: 0.6) = {
  calc.min(base-size, calc.max(min-size, available * ratio))
}

/// Tries shrinking a label font from `base-size` down to `shrink-min` until it fits.
///
/// Returns `(fits: bool, size: length)`.
///
/// - available-w (length): Width of the container
/// - available-h (length): Height of the container
/// - base-size (length): Starting (preferred) font size
/// - text-len (int): Number of characters in the label
/// - shrink-min (length): Minimum font size to try before giving up
/// -> dictionary
#let try-fit-label(available-w, available-h, base-size, text-len, shrink-min: 5pt) = {
  let steps = calc.max(1, int((base-size - shrink-min) / 1pt) + 1)
  let result = (fits: false, size: base-size)
  for i in range(steps) {
    let sz = base-size - i * 1pt
    if sz < shrink-min { break }
    if label-fits-inside(available-w, available-h, sz, text-len) {
      result = (fits: true, size: sz)
      break
    }
  }
  result
}

/// Places a label near a Cartesian point with quadrant-aware alignment.
///
/// Clamps the label position to stay within the given bounds rectangle.
/// Optionally draws a leader line from the original point to the displaced label.
///
/// - x (length): Original x position
/// - y (length): Original y position
/// - body (content): Label content to place
/// - bounds (dictionary): Dict with `left`, `right`, `top`, `bottom` keys
/// - box-width (length): Width of the label box
/// - box-height (length): Height of the label box
/// - offset-y (length): Vertical offset from the point (negative = above)
/// - leader (bool): Whether to draw a leader line
/// - leader-stroke (stroke): Stroke style for the leader line
/// -> content
#let place-cartesian-label(x, y, body, bounds, box-width: 40pt, box-height: 12pt, offset-y: -12pt, leader: false, leader-stroke: 0.5pt + gray) = {
  // Determine quadrant-aware offset: push label away from center
  let cx = (bounds.left + bounds.right) / 2
  let cy = (bounds.top + bounds.bottom) / 2

  let offset-x = if x >= cx { 8pt } else { -8pt - box-width }

  // Compute displaced position
  let lx = x + offset-x
  let ly = y + offset-y

  // Clamp to bounds
  let lx = calc.max(bounds.left, calc.min(bounds.right - box-width, lx))
  let ly = calc.max(bounds.top, calc.min(bounds.bottom - box-height, ly))

  // Leader line from original point to label anchor
  if leader {
    place(left + top,
      line(start: (x, y), end: (lx + box-width / 2, ly + box-height / 2), stroke: leader-stroke))
  }

  // Label
  place(left + top, dx: lx, dy: ly,
    box(width: box-width, align(center, body)))
}

/// Pins a label to its placement point by vertical alignment, independent of
/// the surrounding document's font size.
///
/// `place(dy: y, pin(body))` centres `body` on `y`; with `align: bottom` it
/// sits on `y`, with `align: top` it hangs from it. Prefer this over
/// `move(dy: -0.5em, ...)`: an `em` there resolves against the document's
/// text size, not the label's, so labels drift when the document font changes.
///
/// - body (content): Label content
/// - width (auto, length): Box width (for horizontal alignment)
/// - align (alignment): Alignment within the zero-height box
/// -> content
#let pin(body, width: auto, align: horizon) = box(width: width, height: 0pt, std.align(align, body))

// ---------------------------------------------------------------------------
// Measured label helpers
//
// The functions above estimate text width from a character count (0.6 em per
// character). That is fine for coarse decisions but wrong for the cases that
// matter: bold text, wide capitals, CJK, math. The helpers below measure the
// real glyph run, so a label that "fits" does fit. They call `measure`, so
// they must run inside `context` (every chart body already does).
// ---------------------------------------------------------------------------

/// Measured width of `body` set at `size`.
///
/// - body (content, str): Label
/// - size (length): Font size
/// - weight (str, int): Font weight
/// -> length
#let text-width(body, size, weight: "regular") = measure(text(size: size, weight: weight)[#body]).width

/// Measured height of `body` set at `size` (one line, cap-height to baseline
/// plus any descender the content carries).
///
/// - body (content, str): Label
/// - size (length): Font size
/// - weight (str, int): Font weight
/// -> length
#let text-height(body, size, weight: "regular") = measure(text(size: size, weight: weight)[#body]).height

/// Widest of several labels, measured.
///
/// - labels (array): Labels
/// - size (length): Font size
/// - weight (str, int): Font weight
/// -> length
#let max-text-width(labels, size, weight: "regular") = {
  labels.fold(0pt, (acc, l) => calc.max(acc, text-width(l, size, weight: weight)))
}

/// Largest font size, between `min` and `base`, at which `body` fits in
/// `avail` (measured, not estimated). Glyph advances scale with the size, so
/// one measurement at `base` is enough. When even `min` is too big the result
/// is `min`: the caller decides whether to wrap, thin out or drop the label.
///
/// - body (content, str): Label
/// - avail (length): Width the label has to fit into
/// - base (length): Preferred size
/// - min (length): Floor size
/// - weight (str, int): Font weight
/// -> length
#let fit-font-size(body, avail, base, min: 5pt, weight: "regular") = {
  let w = text-width(body, base, weight: weight)
  if w <= avail or w <= 0pt { base } else { calc.max(min, base * (avail / w)) }
}

/// Every Nth label is enough when labels of width `label-w` are spaced
/// `pitch` apart: returns that N (at least 1). This is the first resort when
/// labels collide: thin them out, do not rotate them.
///
/// - label-w (length): Widest label
/// - pitch (length): Distance between neighbouring label centres
/// - gap (length): Clear space wanted between neighbouring labels
/// -> int
#let label-stride(label-w, pitch, gap: 4pt) = {
  if pitch <= 0pt { return 1 }
  calc.max(1, int(calc.ceil((label-w + gap) / pitch - 1e-9)))
}

/// `c` of `n` positions, spread evenly over the whole run, always including
/// the first and the last (when `c` is 1, only the first). Neighbours are at
/// least `floor((n - 1) / (c - 1))` positions apart.
///
/// - n (int): Number of positions
/// - c (int): How many to keep
/// -> array of ints, ascending
#let spread-indices(n, c) = {
  if n <= 0 or c <= 0 { return () }
  if c >= n { return array.range(n) }
  if c == 1 { return (0,) }
  array.range(c).map(j => int(calc.round(j * (n - 1) / (c - 1))))
}

/// Which of `n` evenly spaced positions to label when labels have to be
/// at least `k` positions apart. Unlike "every k-th from the first", the
/// labelled positions are spread evenly over the whole run and always include
/// the first and the last (never closer than `k` to each other); when not even
/// two fit, only the first is kept.
///
/// - n (int): Number of positions
/// - k (int): Minimum distance, in positions, between labelled ones
/// -> array of ints, ascending
#let thin-indices(n, k) = {
  if n <= 0 { return () }
  if k <= 1 or n == 1 { return array.range(n) }
  spread-indices(n, calc.quo(n - 1, k) + 1)
}

/// Label size for positions `pitch` apart (rows, columns): the largest size
/// up to `base` at which neighbouring labels do not touch (`line-k` is the
/// line height the label needs, in em; 1.0 leaves room for descenders). The
/// size shrinks to `floor` before anything is dropped; only if even `floor`
/// does not fit does `stride` rise above 1, to the number of positions
/// between labels (feed it to `thin-indices`).
///
/// - pitch (length): Distance between neighbouring label centres
/// - base (length): Preferred size
/// - floor (length): Smallest size worth printing
/// - line-k (float): Line height needed, in em
/// -> dictionary with `size` and `stride`
#let fit-pitch(pitch, base, floor: 5pt, line-k: 1.0) = {
  let s = calc.min(base, pitch / line-k)
  if s >= floor { (size: s, stride: 1) } else {
    (size: floor, stride: calc.max(2, int(calc.ceil(floor * line-k / pitch - 1e-9))))
  }
}

/// Lays labels out along one axis (a column of names, a row of them, the ends
/// of lines, an arc read as a line) so that none overlaps another. The one
/// spreader every chart uses.
///
/// Each label is wanted at `wants.at(i)` (its centre). The result moves the
/// labels as little as it can (least squares), never reorders them (equal
/// wishes keep their input order) and keeps neighbours `gap` apart, clear
/// space between their extents. Labels that collide form a cluster that is
/// centred on where its members wanted to be, then clamped into `lo..hi`.
/// A solution inside `lo..hi` is found whenever one exists.
///
/// When the labels cannot all fit, in this order: the `gap` is squeezed (down
/// to `min-gap`, 0 by default: extents touch); then labels are left out,
/// those of the lowest `priority` first, and among equals the one whose
/// removal leaves the smallest hole, the first and last last, so the rest
/// are thinned evenly. The labels that remain never overlap. A label left
/// out has `none` for its place: the caller does not draw it.
///
/// All positions are lengths along the axis (an angle can be passed as
/// points, one point per degree). `lo` and `hi` bound the labels' extents
/// (their edges), which are their centres when `sizes` is 0.
///
/// - wants (array): Wanted centre of each label, in any order
/// - sizes (length, array): Extent of the label along the axis; one length for all or one each
/// - gap (length): Clear space wanted between neighbours
/// - min-gap (length): Least clear space accepted before labels are left out; negative
///   when `sizes` carry air around the text, which crowded labels may then use
/// - lo (none, length): Start of the room; none: unbounded
/// - hi (none, length): End of the room; none: unbounded
/// - priority (none, array): Higher survives when labels must be left out
/// - need (none, function): `(a, b) => length`, the least distance between the centres of
///   neighbours `a` then `b` (indices into `wants`); replaces `sizes` and `gap` for spacing
/// -> array, in the order of `wants`, of lengths (centres) or `none` (left out)
#let spread-labels(wants, sizes: 0pt, gap: 0pt, min-gap: 0pt, lo: none, hi: none, priority: none, need: none) = {
  let n = wants.len()
  if n == 0 { return () }
  let size-of(i) = if type(sizes) == array { sizes.at(i) } else { sizes }
  let dist(g, a, b) = if need != none { need(a, b) } else { (size-of(a) + size-of(b)) / 2 + g }
  // What `ls` take up with no space between neighbours (and the space each gap adds)
  let base(ls) = {
    let t = (size-of(ls.first()) + size-of(ls.last())) / 2
    for k in range(1, ls.len()) { t += dist(0pt, ls.at(k - 1), ls.at(k)) }
    t
  }
  let live = range(n).sorted(key: i => (wants.at(i), i))
  let g = gap
  if lo != none and hi != none {
    let room = hi - lo + 0.01pt
    while live.len() > 1 and base(live) + (live.len() - 1) * min-gap > room {
      let m = live.len()
      let key(j) = {
        let end = j == 0 or j == m - 1
        (if priority == none { 0 } else { priority.at(live.at(j)) }, if end { 1 } else { 0 },
          if end { 0pt } else { wants.at(live.at(j + 1)) - wants.at(live.at(j - 1)) }, -live.at(j))
      }
      let _ = live.remove(range(m).sorted(key: key).first())
    }
    if live.len() > 1 and need == none {
      g = calc.max(min-gap, calc.min(gap, (room - base(live)) / (live.len() - 1)))
    }
  }
  // Labels stacked as tightly as allowed, `offs` from the first: the nearest layout is the
  // nearest non-decreasing fit (pool adjacent violators) to the wishes less those offsets
  let offs = (0pt,)
  for k in range(1, live.len()) { offs.push(offs.last() + dist(g, live.at(k - 1), live.at(k))) }
  let blocks = ()
  for (k, i) in live.enumerate() {
    blocks.push((wants.at(i) - offs.at(k), 1))
    while blocks.len() > 1 {
      let (a, b) = (blocks.at(-2), blocks.at(-1))
      if a.at(0) / a.at(1) <= b.at(0) / b.at(1) { break }
      let _ = blocks.pop()
      blocks.at(-1) = (a.at(0) + b.at(0), a.at(1) + b.at(1))
    }
  }
  let fit = ()
  for (sum, count) in blocks { fit += (sum / count,) * count }
  // Clamp into the room (the first label's start, the last one's end)
  let lb = if lo == none { none } else { lo + size-of(live.first()) / 2 }
  let ub = if hi == none { none } else { hi - size-of(live.last()) / 2 - offs.last() }
  let out = (none,) * n
  for (k, i) in live.enumerate() {
    let z = fit.at(k)
    z = if lb != none and ub != none and lb > ub { (lb + ub) / 2 } else {
      if lb != none { z = calc.max(z, lb) }
      if ub != none { z = calc.min(z, ub) }
      z
    }
    // A label nothing moved keeps its wish exactly
    out.at(i) = if z == wants.at(i) - offs.at(k) { wants.at(i) } else { z + offs.at(k) }
  }
  out
}

/// Places `body` with its vertical centre on `y` and its left edge on `x`,
/// whatever its height: the body is measured, so a wrapped or stacked
/// multi-line label is centred as a block. (A zero-height `box` aligned to
/// the horizon only works for one line; a stack inside one collapses.)
///
/// - x (length): Left edge of the label box
/// - y (length): Vertical centre
/// - body (content): Label
/// - width (auto, length): Box width; text wraps inside it
/// - align (alignment): Horizontal alignment inside the box
/// -> content
#let place-centered(x, y, body, width: auto, align: left) = {
  let b = box(width: width, std.align(align, body))
  let h = measure(b).height
  place(left + top, dx: x, dy: y - h / 2, b)
}

/// Decides how to set a label, with an optional second (detail) line, inside
/// a `w` × `h` cell: the largest size, from `base` down to `min`, at which the
/// label fits *measured*: on one line, or wrapped at spaces when no word is
/// wider than the cell. The detail line is added when it fits under the label.
///
/// Returns `none` when not even `min` fits: the caller then leaves the cell
/// unlabelled (or labels it elsewhere) instead of printing past its edges.
///
/// - label (content, str): Main label
/// - detail (none, content, str): Secondary line (a value, a share)
/// - w (length): Cell width available to text
/// - h (length): Cell height available to text
/// - base (length): Preferred size
/// - min (length): Smallest readable size
/// - weight (str, int): Weight of the main label
/// - detail-k (float): Detail size relative to the label
/// - lead-k (float): Space between the lines, in em of the label
/// -> none, dictionary with `size`, `wrapped` and `detail`
#let fit-cell-label(label, detail, w, h, base, min: 6pt, weight: "bold", detail-k: 0.85, lead-k: 0.25) = {
  if w <= 0pt or h <= 0pt { return none }
  let words = if type(label) == str { label.split(" ") } else { (label,) }
  let steps = int((base - min) / 0.5pt)
  for k in range(calc.max(steps, 0) + 1) {
    let s = base - k * 0.5pt
    if s * 1.2 > h { continue }
    let lw = text-width(label, s, weight: weight)
    let main-h = if lw <= w { s * 1.2 } else if max-text-width(words, s, weight: weight) <= w {
      measure(box(width: w, text(size: s, weight: weight)[#label])).height
    } else { none }
    if main-h == none or main-h > h { continue }
    let det-h = s * (detail-k * 1.2 + lead-k)
    let has-detail = detail != none and detail != "" and main-h + det-h <= h and text-width(detail, s * detail-k) <= w
    return (size: s, wrapped: lw > w, detail: has-detail)
  }
  none
}
