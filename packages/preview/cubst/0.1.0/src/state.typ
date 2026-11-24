// Puzzle state model.
//
// A state is a plain dictionary:
//   (kind: "puzzle", puzzle: "cube", event: "3x3", params: (size: 3),
//    scheme: (U: "yellow", ..), faces: (U: (..stickers..), ..))
// Each face is a flat array of stickers in the order defined by the puzzle
// (see `src/puzzles/<name>.typ`); a sticker is a color *name* or `none` for
// hidden. For cubes `face()` reshapes the array into rows.
//
// Nothing in this file knows about moves or rendering.

#import "geom.typ" as g
#import "puzzles/registry.typ" as registry
#import "puzzles/cube.typ": default-scheme

#let is-puzzle(x) = type(x) == dictionary and x.at("kind", default: none) == "puzzle"

#let assert-puzzle(x, who: "cubst") = {
  assert(
    is-puzzle(x),
    message: who + ": expected a puzzle state (made with `cube()` or `case()`), got " + repr(x),
  )
}

/// A solved puzzle for the given event ("3x3", "4x4", .., "skewb", "pyraminx",
/// "megaminx"). `options` are puzzle-specific settings, e.g. `(cut: 0.4)` on
/// the megaminx.
#let solved(event: "3x3", scheme: auto, options: (:)) = {
  let (puzzle, params) = registry.resolve(event, options: options)
  let p = registry.puzzles.at(puzzle)
  let faces = (p.faces)(params)
  let scheme = if scheme == auto { (p.default-scheme)(params) } else { scheme }
  for f in (p.at("scheme-faces", default: p.faces))(params) {
    assert(f in scheme, message: "cubst: scheme for " + (p.event-name)(params) + " is missing face " + f)
  }
  let base = (
    kind: "puzzle",
    puzzle: puzzle,
    event: (p.event-name)(params),
    params: params,
    scheme: scheme,
  )
  // a puzzle whose geometry depends on the state builds its own solved state
  if "solved" in p { return base + (p.solved)(params, scheme) }
  let counts = (:)
  for s in (p.model)(params).stickers { counts.insert(s.face, counts.at(s.face, default: 0) + 1) }
  base + (faces: faces.map(f => (f, (scheme.at(f),) * counts.at(f))).to-dict())
}

#let assert-face(c, name, who: "cubst") = {
  assert(
    name in c.faces,
    message: who + ": " + c.event + " has no face " + repr(name) + "; faces are " + c.faces.keys().join(", "),
  )
}

/// The stickers of one face: rows for a cube, a flat array otherwise.
#let face(c, name) = {
  assert-puzzle(c, who: "face")
  assert-face(c, name, who: "face")
  let flat = c.faces.at(name)
  let rows = registry.of(c).at("rows", default: none)
  if rows == none { flat } else { flat.chunks(rows(c.params)) }
}

/// Sticker index for a position: an index, or `(row, col)` on a cube.
#let index-of(c, name, pos) = {
  let count = c.faces.at(name).len()
  let i = if type(pos) == int { pos } else {
    let hook = registry.of(c).at("index-of", default: none)
    assert(hook != none, message: "cubst: " + c.event + " sticker positions are plain indices, got " + repr(pos))
    hook(c.params, name, pos)
  }
  assert(i >= 0 and i < count, message: "cubst: no sticker " + repr(pos) + " on face " + name + " of a " + c.event)
  i
}

/// One sticker (color name or `none` when hidden): `sticker(c, "U", row, col)`
/// on a cube, `sticker(c, "F", index)` on the other puzzles.
#let sticker(c, name, ..pos) = {
  assert-puzzle(c, who: "sticker")
  assert-face(c, name, who: "sticker")
  let pos = pos.pos()
  let p = if pos.len() == 1 { pos.first() } else { pos }
  c.faces.at(name).at(index-of(c, name, p))
}

/// True when every face shows a single color (a puzzle may define its own
/// test, e.g. the Square-1, whose side stickers never form one face).
#let is-solved(c) = {
  assert-puzzle(c, who: "is-solved")
  let hook = registry.of(c).at("is-solved", default: none)
  if hook != none { return hook(c) }
  c.faces.values().all(stickers => stickers.all(s => s == stickers.first()))
}

/// Piece identity of every sticker, keyed "face:index". Two stickers are on
/// the same piece exactly when every layer of the puzzle moves both or neither
/// (or, when the model names the piece of each sticker, when it says so).
#let pieces(c) = {
  let model = registry.model(c)
  let out = (:)
  for s in model.stickers {
    let key = s.face + ":" + str(s.index)
    if "piece" in s {
      out.insert(key, s.piece)
      continue
    }
    let p = g.centroid(s.poly)
    let sig = model.regions.map(r => {
      let t = g.dot(p, r.axis)
      if t >= r.lo - 1e-6 and t <= r.hi + 1e-6 { "1" } else { "0" }
    }).join()
    out.insert(key, sig)
  }
  out
}

/// Generic mask: keep stickers for which `keep(info)` is true, hide the rest.
/// `info` has `face`, `index`, `color`, `piece`, and `row`/`col` on a cube.
#let mask(c, keep) = {
  assert-puzzle(c, who: "mask")
  let ids = pieces(c)
  let extra = registry.of(c).at("index-info", default: none)
  let out = c
  for (f, stickers) in c.faces {
    for (i, color) in stickers.enumerate() {
      if color == none { continue }
      let info = (face: f, index: i, color: color, piece: ids.at(f + ":" + str(i)))
      if extra != none { info += extra(c.params, i) }
      if not keep(info) { out.faces.at(f).at(i) = none }
    }
  }
  out
}

/// Keep only stickers whose color name is in `colors` (a string or array of strings).
#let keep-colors(c, colors) = {
  let colors = if type(colors) == str { (colors,) } else { colors }
  mask(c, info => info.color in colors)
}

/// Hide stickers of the given faces entirely.
#let hide-faces(c, faces) = {
  let faces = if type(faces) == str { (faces,) } else { faces }
  mask(c, info => info.face not in faces)
}

/// Hide every sticker of every piece that carries at least one sticker of the
/// given color(s). Used for F2L diagrams (hide the last-layer pieces).
#let hide-pieces(c, containing: none) = {
  assert-puzzle(c, who: "hide-pieces")
  let colors = if type(containing) == str { (containing,) } else { containing }
  let ids = pieces(c)
  let marked = ()
  for (f, stickers) in c.faces {
    for (i, color) in stickers.enumerate() {
      if color in colors { marked.push(ids.at(f + ":" + str(i))) }
    }
  }
  mask(c, info => info.piece not in marked)
}
