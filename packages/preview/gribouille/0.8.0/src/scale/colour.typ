///! Internal colour, fill, and alpha scale builders.
///!
///! `palette` accepts a Typst gradient, an array of colours, or `auto` for
///! the library default. The public `scale-*` constructors live in
///! constructors.typ and reach these builders through scale/bind.typ.

#import "../utils/viridis.typ" as viridis-mod
#import "../utils/palette.typ": brewer-palette, okabe-ito
#import "../utils/colour.typ": grey-palette, hue-palette

// Colour and fill builders take the aesthetic name as the first positional
// argument and the per-family kwargs after; the dispatch binds the aesthetic
// from the `scales()` key. Alpha builders bind their sole aesthetic directly.

#let _scale-continuous(
  aesthetic,
  name: none,
  palette: auto,
  limits: none,
  oob: "drop",
  breaks: auto,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: aesthetic,
  type: "continuous",
  name: name,
  palette: palette,
  limits: limits,
  oob: oob,
  breaks: breaks,
  labels: labels,
)

#let _scale-discrete(
  aesthetic,
  name: none,
  palette: auto,
  limits: none,
  oob: "drop",
  labels: auto,
) = (
  kind: "scale",
  aesthetic: aesthetic,
  type: "discrete",
  name: name,
  palette: palette,
  limits: limits,
  oob: oob,
  labels: labels,
)

#let _scale-manual(
  aesthetic,
  values: (),
  name: none,
  limits: none,
  oob: "drop",
  labels: auto,
) = (
  kind: "scale",
  aesthetic: aesthetic,
  type: "discrete",
  name: name,
  palette: values,
  limits: limits,
  oob: oob,
  labels: labels,
)

#let _scale-identity(aesthetic, name: none) = (
  kind: "scale",
  aesthetic: aesthetic,
  type: "identity",
  name: name,
)

#let _scale-viridis-d(
  aesthetic,
  option: "viridis",
  name: none,
  limits: none,
  oob: "drop",
  labels: auto,
) = (
  kind: "scale",
  aesthetic: aesthetic,
  type: "discrete",
  name: name,
  palette: viridis-mod.palette(option),
  limits: limits,
  oob: oob,
  labels: labels,
)

#let _scale-viridis-c(
  aesthetic,
  option: "viridis",
  name: none,
  limits: none,
  oob: "drop",
  breaks: auto,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: aesthetic,
  type: "continuous",
  name: name,
  palette: viridis-mod.palette(option),
  limits: limits,
  oob: oob,
  breaks: breaks,
  labels: labels,
)

#let _scale-viridis-b(
  aesthetic,
  option: "viridis",
  n-breaks: 5,
  breaks: auto,
  name: none,
  limits: none,
  oob: "drop",
  labels: auto,
) = (
  kind: "scale",
  aesthetic: aesthetic,
  type: "continuous",
  name: name,
  palette: viridis-mod.palette(option),
  limits: limits,
  oob: oob,
  labels: labels,
  binned: true,
  n-breaks: n-breaks,
  breaks: breaks,
)

#let _scale-brewer(
  aesthetic,
  palette: "Set1",
  name: none,
  limits: none,
  oob: "drop",
  labels: auto,
) = (
  kind: "scale",
  aesthetic: aesthetic,
  type: "discrete",
  name: name,
  palette: brewer-palette(palette),
  limits: limits,
  oob: oob,
  labels: labels,
)

#let _scale-okabe-ito(
  aesthetic,
  name: none,
  limits: none,
  oob: "drop",
  labels: auto,
) = _scale-discrete(
  aesthetic,
  palette: okabe-ito,
  name: name,
  limits: limits,
  oob: oob,
  labels: labels,
)

#let _scale-gradient(
  aesthetic,
  low: rgb("#132B43"),
  high: rgb("#56B1F7"),
  name: none,
  limits: none,
  oob: "drop",
  breaks: auto,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: aesthetic,
  type: "continuous",
  name: name,
  palette: (low, high),
  limits: limits,
  oob: oob,
  breaks: breaks,
  labels: labels,
)

#let _scale-gradient2(
  aesthetic,
  low: rgb("#1F77B4"),
  mid: rgb("#FFFFFF"),
  high: rgb("#D62728"),
  midpoint: 0,
  name: none,
  limits: none,
  oob: "drop",
  breaks: auto,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: aesthetic,
  type: "continuous",
  name: name,
  palette: (low, mid, high),
  midpoint: midpoint,
  limits: limits,
  oob: oob,
  breaks: breaks,
  labels: labels,
)

