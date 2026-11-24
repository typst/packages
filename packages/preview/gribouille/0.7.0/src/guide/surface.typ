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
///! - A legend has no line surface, so `line` resolves to `none` and a line
///!   part measures nothing in a legend.
///! - `axis-ticks` is an `element-tick` carrying a length; `legend-ticks` is an
///!   `element-line` with none. So `tick-metrics` answers with a length as well
///!   as a surface, and supplies the legend length itself.
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

// Tick geometry a legend draws at. The colour bar has drawn its ticks at these
// two lengths since before the guide layer existed, and `legend-ticks` carries
// no length of its own to read them from, so they live here as named constants
// rather than as locals at the draw site.
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
    } else if role == "ticks" { "legend-ticks" } else if role == "background" {
      "legend-background"
    } else if role == "bar" { "legend-bar" } else {
      // A legend has no axis line, and no sub-decade tick tiers.
      none
    }
  }
}

// The surface a tick tier paints on, the cm it draws, and the cm between it and
// its label.
//
// In an axis context the length comes from the theme through the `tick-length`
// closure the context carries. In a legend context the theme surface carries no
// length, so the two constants above answer instead.
#let tick-metrics(gctx, tier: "major") = {
  let role = if tier == "major" { "ticks" } else { "ticks-" + tier }
  let surface = surface-for(gctx, role)
  // No surface means this context has no such tick: a legend has no sub-decade
  // tiers. Answer with nothing to draw, so a caller reading `len` reserves no
  // room for a tick that never appears.
  if surface == none { return (surface: none, len: 0.0, gap: 0.0) }
  if gctx.mode == "legend" {
    return (surface: surface, len: LEGEND-TICK-LEN, gap: LEGEND-TICK-GAP)
  }
  let resolve = gctx.at("tick-length", default: none)
  (
    surface: surface,
    len: if resolve == none { 0.0 } else { (resolve)(surface) },
    gap: gctx.tick-gap,
  )
}
