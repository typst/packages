///! Align groups onto a shared x-grid for stacked area / ribbon use.
///!
///! Mirrors plotnine's `stat_align`. Each group's y is linearly
///! interpolated onto the union of every group's x values plus the
///! zero-crossings detected within each group, so stacked layers share
///! clean vertices at every break.

#import "../utils/types.typ": parse-number
#import "../utils/group.typ": partition-by-group
#import "../utils/resolution.typ": resolution

#let _ZERO-CROSSING-FRACTION = 0.001

// Parse, drop NA, sort by x. Duplicate-x rows are collapsed to one entry
// per x with the mean y; matches `approx(ties = "ordered" / "mean")`
// semantics so subsequent interpolation cannot silently drop a row.
#let _parsed-pairs(data, x-col, y-col) = {
  let parsed = data
    .map(r => {
      let xv = parse-number(r.at(x-col, default: none))
      let yv = parse-number(r.at(y-col, default: none))
      if xv == none or yv == none { return none }
      (x: xv, y: yv, row: r)
    })
    .filter(p => p != none)
    .sorted(key: p => p.x)
  if parsed.len() < 2 { return parsed }

  let collapsed = ()
  let i = 0
  while i < parsed.len() {
    let cur = parsed.at(i)
    let j = i + 1
    let sum = cur.y
    let count = 1
    while j < parsed.len() and parsed.at(j).x == cur.x {
      sum += parsed.at(j).y
      count += 1
      j += 1
    }
    if count == 1 {
      collapsed.push(cur)
    } else {
      collapsed.push((x: cur.x, y: sum / count, row: cur.row))
    }
    i = j
  }
  collapsed
}

#let _zero-crossings-for-group(pairs) = {
  let crossings = ()
  for i in range(1, pairs.len()) {
    let a = pairs.at(i - 1)
    let b = pairs.at(i)
    if (a.y < 0) != (b.y < 0) {
      let dy = b.y - a.y
      if dy != 0 {
        crossings.push(a.x - a.y * (b.x - a.x) / dy)
      }
    }
  }
  crossings
}

/// Align statistic: resample each group onto a shared x-grid.
///
/// Builds the union of every group's x values plus zero-crossings within each group, deduped and sorted. Each group's y is linearly interpolated onto that grid; rows outside a group's input range are dropped, and the trimmed extremes are padded with `y = 0` so stacked areas join cleanly between groups.
///
/// Returns: Statistic object with `name: "align"`, consumed by geom layers.
///
/// See also: `geom-area`, `geom-ribbon`, `stat-identity`.
///
/// Two groups with mismatched x sampled onto a stacked area.
///
/// ```typst
/// #let d = (
///   (x: 0, y: 1, k: "a"), (x: 2, y: 3, k: "a"), (x: 4, y: 2, k: "a"),
///   (x: 1, y: 2, k: "b"), (x: 3, y: 1, k: "b"), (x: 5, y: 4, k: "b"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", fill: "k"),
///   layers: (geom-area(stat: stat-align(), position: "stack"),),
///   width: 12cm,
///   height: 6cm,
/// )
/// ```
#let stat-align() = (kind: "stat", name: "align", params: (:))

// Panel-level setup: compute the union x-grid + adjust offset once and
// thread them through to per-group apply() via params.
#let setup(data, mapping, params: (:)) = {
  if mapping == none { return params }
  let x-col = mapping.at("x", default: none)
  let y-col = mapping.at("y", default: none)
  if x-col == none or y-col == none { return params }

  let xs = ()
  let crossings = ()
  for g in partition-by-group(data, mapping) {
    let pairs = _parsed-pairs(g.data, x-col, y-col)
    for p in pairs { xs.push(p.x) }
    for c in _zero-crossings-for-group(pairs) { crossings.push(c) }
  }
  if xs.len() == 0 { return params }

  let unique-loc = (xs + crossings).dedup().sorted()
  let lo = unique-loc.first()
  let hi = unique-loc.last()
  // adjust: a small offset used for the leading/trailing zero-pad rows so
  // stacked areas join cleanly without overlapping the first/last x. Bound
  // it at one third of the smallest gap to avoid the pad colliding with a
  // neighbouring location.
  let adjust = (hi - lo) * _ZERO-CROSSING-FRACTION
  let diff = resolution(unique-loc, zero: false)
  if diff > 0 and diff / 3 < adjust { adjust = diff / 3 }

  // Expand the grid with a tiny offset on either side of every breakpoint
  // (`loc - adjust`, `loc`, `loc + adjust`). A group that starts or ends
  // mid-range then gains a baseline vertex just before its first point and
  // just after its last, so a neighbouring group steps cleanly down to zero
  // instead of rising diagonally toward that group's first vertex.
  let expanded = ()
  for loc in unique-loc {
    expanded.push(loc - adjust)
    expanded.push(loc)
    expanded.push(loc + adjust)
  }
  unique-loc = expanded.dedup().sorted()

  let out = params
  out.insert("unique-loc", unique-loc)
  out.insert("adjust", adjust)
  out
}

#let apply(data, mapping, params: (:)) = {
  if mapping == none { return (data: data, mapping: mapping) }
  let x-col = mapping.at("x", default: none)
  let y-col = mapping.at("y", default: none)
  let unique-loc = params.at("unique-loc", default: ())
  let adjust = params.at("adjust", default: 0)
  if x-col == none or y-col == none or unique-loc.len() == 0 {
    return (data: data, mapping: mapping)
  }

  let pairs = _parsed-pairs(data, x-col, y-col)
  if pairs.len() < 2 {
    return (data: pairs.map(p => p.row), mapping: mapping)
  }

  let x-min = pairs.first().x
  let x-max = pairs.last().x
  let n = pairs.len()
  // pi is a sweep index over `pairs`, advanced monotonically as `loc`
  // increases. Both arrays are sorted by x, so the merge-walk is O(loc + n).
  let pi = 0
  let interpolated = ()
  for loc in unique-loc {
    if loc < x-min or loc > x-max { continue }
    while pi + 1 < n and pairs.at(pi + 1).x <= loc { pi += 1 }
    let a = pairs.at(pi)
    let yv = if a.x == loc or pi + 1 >= n {
      a.y
    } else {
      let b = pairs.at(pi + 1)
      let t = (loc - a.x) / (b.x - a.x)
      a.y + (b.y - a.y) * t
    }
    interpolated.push(a.row + ((x-col): loc, (y-col): yv))
  }

  if interpolated.len() == 0 { return (data: (), mapping: mapping) }

  let head-row = pairs.first().row
  let tail-row = pairs.last().row
  let leading = (
    head-row + ((x-col): interpolated.first().at(x-col) - adjust, (y-col): 0)
  )
  let trailing = (
    tail-row + ((x-col): interpolated.last().at(x-col) + adjust, (y-col): 0)
  )
  (data: (leading,) + interpolated + (trailing,), mapping: mapping)
}
