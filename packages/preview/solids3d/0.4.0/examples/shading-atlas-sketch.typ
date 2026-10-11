// The atlas vocabulary rebuilt from the static sketch layer and mesh helpers only.
// No picture(), solid-plot(), pencil-pen(), vintage-hatch() or vintage-stipple() is called here.
#import "../src/sketch.typ": *
#import "../src/projection.typ": *
#import "../src/surface.typ": mesh-edges
#import "../src/path3.typ": flatten3
#import "../src/vec.typ": *

#set page(width: 21cm, height: 29.7cm, margin: (x: 14mm, y: 11mm), fill: rgb("#f2e7d3"))
#set text(font: "DejaVu Serif", size: 8pt, fill: rgb("#2b211b"))

#let paper = rgb("#f2e7d3")
#let ink = rgb("#30241d") // contour: normal black/sepia line
// Parameters of the pure shading layer. Change these two values to tune the
// contrast without changing the geometry or the contour of any object.
#let line-shading-ink = gray(0.42)
#let line-shading-secondary = gray(0.62)
#let pale-ink = rgb("#6d5a4e")
#let light = vunit((1.0, -0.35, 1.0))
#let P = perspective(4.2, 5.2, 3.0)

#let clamp(x, lo: 0.0, hi: 1.0) = calc.min(hi, calc.max(lo, x))
#let tau = 2 * calc.pi

#let _surface-grid(point, normal, tangent-u, tangent-v, nu, nv) = {
  let vertices = ()
  for j in range(nv + 1) {
    for i in range(nu + 1) {
      vertices.push(point(i / nu, j / nv))
    }
  }
  let faces = ()
  for j in range(nv) {
    for i in range(nu) {
      let a = j * (nu + 1) + i
      faces.push((a, a + 1, a + nu + 2, a + nu + 1))
    }
  }
  let cells = ()
  for j in range(nv) {
    for i in range(nu) {
      let u = (i + 0.5) / nu
      let v = (j + 0.5) / nv
      cells.push((
        u: u,
        v: v,
        point: point(u, v),
        normal: vunit(normal(u, v)),
        tangent-u: vunit(tangent-u(u, v)),
        tangent-v: vunit(tangent-v(u, v)),
      ))
    }
  }
  // A coarse occluder set is enough for the local depth test and is much
  // cheaper than comparing every mark with every mesh sample. The actual
  // marks still come from the full parametric surface.
  let samples = ()
  for vertex in vertices { samples.push(vertex) }
  for cell in cells { samples.push(cell.point) }
  let visibility = ()
  for j in range(nv + 1) {
    for i in range(nu + 1) {
      if calc.rem-euclid(i, 3) == 0 and calc.rem-euclid(j, 3) == 0 {
        visibility.push(point(i / nu, j / nv))
      }
    }
  }
  for j in range(nv) {
    for i in range(nu) {
      if calc.rem-euclid(i - 1, 3) == 0 and calc.rem-euclid(j - 1, 3) == 0 {
        visibility.push(point((i + 0.5) / nu, (j + 0.5) / nv))
      }
    }
  }
  (vertices: vertices, faces: faces, cells: cells, samples: samples, point: point, normal: normal, visibility: visibility)
}

#let solid-surface(kind, nu: 22, nv: 12) = {
  if kind == "sphere" {
    let point = (u, v) => {
      let a = tau * u
      let b = calc.pi * (v - 0.5)
      (calc.cos(b) * calc.cos(a), calc.cos(b) * calc.sin(a), calc.sin(b))
    }
    let normal = (u, v) => point(u, v)
    let tangent-u = (u, v) => {
      let a = tau * u
      (-calc.sin(a), calc.cos(a), 0.0)
    }
    let tangent-v = (u, v) => {
      let a = tau * u
      let b = calc.pi * (v - 0.5)
      (-calc.sin(b) * calc.cos(a), -calc.sin(b) * calc.sin(a), calc.cos(b))
    }
    return _surface-grid(point, normal, tangent-u, tangent-v, nu, nv)
  }
  if kind == "cylinder" {
    let point = (u, v) => {
      let a = tau * u
      (0.78 * calc.cos(a), 0.78 * calc.sin(a), 2 * v - 1)
    }
    let normal = (u, v) => {
      let a = tau * u
      (calc.cos(a), calc.sin(a), 0.0)
    }
    let tangent-u = (u, v) => {
      let a = tau * u
      (-calc.sin(a), calc.cos(a), 0.0)
    }
    let tangent-v = (u, v) => (0.0, 0.0, 1.0)
    return _surface-grid(point, normal, tangent-u, tangent-v, nu, nv)
  }
  if kind == "cone" {
    let point = (u, v) => {
      let a = tau * u
      let r = 0.88 * (1 - v)
      (r * calc.cos(a), r * calc.sin(a), 2 * v - 1)
    }
    let tangent-u = (u, v) => {
      let a = tau * u
      let r = 0.88 * (1 - v)
      (-r * calc.sin(a), r * calc.cos(a), 0.0)
    }
    let tangent-v = (u, v) => {
      let a = tau * u
      (-0.88 * calc.cos(a), -0.88 * calc.sin(a), 2.0)
    }
    let normal = (u, v) => vunit(vcross(tangent-u(u, v), tangent-v(u, v)))
    return _surface-grid(point, normal, tangent-u, tangent-v, nu, nv)
  }
  // torus
  let point = (u, v) => {
    let a = tau * u
    let b = tau * v
    let r = 0.78 + 0.30 * calc.cos(b)
    (r * calc.cos(a), r * calc.sin(a), 0.30 * calc.sin(b))
  }
  let normal = (u, v) => {
    let a = tau * u
    let b = tau * v
    (calc.cos(b) * calc.cos(a), calc.cos(b) * calc.sin(a), calc.sin(b))
  }
  let tangent-u = (u, v) => {
    let a = tau * u
    (-calc.sin(a), calc.cos(a), 0.0)
  }
  let tangent-v = (u, v) => {
    let a = tau * u
    let b = tau * v
    (-calc.sin(b) * calc.cos(a), -calc.sin(b) * calc.sin(a), calc.cos(b))
  }
  _surface-grid(point, normal, tangent-u, tangent-v, nu, nv)
}

