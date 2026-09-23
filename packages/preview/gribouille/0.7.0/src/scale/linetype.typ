///! Internal linetype-scale builders.
///!
///! Maps discrete levels onto CeTZ dash keywords consumed by geom-line
///! (`"solid"`, `"dashed"`, `"dotted"`, `"dash-dotted"`, etc.). The public
///! `scale-*` constructors live in constructors.typ and reach these builders
///! through scale/bind.typ.

#import "../utils/palette.typ": default-linetypes

#let _linetype-discrete(
  name: none,
  palette: auto,
  limits: none,
  oob: "drop",
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "linetype",
  type: "discrete",
  name: name,
  palette: if palette == auto { default-linetypes } else { palette },
  limits: limits,
  oob: oob,
  labels: labels,
)

#let _linetype-manual(
  values: (),
  name: none,
  limits: none,
  oob: "drop",
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "linetype",
  type: "discrete",
  name: name,
  palette: values,
  limits: limits,
  oob: oob,
  labels: labels,
)

#let _linetype-identity(name: none) = (
  kind: "scale",
  aesthetic: "linetype",
  type: "identity",
  name: name,
)

#let _linetype-binned(
  n-breaks: 4,
  breaks: auto,
  palette: auto,
  name: none,
  limits: none,
  oob: "drop",
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "linetype",
  type: "continuous",
  name: name,
  palette: if palette == auto { default-linetypes } else { palette },
  limits: limits,
  oob: oob,
  labels: labels,
  binned: true,
  n-breaks: n-breaks,
  breaks: breaks,
)
