#import "geometry.typ": _deixis-sub, _deixis-add, _deixis-scale, _deixis-distance, _deixis-cubic

// Open Hobby interpolation, uniform positive tension on both ends of each
// segment. The mock-curvature angle system is solved before cubic velocities.
// Independent derivation/oracle: develop/hobby, MetaPost's double-number engine.
#let _deixis-hobby-cmds(vertices, tension: 1, curl: (mark: 1, body: 1),
  source-dir: "none", target-dir: "none", source-normal: auto, target-normal: auto,
) = {
  let points = ()
  for p in vertices { if points.len() == 0 or points.last() != p { points.push(p) } }
  if points.len() < 2 { return () }
  let n = points.len() - 1
  let chords = points.windows(2).map(pair => _deixis-sub(pair.last(), pair.first()))
  let lengths = points.windows(2).map(pair => _deixis-distance(..pair))
  let bearing(v) = calc.atan2(v.first(), v.last()).rad()
  let headings = chords.map(v => bearing(v.map(x => x / 1pt)))
  let wrap(x) = {
    // Given directions retain the sign at +/-pi. Turning-angle ties use +pi.
    while x < -calc.pi { x += 2 * calc.pi }
    while x > calc.pi { x -= 2 * calc.pi }
    x
  }
  let turns = (0,) + headings.windows(2).map(pair => {
    let turn = wrap(pair.last() - pair.first())
    if turn == -calc.pi { calc.pi } else { turn }
  }) + (0,)
  let direction(normal, axis, chord, terminal: false) = {
    if normal != auto and normal != (0, 0) {
      return if terminal { normal.map(x => -x) } else { normal }
    }
    if axis == "none" { return none }
    let index = if axis == "horizontal" { 0 } else { 1 }
    let sign = if chord.at(index) < 0pt { -1 } else { 1 }
    if index == 0 { (sign, 0) } else { (0, sign) }
  }
  let source = direction(source-normal, source-dir, chords.first())
  let target = direction(target-normal, target-dir, chords.last(), terminal: true)
  let inv = 1 / tension
  let q = 3 - inv
  let lower = (0,) * (n + 1)
  let diagonal = lower
  let upper = lower
  let rhs = lower
  // Scale each interior equation by the adjacent harmonic distance. This is
  // equivalent to inverse-chord weights without a unit-dependent epsilon.
  for i in range(1, n) {
    let weight = lengths.at(i) / (lengths.at(i - 1) + lengths.at(i))
    lower.at(i) = inv * weight
    diagonal.at(i) = q
    upper.at(i) = inv * (1 - weight)
    rhs.at(i) = -q * weight * turns.at(i) - upper.at(i) * turns.at(i + 1)
  }
  for (index, omega, fixed, heading) in ((0, curl.mark, source, headings.first()), (n, curl.body, target, headings.last())) {
    if fixed != none {
      diagonal.at(index) = 1
      rhs.at(index) = wrap(bearing(fixed) - heading)
    } else {
      // Normalize curl before multiplication to avoid overflow for large curls.
      let scale = calc.max(1, omega)
      diagonal.at(index) = 3 / scale + inv * (omega / scale - 1 / scale)
      let off = 3 * (omega / scale) + inv * (1 / scale - omega / scale)
      if index == 0 { upper.at(0) = off; rhs.at(0) = -off * turns.at(1) }
      else { lower.at(n) = off }
    }
  }
  let angles = (0,) * (n + 1)
  // Two free endpoints determine a straight segment; its curl system can be
  // singular (notably curl=1 at both ends). Do not manufacture a tiny loop.
  if not (n == 1 and source == none and target == none) {
    let check(value) = assert(value == value and value > 0 and value < calc.inf,
      message: "deixis: Hobby boundary conditions are numerically singular; reduce tension/curl or choose endpoint directions.")
    for i in range(1, n + 1) {
      check(diagonal.at(i - 1))
      let ratio = lower.at(i) / diagonal.at(i - 1)
      diagonal.at(i) -= ratio * upper.at(i - 1)
      rhs.at(i) -= ratio * rhs.at(i - 1)
    }
    check(diagonal.last())
    angles.at(n) = rhs.last() / diagonal.last()
    for i in range(n).rev() { angles.at(i) = (rhs.at(i) - upper.at(i) * angles.at(i + 1)) / diagonal.at(i) }
    assert(angles.all(x => x == x and calc.abs(x) < calc.inf),
      message: "deixis: Hobby boundary conditions are not numerically representable; reduce tension/curl or choose endpoint directions.")
  }
  let speed(a, b) = {
    let sa = calc.sin(a * 1rad); let sb = calc.sin(b * 1rad)
    let ca = calc.cos(a * 1rad); let cb = calc.cos(b * 1rad)
    let numerator = 2 + calc.sqrt(2) * (sa - sb / 16) * (sb - sa / 16) * (ca - cb)
    let denominator = 3 * (1 + (calc.sqrt(5) - 1) / 2 * ca + (3 - calc.sqrt(5)) / 2 * cb)
    // MetaPost's finite velocity bound applies after tension: at most four
    // chord lengths. Opposed endpoint directions can still backtrack or loop.
    if denominator <= 0 { 4 } else { calc.min(4, (numerator / denominator) * inv) }
  }
  let unit(a) = (calc.cos(a * 1rad), calc.sin(a * 1rad))
  range(n).map(i => {
    let a = angles.at(i)
    let b = -angles.at(i + 1) - turns.at(i + 1)
    let departure = if i == 0 and source != none { source } else { unit(headings.at(i) + a) }
    let arrival = if i == n - 1 and target != none { target } else { unit(headings.at(i) - b) }
    _deixis-cubic(_deixis-add(points.at(i), _deixis-scale(departure, lengths.at(i) * speed(a, b))),
      _deixis-sub(points.at(i + 1), _deixis-scale(arrival, lengths.at(i) * speed(b, a))), points.at(i + 1))
  })
}
