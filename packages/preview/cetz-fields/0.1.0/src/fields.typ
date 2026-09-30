#import "@preview/cetz:0.5.2"

#let _vadd(a, b) = (a.at(0) + b.at(0), a.at(1) + b.at(1), 0.0)
#let _vscale(a, s) = (a.at(0) * s, a.at(1) * s, 0.0)
#let _norm(a) = calc.sqrt(a.at(0) * a.at(0) + a.at(1) * a.at(1))
#let _distance(a, b) = _norm((a.at(0) - b.at(0), a.at(1) - b.at(1)))

#let _vector-length(magnitude, mode, scale, min-length, max-length) = {
  let raw = if mode == "saturating" {
    max-length * (1 - calc.exp(-scale * magnitude))
  } else if mode == "linear" {
    scale * magnitude
  } else if mode == "sqrt" {
    scale * calc.sqrt(magnitude)
  } else if mode == "log" {
    scale * calc.ln(1 + magnitude)
  } else {
    // "normalized": communicate direction only.
    max-length
  }
  calc.max(min-length, calc.min(max-length, raw))
}

#let _charge-value(c) = {
  assert(type(c) == dictionary, message: "fields: every charge must be a dictionary")
  assert("position" in c, message: "fields: a charge is missing `position`")
  assert("charge" in c or "q" in c, message: "fields: a charge is missing `charge`")
  let q = c.at("charge", default: c.at("q", default: 0))
  assert(type(q) in (int, float), message: "fields: charge values must be numbers")
  q
}

#let _inside(p, domain) = {
  let ((xmin, xmax), (ymin, ymax)) = domain
  p.at(0) >= xmin and p.at(0) <= xmax and p.at(1) >= ymin and p.at(1) <= ymax
}

#let _validate-domain(domain) = {
  assert(type(domain) == array and domain.len() == 2 and domain.all(v => type(v) == array and v.len() == 2),
    message: "fields: domain must be ((x-min, x-max), (y-min, y-max))")
  let ((xmin, xmax), (ymin, ymax)) = domain
  assert(xmin < xmax and ymin < ymax, message: "fields: domain bounds must be increasing")
}

// Compute E = sum(q (r-r_i) / |r-r_i|^3), omitting singular terms.
// Positions passed to this standalone helper must be numeric `(x, y)` values.
#let electric-field(point, charges, softening: 0.0) = {
  assert(softening >= 0, message: "fields: softening must be non-negative")
  let e = (0.0, 0.0, 0.0)
  for c in charges {
    let q = _charge-value(c)
    let p = c.position
    assert(type(p) == array and p.len() >= 2,
      message: "fields: standalone `electric-field` requires numeric positions")
    let dx = point.at(0) - p.at(0)
    let dy = point.at(1) - p.at(1)
    let r2 = dx * dx + dy * dy + softening * softening
    if r2 > 1e-20 {
      let inv-r3 = 1.0 / (r2 * calc.sqrt(r2))
      e = _vadd(e, (q * dx * inv-r3, q * dy * inv-r3, 0.0))
    }
  }
  e
}

#let _field(point, resolved, softening) = {
  let e = (0.0, 0.0, 0.0)
  for c in resolved {
    let dx = point.at(0) - c.point.at(0)
    let dy = point.at(1) - c.point.at(1)
    let r2 = dx * dx + dy * dy + softening * softening
    if r2 > 1e-20 {
      let inv-r3 = 1.0 / (r2 * calc.sqrt(r2))
      e = _vadd(e, (c.q * dx * inv-r3, c.q * dy * inv-r3, 0.0))
    }
  }
  e
}

#let _direction(point, resolved, softening, sign) = {
  let e = _field(point, resolved, softening)
  let magnitude = _norm(e)
  if magnitude < 1e-14 { none } else { _vscale(e, sign / magnitude) }
}

// One fourth-order Runge–Kutta step on the normalized field. Normalization
// makes geometric sampling independent of arbitrary charge units.
#let _rk4(point, step, sign, resolved, softening) = {
  let k1 = _direction(point, resolved, softening, sign)
  if k1 == none { return none }
  let k2 = _direction(_vadd(point, _vscale(k1, step / 2)), resolved, softening, sign)
  if k2 == none { return none }
  let k3 = _direction(_vadd(point, _vscale(k2, step / 2)), resolved, softening, sign)
  if k3 == none { return none }
  let k4 = _direction(_vadd(point, _vscale(k3, step)), resolved, softening, sign)
  if k4 == none { return none }
  _vadd(point, _vscale(_vadd(_vadd(k1, _vscale(k2, 2)), _vadd(_vscale(k3, 2), k4)), step / 6))
}

