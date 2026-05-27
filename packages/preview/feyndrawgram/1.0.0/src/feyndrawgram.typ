#import "@preview/cetz:0.5.2"

#let APP_VERSION=1.0

// --- Color parsing ---------------------------------------------------
#let _hexStrToInt(string) = {
  let res = 0;
  for i in upper(string).clusters() {
    res = res * 16;
    let c = i.to-unicode()
    if ( 0x30 <= c and c <= 0x39 ) {
      c = c - 0x30
    } else if ( 0x41 <= c and c <= 0x46 ) {
      c = c - 0x41 + 10
    } else {
      panic("Invalid hexadecimal number: " + string)
    }
    res += c
  }
  return res
}

#let _hex-to-rgb(hex) = {
  let h = if hex == none { "#000000" } else { hex }
  if h.starts-with("#") { h = h.slice(1) }
  if h.len() == 3 or h.len() == 4 { // alpha channel
    h = h.at(0) + h.at(0) + h.at(1) + h.at(1) + h.at(2) + h.at(2)
  }
  let r = _hexStrToInt(h.slice(0, 2))
  let g = _hexStrToInt(h.slice(2, 4))
  let b = _hexStrToInt(h.slice(4, 6))
  rgb(r, g, b)
}

// --- Coordinate conversion: SVG (y-down) -> CeTZ (y-up) --------------

#let _xy(x, y, unit) = (x * unit, -y * unit)

#let _wrap-angle(a) = {
  let r = a
  while r >   calc.pi { r -= 2 * calc.pi }
  while r <= -calc.pi { r += 2 * calc.pi }
  r
}

// =====================================================================
// EDGE GEOMETRY - mirrors render() in feyndrawgram.js of the web app
// =====================================================================

#let _edge-geom(edge) = {
  let dx = edge.x2 - edge.x1
  let dy = edge.y2 - edge.y1
  let c  = calc.sqrt(dx*dx + dy*dy)
  let curv = edge.at("curvature", default: 0)

  if c < 0.1 {
    // tadpole / self-loop
    let R = if curv == 0 or calc.abs(curv) < 2 { 20.0 }
            else { calc.abs(curv) }
    let a-base = edge.at("tadpoleAngle", default: -calc.pi/2)
    (
      shape: "tadpole",
      c: c, L: 2 * calc.pi * R,
      cx: edge.x1 + R * calc.cos(a-base),
      cy: edge.y1 + R * calc.sin(a-base),
      R: R, a-base: a-base,
    )
  } else if curv == 0 {
    // straight line
    (
      shape: "straight",
      c: c, L: c,
      dx: dx, dy: dy,
      tang: calc.atan2(dx, dy).rad(),
    )
  } else {
    // circular arc
    let s = curv
    let R = calc.abs(s/2 + (c*c)/(8*s))
    let sign-s = if s > 0 { 1 } else { -1 }
    let h = s - R * sign-s
    let cxA = (edge.x1 + edge.x2)/2 + (-dy/c) * h
    let cyA = (edge.y1 + edge.y2)/2 + ( dx/c) * h
    let a1 = calc.atan2(edge.x1 - cxA, edge.y1 - cyA).rad()
    let a2 = calc.atan2(edge.x2 - cxA, edge.y2 - cyA).rad()
    let diff = _wrap-angle(a2 - a1)
    if s > 0 and diff > 0 { diff -= 2 * calc.pi }
    if s < 0 and diff < 0 { diff += 2 * calc.pi }
    (
      shape: "arc",
      c: c, L: R * calc.abs(diff),
      cx: cxA, cy: cyA, R: R,
      a1: a1, diff: diff, s: s, sign-s: sign-s,
    )
  }
}

#let _get-tangent-angle(edge, geom, t) = {
  if geom.shape == "tadpole" {
    let flip = edge.at("arrowFlip", default: false)
    let start-angle = geom.a-base + calc.pi
    let cur = if flip { start-angle - t * 2 * calc.pi }
              else    { start-angle + t * 2 * calc.pi }
    if flip { cur - calc.pi/2 } else { cur + calc.pi/2 }
  } else if geom.shape == "straight" {
    geom.tang
  } else if t == 0.5 {
    // Arc midpoint: tangent matches chord direction.
    let dx = edge.x2 - edge.x1
    let dy = edge.y2 - edge.y1
    calc.atan2(dx, dy).rad()
  } else {
    geom.a1 + geom.diff * t + (if geom.s > 0 { -calc.pi/2 } else { calc.pi/2 })
  }
}

