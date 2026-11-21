///! Deterministic density-shaped offsets.
///!
///! A quasirandom swarm: points at the same x spread sideways in proportion
///! to the local density of their y values, ordered by a van der Corput
///! sequence so the cloud fills evenly without a random number generator.
///! With `orientation: "y"`, points at the same y spread up and down instead,
///! in proportion to the density of their x values.
///! Renders are reproducible without a seed.

#import "../utils/errors.typ": assert-number, fail, fail-enum
#import "../utils/bucket.typ": bucket-dict
#import "../utils/types.typ": parse-number
#import "../utils/kde.typ": bw-nrd0

/// Density-shaped per-row offset on x, or on y with `orientation: "y"`.
///
/// For every bucket of rows sharing a swarm-axis value (x by default), each point is offset along that axis by `width × (2·v − 1) × d`, where `v` walks the van der Corput base-2 sequence in value order and `d` is the point's Gaussian kernel density estimate normalised to the bucket's peak. Dense regions spread wide, sparse tails stay close to the spine, and the result is a violin-shaped swarm.
///
/// A discrete (categorical) x is swarmed directly on its level positions, keeping the axis labels. `as-factor` is only needed to force a numeric column onto a discrete axis.
///
/// - width: Maximum absolute offset applied along the swarm axis, in that axis's data units.
/// - adjust: Bandwidth multiplier for the density estimate, greater than `0`: `adjust: 0.5` halves the smoothing.
/// - orientation: Axis the swarm spreads along: `"x"`, `"y"`, or `auto`. `auto` picks `"y"` when only the y axis is discrete, and `"x"` otherwise.
/// - method: `"quasirandom"` (default) spreads points by local density. `"center"` bins the value axis and stacks the points of each bin side by side, centred on the row, so the width of a stack shows the number of points. `width` caps nothing under `"center"`.
/// - binwidth: `"center"` only. Size of a bin on the value axis, in data units. `auto` is the range of the value column over the layer divided by 30, or 1 when the range is 0. Bins are centred on multiples of `binwidth`, starting from 0. Each point moves to the nearest multiple, so a value already on that grid does not move.
/// - spacing: `"center"` only. Distance between neighbouring points of a stack, in data units of the swarm axis, the same for every row. `auto` is `width / 10`, which keeps points of the default size apart on a panel of ordinary size.
///
/// Returns: Position dictionary with `name: "beeswarm"`, consumed by `plot`.
///
/// See also: `position-jitter`, `geom-beeswarm`.
///
/// Swarm overplotted points per group; a tighter `width` keeps the cloud close to its spine.
///
/// ```typst
/// #let d = ()
/// #for grp in ("a", "b") {
///   for i in range(0, 50) {
///     d.push((grp: grp, y: calc.sin(i * 0.7) + calc.sin(i * 1.9) + (if grp == "b" { 4 } else { 0 })))
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: as-factor("grp"), y: "y"),
///   layers: (geom-point(size: 2pt, position: position-beeswarm(width: 0.25)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// A discrete y axis swarms up and down around each level:
///
/// ```typst
/// #let d = ()
/// #for grp in ("a", "b") {
///   for i in range(0, 50) {
///     d.push((grp: grp, x: calc.sin(i * 0.7) + calc.sin(i * 1.9) + (if grp == "b" { 4 } else { 0 })))
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: as-factor("grp")),
///   layers: (geom-point(size: 2pt, position: position-beeswarm(width: 0.25)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Count-based stacks: each row grows wider with its number of points.
///
/// ```typst
/// #let d = ()
/// #for i in range(0, 40) { d.push((grp: "a", y: calc.rem(i * 7, 11))) }
/// #for i in range(0, 12) { d.push((grp: "b", y: calc.rem(i * 5, 11))) }
/// #plot(
///   data: d,
///   mapping: aes(x: as-factor("grp"), y: "y"),
///   layers: (geom-point(size: 2pt, position: position-beeswarm(method: "center", binwidth: 1)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let position-beeswarm(
  width: 0.4,
  adjust: 1,
  orientation: auto,
  method: "quasirandom",
  binwidth: auto,
  spacing: auto,
) = {
  assert-number("position-beeswarm", "width", width, min: 0)
  assert-number("position-beeswarm", "adjust", adjust, positive: true)
  if orientation not in (auto, "x", "y") {
    fail-enum(
      "position-beeswarm",
      "orientation",
      orientation,
      ("x", "y"),
      hint: "Use `auto` to pick the swarm axis from the discrete scale.",
    )
  }
  if method not in ("quasirandom", "center") {
    fail-enum(
      "position-beeswarm",
      "method",
      method,
      ("quasirandom", "center"),
    )
  }
  if binwidth != auto {
    assert-number("position-beeswarm", "binwidth", binwidth, positive: true)
  }
  if spacing != auto {
    assert-number("position-beeswarm", "spacing", spacing, positive: true)
  }
  if method == "center" and adjust != 1 {
    fail(
      "position-beeswarm",
      "adjust applies to method \"quasirandom\" only; got method \"center\"",
      hint: "Use `binwidth` and `spacing` with \"center\", or set `method: \"quasirandom\"`.",
    )
  }
  if method == "center" and width == 0 and spacing == auto {
    fail(
      "position-beeswarm",
      "spacing is auto and width is 0, so stacks have no step; got method \"center\"",
      hint: "Set `spacing`, because `auto` is `width / 10`.",
    )
  }
  if method == "quasirandom" and (binwidth != auto or spacing != auto) {
    fail(
      "position-beeswarm",
      "binwidth and spacing apply to method \"center\" only; got method \"quasirandom\"",
      hint: "Set `method: \"center\"`, or remove `binwidth` and `spacing`.",
    )
  }
  (
    kind: "position",
    name: "beeswarm",
    params: (
      width: width,
      adjust: adjust,
      orientation: orientation,
      method: method,
      binwidth: binwidth,
      spacing: spacing,
    ),
  )
}

