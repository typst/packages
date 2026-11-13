///! Band geometry: the symmetric per-axis band shared by boxplot,
///! errorbar(h), and crossbar, plus the filled ribbon polygon shared by
///! ribbon, area, and smooth.

#import "../scale/train.typ": discrete-slot-width, map-axis, map-position
#import "types.typ": parse-number
#import "../coord/project.typ": path-uvs, project-uvs
#import "flip.typ": user-point, user-stair-direction
#import "stair.typ": stair

/// Compute the panel coordinate range of a band centred on `raw`.
///
/// Axis-agnostic: `trained` and `range` may describe either x or y. For continuous scales the band edges are mapped through `map-axis` so the half-width is interpreted in data units and any `view-trans` expansion is honoured. For discrete scales the band is sized as a fraction of the per-category slot width, accounting for `view-index` expansion.
///
/// - trained: Trained scale dict for the axis the band runs along.
/// - raw: Row value at the band centre.
/// - half-width: Band half-width in data units (continuous) or as a fraction of the slot (discrete).
/// - range: Pair `(lo, hi)` giving the panel extent on the same axis.
///
/// Returns: Pair `(c-lo, c-hi)` of mapped band edges, or `none` when the centre cannot be mapped.
#let axis-band(trained, raw, half-width, range) = {
  if trained.type == "continuous" {
    let raw-num = parse-number(raw)
    if raw-num == none { return none }
    (
      map-axis(trained, raw-num - half-width, range),
      map-axis(trained, raw-num + half-width, range),
    )
  } else {
    let c = map-position(trained, raw, range)
    if c == none { return none }
    let half = discrete-slot-width(trained, range) * half-width
    (c - half, c + half)
  }
}

/// Build a closed filled-band polygon from points already sorted by x: the upper edge forward followed by the lower edge reversed. Under coord-flip the band runs along the vertical axis and spans the horizontal one. `hi`/`lo` read the upper/lower value off each point. The outline goes through the coord as one closed path, so under coord-radial both edges and the two edges that close the band follow the polar grid. A non-`none` `direction` (`"hv"` or `"vh"`) steps both edges into a staircase, leaving the closed shape intact.
///
/// - ctx: Per-draw context forwarded to `project-uvs`.
/// - sorted: Points sorted by x, each carrying an `x` field.
/// - hi: Accessor `p => value` for the upper edge.
/// - lo: Accessor `p => value` for the lower edge.
/// - direction: Stair direction `"hv"`/`"vh"`, or `none` for a smooth band.
///
/// Returns: Array of projected `(x, y)` points forming the closed polygon, or `none` when a point does not resolve.
#let band-polygon(ctx, sorted, hi, lo, direction: none) = {
  let upper = path-uvs(ctx, sorted.map(p => user-point(ctx, p.x, hi(p))))
  let lower = path-uvs(
    ctx,
    sorted.rev().map(p => user-point(ctx, p.x, lo(p))),
  )
  if upper.any(uv => uv == none) or lower.any(uv => uv == none) {
    return none
  }
  direction = user-stair-direction(direction, ctx)
  if direction != none {
    upper = stair(upper, direction)
    lower = stair(lower, direction)
  }
  project-uvs(ctx, upper + lower, closed: true)
}
