///! Deterministic density-shaped horizontal offsets.
///!
///! A quasirandom swarm: points at the same x spread sideways in proportion
///! to the local density of their y values, ordered by a van der Corput
///! sequence so the cloud fills evenly without a random number generator.
///! Renders are reproducible without a seed.

#import "../utils/types.typ": parse-number
#import "../utils/kde.typ": bw-nrd0

/// Density-shaped per-row offset on x.
///
/// For every bucket of rows sharing an x value, each point is offset sideways by `width × (2·v − 1) × d`, where `v` walks the van der Corput base-2 sequence in y order and `d` is the point's Gaussian kernel density estimate normalised to the bucket's peak. Dense regions spread wide, sparse tails stay close to the spine, and the result is a violin-shaped swarm.
///
/// A discrete (categorical) x is swarmed directly on its level positions, keeping the axis labels. `as-factor` is only needed to force a numeric column onto a discrete axis.
///
/// - width: Maximum absolute offset applied to the x position, in x data units.
/// - adjust: Bandwidth multiplier for the density estimate: `adjust: 0.5` halves the smoothing.
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
#let position-beeswarm(width: 0.4, adjust: 1) = (
  kind: "position",
  name: "beeswarm",
  params: (width: width, adjust: adjust),
)

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

#let apply(data, mapping, params: (:), coord: none) = {
  let width = params.at("width", default: 0.4)
  let adjust = params.at("adjust", default: 1)
  let x-col = mapping.at("x", default: none)
  let y-col = mapping.at("y", default: none)
  if x-col == none or y-col == none or width == 0 {
    return (data: data, mapping: mapping)
  }

  // Bucket row indices by their numeric x value; rows with a non-numeric x
  // (an unforced discrete level) pass through unchanged.
  let buckets = (:)
  for (i, row) in data.enumerate() {
    let xv = parse-number(row.at(x-col, default: none))
    let yv = parse-number(row.at(y-col, default: none))
    if xv == none or yv == none { continue }
    let key = str(xv)
    let bucket = buckets.at(key, default: ())
    bucket.push((i: i, y: yv))
    buckets.insert(key, bucket)
  }

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
      r.insert(x-col, parse-number(row.at(x-col)) + offset)
      r
    })
  (data: new-data, mapping: mapping)
}