#let _visible(P, point, normal) = vdot(normal, vunit(vsub(P.camera, point))) > 0.025

// A torus has a concave silhouette: a normal-facing sample can still be
// hidden by the opposite wall of the tube. This is a small deterministic
// software depth test. The candidates are surface samples, so it remains a
// geometric mask rather than a 2-D crop drawn after projection.
#let _project(ctx, P, point, center, scale) = (ctx.project3)(point, P: P, center: center, scale: scale)

#let _surface-visible(data, kind, point, normal) = {
  if not _visible(P, point, normal) { return false }
  if kind != "torus" { return true }
  let q = project-point(P, point)
  for other in data.visibility {
    if other != point {
      let r = project-point(P, other)
      let dx = r.at(0) - q.at(0)
      let dy = r.at(1) - q.at(1)
      if dx * dx + dy * dy < 0.0016 and closer(P, other, point) {
        return false
      }
    }
  }
  true
}

#let _inside-polygon(point, polygon) = {
  let inside = false
  let j = polygon.len() - 1
  for i in range(polygon.len()) {
    let a = polygon.at(i)
    let b = polygon.at(j)
    if ((a.at(1) > point.at(1)) != (b.at(1) > point.at(1))) {
      let x = (b.at(0) - a.at(0)) * (point.at(1) - a.at(1)) / (b.at(1) - a.at(1)) + a.at(0)
      if point.at(0) < x { inside = not inside }
    }
    j = i
  }
  inside
}

// The outer torus boundary is taken from the support polygon of the sampled
// surface. The inner boundary is the projected inner equator, slightly
// expanded so a stroke can never enter the void because of sample tolerance.
#let _torus-bounds(data) = {
  let outer = ()
  let sides = 64
  for k in range(sides) {
    let a = tau * k / sides
    let direction = (calc.cos(a), calc.sin(a))
    let best = none
    let best-value = -1e9
    for sample in data.samples {
      let q = project-point(P, sample)
      let value = q.at(0) * direction.at(0) + q.at(1) * direction.at(1)
      if value > best-value {
        best-value = value
        best = q
      }
    }
    outer.push(best)
  }
  let inner = ()
  for k in range(sides) {
    inner.push(project-point(P, (0.48 * calc.cos(tau * k / sides), 0.48 * calc.sin(tau * k / sides), 0.0)))
  }
  let cx = 0.0
  let cy = 0.0
  for q in inner {
    cx += q.at(0) / inner.len()
    cy += q.at(1) / inner.len()
  }
  let expanded = ()
  for q in inner {
    expanded.push((cx + (q.at(0) - cx) * 1.06, cy + (q.at(1) - cy) * 1.06))
  }
  (outer: outer, inner: expanded)
}

#let _inside-torus(point, bounds) = {
  _inside-polygon(point, bounds.outer) and not _inside-polygon(point, bounds.inner)
}

// Marks are made in 3-D first. They follow short parametric curves rather
// than being laid down as a flat projected grid; this makes the curvature of
// the sphere, cone and torus visible while retaining a small pure-Typst core.
#let _wrap01(x) = x - calc.floor(x)

