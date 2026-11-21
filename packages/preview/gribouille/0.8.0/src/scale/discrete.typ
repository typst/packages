///! Discrete position scales for x and y.
///!
///! Use these when the mapped column is categorical. `limits` controls which
///! levels appear and in what order.

#let _discrete-scale(
  aesthetic,
  name: none,
  limits: none,
  oob: "drop",
  labels: auto,
  expand: auto,
) = (
  kind: "scale",
  aesthetic: aesthetic,
  type: "discrete",
  name: name,
  limits: limits,
  oob: oob,
  labels: labels,
  expand: expand,
)
