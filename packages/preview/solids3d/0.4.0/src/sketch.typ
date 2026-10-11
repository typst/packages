// sketch.typ — a small deterministic, static 2-D sketch layer.
//
// The vocabulary is deliberately p5-like, but the output is an embedded SVG:
// setup/draw are evaluated once by Typst, so sketches remain reproducible,
// printable and free of a browser/runtime dependency.

#import "pens.typ": *
#import "projection.typ": project-point, currentprojection

#let _sketch-hash(seed, index) = {
  let x = calc.sin(float(seed) * 12.9898 + float(index) * 78.233 + 37.719)
  let y = x * 43758.5453123
  y - calc.floor(y)
}

// Deterministic replacement for p5.random(). The explicit index makes a
// result independent of evaluation order and therefore stable in Typst.
#let sketch-random(seed: 0, index: 0, a: 0.0, b: 1.0) = {
  float(a) + _sketch-hash(seed, index) * (float(b) - float(a))
}

#let _sketch-lattice(x, y, z, seed) = _sketch-hash(seed + x * 17.0 + y * 59.0 + z * 113.0, 0)
#let _sketch-lerp(a, b, t) = a + (b - a) * t
#let _sketch-smooth(t) = t * t * (3 - 2 * t)

// Value noise with deterministic octave accumulation. Coordinates are in an
// unbounded mathematical plane; `octaves` is normally 1–5.
#let sketch-noise(x, y: 0.0, z: 0.0, seed: 0, octaves: 3) = {
  let result = 0.0
  let amplitude = 1.0
  let frequency = 1.0
  let norm = 0.0
  let count = calc.max(1, int(octaves))
  for _ in range(count) {
    let fx = float(x) * frequency
    let fy = float(y) * frequency
    let fz = float(z) * frequency
    let x0 = calc.floor(fx)
    let y0 = calc.floor(fy)
    let z0 = calc.floor(fz)
    let tx = _sketch-smooth(fx - x0)
    let ty = _sketch-smooth(fy - y0)
    let tz = _sketch-smooth(fz - z0)
    let c000 = _sketch-lattice(x0, y0, z0, seed)
    let c100 = _sketch-lattice(x0 + 1, y0, z0, seed)
    let c010 = _sketch-lattice(x0, y0 + 1, z0, seed)
    let c110 = _sketch-lattice(x0 + 1, y0 + 1, z0, seed)
    let c001 = _sketch-lattice(x0, y0, z0 + 1, seed)
    let c101 = _sketch-lattice(x0 + 1, y0, z0 + 1, seed)
    let c011 = _sketch-lattice(x0, y0 + 1, z0 + 1, seed)
    let c111 = _sketch-lattice(x0 + 1, y0 + 1, z0 + 1, seed)
    let x00 = _sketch-lerp(c000, c100, tx)
    let x10 = _sketch-lerp(c010, c110, tx)
    let x01 = _sketch-lerp(c001, c101, tx)
    let x11 = _sketch-lerp(c011, c111, tx)
    let y0v = _sketch-lerp(x00, x10, ty)
    let y1v = _sketch-lerp(x01, x11, ty)
    result += _sketch-lerp(y0v, y1v, tz) * amplitude
    norm += amplitude
    amplitude *= 0.5
    frequency *= 2
  }
  result / norm
}

#let _sketch-point(p) = repr(calc.round(p.at(0), digits: 3)) + "," + repr(calc.round(p.at(1), digits: 3))
#let _sketch-points(points) = points.map(_sketch-point).join(" ")
#let _sketch-angle(a) = if type(a) == angle { a / 1rad } else { float(a) * 1deg / 1rad }

#let _sketch-color(value, fallback: black) = {
  if value == none { return none }
  let p = resolve-pen(value)
  if p == none or p.at("invisible", default: false) { return none }
  let paint = p.at("paint", default: fallback)
  if type(paint) != color { paint = fallback }
  let u = rgba-of(paint)
  let c = rgb(
    int(calc.round(u.at(0) * 255)),
    int(calc.round(u.at(1) * 255)),
    int(calc.round(u.at(2) * 255)),
  ).to-hex()
  (color: c, opacity: u.at(3) * p.at("opacity", default: 1.0), pen: p)
}

