///! Symmetric per-axis band shared by boxplot, errorbar(h), crossbar.

#import "../scale/train.typ": discrete-slot-width, map-axis, map-position
#import "types.typ": parse-number

/// Compute the panel coordinate range of a band centred on `raw`.
///
/// Axis-agnostic: `trained` and `range` may describe either x or y. For
/// continuous scales the band edges are mapped through `map-axis` so the
/// half-width is interpreted in data units and any `view-trans` expansion
/// is honoured. For discrete scales the band is sized as a fraction of the
/// per-category slot width, accounting for `view-index` expansion.
///
/// \@internal
///
/// \@param trained Trained scale dict for the axis the band runs along.
///
/// \@param raw Row value at the band centre.
///
/// \@param half-width Band half-width in data units (continuous) or as a fraction of the slot (discrete).
///
/// \@param range Pair `(lo, hi)` giving the panel extent on the same axis.
///
/// \@returns Pair `(c-lo, c-hi)` of mapped band edges, or `none` when the centre cannot be mapped.
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

