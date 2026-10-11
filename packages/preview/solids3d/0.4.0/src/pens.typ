// pens.typ — Asymptote colours, pens, line types, materials and lights.

#import "vec.typ": *

// ---------------------------------------------------------------------------
// Colours (plain_pens.asy). rgb components in [0,1].
// ---------------------------------------------------------------------------
#let rgbf(r, g, b, a: 1.0) = rgb(clamp(r, 0, 1) * 100%, clamp(g, 0, 1) * 100%, clamp(b, 0, 1) * 100%, clamp(a, 0, 1) * 100%)
#let gray(x) = rgbf(x, x, x)
#let grey = gray

#let black = gray(0)
#let white = gray(1)
// Palette of the illustration styles.
#let vintage-paper = rgbf(0.953, 0.918, 0.851)
#let vintage-ink = rgbf(0.153, 0.129, 0.098)
#let vintage-pale-ink = rgbf(0.471, 0.416, 0.345)
#let vintage-wash = rgbf(0.72, 0.58, 0.39)
#let pencil-ink = rgbf(0.16, 0.17, 0.18)
#let red = rgbf(1, 0, 0)
#let green = rgbf(0, 1, 0)
#let blue = rgbf(0, 0, 1)
#let cyan = rgbf(0, 1, 1)
#let magenta = rgbf(1, 0, 1)
#let yellow = rgbf(1, 1, 0)

#let palered = rgbf(1, 0.75, 0.75)
#let palegreen = rgbf(0.75, 1, 0.75)
#let paleblue = rgbf(0.75, 0.75, 1)
#let palecyan = rgbf(0.75, 1, 1)
#let palemagenta = rgbf(1, 0.75, 1)
#let paleyellow = rgbf(1, 1, 0.75)
#let palegray = gray(0.95)

#let lightred = rgbf(1, 0.5, 0.5)
#let lightgreen = rgbf(0.5, 1, 0.5)
#let lightblue = rgbf(0.5, 0.5, 1)
#let lightcyan = rgbf(0.5, 1, 1)
#let lightmagenta = rgbf(1, 0.5, 1)
#let lightyellow = rgbf(1, 1, 0.5)
#let lightgray = gray(0.9)

#let mediumred = rgbf(1, 0.25, 0.25)
#let mediumgreen = rgbf(0.25, 1, 0.25)
#let mediumblue = rgbf(0.25, 0.25, 1)
#let mediumcyan = rgbf(0.25, 1, 1)
#let mediummagenta = rgbf(1, 0.25, 1)
#let mediumyellow = rgbf(1, 1, 0.25)
#let mediumgray = gray(0.75)

#let heavyred = rgbf(0.75, 0, 0)
#let heavygreen = rgbf(0, 0.75, 0)
#let heavyblue = rgbf(0, 0, 0.75)
#let heavycyan = rgbf(0, 0.75, 0.75)
#let heavymagenta = rgbf(0.75, 0, 0.75)
#let lightolive = rgbf(0.75, 0.75, 0)
#let heavygray = gray(0.25)

#let deepred = rgbf(0.5, 0, 0)
#let deepgreen = rgbf(0, 0.5, 0)
#let deepblue = rgbf(0, 0, 0.5)
#let deepcyan = rgbf(0, 0.5, 0.5)
#let deepmagenta = rgbf(0.5, 0, 0.5)
#let deepyellow = rgbf(0.5, 0.5, 0)
#let deepgray = gray(0.1)

#let darkred = rgbf(0.25, 0, 0)
#let darkgreen = rgbf(0, 0.25, 0)
#let darkblue = rgbf(0, 0, 0.25)
#let darkcyan = rgbf(0, 0.25, 0.25)
#let darkmagenta = rgbf(0.25, 0, 0.25)
#let darkolive = rgbf(0.25, 0.25, 0)
#let darkgray = gray(0.05)

#let orange = rgbf(1, 0.5, 0)
#let fuchsia = rgbf(1, 0, 0.5)
#let chartreuse = rgbf(0.5, 1, 0)
#let springgreen = rgbf(0, 1, 0.5)
#let purple = rgbf(0.5, 0, 1)
#let royalblue = rgbf(0, 0.5, 1)

