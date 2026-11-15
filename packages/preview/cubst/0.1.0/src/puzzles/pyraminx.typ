// Pyraminx.
//
// A regular tetrahedron of edge 3 standing on its D face, with the U vertex on
// top and the F face towards the viewer. Vertices: U (top), L (front-left),
// R (front-right), B (back). Faces: F (U L R), L (U B L), R (U R B), D (L R B).
//
// Each face has nine triangular stickers, read row by row from the apex of
// the head-on picture: row 0 = (0), row 1 = (1 2 3), row 2 = (4 5 6 7 8).
// Even positions within a row point up, odd positions point down.
// Side faces are drawn with U at the top, D with B at the top.
//
// Notation (WCA): U L R B turn the two layers at that vertex, u l r b only the
// tip, 120° clockwise as seen from the vertex. Suffix ' for counter-clockwise.
// Rotations of the whole puzzle: y about the U vertex (clockwise seen from
// above, like U), z about the F face centre (clockwise seen from the front).

#import "../geom.typ" as g
#import "../notation.typ"

#let edge = 3
#let height = edge * calc.sqrt(2 / 3)
#let verts = (
  U: (0, 3 * height / 4, 0),
  B: (0, -height / 4, -edge / calc.sqrt(3)),
  L: (-edge / 2, -height / 4, edge / (2 * calc.sqrt(3))),
  R: (edge / 2, -height / 4, edge / (2 * calc.sqrt(3))),
)
// (apex, base-left, base-right) as seen from outside with the apex up
#let corners = (F: ("U", "L", "R"), L: ("U", "B", "L"), R: ("U", "R", "B"), D: ("B", "R", "L"))
#let face-names = ("F", "L", "R", "D")
#let default-scheme = (F: "green", L: "red", R: "blue", D: "yellow")

#let the-model = {
  let faces = (:)
  let stickers = ()
  for f in face-names {
    let (a, bl, br) = corners.at(f).map(v => verts.at(v))
    let center = g.centroid((a, bl, br))
    let normal = g.unit(center)
    let fr = g.frame(center, normal, g.sub(a, center))
    faces.insert(f, (normal: normal, frame: fr, verts: (a, bl, br)))
    // lattice points: P(i, j) = apex + i * down-left + j * right
    let e1 = g.scale(g.sub(br, bl), 1 / edge)
    let e2 = g.scale(g.sub(bl, a), 1 / edge)
    let p(i, j) = g.add(a, g.add(g.scale(e2, i), g.scale(e1, j)))
    let index = 0
    for r in range(edge) {
      for k in range(2 * r + 1) {
        let j = calc.quo(k, 2)
        let poly = if calc.rem(k, 2) == 0 { (p(r, j), p(r + 1, j), p(r + 1, j + 1)) } else {
          (p(r, j), p(r, j + 1), p(r + 1, j + 1))
        }
        stickers.push((face: f, index: index, poly: poly))
        index += 1
      }
    }
  }
  // layers at each vertex: the tip (top third) and the tip plus the middle layer
  let regions = ()
  for (name, v) in verts {
    let axis = g.unit(v)
    let top = g.norm(v)
    regions.push((axis: axis, lo: top - height / 3, hi: 1e9))
    regions.push((axis: axis, lo: top - 2 * height / 3, hi: 1e9))
  }
  (faces: faces, stickers: stickers, regions: regions)
}

#let token = regex("^([ULRBulrbyz])(2['’]|['’]2|2|['’])?")
#let rotation-axes = (
  y: g.unit(verts.U),
  z: g.unit(g.centroid(corners.F.map(v => verts.at(v)))),
)
#let make-move(caps) = {
  let (letter, suffix) = caps
  let amount = notation.suffix-amount(suffix)
  if letter in rotation-axes {
    return (
      base: letter,
      amount: amount,
      order: 3,
      axis: rotation-axes.at(letter),
      step: -120deg,
      region: (-1e9, 1e9),
      style: "",
      puzzle: "pyraminx",
    )
  }
  let v = verts.at(upper(letter))
  let tip-only = letter != upper(letter)
  let depth = if tip-only { height / 3 } else { 2 * height / 3 }
  (
    base: letter,
    amount: amount,
    order: 3,
    axis: g.unit(v),
    step: -120deg,
    region: (g.norm(v) - depth, 1e9),
    style: "",
    puzzle: "pyraminx",
  )
}

#let puzzle = (
  name: "pyraminx",
  event: name => if name == "pyraminx" { (:) } else { none },
  event-name: params => "pyraminx",
  faces: params => face-names,
  default-scheme: params => default-scheme,
  model: params => the-model,
  parse: (alg, params) => notation.scan(alg, token, make-move),
  format: m => m.base + notation.format-suffix(m.amount, m.order),
  views: ("face", "tip", "full", "net"),
  // `full` has a face in front and a vertex on top (F and U by default)
  front-top: ("F", "U"),
  tops: ("U", "L", "R", "B"),
  direction: (params, name, role) => if role == "top" {
    if name in verts { g.unit(verts.at(name)) } else { none }
  } else {
    if name in the-model.faces { the-model.faces.at(name).normal } else { none }
  },
  cameras: params => (
    // from the front-right and slightly below, tip on top: F large on the
    // left, R on the right, the D base visible underneath
    full: (dir: g.unit((1.2, -0.35, 1)), up: (0, 1, 0)),
    tips: (
      U: (dir: g.unit(verts.U), up: (0, 0, -1)),
      L: (dir: g.unit(verts.L), up: (0, 1, 0)),
      R: (dir: g.unit(verts.R), up: (0, 1, 0)),
      B: (dir: g.unit(verts.B), up: (0, 1, 0)),
    ),
  ),
  net: params => (
    roots: ("F",),
    edges: (("F", "D"), ("D", "L"), ("D", "R")),
  ),
)
