///! Internal stroke-scale builders.
///!
///! The public `scale-*` constructors live in constructors.typ and reach these
///! builders through the dispatch in scale/bind.typ.

#let _stroke-continuous(
  name: none,
  range: (0.2pt, 1.4pt),
  limits: none,
  oob: "drop",
  breaks: auto,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "stroke",
  type: "continuous",
  name: name,
  range: range,
  limits: limits,
  oob: oob,
  breaks: breaks,
  labels: labels,
)

#let _stroke-manual(
  values: (),
  name: none,
  limits: none,
  oob: "drop",
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "stroke",
  type: "discrete",
  name: name,
  palette: values,
  limits: limits,
  oob: oob,
  labels: labels,
)

#let _stroke-binned(
  n-breaks: 4,
  breaks: auto,
  range: (0.2pt, 1.4pt),
  name: none,
  limits: none,
  oob: "drop",
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "stroke",
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

#let _stroke-identity(name: none) = (
  kind: "scale",
  aesthetic: "stroke",
  type: "identity",
  name: name,
)
