// Native engine: a pure-Typst re-implementation of the common draw.io shapes,
// edges and labels. Used by `drawio(..., engine: "native")` in lib.typ; it
// needs no plugin but only approximates draw.io's rendering.

#import "inflate.typ": base64-decode, inflate, url-decode

// ───────────────────────── XML helpers ─────────────────────────

#let _elems(node) = node.children.filter(c => type(c) == dictionary)
#let _find(node, tag) = _elems(node).find(c => c.tag == tag)
#let _all(node, tag) = _elems(node).filter(c => c.tag == tag)
#let _text-of(node) = node.children.filter(c => type(c) == str).join("")

#let _first-elem(nodes) = nodes.filter(c => type(c) == dictionary).first()

// Returns the <mxGraphModel> element of the requested page.
#let _model(data, page) = {
  let src = if type(data) == str { bytes(data) } else { data }
  let rootel = _first-elem(xml(src))
  if rootel.tag == "mxGraphModel" { return rootel }
  assert(rootel.tag == "mxfile", message: "drawio: not a draw.io file")
  let pages = _all(rootel, "diagram")
  assert(pages.len() > 0, message: "drawio: file contains no diagram")
  let d = if type(page) == int {
    assert(page < pages.len(), message: "drawio: page index out of range")
    pages.at(page)
  } else {
    let found = pages.find(p => p.attrs.at("name", default: "") == page)
    assert(found != none, message: "drawio: no page named " + repr(page))
    found
  }
  let inner = _find(d, "mxGraphModel")
  if inner != none { return inner }
  // Compressed page: base64 → raw deflate → URL-encoded XML.
  let raw = _text-of(d).trim()
  _first-elem(xml(bytes(url-decode(inflate(base64-decode(raw))))))
}

// ───────────────────────── Cells & styles ─────────────────────────

#let _norm(el) = {
  if el.tag == "mxCell" {
    let a = el.attrs
    (
      id: a.at("id", default: none),
      value: a.at("value", default: ""),
      style: a.at("style", default: ""),
      vertex: a.at("vertex", default: "0") == "1",
      edge: a.at("edge", default: "0") == "1",
      parent: a.at("parent", default: none),
      source: a.at("source", default: none),
      target: a.at("target", default: none),
      geom: _find(el, "mxGeometry"),
    )
  } else {
    // <object>/<UserObject> wrappers carry id and label, the inner mxCell the rest
    let inner = _find(el, "mxCell")
    if inner == none { return none }
    let c = _norm(inner)
    c.id = el.attrs.at("id", default: c.id)
    c.value = el.attrs.at("label", default: c.value)
    c
  }
}

#let _style(s) = {
  let d = (:)
  let flags = ()
  for part in s.split(";") {
    let part = part.trim()
    if part == "" { continue }
    if "=" in part {
      let kv = part.split("=")
      d.insert(kv.at(0), kv.slice(1).join("="))
    } else {
      flags.push(part)
    }
  }
  (d, flags)
}

#let _num-re = regex("^-?[0-9]*\\.?[0-9]+$")
#let _f(v) = if v == none { 0.0 } else { float(v) }
#let _sf(st, key, default) = {
  let v = st.at(key, default: none)
  if v != none and v.match(_num-re) != none { float(v) } else { default }
}

#let _named = (
  white: white,
  black: black,
  red: red,
  blue: blue,
  green: green,
  yellow: yellow,
  gray: gray,
  orange: orange,
  purple: purple,
)
#let _hex-re = regex("^#([0-9a-fA-F]{3,4}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$")

#let _color(v, default) = {
  if v == none or v == "" or v == "default" or v == "inherit" { return default }
  if v == "none" { return none }
  if v.match(_hex-re) != none { return rgb(v) }
  _named.at(v.lower(), default: default)
}

#let _stroke(st, s, default-color, dashes: true) = {
  let col = _color(st.at("strokeColor", default: none), default-color)
  if col == none { return none }
  let w = _sf(st, "strokeWidth", 1.0) * s
  let dash = if dashes and st.at("dashed", default: "0") == "1" {
    let pat = st.at("dashPattern", default: none)
    if pat == none {
      "dashed"
    } else {
      pat.split(" ").filter(x => x.match(_num-re) != none).map(x => float(x) * s)
    }
  } else { none }
  stroke(paint: col, thickness: w, dash: dash)
}