#let _get-base-point(edge, geom, t) = {
  let tang = _get-tangent-angle(edge, geom, t)
  let x = 0; let y = 0
  if geom.shape == "tadpole" {
    let flip = edge.at("arrowFlip", default: false)
    let start-angle = geom.a-base + calc.pi
    let ang = if flip { start-angle - t * 2 * calc.pi }
              else    { start-angle + t * 2 * calc.pi }
    x = geom.cx + geom.R * calc.cos(ang)
    y = geom.cy + geom.R * calc.sin(ang)
  } else if geom.shape == "straight" {
    x = edge.x1 + t * geom.dx
    y = edge.y1 + t * geom.dy
  } else {
    let ang = geom.a1 + geom.diff * t
    x = geom.cx + geom.R * calc.cos(ang)
    y = geom.cy + geom.R * calc.sin(ang)
  }
  (
    x: x, y: y,
    tx: calc.cos(tang),  ty: calc.sin(tang),
    nx: -calc.sin(tang), ny: calc.cos(tang),
  )
}

// =====================================================================
// PATTERN FILLS
// =====================================================================

#let _resolve-fill(obj, unit) = {
  let ft = obj.at("fillType", default: "solid")
  let fc = _hex-to-rgb(obj.at("fillColor", default: "#ffffff"))
  if ft != "pattern" { return fc }

  let ang = calc.rem(obj.at("patAngle", default: 45), 180)
  while (ang < 0)   { ang += 180 }
  while (ang > 180) { ang -= 180 }
  ang = ang * 1deg

  let spacing = obj.at("patSpacing", default: 10) * unit
  let lw      = obj.at("patWidth",   default: 2 ) * unit / 2
  let lc      = _hex-to-rgb(obj.at("patColor", default: "#000000"))

  // cutoff of 5 deg for numerical stability

  let pat

  if(ang < 5deg or ang > 175deg) {
    // horizontal lines
    let pat_w = 10pt
    let pat_h = spacing

    pat = tiling(
      size: ( pat_w, pat_h ), {
      place(rect(width: pat_w, height: pat_h, fill: fc, stroke: none))
      place(
        line(
          start: (0%,50%),
          end:   (100%,50%),
          stroke: lw + lc
        )
      )
    })
  } else if (ang > 85deg and ang < 95deg) {
    // vertical lines    let pat_w = 10pt
    let pat_w = spacing
    let pat_h = 10pt

    pat = tiling(
      size: ( pat_w, pat_h ), {
      place(rect(width: pat_w, height: pat_h, fill: fc, stroke: none))
      place(
        line(
          start: (50%,0%),
          end:   (50%,10%),
          stroke: lw + lc
        )
      )
    })
  } else {
    // generic pattern
    let pat_w = calc.abs( spacing / calc.sin(ang) )
    let pat_h = calc.abs( spacing / calc.cos(ang) )
    let sign = if calc.cos(ang) > 0 {-1.0} else {+1.0}

    pat = tiling(
      size: ( pat_w, pat_h ), {
      place(rect(width: pat_w, height: pat_h, fill: fc, stroke: none))
      place( line(
        start: (-50%,50%-50%*sign),
        end:   (150%,50%+100%*sign+50%*sign),
        stroke: lw + lc
      ))
      place( line(
        start: (-50%,50%-150%*sign),
        end:   (150%,50%+50%*sign),
        stroke: lw + lc
      ))
    })
  }

  return pat
}

// =====================================================================
// EDGES
// =====================================================================