#let _sketch-opacity(u) = if u >= 0.999 { "" } else { " opacity=\"" + repr(calc.round(u, digits: 3)) + "\"" }
#let _sketch-stroke(value, width, scale) = {
  let c = _sketch-color(value)
  if c == none { "stroke=\"none\"" } else {
    let p = c.pen
    let w = if type(width) == length { width.to-absolute().pt() / scale } else { float(width) }
    let out = "stroke=\"" + c.color + "\" stroke-width=\"" + repr(calc.round(w, digits: 3))
    out += "\" stroke-linecap=\"" + p.at("cap", default: "round")
    out += "\" stroke-linejoin=\"" + p.at("join", default: "round")
    out += "\"" + _sketch-opacity(c.opacity)
    out
  }
}

#let _sketch-fill(value) = {
  let c = _sketch-color(value)
  if c == none { "fill=\"none\"" } else { "fill=\"" + c.color + "\"" + _sketch-opacity(c.opacity) }
}

// SVG-level primitives. They are public so a generated command list can be
// assembled without first creating a sketch context.
#let sketch-line(a, b, stroke: black, width: 0.8, cap: auto) = (kind: "line", a: a, b: b, stroke: stroke, width: width, cap: cap)
#let sketch-circle(center, radius, fill: none, stroke: black, width: 0.8) = (kind: "circle", center: center, radius: radius, fill: fill, stroke: stroke, width: width)
#let sketch-ellipse(center, radius, fill: none, stroke: black, width: 0.8) = (kind: "ellipse", center: center, radius: radius, fill: fill, stroke: stroke, width: width)
#let sketch-rect(position, size, fill: none, stroke: black, width: 0.8, radius: 0) = (kind: "rect", position: position, size: size, fill: fill, stroke: stroke, width: width, radius: radius)
#let sketch-polyline(points, stroke: black, width: 0.8, fill: none, closed: false) = (kind: "polyline", points: points, stroke: stroke, width: width, fill: fill, closed: closed)
#let sketch-polygon(points, fill: none, stroke: black, width: 0.8) = sketch-polyline(points, stroke: stroke, width: width, fill: fill, closed: true)

#let sketch-transform(point, translate: (0.0, 0.0), rotate: 0deg, scale: 1.0, center: (0.0, 0.0)) = {
  let a = _sketch-angle(rotate)
  let c = calc.cos(a)
  let s = calc.sin(a)
  let x = (point.at(0) - center.at(0)) * float(scale)
  let y = (point.at(1) - center.at(1)) * float(scale)
  (center.at(0) + c * x - s * y + translate.at(0), center.at(1) + s * x + c * y + translate.at(1))
}

#let sketch-polar(radius, angle, center: (0.0, 0.0)) = {
  let a = _sketch-angle(angle)
  (center.at(0) + radius * calc.cos(a), center.at(1) + radius * calc.sin(a))
}

#let _sketch-context(viewbox, seed, projection) = {
  let x0 = viewbox.at(0)
  let y0 = viewbox.at(1)
  let w = viewbox.at(2)
  let h = viewbox.at(3)
  let random(index: 0, a: 0.0, b: 1.0) = sketch-random(seed: seed, index: index, a: a, b: b)
  let noise(x, y: 0.0, z: 0.0, octaves: 3) = sketch-noise(x, y: y, z: z, seed: seed, octaves: octaves)
  let project3(v, P: auto, center: (x0 + w / 2, y0 + h / 2), scale: 1.0) = {
    let Q = if P == auto { projection } else { P }
    if Q == none { panic("sketch.project3 needs a projection") }
    let p = project-point(Q, v)
    (center.at(0) + scale * p.at(0), center.at(1) - scale * p.at(1))
  }
  (
    width: w,
    height: h,
    viewbox: viewbox,
    seed: seed,
    random: random,
    noise: noise,
    line: sketch-line,
    circle: sketch-circle,
    ellipse: sketch-ellipse,
    rect: sketch-rect,
    polyline: sketch-polyline,
    polygon: sketch-polygon,
    transform: sketch-transform,
    polar: sketch-polar,
    project3: project3,
  )
}