#let _known = (
  "swimlane",
  "ellipse",
  "doubleEllipse",
  "cloud",
  "rhombus",
  "triangle",
  "hexagon",
  "parallelogram",
  "cylinder",
  "cylinder3",
  "text",
)

#let _kind(st, flags) = {
  let names = flags + (st.at("shape", default: ""),)
  let k = names.find(n => n in _known)
  if k == "doubleEllipse" or k == "cloud" { "ellipse" } else if k == "cylinder3" {
    "cylinder"
  } else if k == none { "rect" } else { k }
}

// Absolute rectangle (x, y, w, h) in diagram pixels; children of containers
// (swimlanes, groups) are stored relative to their parent.
#let _rect-of(by-id, c) = {
  let ga = if c.geom == none { (:) } else { c.geom.attrs }
  let x = _f(ga.at("x", default: none))
  let y = _f(ga.at("y", default: none))
  let w = _f(ga.at("width", default: none))
  let h = _f(ga.at("height", default: none))
  let p = if c.parent == none { none } else { by-id.at(c.parent, default: none) }
  if p != none and p.vertex {
    let pr = _rect-of(by-id, p)
    x += pr.at(0)
    y += pr.at(1)
  }
  (x, y, w, h)
}

#let _parent-off(by-id, c) = {
  let p = if c.parent == none { none } else { by-id.at(c.parent, default: none) }
  if p != none and p.vertex {
    let pr = _rect-of(by-id, p)
    (pr.at(0), pr.at(1))
  } else { (0.0, 0.0) }
}

// ───────────────────────── Labels ─────────────────────────

#let _label(v, html) = {
  let s = v
  if html or "<" in s {
    s = s.replace(regex("(?i)<br\\s*/?>"), "\n")
    s = s.replace(regex("(?i)</(div|p|li|h[1-6]|tr)>"), "\n")
    s = s.replace(regex("<[^>]*>"), "")
    s = s.replace("&nbsp;", "\u{a0}").replace("&lt;", "<").replace("&gt;", ">")
    s = s.replace("&quot;", "\"").replace("&amp;", "&")
    s = s.trim("\n")
  }
  s
}

