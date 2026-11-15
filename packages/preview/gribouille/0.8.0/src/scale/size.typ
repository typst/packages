///! Internal size-scale builders.
///!
///! The public `scale-*` constructors live in constructors.typ and reach these
///! builders through the dispatch in scale/bind.typ.

#let _size-continuous(
  name: none,
  range: (1pt, 6pt),
  limits: none,
  oob: "drop",
  breaks: auto,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "size",
  type: "continuous",
  name: name,
  range: range,
  limits: limits,
  oob: oob,
  breaks: breaks,
  labels: labels,
)

#let _size-binned(
  n-breaks: 4,
  breaks: auto,
  range: (1pt, 6pt),
  name: none,
  limits: none,
  oob: "drop",
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "size",
  type: "continuous",
  name: name,
  range: range,
  limits: limits,
  oob: oob,
  breaks: breaks,
  labels: labels,
  binned: true,
  n-breaks: n-breaks,
)

#let _size-area(
  name: none,
  range: (1pt, 6pt),
  limits: none,
  oob: "drop",
  breaks: auto,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "size",
  type: "continuous",
  name: name,
  range: range,
  limits: limits,
  oob: oob,
  breaks: breaks,
  labels: labels,
  size-trans: "area",
)

#let _size-binned-area(
  n-breaks: 4,
  breaks: auto,
  range: (1pt, 6pt),
  name: none,
  limits: none,
  oob: "drop",
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "size",
  type: "continuous",
  name: name,
  range: range,
  limits: limits,
  oob: oob,
  breaks: breaks,
  labels: labels,
  binned: true,
  n-breaks: n-breaks,
  size-trans: "area",
)

#let _size-identity(name: none) = (
  kind: "scale",
  aesthetic: "size",
  type: "identity",
  name: name,
)

#let _size-manual(
  values: (),
  name: none,
  limits: none,
  oob: "drop",
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "size",
  type: "discrete",
  name: name,
  palette: values,
  limits: limits,
  oob: oob,
  labels: labels,
)
