#import "paths.typ": add, sub, mul, distance
#let cross(a, b) = a.at(0)*b.at(1)-a.at(1)*b.at(0)
#let lengths(points) = {
  let values = (0,)
  for i in range(points.len()-1) { values.push(values.last()+distance(points.at(i), points.at(i+1))) }
  values
}
#let intersection(a, b, c, d) = {
  // Cheap bounds rejection before testing the actual sampled wave segments.
  if (calc.max(a.at(0), b.at(0)) < calc.min(c.at(0), d.at(0)) or calc.max(c.at(0), d.at(0)) < calc.min(a.at(0), b.at(0)) or
    calc.max(a.at(1), b.at(1)) < calc.min(c.at(1), d.at(1)) or calc.max(c.at(1), d.at(1)) < calc.min(a.at(1), b.at(1))) { return none }
  let r = sub(b, a)
  let s = sub(d, c)
  let denominator = cross(r, s)
  if calc.abs(denominator) < 0.0000000001 { return none }
  let delta = sub(c, a)
  let t = cross(delta, s)/denominator
  let u = cross(delta, r)/denominator
  if t >= 0 and t <= 1 and u >= 0 and u <= 1 {t} else {none}
}
#let merge-intervals(intervals) = {
  let merged = ()
  for interval in intervals.sorted(key: x => x.first()) {
    if merged.len() > 0 and interval.first() <= merged.last().last() {
      let previous = merged.pop()
      merged.push((previous.first(), calc.max(previous.last(), interval.last())))
    } else { merged.push(interval) }
  }
  merged
}
#let at-distance(points, ls, s) = {
  let j = ls.position(n => n > s)
  if j == none { return points.last() }
  let i = j - 1
  add(points.at(i), mul(sub(points.at(j), points.at(i)), (s - ls.at(i))/(ls.at(j)-ls.at(i))))
}
#let split-points(points, intervals) = {
  if intervals.len() == 0 { return (points,) }
  let ls = lengths(points)
  let start = 0
  let parts = ()
  for (lo, hi) in merge-intervals(intervals) + ((ls.last(), ls.last()),) {
    if lo > start + 0.00000001 {
      let inside = points.enumerate().filter(item => ls.at(item.first()) > start and ls.at(item.first()) < lo).map(item => item.last())
      parts.push((at-distance(points, ls, start),) + inside + (at-distance(points, ls, lo),))
    }
    start = hi
  }
  parts
}
// An opt-in wave/wave treatment. The lexically larger stable edge ID stays
// continuous. No paint/mask is emitted: the lower stroke has missing geometry.
#let crossing-parts(result, sampled, gap: 0) = {
  assert((type(gap) == int or type(gap) == float) and gap >= 0 and gap < calc.inf, message: "invalid crossing-gap")
  let cuts = (:)
  let waves = if gap == 0 {()} else {result.routes.filter(r => r.style.line == "wave" and r.arrow == "none").sorted(key: r => r.id)}
  for (index, lower) in waves.enumerate() {
    let p = sampled.at(lower.id)
    let ls = lengths(p)
    let intervals = ()
    for upper in waves.slice(index+1) {
      // Preserve vertex joins and parallel-edge endpoints; these are not bridges.
      if (lower.from, lower.to).any(id => (upper.from, upper.to).contains(id)) { continue }
      let q = sampled.at(upper.id)
      for i in range(p.len()-1) {
        for j in range(q.len()-1) {
          let t = intersection(p.at(i), p.at(i+1), q.at(j), q.at(j+1))
          if t != none {
            let location = add(p.at(i), mul(sub(p.at(i+1), p.at(i)), t))
            let near-vertex = result.vertices.any(v => distance(location, result.positions.at(v.id)) < v.size+gap)
            let s = ls.at(i)+t*(ls.at(i+1)-ls.at(i))
            if not near-vertex and s > gap and s + gap < ls.last() { intervals.push((s - gap, s + gap)) }
          }
        }
      }
    }
    cuts.insert(lower.id, merge-intervals(intervals))
  }
  let parts = (:)
  for route in result.routes { parts.insert(route.id, split-points(sampled.at(route.id), cuts.at(route.id, default: ()))) }
  parts
}