#let _label-body(lbl, st, s) = {
  let fsz = _sf(st, "fontSize", 12.0) * s
  let fstyle = int(_sf(st, "fontStyle", 0.0))
  let bold = calc.rem(fstyle, 2) == 1
  let italic = calc.rem(calc.quo(fstyle, 2), 2) == 1
  let under = calc.rem(calc.quo(fstyle, 4), 2) == 1
  let fcol = _color(st.at("fontColor", default: none), black)
  let wrap = st.at("whiteSpace", default: "") == "wrap"
  let txt = if wrap { lbl } else { lbl.replace(" ", "\u{a0}") }
  let body = txt.split("\n").map(l => [#l]).join(linebreak())
  if under { body = underline(body) }
  set par(leading: 0.35em, justify: false, spacing: 0pt)
  text(
    size: fsz,
    fill: fcol,
    weight: if bold { "bold" } else { "regular" },
    style: if italic { "italic" } else { "normal" },
    body,
  )
}

#let _halign = (left: left, right: right, center: center)
#let _valign = (top: top, bottom: bottom, middle: horizon)

// ───────────────────────── Vertices ─────────────────────────

#let _vertex(c, by-id, ox, oy, s) = {
  let (st, flags) = _style(c.style)
  let kind = _kind(st, flags)
  let (x, y, w, h) = _rect-of(by-id, c)
  x = x - ox
  y = y - oy
  let sw = w * s
  let sh = h * s
  let is-text = kind == "text"

  let fill = _color(st.at("fillColor", default: none), if is-text { none } else { white })
  let grad = _color(st.at("gradientColor", default: none), none)
  if fill != none and grad != none {
    let dir = st.at("gradientDirection", default: "south")
    let ang = (south: 90deg, north: 270deg, east: 0deg, west: 180deg).at(dir, default: 90deg)
    fill = gradient.linear(fill, grad, angle: ang)
  }
  let sk = _stroke(st, s, if is-text { none } else { black })

  let lbl = _label(c.value, st.at("html", default: "0") == "1")
  let ha = _halign.at(st.at("align", default: "center"), default: center)
  let va = _valign.at(st.at("verticalAlign", default: "middle"), default: horizon)
  let pad = (4.0 + _sf(st, "spacing", 2.0)) * s
  let lbl-pos = st.at("labelPosition", default: "center")
  let vlbl-pos = st.at("verticalLabelPosition", default: "middle")

  // label area (inside the shape unless moved outside); swimlanes label the header
  let ss = _sf(st, "startSize", 23.0) * s
  let horiz = st.at("horizontal", default: "1") != "0"

  let body = if kind == "ellipse" {
    ellipse(width: sw, height: sh, fill: fill, stroke: sk)
  } else if kind == "rhombus" {
    polygon(fill: fill, stroke: sk, (sw / 2, 0pt), (sw, sh / 2), (sw / 2, sh), (0pt, sh / 2))
  } else if kind == "triangle" {
    polygon(fill: fill, stroke: sk, (0pt, 0pt), (sw, sh / 2), (0pt, sh))
  } else if kind == "hexagon" {
    let k = _sf(st, "size", 0.25) * sw
    polygon(fill: fill, stroke: sk, (k, 0pt), (sw - k, 0pt), (sw, sh / 2), (sw - k, sh), (k, sh), (0pt, sh / 2))
  } else if kind == "parallelogram" {
    let k = _sf(st, "size", 0.25) * sw
    polygon(fill: fill, stroke: sk, (k, 0pt), (sw, 0pt), (sw - k, sh), (0pt, sh))
  } else if kind == "cylinder" {
    let eh = calc.min(_sf(st, "size", 15.0) * s * 1.3, sh / 3)
    box(width: sw, height: sh, {
      place(top + left, dy: sh - eh, ellipse(width: sw, height: eh, fill: fill, stroke: sk))
      place(top + left, dy: eh / 2, rect(width: sw, height: sh - eh, fill: fill, stroke: none))
      place(top + left, dy: eh / 2, line(length: sh - eh, angle: 90deg, stroke: sk))
      place(top + left, dx: sw, dy: eh / 2, line(length: sh - eh, angle: 90deg, stroke: sk))
      place(top + left, ellipse(width: sw, height: eh, fill: fill, stroke: sk))
    })
  } else if kind == "swimlane" {
    let body-fill = _color(st.at("swimlaneFillColor", default: none), none)
    box(width: sw, height: sh, {
      place(top + left, rect(width: sw, height: sh, fill: body-fill, stroke: sk))
      if horiz {
        place(top + left, rect(width: sw, height: ss, fill: fill, stroke: sk))
      } else {
        place(top + left, rect(width: ss, height: sh, fill: fill, stroke: sk))
      }
    })
  } else if kind == "text" {
    none
  } else {
    let r = if st.at("rounded", default: "0") == "1" {
      let arc = _sf(st, "arcSize", 15.0)
      if st.at("absoluteArcSize", default: "0") == "1" { arc * s } else {
        calc.min(sw, sh) * (arc / 100)
      }
    } else { 0pt }
    rect(width: sw, height: sh, fill: fill, stroke: sk, radius: r)
  }

  let label-item = if lbl == "" { none } else if kind == "swimlane" {
    if horiz {
      place(top + left, box(width: sw, height: ss, inset: pad, align(ha + va, _label-body(lbl, st, s))))
    } else {
      place(top + left, rotate(-90deg, reflow: true, box(width: sh, height: ss, inset: pad, align(ha + va, _label-body(lbl, st, s)))))
    }
  } else if vlbl-pos == "bottom" {
    place(top + left, dy: sh, box(width: sw, inset: pad, align(ha + top, _label-body(lbl, st, s))))
  } else if vlbl-pos == "top" {
    place(bottom + left, dy: -sh, box(width: sw, inset: pad, align(ha + bottom, _label-body(lbl, st, s))))
  } else if lbl-pos == "right" {
    place(top + left, dx: sw, box(height: sh, inset: pad, align(left + va, _label-body(lbl, st, s))))
  } else if lbl-pos == "left" {
    place(top + right, dx: -sw, box(height: sh, inset: pad, align(right + va, _label-body(lbl, st, s))))
  } else {
    place(top + left, box(width: sw, height: sh, inset: pad, align(ha + va, _label-body(lbl, st, s))))
  }

  let piece = box(width: sw, height: sh, {
    if body != none { place(top + left, body) }
    if label-item != none { label-item }
  })
  let rot = _sf(st, "rotation", 0.0)
  if rot != 0.0 { piece = rotate(rot * 1deg, origin: center + horizon, piece) }
  place(top + left, dx: x * s, dy: y * s, piece)
}