#let _clip-to-domain(a, b, domain) = {
  let ((xmin, xmax), (ymin, ymax)) = domain
  let t = 1.0
  let dx = b.at(0) - a.at(0)
  let dy = b.at(1) - a.at(1)
  if b.at(0) < xmin and dx != 0 { t = calc.min(t, (xmin - a.at(0)) / dx) }
  if b.at(0) > xmax and dx != 0 { t = calc.min(t, (xmax - a.at(0)) / dx) }
  if b.at(1) < ymin and dy != 0 { t = calc.min(t, (ymin - a.at(1)) / dy) }
  if b.at(1) > ymax and dy != 0 { t = calc.min(t, (ymax - a.at(1)) / dy) }
  _vadd(a, _vscale((dx, dy, 0), calc.max(0.0, calc.min(1.0, t))))
}

#let _trace(source-index, angle, resolved, domain, step, max-steps, start-radius, hit-radius, softening) = {
  let source = resolved.at(source-index)
  let sign = if source.q >= 0 { 1.0 } else { -1.0 }
  let radial = (calc.cos(angle), calc.sin(angle), 0.0)
  let p = _vadd(source.point, _vscale(radial, start-radius))
  let points = (p,)
  let done = false

  for _ in range(max-steps) {
    if done { break }
    let next = _rk4(p, step, sign, resolved, softening)
    if next == none { break }
    if not _inside(next, domain) {
      points.push(_clip-to-domain(p, next, domain))
      break
    }

    points.push(next)
    p = next
    for (j, other) in resolved.enumerate() {
      let target-radius = if hit-radius == auto { other.radius * 1.15 } else { hit-radius }
      if j != source-index and _distance(p, other.point) <= target-radius {
        // Snap to the marker edge rather than entering the singularity.
        let delta = (p.at(0) - other.point.at(0), p.at(1) - other.point.at(1), 0.0)
        let d = _norm(delta)
        if d > 1e-12 { points.last() = _vadd(other.point, _vscale(delta, target-radius / d)) }
        done = true
        break
      }
    }
  }
  points
}

#let _source-color(c, q, positive-color, negative-color, neutral-color) = {
  c.at("color", default: if q > 0 { positive-color } else if q < 0 { negative-color } else { neutral-color })
}

