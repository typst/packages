// picture.typ — drawing commands and the 2D renderer.
//
// Drawing functions (draw, dot, label, xaxis3, ...) return arrays of
// command dictionaries; `picture(..commands)` projects everything with a
// projection, sorts patches by depth and lays the result out as a box.

#import "vec.typ": *
#import "path3.typ": *
#import "path2.typ"
#import "nibridge.typ" as nibridge
#import "knots.typ": knot-prims
#import "braces.typ": brace-prims
#import "engrave.typ": engrave-prims, engraving as make-engraving, engraving-paper
#import "projection.typ": *
#import "pens.typ": *
#import "surface.typ": *
#import "solids.typ": *

// Asymptote constants
#let dotfactor = 6
#let arrowfactor = 15
#let arrowangle = 15
#let labelmargin-factor = 0.28
// width (pt) of the same-colour stroke drawn around opaque patches to hide
// the anti-aliasing hairlines between adjacent patches
#let seam-width = 0.5

// 2D alignment directions (pairs)
#let E = (1.0, 0.0)
#let N = (0.0, 1.0)
#let W = (-1.0, 0.0)
#let S = (0.0, -1.0)
#let NE = (0.7071067811865476, 0.7071067811865476)
#let NW = (-0.7071067811865476, 0.7071067811865476)
#let SE = (0.7071067811865476, -0.7071067811865476)
#let SW = (-0.7071067811865476, -0.7071067811865476)
#let ENE = (0.9238795325112867, 0.3826834323650898)
#let NNE = (0.3826834323650898, 0.9238795325112867)
#let NNW = (-0.3826834323650898, 0.9238795325112867)
#let WNW = (-0.9238795325112867, 0.3826834323650898)
#let WSW = (-0.9238795325112867, -0.3826834323650898)
#let SSW = (-0.3826834323650898, -0.9238795325112867)
#let SSE = (0.3826834323650898, -0.9238795325112867)
#let ESE = (0.9238795325112867, -0.3826834323650898)
#let Center = (0.0, 0.0)
#let pair-scale(k, a) = (k * a.at(0), k * a.at(1))

// ---------------------------------------------------------------------------
// Tokens
// ---------------------------------------------------------------------------
#let is-cmd(x) = type(x) == dictionary and "cmd" in x
#let is-label(x) = type(x) == dictionary and x.at("kind", default: none) == "label"
#let is-arrow(x) = type(x) == dictionary and x.at("kind", default: none) == "arrow"
#let is-deferred(x) = type(x) == dictionary and x.at("kind", default: none) == "deferred"
#let is-content(x) = type(x) == content or type(x) == str

// Label(body, position: auto, align: auto, rotate: none, dx: 0, dy: 0):
// position is a relative time along a path (0 = start, 1 = end) for path and
// axis labels. `rotate: auto` follows the projected tangent when the label is
// attached to a path. Numeric dx/dy values use picture units; Typst lengths
// such as 3pt are also accepted and stay absolute. Positive dy goes upward in
// the projected drawing coordinate system.
#let Label(body, ..args, position: auto, align: auto, rotate: none, dx: 0, dy: 0, center: false) = {
  for x in args.pos() {
    if is-num(x) { position = x } else if is-pair(x) { align = x }
  }
  (kind: "label", body: body, position: position, align: align, rotate: rotate,
    dx: dx, dy: dy, center: center)
}

// Arrow tokens: Arrow3 (a shaded 3D cone, like Asymptote's DefaultHead3),
// Arrow (a flat 2D head). arrow3(size: 7.5pt, angle: 15, style: "cone")
#let arrow3(size: auto, angle: arrowangle, position: "end", style: "cone") = (kind: "arrow", size: size, angle: angle, position: position, style: style)
#let Arrow3 = arrow3()
#let BeginArrow3 = arrow3(position: "begin")
#let Arrows3 = arrow3(position: "both")
#let Arrow = arrow3(style: "flat")
#let BeginArrow = arrow3(position: "begin", style: "flat")
#let Arrows = arrow3(position: "both", style: "flat")

// Deferred computations (evaluated with the picture's projection).
#let deferred(f) = (kind: "deferred", f: f)

// ---------------------------------------------------------------------------
// Commands
// ---------------------------------------------------------------------------
#let flatten-cmds(xs) = {
  let out = ()
  for x in xs {
    if is-cmd(x) { out.push(x) } else if type(x) == array { out += flatten-cmds(x) } else if x == none { } else {
      panic("not a drawing command: " + repr(x))
    }
  }
  out
}

// limits(min, max): axis limits for xaxis3/yaxis3/zaxis3.
#let limits(m, M) = ((cmd: "limits", min: m.map(float), max: M.map(float)),)

// Is x a pen-like value (colour, stroke, pen or material dictionary...)?
#let is-penlike(x) = x == none or is-pen(x) or is-material(x) or type(x) in (color, stroke, length, float, gradient, tiling)
// An array of pens (one material per patch)
#let is-pen-array(x) = type(x) == array and x.len() > 0 and not is-pair(x) and x.all(e => is-penlike(e) and type(e) != float and e != none)

// Classify positional arguments of draw()/dot()/label().
#let classify(args) = {
  let out = (pens: (), ints: (), labels: (), arrows: (), lights: (), aligns: (), others: ())
  for x in args {
    if is-label(x) or is-content(x) { out.labels.push(if is-label(x) { x } else { Label(x) }) } else if is-arrow(x) { out.arrows.push(x) } else if is-light(x) { out.lights.push(x) } else if type(x) == int { out.ints.push(x) } else if is-pair(x) { out.aligns.push(x) } else if is-penlike(x) or is-pen-array(x) { out.pens.push(x) } else { out.others.push(x) }
  }
  out
}

// draw(object, ..) — object may be a path3, an array of path3, a surface,
// a revolution, a deferred object or an existing command list.
#let is-drawable(x) = is-path3(x) or is-surface(x) or is-patch(x) or is-revolution(x) or is-deferred(x) or is-cmd(x) or is-triple(x) or (type(x) == array and not is-pair(x) and not is-pen-array(x))

#let draw(..args, pen: auto, surfacepen: auto, arrow: none, label: none, align: auto, light: auto, meshpen: none,
  m: auto, n: nslice, frontpen: auto, backpen: auto, longitudinalpen: auto, longitudinalbackpen: auto,
  ninterpolate: auto, seam: auto, hatch: auto, stipple: auto) = {
  if surfacepen != auto { pen = surfacepen }
  // the object is the first drawable positional argument (Asymptote allows
  // a Label before the path: draw(Label("x"), g, red, Arrow3))
  let pos = args.pos()
  let k = pos.position(is-drawable)
  if k == none { panic("draw: nothing to draw in " + repr(pos)) }
  let obj = pos.at(k)
  let rest = pos.slice(0, k) + pos.slice(k + 1)
  let c = classify(rest)
  if c.labels.len() > 0 and label == none { label = c.labels.at(0) }
  if c.arrows.len() > 0 and arrow == none { arrow = c.arrows.at(0) }
  if arrow == true { arrow = Arrow3 }
  if c.lights.len() > 0 and light == auto { light = c.lights.at(0) }
  if align == auto and c.aligns.len() > 0 { align = c.aligns.at(0) }
  if label != none and align != auto { label.align = align }
  if is-triple(obj) { obj = line3(obj, obj) }
  if is-path3(obj) {
    let p = if pen == auto { if c.pens.len() > 0 { c.pens.at(0) } else { auto } } else { pen }
    return ((cmd: "path", g: obj, pen: p, arrow: arrow, label: label, ninterpolate: ninterpolate),)
  }
  if is-surface(obj) or is-patch(obj) {
    let s = if is-patch(obj) { surface(obj) } else { obj }
    let mat = if pen == auto { if c.pens.len() > 0 { c.pens.at(0) } else { auto } } else { pen }
    let mp = if meshpen == none and c.pens.len() > 1 { c.pens.at(1) } else { meshpen }
    return ((cmd: "surface", s: s, material: mat, meshpen: mp, light: light, seam: seam, hatch: hatch, stipple: stipple),)
  }
  if is-revolution(obj) {
    let fp = if frontpen == auto { if c.pens.len() > 0 { c.pens.at(0) } else { if pen == auto { auto } else { pen } } } else { frontpen }
    let bp = if backpen == auto { if c.pens.len() > 1 { c.pens.at(1) } else { auto } } else { backpen }
    let mm = if m == auto { if c.ints.len() > 0 { c.ints.at(0) } else { 0 } } else { m }
    let nn = if c.ints.len() > 1 { c.ints.at(1) } else { n }
    return ((cmd: "revolution", r: obj, m: mm, n: nn, frontpen: fp, backpen: bp, longitudinalpen: longitudinalpen, longitudinalbackpen: longitudinalbackpen),)
  }
  if is-deferred(obj) {
    let p = if pen == auto { if c.pens.len() > 0 { c.pens.at(0) } else { auto } } else { pen }
    return ((cmd: "deferred", f: obj.f, pen: p, arrow: arrow, label: label),)
  }
  if is-cmd(obj) { return (obj,) }
  if type(obj) == array {
    if obj.len() == 0 { return () }
    if obj.all(is-cmd) { return obj }
    let out = ()
    for x in obj {
      out += draw(x, ..rest, pen: pen, arrow: arrow, label: label, align: align, light: light, meshpen: meshpen, m: m, n: n,
        frontpen: frontpen, backpen: backpen, longitudinalpen: longitudinalpen, longitudinalbackpen: longitudinalbackpen, ninterpolate: ninterpolate, seam: seam, hatch: hatch, stipple: stipple)
    }
    return out
  }
  panic("draw: cannot draw " + repr(obj))
}

// fill a planar path (a surface without lighting)
#let fill3(g, ..args, pen: auto, stipple: auto) = {
  let c = classify(args.pos())
  let p = if pen == auto { if c.pens.len() > 0 { c.pens.at(0) } else { auto } } else { pen }
  ((cmd: "surface", s: surface(g), material: p, meshpen: none, light: nolight, seam: auto, stipple: stipple),)
}

// dot(v), dot(v, pen), dot(label, v, align, pen), dot(path3), dot(triple[])
#let dot(..args, pen: auto, label: none, align: auto, size: auto) = {
  let pos = ()
  let c = classify(args.pos())
  for x in c.others {
    if is-triple(x) { pos.push(x) } else if is-path3(x) { pos += nodes3(x) } else if type(x) == array { pos += nodes3(x) }
  }
  let p = if pen == auto { if c.pens.len() > 0 { c.pens.at(0) } else { auto } } else { pen }
  let L = if label != none { if is-label(label) { label } else { Label(label) } } else if c.labels.len() > 0 { c.labels.at(0) } else { none }
  if L != none {
    let al = if align != auto { align } else if c.aligns.len() > 0 { c.aligns.at(0) } else if L.align != auto { L.align } else { E }
    L.align = al
  }
  pos.map(v => (cmd: "dot", v: v.map(float), pen: p, label: L, size: size))
}

// label(body, v, align, pen)
#let label(body, v, ..args, align: auto, pen: auto) = {
  let c = classify(args.pos())
  let al = if align != auto { align } else if c.aligns.len() > 0 { c.aligns.at(0) } else { Center }
  let p = if pen == auto { if c.pens.len() > 0 { c.pens.at(0) } else { auto } } else { pen }
  let L = if is-label(body) { body } else { Label(body) }
  if L.align == auto { L.align = al }
  ((cmd: "label", v: v.map(float), label: L, pen: p),)
}

