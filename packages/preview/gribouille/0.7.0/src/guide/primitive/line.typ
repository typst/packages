///! The guide spine: the line an axis draws along its own edge.
///!
///! Ported from the two axis-line draw sites in `render/panel-draw.typ`, which
///! draw one segment along each primary edge, and from the outer arc in
///! `render/panel-radial.typ`, which draws the same spine around a sweep.
///!
///! The line sits on the panel edge rather than beside it, so it reserves no
///! depth. A legend has no line surface at all, so there it draws nothing and
///! measures nothing, which is the asymmetry `surface-for` encodes.
///!
///! A swept spine is a polyline rather than a segment, sampled at the rate
///! `arc-steps` gives every curve drawn at a constant radius. It reads the
///! sweep off the context, so the same primitive draws a straight side and an
///! arc without knowing which it is on.
///!
///! `lo` and `hi` are where the spine starts and ends along the guide. They are
///! the whole span on a cartesian side and the trimmed span on a capped theta
///! axis, which fades the arc out short of its end angle.

#import "../../deps.typ": cetz
#import "../../utils/errors.typ": check
#import "../../utils/radial.typ": arc-steps
#import "../surface.typ": surface-for
#import "common.typ": NOTHING, measured, primitive, stroke-for

#let prim-line(lo: 0.0, hi: 1.0) = {
  check(
    lo >= 0.0 and hi <= 1.0 and lo < hi,
    "guide-line",
    "the spine runs from " + repr(lo) + " to " + repr(hi),
    hint: "Both are fractions of the guide, with `lo` before `hi`.",
  )
  primitive("line", entries: auto, lo: lo, hi: hi)
}

// A spine runs the length of the guide and adds no thickness to the band. A
// blanked surface draws nothing, so it measures nothing either: measure and
// draw gate on the same stroke.
#let measure(prim, gctx, entries: auto) = {
  if stroke-for(gctx, surface-for(gctx, "line")) == none { return NOTHING }
  measured(fills: true)
}

// The points the spine is drawn through: two on a straight side, one per
// sampling step on a swept one.
#let _points(prim, gctx) = {
  let lo = prim.at("lo", default: 0.0)
  let hi = prim.at("hi", default: 1.0)
  let place = gctx.place
  let sweep = gctx.at("sweep", default: none)
  if sweep == none { return (place(lo, 0.0), place(hi, 0.0)) }
  let steps = arc-steps((hi - lo) * sweep)
  range(steps + 1).map(i => place(lo + (hi - lo) * i / steps, 0.0))
}

#let draw(prim, gctx, entries: auto) = {
  let stroke = stroke-for(gctx, surface-for(gctx, "line"))
  if stroke == none { return }
  if gctx.place == none { return }
  cetz.draw.line(.._points(prim, gctx), stroke: stroke)
}
