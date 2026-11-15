#import "lane-cost.typ": exposure, lane-total

// Exact directional rows for the actual search lattice. Preserve original lane
// order and clipping arithmetic: a prefix integral changes floating additions
// and can change A* ties. No midpoint samples or rounded coordinate keys.
// Build once per reservation snapshot, not once per direction/state/visit.
#let prepare-costs(lanes, spacing, xs, ys, min-lanes: 16, max-rows: 1024, max-checks: 32768, max-entries: 8192) = {
  assert((min-lanes, max-rows, max-checks, max-entries).all(v => type(v) == int and v >= 0))
  let fallback(reason, checks: 0, entries: 0) = (kind: "scan", reason: reason,
    lanes: lanes, spacing: spacing, checks: checks, entries: entries)
  if lanes.len() < min-lanes { return fallback("small") }
  if xs.len() + ys.len() > max-rows { return fallback("rows") }
  let axes = (lanes.filter(s => s.axis == 0), lanes.filter(s => s.axis == 1))
  let coordinates = (ys, xs)
  let checks = axes.at(0).len() * ys.len() + axes.at(1).len() * xs.len()
  if checks > max-checks { return fallback("checks") }
  let rows = (); let entries = 0
  for axis in (0, 1) {
    let lines = ()
    for fixed in coordinates.at(axis) {
      let active = axes.at(axis).filter(s => calc.abs(s.fixed - fixed) < spacing)
      entries += active.len()
      if entries > max-entries { return fallback("entries", checks: checks, entries: entries) }
      lines.push(active)
    }
    rows.push(lines)
  }
  (kind: "index", coordinates: coordinates, rows: rows, lanes: lanes, spacing: spacing,
    checks: checks, entries: entries)
}

#let indexed-exposure(a, b, index) = {
  if a == b { return 0 }
  if index.kind == "scan" { return exposure(a, b, index.lanes, index.spacing) }
  let axis = if a.last() == b.last() { 0 } else { 1 }
  let fixed = a.at(1 - axis)
  assert.eq(fixed, b.at(1 - axis))
  let values = index.coordinates.at(axis)
  let lo = 0; let hi = values.len()
  while lo < hi {
    let mid = calc.floor((lo + hi) / 2)
    if values.at(mid) < fixed { lo = mid + 1 } else { hi = mid }
  }
  // Mandatory stubs are normally on lattice lines. Retain an exact scanner for
  // any off-lattice call; the public geometry must never be snapped for cost.
  if lo == values.len() or values.at(lo) != fixed { return exposure(a, b, index.lanes, index.spacing) }
  lane-total(calc.min(a.at(axis), b.at(axis)), calc.max(a.at(axis), b.at(axis)), fixed,
    index.rows.at(axis).at(lo))
}