// ---- Smooth path (line/arc/tadpole) as a CeTZ draw element. The stroke
//      is "none" by default because this is used as the base path for
//      cetz.decorations.* which draw the wave themselves on top.
#let _build-smooth-path(edge, geom, offset, unit, stroke: none) = {
  if geom.shape == "tadpole" {
    let flip     = edge.at("arrowFlip", default: false)
    let tad-sign = if flip { 1 } else { -1 }
    let Rn       = geom.R + offset * tad-sign
    let start-a  = geom.a-base + calc.pi
    let end-a    = start-a + (if flip { 2 * calc.pi } else { -2 * calc.pi })
    let sx = geom.cx + Rn * calc.cos(start-a)
    let sy = geom.cy + Rn * calc.sin(start-a)
    cetz.draw.arc(
      _xy(sx, sy, unit),
      start:  (-start-a) * 1rad,
      stop:   (-end-a)   * 1rad,
      radius: Rn * unit,
      stroke: stroke,
    )
  } else if geom.shape == "straight" {
    let nx = -geom.dy / geom.c
    let ny =  geom.dx / geom.c
    cetz.draw.line(
      _xy(edge.x1 + offset*nx, edge.y1 + offset*ny, unit),
      _xy(edge.x2 + offset*nx, edge.y2 + offset*ny, unit),
      stroke: stroke,
    )
  } else {
    let Rn = geom.R + offset * geom.sign-s
    let sx = geom.cx + Rn * calc.cos(geom.a1)
    let sy = geom.cy + Rn * calc.sin(geom.a1)
    cetz.draw.arc(
      _xy(sx, sy, unit),
      start:  (-geom.a1) * 1rad,
      stop:   (-(geom.a1 + geom.diff)) * 1rad,
      radius: Rn * unit,
      stroke: stroke,
    )
  }
}

// ---- Explicit (sampled) edge: clones the JS render() loop verbatim
#let _render-edge-explicit(edge, geom, unit, stroke-color) = {
  let mult = edge.at("multiplicity", default: 1)
  let sw   = edge.at("strokeWidth",  default: 2)
  let lt   = edge.at("lineType",     default: "solid")

  let stroke-style = (paint: stroke-color, thickness: sw * unit)
  if lt == "dashed" {
    let dl = edge.at("dashLength", default: 5)
    stroke-style.insert("dash", (array: (dl * unit, dl * unit)))
  }

  let base-off = sw
  let offsets = if mult == 1 { (0,) }
                else if mult == 2 { (-base-off, base-off) }
                else { (-base-off * 1.5, 0, base-off * 1.5) }

  for offset in offsets {
    let pts = ()
    if lt == "wavy" or lt == "gluon" {
      let is-gluon = lt == "gluon"
      let lambda   = if is-gluon { 12 } else { 10 }
      let A        = (if is-gluon { 5 } else { 3 }) / mult
      let m        = calc.max(1, calc.round(geom.L / lambda))
      let steps    = calc.max(20, calc.ceil(5 * geom.L))
      for i in range(steps + 1) {
        let t  = i / steps
        let pt = _get-base-point(edge, geom, t)
        let ph = t * m * 2 * calc.pi
        let bx = pt.x + offset * pt.nx
        let by = pt.y + offset * pt.ny
        let px = 0; let py = 0
        if is-gluon {
          px = bx + A*calc.sin(ph)*pt.nx + A*(calc.cos(ph) - 1)*pt.tx
          py = by + A*calc.sin(ph)*pt.ny + A*(calc.cos(ph) - 1)*pt.ty
        } else {
          px = bx + A*calc.sin(ph)*pt.nx
          py = by + A*calc.sin(ph)*pt.ny
        }
        pts.push(_xy(px, py, unit))
      }
    } else {
      let steps = if geom.shape == "straight" { 1 }
                  else { calc.ceil(geom.L / 2) }
      for i in range(steps + 1) {
        let t  = i / steps
        let pt = _get-base-point(edge, geom, t)
        pts.push(_xy(pt.x + offset * pt.nx,
                     pt.y + offset * pt.ny, unit))
      }
    }
    cetz.draw.line(..pts, stroke: stroke-style)
  }
}

