// matrix.typ - Layout for grids with row and column labels (heatmaps,
// correlation matrices, calendars)
//
// The grid's two label gutters are measured from the labels, not guessed from
// theme paddings: the row gutter is as wide as the widest row label, and the
// column gutter is as tall as the column labels need. Column labels stay
// horizontal whenever they fit their cells (shrinking a little first), turn 45
// degrees (then vertical, shrinking to a floor) only when they cannot, and are
// thinned, evenly with the first and last always shown, only when even those
// would collide. Functions measure text, so call them inside `context`.

#import "../theme.typ": *
#import "fonts.typ": text-width, text-height, max-text-width, fit-font-size, thin-indices, fit-pitch, place-centered

/// Lays out the label gutters around a `cell-w` × `cell-h` grid.
///
/// Returns a dictionary:
/// - `labels`: content to place at the origin of the chart box: row labels
///   right-aligned against the grid, column labels above it
/// - `gx`, `gy`: where the grid's top-left corner goes
/// - `row-w`, `header-h`: gutter sizes (the row gutter includes its gap)
/// - `overhang`: how far the last column label sticks out to the right of the grid
/// - `col-mode`: `"horizontal"`, `"rotated"` (45 degrees) or `"vertical"`
/// - `size`: label size used
///
/// - row-labels (array): One label per row
/// - col-labels (array): One label per column
/// - cell-w (length): Cell width
/// - cell-h (length): Cell height
/// - theme (dictionary): Resolved theme
/// - max-row-w (none, length): Cap on the row gutter; wider labels shrink, then wrap
/// - label-fill (auto, color): Label colour
/// -> dictionary
#let matrix-layout(
  row-labels,
  col-labels,
  cell-w,
  cell-h,
  theme,
  max-row-w: none,
  label-fill: auto,
) = {
  let base = theme.axis-label-size
  let gap = theme.axis-label-gap
  let off = theme.label-offset + 1pt
  let fill = if label-fill == auto { theme.text-color } else { label-fill }
  let n-rows = row-labels.len()
  let n-cols = col-labels.len()

  // --- Row gutter: widest row label, measured ---
  // The size shrinks with the cell height before any label is dropped; labels
  // that still do not fit are spread evenly, first and last always shown
  let r-fit = fit-pitch(cell-h, base, floor: 5pt)
  let r-size = r-fit.size
  let r-kept = thin-indices(n-rows, r-fit.stride)
  let r-shown = row-labels.enumerate().filter(((i, _)) => i in r-kept).map(((_, l)) => l)
  let r-widest = r-shown.fold("", (a, b) => if text-width(b, r-size) > text-width(a, r-size) { b } else { a })
  if max-row-w != none and text-width(r-widest, r-size) > max-row-w - gap {
    r-size = fit-font-size(r-widest, max-row-w - gap, r-size, min: calc.max(6pt, r-size * 0.75))
  }
  let r-w = text-width(r-widest, r-size)
  let r-cap = if max-row-w != none { max-row-w - gap } else { r-w }
  let r-box = calc.min(r-w, r-cap)
  if r-w > r-cap { r-size = calc.max(5pt, calc.min(r-size, cell-h * 0.9 / 2.3)) }
  let row-w = r-box + gap

  // --- Column labels ---
  // In order: horizontal (shrinking a little); 45 degrees, shrunk to the
  // slant's pitch; vertical, shrunk to the cell width; and only then thinned
  // (evenly, first and last always shown) at 45 degrees
  let c-floor = 6pt
  let c-widest = col-labels.fold("", (a, b) => if text-width(b, base) > text-width(a, base) { b } else { a })
  let slack = 4pt
  let c-size = fit-font-size(c-widest, cell-w - slack, base, min: calc.max(c-floor, base * 0.8))
  let mode = "horizontal"
  let c-kept = array.range(n-cols)
  if text-width(c-widest, c-size) > cell-w - slack {
    // Rotated labels need 1.2 line heights between neighbours (across the slant
    // for 45 degrees), or they read as a hatching
    let f45 = fit-pitch(0.7071 * cell-w, base, floor: c-floor, line-k: 1.2)
    let f90 = fit-pitch(cell-w, base, floor: c-floor, line-k: 1.2)
    if f45.stride == 1 {
      mode = "rotated"
      c-size = f45.size
    } else if f90.stride == 1 {
      mode = "vertical"
      c-size = f90.size
    } else {
      mode = "rotated"
      c-size = c-floor
      c-kept = thin-indices(n-cols, f45.stride)
    }
  }
  let lh = text-height("Mg", c-size)
  let header-h = 0pt
  let overhang = 0pt
  if n-cols > 0 {
    let c-shown = col-labels.enumerate().filter(((j, _)) => j in c-kept).map(((_, l)) => l)
    let wmax = max-text-width(c-shown, c-size)
    if mode == "horizontal" {
      header-h = lh + off
    } else if mode == "vertical" {
      header-h = wmax + off
    } else {
      header-h = (wmax + lh) * 0.7071 + off
      overhang = calc.max(0pt, (text-width(c-shown.last(), c-size) + lh) * 0.7071 - cell-w / 2)
    }
  }

  let drawn = {
    for (i, l) in row-labels.enumerate() {
      if i not in r-kept { continue }
      place-centered(0pt, header-h + (i + 0.5) * cell-h,
        text(size: r-size, fill: fill)[#l], width: r-box, align: right)
    }
    for (j, l) in col-labels.enumerate() {
      if j not in c-kept { continue }
      let cx = row-w + (j + 0.5) * cell-w
      let body = text(size: c-size, fill: fill)[#l]
      if mode == "horizontal" {
        place(left + top, dx: cx - text-width(l, c-size) / 2, dy: header-h - off - lh, body)
      } else if mode == "vertical" {
        place(left + top, dx: cx + lh / 2, dy: header-h - off - lh,
          rotate(-90deg, origin: bottom + left, body))
      } else {
        place(left + top, dx: cx, dy: header-h - off - lh,
          rotate(-45deg, origin: bottom + left, body))
      }
    }
  }

  (
    labels: drawn,
    gx: row-w,
    gy: header-h,
    row-w: row-w,
    header-h: header-h,
    overhang: overhang,
    col-mode: mode,
    size: c-size,
  )
}

/// One font size for every value written inside the cells of a grid: the
/// largest size, up to `base`, at which the widest value fits a cell.
/// `none` when even the smallest readable size does not fit (the caller then
/// omits the values rather than printing over cell edges).
///
/// - strs (array): The value strings that will be printed
/// - cell-w (length): Cell width
/// - cell-h (length): Cell height
/// - theme (dictionary): Resolved theme
/// - min (length): Smallest readable size
/// -> none, length
#let cell-label-size(strs, cell-w, cell-h, theme, min: 5pt) = {
  let base = calc.min(theme.axis-label-size, cell-h * 0.7)
  if strs.len() == 0 { return base }
  let widest = strs.fold("", (a, b) => if text-width(b, base) > text-width(a, base) { b } else { a })
  let size = fit-font-size(widest, cell-w - 4pt, base, min: min)
  if size < min or text-width(widest, size) > cell-w - 3pt { none } else { size }
}