#let _surface-mark-points(ctx, data, kind, cell, du, dv, span, center, scale, bounds: none) = {
  let runs = ()
  let run = ()
  let samples = if kind == "torus" { 17 } else { 13 }
  let midpoint = (samples - 1) / 2
  for k in range(samples) {
    let t = (k - midpoint) / midpoint
    let u = _wrap01(cell.u + du * span * t)
    let v0 = cell.v + dv * span * t
    let v = if kind == "torus" { _wrap01(v0) } else { clamp(v0, lo: 0.012, hi: 0.988) }
    let p = (data.point)(u, v)
    let n = vunit((data.normal)(u, v))
    let q = project-point(P, p)
    let allowed = if kind == "torus" { _inside-torus(q, bounds) } else { true }
    if _surface-visible(data, kind, p, n) and allowed {
      run.push(_project(ctx, P, p, center, scale))
    } else if run.len() >= 2 {
      runs.push((ctx.polyline)(run, stroke: line-shading-ink, width: 0.64, fill: none))
      run = ()
    } else {
      run = ()
    }
  }
  if run.len() >= 2 { runs.push((ctx.polyline)(run, stroke: line-shading-ink, width: 0.64, fill: none)) }
  runs
}

#let _torus-hatch-line(ctx, data, bounds, fixed, along, center, scale, stroke, width) = {
  let output = ()
  let run = ()
  let samples = if along == "u" { 97 } else { 65 }
  for k in range(samples) {
    let t = k / (samples - 1)
    let u = if along == "u" { t } else { fixed }
    let v = if along == "u" { fixed } else { t }
    let p = (data.point)(u, v)
    let n = vunit((data.normal)(u, v))
    let q = project-point(P, p)
    if _surface-visible(data, "torus", p, n) and _inside-torus(q, bounds) {
      run.push(_project(ctx, P, p, center, scale))
    } else if run.len() >= 2 {
      output.push((ctx.polyline)(run, stroke: stroke, width: width, fill: none))
      run = ()
    } else {
      run = ()
    }
  }
  if run.len() >= 2 {
    output.push((ctx.polyline)(run, stroke: stroke, width: width, fill: none))
  }
  output
}

#let hatch-commands(ctx, data, kind, mode, seed, center, scale) = {
  let output = ()
  if kind == "torus" {
    // Iso-parameter lines keep the torus rhythm regular. Each line is still
    // sampled and clipped in 3-D, then checked against the projected outer
    // and inner silhouette, so a regular hatch never becomes a flat crop.
    let bounds = _torus-bounds(data)
    let row-step = if mode == "broad" { 4 } else { 2 }
    for j in range(20) {
      if calc.rem-euclid(j, row-step) == 0 {
        let v = (j + 0.5) / 20
        let shade = clamp(1.12 - vdot(vunit((data.normal)(0.0, v)), light), lo: 0.04, hi: 1.0)
        output += _torus-hatch-line(ctx, data, bounds, v, "u", center, scale,
          line-shading-ink, 0.50 + 0.14 * shade)
      }
    }
    if mode == "cross" {
      for i in range(30) {
        if calc.rem-euclid(i, 4) == 0 {
          let u = (i + 0.5) / 30
          let shade = clamp(1.12 - vdot(vunit((data.normal)(u, 0.25)), light), lo: 0.04, hi: 1.0)
          output += _torus-hatch-line(ctx, data, bounds, u, "v", center, scale,
            line-shading-secondary, 0.40 + 0.08 * shade)
        }
      }
    }
    return output
  }

  let density0 = if mode == "broad" { 0.28 } else if mode == "close" { 0.46 } else { 0.60 }
  let span0 = if mode == "broad" { 0.92 } else if mode == "close" { 0.52 } else { 0.44 }
  let density = density0
  let span = span0
  let width = if mode == "broad" { 0.58 } else if mode == "close" { 0.50 } else { 0.44 }
  for (index, cell) in data.cells.enumerate() {
    let n = cell.normal
    let p = cell.point
    if _surface-visible(data, kind, p, n) {
      let shade = clamp(1.12 - vdot(n, light), lo: 0.04, hi: 1.0)
      let chance = density * (0.16 + 0.95 * shade)
      let dice = sketch-random(seed: seed, index: index * 3, a: 0, b: 1)
      if dice < chance {
        let primary-du = if kind == "sphere" { 0.12 } else if kind == "cone" { 0.16 } else { 0.20 }
        let primary-dv = if kind == "sphere" { 0.095 } else if kind == "cone" { 0.022 } else { 0.018 }
        let jitter-u = (sketch-random(seed: seed + 17, index: index * 5 + 1) - 0.5) * 0.045
        let jitter-v = (sketch-random(seed: seed + 17, index: index * 5 + 2) - 0.5) * 0.045
        let mark-cell = (u: cell.u + jitter-u, v: cell.v + jitter-v)
        let marks = _surface-mark-points(ctx, data, kind, mark-cell, primary-du, primary-dv, span, center, scale)
        for mark in marks {
          mark.width = width + 0.16 * shade
          output.push(mark)
        }
        if mode == "cross" and shade > 0.58 and sketch-random(seed: seed, index: index * 3 + 1) < 0.70 * shade {
          let cross-du = if kind == "sphere" { -0.08 } else { 0.015 }
          let cross-dv = if kind == "sphere" { 0.14 } else { 0.15 }
          let cross-span = span * 0.84
          let marks2 = _surface-mark-points(ctx, data, kind, mark-cell, cross-du, cross-dv, cross-span, center, scale)
          for mark in marks2 {
            mark.stroke = line-shading-secondary
            mark.width = width * 0.82
            output.push(mark)
          }
        }
      }
    }
  }
  output
}

