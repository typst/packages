///! A legend's key grid: every glyph and its label, in rows and columns.
///!
///! Ported from `_draw-swatch` and `_draw-size-ladder` in `render/legend.typ`
///! and from the width and height estimates that reserve the room they draw
///! into. Each of those computed its own grid, and the three were kept in step
///! by comment; here one walk serves all of them.
///!
///! This is the one primitive that is not a band. A tick row or a label row runs
///! along the guide and has a single thickness; a key grid has a width per
///! column, an offset per row, and a glyph beside or above a label in every
///! cell. No stack of primitives can express that, so the grid is one primitive
///! that owns the whole of it.
///!
///! The grid records come in already built, because which formula sizes the
///! columns belongs to the guide rather than to the walk: a swatch sizes each
///! column to its own widest label, a vertical ladder sizes every column to the
///! widest label in the guide, and a horizontal one packs its columns edge to
///! edge. `src/guide/grid.typ` holds all three, and measure and draw read the
///! one record, so the room and the ink still cannot drift apart.
///!
///! Nothing is measured here. An entry carries the value its glyph is inked
///! from and the label beside it, and nothing else the walk reads: the render
///! stage measures the labels and turns them into those records before the
///! table arrives. The glyph draw comes down as a closure on the context for the
///! same reason, because the aesthetic bundle a glyph is inked from lives with
///! the scales, downstream of this module.

#import "../../deps.typ": cetz
#import "../../utils/errors.typ": assert-halign, check, fail-enum, fail-type
#import "../entry.typ": check-grid-entries
#import "../grid.typ": (
  METRIC-FIELDS, align-offset, grid-rc, pin-below, pin-right-of,
)
#import "../surface.typ": surface-for
#import "common.typ": NOTHING, entries-of, measured, primitive

// Where a label reads against its key: beside it, as every vertical legend
// draws it, or under it, as a horizontal size ladder does.
#let FLOWS = ("right", "below")

// The fields each grid record carries, checked where the record arrives so a
// half-built one fails by name rather than as a missing key inside the walk.
#let _COLUMN-FIELDS = ("widths", "gap", "offsets", "total")
#let _ROW-FIELDS = ("extra", "before", "total")

#let _check-record(value, fields, name) = {
  if type(value) != dictionary or fields.any(k => k not in value) {
    fail-type(
      "guide-keys",
      name,
      value,
      "a record carrying " + fields.join(", "),
      hint: "Build it with the helpers in `src/guide/grid.typ`.",
    )
  }
  value
}

// `metrics` is the record `key-metrics` builds, `shape` the `(rows, cols)` the
// keys flow into, and `columns` and `rows` the grid those keys land on.
// `label-align` justifies a label inside its own column and `justify` justifies
// the whole grid inside the guide, which is what puts a horizontal legend's keys
// under the centre of its title.
#let prim-keys(
  entries: auto,
  shape: (rows: 1, cols: 1),
  byrow: false,
  key: "rect",
  metrics: none,
  columns: none,
  rows: none,
  flow: "right",
  angle: 0,
  label-align: none,
  justify: none,
) = {
  if (
    type(shape) != dictionary or ("rows", "cols").any(k => k not in shape)
  ) {
    fail-type(
      "guide-keys",
      "shape",
      shape,
      "a dictionary with `rows` and `cols`",
    )
  }
  // A grid of no rows is legal and measures nothing, which is what a guide with
  // no levels resolves to. A fractional or negative count is not.
  for name in ("rows", "cols") {
    let n = shape.at(name)
    if type(n) != int or n < 0 {
      fail-type(
        "guide-keys",
        "shape." + name,
        n,
        "a whole number of at least 0",
      )
    }
  }
  if (
    type(metrics) != dictionary or METRIC-FIELDS.any(k => k not in metrics)
  ) {
    fail-type(
      "guide-keys",
      "metrics",
      metrics,
      "the record `key-metrics` builds",
      hint: "Build it with `key-metrics`, which carries "
        + METRIC-FIELDS.join(", ")
        + ".",
    )
  }
  let cols = _check-record(columns, _COLUMN-FIELDS, "columns")
  let stack = _check-record(rows, _ROW-FIELDS, "rows")
  // The records have to describe this grid, in every field the walk reads, or a
  // key lands in a column that was never sized.
  for (name, got, want) in (
    ("columns.widths", cols.widths.len(), shape.cols),
    ("columns.offsets", cols.offsets.len(), shape.cols),
    ("rows.extra", stack.extra.len(), shape.rows),
    ("rows.before", stack.before.len(), shape.rows),
  ) {
    check(
      got == want,
      "guide-keys",
      name + " describes " + str(got) + " of " + str(want),
      hint: "Build the record from the same shape the keys flow into.",
    )
  }
  if not FLOWS.contains(flow) {
    fail-enum("guide-keys", "flow", flow, FLOWS)
  }
  // Both alignments go through the shared guard, so a string such as "center"
  // fails by name rather than falling through to the left default.
  assert-halign("guide-keys", label-align, name: "label-align")
  assert-halign("guide-keys", justify, name: "justify")
  primitive(
    "keys",
    entries: entries,
    shape: shape,
    byrow: byrow,
    key: key,
    metrics: metrics,
    columns: cols,
    rows: stack,
    flow: flow,
    angle: angle,
    label-align: label-align,
    justify: justify,
  )
}

