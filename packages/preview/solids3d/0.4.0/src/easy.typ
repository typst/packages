// easy.typ — the simple layer: one function, `fig`, turns solids, surfaces, curves and knots into a finished figure.
//
//   #fig(sphere(1))                                   // a shaded sphere
//   #fig(torus(1, 0.4), style: "banknote")            // an engraved torus
//   #fig(trefoil(), style: "engraving")               // a knot
//   #fig(cone(1, 2), brace3((0, 0, 0), (0, 0, 2), $h$))
#import "picture.typ": picture, draw
#import "surface.typ": surface, surface-mesh, is-revolution
#import "solids.typ": silhouette
#import "projection.typ": orthographic, perspective, is-projection
#import "pens.typ": light as make-light, linewidth
#import "path3.typ": is-path3, box3
#import "engrave.typ": engraving, engraving-ink, engraving-paper
#import "engraved.typ": engraved
#import "knots.typ": knot3

// Camera angles (azimuth, elevation) in degrees of the named views.
#let _views = (
  iso: (39, 25), front: (-90, 8), back: (90, 8), side: (0, 8), left: (180, 8), top: (-90, 89), bottom: (-90, -89),
  low: (39, 8), high: (39, 55),
)

/// Projection of a named view or of `(azimuth, elevation)` angles (degrees). `persp: true` gives a perspective view.
#let view-projection(v, persp: false) = {
  if is-projection(v) { return v }
  let (az, el) = if type(v) == str {
    assert(v in _views, message: "fig: unknown view \"" + v + "\" (iso, front, back, side, left, top, bottom, low, high or (azimuth, elevation))")
    _views.at(v)
  } else { v }
  let k = if persp { 9 } else { 5 }
  let x = k * calc.cos(el * 1deg) * calc.cos(az * 1deg)
  let y = k * calc.cos(el * 1deg) * calc.sin(az * 1deg)
  let z = k * calc.sin(el * 1deg)
  if persp { perspective(x, y, z) } else { orthographic(x, y, z) }
}

/// A solid or surface with a colour: `fig(paint(sphere(1), orange))`.
#let paint(shape, color) = (kind: "painted", shape: shape, color: color)

/// Cube of side `a` centred on `c`. `brick(l, w, h, c:)`: rectangular block.
#let brick(l, w, h, c: (0, 0, 0)) = {
  let (x0, y0, z0) = (c.at(0) - l / 2, c.at(1) - w / 2, c.at(2) - h / 2)
  let (x1, y1, z1) = (c.at(0) + l / 2, c.at(1) + w / 2, c.at(2) + h / 2)
  let vs = ()
  for k in (z0, z1) { for j in (y0, y1) { for i in (x0, x1) { vs.push((i, j, k)) } } }
  let out = surface-mesh(vs, ((0, 4, 6, 2), (1, 3, 7, 5), (0, 1, 5, 4), (2, 6, 7, 3), (0, 2, 3, 1), (4, 5, 7, 6)), smooth: false)
  out.box = ((x0, y0, z0), (x1, y1, z1))
  out
}
#let cube(a, c: (0, 0, 0)) = brick(a, a, a, c: c)

#let engraving-fn = engraving
#let _is-cmd(x) = type(x) == dictionary and "cmd" in x

// Turn any item given to `fig` into picture commands.
#let _item(x, o) = {
  if type(x) == function { return knot3(x, width: o.tube, style: o.knot-style, samples: 140) }
  if type(x) == array {
    if x.len() > 0 and x.all(e => type(e) == function) { return knot3(..x, width: o.tube, style: o.knot-style, samples: 140) }
    return x.map(e => _item(e, o))
  }
  if type(x) != dictionary { return () }
  if _is-cmd(x) { return x }
  let kind = x.at("kind", default: none)
  let (shape, color) = if kind == "painted" { (x.shape, x.color) } else { (x, none) }
  let skind = shape.at("kind", default: none)
  let color = if color == none and o.default-color != none { o.default-color } else { color }
  if is-revolution(shape) {
    if o.engr { return engraved(shape, rim: o.rim, color: color) }
    let out = (draw(surface(shape), ..(if color == none { () } else { (color,) })),)
    if o.rim != none { out.push(draw(silhouette(shape, m: 48), o.rim)) }
    return out
  }
  if skind == "surface" {
    let out = (draw(surface(shape), ..(if color == none { () } else { (color,) })),)
    if "box" in shape and o.rim != none { out.push(draw(box3(..shape.box), o.rim)) }
    return out
  }
  if is-path3(shape) { return draw(shape, if color == none { linewidth(0.8) } else { color }) }
  ()
}