// Draw into the current CeTZ canvas. Charge positions accept every coordinate
// form that `cetz.coordinate.resolve` accepts, including named anchors that
// have already been defined in the canvas.
#let draw-charge-diagram(
  charges,
  mode: "field-lines",
  domain: ((-4, 4), (-3, 3)),
  lines-per-charge: 12,
  step: 0.07,
  max-steps: 900,
  softening: 0.0,
  marker-radius: 0.22,
  label-padding: 0.06,
  hit-radius: auto,
  line-stroke: 0.65pt,
  line-color: black,
  charge-thickness-factor: 0.35,
  arrow-position: 52%,
  arrow-scale: 0.72,
  vector-samples: (17, 13),
  vector-length-mode: "saturating",
  vector-scale: 0.32,
  vector-min-length: 0.0,
  vector-max-length: 0.32,
  vector-min-field: 1e-8,
  vector-arrowhead: ">>",
  vector-arrow-scale: 0.62,
  vector-gradient: none,
  vector-color-min: auto,
  vector-color-max: auto,
  positive-color: rgb("d94b45"),
  negative-color: rgb("3977c3"),
  neutral-color: gray,
  particle-opacity: 28%,
  show-charges: true,
  labels: true,
  anchors: (),
) = {
  _validate-domain(domain)
  assert(mode in ("field-lines", "vectors"), message: "fields: mode must be `field-lines` or `vectors`")
  assert(type(lines-per-charge) == int and lines-per-charge > 0,
    message: "fields: lines-per-charge must be a positive integer")
  assert(step > 0 and max-steps > 0, message: "fields: step and max-steps must be positive")
  assert(marker-radius > 0 and label-padding >= 0 and softening >= 0,
    message: "fields: radii must be positive; padding and softening must be non-negative")
  assert(hit-radius == auto or hit-radius > 0,
    message: "fields: hit-radius must be `auto` or positive")
  assert(type(particle-opacity) == ratio and particle-opacity >= 0% and particle-opacity <= 100%,
    message: "fields: particle-opacity must be between 0% and 100%")
  assert(type(anchors) == array, message: "fields: anchors must be an array")
  assert(vector-length-mode in ("saturating", "linear", "sqrt", "log", "normalized"),
    message: "fields: invalid vector-length-mode")
  assert(vector-scale >= 0 and vector-min-length >= 0 and vector-max-length > 0
    and vector-min-length <= vector-max-length,
    message: "fields: invalid vector length scaling options")
  assert(type(vector-arrowhead) == str and vector-arrow-scale > 0,
    message: "fields: invalid vector arrowhead options")
  assert(vector-gradient == none or type(vector-gradient) == gradient,
    message: "fields: vector-gradient must be a gradient, usually `gradient.linear(...)`")
  assert(vector-color-min == auto or type(vector-color-min) in (int, float),
    message: "fields: vector-color-min must be `auto` or a number")
  assert(vector-color-max == auto or type(vector-color-max) in (int, float),
    message: "fields: vector-color-max must be `auto` or a number")
  if vector-color-min != auto and vector-color-max != auto {
    assert(vector-color-min < vector-color-max,
      message: "fields: vector-color-min must be below vector-color-max")
  }

  let charge-names = charges.filter(c => "name" in c).map(c => c.name)
  assert(charge-names.all(n => type(n) == str and n != ""),
    message: "fields: charge names must be non-empty strings")
  assert(charge-names.dedup().len() == charge-names.len(),
    message: "fields: charge names must be unique")
  let anchor-names = anchors.map(a => {
    assert(type(a) == dictionary and ("particle", "field-line", "name").all(k => k in a),
      message: "fields: each anchor needs `particle`, `field-line`, and `name`")
    assert(type(a.particle) == str and type(a.name) == str and a.name != "",
      message: "fields: anchor particle and name must be non-empty strings")
    assert(type(a.at("field-line")) == angle,
      message: "fields: anchor `field-line` must be an angle, such as `45deg`")
    a.name
  })
  assert(anchor-names.dedup().len() == anchor-names.len(),
    message: "fields: field-line anchor names must be unique")
  assert(not anchor-names.any(n => n in charge-names),
    message: "fields: field-line anchor names must not equal charge names")

  cetz.draw.get-ctx(ctx => {
    let positions = charges.map(c => c.position)
    let resolved-result = cetz.coordinate.resolve(ctx, ..positions, update: false)
    let resolved = ()
    for (i, c) in charges.enumerate() {
      let q = _charge-value(c)
      let label-body = c.at("label", default: if q > 0 { "+" } else if q < 0 { "−" } else { "0" })
      // Exact black follows Typst Mate's Obsidian text-color substitution;
      // custom line colors intentionally remain fixed.
      let label-content = text(fill: line-color, weight: "bold", size: 9pt, label-body)
      let radius = c.at("radius", default: marker-radius)
      assert(type(radius) in (int, float) and radius > 0,
        message: "fields: charge radii must be positive numbers")
      if show-charges and labels {
        let (label-width, label-height) = cetz.util.measure(ctx, label-content)
        // Circumscribe the measured label rectangle, then add breathing room.
        // User-provided radii therefore remain minimums rather than being ignored.
        let content-radius = calc.sqrt(
          calc.pow(label-width / 2, 2) + calc.pow(label-height / 2, 2)
        ) + label-padding
        radius = calc.max(radius, content-radius)
      }
      resolved.push((
        point: resolved-result.at(i + 1),
        q: q,
        radius: radius,
        label-body: label-body,
        label-content: label-content,
        source: c,
      ))
    }

    // Resolve requested path names to the nearest uniformly seeded line. Using
    // cosine avoids angle wrapping problems at 0deg/360deg.
    let line-aliases = ()
    for requested in anchors {
      let source-index = resolved.position(c => c.source.at("name", default: none) == requested.particle)
      assert(source-index != none,
        message: "fields: unknown named particle `" + requested.particle + "` in anchors")
      assert(resolved.at(source-index).q != 0,
        message: "fields: cannot anchor a field line of a zero charge")
      let closest = 0
      let best-score = -2.0
      for n in range(lines-per-charge) {
        let score = calc.cos(360deg * n / lines-per-charge - requested.at("field-line"))
        if score > best-score {
          best-score = score
          closest = n
        }
      }
      line-aliases.push((source-index: source-index, line-index: closest, name: requested.name))
    }

    let elements = ()
    let ((xmin, xmax), (ymin, ymax)) = domain
    // An invisible frame guarantees that the requested domain determines the canvas.
    elements += cetz.draw.rect((xmin, ymin), (xmax, ymax), stroke: none, fill: none)

    if mode == "field-lines" {
      for (i, source) in resolved.enumerate() {
        if source.q != 0 {
          let width-factor = calc.max(0.05, 1 + charge-thickness-factor * calc.abs(source.q))
          for n in range(lines-per-charge) {
            let angle = 360deg * n / lines-per-charge
            let points = _trace(i, angle, resolved, domain, step, max-steps,
              source.radius * 1.18, hit-radius, softening)
            if points.len() >= 2 {
              if source.q < 0 { points = points.rev() }
              let path-color = source.source.at("line-color", default: line-color)
              elements += cetz.draw.line(
                ..points,
                stroke: (paint: path-color, thickness: line-stroke * width-factor, cap: "round", join: "round"),
                mark: (end: ">", pos: arrow-position, scale: arrow-scale, fill: path-color, shorten-to: none),
              )
              // A stroke-less copy supplies CeTZ's standard path anchors
              // without changing or redrawing the visible field line.
              for alias in line-aliases.filter(a => a.source-index == i and a.line-index == n) {
                elements += cetz.draw.line(..points, name: alias.name, stroke: none, mark: none)
              }
            }
          }
        }
      }
    } else {
      let (nx, ny) = if type(vector-samples) == int { (vector-samples, vector-samples) } else { vector-samples }
      assert(type(nx) == int and type(ny) == int and nx > 0 and ny > 0,
        message: "fields: vector-samples must contain positive integers")
      let vectors = ()
      for ix in range(nx) {
        for iy in range(ny) {
          let p = (xmin + (ix + 0.5) * (xmax - xmin) / nx, ymin + (iy + 0.5) * (ymax - ymin) / ny, 0.0)
          let near-charge = resolved.any(c => {
            let exclusion-radius = if hit-radius == auto { c.radius * 1.15 } else { hit-radius }
            _distance(p, c.point) < exclusion-radius
          })
          if not near-charge {
            let e = _field(p, resolved, softening)
            let magnitude = _norm(e)
            if magnitude >= vector-min-field {
              vectors.push((point: p, field: e, magnitude: magnitude))
            }
          }
        }
      }

      if vectors.len() > 0 {
        let magnitudes = vectors.map(v => v.magnitude)
        let color-min = if vector-color-min == auto { calc.min(..magnitudes) } else { vector-color-min }
        let color-max = if vector-color-max == auto { calc.max(..magnitudes) } else { vector-color-max }
        // A constant sampled field maps to the middle of the gradient.
        let color-span = color-max - color-min
        assert(color-span >= 0,
          message: "fields: resolved vector-color-min must not exceed vector-color-max")

        for vector in vectors {
          let length = _vector-length(
            vector.magnitude,
            vector-length-mode,
            vector-scale,
            vector-min-length,
            vector-max-length,
          )
          let delta = _vscale(vector.field, length / vector.magnitude)
          let vector-color = if vector-gradient == none {
            line-color
          } else {
            let offset = if color-span == 0 {
              50%
            } else {
              calc.max(0.0, calc.min(1.0, (vector.magnitude - color-min) / color-span)) * 100%
            }
            vector-gradient.sample(offset)
          }
          elements += cetz.draw.line(
            _vadd(vector.point, _vscale(delta, -0.5)),
            _vadd(vector.point, _vscale(delta, 0.5)),
            stroke: (paint: vector-color, thickness: line-stroke, cap: "round"),
            mark: (
              end: vector-arrowhead,
              scale: vector-arrow-scale,
              fill: vector-color,
              shorten-to: auto,
            ),
          )
        }
      }
    }

    for c in resolved {
      let color = _source-color(c.source, c.q, positive-color, negative-color, neutral-color)
      let opacity = c.source.at("opacity", default: particle-opacity)
      assert(type(opacity) == ratio and opacity >= 0% and opacity <= 100%,
        message: "fields: charge opacity must be between 0% and 100%")
      let particle-fill = color.transparentize(100% - opacity)
      let radius = c.radius
      // A named hidden charge still gets an invisible circle so its complete
      // circle anchor set remains available when `show-charges` is false.
      if show-charges or "name" in c.source {
        elements += cetz.draw.circle(
          c.point,
          radius: radius,
          name: c.source.at("name", default: none),
          fill: if show-charges { particle-fill } else { none },
          stroke: if show-charges { (paint: line-color, thickness: 0.8pt) } else { none },
        )
      }
      if show-charges and labels {
        let (x, y, ..) = c.point
        // Give the label a box matching the particle diameter. Explicit
        // center+horizon alignment keeps strings, math, and custom content
        // centered independently of font baselines.
        elements += cetz.draw.content(
          (x - radius, y + radius),
          (x + radius, y - radius),
          align(center + horizon, c.label-content),
          frame: none,
        )
      }
    }
    elements
  })
}
