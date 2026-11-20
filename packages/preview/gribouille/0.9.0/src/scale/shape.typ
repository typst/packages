///! Internal shape-scale builders.
///!
///! Maps discrete levels onto marker-shape keywords consumed by geom-point
///! (`"circle"`, `"square"`, `"triangle"`, `"diamond"`, `"cross"`, `"x"`,
///! `"star"`, `"triangle-down"`, `"circle-cross"`). Any value outside this set renders
///! as a literal glyph. The public `scale-*` constructors live in
///! constructors.typ and reach these builders through scale/bind.typ.

#import "../utils/palette.typ": default-shapes

#let _shape-discrete(
  name: none,
  palette: auto,
  limits: none,
  oob: "drop",
  labels: auto,
  missing-value: none,
  missing-translate: true,
) = (
  kind: "scale",
  aesthetic: "shape",
  type: "discrete",
  name: name,
  palette: if palette == auto { default-shapes } else { palette },
  limits: limits,
  oob: oob,
  labels: labels,
  missing-value: missing-value,
  missing-translate: missing-translate,
)

#let _shape-manual(
  values: (),
  name: none,
  limits: none,
  oob: "drop",
  labels: auto,
  missing-value: none,
  missing-translate: true,
) = (
  kind: "scale",
  aesthetic: "shape",
  type: "discrete",
  name: name,
  palette: values,
  limits: limits,
  oob: oob,
  labels: labels,
  missing-value: missing-value,
  missing-translate: missing-translate,
)

#let _shape-identity(name: none) = (
  kind: "scale",
  aesthetic: "shape",
  type: "identity",
  name: name,
)

#let _shape-binned(
  n-breaks: 4,
  breaks: auto,
  palette: auto,
  name: none,
  limits: none,
  oob: "drop",
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "shape",
  type: "continuous",
  name: name,
  palette: if palette == auto { default-shapes } else { palette },
  limits: limits,
  oob: oob,
  labels: labels,
  binned: true,
  n-breaks: n-breaks,
  breaks: breaks,
)
