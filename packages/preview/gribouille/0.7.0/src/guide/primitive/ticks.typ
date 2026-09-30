///! Tick marks, in one or more weights.
///!
///! Ported from the tick draw in `render/panel-draw.typ`, which draws one
///! segment per break from the panel edge outward, and from the log-tick draw
///! beside it, which repeats that over a mid tier and a minor tier.
///!
///! The two were separate loops because each wrote its own `if axis == "x"`
///! branch. Here a tick is one line from `place(frac, 0)` to
///! `place(frac, len)`, so the four sides and the radial sweep share it, and a
///! tier is only a different length and surface over the same loop.
///!
///! Depth comes from the longest tier drawn, not from the major alone, so a
///! theme that lengthens a sub-decade tier past the major still reserves the
///! room it needs.

#import "../../deps.typ": cetz
#import "../entry.typ": TIERS, entries-of-tier
#import "../surface.typ": tick-metrics
#import "common.typ": (
  NOTHING, check-tier, draws-tick, entries-of, measured, primitive, stroke-for,
)

// Draw ticks for these weights, in this order. A plain axis draws majors only;
// a log axis adds the two sub-decade tiers.
#let prim-ticks(entries: auto, tiers: ("major",)) = primitive(
  "ticks",
  entries: entries,
  tiers: tiers.map(t => check-tier(t, TIERS, "guide-ticks")),
)

// The stroke and length a tier resolves to, or `none` when nothing is drawn.
#let _tier-ink(gctx, tier) = {
  let m = tick-metrics(gctx, tier: tier)
  if m.surface == none { return none }
  let stroke = stroke-for(gctx, m.surface)
  if not draws-tick(stroke, m.len) { return none }
  (stroke: stroke, len: m.len)
}

// The band a tick row occupies is the longest tier that actually draws.
#let measure(prim, gctx, entries: auto) = {
  let rows = entries-of(prim, entries, scope: "guide-ticks")
  if rows.len() == 0 { return NOTHING }
  let depth = 0.0
  for tier in prim.at("tiers", default: ("major",)) {
    if entries-of-tier(rows, tier).len() == 0 { continue }
    let ink = _tier-ink(gctx, tier)
    if ink == none { continue }
    depth = calc.max(depth, ink.len)
  }
  if depth == 0.0 { return NOTHING }
  measured(across: depth, fills: true)
}

#let draw(prim, gctx, entries: auto) = {
  let rows = entries-of(prim, entries, scope: "guide-ticks")
  if rows.len() == 0 { return }
  let place = gctx.place
  if place == none { return }
  for tier in prim.at("tiers", default: ("major",)) {
    let ink = _tier-ink(gctx, tier)
    if ink == none { continue }
    for e in entries-of-tier(rows, tier) {
      cetz.draw.line(
        place(e.frac, 0.0),
        place(e.frac, ink.len),
        stroke: ink.stroke,
      )
    }
  }
}
