///! The two-dimensional grid a legend lays its keys out on.
///!
///! A legend is not a stack of rows. It is a grid: keys flow down a column or
///! across a row, each column sizes to its own widest label, and a row that
///! carries a two-line label pushes every row below it down. That is why the
///! swatch cannot be expressed as a stack of primitives and needs a primitive
///! that owns the whole grid.
///!
///! Everything here is geometry over numbers. Nothing in this module measures
///! text, reads a theme, or draws: the render stage stamps each entry with the
///! extent of its label, exactly as it already does for the axis labels, and
///! these helpers read those numbers back. That is what lets the size a legend
///! reserves and the ink it puts down come from one set of formulas.
///!
///! Ported from the swatch and size-ladder helpers in `render/legend.typ`,
///! which the ladder still calls until it moves onto the layer as well.

#import "../utils/errors.typ": check

// Column gap: at least `MIN` cm, growing with the widest column by `RATIO` so
// dense legends keep breathing room.
#let COL-GAP-MIN = 0.15
#let COL-GAP-RATIO = 0.1

// The grid a count of keys flows into. An explicit `ncol` fixes the columns and
// an explicit `nrow` the rows; with neither, a horizontal guide is one row and a
// vertical one is one column.
#let grid-shape(n, nrow, ncol, direction) = {
  if ncol != none {
    let cols = calc.max(1, ncol)
    (rows: calc.max(1, calc.ceil(n / cols)), cols: cols)
  } else if nrow != none {
    let rows = calc.max(1, nrow)
    (rows: rows, cols: calc.max(1, calc.ceil(n / rows)))
  } else if direction == "horizontal" {
    (rows: 1, cols: n)
  } else {
    (rows: n, cols: 1)
  }
}

// Index of the key at (row, col). Column-major (`byrow: false`) numbers items
// down each column; row-major (`byrow: true`) numbers them across each row.
#let grid-index(row, col, shape, byrow) = {
  if byrow { row * shape.cols + col } else { col * shape.rows + row }
}

// Inverse of `grid-index`: recover (row, col) from a linear index.
#let grid-rc(i, shape, byrow) = {
  if byrow {
    (row: calc.quo(i, shape.cols), col: calc.rem(i, shape.cols))
  } else {
    (row: calc.rem(i, shape.rows), col: calc.quo(i, shape.rows))
  }
}

// Turn a per-row extra-height list into stacking data: `extra` per row, the
// cumulative overflow `before` each row (how far that row is pushed down), and
// the `total` added to the single-line stack height.
#let stack-offsets(extras) = {
  let before = ()
  let acc = 0.0
  for e in extras {
    before.push(acc)
    acc += e
  }
  (extra: extras, before: before, total: acc)
}

// Per-row stacking offsets: each row's overflow is the tallest overflow across
// its columns. `extra-of(i)` returns the i-th key's extra height in cm and
// `count` bounds the populated cells.
#let row-overflows(count, extra-of, shape, byrow) = stack-offsets(
  range(shape.rows).map(row => {
    let max-e = 0.0
    for col in range(shape.cols) {
      let i = grid-index(row, col, shape, byrow)
      if i >= count { continue }
      let e = (extra-of)(i)
      if e > max-e { max-e = e }
    }
    max-e
  }),
)

// Per-column widths, the gap between columns, the cumulative left offsets, and
// the total grid width.
//
// Each column sizes to its own widest label, so a single oversized key does not
// pad every other column. `width-of(i)` returns the i-th label's width in cm and
// `lead` is the room the key glyph takes before the label in every cell.
#let column-widths(count, width-of, shape, byrow, lead) = {
  let widths = range(shape.cols).map(col => {
    let max-w = 0.0
    for row in range(shape.rows) {
      let i = grid-index(row, col, shape, byrow)
      if i >= count { continue }
      let w = (width-of)(i)
      if w > max-w { max-w = w }
    }
    lead + max-w
  })
  // A grid of no columns is as wide as nothing. This is the shape a horizontal
  // guide with no keys flows into; a vertical one keeps its single column and
  // sizes it as usual, because the record has to describe the shape the keys
  // flow into or `prim-keys` rejects it.
  //
  // No legend reaches it today: a scale with no levels is dropped before a
  // guide is built for it. This holds the boundary rather than a live path, so
  // a caller that hands the helper an empty shape gets an empty record instead
  // of `calc.max` over an empty list, which raises a Typst message in place of
  // a library one.
  if widths.len() == 0 {
    return (widths: (), gap: COL-GAP-MIN, offsets: (), total: 0.0)
  }
  let gap = calc.max(COL-GAP-MIN, COL-GAP-RATIO * calc.max(..widths))
  let offsets = ()
  let acc = 0.0
  for w in widths {
    offsets.push(acc)
    acc += w + gap
  }
  (widths: widths, gap: gap, offsets: offsets, total: acc - gap)
}