// Van der Corput base-2 value for a 1-indexed rank: the bit-reversed
// fraction (1 → 0.5, 2 → 0.25, 3 → 0.75, ...), which spreads consecutive
// ranks evenly across (0, 1).
#let _van-der-corput(n) = {
  let value = 0.0
  let denom = 1.0
  let rest = n
  while rest > 0 {
    denom *= 2
    value += calc.rem(rest, 2) / denom
    rest = calc.floor(rest / 2)
  }
  value
}

// An explicit orientation wins. `auto` swarms along y only when y is the sole
// discrete axis.
#let _resolve-orientation(orientation, discrete-axes) = {
  if orientation != auto { return orientation }
  if "y" in discrete-axes and "x" not in discrete-axes { "y" } else { "x" }
}

// Offsets for the `n` points of one bin, in value order: 0, s, -s, 2s, -2s, ...
// for an odd count and s/2, -s/2, 3s/2, -3s/2, ... for an even count, so the
// stack stays centred on the row.
#let _center-offsets(n, spacing) = {
  range(n).map(k => {
    let step = if calc.odd(n) { calc.ceil(k / 2) } else {
      calc.floor(k / 2) + 0.5
    }
    let sign = if calc.odd(n) {
      if calc.odd(k) { 1 } else { -1 }
    } else if calc.even(k) {
      1
    } else {
      -1
    }
    sign * step * spacing
  })
}

