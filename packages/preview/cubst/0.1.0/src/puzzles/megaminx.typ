// Megaminx.
//
// A regular dodecahedron with U on top and F towards the viewer. The upper
// ring is F, R, BR, BL, L (clockwise seen from above); the lower ring is DR,
// DBR, B, DBL, DL, each sitting below the gap between two upper faces; D is
// at the bottom. Face inradius is 1.5 units.
//
// The `full` view looks straight down one face (F unless `draw(face:)` says
// otherwise, with `top:` up), so that face and its five neighbours are seen.
//
// Each face has eleven stickers: 0 is the centre, 1–5 the edge stickers and
// 6–10 the corner stickers, both clockwise from the top of the head-on
// picture. Every face is drawn with a vertex at the top: U with B at the
// top, D with F at the top, the side faces with U at the upper right.
//
// Notation (WCA): face turns U F R L BL BR DR DL DBR DBL B D with ' 2 2';
// R++ / R-- turn everything except L, D++ / D-- everything except U, by two
// fifths, clockwise (++) or counter-clockwise (--) seen from the R / D side.

#import "../geom.typ" as g
#import "../notation.typ"

#let phi = (1 + calc.sqrt(5)) / 2
#let face-names = ("U", "F", "R", "BR", "BL", "L", "D", "DR", "DBR", "B", "DBL", "DL")
#let default-scheme = (
  U: "white", F: "green", R: "red", BR: "blue", BL: "yellow", L: "purple",
  D: "grey", B: "lime", DBL: "orange", DL: "lightblue", DR: "beige", DBR: "pink",
)

// Options a user can pass with `cube(event: "megaminx", options: (..))`:
// `cut` is the size of the centre pentagon (its inradius over the face
// inradius). It changes the sticker shapes and the layer depth.
#let options = (cut: 0.4)

#let build(cut) = {
  // An edge sticker is the strip outside its own cut line and inside the two
  // neighbouring ones; those cross the face edge only when the cut is deeper
  // than cos 72° ≈ 0.309 of the inradius, so smaller cuts leave the edge
  // stickers floating inside the face. That is allowed (the manual warns)
  // but the geometry must stay non-degenerate.
  assert(
    type(cut) in (int, float) and cut > 0.05 and cut < 0.95,
    message: "cubst: megaminx cut must be a number between 0.05 and 0.95, got " + repr(cut),
  )
  // standard dodecahedron: vertices (±1,±1,±1), (0,±1/φ,±φ) and cyclic
  // permutations; face centres along (0,±φ,±1) and cyclic permutations.
  // Rotate about x so that the (0, φ, 1) face points up, then about y by 36°
  // so that an upper-ring face points to the front.
  let r = calc.sqrt(1 + phi * phi)
  let (ct, st) = (phi / r, 1 / r)
  let (cy, sy) = (calc.cos(36deg), calc.sin(36deg))
  let orient(p) = {
    let (x, y, z) = (p.at(0), p.at(1) * ct + p.at(2) * st, -p.at(1) * st + p.at(2) * ct)
    (x * cy + z * sy, y, -x * sy + z * cy)
  }
  let raw-verts = ()
  for x in (-1, 1) {
    for y in (-1, 1) {
      for z in (-1, 1) { raw-verts.push((x, y, z)) }
    }
  }
  for s in (-1, 1) {
    for t in (-1, 1) {
      raw-verts.push((0, s / phi, t * phi))
      raw-verts.push((s / phi, t * phi, 0))
      raw-verts.push((s * phi, 0, t / phi))
    }
  }
  let raw-normals = ()
  for s in (-1, 1) {
    for t in (-1, 1) {
      raw-normals.push((0, s * phi, t))
      raw-normals.push((t, 0, s * phi))
      raw-normals.push((s * phi, t, 0))
    }
  }
  let verts = raw-verts.map(orient)
  let normals = raw-normals.map(n => g.unit(orient(n)))

  // name each face by its direction
  let upper = (F: 0deg, R: 72deg, BR: 144deg, BL: -144deg, L: -72deg)
  let lower = (DR: 36deg, DBR: 108deg, B: 180deg, DBL: -108deg, DL: -36deg)
  let name-of(n) = {
    if n.at(1) > 0.9 { return "U" }
    if n.at(1) < -0.9 { return "D" }
    let az = calc.atan2(n.at(2), n.at(0))
    let ring = if n.at(1) > 0 { upper } else { lower }
    let diff(a, b) = calc.abs(calc.rem-euclid((a - b).deg() + 180, 360) - 180)
    ring.pairs().sorted(key: ((name, a)) => diff(az, a)).first().at(0)
  }
  // scale so that one unit is the edge of the centre pentagon at the default
  // cut (a pentagon of inradius r has edge 2 r tan 36°), like a cube sticker
  let n0 = normals.first()
  let ring0 = verts.sorted(key: v => -g.dot(v, n0)).slice(0, 5)
  let c0 = g.centroid(ring0)
  let fr0 = g.frame(c0, n0, (0, 0, 1))
  let local0 = ring0.map(v => g.to-local(fr0, v)).sorted(key: g.clock-angle)
  let inradius-raw = g.norm2(g.centroid2((local0.at(0), local0.at(1))))
  let s = (1 / (2 * options.cut * calc.tan(36deg))) / inradius-raw
  let verts = verts.map(v => g.scale(v, s))

  // head-on orientation: U with B at the top, D with F at the top, and the
  // side faces turned 36° clockwise from "U at the top", so that every face
  // has a vertex at the top and a horizontal bottom edge (U then sits at the
  // upper right of a side face)
  let ups = (U: (0, 0, -1), D: (0, 0, 1))
  let up-of(name, n) = ups.at(name, default: g.rotate((0, 1, 0), n, 36deg))
  let faces = (:)
  let stickers = ()
  let inradius = none
  let face-inradius = none
  for n in normals {
    let name = name-of(n)
    let ring = verts.sorted(key: v => -g.dot(v, n)).slice(0, 5)
    let center = g.centroid(ring)
    let fr = g.frame(center, n, up-of(name, n))
    let local = ring.map(v => g.to-local(fr, v)).sorted(key: g.clock-angle)
    faces.insert(name, (normal: n, frame: fr, verts: local.map(q => g.from-local(fr, q))))
    inradius = g.dot(ring.first(), n)
    // edge i runs from vertex i to i+1; its outward unit normal m_i
    let mids = range(5).map(i => g.centroid2((local.at(i), local.at(calc.rem(i + 1, 5)))))
    face-inradius = g.norm2(mids.first())
    let d = cut * face-inradius
    let m = mids.map(g.unit2)
    let inside(poly, i) = g.clip(poly, m.at(i).at(0), m.at(i).at(1), d)
    let outside(poly, i) = g.clip(poly, -m.at(i).at(0), -m.at(i).at(1), -d)
    let shapes = ()
    shapes.push(range(5).fold(local, inside)) // centre
    // edges clockwise from the top (by their midpoint), then corners clockwise
    // from the top (the vertices are already sorted that way)
    for i in range(5).sorted(key: i => g.clock-angle(mids.at(i))) {
      shapes.push(inside(inside(outside(local, i), calc.rem(i + 4, 5)), calc.rem(i + 1, 5)))
    }
    for i in range(5) { shapes.push(outside(outside(local, calc.rem(i + 4, 5)), i)) }
    for (i, poly) in shapes.enumerate() {
      stickers.push((face: name, index: i, poly: poly.map(q => g.from-local(fr, q))))
    }
  }
  // depth of a face's cut plane below the face: the cut line in a neighbour
  // lies (face-inradius - d) from the shared edge, at the dihedral angle
  let depth = (1 - cut) * face-inradius * (2 / calc.sqrt(5))
  let layer = inradius - depth
  let regions = face-names.map(f => (axis: faces.at(f).normal, lo: layer, hi: 1e9))
  (faces: faces, stickers: stickers, regions: regions, layer: layer)
}