// ───────────────────────── Edges ─────────────────────────

// Point where the ray from the shape's centre towards `aim` leaves the shape.
#let _clip(r, kind, aim) = {
  let (x, y, w, h) = r
  let cx = x + w / 2
  let cy = y + h / 2
  let dx = aim.at(0) - cx
  let dy = aim.at(1) - cy
  if (dx == 0 and dy == 0) or w == 0 or h == 0 { return (cx, cy) }
  let a = calc.abs(dx) / (w / 2)
  let b = calc.abs(dy) / (h / 2)
  let t = if kind == "ellipse" {
    1 / calc.sqrt(a * a + b * b)
  } else if kind == "rhombus" {
    1 / (a + b)
  } else {
    1 / calc.max(a, b)
  }
  (cx + t * dx, cy + t * dy)
}

#let _edge-points(c, by-id) = {
  let (st, flags) = _style(c.style)
  let (px, py) = _parent-off(by-id, c)
  let waypoints = ()
  let sp = none
  let tp = none
  if c.geom != none {
    let arr = _find(c.geom, "Array")
    if arr != none {
      for p in _all(arr, "mxPoint") {
        waypoints.push((_f(p.attrs.at("x", default: none)) + px, _f(p.attrs.at("y", default: none)) + py))
      }
    }
    for p in _all(c.geom, "mxPoint") {
      let pt = (_f(p.attrs.at("x", default: none)) + px, _f(p.attrs.at("y", default: none)) + py)
      let role = p.attrs.at("as", default: "")
      if role == "sourcePoint" { sp = pt } else if role == "targetPoint" { tp = pt }
    }
  }
  let src = if c.source != none { by-id.at(c.source, default: none) } else { none }
  let tgt = if c.target != none { by-id.at(c.target, default: none) } else { none }
  let srect = if src != none { _rect-of(by-id, src) } else { none }
  let trect = if tgt != none { _rect-of(by-id, tgt) } else { none }
  let skind = if src != none { let (a, b) = _style(src.style); _kind(a, b) } else { "rect" }
  let tkind = if tgt != none { let (a, b) = _style(tgt.style); _kind(a, b) } else { "rect" }

  let ctr(r) = (r.at(0) + r.at(2) / 2, r.at(1) + r.at(3) / 2)
  let s-center = if srect != none { ctr(srect) } else if sp != none { sp } else if waypoints.len() > 0 { waypoints.first() } else { (0.0, 0.0) }
  let t-center = if trect != none { ctr(trect) } else if tp != none { tp } else if waypoints.len() > 0 { waypoints.last() } else { (0.0, 0.0) }
  let s-aim = if waypoints.len() > 0 { waypoints.first() } else { t-center }
  let t-aim = if waypoints.len() > 0 { waypoints.last() } else { s-center }

  let has-exit = srect != none and st.at("exitX", default: none) != none and st.at("exitY", default: none) != none
  let has-entry = trect != none and st.at("entryX", default: none) != none and st.at("entryY", default: none) != none
  let exit-pt = if has-exit {
    (srect.at(0) + _sf(st, "exitX", 0.5) * srect.at(2), srect.at(1) + _sf(st, "exitY", 0.5) * srect.at(3))
  } else { none }
  let entry-pt = if has-entry {
    (trect.at(0) + _sf(st, "entryX", 0.5) * trect.at(2), trect.at(1) + _sf(st, "entryY", 0.5) * trect.at(3))
  } else { none }

  let ortho = st.at("edgeStyle", default: "") in ("orthogonalEdgeStyle", "elbowEdgeStyle", "entityRelationEdgeStyle")

  if ortho and waypoints.len() == 0 {
    let dx = t-center.at(0) - s-center.at(0)
    let dy = t-center.at(1) - s-center.at(1)
    let s-h = if has-exit { let ex = _sf(st, "exitX", 0.5); ex == 0.0 or ex == 1.0 } else { calc.abs(dx) >= calc.abs(dy) }
    let t-h = if has-entry { let ex = _sf(st, "entryX", 0.5); ex == 0.0 or ex == 1.0 } else { calc.abs(dx) >= calc.abs(dy) }
    let a = if exit-pt != none { exit-pt } else if srect != none {
      if s-h { (if dx >= 0 { srect.at(0) + srect.at(2) } else { srect.at(0) }, s-center.at(1)) } else {
        (s-center.at(0), if dy >= 0 { srect.at(1) + srect.at(3) } else { srect.at(1) })
      }
    } else { s-center }
    let b = if entry-pt != none { entry-pt } else if trect != none {
      if t-h { (if dx >= 0 { trect.at(0) } else { trect.at(0) + trect.at(2) }, t-center.at(1)) } else {
        (t-center.at(0), if dy >= 0 { trect.at(1) } else { trect.at(1) + trect.at(3) })
      }
    } else { t-center }
    if s-h and t-h {
      let mx = (a.at(0) + b.at(0)) / 2
      (a, (mx, a.at(1)), (mx, b.at(1)), b)
    } else if not s-h and not t-h {
      let my = (a.at(1) + b.at(1)) / 2
      (a, (a.at(0), my), (b.at(0), my), b)
    } else if s-h {
      (a, (b.at(0), a.at(1)), b)
    } else {
      (a, (a.at(0), b.at(1)), b)
    }
  } else {
    let a = if exit-pt != none { exit-pt } else if srect != none { _clip(srect, skind, s-aim) } else { s-center }
    let b = if entry-pt != none { entry-pt } else if trect != none { _clip(trect, tkind, t-aim) } else { t-center }
    (a,) + waypoints + (b,)
  }
}