/// Finished figure. Items: solids (`sphere`, `cone`, `torus`, `cube`…), surfaces, 3D paths, knot curves (`trefoil()`),
/// `paint(shape, colour)`, and commands such as `brace3(...)`, `draw(...)`, `label3(...)`.
/// - `size`: width of the figure. `view`: `"iso"` (default), `"front"`, `"top"`, `"side"`, `"low"`, `"high"`… or `(azimuth, elevation)` in degrees.
/// - `style`: `"shaded"` (default), `"engraving"`, `"banknote"` (wavy lines), `"etching"` (blue ink), `"vintage"`, `"pencil"`.
/// - `rim`: pen of the contours (`auto`, `none`, or a pen). `persp`: perspective view. `light`: `auto` or a light.
/// - `tube`, `knot-style`: width and style (`"weave"`/`"gap"`) of the knots. `engraving`: an `engraving(...)` to tune the lines.
/// Any other option is passed to `picture`.
#let fig(..args) = {
  let nm = args.named()
  let size = nm.at("size", default: 6cm)
  let view = nm.at("view", default: "iso")
  let style = nm.at("style", default: "shaded")
  let light = nm.at("light", default: auto)
  let rim = nm.at("rim", default: auto)
  let persp = nm.at("persp", default: false)
  let tube = nm.at("tube", default: 7pt)
  let knot-style = nm.at("knot-style", default: "weave")
  let engraving = nm.at("engraving", default: auto)
  let opts = nm
  for k in ("size", "view", "style", "light", "rim", "persp", "tube", "knot-style", "engraving") { if k in opts { let _ = opts.remove(k) } }
  assert(style in ("shaded", "engraving", "banknote", "etching", "vintage", "pencil"),
    message: "fig: style must be \"shaded\", \"engraving\", \"banknote\", \"etching\", \"vintage\" or \"pencil\"")
  let engr = style in ("engraving", "banknote", "etching")
  let spec = if engraving != auto { engraving } else if style == "banknote" {
    engraving-fn(wave: (amplitude: 0.45pt, length: 11pt, shift: 0.35), angle: 20, spacing: 2.4pt)
  } else if style == "etching" {
    engraving-fn(paper: white, ink: rgb("#1c3d7a"), angle: 55, spacing: 2.8pt, cross: false)
  } else { auto }
  let o = (default-color: if style == "shaded" { rgb("#8fb4e3") } else { none }, engr: engr, tube: tube, knot-style: knot-style, rim: if rim == auto { linewidth(0.8) } else { rim })
  // all curves given to `fig` form ONE knot / link (so that their crossings are detected)
  let curves = ()
  let rest = ()
  for x in args.pos() {
    if type(x) == function { curves.push(x) }
    else if type(x) == array and x.len() > 0 and x.all(e => type(e) == function) { curves += x }
    else { rest.push(x) }
  }
  let cmds = rest.map(x => _item(x, o))
  if curves.len() > 0 { cmds.push(knot3(..curves, width: tube, style: knot-style, samples: 140)) }
  picture(..cmds, size: size, projection: view-projection(view, persp: persp),
    light: if light == auto { make-light((-1, 0.9, 1.1)) } else { light },
    style: if engr { "engraving" } else if style == "shaded" { "none" } else { style },
    engraving: spec, ..opts)
}
