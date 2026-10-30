// Centerline policy. These are not stroke/head envelopes.
// Each lane is one prior shaft interval: axis, fixed coordinate, low/high.
#let lane-total(low, high, fixed, lanes) = lanes.map(s => {
  let l = calc.max(low, s.low); let h = calc.min(high, s.high)
  let shared = if s.fixed != fixed { 0 } else {
    s.at("exempt", default: ()).map(e => calc.max(0, calc.min(h, e.high) - calc.max(l, e.low))).sum(default: 0)
  }
  calc.max(0, h - l - shared)
}).sum(default: 0)

#let exposure(a, b, lanes, spacing) = {
  if a == b { return 0 }
  let axis = if a.last() == b.last() { 0 } else { 1 }
  assert(a.at(1 - axis) == b.at(1 - axis))
  let low = calc.min(a.at(axis), b.at(axis))
  let high = calc.max(a.at(axis), b.at(axis))
  lane-total(low, high, a.at(1 - axis),
    lanes.filter(s => s.axis == axis and calc.abs(s.fixed - a.at(1 - axis)) < spacing))
}

#let tracks(lanes, spacing) = {
  let xs = (); let ys = ()
  for s in lanes {
    if s.axis == 0 {
      xs += (s.low, s.high)
      xs += s.at("exempt", default: ()).map(e => (e.low, e.high)).flatten()
      ys += (s.fixed - spacing, s.fixed, s.fixed + spacing)
    } else {
      xs += (s.fixed - spacing, s.fixed, s.fixed + spacing)
      ys += (s.low, s.high)
      ys += s.at("exempt", default: ()).map(e => (e.low, e.high)).flatten()
    }
  }
  (xs, ys)
}

#let reserve(points) = {
  let segments = points.windows(2).filter(pair => pair.first() != pair.last()).map(((a, b)) => {
    let axis = if a.last() == b.last() { 0 } else { 1 }
    assert(a.at(1 - axis) == b.at(1 - axis))
    (axis: axis, fixed: a.at(1 - axis), low: calc.min(a.at(axis), b.at(axis)), high: calc.max(a.at(axis), b.at(axis)))
  }).sorted(key: s => (s.axis, s.fixed, s.low, s.high))
  let merged = ()
  for s in segments {
    if merged.len() > 0 and merged.last().axis == s.axis and merged.last().fixed == s.fixed and s.low <= merged.last().high {
      merged.last().high = calc.max(merged.last().high, s.high)
    } else { merged.push(s) }
  }
  merged
}
