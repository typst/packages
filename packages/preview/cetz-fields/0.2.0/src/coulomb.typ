#import "@preview/cetz:0.5.2"
#import "vectorfield.typ" as vectorfield
#import "graph.typ" as graph

#let _num(x) = type(x) in (int, float)
#let _resolve(ctx, p) = {
  if type(p) == array and p.len() == 2 and p.all(_num) { return p }
  assert(not (type(p) == array and p.len() == 3 and p.all(_num)), message: "fields: 3D charge positions are not supported")
  let value = cetz.coordinate.resolve(ctx, p, update: false).last()
  assert(type(value) == array and value.len() in (2, 3) and (value.len() == 2 or value.at(2) == 0), message: "fields: charges require 2D coordinates (z must be zero)")
  (value.at(0), value.at(1))
}

#let electric-field(point, charges, softening: 0) = {
  assert(type(point) == array and point.len() == 2 and point.all(_num) and _num(softening) and softening >= 0,
    message: "fields: electric-field requires a numeric point and nonnegative softening")
  let x = 0.0
  let y = 0.0
  for c in charges {
    assert(type(c) == dictionary and "charge" in c and _num(c.charge) and type(c.position) == array and c.position.len() == 2 and c.position.all(_num),
      message: "fields: electric-field requires numeric charges")
    let dx = point.at(0) - c.position.at(0)
    let dy = point.at(1) - c.position.at(1)
    let r2 = dx * dx + dy * dy + softening * softening
    if r2 > 1e-20 {
      let factor = c.charge / (r2 * calc.sqrt(r2))
      x += factor * dx
      y += factor * dy
    }
  }
  (x, y)
}
#let coulomb-field(charges, softening: 0) = vectorfield.new((x, y) => electric-field((x, y), charges, softening: softening))