#let salmon = lightred
#let brown = deepred
#let olive = deepyellow
#let darkbrown = darkred
#let pink = palemagenta
#let palegrey = palegray
#let lightgrey = lightgray
#let mediumgrey = mediumgray
#let heavygrey = heavygray
#let deepgrey = deepgray
#let darkgrey = darkgray

// Colour arithmetic helpers (Asymptote adds pens component-wise, e.g.
// lightgrey+white, paleblue+white).
#let rgba-of(c) = {
  let comps = c.rgb().components(alpha: true)
  comps.map(x => x / 100%)
}
#let from-rgba(v) = rgbf(v.at(0), v.at(1), v.at(2), a: v.at(3, default: 1.0))
#let color-add(a, b) = {
  let u = rgba-of(a)
  let v = rgba-of(b)
  rgbf(u.at(0) + v.at(0), u.at(1) + v.at(1), u.at(2) + v.at(2), a: calc.min(u.at(3), v.at(3)))
}
#let color-scale(k, a) = {
  let u = rgba-of(a)
  rgbf(k * u.at(0), k * u.at(1), k * u.at(2), a: u.at(3))
}
// Asymptote's opacity(x): a pen carrying only an opacity.
#let opacity(x) = (kind: "pen", opacity: float(x))
#let withopacity(c, x) = {
  let u = rgba-of(c)
  rgbf(u.at(0), u.at(1), u.at(2), a: x)
}

// ---------------------------------------------------------------------------
// Line types. Pattern lengths are multiples of the line width when
// scale is true (Asymptote's linetype()).
// ---------------------------------------------------------------------------
#let linetype(pattern, offset: 0, scale: true) = {
  let pat = if type(pattern) == str { pattern.split(" ").filter(s => s != "").map(float) } else { pattern.map(float) }
  (kind: "pen", dash: (pattern: pat, offset: float(offset), scale: scale))
}
#let solid = (kind: "pen", dash: none)
#let dotted = linetype((0, 4))
#let dashed = linetype((8, 8))
#let longdashed = linetype((24, 8))
#let dashdotted = linetype((8, 8, 0, 8))
#let longdashdotted = linetype((24, 8, 0, 8))
#let Dotted = (kind: "pen", dash: (pattern: (0.0, 3.0), offset: 0.0, scale: true), thickness-factor: 2)
#let defaultbackpen = linetype((4, 4), offset: 4, scale: false)

#let squarecap = (kind: "pen", cap: "butt")
#let roundcap = (kind: "pen", cap: "round")
#let extendcap = (kind: "pen", cap: "square")
#let miterjoin = (kind: "pen", join: "miter")
#let roundjoin = (kind: "pen", join: "round")
#let beveljoin = (kind: "pen", join: "bevel")

#let linewidth(w) = (kind: "pen", thickness: if type(w) == length { w } else { w * 1pt })
#let fontsize(s) = (kind: "pen", fontsize: if type(s) == length { s } else { s * 1pt })

#let nullpen = none
#let invisible = (kind: "pen", invisible: true)

// Asymptote defaults: linewidth 0.5bp, round caps and joins, 12pt fonts.
#let default-pen = (
  kind: "pen", paint: black, thickness: 0.5pt, dash: none, opacity: 1.0, cap: "round", join: "round", fontsize: 12pt, invisible: false,
)
#let currentpen = default-pen

#let is-pen(x) = type(x) == dictionary and x.at("kind", default: none) == "pen"

// Merge pen attributes (Asymptote's pen + pen).
#let pen-merge(a, b) = {
  let out = a
  for (k, v) in b {
    if k == "thickness-factor" {
      out.thickness = out.at("thickness", default: default-pen.thickness) * v
    } else if k != "kind" {
      out.insert(k, v)
    }
  }
  out
}

// Normalise anything pen-like into a pen dictionary (or none).
#let topen(x) = {
  if x == none { return none }
  if x == auto { return (kind: "pen") }
  if is-pen(x) { return x }
  if type(x) == color or type(x) == gradient or type(x) == tiling { return (kind: "pen", paint: x) }
  if type(x) == length { return (kind: "pen", thickness: x) }
  if type(x) == int or type(x) == float { return (kind: "pen", thickness: x * 1pt) }
  if type(x) == stroke {
    let p = (kind: "pen")
    if x.paint != auto { p.paint = x.paint }
    if x.thickness != auto { p.thickness = x.thickness }
    if x.dash != auto { p.dash = (typst: x.dash) }
    if x.cap != auto { p.cap = x.cap }
    if x.join != auto { p.join = x.join }
    return p
  }
  if type(x) == array { return x.map(topen).filter(p => p != none).fold((kind: "pen"), pen-merge) }
  if type(x) == dictionary { return (kind: "pen") + x }
  panic("cannot convert " + repr(x) + " to a pen")
}

