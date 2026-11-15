#import "@preview/cetz:0.5.2"
#import "vectorfield.typ" as vectorfield

#let _num(x) = type(x) in (int, float)
#let _xy(p) = (p.at(0), p.at(1))
#let _norm(p) = calc.sqrt(p.at(0) * p.at(0) + p.at(1) * p.at(1))
#let _valid(p) = type(p) == array and p.len() == 2 and p.all(_num)
#let _get(d, key, default) = d.at(key, default: default)

// Deferred descriptor: resolution occurs inside draw-field-graph's canvas context.
#let vector-grid(domain, samples: (17, 13), exclude: ()) = (kind: "grid", domain: domain, samples: samples, exclude: exclude)
#let line-origins(sources, count: 12, radius: 0.22) = (kind: "origins", sources: sources, count: count, radius: radius)
#let cetz-circle-terminator(position, radius, name: none) = (kind: "circle", position: position, radius: radius, name: name)
#let cetz-combine-terminators(..terms) = (kind: "combine", terms: terms.pos())

#let _resolve(ctx, p) = {
  if _valid(p) { return p }
  assert(not (type(p) == array and p.len() == 3 and p.all(_num)), message: "fields: 3D coordinates are not supported")
  let value = cetz.coordinate.resolve(ctx, p, update: false).last()
  assert(type(value) == array and value.len() in (2, 3) and (value.len() == 2 or value.at(2) == 0), message: "fields: expected a 2D CeTZ coordinate (z must be zero)")
  _xy(value)
}

#let _grid(ctx, spec) = {
  if type(spec) == array { return spec }
  assert(type(spec) == dictionary and spec.at("kind", default: none) == "grid", message: "fields: grid must be an array or vector-grid descriptor")
  let (raw-lo, raw-hi) = spec.domain
  let lo = _resolve(ctx, raw-lo)
  let hi = _resolve(ctx, raw-hi)
  assert(lo.at(0) < hi.at(0) and lo.at(1) < hi.at(1), message: "fields: invalid grid corners")
  let counts = spec.samples
  if type(counts) == int { counts = (counts, counts) }
  assert(type(counts) == array and counts.len() == 2 and counts.all(v => type(v) == int and v > 0), message: "fields: samples must be positive integers")
  let entries = ()
  for ix in range(counts.at(0)) {
    for iy in range(counts.at(1)) {
      let p = (lo.at(0) + (ix + 0.5) * (hi.at(0) - lo.at(0)) / counts.at(0), lo.at(1) + (iy + 0.5) * (hi.at(1) - lo.at(1)) / counts.at(1))
      let blocked = spec.exclude.any(d => {
        let c = _resolve(ctx, d.position)
        _norm((p.at(0) - c.at(0), p.at(1) - c.at(1))) < d.radius
      })
      if not blocked { entries.push(p) }
    }
  }
  entries
}

#let _origins(ctx, spec) = {
  if type(spec) == array { return spec }
  assert(type(spec) == dictionary and spec.at("kind", default: none) == "origins", message: "fields: origins must be an array or line-origins descriptor")
  let result = ()
  for source in spec.sources {
    let center = _resolve(ctx, source.position)
    let count = source.at("count", default: spec.count)
    let radius = source.at("radius", default: spec.radius)
    assert(type(count) == int and count >= 0 and _num(radius) and radius > 0, message: "fields: invalid seed count or radius")
    for i in range(count) {
      let angle = 360deg * i / count
      result.push((position: (center.at(0) + radius * calc.cos(angle), center.at(1) + radius * calc.sin(angle)), reverse: source.at("reverse", default: false), color: source.at("color", default: black)))
    }
  }
  result
}

#let _terminator(ctx, term, to-field) = {
  if term == none or type(term) == function { return term }
  assert(type(term) == dictionary, message: "fields: invalid CeTZ terminator")
  if term.at("kind", default: none) == "circle" {
    let p = to-field(_resolve(ctx, term.position))
    return vectorfield.circle-terminator(p, term.radius, name: term.at("name", default: none))
  }
  assert(term.at("kind", default: none) == "combine", message: "fields: unknown CeTZ terminator")
  vectorfield.combine-terminators(..term.terms.map(t => _terminator(ctx, t, to-field)))
}

#let _length(m, mode, scale, minimum, maximum) = {
  let raw = if mode == "saturating" { maximum * (1 - calc.exp(-scale * m)) }
    else if mode == "linear" { scale * m }
    else if mode == "sqrt" { scale * calc.sqrt(m) }
    else if mode == "log" { scale * calc.ln(1 + m) }
    else if mode == "normalized" { maximum }
    else { panic("fields: unknown vector length mode") }
  calc.max(minimum, calc.min(maximum, raw))
}