#let _project-point(P, p, center, scale) = {
  let q = project-point(P, p)
  (center.at(0) + scale * q.at(0), center.at(1) - scale * q.at(1))
}

#let _outline-points(kind, P, center, scale) = {
  let points = ()
  if kind == "sphere" {
    let view = vunit(vsub(P.camera, P.target))
    let base = if calc.abs(vdot(view, Z)) > 0.92 { X } else { Z }
    let e1 = vunit(vcross(view, base))
    let e2 = vunit(vcross(view, e1))
    for i in range(65) {
      let a = tau * i / 64
      points.push(_project-point(P, vadd(vmul(calc.cos(a), e1), vmul(calc.sin(a), e2)), center, scale))
    }
    return points
  }
  if kind == "cylinder" {
    for z in (-1.0, 1.0) {
      for i in range(49) {
        let a = tau * i / 48
        points.push(_project-point(P, (0.78 * calc.cos(a), 0.78 * calc.sin(a), z), center, scale))
      }
    }
    return points
  }
  if kind == "cone" {
    for i in range(49) {
      let a = tau * i / 48
      points.push(_project-point(P, (0.88 * calc.cos(a), 0.88 * calc.sin(a), -1), center, scale))
    }
    return points
  }
  for radius in (1.08, 0.48) {
    for i in range(65) {
      let a = tau * i / 64
      points.push(_project-point(P, (radius * calc.cos(a), radius * calc.sin(a), 0), center, scale))
    }
  }
  points
}

#let _visible-ring(ctx, points, normals, center, scale, width: 0.72) = {
  let output = ()
  let run = ()
  for i in range(points.len()) {
    let p = points.at(i)
    if _visible(P, p, normals.at(i)) {
      run.push(_project-point(P, p, center, scale))
    } else if run.len() >= 2 {
      output.push((ctx.polyline)(run, stroke: ink, width: width, fill: none))
      run = ()
    } else {
      run = ()
    }
  }
  if run.len() >= 2 { output.push((ctx.polyline)(run, stroke: ink, width: width, fill: none)) }
  output
}

#let _ring-silhouette-indices(segments: 48) = {
  let view = vunit(vsub(P.camera, P.target))
  let best = 0
  let distance = float.inf
  for i in range(segments) {
    let a = tau * i / segments
    let radial = (calc.cos(a), calc.sin(a), 0.0)
    let d = calc.abs(vdot(radial, view))
    if d < distance { distance = d; best = i }
  }
  (best, calc.rem-euclid(best + int(segments / 2), segments))
}

#let outline-commands(ctx, kind, center, scale, data: none) = {
  if kind == "sphere" {
    let pts = _outline-points(kind, P, center, scale)
    return ((ctx.polyline)(pts, stroke: ink, width: 0.82, fill: none),)
  }
  if kind == "cylinder" {
    let top = range(49).map(i => (0.78 * calc.cos(tau * i / 48), 0.78 * calc.sin(tau * i / 48), 1.0))
    let bottom = range(49).map(i => (0.78 * calc.cos(tau * i / 48), 0.78 * calc.sin(tau * i / 48), -1.0))
    let side-normal = range(49).map(i => (calc.cos(tau * i / 48), calc.sin(tau * i / 48), 0.0))
    let top2 = top.map(p => _project-point(P, p, center, scale))
    let (left-index, right-index) = _ring-silhouette-indices()
    let output = ((ctx.polyline)(top2, stroke: ink, width: 0.72, fill: none),)
    output += _visible-ring(ctx, bottom, side-normal, center, scale)
    for index in (left-index, right-index) {
      output.push((ctx.line)(
        _project-point(P, bottom.at(index), center, scale),
        _project-point(P, top.at(index), center, scale),
        stroke: ink,
        width: 0.72,
      ))
    }
    return output
  }
  if kind == "cone" {
    let base = range(49).map(i => (0.88 * calc.cos(tau * i / 48), 0.88 * calc.sin(tau * i / 48), -1.0))
    let normals = range(49).map(i => (calc.cos(tau * i / 48), calc.sin(tau * i / 48), 0.0))
    let apex = _project-point(P, vadd(O, Z), center, scale)
    let (left-index, right-index) = _ring-silhouette-indices()
    let left = _project-point(P, base.at(left-index), center, scale)
    let right = _project-point(P, base.at(right-index), center, scale)
    let output = _visible-ring(ctx, base, normals, center, scale, width: 0.72)
    output += ((ctx.line)(apex, left, stroke: ink, width: 0.72),
      (ctx.line)(apex, right, stroke: ink, width: 0.72))
    return output
  }
  let inner = range(65).map(i => (0.48 * calc.cos(tau * i / 64), 0.48 * calc.sin(tau * i / 64), 0.0))
  let inner-normal = range(65).map(i => (-calc.cos(tau * i / 64), -calc.sin(tau * i / 64), 0.0))
  let bounds = _torus-bounds(data)
  let outer2 = bounds.outer.map(q => (
    center.at(0) + scale * q.at(0),
    center.at(1) - scale * q.at(1),
  ))
  outer2.push(outer2.first())
  let output = ((ctx.polyline)(outer2, stroke: ink, width: 0.72, fill: none),)
  output += _visible-ring(ctx, inner, inner-normal, center, scale)
  output
}