// Build a pen from several attributes: pen(blue, 1pt, dashed).
#let pen(..items) = {
  let ps = items.pos().map(topen).filter(p => p != none)
  let out = ps.fold((kind: "pen"), pen-merge)
  for (k, v) in items.named() { out.insert(k, v) }
  out
}

// Complete a pen with defaults.
#let resolve-pen(x, default: default-pen) = {
  let p = topen(x)
  if p == none { return none }
  let out = default
  for (k, v) in p {
    if k == "thickness-factor" { out.thickness = out.thickness * v } else if k != "kind" { out.insert(k, v) }
  }
  out
}

// Paint of a pen including its opacity.
#let pen-paint(p) = {
  let c = p.at("paint", default: black)
  let op = p.at("opacity", default: 1.0)
  if op < 1 and type(c) == color {
    let u = rgba-of(c)
    rgbf(u.at(0), u.at(1), u.at(2), a: u.at(3) * op)
  } else { c }
}

// Convert a resolved pen into a Typst stroke.
#let pen-stroke(p) = {
  if p == none or p.at("invisible", default: false) { return none }
  let th = p.at("thickness", default: 0.5pt)
  let d = p.at("dash", default: none)
  let dash = none
  if d != none {
    if "typst" in d { dash = d.typst } else {
      let unit = if d.scale { th } else { 1pt }
      let arr = d.pattern.map(x => x * unit)
      if arr.len() > 0 and arr.any(x => x > 0pt) {
        dash = (array: arr, phase: d.offset * unit)
      }
    }
  }
  stroke(paint: pen-paint(p), thickness: th, dash: dash, cap: p.at("cap", default: "round"), join: p.at("join", default: "round"))
}

// Optional vector pencil strokes. The renderer expands a pencil pen into a
// filled, deterministic elliptical-nib envelope (and optional extra passes);
// The bundled elliptical-pen plugin returns polygons, so the result stays
// sharp and printable without raster texture.
#let pencil-pen(paint: black, thickness: 0.65pt, roughness: 0.10, passes: 1, seed: 0,
  opacity: 0.82, nib-major: 1.15, nib-angle: 24.0, nib-ratio: 0.42,
  pressure: none, samples: none, cap: "round", join: "round") = (
  kind: "pen",
  paint: paint,
  thickness: if type(thickness) == length { thickness } else { thickness * 1pt },
  opacity: float(opacity),
  cap: cap,
  join: join,
  pencil: (
    // Retained for API compatibility (the nib envelope does not apply a Typst wobble).
    roughness: float(roughness),
    passes: calc.max(1, int(passes)),
    seed: int(seed),
    nib-major: float(nib-major),
    nib-angle: float(nib-angle),
    nib-ratio: float(nib-ratio),
    pressure: pressure,
    samples: samples,
  ),
)

// Add pencil metadata to an existing pen while preserving its colour,
// width, dash pattern, and other normal pen attributes.
#let pencilize-pen(x, roughness: 0.10, passes: 1, seed: 0, opacity: 0.82,
  nib-major: 1.15, nib-angle: 24.0, nib-ratio: 0.42, pressure: none,
  samples: none) = {
  let p = resolve-pen(x)
  if p == none { return none }
  // Illustration styles normally promote every pen to the elliptical nib.
  // `plain: true` is the explicit opt-out for a conventional contour drawn
  // over a shaded, nib-filled surface.
  if p.at("plain", default: false) { return p }
  if p.at("pencil", default: none) != none { return p }
  p.pencil = (
    roughness: float(roughness),
    passes: calc.max(1, int(passes)),
    seed: int(seed),
    nib-major: float(nib-major),
    nib-angle: float(nib-angle),
    nib-ratio: float(nib-ratio),
    pressure: pressure,
    samples: samples,
  )
  p.opacity = p.at("opacity", default: 1.0) * float(opacity)
  p
}

