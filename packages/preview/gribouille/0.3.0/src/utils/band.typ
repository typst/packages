///! Band geometry: the symmetric per-axis band shared by boxplot,
///! errorbar(h), and crossbar, plus the filled ribbon polygon shared by
///! ribbon, area, and smooth.

#import "../scale/train.typ": discrete-slot-width, map-axis, map-position
#import "types.typ": parse-number
#import "radial.typ": project-point

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

/// Build a closed filled-band polygon from points already sorted by x: the upper edge forward followed by the lower edge reversed. `hi`/`lo` read the upper/lower value off each point. Unmappable points project to `none` and pass through unchanged, so callers guard with `pts.any(p => p == none)`.
///
/// - ctx: Per-draw context forwarded to `project-point`.
/// - sorted: Points sorted by x, each carrying an `x` field.
/// - hi: Accessor `p => value` for the upper edge.
/// - lo: Accessor `p => value` for the lower edge.
///
/// Returns: Array of projected `(x, y)` points forming the closed polygon.
#let band-polygon(ctx, sorted, hi, lo) = {
  let upper = sorted.map(p => project-point(ctx, p.x, hi(p)))
  let lower = sorted.rev().map(p => project-point(ctx, p.x, lo(p)))
  upper + lower
}