// Columns of one width, with a fixed gap between them.
//
// A size ladder sizes every column to the widest label in the whole guide
// rather than to the widest in each column, and a horizontal one packs its
// columns edge to edge. Both are this, against `column-widths` above.
#let uniform-columns(cols, width, gap: 0.0) = {
  let offsets = range(cols).map(col => col * (width + gap))
  (
    widths: range(cols).map(_ => width),
    gap: gap,
    offsets: offsets,
    total: if cols == 0 { 0.0 } else { cols * width + (cols - 1) * gap },
  )
}

// Rows that never stack, for a grid whose stride already carries the tallest
// label in the guide. The record has the shape `row-overflows` returns, so one
// walk serves a stacking grid and a uniform one alike.
#let flat-rows(rows) = stack-offsets(range(rows).map(_ => 0.0))

// Offset (cm) that justifies a part of width `part` inside a block of width
// `total`: nothing for left, half the slack for centre, all of it for right.
#let align-offset(align, total, part) = if align == right {
  total - part
} else if align == center {
  (total - part) / 2
} else { 0.0 }

// Where a label drawn to the right of a key lands, and the cetz anchor that
// pins it there. The label is justified inside a slot of width `slot` whose
// near edge is `start`: `left` keeps the near edge, `center` and `right` shift
// toward the far one.
//
// The `mid-*` anchors centre on the cap-height band rather than the glyph
// bounds, so a descender does not lift its label above a neighbour without one.
#let pin-right-of(align, start, slot) = {
  if align == right {
    (start + slot, "mid-east")
  } else if align == center {
    (start + slot / 2, "mid")
  } else {
    (start, "mid-west")
  }
}

// Where a label drawn under a key lands, and the cetz anchor that pins it
// there. The label keeps the key's own centre; the alignment only decides which
// of its edges that centre pins.
#let pin-below(align, centre) = {
  if align == right {
    (centre, "north-east")
  } else if align == center {
    (centre, "north")
  } else {
    (centre, "north-west")
  }
}

// The cm a key cell spends on its parts. Grouped into one record because they
// travel together from the render stage, which is the only place the font size
// and the themed key size they derive from are known.
//
// - `off` is the key glyph's radius, and the distance along the cell to its
//   centre.
// - `drop` is how far down the cell that centre sits. It equals `off` where the
//   label reads beside the key, and is its own number where the label reads
//   under it, because a horizontal ladder drops its glyph past its own radius.
// - `last` is what the final row reserves in place of a full stride.
// - `slack` is the room below that last row.
// - `lead` is what a column reserves before its label and `label-lead` is where
//   the label is actually pinned. The two have never been equal: the
//   reservation leaves half an em past the glyph and the draw leaves a flat
//   0.15 cm. They are carried separately rather than reconciled, because
//   reconciling them moves every legend.
// - `label-drop` is how far down the cell a label under a key sits, and is read
//   only by that flow.
#let METRIC-FIELDS = (
  "off",
  "drop",
  "last",
  "line-h",
  "slack",
  "lead",
  "label-lead",
  "label-drop",
)

#let key-metrics(
  off: 0.0,
  drop: auto,
  last: auto,
  line-h: 0.0,
  slack: 0.0,
  lead: 0.0,
  label-lead: 0.0,
  label-drop: 0.0,
) = {
  // A key that reads beside its label sits at its own radius and reserves its
  // own diameter, so those two follow the radius unless a flow states otherwise.
  let resolved = (
    off: off,
    drop: if drop == auto { off } else { drop },
    last: if last == auto { 2 * off } else { last },
    line-h: line-h,
    slack: slack,
    lead: lead,
    label-lead: label-lead,
    label-drop: label-drop,
  )
  for (name, value) in resolved {
    check(
      type(value) in (int, float) and value >= 0,
      "guide-grid",
      name
        + " must be a number of centimetres of at least 0; got "
        + repr(value),
      hint: "The render stage resolves these from the font size and the key "
        + "size before they get here.",
    )
  }
  resolved.pairs().map(((name, value)) => (name, value * 1.0)).to-dict()
}