#let pure-solid-scene(kind, mode, seed) = ctx => {
  // The torus needs a denser depth sample because its inner rim is
  // silhouette-critical; the other solids keep the lighter atlas grid.
  let data = if kind == "torus" {
    solid-surface(kind, nu: 30, nv: 20)
  } else {
    solid-surface(kind)
  }
  let center = (50.0, 50.0)
  let scale = 26.0
  let commands = ()
  commands += hatch-commands(ctx, data, kind, mode, seed, center, scale)
  commands += outline-commands(ctx, kind, center, scale, data: data)
  commands
}

#let specimen(kind, mode, seed) = [
  #sketch(width: 3.25cm, height: 3.0cm, viewbox: (0, 0, 100, 100), seed: seed,
    projection: P, draw: pure-solid-scene(kind, mode, seed))
]

// The mesh helper is used without picture() here: the returned 3-D edges are
// flattened and sent through sketch.project3. This small construction view is
// kept separate from the atlas marks so it does not turn the comparison into
// a disguised wireframe renderer.
#let mesh-scene = ctx => {
  let data = solid-surface("sphere", nu: 12, nv: 8)
  let commands = ()
  for edge in mesh-edges(data.vertices, data.faces) {
    let pts = flatten3(edge, n: 1).map(p => (ctx.project3)(p, P: P, center: (50, 50), scale: 25))
    commands.push((ctx.polyline)(pts, stroke: pale-ink, width: 0.32, fill: none))
  }
  commands
}

// Fibonacci and random stippling also remain entirely static SVG marks. The
// points are selected on the 3-D sphere before projection.
#let stipple-scene(distribution, seed) = ctx => {
  let commands = ()
  let count = 1150
  for i in range(count) {
    let (u, z) = if distribution == "fibonacci" {
      let golden = calc.pi * (3 - calc.sqrt(5))
      let zz = 1 - 2 * (i + 0.5) / count
      (i * golden, zz)
    } else {
      (tau * sketch-random(seed: seed, index: i * 2),
        1 - 2 * sketch-random(seed: seed, index: i * 2 + 1))
    }
    let r = calc.sqrt(calc.max(0, 1 - z * z))
    let p = (r * calc.cos(u), r * calc.sin(u), z)
    let n = p
    if _visible(P, p, n) {
      let shade = clamp(1.12 - vdot(n, light), lo: 0.03, hi: 1.0)
      let keep = sketch-random(seed: seed + 91, index: i * 3, a: 0, b: 1)
      if keep < 0.16 + 0.94 * shade {
        let radius = 0.16 + 0.48 * calc.pow(shade, 1.25)
        let q = (ctx.project3)(p, P: P, center: (50, 50), scale: 26)
        commands.push((ctx.circle)(q, radius, fill: line-shading-ink, stroke: none))
      }
    }
  }
  commands += outline-commands(ctx, "sphere", (50, 50), 26)
  commands
}

#let _nib-rail(t, side) = {
  let u = 1 - t
  // A single bowed cubic, with the same kind of broad-to-fine profile as
  // the atlas specimen. The envelope is built from offset samples.
  let x = 8 * u * u * u + 3 * 30 * u * u * t + 3 * 65 * u * t * t + 92 * t * t * t
  let y = 46 * u * u * u + 3 * 43 * u * u * t + 3 * 58 * u * t * t + 50 * t * t * t
  let dx = 3 * u * u * (30 - 8) + 6 * u * t * (65 - 30) + 3 * t * t * (92 - 65)
  let dy = 3 * u * u * (43 - 46) + 6 * u * t * (58 - 43) + 3 * t * t * (50 - 58)
  let length = calc.sqrt(dx * dx + dy * dy)
  let nx = -dy / length
  let ny = dx / length
  let width = 4.2 * calc.pow(1 - t, 0.72) + 0.08
  (x + side * nx * width, y + side * ny * width)
}

