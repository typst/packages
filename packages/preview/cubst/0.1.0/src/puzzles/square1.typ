// Square-1.
//
// Three layers: the top and bottom each have 12 slots of 30° holding
// corners (two slots each) and edges (one slot); the equator is two pieces.
// The slice plane is fixed in space. It meets the front and back faces 15°
// off centre, with the smaller front part on the left (the WCA holding
// position). Slots are numbered clockwise as seen from above, starting at
// the slice at the back, so slots 0–5 are the right half in both layers.
//
// Unlike the other puzzles the geometry depends on the state: a corner
// turned by 30° does not land on another sticker's outline. So this puzzle
// keeps a `layout` in the state (which piece sits in which slot, whether the
// equator is flipped) and rebuilds the sticker polygons and the colour arrays
// from it after every move, through the `solved`, `model-of`, `apply` and
// `is-solved` hooks that the engine offers for exactly this case.
//
// Notation (WCA): (x, y) turns the top layer x·30° clockwise as seen from
// above and the bottom layer y·30° clockwise as seen from below; / turns the
// right half 180°, which is only possible when no corner straddles the slice.
// There are no groups, commutators or rotations.
//
// The model gives every sticker its own normal and piece id. The 3D renderer
// can draw it (it culls and depth-sorts per sticker), but the `full` view is
// not offered: a shape-shifted Square-1 is hard to read in 3D.

#import "../geom.typ" as g

#let S = 1.5                        // half-width: the puzzle is 3 units wide
#let M = 0.3                        // half-thickness of the equator
#let A0 = 75deg                     // direction of the slice at the back (seen from above, from +x)
#let T = calc.tan(15deg)            // the slice meets the front and back sides at x = ±T·S
#let R1 = S / calc.cos(15deg)       // distance to the points where a piece boundary meets a side
#let R2 = S * calc.sqrt(2)          // distance to a corner of the square
#let N = (calc.cos(A0 - 90deg), calc.sin(A0 - 90deg))   // normal of the slice plane, pointing right

// the public faces; the side stickers live in a third array, `E`, which is an
// implementation detail (it is not flat, and nobody reads sides by index)
#let face-names = ("U", "D")
#let scheme-faces = ("U", "D", "F", "B", "R", "L")
#let default-scheme = (U: "yellow", D: "white", F: "red", B: "orange", R: "green", L: "blue")

// top view: x to the right, y towards the back; `lift` puts it at height h
#let polar(r, a) = (r * calc.cos(a), r * calc.sin(a))
#let lift(q, h) = (q.at(0), h, -q.at(1))
#let reflect(q) = g.sub2(g.scale2(N, 2 * g.dot2(q, N)), q)

/// The solved layout: corner, edge, corner, .. from the slice at the back in
/// both layers, the equator unflipped. A piece is `(kind, cap, sides)`, its
/// side colours listed in slot order.
#let solved-layout(scheme) = {
  let order = (("B", "R"), ("R",), ("R", "F"), ("F",), ("F", "L"), ("L",), ("L", "B"), ("B",))
  let layer(cap) = order.map(s => (
    kind: if s.len() == 2 { "corner" } else { "edge" },
    cap: scheme.at(cap),
    sides: s.map(f => scheme.at(f)),
  ))
  let slots = (0, 0, 1, 2, 2, 3, 4, 4, 5, 6, 6, 7)
  (
    pieces: layer("U") + layer("D"),
    top: slots,
    bottom: slots.map(i => i + 8),
    flipped: false,
    mid: (
      mL: (F: scheme.F, B: scheme.B, L: scheme.L),
      mR: (F: scheme.F, R: scheme.R, B: scheme.B),
    ),
  )
}

// unit normal of a polygon, pointing away from `ref`
#let outward(poly, ref) = {
  let n = g.unit(g.cross(g.sub(poly.at(1), poly.at(0)), g.sub(poly.at(2), poly.at(0))))
  if g.dot(n, g.sub(g.centroid(poly), ref)) < 0 { g.scale(n, -1) } else { n }
}

