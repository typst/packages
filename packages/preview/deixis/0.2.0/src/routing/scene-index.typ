// Prepared open-interior interval indexes in unitless pt coordinates. A boundary
// is traversable at exact clearance. Touching intervals must remain separate:
// merging them would close a legitimate zero-width centerline corridor.
#let _deixis-union-intervals(intervals) = {
  let result = ()
  for interval in intervals.sorted(key: i => i.first()) {
    if result.len() > 0 and interval.first() < result.last().last() {
      result.last() = (result.last().first(), calc.max(result.last().last(), interval.last()))
    } else { result.push(interval) }
  }
  result
}

#let _deixis-scene-index(rectangles, vertical: false) = {
  let (a, b, c, d) = if vertical { ("left", "right", "top", "bottom") } else { ("top", "bottom", "left", "right") }
  let levels = rectangles.map(r => (r.at(a), r.at(b))).flatten().sorted().dedup()
  let line(at) = _deixis-union-intervals(rectangles.filter(r => r.at(a) < at and at < r.at(b)).map(r => (r.at(c), r.at(d))))
  (levels: levels, boundary: levels.map(line),
    slab: levels.windows(2).map(pair => line(pair.first() + (pair.last() - pair.first()) / 2)))
}

#let _deixis-index-intervals(index, coordinate) = {
  let lo = 0; let hi = index.levels.len()
  while lo < hi {
    let mid = calc.floor((lo + hi) / 2)
    if index.levels.at(mid) < coordinate { lo = mid + 1 } else { hi = mid }
  }
  if lo < index.levels.len() and index.levels.at(lo) == coordinate { index.boundary.at(lo) }
  else if lo > 0 and lo < index.levels.len() { index.slab.at(lo - 1) }
  else { () }
}

#let _deixis-index-blocked(index, coordinate, start, end) = {
  let intervals = _deixis-index-intervals(index, coordinate)
  let low = calc.min(start, end); let high = calc.max(start, end)
  // Find the first interval whose end exceeds low. Open ends allow touching.
  let lo = 0; let hi = intervals.len()
  while lo < hi {
    let mid = calc.floor((lo + hi) / 2)
    if intervals.at(mid).last() <= low { lo = mid + 1 } else { hi = mid }
  }
  lo < intervals.len() and intervals.at(lo).first() < high
}
