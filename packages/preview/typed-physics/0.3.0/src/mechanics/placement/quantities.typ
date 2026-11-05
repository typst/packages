// Symbolic quantities introduced while declarations become placed geometry.

#import "../../shared/expression.typ"

// A number substitutes to itself and still prints as g; content the author
// wrote keeps gravity symbolic through every equation that uses it.
#let gravity-quantity(gravity-acceleration) = expression.declared(
  gravity-acceleration,
  $g$,
)

// `block("m1")` should print as m_1 and `block("A")` as m_A, so a name that is
// already a mass symbol does not get wrapped in another one. A `symbol:` the
// author declared replaces the derived one everywhere the mass is printed.
#let mass-symbol(name, declared-symbol) = {
  if declared-symbol != auto { return declared-symbol }
  let numbered-mass-name = name.match(regex("^m([0-9]+)$"))
  if numbered-mass-name != none {
    let mass-index = numbered-mass-name.captures.first()
    return $m_#mass-index$
  }
  $m_#name$
}

// One ramp in a situation is θ; several are told apart by name.
#let angle-symbol(surface-name, ramp-count, declared-symbol) = {
  if declared-symbol != auto { return declared-symbol }
  if ramp-count <= 1 { $theta$ } else { $theta_#surface-name$ }
}

// ── Attachment points ────────────────────────────────────────────────────────
//
// One spelling reaches every point another element can be pinned to:
// `"ceiling"` for an element's default anchor, `"incline.apex"` for a named
// one, and `(on: "ceiling", at: 40%)` for a ratio along a surface.