#let nib-scene = ctx => {
  let commands = ()
  let pieces = 22
  for i in range(pieces) {
    let t0 = i / pieces
    let t1 = calc.min(1.0, t0 + if i < 11 { 1 / pieces } else { 0.68 / pieces })
    // The broad first half is continuous. Later pieces deliberately break
    // apart as the envelope approaches printable width.
    if i < 11 or calc.rem(i - 11, 2) == 0 {
      let polygon = (
        _nib-rail(t0, 1),
        _nib-rail(t1, 1),
        _nib-rail(t1, -1),
        _nib-rail(t0, -1),
      )
      commands.push((ctx.polygon)(polygon, fill: line-shading-ink, stroke: none))
    }
  }
  commands
}

// Faceted solids use the same pure path layer, but their marks are built
// directly on each planar face. `mesh-edges` supplies the visible edge set.
#let _mean3(points) = {
  if points.len() == 0 { return O }
  vmul(1 / points.len(), points.fold(O, vadd))
}

#let polyhedron-data(kind) = {
  if kind == "cube" {
    return (
      center: O,
      vertices: (
        (-1, -1, -1), (1, -1, -1), (1, 1, -1), (-1, 1, -1),
        (-1, -1, 1), (1, -1, 1), (1, 1, 1), (-1, 1, 1),
      ),
      faces: ((0, 1, 2, 3), (4, 7, 6, 5), (0, 4, 5, 1),
        (1, 5, 6, 2), (2, 6, 7, 3), (3, 7, 4, 0)),
    )
  }
  if kind == "tetrahedron" {
    return (
      center: O,
      vertices: ((1, 1, 1), (-1, -1, 1), (-1, 1, -1), (1, -1, -1)),
      faces: ((0, 1, 2), (0, 3, 1), (0, 2, 3), (1, 3, 2)),
    )
  }
  if kind == "octahedron" {
    return (
      center: O,
      vertices: ((1, 0, 0), (-1, 0, 0), (0, 1, 0), (0, -1, 0), (0, 0, 1), (0, 0, -1)),
      faces: ((4, 0, 2), (4, 2, 1), (4, 1, 3), (4, 3, 0),
        (5, 2, 0), (5, 1, 2), (5, 3, 1), (5, 0, 3)),
    )
  }
  if kind == "pyramid" {
    return (
      center: (0, 0, -0.45),
      vertices: ((-1, -1, -1), (1, -1, -1), (1, 1, -1), (-1, 1, -1), (0, 0, 1.35)),
      faces: ((0, 1, 2, 3), (0, 4, 1), (1, 4, 2), (2, 4, 3), (3, 4, 0)),
    )
  }
  if kind == "triangular-prism" {
    return (
      center: O,
      vertices: ((-1, -0.82, -0.9), (1, -0.82, -0.9), (0, 0.92, -0.9),
        (-1, -0.82, 0.9), (1, -0.82, 0.9), (0, 0.92, 0.9)),
      faces: ((0, 2, 1), (3, 4, 5), (0, 1, 4, 3), (1, 2, 5, 4), (2, 0, 3, 5)),
    )
  }
  // A low-detail icosahedron-like envelope, useful as a final non-prismatic
  // test while keeping the example inexpensive to compile.
  let phi = (1 + calc.sqrt(5)) / 2
  (
    center: O,
    vertices: (
      (-1, phi, 0), (1, phi, 0), (-1, -phi, 0), (1, -phi, 0),
      (0, -1, phi), (0, 1, phi), (0, -1, -phi), (0, 1, -phi),
      (phi, 0, -1), (phi, 0, 1), (-phi, 0, -1), (-phi, 0, 1),
    ),
    faces: (
      (0, 11, 5), (0, 5, 1), (0, 1, 7), (0, 7, 10), (0, 10, 11),
      (1, 5, 9), (5, 11, 4), (11, 10, 2), (10, 7, 6), (7, 1, 8),
      (3, 9, 4), (3, 4, 2), (3, 2, 6), (3, 6, 8), (3, 8, 9),
      (4, 9, 5), (2, 4, 11), (6, 2, 10), (8, 6, 7), (9, 8, 1),
    ),
  )
}

#let _poly-face(data, ids) = {
  let points = ids.map(i => data.vertices.at(i))
  let center = _mean3(points)
  let normal = vunit(vcross(vsub(points.at(1), points.at(0)), vsub(points.at(2), points.at(0))))
  if vdot(normal, vsub(center, data.center)) < 0 { normal = vneg(normal) }
  let tangent = vunit(vsub(points.at(1), points.at(0)))
  let binormal = vunit(vcross(normal, tangent))
  let radius = 0.0
  for point in points { radius = calc.max(radius, vabs(vsub(point, center))) }
  (points: points, center: center, normal: normal, tangent: tangent, binormal: binormal, radius: radius)
}