// ---- Native (CeTZ decorations) edge: only used when use-cetz-decorations
//      is true AND the edge is mult=1 oscillating (caller checks).
#let _render-edge-native(edge, geom, unit, stroke-color) = {
  let sw  = edge.at("strokeWidth", default: 2)
  let lt  = edge.lineType
  let A   = (if lt == "gluon" { 12 } else { 8 })
  let lam = if lt == "gluon" { 15 } else { 10 }
  let seg = int(calc.max(2, calc.round(geom.L / lam)))
  let stroke-style = (paint: stroke-color, thickness: sw * unit)

  let base = _build-smooth-path(edge, geom, 0, unit, stroke: none)
  if lt == "wavy" {
    cetz.decorations.wave(base,
      amplitude: A * unit, segments: seg, stroke: stroke-style)
  } else { // gluon
    cetz.decorations.coil(base,
      amplitude: A * unit, segments: seg, stroke: stroke-style)
  }
}

#let _render-edge(edge, unit, use-cetz-decorations: false) = {
  let stroke-color = _hex-to-rgb(edge.at("color", default: "#000000"))
  let geom = _edge-geom(edge)
  let lt   = edge.at("lineType",     default: "solid")
  let mult = edge.at("multiplicity", default: 1)

  let can-use-native = (
    use-cetz-decorations and
    (lt == "wavy" or lt == "gluon") and
    mult == 1
  )

  if can-use-native {
    _render-edge-native(edge, geom, unit, stroke-color)
  } else {
    _render-edge-explicit(edge, geom, unit, stroke-color)
  }
}

// ---- Arrows: stealth-shaped filled triangles. The local-frame triangle
//      from render() is M 0 0 L -s -s/2.5 L -s*0.7 0 L -s s/2.5 Z (SVG
//      y-down). In CeTZ y-up we flip the y of the local vertices and
//      negate the rotation angle.
#let _render-edge-arrows(edge, unit) = {
  let has-start = edge.at("arrowStart", default: false)
  let has-mid   = edge.at("arrowMid",   default: false)
  let has-end   = edge.at("arrowEnd",   default: false)
  if not (has-start or has-mid or has-end) { return }

  let geom        = _edge-geom(edge)
  let stroke-col  = _hex-to-rgb(edge.at("color", default: "#000000"))
  let sw          = edge.at("strokeWidth", default: 2)
  let s           = edge.at("arrowSize",   default: 20)
  let flip        = edge.at("arrowFlip",   default: false)
  let is-tadpole  = geom.c < 0.1
  let end-offset  = sw * 1.5
  let mid-offset  = s * 0.35

  let emit(t, angle, offset) = {
    // angle adjustment that render() applies for flipped non-tadpole arrows
    let eff = if flip and not is-tadpole { angle + calc.pi } else { angle }
    // CeTZ y-up: negate rotation, flip the local-y of the triangle vertices.
    cetz.draw.group({
      let pt = _get-base-point(edge, geom, t)
      cetz.draw.translate(_xy(pt.x, pt.y, unit))
      cetz.draw.rotate((-eff) * 1rad)
      cetz.draw.translate((offset * unit, 0pt))
      cetz.draw.line(
        (0pt, 0pt),
        (-s * unit,      s/2.5 * unit),   // y-flipped wrt SVG
        (-s*0.7 * unit,  0pt),
        (-s * unit,     -s/2.5 * unit),   // y-flipped wrt SVG
        close: true, fill: stroke-col, stroke: none,
      )
    })
  }

  if has-start { emit(0,   _get-tangent-angle(edge, geom, 0)   + calc.pi, end-offset) }
  if has-end   { emit(1,   _get-tangent-angle(edge, geom, 1),        end-offset) }
  if has-mid   { emit(0.5, _get-tangent-angle(edge, geom, 0.5),      mid-offset) }
}

// =====================================================================
// SHAPES (boxes and blobs)
// =====================================================================

#let _render-shape(shape, unit) = {
  let stroke-col = _hex-to-rgb(shape.at("color", default: "#000000"))
  let sw         = shape.at("strokeWidth", default: 2)
  let stroke     = (paint: stroke-col, thickness: sw * unit)
  let fill       = _resolve-fill(shape, unit)

  if shape.type == "circle" {
    cetz.draw.circle(
      _xy(shape.x, shape.y, unit),
      radius: (shape.rx * unit, shape.ry * unit),
      fill: fill, stroke: stroke,
    )
  } else {
    cetz.draw.rect(
      _xy(shape.x, shape.y, unit),
      _xy(shape.x + shape.width, shape.y + shape.height, unit),
      fill: fill, stroke: stroke,
    )
  }
}