// Axes: xaxis3(label, pen, Arrow3, min: , max: )
#let axis3(which, args, pen, arrow, label, min, max) = {
  let c = classify(args)
  let L = if label != none { if is-label(label) { label } else { Label(label) } } else if c.labels.len() > 0 { c.labels.at(0) } else { none }
  let p = if pen == auto { if c.pens.len() > 0 { c.pens.at(0) } else { auto } } else { pen }
  let ar = if arrow == none { if c.arrows.len() > 0 { c.arrows.at(0) } else { none } } else { arrow }
  if ar == true { ar = Arrow3 }
  ((cmd: "axis", axis: which, pen: p, arrow: ar, label: L, min: min, max: max),)
}
#let xaxis3(..args, pen: auto, arrow: none, label: none, min: auto, max: auto) = axis3("x", args.pos(), pen, arrow, label, min, max)
#let yaxis3(..args, pen: auto, arrow: none, label: none, min: auto, max: auto) = axis3("y", args.pos(), pen, arrow, label, min, max)
#let zaxis3(..args, pen: auto, arrow: none, label: none, min: auto, max: auto) = axis3("z", args.pos(), pen, arrow, label, min, max)
#let axes3(..args, xlabel: $x$, ylabel: $y$, zlabel: $z$, pen: auto, arrow: Arrow3, min: auto, max: auto) = {
  xaxis3(xlabel, ..args, pen: pen, arrow: arrow, min: min, max: max) + yaxis3(ylabel, ..args, pen: pen, arrow: arrow, min: min, max: max) + zaxis3(zlabel, ..args, pen: pen, arrow: arrow, min: min, max: max)
}

// ---------------------------------------------------------------------------
// Generic transform application: apply(T, object)
// ---------------------------------------------------------------------------
#let apply(T, obj) = {
  if is-triple(obj) { tpoint(T, obj) } else if is-path3(obj) { transform-path3(T, obj) } else if is-surface(obj) { transform-surface(T, obj) } else if is-patch(obj) { transform-patch(T, obj) } else if is-revolution(obj) { transform-revolution(T, obj) } else if type(obj) == array { obj.map(x => apply(T, x)) } else if is-transform(obj) { tmul(T, obj) } else { panic("apply: unsupported object " + repr(obj)) }
}

// ---------------------------------------------------------------------------
// Renderer
// ---------------------------------------------------------------------------
#let rectify(d) = {
  let sc = calc.max(calc.abs(d.at(0)), calc.abs(d.at(1)))
  let v = if sc != 0 { pair-scale(0.5 / sc, d) } else { (0.0, 0.0) }
  (v.at(0) + 0.5, v.at(1) + 0.5)
}

// 3D bounds of a command list (for automatic axis limits).
#let bounds3(cmds) = {
  let pts = ()
  for c in cmds {
    if c.cmd == "path" { pts.push(min3(c.g)); pts.push(max3(c.g)) } else if c.cmd == "surface" {
      let (a, b) = surface-bounds(c.s)
      pts.push(a)
      pts.push(b)
    } else if c.cmd == "dot" or c.cmd == "label" { pts.push(c.v) } else if c.cmd == "brace3" {
      pts.push(c.a)
      pts.push(c.b)
    } else if c.cmd == "knot3" {
      for st in c.pts { for v in st { pts.push(v) } }
    } else if c.cmd == "revolution" {
      for k in range(4) {
        let g = transform-path3(rotate3(90 * k, c.r.c, v: vadd(c.r.c, c.r.axis)), c.r.g)
        pts.push(min3(g))
        pts.push(max3(g))
      }
    }
  }
  if pts.len() == 0 { return (O, O) }
  let m = pts.fold((float.inf, float.inf, float.inf), vmin)
  let M = pts.fold((-float.inf, -float.inf, -float.inf), vmax)
  (m, M)
}

// 2D arc length helpers for arrowheads
#let arclength2-seg(a, b, c, d) = {
  let sum = 0.0
  for i in range(8) {
    sum += gl-weights.at(i) * path2.pabs(path2.bez2-deriv(a, b, c, d, gl-nodes.at(i)))
  }
  sum
}

// Shorten a 2D path by `len` (in user units) at its end (from-end) or start.
#let shorten2(p, len, from-end) = {
  if len <= 0 { return p }
  let q = if from-end { p } else {
    (kind: "path", nodes: p.nodes.rev(), pre: p.post.rev(), post: p.pre.rev(), straight: p.straight.rev(), cyclic: false)
  }
  // walk back from the end
  let L = path2.length2(q)
  let remaining = len
  let cut-seg = L - 1
  let cut-t = 0.0
  let found = false
  let i = L - 1
  while i >= 0 and not found {
    let (a, b, c, d) = path2.segment2(q, i)
    let sl = if q.straight.at(i, default: false) { path2.pabs(path2.psub(d, a)) } else { arclength2-seg(a, b, c, d) }
    if sl >= remaining {
      // find t with length from t to 1 == remaining (bisection)
      let lo = 0.0
      let hi = 1.0
      for k in range(30) {
        let mid = 0.5 * (lo + hi)
        // length of [mid,1]
        let rest = if q.straight.at(i, default: false) { (1 - mid) * sl } else {
          let s = 1 - mid
          // approximate: subdivide numerically
          let acc = 0.0
          let prev = path2.bez2(a, b, c, d, mid)
          for j in range(1, 9) {
            let pt = path2.bez2(a, b, c, d, mid + s * j / 8)
            acc += path2.pabs(path2.psub(pt, prev))
            prev = pt
          }
          acc
        }
        if rest > remaining { lo = mid } else { hi = mid }
      }
      cut-seg = i
      cut-t = 0.5 * (lo + hi)
      found = true
    } else {
      remaining -= sl
      i -= 1
    }
  }
  if not found { return none }
  // build the truncated path: segments 0..cut-seg-1 whole, then part of cut-seg
  let nodes = q.nodes.slice(0, cut-seg + 1)
  let pre = q.pre.slice(0, cut-seg + 1)
  let post = q.post.slice(0, cut-seg + 1)
  let strs = q.straight.slice(0, cut-seg)
  let (a, b, c, d) = path2.segment2(q, cut-seg)
  if cut-t > 1e-9 {
    // De Casteljau left part
    let ab = path2.pinterp(a, b, cut-t)
    let bc = path2.pinterp(b, c, cut-t)
    let cd = path2.pinterp(c, d, cut-t)
    let abc = path2.pinterp(ab, bc, cut-t)
    let bcd = path2.pinterp(bc, cd, cut-t)
    let mm = path2.pinterp(abc, bcd, cut-t)
    post.at(cut-seg) = ab
    nodes.push(mm)
    pre.push(abc)
    post.push(mm)
    strs.push(q.straight.at(cut-seg, default: false))
  } else {
    post.at(cut-seg) = nodes.at(cut-seg)
  }
  let out = (kind: "path", nodes: nodes, pre: pre, post: post, straight: strs, cyclic: false)
  if from-end { out } else {
    (kind: "path", nodes: out.nodes.rev(), pre: out.post.rev(), post: out.pre.rev(), straight: out.straight.rev(), cyclic: false)
  }
}

// 2D alignment of a label at v: pairs are used as is, triples are projected.
#let align2(P, v, al) = {
  if is-triple(al) {
    let a = project-point(P, vadd(v, vmul(0.5, al)))
    let b = project-point(P, vsub(v, vmul(0.5, al)))
    let d = path2.psub(a, b)
    let n = path2.pabs(d)
    if n == 0 { Center } else { pair-scale(vabs(al) / n, d) }
  } else { al }
}

// Resolve a label's requested rotation.  Projected paths use the screen
// tangent (the renderer flips the mathematical y axis), then normalize modulo
// 180 degrees so a dimension never makes its text read upside down.
#let label-angle(L, tangent: none) = {
  let requested = L.at("rotate", default: none)
  if requested == auto or requested == true {
    if tangent == none { return none }
    let half-pi = calc.pi / 2
    let a = calc.rem-euclid(-path2.pangle(tangent) + half-pi, calc.pi) - half-pi
    a * 1rad
  } else if requested == none or requested == false {
    none
  } else if is-num(requested) {
    requested * 1deg
  } else {
    requested
  }
}

// Text of a label with its pen applied.  Rotation is applied after the paint
// and font wrappers so math, units, and isolated RTL/LTR content stay intact.
#let label-body(body, p, angle: none) = {
  let b = body
  if p != none {
    let paint = p.at("paint", default: black)
    let fs = p.at("fontsize", default: none)
    if paint != black { b = text(fill: paint, b) }
    if fs != none and fs != 12pt { b = text(size: fs, b) }
  }
  if angle != none { b = rotate(angle, reflow: true, b) }
  b
}

// Convert a public label displacement to points. Numbers follow the
// projected picture coordinate system and therefore scale with the figure;
// Typst lengths remain absolute screen offsets.
#let label-shift-pt(value, scale) = {
  if value == none or value == auto { 0.0 }
  else if is-num(value) { value * scale }
  else { value.to-absolute().pt() }
}

// Choose the side of a projected path indicated by `align`, while keeping the
// label's centre on the path tangent. The normal is expressed in projected
// (y-up) coordinates; the renderer flips its y component for the screen.
#let label-normal(tangent, al) = {
  let n = path2.pabs(tangent)
  if n <= 1e-12 {
    let m = path2.pabs(al)
    if m <= 1e-12 { (0.0, 1.0) } else { path2.pmul(1 / m, al) }
  } else {
    let d = path2.pmul(1 / n, tangent)
    let left = (-d.at(1), d.at(0))
    let right = (d.at(1), -d.at(0))
    if path2.pdot(al, left) >= path2.pdot(al, right) { left } else { right }
  }
}

// Return the axis-aligned box in screen points for a label. Centered labels
// (dimension annotations) are offset along the chosen normal by the margin
// plus the box's half extent, so their text is centred on the cotation rather
// than merely attached to one corner of its bounding box.
#let label-box(anchor, al, w, h, mg, dx: 0, dy: 0, scale: 1, center: false, normal: none) = {
  let ax = anchor.at(0) + label-shift-pt(dx, scale)
  let ay = anchor.at(1) - label-shift-pt(dy, scale)
  if center and normal != none {
    let ns = (normal.at(0), -normal.at(1))
    let extent = 0.5 * (calc.abs(ns.at(0)) * w + calc.abs(ns.at(1)) * h)
    let distance = mg + extent
    let cx = ax + ns.at(0) * distance
    let cy = ay + ns.at(1) * distance
    (cx - 0.5 * w, cy - 0.5 * h, cx + 0.5 * w, cy + 0.5 * h)
  } else {
    let (rx, ry) = rectify((-al.at(0), -al.at(1)))
    (ax - rx * w, ay - (1 - ry) * h, ax - rx * w + w, ay - (1 - ry) * h + h)
  }
}

// Merge all surface commands into a single one (global depth sorting).
#let merge-surfaces(cmds) = {
  let surf = cmds.filter(c => c.cmd == "surface")
  if surf.len() <= 1 { return cmds }
  // every patch keeps its own material / mesh pen / light
  let patches = ()
  let mats = ()
  let meshes = ()
  let lights = ()
  let seams = ()
  let hatches = ()
  let stipples = ()
  let ids = ()
  for (k, c) in surf.enumerate() {
    let ms = if type(c.material) == array and not is-pen(c.material) { c.material } else { (c.material,) }
    for (i, q) in c.s.patches.enumerate() {
      patches.push(q)
      mats.push(ms.at(calc.rem(i, ms.len())))
      meshes.push(c.meshpen)
      lights.push(c.light)
      seams.push(c.seam)
      hatches.push(c.at("hatch", default: none))
      stipples.push(c.at("stipple", default: none))
      ids.push(k)
    }
  }
  let merged = (cmd: "surface", s: (kind: "surface", patches: patches), material: mats, meshpen: meshes, light: lights, seam: seams, hatch: hatches, stipple: stipples, ids: ids, per-patch: true)
  let out = ()
  let done = false
  for c in cmds {
    if c.cmd == "surface" {
      if not done { out.push(merged); done = true }
    } else { out.push(c) }
  }
  out
}

// ---------------------------------------------------------------------------
// Silhouette refinement of surfaces of revolution.
// ---------------------------------------------------------------------------

// Angles (degrees) at which the profile point with unrotated normal n,
// revolved about the unit axis u, is seen edge-on: solves
//   (R(th) n) . v = 0   with   f(th) = C + A cos th + B sin th.
// v0 is the camera direction (orthographic) or c - camera (perspective) and
// k the perspective offset n.(p - c).
#let silhouette-angles(n, u, v0, k) = {
  let un = vdot(u, n)
  let uv = vdot(u, v0)
  let C = un * uv + k
  let A = vdot(n, v0) - un * uv
  let B = vdot(vcross(u, n), v0)
  let R = calc.sqrt(A * A + B * B)
  if R < 1e-12 { return () }
  let q = -C / R
  if q < -1 or q > 1 { return () }
  let phi = calc.atan2(A, B).deg()
  let dlt = calc.acos(q).deg()
  (phi + dlt, phi - dlt)
}

