// N×N×N cube.
//
// Faces are squares of side N centred on the axes. Face arrays follow the
// standard net (every face viewed from outside with U above it, except U with
// B above it and D with F above it); sticker index = row * N + col.
//
// Notation: R L U D F B, wide Rw r 3Rw, slices M E S, rotations x y z,
// suffixes ' 2 2', groups (R U R' U')3.

#import "../geom.typ" as g
#import "../notation.typ"

#let face-names = ("U", "D", "F", "B", "R", "L")
#let normals = (U: (0, 1, 0), D: (0, -1, 0), F: (0, 0, 1), B: (0, 0, -1), R: (1, 0, 0), L: (-1, 0, 0))
#let ups = (U: (0, 0, -1), D: (0, 0, 1), F: (0, 1, 0), B: (0, 1, 0), R: (0, 1, 0), L: (0, 1, 0))
#let opposite = (U: "D", D: "U", F: "B", B: "F", R: "L", L: "R")
#let slice-face = (M: "L", E: "D", S: "F")
#let rotation-face = (x: "R", y: "U", z: "F")

#let default-scheme = (U: "yellow", D: "white", F: "green", B: "blue", R: "orange", L: "red")

/// The six square faces of a cube with half-size `h`, with their frames.
/// Shared with the skewb.
#let cube-faces(h) = {
  face-names.map(f => {
    let fr = g.frame(g.scale(normals.at(f), h), normals.at(f), ups.at(f))
    let corner(x, y) = g.from-local(fr, (x, y))
    (f, (normal: normals.at(f), frame: fr, verts: (corner(-h, -h), corner(-h, h), corner(h, h), corner(h, -h))))
  }).to-dict()
}

// "3x3", "3*3" or "3x3x3": the separator may be `x` or `*`
#let event(name) = {
  let m = name.match(regex("^(\d+)[x*](\d+)(?:[x*](\d+))?$"))
  if m == none { return none }
  let n = int(m.captures.at(0))
  if n < 1 or m.captures.at(1) != m.captures.at(0) { return none }
  if m.captures.at(2) != none and m.captures.at(2) != m.captures.at(0) { return none }
  (size: n)
}

#let model(params) = {
  let n = params.size
  let h = n / 2
  let faces = cube-faces(h)
  let stickers = ()
  for f in face-names {
    let fr = faces.at(f).frame
    for r in range(n) {
      for c in range(n) {
        let (x0, y0) = (c - h, r - h)
        stickers.push((
          face: f,
          index: r * n + c,
          poly: ((x0, y0), (x0 + 1, y0), (x0 + 1, y0 + 1), (x0, y0 + 1)).map(q => g.from-local(fr, q)),
        ))
      }
    }
  }
  // every layer of every face, for piece identification
  let regions = ()
  for f in face-names {
    for d in range(n) { regions.push((axis: normals.at(f), lo: h - d - 1, hi: h - d)) }
  }
  (faces: faces, stickers: stickers, regions: regions)
}

// --- notation ----------------------------------------------------------------

#let token = regex("^(\d*)([RLUDFBrludfbMESxyz])(w?)(2['’]|['’]2|2|['’])?")

#let make-move(caps, size) = {
  let (count, letter, w, suffix) = caps
  let h = size / 2
  let big = 1e9
  let move = if letter in slice-face {
    assert(count == "" and w == "", message: "cubst: slice move " + letter + " takes no layer count or 'w'")
    assert(size >= 3, message: "cubst: slice moves need a cube of size 3 or more")
    (base: letter, face: slice-face.at(letter), layers: "inner", region: (-h + 1, h - 1))
  } else if letter in rotation-face {
    assert(count == "" and w == "", message: "cubst: rotation " + letter + " takes no layer count or 'w'")
    (base: letter, face: rotation-face.at(letter), layers: "all", region: (-big, big))
  } else {
    let face = upper(letter)
    let wide = w == "w" or letter != face
    let layers = if count != "" {
      assert(wide, message: "cubst: a layer count needs a wide move, e.g. 3Rw")
      int(count)
    } else if wide { 2 } else { 1 }
    assert(layers <= size, message: "cubst: " + str(layers) + " layers do not fit a " + str(size) + "x" + str(size) + " cube")
    let base = if layers == 1 { face } else if layers == 2 { face + "w" } else { str(layers) + face + "w" }
    (base: base, face: face, layers: layers, region: (h - layers, h))
  }
  (
    ..move,
    amount: notation.suffix-amount(suffix),
    order: 4,
    axis: normals.at(move.face),
    step: -90deg,
    style: "",
    puzzle: "cube",
  )
}

#let parse(alg, params) = notation.scan(alg, token, caps => make-move(caps, params.size))
#let format(m) = m.base + notation.format-suffix(m.amount, 4)

// --- hooks used by state and renderers ---------------------------------------

#let index-of(params, face, pos) = {
  assert(
    type(pos) == array and pos.len() == 2,
    message: "cubst: a cube sticker position is (row, col), got " + repr(pos),
  )
  pos.at(0) * params.size + pos.at(1)
}
#let index-info(params, index) = (row: calc.quo(index, params.size), col: calc.rem(index, params.size))

#let puzzle = (
  name: "cube",
  event: event,
  event-name: params => str(params.size) + "x" + str(params.size),
  faces: params => face-names,
  default-scheme: params => default-scheme,
  model: model,
  parse: parse,
  format: format,
  views: ("face", "ll", "oll", "f2l", "full", "net"),
  cameras: params => (full: (dir: g.unit((1, 1, 1)), up: (0, 1, 0)), tips: (:)),
  front-top: ("F", "U"),
  net: params => (
    roots: ("F",),
    edges: (("F", "U"), ("F", "D"), ("F", "L"), ("F", "R"), ("R", "B")),
  ),
  rows: params => params.size,
  index-of: index-of,
  index-info: index-info,
)