// =====================================================================
// NODES (vertices)
// =====================================================================

#let _render-node(node, unit) = {
  let stroke-col = _hex-to-rgb(node.at("color", default: "#000000"))
  let sw     = node.at("strokeWidth", default: 2)
  let r      = node.at("radius",      default: 5)
  let style  = node.at("nodeStyle",   default: "solid")
  let stroke = (paint: stroke-col, thickness: sw * unit)
  let fill   = _resolve-fill(node, unit)
  let pos    = _xy(node.x, node.y, unit)

  if style == "solid" {
    // In render(): fill = (fillType==solid ? color : pattern).
    let f = if node.at("fillType", default: "solid") == "solid" {
      stroke-col
    } else { fill }
    cetz.draw.circle(pos, radius: r * unit, fill: f, stroke: stroke)

  } else if style == "odot" {
    cetz.draw.circle(pos, radius: r       * unit, fill: fill,        stroke: stroke)
    cetz.draw.circle(pos, radius: r / 3   * unit, fill: stroke-col,  stroke: none)

  } else if style == "otimes" {
    cetz.draw.circle(pos, radius: r * unit, fill: fill, stroke: stroke)
    let d = r * 0.707
    cetz.draw.line(
      _xy(node.x - d, node.y - d, unit),
      _xy(node.x + d, node.y + d, unit),
      stroke: stroke,
    )
    cetz.draw.line(
      _xy(node.x - d, node.y + d, unit),
      _xy(node.x + d, node.y - d, unit),
      stroke: stroke,
    )

  } else if style == "square" {
    cetz.draw.rect(
      _xy(node.x - r, node.y - r, unit),
      _xy(node.x + r, node.y + r, unit),
      fill: fill, stroke: stroke,
    )

  } else if style == "diamond" {
    cetz.draw.group({
      cetz.draw.translate(pos)
      cetz.draw.rotate(45deg)
      cetz.draw.rect(
        (-r * unit, -r * unit),
        ( r * unit,  r * unit),
        fill: fill, stroke: stroke,
      )
    })
  }
}

// =====================================================================
// LABELS
// =====================================================================

#let _render-label(label, unit) = {
  cetz.draw.content(
    _xy(label.x, label.y, unit),
    eval(label.text, mode: "markup"),
  )
}

// =====================================================================
// PUBLIC API
// =====================================================================

#let feyndrawgram(
  data,
  use-cetz-decorations: false,
  unit: none,
) = {
  unit = if unit != none {
    unit
  } else {
    let version = float(data.at("version", default: "0.0"))
    if version < 1.0 {
      25 / 40 * 1pt
    } else if version > APP_VERSION {
      panic("Warning: this file has been created with a more recent version of FeynDrawGram (v"+str(version)+"). Unexpected errors may occur.")
    } else {
      1pt
    }
  }

  if type(data) != dictionary {
    panic("feyndrawgram: expected a dictionary (parsed JSON), got "
          + str(type(data)))
  }
  let ver = data.at("version", default: none)

  let edges  = data.at("edges",  default: ())
  let shapes = data.at("shapes", default: ())
  let nodes  = data.at("nodes",  default: ())
  let labels = data.at("labels", default: ())

  cetz.canvas({
    // Order matches render() in feyndrawgram.js:
    // 1) edges (and their arrows) underneath
    for edge in edges {
      _render-edge(edge, unit, use-cetz-decorations: use-cetz-decorations)
      _render-edge-arrows(edge, unit)
    }
    // 2) shapes (boxes/blobs)
    for shape in shapes { _render-shape(shape, unit) }
    // 3) nodes (vertices)
    for node  in nodes  { _render-node(node, unit) }
    // 4) labels (text) on top
    for label in labels { _render-label(label, unit) }
  })
}