// Split a rim patch of a surface of revolution along the exact silhouette
// generators (and halve curved profile segments), so that the projected
// outline of the surface is smooth.
// `rpt` is the radius of the parallel through the patch in points; the
// residual dip of the outline after refinement stays below rim-tolerance.
#let rim-tolerance = 0.25 // pt
#let refine-rev-patch(pt, P, rpt) = {
  let rv = pt.rev
  let c = rv.c
  let u = rv.u
  let (a, b, cc, d) = rv.seg
  let (th0, th1) = (rv.th0, rv.th1)
  let span = th1 - th0
  if span <= 0.05 { return (pt,) }
  let v0 = if P.infinity { P.normal } else { vsub(c, P.camera) }
  // sample the silhouette angle along the profile segment: once for a
  // straight profile, else every delta degrees of turning, with
  // r (1 - cos(delta/2)) = rim-tolerance
  let ts = if rv.st { (0.5,) } else {
    let t0 = vunit(segment-tangent(a, b, cc, d, 0.0))
    let t1 = vunit(segment-tangent(a, b, cc, d, 1.0))
    let phi = calc.acos(calc.max(-1, calc.min(1, vdot(t0, t1)))).deg()
    let delta = calc.sqrt(8 * rim-tolerance / calc.max(rpt, 1e-9)) * 180 / calc.pi
    let nt = calc.max(2, calc.min(6, calc.ceil(phi / delta) + 1))
    range(nt).map(i => i / (nt - 1))
  }
  let splits = ()
  for t in ts {
    let p = bez(a, b, cc, d, t)
    let tau = bez-deriv(a, b, cc, d, t)
    if vabs2(tau) < 1e-24 { tau = segment-tangent(a, b, cc, d, t) }
    let prel = vsub(p, c)
    let (px, py, pz) = prel
    let (tx, ty, tz) = tau
    let (ux, uy, uz) = u
    let n = rev-normal(px, py, pz, tx, ty, tz, 0.0, 0.0, 0.0, ux, uy, uz)
    let k = if P.infinity { 0.0 } else { vdot(n, prel) }
    for th in silhouette-angles(n, u, v0, k) {
      let x = th0 + calc.rem-euclid(th - th0, 360)
      if x > th0 + 0.02 and x < th1 - 0.02 { splits.push(x) }
    }
  }
  splits = splits.sorted()
  let angles = (th0,)
  for x in splits { if x - angles.last() > 0.02 { angles.push(x) } }
  angles.push(th1)
  if angles.len() == 2 { return (pt,) }
  let out = ()
  for j in range(angles.len() - 1) {
    out.push(rev-patch(c, u, a, b, cc, d, rv.st, angles.at(j), angles.at(j + 1), pt.color))
  }
  out
}

// ---------------------------------------------------------------------------
// Smooth shading: a linear gradient fitted (least squares) to the corner
// colours of a patch. Returns none when the patch is (nearly) uniform.
// ---------------------------------------------------------------------------
// colour variation across a patch below which it is filled with a flat colour
#let flat-threshold = 1.5 / 255

#let fit-gradient(pts, cols) = {
  let n = pts.len()
  // pass 1: means and luminances
  let xm = 0.0
  let ym = 0.0
  let lm = 0.0
  let rm = 0.0
  let gm = 0.0
  let bm = 0.0
  let lums = ()
  for i in range(n) {
    let (x, y) = pts.at(i)
    let (r, g, b) = cols.at(i)
    let l = 0.299 * r + 0.587 * g + 0.114 * b
    lums.push(l)
    xm += x
    ym += y
    lm += l
    rm += r
    gm += g
    bm += b
  }
  xm = xm / n
  ym = ym / n
  lm = lm / n
  rm = rm / n
  gm = gm / n
  bm = bm / n
  // pass 2: least-squares plane of the luminance
  let sxx = 0.0
  let sxy = 0.0
  let syy = 0.0
  let sxl = 0.0
  let syl = 0.0
  for i in range(n) {
    let (x, y) = pts.at(i)
    let dx = x - xm
    let dy = y - ym
    let dl = lums.at(i) - lm
    sxx += dx * dx
    sxy += dx * dy
    syy += dy * dy
    sxl += dx * dl
    syl += dy * dl
  }
  let det = sxx * syy - sxy * sxy
  let tr = sxx + syy
  if det <= 1e-12 * tr * tr { return none }
  let bx = (syy * sxl - sxy * syl) / det
  let by = (sxx * syl - sxy * sxl) / det
  let gn = calc.sqrt(bx * bx + by * by)
  if gn <= 0 { return none }
  let gx = bx / gn
  let gy = by / gn
  // pass 3: positions along the gradient and per-channel slopes
  let ss = ()
  let smin = float.inf
  let smax = -float.inf
  let s2 = 0.0
  let cr = 0.0
  let cg = 0.0
  let cb = 0.0
  for i in range(n) {
    let (x, y) = pts.at(i)
    let si = (x - xm) * gx + (y - ym) * gy
    ss.push(si)
    if si < smin { smin = si }
    if si > smax { smax = si }
    let (r, g, b) = cols.at(i)
    s2 += si * si
    cr += si * (r - rm)
    cg += si * (g - gm)
    cb += si * (b - bm)
  }
  if gn * (smax - smin) < flat-threshold or s2 <= 0 { return none }
  let (kr, kg, kb) = (cr / s2, cg / s2, cb / s2)
  let c1 = (calc.max(0, calc.min(1, rm + kr * smin)), calc.max(0, calc.min(1, gm + kg * smin)), calc.max(0, calc.min(1, bm + kb * smin)))
  let c2 = (calc.max(0, calc.min(1, rm + kr * smax)), calc.max(0, calc.min(1, gm + kg * smax)), calc.max(0, calc.min(1, bm + kb * smax)))
  // pass 4: residual (largest deviation of the fitted colours from the samples)
  let res = 0.0
  let inv = 1 / (smax - smin)
  for i in range(n) {
    let t = (ss.at(i) - smin) * inv
    let (r, g, b) = cols.at(i)
    let e = calc.abs(c1.at(0) + t * (c2.at(0) - c1.at(0)) - r)
    if e > res { res = e }
    e = calc.abs(c1.at(1) + t * (c2.at(1) - c1.at(1)) - g)
    if e > res { res = e }
    e = calc.abs(c1.at(2) + t * (c2.at(2) - c1.at(2)) - b)
    if e > res { res = e }
  }
  (xm + smin * gx, ym + smin * gy, xm + smax * gx, ym + smax * gy, c1, c2, res)
}

// Split a patch of a surface of revolution in two (angularly) or four
// (also halving a curved profile segment), for smoother shading.
// mode: "u" (halve the angular sector), "v" (halve the profile segment) or
// "uv" (both).
#let split-rev-patch(pt, mode) = {
  let rv = pt.rev
  let (a, b, cc, d) = rv.seg
  let pieces = if rv.st or mode == "u" { ((a, b, cc, d),) } else { bez-split(a, b, cc, d, 0.5) }
  let angles = if mode == "v" { ((rv.th0, rv.th1),) } else {
    let mid = 0.5 * (rv.th0 + rv.th1)
    ((rv.th0, mid), (mid, rv.th1))
  }
  let out = ()
  for (A, B, C, D) in pieces {
    for (t0, t1) in angles { out.push(rev-patch(rv.c, rv.u, A, B, C, D, rv.st, t0, t1, pt.color)) }
  }
  out
}

// Create a two-node vector path for one hatch segment.
#let hatch-line2(a, b) = (
  kind: "path",
  nodes: (a, b),
  pre: (a, b),
  post: (a, b),
  straight: (true,),
  cyclic: false,
)

// Intersect a family of parallel lines with the projected polygon of a
// surface patch.  Surface patches are normally convex quads; using their
// control polygon keeps this helper small and, importantly, keeps hatching
// in the same projected 2D coordinate system as the fill.
#let hatch-segments2(p, spec) = {
  if spec == none or spec == false { return () }
  let q = if type(spec) == dictionary { spec } else { (pen: spec) }
  let nodes = path2.flatten2(p, n: 8)
  if nodes.len() < 3 { return () }
  let spacing = float(q.at("spacing", default: 0.22))
  if spacing <= 0.001 { return () }
  let base-angle = float(q.at("angle", default: 35.0))
  let angles = if q.at("cross", default: false) { (base-angle, base-angle + 90.0) } else { (base-angle,) }
  let out = ()
  let minx = calc.min(..nodes.map(z => z.at(0)))
  let maxx = calc.max(..nodes.map(z => z.at(0)))
  let miny = calc.min(..nodes.map(z => z.at(1)))
  let maxy = calc.max(..nodes.map(z => z.at(1)))
  let cx = 0.5 * (minx + maxx)
  let cy = 0.5 * (miny + maxy)
  for angle in angles {
    let d = (calc.cos(angle * 1deg), calc.sin(angle * 1deg))
    let n = (-d.at(1), d.at(0))
    let projections = nodes.map(z => z.at(0) * n.at(0) + z.at(1) * n.at(1))
    let lo = calc.min(..projections)
    let hi = calc.max(..projections)
    let count = calc.min(80, calc.max(1, int(calc.ceil((hi - lo) / spacing)) + 1))
    for k in range(count) {
      let level = if count == 1 { 0.5 * (lo + hi) } else { lo + (hi - lo) * k / (count - 1) }
      let base = (n.at(0) * level, n.at(1) * level)
      let hits = ()
      for i in range(nodes.len()) {
        let j = if i + 1 == nodes.len() { 0 } else { i + 1 }
        let a = nodes.at(i)
        let b = nodes.at(j)
        let ex = b.at(0) - a.at(0)
        let ey = b.at(1) - a.at(1)
        let wx = a.at(0) - base.at(0)
        let wy = a.at(1) - base.at(1)
        let den = d.at(0) * ey - d.at(1) * ex
        if calc.abs(den) > 1e-12 {
          let t = (wx * ey - wy * ex) / den
          let u = (wx * d.at(1) - wy * d.at(0)) / den
          if u >= -1e-9 and u <= 1 + 1e-9 { hits.push((base.at(0) + t * d.at(0), base.at(1) + t * d.at(1))) }
        }
      }
      if hits.len() >= 2 {
        let sorted = hits.sorted(key: z => z.at(0) * d.at(0) + z.at(1) * d.at(1))
        let a = sorted.first()
        let b = sorted.last()
        let dx = b.at(0) - a.at(0)
        let dy = b.at(1) - a.at(1)
        let length = calc.sqrt(dx * dx + dy * dy)
        if q.at("broken", default: false) and length > 1e-9 {
          let segment = calc.max(0.01, float(q.at("segment", default: 0.20)))
          let gap = calc.max(0.0, float(q.at("gap", default: 0.08)))
          let step = segment + gap
          let pieces = calc.max(1, int(calc.ceil(length / step)))
          for piece in range(pieces) {
            let t0 = calc.min(1.0, piece * step / length)
            let t1 = calc.min(1.0, (piece * step + segment) / length)
            if t1 - t0 > 1e-5 {
              out.push(hatch-line2(
                (a.at(0) + t0 * dx, a.at(1) + t0 * dy),
                (a.at(0) + t1 * dx, a.at(1) + t1 * dy),
              ))
            }
          }
        } else {
          out.push(hatch-line2(a, b))
        }
      }
    }
  }
  out
}

