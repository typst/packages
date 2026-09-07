// Internal type tags and small vector helpers shared across the package.
// Every diagram item flowing through `diagram()` is a length-N array of
// tagged dictionaries (arrays are used, not bare dictionaries, so that
// sequential statements in a Typst code block auto-join via `+`).

#let is-node(it) = type(it) == dictionary and it.at("type", default: none) == "node"
#let is-edge(it) = type(it) == dictionary and it.at("type", default: none) == "edge"
#let is-content(it) = type(it) == dictionary and it.at("type", default: none) == "content"

#let is-coord(it) = (
  type(it) == array and it.len() == 2
    and type(it.at(0)) in (int, float)
    and type(it.at(1)) in (int, float)
)

// Unwraps a value that may be a raw node array (as returned by `z(..)` etc,
// i.e. `((..dict),)`), an already-bare node dictionary, or something else
// (coordinate / path element), returning the bare node dictionary if any.
#let unwrap-node(it) = {
  if type(it) == array and it.len() == 1 and is-node(it.at(0)) {
    it.at(0)
  } else if is-node(it) {
    it
  } else {
    none
  }
}

// Plain 2-vectors, used throughout for diagram-unit coordinate maths.
#let vadd(a, b) = (a.at(0) + b.at(0), a.at(1) + b.at(1))
#let vsub(a, b) = (a.at(0) - b.at(0), a.at(1) - b.at(1))
#let vscale(a, k) = (a.at(0) * k, a.at(1) * k)
#let vlen(a) = calc.sqrt(a.at(0) * a.at(0) + a.at(1) * a.at(1))
#let vmid(a, b) = vscale(vadd(a, b), 0.5)
// Rotated a quarter turn, for offsetting perpendicular to a direction.
#let vperp(a) = (-a.at(1), a.at(0))
// Unit-length version; the zero vector is returned unchanged.
#let vunit(a) = {
  let len = vlen(a)
  if len == 0 { a } else { vscale(a, 1 / len) }
}

// Turns a direction given as an `angle` or an `alignment` into an `angle`,
// in diagram-unit math convention (0deg = +x/right, 90deg = +y/up — matches
// the fact that diagram coordinates now put +y up, per `geometry.to-screen`).
#let direction-to-angle(direction) = {
  if type(direction) == angle { return direction }
  assert(
    direction in (left, right, top, bottom),
    message: "direction must be an angle or one of left/right/top/bottom, got " + repr(direction),
  )
  if direction == right { 0deg }
  else if direction == left { 180deg }
  else if direction == top { 90deg }
  else { -90deg }
}

// Wraps label content so `measure()` (and the identical wrapping used when
// the same content is later placed) reports the tight ink bounding box
// instead of the font's ascender/descender metrics box. Without this,
// content like `$g$` (no ascender) measures with a chunk of dead space
// above the glyph, which then reads as "not vertically centered" once
// placed in the middle of a shape.
#let tight-text(body) = text(top-edge: "bounds", bottom-edge: "bounds", body)

// Splits a `from`/`to` edge-endpoint argument (auto | angle | alignment |
// (angle-or-alignment, strength)) into (angle, strength).
#let split-direction(direction) = {
  if direction == auto { return (auto, 1) }
  if type(direction) == array {
    assert(direction.len() == 2, message: "direction array must have exactly 2 elements")
    let (first, second) = direction
    let first-direction = type(first) in (angle, alignment)
    let second-direction = type(second) in (angle, alignment)
    let first-number = type(first) in (int, float)
    let second-number = type(second) in (int, float)
    assert(
      (first-direction and second-number)
        or (second-direction and first-number),
      message: "direction array must contain exactly one direction and one numeric strength",
    )
    let value = if first-direction { first } else { second }
    let strength = if first-number { first } else { second }
    assert(strength > 0, message: "direction strength must be positive")
    return (direction-to-angle(value), strength)
  }
  (direction-to-angle(direction), 1)
}