#let draw-field-graph(field, domain: ((-4, -3), (4, 3)), vectors: none, lines: none, trajectories: none, reserved-names: (), overlay: none) = {
  assert(type(reserved-names) == array, message: "fields: reserved-names must be an array")
  cetz.draw.get-ctx(ctx => {
    let lo = _resolve(ctx, domain.at(0))
    let hi = _resolve(ctx, domain.at(1))
    assert(lo.at(0) < hi.at(0) and lo.at(1) < hi.at(1), message: "fields: invalid domain corners")
    let center = ((lo.at(0) + hi.at(0)) / 2, (lo.at(1) + hi.at(1)) / 2)
    let numerical = ((lo.at(0) - center.at(0), lo.at(1) - center.at(1)), (hi.at(0) - center.at(0), hi.at(1) - center.at(1)))
    let to-field = p => (p.at(0) - center.at(0), p.at(1) - center.at(1))
    let to-cetz = p => (p.at(0) + center.at(0), p.at(1) + center.at(1))
    let names = reserved-names
    let elements = cetz.draw.rect(lo, hi, stroke: none, fill: none)
    if vectors != none {
      assert(type(vectors) == dictionary, message: "fields: vectors must be a dictionary")
      let entries = _grid(ctx, _get(vectors, "grid", vector-grid((lo, hi), samples: _get(vectors, "samples", (17, 13)))))
      let retained = ()
      let threshold = _get(vectors, "min-field", 1e-8)
      for entry in entries {
        let p = _resolve(ctx, if type(entry) == dictionary { entry.position } else { entry })
        let n = if type(entry) == dictionary { entry.at("name", default: none) } else { none }
        if n != none {
          assert(type(n) == str and n != "" and not n in names, message: "fields: duplicate or invalid path name")
          names.push(n)
        }
        let blocked = _get(vectors, "exclude", ()).any(d => {
          let c = _resolve(ctx, d.position)
          _norm((p.at(0) - c.at(0), p.at(1) - c.at(1))) < d.radius
        })
        if not blocked {
          let f = vectorfield.sample(field, ..to-field(p))
          let m = _norm(f)
          if m >= threshold and m > 0 { retained.push((position: p, field: f, magnitude: m, name: n)) }
        }
      }
      if retained.len() > 0 {
        let mags = retained.map(v => v.magnitude)
        let cmin = _get(vectors, "color-min", auto)
        let cmax = _get(vectors, "color-max", auto)
        if cmin == auto { cmin = calc.min(..mags) }
        if cmax == auto { cmax = calc.max(..mags) }
        assert(cmin <= cmax, message: "fields: invalid vector colour interval")
        let grad = _get(vectors, "gradient", none)
        assert(grad == none or type(grad) == gradient, message: "fields: gradient must be a Typst gradient")
        let maxlen = _get(vectors, "max-length", 0.32)
        let minlen = _get(vectors, "min-length", 0)
        assert(minlen >= 0 and maxlen > 0 and minlen <= maxlen, message: "fields: invalid vector length bounds")
        for v in retained {
          let length = _length(v.magnitude, _get(vectors, "length-mode", "saturating"), _get(vectors, "scale", 0.32), minlen, maxlen)
          let dx = v.field.at(0) * length / (2 * v.magnitude)
          let dy = v.field.at(1) * length / (2 * v.magnitude)
          let offset = if cmax == cmin { 50% } else { calc.max(0, calc.min(1, (v.magnitude - cmin) / (cmax - cmin))) * 100% }
          let color = if grad == none { _get(vectors, "color", black) } else { grad.sample(offset) }
          elements += cetz.draw.line((v.position.at(0) - dx, v.position.at(1) - dy), (v.position.at(0) + dx, v.position.at(1) + dy), name: v.name,
            stroke: (paint: color, thickness: _get(vectors, "stroke", 0.65pt), cap: "round"), mark: (end: _get(vectors, "arrowhead", ">>"), scale: _get(vectors, "arrow-scale", 0.62), fill: color, shorten-to: auto))
        }
      }
    }
    for (mode, options) in (("trajectory", trajectories), ("streamline", lines)) {
      if options != none {
        assert(type(options) == dictionary, message: "fields: paths must be a dictionary")
        let origins = _origins(ctx, _get(options, "origins", ()))
        for origin in origins {
          let start = to-field(_resolve(ctx, origin.position))
          let name = origin.at("name", default: none)
          let aliases = origin.at("aliases", default: ())
          assert(type(aliases) == array, message: "fields: aliases must be an array")
          for alias in if name == none { aliases } else { (name,) + aliases } {
            assert(type(alias) == str and alias != "" and not alias in names, message: "fields: duplicate or invalid path name")
            names.push(alias)
          }
          let term = _terminator(ctx, origin.at("terminate", default: options.at("terminate", default: none)), to-field)
          let step = _get(origin, "step", _get(options, "step", 0.07))
          let maxsteps = _get(origin, "max-steps", _get(options, "max-steps", 900))
          let result = if mode == "trajectory" {
            vectorfield.trajectory(field, ..start, vx: _get(origin, "vx", 0), vy: _get(origin, "vy", 0), step: step, max-steps: maxsteps, domain: numerical, terminate: term)
          } else {
            vectorfield.streamline(field, ..start, reverse: _get(origin, "reverse", false), step: step, max-steps: maxsteps, domain: numerical, terminate: term)
          }
          let points = result.points.map(s => to-cetz(s))
          if mode == "streamline" and _get(origin, "reverse", false) { points = points.rev() }
          if points.len() >= 2 {
            let color = _get(origin, "color", _get(options, "color", black))
            let stroke = _get(origin, "stroke", _get(options, "stroke", 0.65pt))
            let mark = if _get(origin, "arrows", true) {
              (end: ">", pos: _get(origin, "arrow-position", _get(options, "arrow-position", 52%)), scale: _get(origin, "arrow-scale", _get(options, "arrow-scale", 0.72)), fill: color, shorten-to: none)
            } else { none }
            elements += cetz.draw.line(..points, name: name, stroke: (paint: color, thickness: stroke, cap: "round", join: "round"), mark: mark)
            for alias in aliases { elements += cetz.draw.line(..points, name: alias, stroke: none, mark: none) }
          }
        }
      }
    }
    if overlay != none { elements += overlay(ctx, center, names) }
    elements
  })
}

#let field-graph(field, domain: ((-4, -3), (4, 3)), vectors: none, lines: none, trajectories: none, setup: none, length: 1cm, padding: 0.15, background: none) = cetz.canvas(length: length, padding: padding, background: background, {
  if setup != none { cetz.draw.scope(setup) }
  draw-field-graph(field, domain: domain, vectors: vectors, lines: lines, trajectories: trajectories)
})