#let _point-at(pts, t) = {
  let lens = ()
  let total = 0.0
  for i in range(pts.len() - 1) {
    let a = pts.at(i)
    let b = pts.at(i + 1)
    let l = calc.sqrt(calc.pow(b.at(0) - a.at(0), 2) + calc.pow(b.at(1) - a.at(1), 2))
    lens.push(l)
    total += l
  }
  if total == 0 { return pts.first() }
  let target = total * t
  let acc = 0.0
  for (i, l) in lens.enumerate() {
    if acc + l >= target {
      let f = if l == 0 { 0 } else { (target - acc) / l }
      let a = pts.at(i)
      let b = pts.at(i + 1)
      return (a.at(0) + (b.at(0) - a.at(0)) * f, a.at(1) + (b.at(1) - a.at(1)) * f)
    }
    acc += l
  }
  pts.last()
}

// Unit vector pointing from the last distinct earlier point to the tip.
#let _dir(pts, at-end) = {
  let n = pts.len()
  let tip = if at-end { pts.at(n - 1) } else { pts.at(0) }
  for k in range(1, n) {
    let q = if at-end { pts.at(n - 1 - k) } else { pts.at(k) }
    let dx = tip.at(0) - q.at(0)
    let dy = tip.at(1) - q.at(1)
    let l = calc.sqrt(dx * dx + dy * dy)
    if l > 0.01 { return (dx / l, dy / l) }
  }
  (1.0, 0.0)
}

#let _arrow-size(st, which) = {
  let sz = _sf(st, which + "Size", 6.0)
  sz * 1.6 + 2
}

