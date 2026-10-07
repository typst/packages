// Pure Typst numerical kernel; positions and velocities are unitless numbers.
#let _num(x) = type(x) in (int, float)
#let _state(s) = type(s) == array and s.len() == 4 and s.all(_num)
#let _point(p) = type(p) == array and p.len() == 2 and p.all(_num)
#let _add(a, b, scale: 1) = (a.at(0) + scale * b.at(0), a.at(1) + scale * b.at(1), a.at(2) + scale * b.at(2), a.at(3) + scale * b.at(3))
#let _interpolate(a, b, t) = _add(a, _add(b, a, scale: -1), scale: t)
#let _norm(v) = calc.sqrt(v.at(0) * v.at(0) + v.at(1) * v.at(1))

#let circle-terminator(center, radius, name: none) = {
  assert(_point(center) and _num(radius) and radius > 0, message: "fields: circle requires numeric centre and positive radius")
  assert(name == none or type(name) == str, message: "fields: terminator name must be a string")
  (before, after) => {
    assert(_state(before) and _state(after), message: "fields: terminator requires states")
    let dx = after.at(0) - before.at(0)
    let dy = after.at(1) - before.at(1)
    let ox = before.at(0) - center.at(0)
    let oy = before.at(1) - center.at(1)
    let a = dx * dx + dy * dy
    let c = ox * ox + oy * oy - radius * radius
    let t = none
    if c <= 0 { t = 0 }
    else if a > 0 {
      let b = 2 * (ox * dx + oy * dy)
      let discriminant = b * b - 4 * a * c
      if discriminant >= 0 {
        let first = (-b - calc.sqrt(discriminant)) / (2 * a)
        if first >= 0 and first <= 1 { t = first }
      }
    }
    if t == none { none } else { (at: t, state: _interpolate(before, after, t), name: name) }
  }
}

#let combine-terminators(..terminators) = {
  let terms = terminators.pos()
  assert(terms.all(t => type(t) == function), message: "fields: terminators must be functions")
  (before, after) => {
    let winner = none
    for t in terms {
      let result = t(before, after)
      if result != none and (winner == none or result.at("at") < winner.at("at")) { winner = result }
    }
    winner
  }
}

#let _boundary(a, b, domain) = {
  let (lo, hi) = domain
  let t = 1.0
  let crossing = false
  for axis in range(2) {
    let delta = b.at(axis) - a.at(axis)
    if b.at(axis) <= lo.at(axis) and a.at(axis) > lo.at(axis) and delta != 0 {
      t = calc.min(t, (lo.at(axis) - a.at(axis)) / delta)
      crossing = true
    }
    if b.at(axis) >= hi.at(axis) and a.at(axis) < hi.at(axis) and delta != 0 {
      t = calc.min(t, (hi.at(axis) - a.at(axis)) / delta)
      crossing = true
    }
  }
  if crossing { t } else { none }
}

#let new(fn) = {
  assert(type(fn) == function, message: "fields: vectorfield.new needs a function")
  (fn: fn)
}

#let sample(field, x, y) = {
  assert(type(field) == dictionary and "fn" in field and type(field.fn) == function,
    message: "fields: expected a vector field created by vectorfield.new")
  assert(_num(x) and _num(y), message: "fields: sample position must be numeric")
  let value = (field.fn)(x, y)
  assert(_point(value), message: "fields: field must return a numeric pair")
  value
}

#let _integrate(field, x, y, vx, vy, mode, reverse, step, max-steps, domain, terminate, min-field) = {
    assert(_state((x, y, vx, vy)), message: "fields: initial state must be numeric")
    assert(_num(step) and step > 0 and type(max-steps) == int and max-steps > 0,
      message: "fields: step and max-steps must be positive")
    assert(terminate == none or type(terminate) == function, message: "fields: terminate must be a function")
    if domain != none {
      assert(type(domain) == array and domain.len() == 2 and domain.all(_point),
        message: "fields: numeric domain must contain two 2D corners")
      let (lo, hi) = domain
      assert(lo.at(0) < hi.at(0) and lo.at(1) < hi.at(1) and x >= lo.at(0) and x <= hi.at(0) and y >= lo.at(1) and y <= hi.at(1),
        message: "fields: invalid domain or origin outside domain")
    }
    let direction = (s) => {
      let f = sample(field, s.at(0), s.at(1))
      if mode == "trajectory" { return (s.at(2), s.at(3), f.at(0), f.at(1)) }
      let mag = _norm(f)
      if mag < min-field { return none }
      let sign = if reverse { -1 } else { 1 }
      (sign * f.at(0) / mag, sign * f.at(1) / mag, 0, 0)
    }
    let initial = if mode == "streamline" {
      let f = sample(field, x, y)
      (x, y, f.at(0), f.at(1))
    } else { (x, y, vx, vy) }
    let points = (initial,)
    let reason = "max-steps"
    let hit = none
    for _ in range(max-steps) {
      let current = points.last()
      let k1 = direction(current)
      if k1 == none { reason = "null"; break }
      let k2 = direction(_add(current, k1, scale: step / 2))
      if k2 == none { reason = "null"; break }
      let k3 = direction(_add(current, k2, scale: step / 2))
      if k3 == none { reason = "null"; break }
      let k4 = direction(_add(current, k3, scale: step))
      if k4 == none { reason = "null"; break }
      let weighted = _add(_add(k1, k2, scale: 2), _add(k3, k4, scale: 0.5), scale: 2) // k1+2k2+2k3+k4
      let next = _add(current, weighted, scale: step / 6)
      if mode == "streamline" {
        let f = sample(field, next.at(0), next.at(1))
        next = (next.at(0), next.at(1), f.at(0), f.at(1))
      }
      let boundary = if domain == none { none } else { _boundary(current, next, domain) }
      let result = if terminate == none { none } else { terminate(current, next) }
      if result != none {
        assert(type(result) == dictionary and "at" in result and "state" in result and _num(result.at("at")) and result.at("at") >= 0 and result.at("at") <= 1 and _state(result.state),
          message: "fields: terminator must return (at: t, state: (x, y, vx, vy))")
      }
      if boundary != none and (result == none or boundary <= result.at("at")) {
        let clipped = _interpolate(current, next, boundary)
        if mode == "streamline" {
          let f = sample(field, clipped.at(0), clipped.at(1))
          clipped = (clipped.at(0), clipped.at(1), f.at(0), f.at(1))
        }
        points.push(clipped)
        reason = "boundary"
        break
      }
      if result != none {
        let snapped = result.state
        if mode == "streamline" {
          let f = sample(field, snapped.at(0), snapped.at(1))
          snapped = (snapped.at(0), snapped.at(1), f.at(0), f.at(1))
        }
        points.push(snapped)
        reason = "terminated"
        hit = result.at("name", default: none)
        break
      }
      points.push(next)
    }
  (points: points, reason: reason, hit: hit)
}

#let streamline(field, x, y, reverse: false, step: 0.07, max-steps: 900, domain: none, terminate: none, min-field: 1e-14) = {
  assert(_num(min-field) and min-field > 0, message: "fields: min-field must be positive")
  _integrate(field, x, y, 0, 0, "streamline", reverse, step, max-steps, domain, terminate, min-field)
}

#let trajectory(field, x, y, vx: 0, vy: 0, step: 0.07, max-steps: 900, domain: none, terminate: none) = {
  _integrate(field, x, y, vx, vy, "trajectory", false, step, max-steps, domain, terminate, 0)
}