// Count-based swarm: bin the value axis on a grid of `binwidth` anchored at 0,
// move each point to its nearest grid value,
// and stack the points of a bin side by side around the row.
#let _apply-center(data, mapping, placed, swarm-col, value-col, params) = {
  if placed.len() == 0 { return (data: data, mapping: mapping) }
  let width = params.at("width", default: 0.4)
  let values = placed.map(e => e.y)
  let lo = calc.min(..values)
  let span = calc.max(..values) - lo
  let binwidth = params.at("binwidth", default: auto)
  if binwidth == auto { binwidth = if span == 0 { 1 } else { span / 30 } }
  let spacing = params.at("spacing", default: auto)
  if spacing == auto { spacing = width / 10 }

  let binned = placed.map(e => (
    ..e,
    bin: int(calc.round(e.y / binwidth)),
  ))
  let buckets = bucket-dict(binned, e => str(e.x) + "|" + str(e.bin))
  let moved = (:)
  for bucket in buckets.values() {
    let ordered = bucket.sorted(key: e => e.y)
    let offsets = _center-offsets(ordered.len(), spacing)
    for (e, offset) in ordered.zip(offsets) {
      moved.insert(str(e.i), (
        x: e.x + offset,
        y: e.bin * binwidth,
      ))
    }
  }
  let new-data = data
    .enumerate()
    .map(((i, row)) => {
      let m = moved.at(str(i), default: none)
      if m == none { return row }
      let r = row
      r.insert(swarm-col, m.x)
      r.insert(value-col, m.y)
      r
    })
  (data: new-data, mapping: mapping)
}

#let apply(data, mapping, params: (:), coord: none) = {
  let width = params.at("width", default: 0.4)
  let adjust = params.at("adjust", default: 1)
  let method = params.at("method", default: "quasirandom")
  let orientation = _resolve-orientation(
    params.at("orientation", default: auto),
    params.at("discrete-axes", default: ()),
  )
  let (swarm, value) = if orientation == "y" { ("y", "x") } else { ("x", "y") }
  let swarm-col = mapping.at(swarm, default: none)
  let value-col = mapping.at(value, default: none)
  let inert = width == 0 and method != "center"
  if swarm-col == none or value-col == none or inert {
    return (data: data, mapping: mapping)
  }

  // Bucket row indices by their numeric swarm value; rows with a non-numeric
  // swarm value (an unforced discrete level) pass through unchanged.
  // One pass to drop the rows with no position, one to bucket what is left by
  // the slot they share.
  let placed = data
    .enumerate()
    .map(((i, row)) => (
      i: i,
      x: parse-number(row.at(swarm-col, default: none)),
      y: parse-number(row.at(value-col, default: none)),
    ))
    .filter(e => e.x != none and e.y != none)
  if method == "center" {
    return _apply-center(data, mapping, placed, swarm-col, value-col, params)
  }
  let buckets = bucket-dict(placed, e => str(e.x))

  let offsets = (:)
  for (key, bucket) in buckets.pairs() {
    if bucket.len() < 2 {
      for e in bucket { offsets.insert(str(e.i), 0.0) }
      continue
    }
    let ys = bucket.map(e => e.y)
    let bw = bw-nrd0(ys) * adjust
    // Unnormalised Gaussian kernel sums: each offset scales a point's density
    // by the bucket peak, so the 1/(n·bw·√(2π)) density constant cancels.
    let densities = ys.map(y => (
      ys
        .map(v => {
          let z = (y - v) / bw
          calc.exp(-0.5 * z * z)
        })
        .sum()
    ))
    let peak = calc.max(..densities)
    // Rank in y order (stable: ties keep input order) drives the van der
    // Corput walk so neighbouring values land on opposite sides.
    let by-y = range(bucket.len()).sorted(key: j => bucket.at(j).y)
    for (rank, j) in by-y.enumerate() {
      let offset = (
        width * (2 * _van-der-corput(rank + 1) - 1) * densities.at(j) / peak
      )
      offsets.insert(str(bucket.at(j).i), offset)
    }
  }

  let new-data = data
    .enumerate()
    .map(((i, row)) => {
      let offset = offsets.at(str(i), default: none)
      if offset == none { return row }
      let r = row
      r.insert(swarm-col, parse-number(row.at(swarm-col)) + offset)
      r
    })
  (data: new-data, mapping: mapping)
}