// Intersect a line in the face plane with the convex face polygon. This
// prevents planar marks from spilling outside triangles and pyramid sides.
#let _face-line(face, along, across, offset) = {
  let hits = ()
  let points = face.points
  for i in range(points.len()) {
    let a = points.at(i)
    let b = points.at(calc.rem-euclid(i + 1, points.len()))
    let aa = vsub(a, face.center)
    let bb = vsub(b, face.center)
    let xa = vdot(aa, along)
    let ya = vdot(aa, across)
    let xb = vdot(bb, along)
    let yb = vdot(bb, across)
    if (ya <= offset and yb > offset) or (yb <= offset and ya > offset) {
      let t = (offset - ya) / (yb - ya)
      hits.push(xa + t * (xb - xa))
    }
  }
  if hits.len() < 2 { none } else {
    let lo = hits.first()
    let hi = hits.first()
    for x in hits {
      if x < lo { lo = x }
      if x > hi { hi = x }
    }
    (
      vadd(face.center, vadd(vmul(lo, along), vmul(offset, across))),
      vadd(face.center, vadd(vmul(hi, along), vmul(offset, across))),
    )
  }
}

#let poly-hatch-commands(ctx, data, mode, seed, center, scale) = {
  let output = ()
  let levels = if mode == "broad" { 5 } else if mode == "close" { 8 } else { 10 }
  let width = if mode == "broad" { 0.58 } else if mode == "close" { 0.50 } else { 0.44 }
  for (face-index, ids) in data.faces.enumerate() {
    let face = _poly-face(data, ids)
    if _visible(P, face.center, face.normal) {
      let shade = clamp(1.12 - vdot(face.normal, light), lo: 0.05, hi: 1.0)
      // No random omissions or offsets here: q is a regular parameter in the
      // face plane, and _face-line clips each complete line to that polygon.
      for level in range(levels) {
        let q = if levels == 1 { 0.5 } else { (level + 0.5) / levels }
        let offset = (q - 0.5) * 1.15 * face.radius
        let line = _face-line(face, face.tangent, face.binormal, offset)
        if line != none {
          let (start, end) = line
          output.push((ctx.line)(
            (ctx.project3)(start, P: P, center: center, scale: scale),
            (ctx.project3)(end, P: P, center: center, scale: scale),
            stroke: line-shading-ink,
            width: width + 0.14 * shade,
          ))
        }
      }
      if mode == "cross" and shade > 0.58 {
        let levels2 = 4
        for level in range(levels2) {
          let q = (level + 0.5) / levels2
          let offset = (q - 0.5) * 0.9 * face.radius
          let line = _face-line(face, face.binormal, face.tangent, offset)
          if line != none {
            let (start, end) = line
            output.push((ctx.line)(
              (ctx.project3)(start, P: P, center: center, scale: scale),
              (ctx.project3)(end, P: P, center: center, scale: scale),
              stroke: line-shading-secondary,
              width: width * 0.78,
            ))
          }
        }
      }
    }
  }
  output
}

#let poly-edge-commands(ctx, data, center, scale) = {
  let output = ()
  for edge in mesh-edges(data.vertices, data.faces) {
    let points = flatten3(edge, n: 1)
    let a = points.at(0)
    let b = points.at(1)
    let mid = vmul(0.5, vadd(a, b))
    let a-index = none
    let b-index = none
    for (vertex-index, vertex) in data.vertices.enumerate() {
      if vertex == a { a-index = vertex-index }
      if vertex == b { b-index = vertex-index }
    }
    let front = false
    for ids in data.faces {
      let has-a = false
      let has-b = false
      for id in ids {
        if id == a-index { has-a = true }
        if id == b-index { has-b = true }
      }
      if has-a and has-b and _visible(P, _mean3(ids.map(i => data.vertices.at(i))), _poly-face(data, ids).normal) {
        front = true
      }
    }
    // If the adjacency lookup cannot identify an edge, retain it when its
    // midpoint is on the camera-facing half. This keeps custom meshes useful.
    if front or _visible(P, mid, vunit(vsub(mid, data.center))) {
      output.push((ctx.line)(
        (ctx.project3)(a, P: P, center: center, scale: scale),
        (ctx.project3)(b, P: P, center: center, scale: scale),
        stroke: ink,
        width: 0.72,
      ))
    }
  }
  output
}

#let poly-scene(kind, mode: "cross", seed: 73) = ctx => {
  let data = polyhedron-data(kind)
  let commands = ()
  commands += poly-hatch-commands(ctx, data, mode, seed, (50, 50), 24)
  commands += poly-edge-commands(ctx, data, (50, 50), 24)
  commands
}

#align(center)[
  #text(size: 8.5pt, tracking: 0.8pt, style: "italic")[#smallcaps[Pure sketch experiment]]
  #v(3pt)
  #text(size: 13pt, weight: "bold")[An Atlas of Line Shading]
  #v(2pt)
  #text(size: 8pt, fill: pale-ink, style: "italic")[static SVG · geometry-first marks]
]
#v(6mm)

