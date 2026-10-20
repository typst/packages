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

/// Single-pass greedy label deconfliction.
///
/// Takes an array of proposal dicts, each with keys `cx`, `cy`, `lx`, `ly`, `w`, `h`
/// (plus any extra keys which are preserved). Sorts by `ly`, then nudges overlapping
/// labels, trying both upward and downward and picking the direction that keeps the
/// label closest to its original proposed position.
///
/// - proposals (array): Array of label-position dicts
/// - bounds (dictionary): Dict with `left`, `right`, `top`, `bottom` keys
/// - gap (length): Minimum vertical gap between labels
/// -> array
#let greedy-deconflict(proposals, bounds, gap: 2pt) = {
  // Sort by ly (top position)
  let sorted = proposals.sorted(key: p => p.ly)
  let placed = ()
  for p in sorted {
    let ly = p.ly
    let orig-ly = p.ly
    // Check against all already-placed labels for overlaps
    let has-overlap = true
    let iters = 0
    // Iteratively resolve overlaps (max 10 iterations to avoid infinite loops)
    while has-overlap and iters < 10 {
      has-overlap = false
      iters += 1
      for prev in placed {
        let overlap-v = prev.ly + prev.h + gap - ly
        let overlap-h = not (p.lx + p.w <= prev.lx or prev.lx + prev.w <= p.lx)
        if overlap-h and overlap-v > 0pt {
          // Try nudging down
          let ly-down = prev.ly + prev.h + gap
          // Try nudging up (above the conflicting label)
          let ly-up = prev.ly - p.h - gap
          // Pick the direction closer to the original proposed position
          let dist-down = calc.abs((ly-down - orig-ly) / 1pt)
          let dist-up = calc.abs((ly-up - orig-ly) / 1pt)
          if ly-up >= bounds.top and dist-up <= dist-down {
            ly = ly-up
          } else {
            ly = ly-down
          }
          has-overlap = true
        }
      }
    }
    // Clamp to bounds
    let ly = calc.max(bounds.top, calc.min(bounds.bottom - p.h, ly))
    let lx = calc.max(bounds.left, calc.min(bounds.right - p.w, p.lx))
    let entry = (:)
    for (k, v) in p.pairs() {
      if k == "lx" { entry.insert(k, lx) }
      else if k == "ly" { entry.insert(k, ly) }
      else { entry.insert(k, v) }
    }
    placed.push(entry)
  }
  placed
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
