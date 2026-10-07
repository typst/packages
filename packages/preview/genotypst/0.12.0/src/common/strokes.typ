#import "./colors.typ": _dark-gray, _medium-gray, _yellow

/// Default stroke for coordinate axes, scale bars, and label leader lines
#let _default-axis-stroke = stroke(
  thickness: 0.75pt,
  paint: black,
  cap: "butt",
)

/// Default stroke for filled-shape outlines, such as gene arrows
#let _default-outline-stroke = stroke(
  thickness: 0.75pt,
  paint: black,
  join: "miter",
)

/// Default stroke for matrix cell borders
#let _default-cell-stroke = stroke(thickness: 0.75pt, paint: _medium-gray)

/// Default stroke for tree branches
#let _default-branch-stroke = stroke(
  thickness: 0.75pt,
  paint: black,
  cap: "square",
)

/// Default stroke for leader lines connecting aligned tip labels to branches
#let _default-tip-leader-stroke = stroke(
  thickness: 0.75pt,
  paint: _medium-gray,
  cap: "square",
  dash: (1pt, 2.3pt),
)

/// Default stroke for dynamic-programming traceback arrows
#let _default-arrow-stroke = stroke(
  thickness: 0.75pt,
  paint: _medium-gray,
  cap: "round",
)

/// Default stroke for traceback arrows lying on the highlighted path
#let _default-path-arrow-stroke = stroke(
  thickness: 0.75pt,
  paint: _dark-gray,
  cap: "round",
)

/// Default stroke for the dynamic-programming traceback highlight
#let _default-path-stroke = stroke(
  thickness: 18pt,
  paint: _yellow.transparentize(50%),
  cap: "round",
  join: "round",
)