// the stickers of one layer: the cap and the side stickers of every piece, in
// slot order; also the layer's outline for the body
#let layer-items(name, slots, h, hin, layout) = {
  let items = ()
  let outs = ()
  for k in range(12) {
    let id = slots.at(k)
    if slots.at(calc.rem(k + 11, 12)) == id { continue }   // not the piece's first slot
    let piece = layout.pieces.at(id)
    let w = if piece.kind == "corner" { 2 } else { 1 }
    let phi = A0 - 30deg * k - 15deg * w
    let outer = if w == 2 {
      (polar(R1, phi + 30deg), polar(R2, phi), polar(R1, phi - 30deg))
    } else {
      (polar(R1, phi + 15deg), polar(R1, phi - 15deg))
    }
    outs += outer
    let cap = ((0, 0), ..outer)
    let ref = lift(g.centroid2(cap), (h + hin) / 2)
    items.push((face: name, poly: cap.map(q => lift(q, h)), color: piece.cap, piece: str(id), ref: ref, at: (id, "cap")))
    for i in range(outer.len() - 1) {
      let (p, q) = (outer.at(i), outer.at(i + 1))
      items.push((
        face: "E",
        poly: (lift(p, h), lift(q, h), lift(q, hin), lift(p, hin)),
        color: piece.sides.at(i),
        piece: str(id),
        ref: ref,
        at: (id, i),
      ))
    }
  }
  (items: items, outline: outs.map(q => lift(q, h)))
}

// the six stickers of the equator; the right piece is mirrored when flipped
#let equator-items(layout) = {
  let left = ((-S, -S), (-T * S, -S), (T * S, S), (-S, S))
  let right = ((-T * S, -S), (S, -S), (S, S), (T * S, S))
  if layout.flipped { right = right.map(reflect) }
  let items = ()
  for (id, verts, segs) in (("mL", left, ((0, "F"), (2, "B"), (3, "L"))), ("mR", right, ((0, "F"), (1, "R"), (2, "B")))) {
    let ref = lift(g.centroid2(verts), 0)
    for (i, f) in segs {
      let (p, q) = (verts.at(i), verts.at(calc.rem(i + 1, 4)))
      items.push((
        face: "E",
        poly: (lift(p, M), lift(q, M), lift(q, -M), lift(p, -M)),
        color: layout.mid.at(id).at(f),
        piece: id,
        ref: ref,
        at: (id, f),
        band: true,
      ))
    }
  }
  items
}

/// Model, colour arrays and, for every sticker, where its colour lives in the
/// layout. Sticker order: U caps in slot order; E = top layer sides, equator
/// (left piece F B L, right piece F R B), bottom layer sides; D caps.
#let build(layout, scheme) = {
  let top = layer-items("U", layout.top, S, M, layout)
  let bottom = layer-items("D", layout.bottom, -S, -M, layout)
  let items = top.items + equator-items(layout) + bottom.items
  let stickers = ()
  let colors = (U: (), D: (), E: ())
  let refs = ()
  for it in items {
    let i = colors.at(it.face).len()
    let st = (face: it.face, index: i, poly: it.poly, normal: outward(it.poly, it.ref), piece: it.piece)
    if "band" in it { st.band = true }
    stickers.push(st)
    colors.at(it.face).push(it.color)
    refs.push(it.at)
  }
  (
    model: (
      faces: (
        U: (normal: (0, 1, 0), frame: g.frame((0, S, 0), (0, 1, 0), (0, 0, -1)), verts: top.outline),
        D: (normal: (0, -1, 0), frame: g.frame((0, -S, 0), (0, -1, 0), (0, 0, 1)), verts: bottom.outline),
      ),
      stickers: stickers,
      regions: (),
    ),
    faces: colors,
    refs: refs,
  )
}

// copy the colours of `c.faces` (which masks may have set to `none`) back
// into the layout, so that they survive the next move
#let sync(layout, c) = {
  let b = build(layout, c.scheme)
  let out = layout
  for (st, at) in b.model.stickers.zip(b.refs) {
    let color = c.faces.at(st.face).at(st.index)
    let (id, where) = at
    if id in ("mL", "mR") { out.mid.at(id).at(where) = color } else if where == "cap" {
      out.pieces.at(id).cap = color
    } else { out.pieces.at(id).sides.at(where) = color }
  }
  out
}

// --- notation -------------------------------------------------------------------

#let wrap(v) = calc.rem-euclid(v + 5, 12) - 5
// `str(-1)` gives a typographic minus; notation uses the ASCII hyphen
#let int-str(v) = if v < 0 { "-" + str(-v) } else { str(v) }

#let format(m) = if m.base == "/" { "/" } else {
  "(" + int-str(wrap(m.x * m.amount)) + "," + int-str(wrap(m.y * m.amount)) + ")"
}