// ---------------------------------------------------------------------------
// Materials (three_light.asy). A material is a dictionary with diffuse,
// emissive and specular colours, an opacity and a shininess.
// ---------------------------------------------------------------------------
#let default-shininess = 0.7

#let is-material(m) = type(m) == dictionary and m.at("kind", default: none) == "material"

#let material(diffuse: black, emissive: black, specular: mediumgray, opacity: auto, shininess: default-shininess,
  diffusepen: none, emissivepen: none, specularpen: none) = {
  // accept Asymptote's parameter names as aliases
  let d = if diffusepen != none { diffusepen } else { diffuse }
  let e = if emissivepen != none { emissivepen } else { emissive }
  let s = if specularpen != none { specularpen } else { specular }
  let dp = resolve-pen(d)
  let dcol = if dp == none { none } else { dp.at("paint", default: black) }
  let op = if opacity == auto {
    if dp == none { 1.0 } else { rgba-of(pen-paint(dp)).at(3) }
  } else { float(opacity) }
  (
    kind: "material",
    diffuse: if dcol == none { black } else { dcol },
    emissive: resolve-pen(e).at("paint", default: black),
    specular: resolve-pen(s).at("paint", default: mediumgray),
    opacity: op,
    shininess: float(shininess),
    invisible: dp == none or dp.at("invisible", default: false),
  )
}

// Convert a colour / pen / material into a material.
#let tomaterial(x) = {
  if x == none { return material(diffuse: none) }
  if is-material(x) { return x }
  let p = resolve-pen(x)
  if p == none { return material(diffuse: none) }
  let col = pen-paint(p)
  material(diffuse: col, opacity: rgba-of(col).at(3))
}

// ---------------------------------------------------------------------------
// Lights (plain_prethree.asy / three_light.asy). Directions are given in
// the viewport (camera) frame unless viewport: false.
// ---------------------------------------------------------------------------
#let is-light(l) = type(l) == dictionary and l.at("kind", default: none) == "light"

// light(diffuse: white, specular: diffuse, specularfactor: 1, background: none, ..positions)
// or light(x, y, z)
#let light(..args, diffuse: auto, specular: auto, specularfactor: 1, background: none, viewport: true) = {
  let a = args.pos()
  // positional colours (pens) come first: light(diffuse, specular, ..positions)
  let cols = a.filter(x => not is-triple(x) and not is-num(x))
  a = a.filter(x => is-triple(x) or is-num(x))
  if diffuse == auto { diffuse = if cols.len() > 0 { cols.at(0) } else { white } }
  if specular == auto and cols.len() > 1 { specular = cols.at(1) }
  let positions = if a.len() == 3 and is-num(a.at(0)) { ((a.at(0), a.at(1), a.at(2)),) } else { a }
  let n = positions.len()
  let diff = if type(diffuse) == array { diffuse } else { range(n).map(_ => diffuse) }
  let spec = if specular == auto { diff } else if type(specular) == array { specular } else { range(n).map(_ => specular) }
  (
    kind: "light",
    diffuse: diff.map(c => rgba-of(resolve-pen(c).paint)),
    specular: spec.map(c => rgba-of(resolve-pen(c).paint)),
    position: positions.map(v => vunit(v.map(float))),
    specularfactor: float(specularfactor),
    background: background,
    viewport: viewport,
  )
}

#let nolight = (kind: "light", diffuse: (), specular: (), position: (), specularfactor: 1.0, background: none, viewport: true)

#let Viewport = light(specularfactor: 3, (0.25, -0.25, 1))
#let White = light(
  diffuse: (rgbf(0.38, 0.38, 0.45), rgbf(0.6, 0.6, 0.67), rgbf(0.5, 0.5, 0.57)),
  specularfactor: 3,
  (-2, -1.5, -0.5), (2, 1.1, -2.5), (-0.5, 0, 2),
)
#let Headlamp = light(diffuse: white, specular: gray(0.7), specularfactor: 3, vdir(42, 48))
#let currentlight = Headlamp

// Convert a triple into a light (Asymptote casts triples to lights).
#let tolight(x) = {
  if x == none { nolight } else if is-light(x) { x } else if is-triple(x) { light(x) } else { panic("not a light: " + repr(x)) }
}