// Deterministic stipple points inside a projected patch. This is a small
// vector lit-stipple texture: circles are kept
// inside the flattened patch and their density/size can be adjusted by light.
// `max-patch-count` prevents a large global request from multiplying by every
// small surface patch in the pure fallback; users can raise it explicitly.
#let stipple-dots2(p, spec, holes: ()) = {
  if spec == none or spec == false { return () }
  let q = if type(spec) == dictionary { spec } else { (pen: spec) }
  let nodes = path2.flatten2(p, n: 8)
  if nodes.len() < 3 { return () }
  let patch-cap = calc.max(0, int(q.at("max-patch-count", default: 96)))
  let count = calc.max(0, calc.min(patch-cap, int(q.at("count", default: 40))))
  if count == 0 { return () }
  let min-size = calc.max(0.0001, float(q.at("min-size", default: 0.012)))
  let max-size = calc.max(min-size, float(q.at("max-size", default: 0.028)))
  let gamma = calc.max(0.1, float(q.at("gamma", default: 1.2)))
  let seed = float(q.at("seed", default: 0))
  let straight = ()
  for _ in nodes { straight.push(true) }
  let poly = (kind: "path", nodes: nodes, pre: nodes, post: nodes,
    straight: straight, cyclic: true)
  let minx = calc.min(..nodes.map(z => z.at(0)))
  let maxx = calc.max(..nodes.map(z => z.at(0)))
  let miny = calc.min(..nodes.map(z => z.at(1)))
  let maxy = calc.max(..nodes.map(z => z.at(1)))
  let dots = ()
  // Rejection sampling is bounded and deterministic. The multiplier keeps
  // narrow curved patches from returning too few points.
  for i in range(count * 6 + 12) {
    if dots.len() < count {
      let h1 = 0.5 + 0.5 * calc.sin(seed * 17.31 + i * 11.713 + 0.37)
      let h2 = 0.5 + 0.5 * calc.sin(seed * 7.19 + i * 23.417 + 2.11)
      let h3 = 0.5 + 0.5 * calc.sin(seed * 5.71 + i * 31.019 + 4.83)
      let z = (minx + h1 * (maxx - minx), miny + h2 * (maxy - miny))
      let inside = path2.inside2(poly, z)
      for hole in holes {
        if path2.inside2(hole, z) { inside = false }
      }
      if inside {
        let r = min-size + (max-size - min-size) * calc.pow(h3, gamma)
        dots.push((z: z, radius: r))
      }
    }
  }
  dots
}

// Primitives of one surface command. Rim patches of surfaces of revolution
// are split along the silhouette, patches whose shading is too far from
// linear are subdivided, everything is depth sorted, and translucent
// surfaces are split into a back-facing and a front-facing layer, each
// rendered as a group carrying the opacity.
#let shading-tolerance = 0.02
#let shading-levels = 2

#let surface-prims(c, P, light0, shading, refine, s0, style: "none") = {
  let per-patch = c.at("per-patch", default: false)
  let raw-material = c.material
  // The reference sketch vocabulary leaves the paper visible and derives
  // tone from engraved lines. An explicit material still opts into a wash.
  // vintage / pencil: a surface with no explicit material, hatch or stipple is engraved: pale material lit by
  // the scene light, then turned into tonal line work by `engrave-prims` (cf. `picture`).
  let illus = style == "pencil" or style == "vintage"
  let eng-auto = illus and not per-patch and raw-material == auto and c.at("hatch", default: none) == auto and c.at("stipple", default: none) == auto
  let raw-material = if eng-auto { material(diffuse: gray(0.96), emissive: black, specular: black, shininess: 0.1) } else if illus and raw-material == auto { none } else { raw-material }
  // engraving: the tone comes from the light on a pale material (an explicit material darkens or lightens it)
  let raw-material = if style == "engraving" and raw-material == auto { material(diffuse: gray(0.96), emissive: black, specular: black, shininess: 0.1) } else { raw-material }
  let tomat = x => tomaterial(if x == auto { default-pen } else { x })
  let mats = if per-patch { raw-material.map(tomat) } else if type(raw-material) == array and not is-pen(raw-material) { raw-material.map(tomat) } else { (tomat(raw-material),) }
  let mcs = mats.map(material-components)
  let lt0 = if c.light == auto { light0 } else if per-patch { none } else { tolight(c.light) }
  let default-hatch = (
    // Pencil shading is made from visible crossed strokes, not from a
    // stipple texture. Use a denser, darker line family than the sepia
    // engraving so small projected patches still read as sketch marks.
    spacing: if style == "pencil" { 0.14 } else { 0.24 },
    angle: if style == "pencil" { 32.0 } else { 35.0 },
    cross: style == "pencil",
    broken: true,
    lit: true,
    segment: if style == "pencil" { 0.34 } else { 0.22 },
    gap: if style == "pencil" { 0.055 } else { 0.08 },
    pen: pencilize-pen((paint: if style == "pencil" { pencil-ink } else { vintage-pale-ink }, thickness: if style == "pencil" { 0.32pt } else { 0.24pt }), passes: 1, opacity: if style == "pencil" { 0.90 } else { 0.72 }))
  let requested-hatches = c.at("hatch", default: none)
  let hatches = if per-patch {
    requested-hatches.map(h => if (style == "vintage" or style == "pencil") and h == auto { default-hatch } else if h == auto { none } else { h })
  } else {
    if eng-auto { none } else if (style == "vintage" or style == "pencil") and requested-hatches == auto { default-hatch } else if requested-hatches == auto { none } else { requested-hatches }
  }
  let requested-stipples = c.at("stipple", default: none)
  let stipples = if per-patch {
    requested-stipples.map(v => if v == auto { none } else { v })
  } else {
    if requested-stipples == auto { none } else { requested-stipples }
  }
  let mesh-for = raw => {
    if style == "vintage" or style == "pencil" {
      if raw == none { none }
      else {
        let q = pencilize-pen(raw, passes: 1, opacity: 0.72)
        q.paint = if style == "pencil" { pencil-ink } else { vintage-ink }
        q
      }
    } else { resolve-pen(raw) }
  }
  let hatch-lightness = (normal, l) => {
    if l.position.len() == 0 { return 0.5 }
    let n = vunit(tvector(P.modelview, normal))
    if n.at(2) < 0 { n = vneg(n) }
    let total = 0.0
    for i in range(l.position.len()) {
      let L = if l.viewport { l.position.at(i) } else { vunit(tvector(P.modelview, l.position.at(i))) }
      total += calc.abs(vdot(n, L))
    }
    calc.min(1.0, total / l.position.len())
  }
  let adjust-hatch = (h, normal, l) => {
    if h == none or type(h) != dictionary or not h.at("lit", default: true) { return h }
    let q = h
    let lit = hatch-lightness(normal, l)
    // Less light means denser, darker engraving. Keep explicit lengths
    // stable enough for small patches so a mesh does not become noisy.
    q.spacing = h.at("spacing", default: 0.22) * (1.35 - 0.65 * lit)
    q.segment = h.at("segment", default: 0.20) * (1.05 - 0.25 * lit)
    q
  }
  let adjust-stipple = (v, normal, l) => {
    if v == none or type(v) != dictionary or not v.at("lit", default: true) { return v }
    let q = v
    let lit = hatch-lightness(normal, l)
    q.count = calc.max(1, int(q.at("count", default: 40) * (0.55 + 1.45 * (1 - lit))))
    q.min-size = q.at("min-size", default: 0.012) * (0.85 + 0.45 * (1 - lit))
    q.max-size = q.at("max-size", default: 0.028) * (0.90 + 0.55 * (1 - lit))
    if style == "pencil" or style == "vintage" {
      let sp = resolve-pen(q.at("pen", default: pencil-pen()))
      if sp != none { sp.paint = if style == "pencil" { pencil-ink } else { vintage-pale-ink }; q.pen = sp }
    }
    q
  }
  let mp0 = if per-patch { none } else { mesh-for(c.meshpen) }
  let mv = P.modelview
  let (r0, r1, r2, r3) = mv
  let inf = P.infinity
  let (camx, camy, camz) = P.camera
  let smooth0 = shading == "smooth"
  // 1. expand rim patches along the silhouette
  let work = ()
  let (nrx, nry, nrz) = P.normal
  for (idx, pt) in c.s.patches.enumerate() {
    let rim = false
    if refine and "rev" in pt {
      // does the patch straddle the silhouette? (mixed signs of normal . view over corners and centre)
      let pos = 0
      let neg = 0
      let pts = pt.boundary.nodes + (pt.center,)
      for (i, n) in (pt.normals + (pt.normal,)).enumerate() {
        let (nx, ny, nz) = n
        let f = if inf { nx * nrx + ny * nry + nz * nrz } else {
          let (px, py, pz) = pts.at(i)
          nx * (px - camx) + ny * (py - camy) + nz * (pz - camz)
        }
        if f > 0 { pos += 1 } else { neg += 1 }
      }
      rim = pos > 0 and neg > 0
    }
    if rim {
      // radius of the parallel through the patch centre, in points, and the
      // dip of the outline it produces; skip invisible refinements
      let rv = pt.rev
      let (x, y, z) = pt.center
      let (ux, uy, uz) = rv.u
      let (rx, ry, rz) = (x - rv.c.at(0), y - rv.c.at(1), z - rv.c.at(2))
      let h = rx * ux + ry * uy + rz * uz
      let r = calc.sqrt(calc.max(0, rx * rx + ry * ry + rz * rz - h * h))
      let rpt = r * s0 * (if inf { P.zoom } else { P.zoom * P.distance / calc.max(1e-9, calc.sqrt((camx - x) * (camx - x) + (camy - y) * (camy - y) + (camz - z) * (camz - z))) })
      let dip = rpt * (1 - calc.cos(0.5 * (rv.th1 - rv.th0) * 1deg))
      if dip > rim-tolerance {
        for q in refine-rev-patch(pt, P, rpt) { work.push((idx, q, 0)) }
      } else { work.push((idx, pt, 0)) }
    } else { work.push((idx, pt, 0)) }
  }
  // 2. shade (subdividing where the shading is not linear enough)
  let final = ()
  while work.len() > 0 {
    let (idx, pt, lev) = work.pop()
    let mc = if pt.color != none { material-components(tomaterial(pt.color)) } else { mcs.at(calc.rem(idx, mcs.len())) }
    let lt = if per-patch { let l = c.light.at(idx); if l == auto { light0 } else { tolight(l) } } else { lt0 }
    let p2 = project-fast(P, pt.boundary)
    let holes = if "holes" in pt { pt.holes.map(h => project-fast(P, h)) } else { () }
    let fill = none
    let grad = none
    if not mc.invisible {
      // "none" keeps the material's diffuse colour and skips all lighting;
      // useful for wireframe/mesh exports and considerably cheaper than flat
      // lighting.  "flat" still evaluates one normal per patch.
      if shading == "none" {
        fill = (calc.max(0, calc.min(1, mc.D.at(0))), calc.max(0, calc.min(1, mc.D.at(1))), calc.max(0, calc.min(1, mc.D.at(2))))
      }
      let smooth = shading == "smooth" and "normals" in pt and pt.normals.len() == pt.boundary.nodes.len() and lt.position.len() > 0
      if smooth {
        let cols = shade-many(pt.normals + (pt.normal,), mc, lt, mv)
        let nodes = p2.nodes
        let k = nodes.len()
        let cx = 0.0
        let cy = 0.0
        for q in nodes { cx += q.at(0); cy += q.at(1) }
        fill = cols.last()
        grad = fit-gradient(nodes + ((cx / k, cy / k),), cols)
        if grad != none and refine and "rev" in pt and lev < shading-levels and k == 4 {
          // split when the shading error is visible (the tolerance grows as
          // the patch gets smaller on paper), along the longer direction of
          // the patch: nodes are (A0, D0, D1, A1), A->D along the profile
          // (v), 0->1 around the axis (u)
          let ((bx0, by0), (bx1, by1)) = p2.bbox
          let ext = calc.max(bx1 - bx0, by1 - by0) * s0
          if ext > 6 and grad.at(6) > shading-tolerance * calc.max(1, 12 / ext) {
            let (A0, D0, D1, A1) = nodes
            let ev = calc.max(calc.abs(D0.at(0) - A0.at(0)) + calc.abs(D0.at(1) - A0.at(1)), calc.abs(D1.at(0) - A1.at(0)) + calc.abs(D1.at(1) - A1.at(1)))
            let eu = calc.max(calc.abs(D1.at(0) - D0.at(0)) + calc.abs(D1.at(1) - D0.at(1)), calc.abs(A1.at(0) - A0.at(0)) + calc.abs(A1.at(1) - A0.at(1)))
            let mode = if pt.rev.st or eu > 1.5 * ev { "u" } else if ev > 1.5 * eu { "v" } else { "uv" }
            for q in split-rev-patch(pt, mode) { work.push((idx, q, lev + 1)) }
            continue
          }
        }
      } else if shading != "none" {
        fill = shade-many((pt.normal,), mc, lt, mv).at(0)
      }
    }
    // depth key and facing
    let (x, y, z) = pt.center
    let key = if inf { r2.at(0) * x + r2.at(1) * y + r2.at(2) * z } else { -calc.sqrt((camx - x) * (camx - x) + (camy - y) * (camy - y) + (camz - z) * (camz - z)) }
    let (nx, ny, nz) = pt.normal
    let f = if inf { r2.at(0) * nx + r2.at(1) * ny + r2.at(2) * nz } else { nx * (camx - x) + ny * (camy - y) + nz * (camz - z) }
    final.push((key: key, facing: if f >= 0 { 1 } else { -1 }, idx: idx, p2: p2, holes: holes, fill: fill, grad: grad, mc: mc, normal: pt.normal, light: lt))
  }
  // 3. depth sort. A translucent surface is split into a back-facing and a
  // front-facing layer, each drawn as one group carrying the opacity. With
  // global sorting (per-patch mode) the layers of each translucent surface
  // are sorted as units (by their mean depth) among the opaque patches.
  let alphas = mcs.map(m => m.alpha)
  let alpha0 = if alphas.len() > 0 and alphas.all(a => calc.abs(a - alphas.at(0)) < 1e-6) and c.s.patches.all(q => q.color == none) { alphas.at(0) } else { none }
  let split = alpha0 != none and alpha0 < 0.999 and not per-patch
  final = if split {
    final.filter(it => it.facing < 0).sorted(key: it => it.key) + final.filter(it => it.facing > 0).sorted(key: it => it.key)
  } else if per-patch {
    let units = ()
    let layers = (:)
    for it in final {
      if it.mc.alpha < 0.999 and not it.mc.invisible {
        let lk = str(c.ids.at(it.idx)) + "/" + str(it.facing)
        let l = layers.at(lk, default: (sum: 0.0, items: ()))
        l.sum += it.key
        l.items.push(it)
        layers.insert(lk, l)
      } else { units.push((it.key, (it,))) }
    }
    for (lk, l) in layers { units.push((l.sum / l.items.len(), l.items.sorted(key: it => it.key))) }
    units.sorted(key: u => u.at(0)).map(u => u.at(1)).join(default: ())
  } else { final.sorted(key: it => it.key) }
  // 4. emit, grouping runs of translucent patches with the same opacity and facing
  let prims = ()
  let gkey = none
  for it in final {
    let idx = it.idx
    let mc = it.mc
    let mp = if per-patch { mesh-for(c.meshpen.at(idx)) } else { mp0 }
    let sm = if per-patch { c.seam.at(idx) } else { c.seam }
    let hatch0 = if per-patch { hatches.at(idx) } else { hatches }
    let hatch1 = if (style == "pencil" or style == "vintage") { adjust-hatch(hatch0, it.normal, it.light) } else { hatch0 }
    let hatch = if (style == "pencil" or style == "vintage") and it.facing < 0 { none } else { hatch1 }
    let stipple0 = if per-patch { stipples.at(idx) } else { stipples }
    let stipple1 = if (style == "pencil" or style == "vintage") { adjust-stipple(stipple0, it.normal, it.light) } else { stipple0 }
    let stipple = if (style == "pencil" or style == "vintage") and it.facing < 0 { none } else { stipple1 }
    if mc.invisible {
      if mp != none or hatch != none {
        if gkey != none { prims.push((type: "endgroup",)); gkey = none }
        prims.push((type: "fill", p2: it.p2, holes: it.holes, fill: none, grad: none, alpha: 1.0, seam: false, mesh: mp, hatch: hatch, stipple: stipple))
      }
      continue
    }
    let alpha = mc.alpha
    let key = if alpha < 0.999 { (alpha, it.facing, if per-patch { c.ids.at(idx) } else { 0 }) } else { none }
    if key != gkey {
      if gkey != none { prims.push((type: "endgroup",)) }
      if key != none { prims.push((type: "group", alpha: alpha)) }
      gkey = key
    }
    let seam = if sm == auto { if style == "none" { mp == none } else { false } } else { sm }
    prims.push((type: "fill", p2: it.p2, holes: it.holes, fill: it.fill, grad: it.grad, alpha: 1.0, seam: seam, mesh: mp, hatch: hatch, stipple: stipple, group: key != none, eng: eng-auto))
  }
  if gkey != none { prims.push((type: "endgroup",)) }
  prims
}

