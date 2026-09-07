///! Continuous position scales for x and y.
///!
///! Use these to override the default continuous axis: set `limits` to clip,
///! `breaks` and `labels` to control tick marks, or `transform` to apply
///! `"log10"`, `"sqrt"`, or `"reverse"` transformations.

#import "../utils/errors.typ": fail-enum

// Accepted `transform` names, mirrored by `transform-fwd`/`transform-inv` in
// train.typ, and accepted `oob` modes, mirrored by `_check` in oob.typ. The
// public `scale-*` constructors defer, so these fire when `scales()` binds the
// scale: a typo fails there rather than silently no-opping downstream.
#let _TRANSFORMS = ("identity", "reverse", "log10", "sqrt")
#let _OOB-MODES = ("drop", "squish")

#let _check-transform(transform) = {
  if transform not in _TRANSFORMS {
    fail-enum("scale", "transform", transform, _TRANSFORMS)
  }
}

#let _check-oob(oob) = {
  if oob not in _OOB-MODES {
    fail-enum("scale", "oob", oob, _OOB-MODES)
  }
}

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
  _check-transform(transform)
  _check-oob(oob)
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
  // `transform` is always a fixed literal from `_trans(...)` in bind.typ, so only
  // the user-reachable `oob` needs checking here.
  _check-oob(oob)
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
  _check-oob(oob)
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