#let _sketch-svg-command(command, viewbox, scale) = {
  let kind = command.at("kind")
  if kind == "line" {
    let out = "<line x1=\"" + repr(calc.round(command.a.at(0), digits: 3))
    out += "\" y1=\"" + repr(calc.round(command.a.at(1), digits: 3))
    out += "\" x2=\"" + repr(calc.round(command.b.at(0), digits: 3))
    out += "\" y2=\"" + repr(calc.round(command.b.at(1), digits: 3))
    out += "\" " + _sketch-stroke(command.stroke, command.width, scale)
    if command.cap != auto { out += " stroke-linecap=\"" + command.cap + "\"" }
    out += "/>"
    return out
  }
  if kind == "circle" or kind == "ellipse" {
    let (cx, cy) = command.center
    let (rx, ry) = if kind == "circle" { (command.radius, command.radius) } else { command.radius }
    let out = "<ellipse cx=\"" + repr(calc.round(cx, digits: 3))
    out += "\" cy=\"" + repr(calc.round(cy, digits: 3))
    out += "\" rx=\"" + repr(calc.round(rx, digits: 3))
    out += "\" ry=\"" + repr(calc.round(ry, digits: 3)) + "\" "
    out += _sketch-fill(command.fill) + " " + _sketch-stroke(command.stroke, command.width, scale) + "/>"
    return out
  }
  if kind == "rect" {
    let (x, y) = command.position
    let (w, h) = command.size
    let out = "<rect x=\"" + repr(calc.round(x, digits: 3))
    out += "\" y=\"" + repr(calc.round(y, digits: 3))
    out += "\" width=\"" + repr(calc.round(w, digits: 3))
    out += "\" height=\"" + repr(calc.round(h, digits: 3))
    out += "\" rx=\"" + repr(calc.round(command.radius, digits: 3)) + "\" "
    out += _sketch-fill(command.fill) + " " + _sketch-stroke(command.stroke, command.width, scale) + "/>"
    return out
  }
  if kind == "polyline" {
    let tag = if command.closed { "polygon" } else { "polyline" }
    let out = "<" + tag + " points=\"" + _sketch-points(command.points) + "\" "
    out += _sketch-fill(command.fill) + " " + _sketch-stroke(command.stroke, command.width, scale) + "/>"
    return out
  }
  panic("sketch: unknown command " + repr(kind))
}

#let sketch(width: 10cm, height: 10cm, viewbox: (0.0, 0.0, 100.0, 100.0),
  seed: 0, background: none, projection: none, draw: none) = {
  let ctx = _sketch-context(viewbox, seed, projection)
  let output = if draw == none { () } else { draw(ctx) }
  let commands = if output == none { () } else if type(output) == array { output } else { (output,) }
  let (x0, y0, w, h) = viewbox
  context {
  let width-pt = width.to-absolute().pt()
  let scale = if w == 0 { 1.0 } else { width-pt / w }
  let body = ()
  if background != none {
    let bg = "<rect x=\"" + repr(x0)
    bg += "\" y=\"" + repr(y0)
    bg += "\" width=\"" + repr(w)
    bg += "\" height=\"" + repr(h)
    bg += "\" " + _sketch-fill(background) + "/>"
    body.push(bg)
  }
  for command in commands { body.push(_sketch-svg-command(command, viewbox, scale)) }
  let svg = "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"100%\" height=\"100%\" viewBox=\""
  svg += repr(x0) + " " + repr(y0) + " " + repr(w) + " " + repr(h) + "\">"
  svg += body.join() + "</svg>"
  image(bytes(svg), format: "svg", width: width, height: height, fit: "stretch")
  }
}