// Build the primitive list from commands.
#let build-primitives(cmds, P, light0, lim, dotf, shading, refine, s0, style: "none", eng-spec: none) = {
  let prims = ()
  let bounds = none
  let style-pen = x => {
    let q = resolve-pen(x)
    if q != none and (style == "pencil" or style == "vintage") {
      q.paint = if style == "pencil" { pencil-ink } else { vintage-ink }
    }
    q
  }
  let emit-path = (g, pen, arrow, label, ninterpolate) => {
    let p = resolve-pen(pen)
    if p != none and (style == "pencil" or style == "vintage") {
      // One filled envelope per path: keep one pass; extra transparent copies were only a former
      // approximation and made pencil contours look like coloured strokes.
      let passes = 1
      let ink-opacity = if style == "vintage" { 1.0 } else { 0.82 }
      p = pencilize-pen(p, passes: passes, opacity: ink-opacity)
      p.paint = if style == "pencil" { pencil-ink } else { vintage-ink }
    }
    let out = ()
    if p != none or label != none or arrow != none {
      let p2 = project-path(P, g, ninterpolate: ninterpolate)
      let lab = none
      if label != none {
        let L = label
        let L0 = length3(g)
        let pos = if L.position == auto { reltime(g, 0.5) } else if L.position <= 1 and L.position >= 0 { reltime(g, L.position) } else { L.position }
        let v = point(g, pos)
        let z = project-point(P, v)
        let d2 = path2.dir2(p2, pos * (if P.infinity { 1 } else { P.ninterpolate }))
        let al = if L.align == auto {
          let A = if pos <= sqrt-epsilon { S } else if pos >= L0 - sqrt-epsilon { N } else { E }
          // -A * d2 * I  (complex arithmetic)
          let ad = (A.at(0) * d2.at(0) - A.at(1) * d2.at(1), A.at(0) * d2.at(1) + A.at(1) * d2.at(0))
          (ad.at(1), -ad.at(0))
        } else { align2(P, v, L.align) }
        let lp = if p == none { default-pen } else { p }
        let angle = label-angle(L, tangent: d2)
        let centered = L.at("center", default: false)
        lab = (type: "label", z: z, body: label-body(L.body, lp, angle: angle), align: al, pen: lp, v: v, rotation: angle,
          dx: L.at("dx", default: 0), dy: L.at("dy", default: 0), center: centered,
          normal: if centered { label-normal(d2, al) } else { none })
      }
      out.push((type: "path", p2: p2, g: g, pen: p, arrow: arrow, label: lab))
    }
    out
  }
  for c in cmds {
    if c.cmd == "path" {
      prims += emit-path(c.g, c.pen, c.arrow, c.label, c.ninterpolate)
    } else if c.cmd == "brace3" {
      prims += brace-prims(c, P, s0, if style == "engraving" { eng-spec.ink } else if style == "vintage" { vintage-ink } else if style == "pencil" { pencil-ink } else { black }, if lim != none { lim } else { bounds3(cmds) })
    } else if c.cmd == "knot3" {
      let lv = {
        let lp = light0.position
        if lp.len() == 0 { (-0.55, 0.8) } else {
          let v = if light0.viewport { lp.at(0) } else { vunit(tvector(P.modelview, lp.at(0))) }
          let n = calc.max(calc.sqrt(v.at(0) * v.at(0) + v.at(1) * v.at(1)), 1e-6)
          (v.at(0) / n, v.at(1) / n)
        }
      }
      prims += knot-prims(c, P, s0, lv, eng: if style == "engraving" { eng-spec } else { none })
    } else if c.cmd == "deferred" {
      let objs = (c.f)(P)
      let arr = if is-path3(objs) { (objs,) } else { objs }
      for g in arr { prims += emit-path(g, c.pen, c.arrow, c.label, auto) }
    } else if c.cmd == "surface" {
      prims += surface-prims(c, P, light0, shading, refine, s0, style: style)
    } else if c.cmd == "dot" {
      let p = style-pen(c.pen)
      let z = project-point(P, c.v)
      let r = if c.size == auto { 0.5 * dotf * p.thickness } else { 0.5 * c.size }
      prims.push((type: "dot", z: z, r: r, paint: pen-paint(p)))
      if c.label != none {
        let L = c.label
        let angle = label-angle(L)
        let al = align2(P, c.v, L.align)
        prims.push((type: "label", z: z, body: label-body(L.body, p, angle: angle), align: al, pen: p, v: c.v, rotation: angle,
          dx: L.at("dx", default: 0), dy: L.at("dy", default: 0), center: L.at("center", default: false), normal: none))
      }
    } else if c.cmd == "label" {
      let p = style-pen(if c.pen == none { auto } else { c.pen })
      let z = project-point(P, c.v)
      let angle = label-angle(c.label)
      let al = align2(P, c.v, c.label.align)
      prims.push((type: "label", z: z, body: label-body(c.label.body, p, angle: angle), align: al, pen: p, v: c.v, rotation: angle,
        dx: c.label.at("dx", default: 0), dy: c.label.at("dy", default: 0), center: c.label.at("center", default: false), normal: none))
    } else if c.cmd == "revolution" {
      let fp = resolve-pen(c.frontpen)
    // The illustration styles do hidden-line removal rather than
    // drawing a dashed rear skeleton.  Preserve an explicitly requested
    // back pen, but suppress the implicit one in the illustration styles.
    let implicit-back = c.backpen == auto
    let bp0 = if implicit-back { c.frontpen } else { c.backpen }
    let bp = if (style == "pencil" or style == "vintage" or style == "engraving") and implicit-back { none } else {
      resolve-pen(if bp0 == auto { default-pen } else { bp0 })
    }
    // back pens get the dashed default back line type
    if bp != none and bp.at("dash", default: none) == none { bp = pen-merge(bp, defaultbackpen) }
    let lp = if c.longitudinalpen == auto { fp } else { resolve-pen(c.longitudinalpen) }
    let lbp = if c.longitudinalbackpen == auto {
      if c.longitudinalpen == auto {
        if (style == "pencil" or style == "vintage" or style == "engraving") and implicit-back { none } else { bp }
      } else { if lp == none { none } else { pen-merge(lp, defaultbackpen) } }
    } else { resolve-pen(c.longitudinalbackpen) }
    let sk = skeleton(c.r, m: c.m, n: c.n, P: P)
    if bp != none { for g in sk.transverse.back { prims += emit-path(g, bp, none, none, auto) } }
    if lbp != none { for g in sk.longitudinal.back { prims += emit-path(g, lbp, none, none, auto) } }
    if fp != none { for g in sk.transverse.front { prims += emit-path(g, fp, none, none, auto) } }
    if lp != none { for g in sk.longitudinal.front { prims += emit-path(g, lp, none, none, auto) } }

    } else if c.cmd == "axis" {
      if bounds == none { bounds = if lim != none { lim } else { bounds3(cmds) } }
      let (m, M) = bounds
      let idx = ("x": 0, "y": 1, "z": 2).at(c.axis)
      let lo = if c.min == auto { m.at(idx) } else { c.min }
      let hi = if c.max == auto { M.at(idx) } else { c.max }
      let base = range(3).map(k => if k == idx { 0.0 } else if m.at(k) <= 0 and M.at(k) >= 0 { 0.0 } else { m.at(k) })
      let a = base
      let b = base
      a.at(idx) = lo
      b.at(idx) = hi
      let L = c.label
      if L != none and L.position == auto { L.position = 1 }
      prims += emit-path(line3(a, b), c.pen, c.arrow, L, auto)
    } else if c.cmd == "limits" { } else {
      panic("unknown command " + c.cmd)
    }
  }
  prims
}

