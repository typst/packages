///! The colour bar: a painted strip with a tick flank.
///!
///! Ported from `_draw-colourbar` in `render/legend.typ` and from the width and
///! height estimates that reserve the room it draws into.
///!
///! It is one primitive rather than a stack, because the flank of a vertical bar
///! reads across the guide while the guide itself stacks down it. The strip is a
///! fixed box, the ticks hang off its far edge, and the labels sit past those,
///! all of it inside one reservation.
///!
///! The layer says where the strip is; the render stage inks it. `bar-draw` on
///! the context takes the two corners and paints the frame, the gradient or the
///! bins, and the frame stroke, because every one of those reads a palette and a
///! trained scale, which live downstream of this module.
///!
///! `band` and `label-reserve` are the room the guide reserves past the strip.
///! They are handed in as numbers so the caller decides the geometry. Both
///! directions spend the same `tick length + tick gap` this file draws with,
///! plus the box their labels were measured to occupy: a vertical bar spends it
///! across its flank, and a horizontal one down its band.

#import "../../deps.typ": cetz
#import "../../utils/errors.typ": assert-halign, check, fail-enum, fail-type
#import "../grid.typ": align-offset, pin-below, pin-right-of
#import "../surface.typ": surface-for, tick-metrics
#import "../primitive/common.typ": (
  NOTHING, entries-of, measured, primitive, stroke-for,
)

// Which way the strip reads. A horizontal bar runs along the guide and puts its
// flank below; a vertical one runs down the guide and puts its flank to the
// right.
#let DIRECTIONS = ("horizontal", "vertical")

// `bar` is the strip's own box in centimetres, `band` the room reserved past it
// across the guide, and `label-reserve` the room reserved past it along the
// guide. `justify` justifies a horizontal strip inside the guide width, as a
// key grid is justified under its title.
#let prim-bar(
  entries: auto,
  direction: "vertical",
  bar: (0.0, 0.0),
  band: 0.0,
  label-reserve: 0.0,
  label-w: 0.0,
  angle: 0,
  label-align: none,
  justify: none,
) = {
  if not DIRECTIONS.contains(direction) {
    fail-enum("guide-bar", "direction", direction, DIRECTIONS)
  }
  if type(bar) != array or bar.len() != 2 {
    fail-type(
      "guide-bar",
      "bar",
      bar,
      "a (width, height) pair in centimetres",
    )
  }
  for (name, value) in (
    ("bar width", bar.at(0)),
    ("bar height", bar.at(1)),
    ("band", band),
    ("label-reserve", label-reserve),
    ("label-w", label-w),
  ) {
    check(
      type(value) in (int, float) and value >= 0,
      "guide-bar",
      name
        + " must be a number of centimetres of at least 0; got "
        + repr(value),
      hint: "The render stage resolves the strip's box before it gets here.",
    )
  }
  assert-halign("guide-bar", label-align, name: "label-align")
  assert-halign("guide-bar", justify, name: "justify")
  primitive(
    "bar",
    entries: entries,
    direction: direction,
    bar: bar,
    band: band,
    label-reserve: label-reserve,
    label-w: label-w,
    angle: angle,
    label-align: label-align,
    justify: justify,
  )
}

// The room a break label sits past the strip: the tick it hangs off, plus the
// gap after that tick. One formula, so the reservation a guide makes and the
// place the draw below puts the label cannot say different things.
#let bar-lead-of(ticks) = ticks.len + ticks.gap

// The same, for a caller holding a context rather than resolved tick metrics.
#let bar-lead(gctx) = bar-lead-of(tick-metrics(gctx))

// The strip plus the room reserved past it, on both axes.
//
// A context with no bar surface has no colour bar to paint, so the strip takes
// no room and draws none, which is the rule every part on the layer follows.
#let measure(prim, gctx, entries: auto) = {
  if surface-for(gctx, "bar") == none { return NOTHING }
  let (bar-w, bar-h) = prim.bar
  if bar-w == 0.0 and bar-h == 0.0 { return NOTHING }
  measured(
    across: bar-h + prim.band,
    along: bar-w + prim.label-reserve,
  )
}

#let draw(prim, gctx, entries: auto) = {
  if surface-for(gctx, "bar") == none { return }
  let place = gctx.at("place", default: none)
  if place == none { return }
  let span = gctx.at("span", default: none)
  check(
    type(span) in (int, float) and span > 0,
    "guide-bar",
    "the context spans " + repr(span) + " centimetres",
    hint: "A colour bar places itself in centimetres; pass `span:` on the "
      + "context it draws under.",
  )
  let at-cm = (along, across) => place(along / span, across)
  let (bar-w, bar-h) = prim.bar
  let horizontal = prim.direction == "horizontal"
  // A horizontal strip shares the title's centre or edge; a vertical one keeps
  // the near edge, which is what `justify: none` says.
  let indent = if prim.justify == none { 0.0 } else {
    align-offset(prim.justify, span, bar-w)
  }
  let ink-bar = gctx.at("bar-draw", default: none)
  if ink-bar != none {
    (ink-bar)(
      at-cm(indent, bar-h),
      at-cm(indent + bar-w, 0.0),
      horizontal,
    )
  }
  let rows = entries-of(prim, entries, scope: "guide-bar")
  if rows.len() == 0 { return }
  let ticks = tick-metrics(gctx)
  let tick-stroke = stroke-for(gctx, ticks.surface)
  let text-surface = surface-for(gctx, "text")
  let styles = gctx.at("text-style", default: none)
  let style = if text-surface == none or styles == none { none } else {
    (styles)(text-surface)
  }
  let lead = bar-lead-of(ticks)
  for e in rows {
    // The strip is painted from its low end: a horizontal one runs left to
    // right and a vertical one bottom to top, so a vertical break counts back
    // from the far edge of the box.
    let (tick-from, tick-to, label-at, anchor) = if horizontal {
      let along = indent + e.frac * bar-w
      let (lx, pin) = pin-below(prim.label-align, along)
      (
        at-cm(along, bar-h),
        at-cm(along, bar-h + ticks.len),
        at-cm(lx, bar-h + lead),
        pin,
      )
    } else {
      let across = (1.0 - e.frac) * bar-h
      let (lx, pin) = pin-right-of(
        prim.label-align,
        bar-w + lead,
        prim.label-w,
      )
      (
        at-cm(bar-w, across),
        at-cm(bar-w + ticks.len, across),
        at-cm(lx, across),
        pin,
      )
    }
    if tick-stroke != none {
      cetz.draw.line(tick-from, tick-to, stroke: tick-stroke)
    }
    if style == none or e.at("label", default: none) == none { continue }
    cetz.draw.content(
      label-at,
      (style.render)(e.label),
      anchor: anchor,
      angle: prim.angle * 1deg,
    )
  }
}
