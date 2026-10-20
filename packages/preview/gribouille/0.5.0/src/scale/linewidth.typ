///! Internal linewidth-scale builders.
///!
///! The public `scale-*` constructors live in constructors.typ and reach these
///! builders through the dispatch in scale/bind.typ.

#let _linewidth-continuous(
  name: none,
  range: (0.4pt, 1.4pt),
  limits: none,
  oob: "drop",
  breaks: auto,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "linewidth",
  type: "continuous",
  name: name,
  range: range,
  limits: limits,
  oob: oob,
  breaks: breaks,
  labels: labels,
)

#let _linewidth-manual(
  values: (),
  name: none,
  limits: none,
  oob: "drop",
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "linewidth",
  type: "discrete",
  name: name,
  palette: values,
  limits: limits,
  oob: oob,
  labels: labels,
)

#let _linewidth-binned(
  n-breaks: 4,
  breaks: auto,
  range: (0.4pt, 1.4pt),
  name: none,
  limits: none,
  oob: "drop",
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "linewidth",
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

#let _linewidth-identity(name: none) = (
  kind: "scale",
  aesthetic: "linewidth",
  type: "identity",
  name: name,
)