// The table this grid draws, checked at the boundary between the builder that
// stamped it and the primitive that reads it back. A grid row is placed by its
// cell rather than by a fraction, so it is checked as a grid table.
#let _rows-of(prim, inherited) = entries-of(
  prim,
  inherited,
  scope: "guide-keys",
  check: check-grid-entries,
)

// Every key has to have a cell to land in. Without this, an index past the grid
// reaches `grid-rc` and fails on a bare missing offset.
#let _check-fit(prim, rows) = check(
  prim.shape.rows * prim.shape.cols >= rows.len(),
  "guide-keys",
  "a "
    + str(prim.shape.rows)
    + " by "
    + str(prim.shape.cols)
    + " grid has no room for "
    + str(rows.len())
    + " keys",
  hint: "Size the shape from the entry count, as `grid-shape` does.",
)

// A grid is as wide as its columns and as deep as its rows: a full stride for
// every row but the last, which spends only what that last row reserves and a
// slack below it, plus whatever the multi-line rows added.
//
// It reports a length of its own rather than filling: a legend box is sized from
// its keys, unlike a tick row, which is as long as the axis it sits on.
#let measure(prim, gctx, entries: auto) = {
  let rows = _rows-of(prim, entries)
  if rows.len() == 0 { return NOTHING }
  _check-fit(prim, rows)
  let m = prim.metrics
  measured(
    across: (
      (prim.shape.rows - 1) * m.line-h + m.last + m.slack + prim.rows.total
    ),
    along: prim.columns.total,
  )
}

#let draw(prim, gctx, entries: auto) = {
  let rows = _rows-of(prim, entries)
  if rows.len() == 0 { return }
  _check-fit(prim, rows)
  let place = gctx.at("place", default: none)
  if place == none { return }
  let m = prim.metrics
  let columns = prim.columns
  let stack = prim.rows
  // The grid lays itself out in centimetres, so it needs to know what a
  // fraction of the guide is worth. A context that never stated one would put
  // every key at the near edge, so it fails here instead.
  let span = gctx.at("span", default: none)
  check(
    type(span) in (int, float) and span > 0,
    "guide-keys",
    "the context spans " + repr(span) + " centimetres",
    hint: "A key grid places itself in centimetres; pass `span:` on the "
      + "context it draws under.",
  )
  let at-cm = (along, across) => place(along / span, across)
  // A horizontal legend centres or right-justifies its grid under its title; a
  // vertical one keeps the near edge, which is what `justify: none` says.
  let indent = if prim.justify == none { 0.0 } else {
    align-offset(prim.justify, span, columns.total)
  }
  let ink-key = gctx.at("key-draw", default: none)
  let surface = surface-for(gctx, "text")
  let styles = gctx.at("text-style", default: none)
  let style = if surface == none or styles == none { none } else {
    (styles)(surface)
  }
  for (i, e) in rows.enumerate() {
    let rc = grid-rc(i, prim.shape, prim.byrow)
    let start = indent + columns.offsets.at(rc.col)
    // Push the row down past every multi-line row above it, then drop this key
    // half its own overflow, so its block grows downward and the glyph stays
    // centred on the first line.
    let row-top = rc.row * m.line-h + stack.before.at(rc.row)
    let centre = start + m.off
    // A row that stacked a multi-line label grows downward, so everything in it
    // drops half that growth and stays centred on the first line together.
    let stacked = stack.extra.at(rc.row) / 2
    let across = row-top + m.drop + stacked
    if ink-key != none {
      (ink-key)(prim.key, e.value, at-cm(centre, across), m.off)
    }
    if style == none or e.at("label", default: none) == none { continue }
    let (along, anchor) = if prim.flow == "below" {
      pin-below(prim.label-align, centre)
    } else {
      pin-right-of(
        prim.label-align,
        start + m.label-lead,
        columns.widths.at(rc.col) - m.lead,
      )
    }
    let label-across = if prim.flow == "below" {
      row-top + m.label-drop + stacked
    } else { across }
    cetz.draw.content(
      at-cm(along, label-across),
      (style.render)(e.label),
      anchor: anchor,
      angle: prim.angle * 1deg,
    )
  }
}