// Shaded colour of a surface element with the given normal (in world
// coordinates), material and light. `modelview` maps world to camera space.
#let shade(normal, m, l, modelview) = {
  if m.invisible { return none }
  let alpha = m.opacity
  if l.position.len() == 0 {
    let u = rgba-of(m.diffuse)
    return rgbf(u.at(0), u.at(1), u.at(2), a: alpha)
  }
  // Work in the camera frame (x right, y up, z toward the viewer).
  let n = vunit(tvector(modelview, normal))
  // two-sided lighting: flip the normal toward the viewer
  if n.at(2) < 0 { n = vneg(n) }
  let s = m.shininess * 128
  let D = rgba-of(m.diffuse)
  let S = rgba-of(m.specular)
  let E = rgba-of(m.emissive)
  let r = E.at(0)
  let g = E.at(1)
  let b = E.at(2)
  let dr = 0.0
  let dg = 0.0
  let db = 0.0
  let sr = 0.0
  let sg = 0.0
  let sb = 0.0
  for i in range(l.position.len()) {
    let L = if l.viewport { l.position.at(i) } else { vunit(tvector(modelview, l.position.at(i))) }
    let dp = calc.abs(vdot(n, L))
    let ld = l.diffuse.at(i)
    dr += dp * ld.at(0)
    dg += dp * ld.at(1)
    db += dp * ld.at(2)
    let h = calc.abs(vdot(n, vunit(vadd(L, Z))))
    let sp = calc.pow(h, s)
    let ls = l.specular.at(i)
    sr += sp * ls.at(0)
    sg += sp * ls.at(1)
    sb += sp * ls.at(2)
  }
  let f = l.specularfactor
  r += dr * D.at(0) + sr * S.at(0) * f
  g += dg * D.at(1) + sg * S.at(1) * f
  b += db * D.at(2) + sb * S.at(2) * f
  rgbf(r, g, b, a: alpha)
}

// Precompute the numeric components of a material (for shade-fast).
#let material-components(m) = (
  D: rgba-of(m.diffuse), S: rgba-of(m.specular), E: rgba-of(m.emissive), alpha: m.opacity,
  s: m.shininess * 128, invisible: m.invisible,
)

// Shaded colour of a surface element; `mc` comes from material-components,
// `mv` is the modelview matrix. Inlined arithmetic (one call per patch).
#let shade-fast(normal, mc, l, mv) = {
  if mc.invisible { return none }
  let D = mc.D
  let alpha = mc.alpha
  if l.position.len() == 0 { return rgbf(D.at(0), D.at(1), D.at(2), a: alpha) }
  let (r0, r1, r2, r3) = mv
  let (x, y, z) = normal
  let nx = r0.at(0) * x + r0.at(1) * y + r0.at(2) * z
  let ny = r1.at(0) * x + r1.at(1) * y + r1.at(2) * z
  let nz = r2.at(0) * x + r2.at(1) * y + r2.at(2) * z
  let nn = calc.sqrt(nx * nx + ny * ny + nz * nz)
  if nn == 0 { nn = 1e-300 }
  if nz < 0 { nn = -nn }
  nx = nx / nn
  ny = ny / nn
  nz = nz / nn
  let s = mc.s
  let S = mc.S
  let E = mc.E
  let r = E.at(0)
  let g = E.at(1)
  let b = E.at(2)
  let dr = 0.0
  let dg = 0.0
  let db = 0.0
  let sr = 0.0
  let sg = 0.0
  let sb = 0.0
  for i in range(l.position.len()) {
    let (lx, ly, lz) = l.position.at(i)
    if not l.viewport {
      let (tx, ty, tz) = (lx, ly, lz)
      lx = r0.at(0) * tx + r0.at(1) * ty + r0.at(2) * tz
      ly = r1.at(0) * tx + r1.at(1) * ty + r1.at(2) * tz
      lz = r2.at(0) * tx + r2.at(1) * ty + r2.at(2) * tz
      let ln = calc.sqrt(lx * lx + ly * ly + lz * lz)
      if ln > 0 { lx = lx / ln; ly = ly / ln; lz = lz / ln }
    }
    let dp = calc.abs(nx * lx + ny * ly + nz * lz)
    let ld = l.diffuse.at(i)
    dr += dp * ld.at(0)
    dg += dp * ld.at(1)
    db += dp * ld.at(2)
    // Blinn-Phong half vector unit(L + Z)
    let hz = lz + 1
    let hn = calc.sqrt(lx * lx + ly * ly + hz * hz)
    if hn == 0 { hn = 1e-300 }
    let h = calc.abs((nx * lx + ny * ly + nz * hz) / hn)
    let sp = calc.pow(h, s)
    let ls = l.specular.at(i)
    sr += sp * ls.at(0)
    sg += sp * ls.at(1)
    sb += sp * ls.at(2)
  }
  let f = l.specularfactor
  r += dr * D.at(0) + sr * S.at(0) * f
  g += dg * D.at(1) + sg * S.at(1) * f
  b += db * D.at(2) + sb * S.at(2) * f
  rgbf(r, g, b, a: alpha)
}

