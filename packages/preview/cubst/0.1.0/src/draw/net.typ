// Net renderer: the faces unfolded flat. The puzzle only says which face is
// attached to which (a tree per connected part of the net); the unfolding
// itself is generic: a child is placed so that its edge shared with the
// parent coincides with the parent's.

#import "../geom.typ" as g
#import "../state.typ": assert-puzzle
#import "../puzzles/registry.typ" as registry
#import "common.typ": default-palette, fill-of, abs-pt, shape, name-label

/// Draw the net of a puzzle. `spacing` is the distance between faces (`auto`
/// = a quarter unit). `labels: true` writes each sticker's index on it,
/// `"faces"` the name of each face at its centre.
#let draw-net(
  c,
  sticker: 6mm,
  gap: 0pt,
  spacing: auto,
  stroke: 0.5pt + black,
  radius: 0pt,
  palette: default-palette,
  hidden: auto,
  body: none,
  labels: false,
) = {
  assert-puzzle(c, who: "draw-net")
  let model = registry.model(c)
  let net = (registry.of(c).net)(c.params)
  let s = abs-pt(sticker, "sticker")
  let gp = abs-pt(gap, "gap") / s
  let sp = if spacing == auto { 0.25 } else { abs-pt(spacing, "spacing") / s }

  // face-local 2D geometry
  let local = (:)
  for (name, f) in model.faces {
    local.insert(name, (
      verts: f.verts.map(p => g.to-local(f.frame, p)),
      keys: f.verts.map(g.key),
      stickers: model.stickers.filter(st => st.face == name).map(st => (
        poly: st.poly.map(p => g.to-local(f.frame, p)),
        name: c.faces.at(name).at(st.index),
        index: st.index,
      )),
    ))
  }

  // placement of each face: rotate by `angle`, then translate by `t` + `off`
  let placed = (:)
  let tree = (:)
  for r in net.roots {
    placed.insert(r, (angle: 0deg, t: (0, 0), off: (0, 0)))
    tree.insert(r, r)
  }
  // (closures capture by value, so the table is passed in explicitly)
  let transform(placed, name, q) = {
    let pl = placed.at(name)
    g.add2(g.add2(g.rot2(q, pl.angle), pl.t), pl.off)
  }
  let vertex(name, k) = local.at(name).verts.at(local.at(name).keys.position(x => x == k))
  for (parent, child) in net.edges {
    assert(parent in placed, message: "cubst: net edge (" + parent + ", " + child + ") lists the child before its parent")
    let shared = local.at(parent).keys.filter(k => k in local.at(child).keys)
    assert(shared.len() == 2, message: "cubst: faces " + parent + " and " + child + " do not share an edge")
    let pa = transform(placed, parent, vertex(parent, shared.at(0)))
    let pb = transform(placed, parent, vertex(parent, shared.at(1)))
    let ca = vertex(child, shared.at(0))
    let cb = vertex(child, shared.at(1))
    let ang(v) = calc.atan2(v.at(0), v.at(1))
    let angle = ang(g.sub2(pb, pa)) - ang(g.sub2(cb, ca))
    let t = g.sub2(pa, g.rot2(ca, angle))
    // push the child away from the parent by `spacing`, on top of the parent's own push
    let pc = g.sub2(transform(placed, parent, g.centroid2(local.at(parent).verts)), placed.at(parent).off)
    let cc = g.add2(g.rot2(g.centroid2(local.at(child).verts), angle), t)
    let dir = g.unit2(g.sub2(cc, pc))
    placed.insert(child, (angle: angle, t: t, off: g.add2(placed.at(parent).off, g.scale2(dir, sp))))
    tree.insert(child, tree.at(parent))
  }

  // lay the connected parts side by side
  let parts = net.roots.map(r => placed.keys().filter(f => tree.at(f) == r))
  let shift = (:)
  let x = 0
  for (i, part) in parts.enumerate() {
    let pts = part.map(f => local.at(f).verts.map(q => transform(placed, f, q))).flatten().chunks(2)
    let (min, max) = g.bbox(pts)
    for f in part { shift.insert(f, (x - min.at(0), 0)) }
    x += max.at(0) - min.at(0) + 1 + sp
  }
  let world(f, q) = g.add2(transform(placed, f, q), shift.at(f))

  let outlines = placed.keys().map(f => (poly: local.at(f).verts.map(q => world(f, q))))
  let shapes = placed.keys().map(f => local.at(f).stickers.map(st => (
    poly: g.inset(st.poly.map(q => world(f, q)), gp),
    name: st.name,
    index: st.index,
  ))).flatten()
  let (min, max) = g.bbox(outlines.map(o => o.poly).flatten().chunks(2))
  let to-pt(p) = ((p.at(0) - min.at(0)) * s, (p.at(1) - min.at(1)) * s)

  box(width: (max.at(0) - min.at(0)) * s * 1pt, height: (max.at(1) - min.at(1)) * s * 1pt, {
    if body != none {
      for o in outlines { shape(o.poly.map(to-pt), body, none, 0pt) }
    }
    for sh in shapes { shape(sh.poly.map(to-pt), fill-of(sh.name, palette, hidden), stroke, radius) }
    // content centred on a point (in pt), in a box wide enough for "DBR"
    let label(p, body) = place(
      top + left,
      dx: (p.at(0) - 1.5 * s) * 1pt,
      dy: (p.at(1) - 0.5 * s) * 1pt,
      box(width: 3 * s * 1pt, height: s * 1pt, align(std.center + horizon, body)),
    )
    if labels == "faces" {
      for f in placed.keys() { label(to-pt(world(f, g.centroid2(local.at(f).verts))), name-label(f, s)) }
    } else if labels == true {
      for sh in shapes { label(to-pt(g.centroid2(sh.poly)), text(size: 0.38 * s * 1pt, str(sh.index))) }
    }
  })
}