// The picture. size/width/height are lengths; unitsize is used when no
// size is given. The result is a box.
#let picture(..cmds, size: auto, width: auto, height: auto, unitsize: 1cm, projection: currentprojection,
  light: currentlight, limits: none, margin: 0pt, inset: 0pt, fill: none, stroke: none, radius: 0pt,
  dotfactor: dotfactor, arrowsize: auto, clip: false, baseline: 0pt, zsort: "command",
  shading: "smooth", refine: true, backend: "svg", style: "none", engine: "nibart", engraving: auto) = {
  if engine != "nibart" { panic("picture: engine must be \"nibart\" (the \"wasm\" engine was removed in 0.4.0)") }
  if shading != "smooth" and shading != "flat" and shading != "none" {
    panic("picture: shading must be \"smooth\", \"flat\" or \"none\"")
  }
  if backend != "svg" and backend != "typst" {
    panic("picture: backend must be \"svg\" or \"typst\"")
  }
  if zsort != "command" and zsort != "global" {
    panic("picture: zsort must be \"command\" or \"global\"")
  }
  if style != "none" and style != "pencil" and style != "vintage" and style != "engraving" {
    panic("picture: style must be \"none\", \"pencil\", \"vintage\" or \"engraving\"")
  }
  if (style == "vintage" or style == "pencil") and fill == none { fill = vintage-paper }
  // vintage / pencil: the surfaces are engraved with a lighter screen than the "engraving" style
  // (paper left visible, no nib contours: the pens of the scene draw the outlines).
  let eng = if engraving != auto { engraving }
    else if style == "vintage" { make-engraving(spacing: 2.5pt, angle: 35, cross: true, cross-angle: 80, gain: 0.8, minimum: 0.10pt, contours: false, ink: vintage-ink, paper: vintage-paper) }
    else if style == "pencil" { make-engraving(spacing: 2.0pt, angle: 30, cross: true, cross-angle: 62, gain: 0.95, minimum: 0.10pt, contours: false, wave: (amplitude: 0.18pt, length: 9pt), ink: pencil-ink, paper: vintage-paper) }
    else { make-engraving() }
  if style == "engraving" and fill == none { fill = eng.paper }
  let commands = flatten-cmds(cmds.pos())

  if zsort == "global" { commands = merge-surfaces(commands) }
  let P = projection
  let lim = limits
  for c in commands { if c.cmd == "limits" { lim = (c.min, c.max) } }
  let light0 = tolight(light)
  context {
  // rough estimate of the final scale (points per user unit), used to skip
  // refinements that would not be visible
  let s0 = {
    let tw = if width != auto { width.to-absolute().pt() } else if size != auto { if type(size) == array { size.at(0).to-absolute().pt() } else { size.to-absolute().pt() } } else { none }
    let th = if height != auto { height.to-absolute().pt() } else if size != auto { if type(size) == array { size.at(1).to-absolute().pt() } else { size.to-absolute().pt() } } else { none }
    if tw == none and th == none { unitsize.to-absolute().pt() } else {
      let (m, M) = if lim != none { lim } else { bounds3(commands) }
      let xs = ()
      let ys = ()
      for i in range(8) {
        let v = (if calc.rem(i, 2) == 0 { m.at(0) } else { M.at(0) }, if calc.rem(calc.quo(i, 2), 2) == 0 { m.at(1) } else { M.at(1) }, if i < 4 { m.at(2) } else { M.at(2) })
        let z = project-point(P, v)
        xs.push(z.at(0))
        ys.push(z.at(1))
      }
      let bw = calc.max(calc.max(..xs) - calc.min(..xs), 1e-9)
      let bh = calc.max(calc.max(..ys) - calc.min(..ys), 1e-9)
      let sw = if tw != none { tw / bw } else { none }
      let sh = if th != none { th / bh } else { none }
      if sw != none and sh != none { calc.min(sw, sh) } else if sw != none { sw } else { sh }
    }
  }
  let prims = build-primitives(commands, P, light0, lim, dotfactor, shading, refine, s0, style: style, eng-spec: eng)
  if style == "engraving" { prims = engrave-prims(prims, s0, eng) }
  else if style == "vintage" or style == "pencil" { prims = engrave-prims(prims, s0, eng, only-marked: true) }
  // user-space bounding box
  let minx = float.inf
  let miny = float.inf
  let maxx = -float.inf
  let maxy = -float.inf
  for pr in prims {
    let zs = if pr.type == "path" or pr.type == "fill" { path2.bbox2(pr.p2) } else if pr.type == "ink" { pr.bb } else if pr.type == "dot" or pr.type == "label" { (pr.z,) } else { () }
    for z in zs {
      if z.at(0) < minx { minx = z.at(0) }
      if z.at(0) > maxx { maxx = z.at(0) }
      if z.at(1) < miny { miny = z.at(1) }
      if z.at(1) > maxy { maxy = z.at(1) }
    }
  }
  if minx == float.inf { minx = 0.0; miny = 0.0; maxx = 1.0; maxy = 1.0 }
  let bw = maxx - minx
  let bh = maxy - miny
  if bw <= 0 { bw = 1e-9 }
  if bh <= 0 { bh = 1e-9 }
  {
    let fs = text.size
    let ins = inset.to-absolute().pt() + margin.to-absolute().pt()
    // measure labels once
    let measured = prims.map(pr => {
      if pr.type == "label" {
        let mz = measure(pr.body)
        (body: pr.body, w: mz.width.pt(), h: mz.height.pt())
      } else { none }
    })
    // Fixed-size extents (in pt) of a primitive around its anchor for a scale s:
    // returns (l, r, b, t) offsets in Typst coordinates (y down): we compute
    // the final layout box for a given scale.
    // the (user-space) bounding box of all fills is needed once only
    let fminx = float.inf
    let fminy = float.inf
    let fmaxx = -float.inf
    let fmaxy = -float.inf
    let others = ()
    for (k, pr) in prims.enumerate() {
      if pr.type == "fill" {
        let (a, b) = path2.bbox2(pr.p2)
        if a.at(0) < fminx { fminx = a.at(0) }
        if a.at(1) < fminy { fminy = a.at(1) }
        if b.at(0) > fmaxx { fmaxx = b.at(0) }
        if b.at(1) > fmaxy { fmaxy = b.at(1) }
      } else if pr.type == "path" or pr.type == "dot" or pr.type == "label" or pr.type == "ink" { others.push((k, pr)) }
    }
    let layout-extents = s => {
      let rects = ()
      let px = z => (z.at(0) - minx) * s
      let py = z => (maxy - z.at(1)) * s
      if fminx < float.inf { rects.push((px((fminx, 0)) - 0.5 * seam-width, py((0, fmaxy)) - 0.5 * seam-width, px((fmaxx, 0)) + 0.5 * seam-width, py((0, fminy)) + 0.5 * seam-width)) }
      for (k, pr) in others {
        if pr.type == "ink" {
          let (a, b) = pr.bb
          rects.push((px(a), py(b), px(b), py(a)))
        } else if pr.type == "path" {
          let (a, b) = path2.bbox2(pr.p2)
          let hw = if pr.pen != none { 0.5 * pr.pen.thickness.pt() } else { 0.5 * seam-width }
          rects.push((px(a) - hw, py(b) - hw, px(b) + hw, py(a) + hw))
        } else if pr.type == "dot" {
          let r = pr.r.pt()
          rects.push((px(pr.z) - r, py(pr.z) - r, px(pr.z) + r, py(pr.z) + r))
        }
        if pr.type == "label" or (pr.type == "path" and pr.label != none) {
          let lab = if pr.type == "label" { pr } else { pr.label }
          let mz = if pr.type == "label" { measured.at(k) } else { none }
          let (w, h) = if mz != none { (mz.w, mz.h) } else {
            let m2 = measure(lab.body)
            (m2.width.pt(), m2.height.pt())
          }
          let al = lab.align
          let mg = labelmargin-factor * fs.pt() + 0.5 * lab.pen.thickness.pt() + (if "extra" in pr { pr.extra.pt() } else { 0 })
          let box = label-box((px(lab.z), py(lab.z)), al, w, h, mg,
            dx: lab.at("dx", default: 0), dy: lab.at("dy", default: 0), scale: s,
            center: lab.at("center", default: false), normal: lab.at("normal", default: none))
          rects.push(box)
        }
      }
      if rects.len() == 0 { return (0.0, 0.0, 1.0, 1.0) }
      (
        calc.min(..rects.map(r => r.at(0))),
        calc.min(..rects.map(r => r.at(1))),
        calc.max(..rects.map(r => r.at(2))),
        calc.max(..rects.map(r => r.at(3))),
      )
    }
    // Determine the scale.
    let target-w = if width != auto { width.to-absolute().pt() } else if size != auto { if type(size) == array { size.at(0).to-absolute().pt() } else { size.to-absolute().pt() } } else { none }
    let target-h = if height != auto { height.to-absolute().pt() } else if size != auto { if type(size) == array { size.at(1).to-absolute().pt() } else { size.to-absolute().pt() } } else { none }
    let fit = size != auto and width == auto and height == auto // fit within (keep aspect)
    let s = unitsize.to-absolute().pt()
    if target-w != none or target-h != none {
      let sw = if target-w != none { (target-w - 2 * ins) / bw } else { none }
      let sh = if target-h != none { (target-h - 2 * ins) / bh } else { none }
      s = if sw != none and sh != none { calc.min(sw, sh) } else if sw != none { sw } else { sh }
      // refine so that labels and pens fit into the requested size
      for k in range(3) {
        let (L, T, R, B) = layout-extents(s)
        let cw = R - L + 2 * ins
        let ch = B - T + 2 * ins
        let fw = if target-w != none { target-w / cw } else { none }
        let fh = if target-h != none { target-h / ch } else { none }
        let f = if fw != none and fh != none { calc.min(fw, fh) } else if fw != none { fw } else { fh }
        s = s * f
      }
    }
    let (L, T, R, B) = layout-extents(s)
    let ox = ins - L
    let oy = ins - T
    let W = (R - L + 2 * ins) * 1pt
    let H = (B - T + 2 * ins) * 1pt
    let pt = z => (((z.at(0) - minx) * s + ox) * 1pt, ((maxy - z.at(1)) * s + oy) * 1pt)
    // --- geometry -> Typst curve elements (native backend) -----------------
    let to-curve = p2 => {
      let n = p2.nodes.len()
      if n == 0 { return () }
      let nodes = p2.nodes
      let pre = p2.pre
      let post = p2.post
      let strs = p2.straight
      let cyc = p2.cyclic
      let (x0, y0) = nodes.at(0)
      let elems = (curve.move((((x0 - minx) * s + ox) * 1pt, ((maxy - y0) * s + oy) * 1pt)),)
      let Lp = if cyc { n } else { n - 1 }
      for i in range(Lp) {
        let j = if i + 1 == n { 0 } else { i + 1 }
        let (dx, dy) = nodes.at(j)
        let D = (((dx - minx) * s + ox) * 1pt, ((maxy - dy) * s + oy) * 1pt)
        if strs.at(i, default: false) { elems.push(curve.line(D)) } else {
          let (bx, by) = post.at(i)
          let (cx, cy) = pre.at(j)
          elems.push(curve.cubic((((bx - minx) * s + ox) * 1pt, ((maxy - by) * s + oy) * 1pt), (((cx - minx) * s + ox) * 1pt, ((maxy - cy) * s + oy) * 1pt), D))
        }
      }
      if cyc { elems.push(curve.close(mode: "straight")) }
      elems
    }
    // --- geometry -> SVG path data (svg backend) ---------------------------
    let to-d = p2 => {
      let n = p2.nodes.len()
      if n == 0 { return "" }
      let nodes = p2.nodes
      let pre = p2.pre
      let post = p2.post
      let strs = p2.straight
      let cyc = p2.cyclic
      let (x0, y0) = nodes.at(0)
      let parts = ("M" + repr(calc.round((x0 - minx) * s + ox, digits: 2)) + " " + repr(calc.round((maxy - y0) * s + oy, digits: 2)),)
      let Lp = if cyc { n } else { n - 1 }
      for i in range(Lp) {
        let j = if i + 1 == n { 0 } else { i + 1 }
        let (dx, dy) = nodes.at(j)
        if strs.at(i, default: false) {
          parts.push("L" + repr(calc.round((dx - minx) * s + ox, digits: 2)) + " " + repr(calc.round((maxy - dy) * s + oy, digits: 2)))
        } else {
          let (bx, by) = post.at(i)
          let (cx, cy) = pre.at(j)
          parts.push("C" + repr(calc.round((bx - minx) * s + ox, digits: 2)) + " " + repr(calc.round((maxy - by) * s + oy, digits: 2)) + " "
            + repr(calc.round((cx - minx) * s + ox, digits: 2)) + " " + repr(calc.round((maxy - cy) * s + oy, digits: 2)) + " "
            + repr(calc.round((dx - minx) * s + ox, digits: 2)) + " " + repr(calc.round((maxy - dy) * s + oy, digits: 2)))
        }
      }
      if cyc { parts.push("Z") }
      parts.join(" ")
    }
    let hex3 = c => rgb(int(calc.round(c.at(0) * 255)), int(calc.round(c.at(1) * 255)), int(calc.round(c.at(2) * 255))).to-hex()
    let color-attrs = (col, which) => {
      // SVG colour + opacity attributes of a Typst colour
      let u = rgba-of(col)
      let out = which + "=\"" + hex3(u) + "\""
      if u.at(3) < 1 { out += " " + which + "-opacity=\"" + str(calc.round(u.at(3), digits: 3)) + "\"" }
      out
    }
    // A pencil pen is stroked by nibart's elliptical nib. The returned polygons are kept separate so
    // dash and pressure breakup are not silently collapsed into one outline.
    let pencil-paint = p => {
      let c = pen-paint(p)
      if type(c) == color { c } else { pencil-ink }
    }
    let pencil-pressure = (pi, width, pass) => {
      let value = pi.at("pressure", default: none)
      if value == none or type(value) == dictionary { value } else {
        // Backward-compatible numeric pressure: translate it to the
        // nib pressure protocol instead of perturbing points in Typst.
        let strength = calc.min(0.95, calc.max(0.0, float(value)))
        (minimum-axis: width * pi.at("nib-ratio", default: 0.42) * (1 + strength),
          period: calc.max(width * 12, 0.01), seed: pi.at("seed", default: 0) + pass * 97)
      }
    }
    let pencil-dash = (p, width, pass) => {
      let d = p.at("dash", default: none)
      if d == none { return none }
      let unit = if d.at("scale", default: true) { 2 * width } else { 1 / s }
      let lengths = if "typst" in d {
        let td = d.typst
        if type(td) == dictionary and "array" in td {
          td.array.map(x => x.to-absolute().pt() / s)
        } else { () }
      } else {
        d.at("pattern", default: ()).map(x => calc.max(0.000001, float(x)) * unit)
      }
      if lengths.len() == 0 or not lengths.any(x => x > 0) { none } else {
        (lengths: lengths,
          offset: d.at("offset", default: 0.0) * unit,
          jitter: 0.0,
          seed: p.pencil.at("seed", default: 0) + pass * 97)
      }
    }
    let pencil-envelopes = (q, p, pass: 0) => {
      let pi = p.pencil
      let width = 0.5 * p.thickness.to-absolute().pt() / s
      let samples = pi.at("samples", default: none)
      let explicit-pen = if samples == none { none } else { (mode: "explicit", samples: samples) }
      nibridge.envelope-paths(
        k: s,
        q,
        width * pi.at("nib-major", default: 1.15),
        width * pi.at("nib-ratio", default: 0.42),
        angle: pi.at("nib-angle", default: 24.0) * 1deg,
        closed: q.cyclic,
        dash: pencil-dash(p, width, pass),
        pressure: pencil-pressure(pi, width, pass),
        epsilon: 0.003,
        pen: explicit-pen,
      )
    }
    let pencil-fill-attrs = p => {
      let u = rgba-of(pencil-paint(p))
      "fill=\"" + hex3(u) + "\" fill-rule=\"nonzero\"" + (if u.at(3) < 1 { " fill-opacity=\"" + str(calc.round(u.at(3), digits: 3)) + "\"" } else { "" })
    }
    let envelope-d = envelopes => envelopes.map(to-d).filter(d => d != "").join(" ")
    let envelope-curve = envelopes => {
      let out = ()
      for envelope in envelopes { out += to-curve(envelope) }
      out
    }
    let stroke-attrs = p => {
      // stroke attributes of a resolved pen
      let th = p.at("thickness", default: 0.5pt).to-absolute().pt()
      let paint = p.at("paint", default: black)
      let op = p.at("opacity", default: 1.0)
      let u = if type(paint) == color { rgba-of(paint) } else { (0.0, 0.0, 0.0, 1.0) }
      let out = "stroke=\"" + hex3(u) + "\" stroke-width=\"" + str(calc.round(th, digits: 3)) + "\""
      let a = u.at(3) * op
      if a < 1 { out += " stroke-opacity=\"" + str(calc.round(a, digits: 3)) + "\"" }
      out += " stroke-linecap=\"" + p.at("cap", default: "round") + "\" stroke-linejoin=\"" + p.at("join", default: "round") + "\""
      let d = p.at("dash", default: none)
      if d != none {
        let arr = none
        let phase = 0.0
        if "typst" in d {
          let td = d.typst
          if type(td) == dictionary {
            arr = td.array.map(x => if type(x) == length { x.to-absolute().pt() } else { x * th })
            phase = td.at("phase", default: 0pt).to-absolute().pt()
          } else if type(td) == array {
            arr = td.map(x => if type(x) == length { x.to-absolute().pt() } else { x * th })
          } else if type(td) == str {
            let named = ("dotted": (th, 2 * th), "densely-dotted": (th, th), "loosely-dotted": (th, 4 * th),
              "dashed": (3 * th, 3 * th), "densely-dashed": (3 * th, 2 * th), "loosely-dashed": (3 * th, 6 * th),
              "dash-dotted": (3 * th, 2 * th, th, 2 * th), "densely-dash-dotted": (3 * th, th, th, th), "loosely-dash-dotted": (3 * th, 4 * th, th, 4 * th))
            arr = named.at(td, default: none)
          }
        } else {
          let unit = if d.scale { th } else { 1.0 }
          arr = d.pattern.map(x => x * unit)
          phase = d.offset * unit
        }
        if arr != none and arr.len() > 0 and arr.any(x => x > 0) {
          out += " stroke-dasharray=\"" + arr.map(x => str(calc.round(x, digits: 3))).join(" ") + "\""
          if phase != 0 { out += " stroke-dashoffset=\"" + str(calc.round(phase, digits: 3)) + "\"" }
        }
      }
      out
    }
    let Wpt = W.pt()
    let Hpt = H.pt()
    // A run of SVG elements becomes one image.
    let flush = (elems, defs) => {
      if elems.len() == 0 { return none }
      let head = "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"" + str(calc.round(Wpt, digits: 3)) + "\" height=\"" + str(calc.round(Hpt, digits: 3)) + "\" viewBox=\"0 0 " + str(calc.round(Wpt, digits: 3)) + " " + str(calc.round(Hpt, digits: 3)) + "\">"
      let d = if defs.len() > 0 { "<defs>" + defs.join() + "</defs>" } else { "" }
      place(top + left, image(bytes(head + d + elems.join() + "</svg>"), format: "svg", width: W, height: H, fit: "stretch"))
    }
    let svg = backend == "svg"
    let body = ()
    let elems = ()
    let defs = ()
    let ngrad = 0
    let in-group = false
    let group-alpha = 1.0
    // fill primitive (patch or arrow head) in either backend; returns
    // (svg element, gradient definition, native content), each possibly none
    let make-fill = (p2, holes, col, grad, alpha, st, gid) => {
      // col: (r, g, b); grad: none | (x1, y1, x2, y2, c1, c2) in user coordinates
      // st: none | "seam" | resolved pen (mesh)
      if svg {
        let d = to-d(p2)
        for h in holes { d += " " + to-d(h) }
        if d == "" { return (none, none, none) }
        let paint = none
        let def = none
        if grad != none {
          let id = "g" + str(gid)
          let (x1, y1, x2, y2, c1, c2, ..) = grad
          def = "<linearGradient id=\"" + id + "\" gradientUnits=\"userSpaceOnUse\" x1=\"" + str(calc.round((x1 - minx) * s + ox, digits: 2)) + "\" y1=\"" + str(calc.round((maxy - y1) * s + oy, digits: 2)) + "\" x2=\"" + str(calc.round((x2 - minx) * s + ox, digits: 2)) + "\" y2=\"" + str(calc.round((maxy - y2) * s + oy, digits: 2)) + "\"><stop offset=\"0\" stop-color=\"" + hex3(c1) + "\"/><stop offset=\"1\" stop-color=\"" + hex3(c2) + "\"/></linearGradient>"
          paint = "url(#" + id + ")"
        } else if col != none { paint = hex3(col) }
        let attrs = if paint == none { "fill=\"none\"" } else { "fill=\"" + paint + "\"" + (if alpha < 1 { " fill-opacity=\"" + str(calc.round(alpha, digits: 3)) + "\"" } else { "" }) }
        if holes.len() > 0 { attrs += " fill-rule=\"evenodd\"" }
        if st == "seam" and paint != none { attrs += " stroke=\"" + paint + "\" stroke-width=\"" + str(seam-width) + "\" stroke-linejoin=\"round\"" + (if alpha < 1 { " stroke-opacity=\"" + str(calc.round(alpha, digits: 3)) + "\"" } else { "" }) }
        let is-pencil = st != none and st != "seam" and st.at("pencil", default: none) != none
        if st != none and st != "seam" and not is-pencil { attrs += " " + stroke-attrs(st) }
        let extra = ""
        if is-pencil {
          let pi = st.pencil
          let passes = calc.max(1, int(pi.at("passes", default: 1)))
          for q in range(passes) {
            let wd = envelope-d(pencil-envelopes(p2, st, pass: q))
            if wd != "" { extra += "<path d=\"" + wd + "\" " + pencil-fill-attrs(st) + "/>" }
          }
        }
        ("<path d=\"" + d + "\" " + attrs + "/>" + extra, def, none)
      } else {
        let el = to-curve(p2)
        for h in holes { el += to-curve(h) }
        if el.len() == 0 { return (none, none, none) }
        let paint = if col == none { none } else { rgbf(col.at(0), col.at(1), col.at(2), a: alpha) }
        let is-pencil = st != none and st != "seam" and st.at("pencil", default: none) != none
        let stk = if st == "seam" and paint != none { std.stroke(paint: paint, thickness: seam-width * 1pt, join: "round") } else if st != none and st != "seam" and not is-pencil { pen-stroke(st) } else { none }
        let bd = place(top + left, curve(fill: paint, stroke: stk, fill-rule: "even-odd", ..el))
        if is-pencil {
          let pi = st.pencil
          let passes = calc.max(1, int(pi.at("passes", default: 1)))
          for q in range(passes) {
            let wel = envelope-curve(pencil-envelopes(p2, st, pass: q))
            if wel.len() > 1 { bd += place(top + left, curve(fill: pencil-paint(st), fill-rule: "non-zero", stroke: none, ..wel)) }
          }
        }
        (none, none, bd)
      }
    }
    // Labels are collected and emitted after all geometry so that an annotation
    // cannot be hidden by a later face or edge. This mirrors the usual 3D-scene
    // layering rule: geometry first, readable annotations last.
    let overlay-labels = ()
    for (k, pr) in prims.enumerate() {
      if pr.type == "group" {
        if svg {
          elems.push("<g opacity=\"" + str(calc.round(pr.alpha, digits: 3)) + "\">")
        }
        in-group = true
        group-alpha = pr.alpha
      } else if pr.type == "endgroup" {
        if svg { elems.push("</g>") }
        in-group = false
        group-alpha = 1.0
      } else if pr.type == "fill" {
        // inside a group the patches are opaque (the group carries the
        // opacity); the native backend applies it per patch instead
        let alpha = if in-group { if svg { 1.0 } else { group-alpha } } else { pr.alpha }
        let st = if pr.mesh != none { pr.mesh } else if pr.seam and (svg or alpha >= 0.999) { "seam" } else { none }
        let grad = if svg { pr.grad } else { none }
        let (el, df, bd) = make-fill(pr.p2, pr.at("holes", default: ()), pr.fill, grad, alpha, st, ngrad + 1)
        if df != none { defs.push(df); ngrad += 1 }
        if el != none { elems.push(el) }
        if bd != none { body.push(bd) }
        if pr.hatch != none and svg {
          let hs = pr.hatch
          let hpen = resolve-pen(if type(hs) == dictionary { hs.at("pen", default: default-pen) } else { hs })
          if hpen != none {
            for hp2 in hatch-segments2(pr.p2, hs) {
              let pi = hpen.at("pencil", default: none)
              let passes = if pi == none { 1 } else { calc.max(1, int(pi.at("passes", default: 3))) }
              for q in range(passes) {
                if pi == none {
                  let hd = to-d(hp2)
                  if hd != "" { elems.push("<path d=\"" + hd + "\" fill=\"none\" " + stroke-attrs(hpen) + "/>" ) }
                } else {
                  let hd = envelope-d(pencil-envelopes(hp2, hpen, pass: q))
                  if hd != "" { elems.push("<path d=\"" + hd + "\" " + pencil-fill-attrs(hpen) + "/>" ) }
                }
              }
            }
          }
        }
        if pr.hatch != none and not svg {
          let hs = pr.hatch
          let hpen = resolve-pen(if type(hs) == dictionary { hs.at("pen", default: default-pen) } else { hs })
          if hpen != none {
            for hp2 in hatch-segments2(pr.p2, hs) {
              let pi = hpen.at("pencil", default: none)
              let passes = if pi == none { 1 } else { calc.max(1, int(pi.at("passes", default: 3))) }
              for q in range(passes) {
                let envelopes = if pi == none { (hp2,) } else { pencil-envelopes(hp2, hpen, pass: q) }
                let hel = envelope-curve(envelopes)
                if hel.len() > 1 {
                  body.push(place(top + left, if pi == none { curve(stroke: pen-stroke(hpen), ..hel) } else { curve(fill: pencil-paint(hpen), fill-rule: "non-zero", stroke: none, ..hel) }))
                }
              }
            }
          }
        }
        if pr.stipple != none and svg {
          let ss = pr.stipple
          let sp = resolve-pen(if type(ss) == dictionary { ss.at("pen", default: pencil-pen()) } else { ss })
          if sp != none {
            let u = rgba-of(pen-paint(sp))
            for dot in stipple-dots2(pr.p2, ss, holes: pr.at("holes", default: ())) {
              let z = dot.z
              let rr = dot.radius * s
              elems.push("<circle cx=\"" + str(calc.round((z.at(0) - minx) * s + ox, digits: 2)) + "\" cy=\"" + str(calc.round((maxy - z.at(1)) * s + oy, digits: 2)) + "\" r=\"" + str(calc.round(rr, digits: 3)) + "\" fill=\"" + hex3(u) + "\"" + (if u.at(3) < 1 { " fill-opacity=\"" + str(calc.round(u.at(3), digits: 3)) + "\"" } else { "" }) + "/>" )
            }
          }
        }
        if pr.stipple != none and not svg {
          let ss = pr.stipple
          let sp = resolve-pen(if type(ss) == dictionary { ss.at("pen", default: pencil-pen()) } else { ss })
          if sp != none {
            for dot in stipple-dots2(pr.p2, ss, holes: pr.at("holes", default: ())) {
              let rr = dot.radius * s * 1pt
              let z = dot.z
              body.push(place(top + left, dx: ((z.at(0) - minx) * s + ox) * 1pt - rr, dy: ((maxy - z.at(1)) * s + oy) * 1pt - rr, circle(radius: rr, fill: pen-paint(sp), stroke: none)))
            }
          }
        }
      } else if pr.type == "path" {
        let p2 = pr.p2
        if pr.pen != none {
          let stk = pen-stroke(pr.pen)
          if stk != none and p2.nodes.len() > 0 {
            let heads = ()
            if pr.arrow != none and p2.nodes.len() > 1 {
              let asz = if pr.arrow.size == auto { if arrowsize == auto { arrowfactor * pr.pen.thickness } else { arrowsize } } else { pr.arrow.size }
              let asz-pt = asz.to-absolute().pt()
              let ends = if pr.arrow.position == "both" { ("end", "begin") } else { (pr.arrow.position,) }
              for e in ends {
                let at-end = e == "end"
                if pr.arrow.style == "cone" and "g" in pr {
                  // 3D cone head (Asymptote's DefaultHead3), lit and depth-sorted
                  let g3 = pr.g
                  let L3 = length3(g3)
                  let tip3 = if at-end { point(g3, L3) } else { point(g3, 0) }
                  let d3 = dir(g3, if at-end { float(L3) } else { 0.0 })
                  if not at-end { d3 = vneg(d3) }
                  let size-u = asz-pt / s
                  let radius = size-u * calc.tan(pr.arrow.angle * 1deg)
                  let base-c = vsub(tip3, vmul(size-u, d3))
                  let base = Circle3(base-c, radius, normal: d3, n: 12)
                  let head = surface(cone-over(base, tip3), surface(base))
                  let mat = tomaterial(pen-paint(pr.pen))
                  let mc = material-components(mat)
                  let items = head.patches.enumerate().map(((i, q)) => (closeness(P, q.center), i)).sorted(key: it => it.at(0))
                  for it in items {
                    let q = head.patches.at(it.at(1))
                    let cols = shade-many((q.normal,), mc, light0, P.modelview)
                    if cols != none {
                      heads.push((project-path(P, q.boundary, ninterpolate: 1), cols.at(0), mc.alpha))
                    }
                  }
                } else {
                  let Lp = path2.length2(p2)
                  let tip = if at-end { p2.nodes.last() } else { p2.nodes.first() }
                  let d = path2.dir2(p2, if at-end { float(Lp) } else { 0.0 })
                  if not at-end { d = (-d.at(0), -d.at(1)) }
                  // head in user coordinates
                  let hl = asz-pt / s
                  let hw = hl * calc.tan(pr.arrow.angle * 1deg)
                  let nn = (-d.at(1), d.at(0))
                  let bx = tip.at(0) - hl * d.at(0)
                  let by = tip.at(1) - hl * d.at(1)
                  let tri = (kind: "path", nodes: (tip, (bx + hw * nn.at(0), by + hw * nn.at(1)), (bx - hw * nn.at(0), by - hw * nn.at(1))),
                    pre: (tip, tip, tip), post: (tip, tip, tip), straight: (true, true, true), cyclic: true)
                  let u = rgba-of(pen-paint(pr.pen))
                  heads.push((tri, (u.at(0), u.at(1), u.at(2)), u.at(3)))
                }
                // shorten the drawn path by the arrow length
                let shortened = shorten2(p2, asz-pt / s * 0.9, at-end)
                if shortened != none { p2 = shortened }
              }
            }
            if p2.nodes.len() > 1 {
              let pi = pr.pen.at("pencil", default: none)
              let nib = pi != none
              let passes = if not nib { 1 } else { calc.max(1, int(pi.at("passes", default: 1))) }
              if svg {
                for q in range(passes) {
                  if not nib {
                    let d = to-d(p2)
                    if d != "" { elems.push("<path d=\"" + d + "\" fill=\"none\" " + stroke-attrs(pr.pen) + "/>" ) }
                  } else {
                    let d = envelope-d(pencil-envelopes(p2, pr.pen, pass: q))
                    if d != "" { elems.push("<path d=\"" + d + "\" " + pencil-fill-attrs(pr.pen) + "/>" ) }
                  }
                }
              } else {
                for q in range(passes) {
                  let qpaths = if not nib { (p2,) } else { pencil-envelopes(p2, pr.pen, pass: q) }
                  let el = envelope-curve(qpaths)
                  if el.len() > 1 {
                    body.push(place(top + left, if not nib { curve(stroke: stk, ..el) } else { curve(fill: pencil-paint(pr.pen), fill-rule: "non-zero", stroke: none, ..el) }))
                  }
                }
              }
            }
            for (hp, hc, ha) in heads {
              let (el, df, bd) = make-fill(hp, (), hc, none, ha, if svg { "seam" } else { none }, 0)
              if el != none { elems.push(el) }
              if bd != none { body.push(bd) }
            }
          }
        }
        if pr.label != none {
          let lab = pr.label
          let mz = measure(lab.body)
          overlay-labels.push((body: lab.body, z: lab.z, align: lab.align, pen: lab.pen,
            w: mz.width.pt(), h: mz.height.pt(), dx: lab.at("dx", default: 0),
            dy: lab.at("dy", default: 0), center: lab.at("center", default: false),
            normal: lab.at("normal", default: none), extra: 0))
        }
      } else if pr.type == "ink" {
        if svg {
          let u = rgba-of(pr.paint)
          let a = u.at(3) * pr.alpha
          elems.push("<path d=\"" + pr.paths.map(to-d).filter(d => d != "").join(" ") + "\" fill=\"" + hex3(u) + "\" fill-rule=\"nonzero\"" + (if a < 1 { " fill-opacity=\"" + str(calc.round(a, digits: 3)) + "\"" } else { "" }) + "/>")
        } else {
          let el = ()
          for q in pr.paths { el += to-curve(q) }
          if el.len() > 1 { body.push(place(top + left, curve(fill: rgbf(..rgba-of(pr.paint).slice(0, 3), a: rgba-of(pr.paint).at(3) * pr.alpha), fill-rule: "non-zero", stroke: none, ..el))) }
        }
      } else if pr.type == "dot" {
        let z = pt(pr.z)
        if svg {
          let u = rgba-of(pr.paint)
          elems.push("<circle cx=\"" + str(calc.round(z.at(0).pt(), digits: 2)) + "\" cy=\"" + str(calc.round(z.at(1).pt(), digits: 2)) + "\" r=\"" + str(calc.round(pr.r.pt(), digits: 3)) + "\" fill=\"" + hex3(u) + "\"" + (if u.at(3) < 1 { " fill-opacity=\"" + str(calc.round(u.at(3), digits: 3)) + "\"" } else { "" }) + "/>")
        } else {
          body.push(place(top + left, dx: z.at(0) - pr.r, dy: z.at(1) - pr.r, circle(radius: pr.r, fill: pr.paint, stroke: none)))
        }
      } else if pr.type == "label" {
        let mz = measured.at(k)
        overlay-labels.push((body: mz.body, z: pr.z, align: pr.align, pen: pr.pen,
          w: mz.w, h: mz.h, dx: pr.at("dx", default: 0), dy: pr.at("dy", default: 0),
          center: pr.at("center", default: false), normal: pr.at("normal", default: none),
          extra: if "extra" in pr { pr.extra.pt() } else { 0 }))
      }
    }
    // Emit every label only after the geometry pass. Keeping the original
    // measured dimensions preserves structured Typst content and its rotation.
    for lab in overlay-labels {
      let mg = labelmargin-factor * fs.pt() + 0.5 * lab.pen.thickness.pt() + lab.extra
      let z = pt(lab.z)
      let box = label-box((z.at(0).pt(), z.at(1).pt()), lab.align, lab.w, lab.h, mg,
        dx: lab.dx, dy: lab.dy, scale: s, center: lab.center, normal: lab.normal)
      if svg { body.push(flush(elems, defs)); elems = (); defs = () }
      body.push(place(top + left, dx: box.at(0) * 1pt, dy: box.at(1) * 1pt, lab.body))
    }
    if svg { body.push(flush(elems, defs)) }
    box(width: W, height: H, fill: fill, stroke: stroke, radius: radius, clip: clip, baseline: baseline, body.filter(b => b != none).join())
  }
  }
}