// Shaded colours (as (r, g, b) triples in [0, 1]) of several normals at
// once; `mc` comes from material-components, `mv` is the modelview matrix.
// Used for the corner colours of smoothly shaded patches (one call per
// patch, inline arithmetic on purpose).
#let shade-many(normals, mc, l, mv) = {
  if mc.invisible { return none }
  let D = mc.D
  let np = l.position.len()
  if np == 0 {
    let c = (calc.max(0, calc.min(1, D.at(0))), calc.max(0, calc.min(1, D.at(1))), calc.max(0, calc.min(1, D.at(2))))
    return normals.map(_ => c)
  }
  let (r0, r1, r2, r3) = mv
  let (a0, a1, a2) = (r0.at(0), r0.at(1), r0.at(2))
  let (b0, b1, b2) = (r1.at(0), r1.at(1), r1.at(2))
  let (c0, c1, c2) = (r2.at(0), r2.at(1), r2.at(2))
  // lights in the camera frame, with their Blinn-Phong half vectors
  let lights = ()
  for i in range(np) {
    let (lx, ly, lz) = l.position.at(i)
    if not l.viewport {
      let (tx, ty, tz) = (lx, ly, lz)
      lx = a0 * tx + a1 * ty + a2 * tz
      ly = b0 * tx + b1 * ty + b2 * tz
      lz = c0 * tx + c1 * ty + c2 * tz
      let ln = calc.sqrt(lx * lx + ly * ly + lz * lz)
      if ln > 0 { lx = lx / ln; ly = ly / ln; lz = lz / ln }
    }
    let hz = lz + 1
    let hn = calc.sqrt(lx * lx + ly * ly + hz * hz)
    if hn == 0 { hn = 1e-300 }
    lights.push((lx, ly, lz, lx / hn, ly / hn, hz / hn, l.diffuse.at(i), l.specular.at(i)))
  }
  let s = mc.s
  let S = mc.S
  let E = mc.E
  let f = l.specularfactor
  let out = ()
  for nv in normals {
    let (x, y, z) = nv
    let nx = a0 * x + a1 * y + a2 * z
    let ny = b0 * x + b1 * y + b2 * z
    let nz = c0 * x + c1 * y + c2 * z
    let nn = calc.sqrt(nx * nx + ny * ny + nz * nz)
    if nn == 0 { nn = 1e-300 }
    nx = nx / nn
    ny = ny / nn
    nz = nz / nn
    let dr = 0.0
    let dg = 0.0
    let db = 0.0
    let sr = 0.0
    let sg = 0.0
    let sb = 0.0
    for (lx, ly, lz, hx, hy, hz, ld, ls) in lights {
      let dp = calc.abs(nx * lx + ny * ly + nz * lz)
      dr += dp * ld.at(0)
      dg += dp * ld.at(1)
      db += dp * ld.at(2)
      let sp = calc.pow(calc.abs(nx * hx + ny * hy + nz * hz), s)
      sr += sp * ls.at(0)
      sg += sp * ls.at(1)
      sb += sp * ls.at(2)
    }
    let r = E.at(0) + dr * D.at(0) + sr * S.at(0) * f
    let g = E.at(1) + dg * D.at(1) + sg * S.at(1) * f
    let b = E.at(2) + db * D.at(2) + sb * S.at(2) * f
    out.push((calc.max(0, calc.min(1, r)), calc.max(0, calc.min(1, g)), calc.max(0, calc.min(1, b))))
  }
  out
}
