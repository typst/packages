// Public constructors (API 1): build a puzzle from a scramble or from the
// case an algorithm solves.

#import "state.typ": solved
#import "moves.typ"

/// A puzzle for `event` ("3x3", "2x2", .., "skewb", "pyraminx", "megaminx"),
/// optionally scrambled.
///
/// - `scramble`: algorithm string (or move array) applied to the solved puzzle.
/// - `inverted`: apply the inverse instead, giving the state that `scramble`
///   solves. This is what you want for case diagrams.
/// - `scheme`: face → color name; `auto` is the puzzle's default scheme.
/// - `options`: puzzle-specific settings, e.g. `(cut: 0.4)` on the megaminx.
#let cube(event: "3x3", scramble: none, inverted: false, scheme: auto, options: (:)) = {
  let c = solved(event: event, scheme: scheme, options: options)
  if scramble == none {
    c
  } else if inverted {
    moves.apply(c, moves.inverse(scramble, event: event, options: options))
  } else {
    moves.apply(c, scramble)
  }
}

/// The state that `alg` solves (shorthand for `cube(scramble: alg, inverted: true)`).
#let case(alg, event: "3x3", scheme: auto, options: (:)) = {
  cube(event: event, scramble: alg, inverted: true, scheme: scheme, options: options)
}
