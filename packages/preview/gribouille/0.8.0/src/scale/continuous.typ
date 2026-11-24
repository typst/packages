///! Continuous position scales for x and y.
///!
///! Use these to override the default continuous axis: set `limits` to clip,
///! `breaks` and `labels` to control tick marks, or `transform` to apply
///! `"log10"`, `"sqrt"`, or `"reverse"` transformations.

#let _continuous-scale(
  aesthetic,
  name: none,
  limits: none,
  oob: "drop",
  breaks: auto,
  minor-breaks: auto,
  n-minor: auto,
  labels: auto,
  transform: "identity",
  expand: auto,
  secondary: none,
) = {
  (
    kind: "scale",
    aesthetic: aesthetic,
    type: "continuous",
    name: name,
    limits: limits,
    oob: oob,
    breaks: breaks,
    minor-breaks: minor-breaks,
    n-minor: n-minor,
    labels: labels,
    transform: transform,
    expand: expand,
    secondary: secondary,
  )
}

#let _transform-scale(
  aesthetic,
  transform,
  name: none,
  limits: none,
  oob: "drop",
  breaks: auto,
  minor-breaks: auto,
  n-minor: auto,
  labels: auto,
) = {
  (
    kind: "scale",
    aesthetic: aesthetic,
    type: "continuous",
    name: name,
    limits: limits,
    oob: oob,
    breaks: breaks,
    minor-breaks: minor-breaks,
    n-minor: n-minor,
    labels: labels,
    transform: transform,
    expand: auto,
  )
}

#let _binned-scale(
  aesthetic,
  name: none,
  limits: none,
  oob: "drop",
  n-breaks: 10,
  breaks: auto,
  labels: auto,
) = {
  (
    kind: "scale",
    aesthetic: aesthetic,
    type: "continuous",
    name: name,
    limits: limits,
    oob: oob,
    breaks: breaks,
    labels: labels,
    transform: "identity",
    expand: auto,
    binned: true,
    n-breaks: n-breaks,
  )
}