// Draws an arrowhead at `tip` pointing along unit vector `u` (all in diagram px).
#let _arrowhead(kind, tip, u, len, st, which, s, ox, oy) = {
  if kind == "none" or kind == none { return none }
  let col = _color(st.at("strokeColor", default: none), black)
  if col == none { return none }
  let sw = _sf(st, "strokeWidth", 1.0) * s
  let sk = stroke(paint: col, thickness: sw, join: "miter")
  let filled = st.at(which + "Fill", default: "1") != "0"
  let fl = if filled { col } else { white }
  let n = (-u.at(1), u.at(0))
  let hw = len * 0.35
  let at(k, m) = (
    (tip.at(0) - k * u.at(0) + m * n.at(0) - ox) * s,
    (tip.at(1) - k * u.at(1) + m * n.at(1) - oy) * s,
  )
  if kind == "classic" or kind == "classicThin" {
    place(top + left, polygon(fill: fl, stroke: sk, at(0, 0), at(len, hw), at(len * 0.75, 0), at(len, -hw)))
  } else if kind == "open" or kind == "openThin" {
    place(top + left, curve(stroke: sk, curve.move(at(len, hw)), curve.line(at(0, 0)), curve.line(at(len, -hw))))
  } else if kind == "oval" {
    let c = at(len / 2, 0)
    place(top + left, dx: c.at(0) - len * s / 2, dy: c.at(1) - len * s / 2, ellipse(width: len * s, height: len * s, fill: fl, stroke: sk))
  } else if kind == "diamond" or kind == "diamondThin" {
    place(top + left, polygon(fill: fl, stroke: sk, at(0, 0), at(len / 2, hw), at(len, 0), at(len / 2, -hw)))
  } else {
    // block (and anything unknown)
    place(top + left, polygon(fill: fl, stroke: sk, at(0, 0), at(len, hw), at(len, -hw)))
  }
}

// Returns an array of content items for one edge (line + arrowheads).
#let _edge-items(c, pts, ox, oy, s) = {
  let (st, flags) = _style(c.style)
  let sk = _stroke(st, s, black)
  let items = ()
  let end-kind = st.at("endArrow", default: "classic")
  let start-kind = st.at("startArrow", default: "none")
  let e-len = _arrow-size(st, "end")
  let s-len = _arrow-size(st, "start")
  let filled-kinds = ("classic", "classicThin", "block", "blockThin", "oval", "diamond", "diamondThin")
  let line-pts = pts
  let n = line-pts.len()
  if n >= 2 {
    let ue = _dir(pts, true)
    let us = _dir(pts, false)
    // pull the line back so it does not poke through filled arrowheads
    if end-kind in filled-kinds and st.at("endFill", default: "1") != "0" {
      let t = line-pts.at(n - 1)
      line-pts.at(n - 1) = (t.at(0) - ue.at(0) * e-len * 0.7, t.at(1) - ue.at(1) * e-len * 0.7)
    }
    if start-kind in filled-kinds and st.at("startFill", default: "1") != "0" {
      let t = line-pts.at(0)
      line-pts.at(0) = (t.at(0) - us.at(0) * s-len * 0.7, t.at(1) - us.at(1) * s-len * 0.7)
    }
    let tp(p) = ((p.at(0) - ox) * s, (p.at(1) - oy) * s)
    let segs = (curve.move(tp(line-pts.first())),)
    for p in line-pts.slice(1) { segs.push(curve.line(tp(p))) }
    items.push(place(top + left, curve(stroke: sk, ..segs)))
    items.push(_arrowhead(end-kind, pts.at(n - 1), ue, e-len, st, "end", s, ox, oy))
    items.push(_arrowhead(start-kind, pts.at(0), (-us.at(0), -us.at(1)), s-len, st, "start", s, ox, oy))
  }
  items
}

// Text centred on a diagram point (diagram px) — measured so it can be centred.
#let _label-at(body, cx, cy, s, bg) = context {
  let b = box(fill: bg, inset: 1.5pt, body)
  let m = measure(b)
  place(top + left, dx: cx * s - m.width / 2, dy: cy * s - m.height / 2, b)
}

// ───────────────────────── Public API ─────────────────────────