#let draw-charge-diagram(charges, domain: ((-4, -3), (4, 3)), vectors: none, lines: (:), trajectories: none,
  lines-per-charge: 12, softening: 0, marker-radius: 0.22, label-padding: 0.06, hit-radius: auto,
  line-stroke: 0.65pt, line-color: black, charge-thickness-factor: 0.35, positive-color: rgb("d94b45"), negative-color: rgb("3977c3"), neutral-color: gray,
  particle-opacity: 28%, show-charges: true, labels: true, anchors: ()) = {
  assert(type(charges) == array and type(lines-per-charge) == int and lines-per-charge >= 0 and marker-radius > 0 and label-padding >= 0,
    message: "fields: invalid charges or line density")
  assert(type(anchors) == array and (hit-radius == auto or (_num(hit-radius) and hit-radius > 0)), message: "fields: invalid anchors or hit radius")
  assert(type(particle-opacity) == ratio and particle-opacity >= 0% and particle-opacity <= 100%, message: "fields: particle opacity must be between 0% and 100%")
  cetz.draw.get-ctx(ctx => {
    let lo = _resolve(ctx, domain.at(0))
    let hi = _resolve(ctx, domain.at(1))
    assert(lo.at(0) < hi.at(0) and lo.at(1) < hi.at(1), message: "fields: invalid domain")
    let graph-center = ((lo.at(0) + hi.at(0)) / 2, (lo.at(1) + hi.at(1)) / 2)
    let resolved = ()
    let charge-names = ()
    for c in charges {
      assert(type(c) == dictionary and "position" in c and "charge" in c and _num(c.charge), message: "fields: charge needs position and numeric charge")
      let pos = _resolve(ctx, c.position)
      let q = c.charge
      let name = c.at("name", default: none)
      if name != none {
        assert(type(name) == str and name != "" and not name in charge-names, message: "fields: duplicate charge name")
        charge-names.push(name)
      }
      let body = c.at("content", default: if q > 0 { [+] } else if q < 0 { [−] } else { [0] })
      let label = text(fill: line-color, weight: "bold", size: 9pt, body)
      let radius = c.at("radius", default: marker-radius)
      assert(_num(radius) and radius > 0, message: "fields: radius must be positive")
      if show-charges and labels {
        let (w, h) = cetz.util.measure(ctx, label)
        radius = calc.max(radius, calc.sqrt(calc.pow(w / 2, 2) + calc.pow(h / 2, 2)) + label-padding)
      }
      let count = if "lines" in c { c.lines } else if q == 0 or lines-per-charge == 0 { 0 } else { int(calc.max(1, calc.round(lines-per-charge * calc.abs(q)))) }
      assert(type(count) == int and count >= 0, message: "fields: lines must be a nonnegative integer")
      if q == 0 { count = 0 }
      resolved.push((source: c, position: pos, field-position: (pos.at(0) - graph-center.at(0), pos.at(1) - graph-center.at(1)), charge: q, name: name, label: label, radius: radius, count: count))
    }
    let field = coulomb-field(resolved.map(c => (position: c.field-position, charge: c.charge)), softening: softening)
    assert(lines != none or anchors.len() == 0, message: "fields: cannot name lines when line drawing is disabled")
    let opts = if lines == none { none } else {
      assert(type(lines) == dictionary, message: "fields: lines must be a dictionary")
      let origins = lines.at("origins", default: ())
      for (i, source) in resolved.enumerate() {
        for n in range(source.count) {
          let seed-angle = 360deg * n / source.count
          let p = (source.position.at(0) + source.radius * 1.18 * calc.cos(seed-angle), source.position.at(1) + source.radius * 1.18 * calc.sin(seed-angle))
          let terms = ()
          for (j, other) in resolved.enumerate() {
            if j != i {
              let r = if hit-radius == auto { other.radius * 1.15 } else { hit-radius }
              terms.push(vectorfield.circle-terminator(other.field-position, r, name: other.name))
            }
          }
          let matching = anchors.filter(a => a.particle == source.name)
          let aliases = matching.filter(a => {
            assert(type(a.at("field-line")) == angle, message: "fields: field-line anchor must be an angle")
            let best = 0
            let score = -2.0
            for k in range(source.count) {
              let candidate = calc.cos(360deg * k / source.count - a.at("field-line"))
              if candidate > score { best = k; score = candidate }
            }
            best == n
          })
          let color = source.source.at("line-color", default: line-color)
          let stroke = line-stroke * calc.max(0.05, 1 + charge-thickness-factor * calc.abs(source.charge))
          let base = (position: p, reverse: source.charge < 0, color: color, stroke: stroke, terminate: vectorfield.combine-terminators(..terms))
          // Multiple requested aliases may refer to the same seed; the first names the visible path.
          if aliases.len() > 0 {
            base.insert("name", aliases.first().name)
            if aliases.len() > 1 { base.insert("aliases", aliases.slice(1).map(a => a.name)) }
          }
          origins.push(base)
        }
      }
      for a in anchors {
        let idx = resolved.position(c => c.name == a.particle)
        assert(idx != none and resolved.at(idx).count > 0, message: "fields: unknown or unseeded charge in anchors")
      }
      let result = lines
      result.insert("origins", origins)
      if not "stroke" in result { result.insert("stroke", line-stroke) }
      if not "color" in result { result.insert("color", line-color) }
      result
    }
    let vopts = if vectors == none { none } else {
      assert(type(vectors) == dictionary, message: "fields: vectors must be a dictionary")
      let result = vectors
      let exclusions = vectors.at("exclude", default: ())
      for c in resolved {
        exclusions.push((position: c.position, radius: if hit-radius == auto { c.radius * 1.15 } else { hit-radius }))
      }
      result.insert("exclude", exclusions)
      result
    }
    let overlay = (drawing-ctx, _, names) => {
      let elements = ()
      for c in resolved {
        let color = c.source.at("color", default: if c.charge > 0 { positive-color } else if c.charge < 0 { negative-color } else { neutral-color })
        let opacity = c.source.at("opacity", default: particle-opacity)
        assert(type(opacity) == ratio and opacity >= 0% and opacity <= 100%, message: "fields: opacity must be a ratio between 0% and 100%")
        assert(c.name == none or not c.name in names, message: "fields: charge name conflicts with path")
        if show-charges or c.name != none {
          elements += cetz.draw.circle(c.position, radius: c.radius, name: c.name,
            fill: if show-charges { color.transparentize(100% - opacity) } else { none },
            stroke: if show-charges { (paint: line-color, thickness: 0.8pt) } else { none })
        }
        if show-charges and labels {
          let (x, y) = c.position
          elements += cetz.draw.content((x - c.radius, y + c.radius), (x + c.radius, y - c.radius), align(center + horizon, c.label), frame: none)
        }
      }
      elements
    }
    graph.draw-field-graph(field, domain: (lo, hi), vectors: vopts, lines: opts, trajectories: trajectories, overlay: overlay)
  })
}

#let charge-diagram(charges, domain: ((-4, -3), (4, 3)), setup: none, length: 1cm, padding: 0.15, background: none, ..options) = cetz.canvas(
  length: length, padding: padding, background: background, {
    if setup != none { cetz.draw.scope(setup) }
    draw-charge-diagram(charges, domain: domain, ..options)
  },
)
