///! Which theme surface a guide part paints on.
///!
///! An axis and a legend draw the same parts and theme them differently: a tick
///! on an axis resolves `axis-ticks-x-bottom`, the same tick beside a colour bar
///! resolves `legend-ticks`. A part therefore never names a surface itself. It
///! asks for a role, and the context answers with the surface that role maps to
///! on this side, in this context.
///!
///! Three asymmetries between the two contexts are encoded here rather than
///! discovered at a draw site:
///!
///! - A legend has no sub-decade tick tiers, so those roles resolve to `none`.
///!   Its `line` role resolves to `legend-line`, which is blank by default, so a
///!   legend draws no spine unless the theme asks for one.
///! - A tick surface carries a length, and `tick-metrics` answers with it as
///!   well as the surface. A context with no `tick-length` closure falls back to
///!   `LEGEND-TICK-LEN` in a legend and to nothing on an axis.
///! - The sub-decade tick tiers are per-axis, never per-side, so they take the
///!   axis rather than the side.

#import "../utils/errors.typ": fail-enum

// The surface suffix each cartesian side resolves against.
#let _SIDE-SUFFIX = (
  top: "x-top",
  bottom: "x-bottom",
  left: "y-left",
  right: "y-right",
)

// What a part asks for. `ticks-mid` and `ticks-minor` are the sub-decade tiers
// a log axis draws; `bar` is the colour-bar body.
#let ROLES = (
  "text",
  "title",
  "line",
  "ticks",
  "ticks-mid",
  "ticks-minor",
  "background",
  "bar",
)

// Tick geometry a legend draws at when its context carries no theme. The length
// is the default of `legend-ticks`; the gap is the room between a tick and its
// label.
#let LEGEND-TICK-LEN = 0.1
#let LEGEND-TICK-GAP = 0.08

// The theme surface a role resolves to, or `none` when this context has no
// such surface. A part that gets `none` draws nothing and measures nothing.
#let surface-for(gctx, role) = {
  if not ROLES.contains(role) {
    fail-enum("guide-surface", "role", role, ROLES)
  }
  if gctx.mode == "axis" {
    // A cartesian side names its own surfaces. The radial positions have none,
    // so they read the side the axis they sweep on would use, which is what the
    // radial draw already does: an x theta axis reads the bottom surfaces, a y
    // theta axis reads the left ones.
    let side = _SIDE-SUFFIX.at(
      gctx.position,
      default: if gctx.axis == "y" { "y-left" } else { "x-bottom" },
    )
    if role == "text" { "axis-text-" + side } else if role == "title" {
      "axis-title-" + side
    } else if role == "line" { "axis-line-" + side } else if role == "ticks" {
      "axis-ticks-" + side
    } else if role == "ticks-mid" {
      "axis-ticks-mid-" + gctx.axis
    } else if role == "ticks-minor" {
      "axis-ticks-minor-" + gctx.axis
    } else if role == "background" { "panel-background" } else { none }
  } else {
    if role == "text" { "legend-text" } else if role == "title" {
      "legend-title"
    } else if role == "line" { "legend-line" } else if role == "ticks" {
      "legend-ticks"
    } else if role == "background" { "legend-background" } else if (
      role == "bar"
    ) { "legend-bar" } else {
      // A legend has no sub-decade tick tiers.
      none
    }
  }
}

// The surface a tick tier paints on, the cm it draws, and the cm between it and
// its label.
//
// The length comes from the theme through the `tick-length` closure the context
// carries. A legend context without one answers with the constants above.
#let tick-metrics(gctx, tier: "major") = {
  let role = if tier == "major" { "ticks" } else { "ticks-" + tier }
  let surface = surface-for(gctx, role)
  // No surface means this context has no such tick: a legend has no sub-decade
  // tiers. Answer with nothing to draw, so a caller reading `len` reserves no
  // room for a tick that never appears.
  if surface == none { return (surface: none, len: 0.0, gap: 0.0) }
  let resolve = gctx.at("tick-length", default: none)
  if gctx.mode == "legend" {
    return (
      surface: surface,
      len: if resolve == none { LEGEND-TICK-LEN } else { (resolve)(surface) },
      gap: LEGEND-TICK-GAP,
    )
  }
  (
    surface: surface,
    len: if resolve == none { 0.0 } else { (resolve)(surface) },
    gap: gctx.tick-gap,
  )
}