// the default geometry is built once; other cuts are built on demand
#let the-model = build(options.cut)
#let model(params) = if params.cut == options.cut { the-model } else { build(params.cut) }

#let token = regex("^(DBR|DBL|BR|BL|DR|DL|U|F|R|L|B|D)(\+\+|--|2['’]|['’]2|2|['’])?")
#let make-move(caps, m) = {
  let (name, suffix) = caps
  if suffix in ("++", "--") {
    assert(name in ("R", "D"), message: "cubst: only R++ R-- D++ D-- are defined on the megaminx")
    // everything except the opposite side turns, seen from that side
    let fixed = if name == "R" { "L" } else { "U" }
    (
      base: name,
      amount: if suffix == "++" { 2 } else { -2 },
      order: 5,
      axis: m.faces.at(fixed).normal,
      step: 72deg,
      region: (-1e9, m.layer),
      style: "pm",
      puzzle: "megaminx",
    )
  } else {
    (
      base: name,
      amount: notation.suffix-amount(suffix),
      order: 5,
      axis: m.faces.at(name).normal,
      step: -72deg,
      region: (m.layer, 1e9),
      style: "",
      puzzle: "megaminx",
    )
  }
}

#let format(m) = {
  if m.style == "pm" { m.base + if m.amount > 0 { "++" } else { "--" } } else {
    m.base + notation.format-suffix(m.amount, 5)
  }
}

#let puzzle = (
  name: "megaminx",
  event: name => if name == "megaminx" { (:) } else { none },
  event-name: params => "megaminx",
  faces: params => face-names,
  default-scheme: params => default-scheme,
  options: options,
  model: model,
  parse: (alg, params) => {
    let m = model(params)
    notation.scan(alg, token, caps => make-move(caps, m))
  },
  format: format,
  views: ("face", "full", "net"),
  // straight down the front face (F), top face (U) up, so the front face and
  // its five neighbours fill a decagon; `draw(face:, top:)` turns this camera
  // to any other adjacent pair
  cameras: params => (full: (dir: model(params).faces.F.normal, up: (0, 1, 0)), tips: (:)),
  front-top: ("F", "U"),
  net: params => (
    roots: ("U", "D"),
    edges: (
      ("U", "F"), ("U", "R"), ("U", "BR"), ("U", "BL"), ("U", "L"),
      ("D", "B"), ("D", "DBL"), ("D", "DL"), ("D", "DR"), ("D", "DBR"),
    ),
  ),
)