#let parse(alg, params) = {
  assert(type(alg) == str, message: "cubst: algorithm must be a string, got " + repr(alg))
  let rest = alg
  let moves = ()
  while true {
    rest = rest.trim(regex("\s+"), at: start)
    if rest == "" { break }
    if rest.starts-with("/") {
      moves.push((base: "/", amount: 1, puzzle: "square1"))
      rest = rest.slice(1)
      continue
    }
    // a typographic minus (as `str()` prints it) is accepted too
    let m = rest.match(regex("^\(\s*([-−]?\d+)\s*,\s*([-−]?\d+)\s*\)"))
    assert(
      m != none,
      message: "cubst: cannot read " + repr(rest) + " in algorithm " + repr(alg) + "; Square-1 moves are (x, y) and /",
    )
    let num(s) = int(s.replace("−", "-"))
    moves.push((base: "layers", x: num(m.captures.at(0)), y: num(m.captures.at(1)), amount: 1, puzzle: "square1"))
    rest = rest.slice(m.end)
  }
  moves
}

// --- moves ----------------------------------------------------------------------

#let apply(c, moves) = {
  let layout = sync(c.layout, c)
  let done = ()
  for m in moves {
    if m.base == "/" {
      for (name, slots) in (("top", layout.top), ("bottom", layout.bottom)) {
        assert(
          slots.at(0) != slots.at(11) and slots.at(5) != slots.at(6),
          message: "cubst: '/' is blocked" + (if done.len() > 0 { " after " + done.map(format).join(" ") } else { "" }) + ": a corner of the " + name + " layer straddles the slice",
        )
      }
      // the right halves swap and reverse; the pieces in them turn over
      let top = layout.top
      let bottom = layout.bottom
      for k in range(6) {
        top.at(k) = layout.bottom.at(5 - k)
        bottom.at(k) = layout.top.at(5 - k)
      }
      for id in (layout.top.slice(0, 6) + layout.bottom.slice(0, 6)).dedup() {
        layout.pieces.at(id).sides = layout.pieces.at(id).sides.rev()
      }
      layout.top = top
      layout.bottom = bottom
      layout.flipped = not layout.flipped
    } else {
      let (x, y) = (m.x * m.amount, m.y * m.amount)
      layout.top = range(12).map(k => layout.top.at(calc.rem-euclid(k - x, 12)))
      layout.bottom = range(12).map(k => layout.bottom.at(calc.rem-euclid(k + y, 12)))
    }
    done.push(m)
  }
  (..c, layout: layout, faces: build(layout, c.scheme).faces)
}

/// Solved up to turning the layers: cube shape, every piece in place and the
/// right way up, the equator not flipped.
#let is-solved(c) = {
  let layout = sync(c.layout, c)
  if layout.flipped { return false }
  let sol = solved-layout(c.scheme)
  let seq(l, slots) = slots.map(id => l.pieces.at(id)).map(p => (p.kind, p.cap, p.sides))
  for (slots, ref) in ((layout.top, sol.top), (layout.bottom, sol.bottom)) {
    let s = seq(layout, slots)
    let r = seq(sol, ref)
    if not range(12).any(k => range(12).all(i => s.at(i) == r.at(calc.rem(i + k, 12)))) { return false }
  }
  true
}

#let puzzle = (
  name: "square1",
  event: name => if name in ("square1", "square-1", "squan") { (:) } else { none },
  event-name: params => "square1",
  faces: params => face-names,
  scheme-faces: params => scheme-faces,
  default-scheme: params => default-scheme,
  model: params => build(solved-layout(default-scheme), default-scheme).model,
  solved: (params, scheme) => {
    let layout = solved-layout(scheme)
    (faces: build(layout, scheme).faces, layout: layout)
  },
  model-of: c => build(c.layout, c.scheme).model,
  apply: apply,
  is-solved: is-solved,
  parse: parse,
  format: format,
  views: ("face", "layers", "obl", "cs", "net"),
  default-view: "layers",
  fixed-face: true,   // `draw(face:, top:)` are errors: `face` shows U, `layers` both
  draw-options: (slices: auto, direction: "horizontal", turn: false),
  layers: ("U", "D"),
  strips: "radial",
  slices: params => ((N.at(0), 0, -N.at(1)),),   // the slice plane's normal, in 3D
  cameras: params => (full: none, tips: (:)),
  net: params => none,
)
