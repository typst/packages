///! Tick labels, in one or more dodged rows.
///!
///! Ported from `_draw-x-label` and `_draw-y-label` in `render/panel-draw.typ`
///! and from the depth helpers in `render/extents.typ` that reserve the band
///! those two draw into. The pair existed because each wrote its own anchor and
///! its own coordinate order; here one routine serves both, and the side only
///! decides which extent of the turned label counts as thickness.
///!
///! Labels are never measured here. The render stage measures text and stamps
///! each entry with its `width` and `height` in cm, as `_break-records` already
///! does, and this module reads them back. That keeps the module free of a
///! Typst measurement context and lets the reservation and the draw agree by
///! construction.
///!
///! `reach` is reported separately from `across` because a rotated
///! corner-pinned label swings about its pin: it can overhang the ends of the
///! band without deepening it, which is what the chrome stage floors its margin
///! on.

#import "../../deps.typ": cetz
#import "../../utils/label-geometry.typ": (
  _label-reach, _rotated-extent, _x-label-anchor,
)
#import "../../utils/errors.typ": check, fail-range
#import "../surface.typ": surface-for
#import "common.typ": NOTHING, entries-of, measured, primitive

// Gap between dodged rows, per side. Mirrors `_X-LABEL-ROW-GAP` and
// `_Y-LABEL-COL-GAP` in `render/extents.typ`, which the reservation and the
// draw both apply today; the axis builder passes them in once it is wired.
#let X-ROW-GAP = 0.35
#let Y-COL-GAP = 0.5

// Rotation the axis draw accepts, matching `_check-axis-angle`.
#let _ANGLE-LIMIT = 90

#let prim-labels(entries: auto, angle: 0, n-dodge: 1, dodge-gap: auto) = {
  if angle < -_ANGLE-LIMIT or angle > _ANGLE-LIMIT {
    fail-range(
      "guide-labels",
      "angle",
      angle,
      -_ANGLE-LIMIT,
      _ANGLE-LIMIT,
      lo-open: false,
      hi-open: false,
      hint: "A quarter turn either way is the limit; past it the labels read "
        + "upside down.",
    )
  }
  check(
    type(n-dodge) == int and n-dodge >= 1,
    "guide-labels",
    "n-dodge must be a whole number of at least 1; got " + repr(n-dodge),
    hint: "One row per dodge; use 1 for a single row.",
  )
  primitive(
    "labels",
    entries: entries,
    angle: angle,
    n-dodge: n-dodge,
    dodge-gap: dodge-gap,
  )
}

// The gap a side puts between dodged rows.
#let _dodge-gap(prim, gctx) = {
  let given = prim.at("dodge-gap", default: auto)
  if given != auto { return given }
  if gctx.position == "top" or gctx.position == "bottom" { X-ROW-GAP } else {
    Y-COL-GAP
  }
}

// The anchor a label is pinned at. An x label turns about a corner so its ink
// stays under its break; every other side pins on a fixed edge, and a radial
// label pins at its centre, as the radial draw already does.
#let _anchor-for(gctx, angle) = {
  if gctx.position == "theta" or gctx.position == "r" { return "center" }
  if gctx.position == "bottom" { return _x-label-anchor(angle) }
  if gctx.position == "top" { return "south" }
  if gctx.position == "left" { return "mid-east" }
  "mid-west"
}

// The extents the render stage stamped on an entry, in cm.
#let _extent-of(e) = (
  e.at("width", default: 0.0),
  e.at("height", default: 0.0),
)

// The widest and tallest label in the table, which is what the band is sized
// from, exactly as the depth helpers size it from the longest label.
#let _largest(rows) = {
  let w = 0.0
  let h = 0.0
  for e in rows {
    let (ew, eh) = _extent-of(e)
    w = calc.max(w, ew)
    h = calc.max(h, eh)
  }
  (w, h)
}

// Depth of the band, plus how far the outermost labels overhang its ends.
//
// Depth is the turned extent of the longest label across the side, plus one gap
// per extra dodge row. That is `_x-label-depth` on a horizontal side and
// `_y-label-width` on a vertical one, which the flip selects between rather
// than duplicating.
#let measure(prim, gctx, entries: auto) = {
  let rows = entries-of(prim, entries, scope: "guide-labels")
  if rows.len() == 0 { return NOTHING }
  if surface-for(gctx, "text") == none { return NOTHING }
  let angle = prim.at("angle", default: 0)
  let n-dodge = prim.at("n-dodge", default: 1)
  let (w, h) = _largest(rows)
  if w == 0.0 and h == 0.0 { return NOTHING }
  let turned = _rotated-extent(w, h, angle)
  // The context says which canvas axis the depth runs along, because that
  // belongs to the `place` closure rather than to the side.
  let horizontal = gctx.axes.along == "x"
  let across = if horizontal { turned.height } else { turned.width }
  let depth = across + (n-dodge - 1) * _dodge-gap(prim, gctx)
  // How far the pinned label spreads either way along the side. The chrome
  // stage floors its margin on this, so it is reported rather than folded in.
  let anchor = _anchor-for(gctx, angle)
  let spread = _label-reach(w, h, angle, anchor)
  let (near, far) = if horizontal {
    (spread.left, spread.right)
  } else { (spread.down, spread.up) }
  measured(across: depth, fills: true, near: near, far: far)
}

#let draw(prim, gctx, entries: auto) = {
  let rows = entries-of(prim, entries, scope: "guide-labels")
  if rows.len() == 0 { return }
  let place = gctx.place
  if place == none { return }
  let surface = surface-for(gctx, "text")
  if surface == none { return }
  let styles = gctx.at("text-style", default: none)
  if styles == none { return }
  let style = (styles)(surface)
  let angle = prim.at("angle", default: 0)
  let n-dodge = prim.at("n-dodge", default: 1)
  let gap = _dodge-gap(prim, gctx)
  let anchor = _anchor-for(gctx, angle)
  // A primitive draws from its own edge outward and lets the composition place
  // that edge, exactly as the spine and the tick rows do. Reading a
  // neighbour's geometry here would put the tick lead in the drawn position and
  // in nobody's reservation.
  //
  // Rows are dodged over the labels actually drawn, so an unlabelled or
  // sub-decade entry does not consume a row and shift the rest.
  let drawn = rows.filter(e => e.at("label", default: none) != none)
  for (idx, e) in drawn.enumerate() {
    let row = calc.rem(idx, n-dodge)
    cetz.draw.content(
      place(e.frac, row * gap),
      (style.render)(e.label),
      anchor: anchor,
      angle: angle * 1deg,
    )
  }
}
