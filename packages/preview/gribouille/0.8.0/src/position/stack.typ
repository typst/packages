///! Stack position adjustment.

#import "_cumulate.typ": cumulate-by-x
#import "../utils/radial.typ": is-radial
#import "../utils/errors.typ": fail, fail-enum

#let _OFFSETS = ("none", "silhouette", "wiggle")

// Streamgraph baseline per x bucket (Byron & Wattenberg 2008). `sorted`
// runs top-of-stack first, so the entry at 1-based index k carries
// bottom-to-top weight k: g0 = -(sum of k * y_k) / (n + 1) places the
// stack so the weighted wiggle of the layer boundaries is minimised.
#let _wiggle-base(sorted, tot) = {
  let weighted = 0.0
  for (k, e) in sorted.enumerate() {
    weighted += (k + 1) * e.y
  }
  -weighted / (sorted.len() + 1)
}

/// Stack position adjustment: cumulate y per x bucket.
///
/// Stacking is per x bucket across all groups. Rows are sorted by the grouping aesthetic so the first alphabetic level sits at the top of the bar in cartesian coords (legend top entry = top band). Under any `coord-radial` the cumulation flips so the first alphabetic level becomes the first slice clockwise from 12 o'clock.
///
/// Typically set on a layer as `position: "stack"` rather than constructed directly; construct it to pick a streamgraph `offset`.
///
/// - offset: Baseline offset per x bucket. `"none"` (default) stacks from zero. `"silhouette"` centres each stack on zero (ThemeRiver). `"wiggle"` places each stack at the Byron-Wattenberg baseline that minimises the weighted wiggle of the layer boundaries, the classic streamgraph look. Both shifted offsets suit `geom-area` over a continuous x; neither is supported under `coord-radial`.
///
/// Returns: Position dictionary with `name: "stack"`, consumed by `plot`.
///
/// See also: `position-dodge`, `position-fill`, `position-identity`.
///
/// Two groups stacked per quarter to show component contribution to a total.
///
/// ```typst
/// #let d = (
///   (q: "Q1", grp: "a", y: 3),
///   (q: "Q1", grp: "b", y: 5),
///   (q: "Q2", grp: "a", y: 4),
///   (q: "Q2", grp: "b", y: 2),
///   (q: "Q3", grp: "a", y: 6),
///   (q: "Q3", grp: "b", y: 4),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "q", y: "y", fill: "grp"),
///   layers: (geom-col(position: "stack"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Stacked area chart over time, useful when the running total itself is informative.
///
/// ```typst
/// #let d = ()
/// #for grp in ("a", "b", "c") {
///   for i in range(0, 10) {
///     d.push((x: i, y: i * 0.3 + (if grp == "b" { 1 } else if grp == "c" { 2 } else { 0 }), grp: grp))
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", fill: "grp"),
///   layers: (geom-area(position: "stack", alpha: 0.6),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Silhouette offset: each stack centred on zero (ThemeRiver).
///
/// ```typst
/// #let d = ()
/// #for (gi, grp) in ("a", "b", "c").enumerate() {
///   for i in range(0, 12) {
///     let wave = calc.sin(i * 0.55 + gi * 1.1) * (0.35 + gi * 0.2)
///     d.push((x: i, y: 1 + gi * 0.2 + wave, grp: grp))
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", fill: "grp"),
///   layers: (
///     geom-area(position: position-stack(offset: "silhouette")),
///   ),
///   width: 12cm,
///   height: 6cm,
/// )
/// ```
///
/// Wiggle offset: the baseline minimising boundary wiggle.
///
/// ```typst
/// #let d = ()
/// #for (gi, grp) in ("a", "b", "c").enumerate() {
///   for i in range(0, 12) {
///     let wave = calc.sin(i * 0.55 + gi * 1.1) * (0.35 + gi * 0.2)
///     d.push((x: i, y: 1 + gi * 0.2 + wave, grp: grp))
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", fill: "grp"),
///   layers: (
///     geom-area(position: position-stack(offset: "wiggle")),
///   ),
///   width: 12cm,
///   height: 6cm,
/// )
/// ```
#let position-stack(offset: "none") = {
  if offset not in _OFFSETS {
    fail-enum("position-stack", "offset", offset, _OFFSETS)
  }
  (kind: "position", name: "stack", params: (offset: offset))
}

#let apply(data, mapping, params: (:), coord: none) = {
  let offset = params.at("offset", default: "none")
  if offset not in _OFFSETS { offset = "none" }
  if is-radial(coord) {
    if offset != "none" {
      fail(
        "position-stack",
        "offset " + repr(offset) + " is not supported under coord-radial",
        hint: "A shifted baseline has no angular meaning; use the default offset: \"none\".",
      )
    }
    return cumulate-by-x(data, mapping, (cum, yv, tot) => (cum, cum + yv))
  }
  let shift = if offset == "silhouette" {
    (sorted, tot) => -tot / 2
  } else if offset == "wiggle" {
    _wiggle-base
  } else { none }
  cumulate-by-x(
    data,
    mapping,
    (cum, yv, tot) => (tot - cum - yv, tot - cum),
    shift: shift,
    drop-empty: offset != "none",
  )
}