#grid(columns: (16mm, 1fr, 1fr, 1fr), column-gutter: 3mm, row-gutter: 4mm, align: center + horizon,
  [],
  text(size: 8pt, style: "italic")[I. Broad],
  text(size: 8pt, style: "italic")[II. Broken close],
  text(size: 8pt, style: "italic")[III. Crossed shadow],
  rotate(-90deg, text(size: 8pt, smallcaps[Sphere])),
  specimen("sphere", "broad", 11), specimen("sphere", "close", 11), specimen("sphere", "cross", 11),
  rotate(-90deg, text(size: 8pt, smallcaps[Cone])),
  specimen("cone", "broad", 17), specimen("cone", "close", 17), specimen("cone", "cross", 17),
  rotate(-90deg, text(size: 8pt, smallcaps[Cylinder])),
  specimen("cylinder", "broad", 23), specimen("cylinder", "close", 23), specimen("cylinder", "cross", 23),
  rotate(-90deg, text(size: 8pt, smallcaps[Torus])),
  specimen("torus", "broad", 31), specimen("torus", "close", 31), specimen("torus", "cross", 31),
)

#v(4mm)
#grid(columns: (1fr, 1fr, 1fr), gutter: 5mm, align: center,
  [#sketch(width: 3.1cm, height: 2.5cm, seed: 41, projection: P, draw: stipple-scene("random", 41))
   #align(center)[#text(size: 8pt, style: "italic")[IV. Random stipple]]],
  [#sketch(width: 3.1cm, height: 2.5cm, seed: 41, projection: P, draw: stipple-scene("fibonacci", 41))
   #align(center)[#text(size: 8pt, style: "italic")[V. Fibonacci stipple]]],
  [#sketch(width: 3.1cm, height: 2.5cm, seed: 17, draw: nib-scene)
   #align(center)[#text(size: 8pt, style: "italic")[VI. Pure polygon nib]]],
)

#v(4mm)
#grid(columns: (1fr, 1fr), gutter: 8mm, align: center,
  [#sketch(width: 3.1cm, height: 2.5cm, seed: 3, projection: P, draw: mesh-scene)
   #align(center)[#text(size: 8pt, style: "italic")[construction mesh via `mesh-edges`]]],
  [
    #text(size: 8pt, smallcaps[Construction.])
    Marks are generated on sampled 3-D patches, culled by a front-facing test,
    and projected only at the end. This gives a real geometric baseline without
    invoking any external engine.
  ],
)

#pagebreak()
#align(center)[
  #text(size: 8.5pt, tracking: 0.8pt, style: "italic")[#smallcaps[Pure sketch experiment · faceted solids]]
  #v(3pt)
  #text(size: 13pt, weight: "bold")[Line shading on polyhedral solids]
  #v(2pt)
  #text(size: 8pt, fill: pale-ink, style: "italic")[planar marks · visible edges from `mesh-edges`]
]
#v(8mm)
#grid(columns: 3, gutter: 8mm, row-gutter: 8mm, align: center,
  [
    #sketch(width: 4.1cm, height: 3.8cm, seed: 73, projection: P, draw: poly-scene("cube", mode: "cross", seed: 73))
    #align(center)[#text(size: 8pt, style: "italic")[cube]]
  ],
  [
    #sketch(width: 4.1cm, height: 3.8cm, seed: 79, projection: P, draw: poly-scene("tetrahedron", mode: "cross", seed: 79))
    #align(center)[#text(size: 8pt, style: "italic")[tétraèdre]]
  ],
  [
    #sketch(width: 4.1cm, height: 3.8cm, seed: 83, projection: P, draw: poly-scene("octahedron", mode: "cross", seed: 83))
    #align(center)[#text(size: 8pt, style: "italic")[octaèdre]]
  ],
  [
    #sketch(width: 4.1cm, height: 3.8cm, seed: 89, projection: P, draw: poly-scene("pyramid", mode: "cross", seed: 89))
    #align(center)[#text(size: 8pt, style: "italic")[pyramide carrée]]
  ],
  [
    #sketch(width: 4.1cm, height: 3.8cm, seed: 97, projection: P, draw: poly-scene("triangular-prism", mode: "cross", seed: 97))
    #align(center)[#text(size: 8pt, style: "italic")[prisme triangulaire]]
  ],
  [
    #sketch(width: 4.1cm, height: 3.8cm, seed: 101, projection: P, draw: poly-scene("icosahedron", mode: "cross", seed: 101))
    #align(center)[#text(size: 8pt, style: "italic")[icosaèdre, maillage triangulé]]
  ],
)
#v(8mm)
#grid(columns: (1fr, 1fr), gutter: 9mm,
  [
    #text(size: 8pt, smallcaps[Méthode.])
    Chaque face est traitée comme un patch plan : normale, direction de hachure,
    densité et éventuelle seconde famille sont calculées avant la projection.
  ],
  [
    #text(size: 8pt, smallcaps[Limite assumée.])
    Les arêtes cachées sont filtrées par adjacence de faces et test de visibilité.
    Ce rendu reste une approximation purement Typst du moteur de référence.
  ],
)