#let _scale-gradientn(
  aesthetic,
  colours: (),
  name: none,
  limits: none,
  oob: "drop",
  breaks: auto,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: aesthetic,
  type: "continuous",
  name: name,
  palette: colours,
  limits: limits,
  oob: oob,
  breaks: breaks,
  labels: labels,
)

#let _scale-grey(
  aesthetic,
  start: 0.2,
  end: 0.8,
  name: none,
  limits: none,
  oob: "drop",
  labels: auto,
) = (
  kind: "scale",
  aesthetic: aesthetic,
  type: "discrete",
  name: name,
  palette: grey-palette(10, start: start, end: end),
  limits: limits,
  oob: oob,
  labels: labels,
)

#let _scale-hue(
  aesthetic,
  hue: (15deg, 375deg),
  chroma: 100,
  luminance: 65,
  name: none,
  limits: none,
  oob: "drop",
  labels: auto,
) = (
  kind: "scale",
  aesthetic: aesthetic,
  type: "discrete",
  name: name,
  palette: hue-palette(12, h: hue, c: chroma, l: luminance),
  limits: limits,
  oob: oob,
  labels: labels,
)

#let _scale-distiller(
  aesthetic,
  palette: "Spectral",
  direction: 1,
  name: none,
  limits: none,
  oob: "drop",
  breaks: auto,
  labels: auto,
) = {
  let stops = brewer-palette(palette)
  if direction < 0 { stops = stops.rev() }
  (
    kind: "scale",
    aesthetic: aesthetic,
    type: "continuous",
    name: name,
    palette: stops,
    limits: limits,
    oob: oob,
    breaks: breaks,
    labels: labels,
  )
}

#let _scale-steps(
  aesthetic,
  low: rgb("#132B43"),
  high: rgb("#56B1F7"),
  n-breaks: 5,
  breaks: auto,
  name: none,
  limits: none,
  oob: "drop",
  labels: auto,
) = (
  kind: "scale",
  aesthetic: aesthetic,
  type: "continuous",
  name: name,
  palette: (low, high),
  limits: limits,
  oob: oob,
  labels: labels,
  binned: true,
  n-breaks: n-breaks,
  breaks: breaks,
)

#let _scale-steps2(
  aesthetic,
  low: rgb("#005A32"),
  mid: white,
  high: rgb("#A50026"),
  midpoint: 0,
  n-breaks: 5,
  breaks: auto,
  name: none,
  limits: none,
  oob: "drop",
  labels: auto,
) = (
  kind: "scale",
  aesthetic: aesthetic,
  type: "continuous",
  name: name,
  palette: (low, mid, high),
  midpoint: midpoint,
  limits: limits,
  oob: oob,
  labels: labels,
  binned: true,
  n-breaks: n-breaks,
  breaks: breaks,
)

#let _scale-stepsn(
  aesthetic,
  colours: (),
  n-breaks: 5,
  breaks: auto,
  name: none,
  limits: none,
  oob: "drop",
  labels: auto,
) = (
  kind: "scale",
  aesthetic: aesthetic,
  type: "continuous",
  name: name,
  palette: colours,
  limits: limits,
  oob: oob,
  labels: labels,
  binned: true,
  n-breaks: n-breaks,
  breaks: breaks,
)

#let _scale-fermenter(
  aesthetic,
  palette: "Spectral",
  n-breaks: 5,
  breaks: auto,
  direction: 1,
  name: none,
  limits: none,
  oob: "drop",
  labels: auto,
) = {
  let stops = brewer-palette(palette)
  if direction < 0 { stops = stops.rev() }
  (
    kind: "scale",
    aesthetic: aesthetic,
    type: "continuous",
    name: name,
    palette: stops,
    limits: limits,
    oob: oob,
    labels: labels,
    binned: true,
    n-breaks: n-breaks,
    breaks: breaks,
  )
}

// Alpha builders. Each binds the `alpha` aesthetic directly.

#let _alpha-continuous(
  name: none,
  range: (0.1, 1),
  limits: none,
  oob: "drop",
  breaks: auto,
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "alpha",
  type: "continuous",
  name: name,
  range: range,
  limits: limits,
  oob: oob,
  breaks: breaks,
  labels: labels,
)

#let _alpha-manual(
  values: (),
  name: none,
  limits: none,
  oob: "drop",
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "alpha",
  type: "discrete",
  name: name,
  palette: values,
  limits: limits,
  oob: oob,
  labels: labels,
)

#let _alpha-binned(
  n-breaks: 4,
  breaks: auto,
  range: (0.1, 1),
  name: none,
  limits: none,
  oob: "drop",
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "alpha",
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

#let _alpha-identity(name: none) = (
  kind: "scale",
  aesthetic: "alpha",
  type: "identity",
  name: name,
)
