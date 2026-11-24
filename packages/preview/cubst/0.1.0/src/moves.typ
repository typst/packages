// The move engine, shared by every puzzle.
//
// A move (see `notation.typ`) is "rotate the stickers whose centroid lies
// between `lo` and `hi` along `axis`, by `step * amount` about `axis`". The
// permutation is found by rotating every moving sticker's centroid and looking
// up which sticker sits there. Nothing here is puzzle-specific; the puzzles
// only provide geometry and notation.

#import "geom.typ" as g
#import "puzzles/registry.typ" as registry
#import "state.typ": assert-puzzle

// Parse for a known puzzle and parameter set (what `apply` uses, so that the
// moves match the state's geometry, e.g. the megaminx cut).
#let parse-with(alg, puzzle, params) = {
  if type(alg) == array { return alg }
  (registry.puzzles.at(puzzle).parse)(alg, params)
}

/// Parse an algorithm string for the given event (and puzzle options). Move
/// arrays pass through.
#let parse(alg, event: "3x3", options: (:)) = {
  if type(alg) == array { return alg }
  let (puzzle, params) = registry.resolve(event, options: options)
  parse-with(alg, puzzle, params)
}

/// Inverse of an algorithm (string or move array), as a move array.
#let inverse(alg, event: "3x3", options: (:)) = {
  parse(alg, event: event, options: options).rev().map(m => (..m, amount: -m.amount))
}

/// Render a move array (or string) back to notation.
#let to-string(moves, event: "3x3", options: (:)) = {
  parse(moves, event: event, options: options).map(m => (registry.puzzles.at(m.puzzle).format)(m)).join(" ")
}

#let nearest(points, q) = {
  let best = none
  let best-d = 1e9
  for (i, p) in points.enumerate() {
    let d = g.norm(g.sub(p, q))
    if d < best-d {
      best = i
      best-d = d
    }
  }
  assert(best-d < 1e-3, message: "cubst: internal error, a rotated sticker landed nowhere")
  best
}

/// Apply an algorithm (string or move array) to a state and return the new state.
#let apply(c, alg) = {
  assert-puzzle(c, who: "apply")
  let moves = parse-with(alg, c.puzzle, c.params)
  if moves.len() == 0 { return c }
  for m in moves {
    assert(
      m.puzzle == c.puzzle,
      message: "cubst: move " + m.base + " belongs to the " + m.puzzle + " notation, not to a " + c.event,
    )
  }
  // a puzzle whose geometry changes with the state moves its own layout
  let hook = registry.of(c).at("apply", default: none)
  if hook != none { return hook(c, moves) }

  let model = registry.model(c)
  let stickers = model.stickers
  let cents = stickers.map(s => g.centroid(s.poly))
  let lookup = (:)
  for (i, p) in cents.enumerate() { lookup.insert(g.key(p), i) }

  // flat state in model order
  let flat = stickers.map(s => c.faces.at(s.face).at(s.index))
  let perms = (:)
  for m in moves {
    let k = m.style + m.base + ":" + str(m.amount)
    if k not in perms {
      let angle = m.step * m.amount
      let perm = range(flat.len())
      for (i, p) in cents.enumerate() {
        let t = g.dot(p, m.axis)
        if t >= m.region.at(0) - 1e-6 and t <= m.region.at(1) + 1e-6 {
          let q = g.rotate(p, m.axis, angle)
          let j = lookup.at(g.key(q), default: none)
          perm.at(i) = if j == none { nearest(cents, q) } else { j }
        }
      }
      perms.insert(k, perm)
    }
    let perm = perms.at(k)
    let next = flat
    for (i, j) in perm.enumerate() { next.at(j) = flat.at(i) }
    flat = next
  }

  let faces = c.faces
  for (i, s) in stickers.enumerate() { faces.at(s.face).at(s.index) = flat.at(i) }
  (..c, faces: faces)
}