/// Renders a draw.io diagram.
///
/// - data (bytes, str): file contents, e.g. `read("fig.drawio", encoding: none)`.
///   Both plain and compressed `.drawio` / `.xml` files are supported.
/// - page (int, str): page index (0-based) or page name.
/// - scale (float): multiplier on the natural size (1 draw.io px = 0.75pt).
/// - width (auto, length, ratio): fit the diagram to this width instead of using `scale`.
/// - padding (int, float): empty margin around the diagram, in draw.io px.
#let drawio(data, page: 0, scale: 1.0, width: auto, padding: 10) = {
  let model = _model(data, page)
  let root = _find(model, "root")
  assert(root != none, message: "drawio: diagram has no <root>")

  let cells = ()
  for el in _elems(root) {
    let c = _norm(el)
    if c != none { cells.push(c) }
  }
  let by-id = (:)
  for c in cells { if c.id != none { by-id.insert(c.id, c) } }

  let is-edge-label(c) = {
    c.vertex and c.parent != none and by-id.at(c.parent, default: (edge: false)).edge
  }

  // first pass: geometry of every drawable + bounds
  let xs = ()
  let ys = ()
  let edge-pts = (:)
  for c in cells {
    if c.edge {
      let pts = _edge-points(c, by-id)
      edge-pts.insert(c.id, pts)
      for p in pts {
        xs.push(p.at(0))
        ys.push(p.at(1))
      }
    } else if c.vertex and not is-edge-label(c) {
      let (x, y, w, h) = _rect-of(by-id, c)
      xs += (x, x + w)
      ys += (y, y + h)
    }
  }
  if xs.len() == 0 { return box() }
  let minx = calc.min(..xs) - padding
  let miny = calc.min(..ys) - padding
  let total-w = calc.max(..xs) + padding - minx
  let total-h = calc.max(..ys) + padding - miny

  let render(s) = {
    let items = ()
    for c in cells {
      if c.edge {
        let pts = edge-pts.at(c.id)
        items += _edge-items(c, pts, minx, miny, s)
        let (st, _) = _style(c.style)
        let lbl = _label(c.value, st.at("html", default: "0") == "1")
        if lbl != "" and pts.len() >= 2 {
          let mid = _point-at(pts, 0.5)
          let bg = _color(st.at("labelBackgroundColor", default: none), white)
          items.push(_label-at(_label-body(lbl, st, s), mid.at(0) - minx, mid.at(1) - miny, s, bg))
        }
      } else if c.vertex and not is-edge-label(c) {
        items.push(_vertex(c, by-id, minx, miny, s))
      }
    }
    // labels that are separate child cells of an edge
    for c in cells {
      if is-edge-label(c) {
        let pts = edge-pts.at(c.parent, default: none)
        if pts == none or pts.len() < 2 { continue }
        let (st, _) = _style(c.style)
        let lbl = _label(c.value, true)
        if lbl == "" { continue }
        let gx = if c.geom != none { _f(c.geom.attrs.at("x", default: none)) } else { 0.0 }
        let gy = if c.geom != none { _f(c.geom.attrs.at("y", default: none)) } else { 0.0 }
        let off = (0.0, 0.0)
        if c.geom != none {
          let o = _all(c.geom, "mxPoint").find(p => p.attrs.at("as", default: "") == "offset")
          if o != none { off = (_f(o.attrs.at("x", default: none)), _f(o.attrs.at("y", default: none))) }
        }
        let at = _point-at(pts, calc.max(0.0, calc.min(1.0, (gx + 1) / 2)))
        let bg = _color(st.at("labelBackgroundColor", default: none), white)
        items.push(_label-at(_label-body(lbl, st, s), at.at(0) + off.at(0) - minx, at.at(1) + off.at(1) + gy - miny, s, bg))
      }
    }
    box(width: total-w * s, height: total-h * s, items.join())
  }

  if width == auto {
    render(0.75pt * scale)
  } else {
    layout(size => {
      let target = if type(width) == ratio { size.width * (width / 100%) } else { width }
      render(target / total-w)
    })
  }
}

/// Returns the names of all pages in a draw.io file.
#let drawio-pages(data) = {
  let src = if type(data) == str { bytes(data) } else { data }
  let rootel = _first-elem(xml(src))
  if rootel.tag == "mxfile" {
    _all(rootel, "diagram").map(d => d.attrs.at("name", default: ""))
  } else { ("",) }
}
