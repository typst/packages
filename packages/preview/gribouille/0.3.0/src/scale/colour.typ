///! Colour and fill scales.
///!
///! `palette` accepts a Typst gradient, an array of colours, or `auto` for
///! the library default. Manual and viridis helpers are colocated in this
///! file for easy discovery.

#import "../utils/viridis.typ" as viridis-mod
#import "../utils/palette.typ": brewer-palette, okabe-ito
#import "../utils/colour.typ": grey-palette, hue-palette

// Internal builders shared by every `scale-colour-*` / `scale-fill-*` twin.
// Each takes the aesthetic name as the first positional argument and the
// per-family kwargs after; the `scale-colour-{name}` / `scale-fill-{name}`
// public wrappers forward `..args` so default values live exactly here.

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
)

#let _scale-steps2(
  aesthetic,
  low: rgb("#005A32"),
  mid: white,
  high: rgb("#A50026"),
  midpoint: 0,
  n-breaks: 5,
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
)

#let _scale-stepsn(
  aesthetic,
  colours: (),
  n-breaks: 5,
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
)

#let _scale-fermenter(
  aesthetic,
  palette: "Spectral",
  n-breaks: 5,
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
  )
}

/// Continuous colour scale mapping a numeric column to stroke colours.
///
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - palette: Colour source: a gradient, an array of colours, or `auto`.
/// - limits: Pair `(lo, hi)` clipping the trained domain, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - breaks: Array of break values for the legend, or `auto`.
/// - labels: Array of legend labels aligned with `breaks`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-colour-viridis-c`, `scale-colour-discrete`, `scale-fill-continuous`.
///
/// Default viridis ramp interpolating across the library's continuous palette.
///
/// ```typst
/// #let d = range(0, 12).map(i => (x: i, y: i, z: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "z"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-continuous(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Pin `limits` to clip the trained domain and render extremes at the palette endpoints.
///
/// ```typst
/// #let d = range(0, 12).map(i => (x: i, y: i, z: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "z"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-continuous(limits: (1, 4)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-colour-continuous(..args) = _scale-continuous("colour", ..args)

/// Discrete colour scale mapping categorical levels to stroke colours.
///
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - palette: Colour source: an array of colours, or `auto`.
/// - limits: Array of level names controlling order and inclusion, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - labels: Array of legend labels aligned with `limits`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-colour-manual`, `scale-colour-viridis-d`, `scale-fill-discrete`.
///
/// Default palette mapping three categories to the library's eight reserved discrete colours.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 2, sp: "a"),
///   (x: 2, y: 4, sp: "b"),
///   (x: 3, y: 3, sp: "c"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "sp"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-discrete(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Override `palette` with an explicit colour array to hand-pick the mapping order.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 2, sp: "a"),
///   (x: 2, y: 4, sp: "b"),
///   (x: 3, y: 3, sp: "c"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "sp"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-discrete(palette: (
///     rgb("#1b9e77"), rgb("#d95f02"), rgb("#7570b3"),
///   )),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Bind a colour-blind-friendly palette to penguin species and reorder the legend via `limits`.
///
/// ```typst
/// #plot(
///   data: penguins,
///   mapping: aes(x: "flipper-len", y: "body-mass", colour: "species"),
///   layers: (geom-point(size: 2pt, alpha: 0.85),),
///   scales: (scale-colour-discrete(
///     palette: (rgb("#0072B2"), rgb("#D55E00"), rgb("#009E73")),
///     limits: ("Adelie", "Chinstrap", "Gentoo"),
///   ),),
///   labs: labs(x: "Flipper Length (mm)", y: "Body Mass (g)", colour: "Species"),
///   width: 11cm,
///   height: 6cm,
/// )
/// ```
#let scale-colour-discrete(..args) = _scale-discrete("colour", ..args)

/// Continuous fill scale mapping a numeric column to fill colours.
///
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - palette: Colour source: a gradient, an array of colours, or `auto`.
/// - limits: Pair `(lo, hi)` clipping the trained domain, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - breaks: Array of break values for the legend, or `auto`.
/// - labels: Array of legend labels aligned with `breaks`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-fill-viridis-c`, `scale-fill-discrete`, `scale-colour-continuous`.
///
/// Default ramp filling bars by their numeric value.
///
/// ```typst
/// #let d = (
///   (grp: "a", y: 1),
///   (grp: "b", y: 2),
///   (grp: "c", y: 3),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "grp", y: "y", fill: "y"),
///   layers: (geom-col(),),
///   scales: (scale-fill-continuous(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// The default ramp shown as a continuous swatch via `geom-rect` over a sampled gradient.
///
/// ```typst
/// #let d = range(0, 16).map(i => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, z: i,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "z"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-continuous(),),
///   guides: guides(fill: none),
///   theme: theme-void(),
///   width: 10cm,
///   height: 1cm,
/// )
/// ```
#let scale-fill-continuous(..args) = _scale-continuous("fill", ..args)

/// Discrete fill scale mapping categorical levels to fill colours.
///
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - palette: Colour source: an array of colours, or `auto`.
/// - limits: Array of level names controlling order and inclusion, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - labels: Array of legend labels aligned with `limits`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-fill-manual`, `scale-fill-viridis-d`, `scale-colour-discrete`.
///
/// Default palette filling three bars from the library's reserved discrete colours.
///
/// ```typst
/// #let d = (
///   (grp: "a", y: 1),
///   (grp: "b", y: 2),
///   (grp: "c", y: 3),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "grp", y: "y", fill: "grp"),
///   layers: (geom-col(),),
///   scales: (scale-fill-discrete(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// The palette laid out as a swatch strip via `geom-rect`, one rectangle per level.
///
/// ```typst
/// #let levels = ("a", "b", "c", "d", "e", "f", "g", "h")
/// #let d = levels.enumerate().map(((i, k)) => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, k: k,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "k"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-discrete(),),
///   guides: guides(fill: none),
///   theme: theme-void(),
///   width: 8cm,
///   height: 1cm,
/// )
/// ```
#let scale-fill-discrete(..args) = _scale-discrete("fill", ..args)

/// Manual discrete colour scale: supply the colour array directly.
///
/// Colours cycle through `values` in the order levels appear, unless `limits` fixes the level order.
///
/// - values: Array of colours, one per level.
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - limits: Array of level names controlling order and inclusion, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - labels: Array of legend labels aligned with `limits`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-colour-discrete`, `scale-fill-manual`.
///
/// Hand-picked colour array applied to three categorical levels.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 2, sp: "a"),
///   (x: 2, y: 4, sp: "b"),
///   (x: 3, y: 3, sp: "c"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "sp"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-manual(values: (
///     rgb("#1b9e77"), rgb("#d95f02"), rgb("#7570b3"),
///   )),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// `limits` fixes the level order independently of how rows appear in the data, useful for stable legends across datasets.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 2, sp: "c"),
///   (x: 2, y: 4, sp: "a"),
///   (x: 3, y: 3, sp: "b"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "sp"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-manual(
///     values: (rgb("#1b9e77"), rgb("#d95f02"), rgb("#7570b3")),
///     limits: ("a", "b", "c"),
///   ),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-colour-manual(..args) = _scale-manual("colour", ..args)

/// Manual discrete fill scale: supply the colour array directly.
///
/// Colours cycle through `values` in the order levels appear, unless `limits` fixes the level order.
///
/// - values: Array of colours, one per level.
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - limits: Array of level names controlling order and inclusion, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - labels: Array of legend labels aligned with `limits`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-fill-discrete`, `scale-colour-manual`.
///
/// Hand-picked colour array applied to three categorical levels.
///
/// ```typst
/// #let d = (
///   (grp: "a", y: 1),
///   (grp: "b", y: 2),
///   (grp: "c", y: 3),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "grp", y: "y", fill: "grp"),
///   layers: (geom-col(),),
///   scales: (scale-fill-manual(values: (
///     rgb("#66c2a5"), rgb("#fc8d62"), rgb("#8da0cb"),
///   )),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// The same array shown as a swatch strip via `geom-rect`.
///
/// ```typst
/// #let pal = (rgb("#66c2a5"), rgb("#fc8d62"), rgb("#8da0cb"))
/// #let d = pal.enumerate().map(((i, _)) => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, k: str(i),
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "k"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-manual(values: pal),),
///   guides: guides(fill: none),
///   theme: theme-void(),
///   width: 6cm,
///   height: 1cm,
/// )
/// ```
#let scale-fill-manual(..args) = _scale-manual("fill", ..args)

/// Discrete viridis colour scale.
///
/// `option` selects between `"viridis"`, `"magma"`, `"plasma"`, `"inferno"`, and `"cividis"`.
///
/// - option: Palette name: `"viridis"`, `"magma"`, `"plasma"`, `"inferno"`, or `"cividis"`.
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - limits: Array of level names controlling order and inclusion, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - labels: Array of legend labels aligned with `limits`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-colour-viridis-c`, `scale-colour-viridis-b`, `scale-fill-viridis-d`.
///
/// Plasma option of the viridis family applied to four categories.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 2, sp: "a"),
///   (x: 2, y: 4, sp: "b"),
///   (x: 3, y: 3, sp: "c"),
///   (x: 4, y: 5, sp: "d"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "sp"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-viridis-d(option: "plasma"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Switching `option` to `"cividis"` selects the colour-blind safe alternative.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 2, sp: "a"),
///   (x: 2, y: 4, sp: "b"),
///   (x: 3, y: 3, sp: "c"),
///   (x: 4, y: 5, sp: "d"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "sp"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-viridis-d(option: "cividis"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-colour-viridis-d(..args) = _scale-viridis-d("colour", ..args)

/// Continuous viridis colour scale.
///
/// `option` selects between `"viridis"`, `"magma"`, `"plasma"`, `"inferno"`, and `"cividis"`.
///
/// - option: Palette name: `"viridis"`, `"magma"`, `"plasma"`, `"inferno"`, or `"cividis"`.
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - limits: Pair `(lo, hi)` clipping the trained domain, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - breaks: Array of break values for the legend, or `auto`.
/// - labels: Array of legend labels aligned with `breaks`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-colour-viridis-d`, `scale-colour-viridis-b`, `scale-fill-viridis-c`.
///
/// Magma option applied to a continuous numeric column.
///
/// ```typst
/// #let d = range(0, 12).map(i => (x: i, y: i, z: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "z"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-viridis-c(option: "magma"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Default `"viridis"` ramp with `limits` clipping the lower tail.
///
/// ```typst
/// #let d = range(0, 12).map(i => (x: i, y: i, z: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "z"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-viridis-c(limits: (2, 6)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-colour-viridis-c(..args) = _scale-viridis-c("colour", ..args)

/// Binned viridis colour scale.
///
/// Partitions the continuous domain into `n-breaks` equal segments, each coloured from the chosen viridis palette.
///
/// - option: Palette name: `"viridis"`, `"magma"`, `"plasma"`, `"inferno"`, or `"cividis"`.
/// - n-breaks: Number of bins to partition the domain into.
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - limits: Pair `(lo, hi)` clipping the trained domain, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - labels: Array of legend labels aligned with the bins, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-colour-viridis-c`, `scale-colour-viridis-d`, `scale-fill-viridis-b`.
///
/// Four equal-width bins coloured from the default viridis ramp.
///
/// ```typst
/// #let d = range(0, 12).map(i => (x: i, y: i, z: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "z"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-viridis-b(n-breaks: 4),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Bumping `n-breaks` and switching to the inferno option produces a finer-grained banded scale.
///
/// ```typst
/// #let d = range(0, 12).map(i => (x: i, y: i, z: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "z"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-viridis-b(option: "inferno", n-breaks: 8),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-colour-viridis-b(..args) = _scale-viridis-b("colour", ..args)

/// Discrete viridis fill scale.
///
/// `option` selects between `"viridis"`, `"magma"`, `"plasma"`, `"inferno"`, and `"cividis"`.
///
/// - option: Palette name: `"viridis"`, `"magma"`, `"plasma"`, `"inferno"`, or `"cividis"`.
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - limits: Array of level names controlling order and inclusion, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - labels: Array of legend labels aligned with `limits`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-fill-viridis-c`, `scale-fill-viridis-b`, `scale-colour-viridis-d`.
///
/// Cividis option filling four categorical bars.
///
/// ```typst
/// #let d = (
///   (grp: "a", y: 1),
///   (grp: "b", y: 2),
///   (grp: "c", y: 3),
///   (grp: "d", y: 4),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "grp", y: "y", fill: "grp"),
///   layers: (geom-col(),),
///   scales: (scale-fill-viridis-d(option: "cividis"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Each viridis option laid out as a swatch strip via `geom-rect`.
///
/// ```typst
/// #let opts = ("viridis", "magma", "plasma", "inferno", "cividis")
/// #let d = opts.enumerate().map(((i, k)) => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, k: k,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "k"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-viridis-d(option: "magma"),),
///   guides: guides(fill: none),
///   theme: theme-void(),
///   width: 6cm,
///   height: 1cm,
/// )
/// ```
#let scale-fill-viridis-d(..args) = _scale-viridis-d("fill", ..args)

/// Continuous viridis fill scale.
///
/// `option` selects between `"viridis"`, `"magma"`, `"plasma"`, `"inferno"`, and `"cividis"`.
///
/// - option: Palette name: `"viridis"`, `"magma"`, `"plasma"`, `"inferno"`, or `"cividis"`.
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - limits: Pair `(lo, hi)` clipping the trained domain, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - breaks: Array of break values for the legend, or `auto`.
/// - labels: Array of legend labels aligned with `breaks`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-fill-viridis-d`, `scale-fill-viridis-b`, `scale-colour-viridis-c`.
///
/// Default viridis ramp filling bars by their numeric value.
///
/// ```typst
/// #let d = range(0, 12).map(i => (grp: str(i), y: i + 1))
/// #plot(
///   data: d,
///   mapping: aes(x: "grp", y: "y", fill: "y"),
///   layers: (geom-col(),),
///   scales: (scale-fill-viridis-c(option: "viridis"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// The viridis ramp shown as a continuous swatch via `geom-rect`.
///
/// ```typst
/// #let d = range(0, 16).map(i => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, z: i,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "z"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-viridis-c(),),
///   guides: guides(fill: none),
///   theme: theme-void(),
///   width: 10cm,
///   height: 1cm,
/// )
/// ```
#let scale-fill-viridis-c(..args) = _scale-viridis-c("fill", ..args)

/// Colour scale that uses each row's value as the stroke colour directly.
///
/// The mapped column must hold values acceptable to Typst's `rgb()` (e.g., `"#ff0000"`) or already be `color` values. No legend is drawn because the column carries the visual outcome verbatim.
///
/// - name: Legend title. Identity scales draw no legend, but the title is carried for downstream consumers that may surface it.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-colour-manual`, `scale-fill-identity`.
///
/// Hex strings carried straight through to point strokes; no legend is drawn.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 2, c: "#1b9e77"),
///   (x: 2, y: 4, c: "#d95f02"),
///   (x: 3, y: 3, c: "#7570b3"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "c"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-identity(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-colour-identity(..args) = _scale-identity("colour", ..args)

/// Fill scale that uses each row's value as the fill colour directly.
///
/// Values must be hex strings or `color` values; see `scale-colour-identity`.
///
/// - name: Legend title. Identity scales draw no legend.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-fill-manual`, `scale-colour-identity`.
///
/// Per-row hex strings used as fills, with `geom-rect` drawing a custom swatch from arbitrary colours.
///
/// ```typst
/// #let d = (
///   (xmin: 0, xmax: 1, ymin: 0, ymax: 1, c: "#1b9e77"),
///   (xmin: 1, xmax: 2, ymin: 0, ymax: 1, c: "#d95f02"),
///   (xmin: 2, xmax: 3, ymin: 0, ymax: 1, c: "#7570b3"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "c"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-identity(),),
///   theme: theme-void(),
///   width: 6cm,
///   height: 1cm,
/// )
/// ```
#let scale-fill-identity(..args) = _scale-identity("fill", ..args)

/// Binned viridis fill scale.
///
/// Partitions the continuous domain into `n-breaks` equal segments, each coloured from the chosen viridis palette.
///
/// - option: Palette name: `"viridis"`, `"magma"`, `"plasma"`, `"inferno"`, or `"cividis"`.
/// - n-breaks: Number of bins to partition the domain into.
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - limits: Pair `(lo, hi)` clipping the trained domain, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - labels: Array of legend labels aligned with the bins, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-fill-viridis-c`, `scale-fill-viridis-d`, `scale-colour-viridis-b`.
///
/// Default viridis ramp quantised into four bins for a banded fill.
///
/// ```typst
/// #let d = range(0, 12).map(i => (grp: str(i), y: i + 1))
/// #plot(
///   data: d,
///   mapping: aes(x: "grp", y: "y", fill: "y"),
///   layers: (geom-col(),),
///   scales: (scale-fill-viridis-b(n-breaks: 4),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// The same ramp shown as a banded swatch via `geom-rect`.
///
/// ```typst
/// #let d = range(0, 12).map(i => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, z: i,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "z"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-viridis-b(option: "plasma", n-breaks: 6),),
///   guides: guides(fill: none),
///   theme: theme-void(),
///   width: 8cm,
///   height: 1cm,
/// )
/// ```
#let scale-fill-viridis-b(..args) = _scale-viridis-b("fill", ..args)

/// Discrete ColorBrewer colour scale.
///
/// `palette` selects a named ColorBrewer palette such as `"Set1"`, `"Dark2"`, or `"Spectral"`. Categorical levels are mapped to colours in the order they first appear in the data.
///
/// - palette: ColorBrewer palette name (qualitative, sequential, or diverging).
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - limits: Array of level names controlling order and inclusion, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - labels: Array of legend labels aligned with `limits`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-fill-brewer`, `scale-colour-discrete`.
///
/// Set1 palette mapping three categorical levels to bold qualitative hues.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 2, sp: "a"),
///   (x: 2, y: 4, sp: "b"),
///   (x: 3, y: 3, sp: "c"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "sp"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-brewer(palette: "Set1"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Switching to the diverging Spectral palette suits ordered categories with a meaningful midpoint.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 2, sp: "low"),
///   (x: 2, y: 3, sp: "mid"),
///   (x: 3, y: 4, sp: "high"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "sp"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-brewer(
///     palette: "Spectral",
///     limits: ("low", "mid", "high"),
///   ),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-colour-brewer(..args) = _scale-brewer("colour", ..args)

/// Discrete ColorBrewer fill scale.
///
/// Fill counterpart of `scale-colour-brewer`. Same palette names apply.
///
/// - palette: ColorBrewer palette name (qualitative, sequential, or diverging).
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - limits: Array of level names controlling order and inclusion, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - labels: Array of legend labels aligned with `limits`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-colour-brewer`, `scale-fill-discrete`.
///
/// Set1 palette filling categorical bars.
///
/// ```typst
/// #let d = (
///   (grp: "a", y: 1),
///   (grp: "b", y: 2),
///   (grp: "c", y: 3),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "grp", y: "y", fill: "grp"),
///   layers: (geom-col(),),
///   scales: (scale-fill-brewer(palette: "Set1"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// The Spectral palette laid out as a swatch strip via `geom-rect`.
///
/// ```typst
/// #let levels = ("a", "b", "c", "d", "e", "f", "g")
/// #let d = levels.enumerate().map(((i, k)) => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, k: k,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "k"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-brewer(palette: "Spectral"),),
///   guides: guides(fill: none),
///   theme: theme-void(),
///   width: 8cm,
///   height: 1cm,
/// )
/// ```
#let scale-fill-brewer(..args) = _scale-brewer("fill", ..args)

/// Discrete Okabe-Ito colour-vision-deficiency-safe colour scale.
///
/// Maps categorical levels to the eight-colour Okabe-Ito palette (Wong 2011, Nature Methods) in the order they first appear in the data. This palette is also the library default for unmapped discrete colour aesthetics; use this helper when you want to opt in explicitly or set `name`, `limits`, or `labels`.
///
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - limits: Array of level names controlling order and inclusion, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - labels: Array of legend labels aligned with `limits`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-fill-okabe-ito`, `scale-colour-brewer`, `scale-colour-discrete`.
///
/// Three categorical levels mapped to the first three Okabe-Ito hues.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 2, sp: "a"),
///   (x: 2, y: 4, sp: "b"),
///   (x: 3, y: 3, sp: "c"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "sp"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-okabe-ito(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-colour-okabe-ito(..args) = _scale-okabe-ito("colour", ..args)

/// Discrete Okabe-Ito colour-vision-deficiency-safe fill scale.
///
/// Fill counterpart of `scale-colour-okabe-ito`. Also the library default for unmapped discrete fill aesthetics.
///
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - limits: Array of level names controlling order and inclusion, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - labels: Array of legend labels aligned with `limits`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-colour-okabe-ito`, `scale-fill-brewer`, `scale-fill-discrete`.
///
/// Categorical bars filled with the Okabe-Ito palette.
///
/// ```typst
/// #let d = (
///   (grp: "a", y: 1),
///   (grp: "b", y: 2),
///   (grp: "c", y: 3),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "grp", y: "y", fill: "grp"),
///   layers: (geom-col(),),
///   scales: (scale-fill-okabe-ito(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-fill-okabe-ito(..args) = _scale-okabe-ito("fill", ..args)

/// Continuous two-stop colour gradient.
///
/// Linearly interpolates between `low` and `high` across the trained domain. Defaults to a blue ramp.
///
/// - low: Colour for the low end of the domain.
/// - high: Colour for the high end of the domain.
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - limits: Pair `(lo, hi)` clipping the trained domain, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - breaks: Array of break values for the legend, or `auto`.
/// - labels: Array of legend labels aligned with `breaks`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-colour-gradient2`, `scale-colour-gradientn`, `scale-fill-gradient`.
///
/// Default low-to-high blue ramp.
///
/// ```typst
/// #let d = range(0, 12).map(i => (x: i, y: i, z: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "z"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-gradient(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Custom two-stop ramp passing explicit `low` and `high` colours.
///
/// ```typst
/// #let d = range(0, 12).map(i => (x: i, y: i, z: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "z"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-gradient(
///     low: rgb("#fee5d9"),
///     high: rgb("#a50f15"),
///   ),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-colour-gradient(..args) = _scale-gradient("colour", ..args)

/// Continuous diverging colour gradient through a midpoint.
///
/// Interpolates `low` to `mid` for values at or below `midpoint`, and `mid` to `high` for values at or above it.
///
/// - low: Colour for values far below `midpoint`.
/// - mid: Colour at `midpoint`.
/// - high: Colour for values far above `midpoint`.
/// - midpoint: Value at which the palette transitions through `mid`.
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - limits: Pair `(lo, hi)` clipping the trained domain, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - breaks: Array of break values for the legend, or `auto`.
/// - labels: Array of legend labels aligned with `breaks`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-colour-gradient`, `scale-colour-gradientn`, `scale-fill-gradient2`.
///
/// Default diverging ramp pivoting at zero, useful for signed numeric values.
///
/// ```typst
/// #let d = range(-5, 6).map(i => (x: i, y: i, z: i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "z"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-gradient2(midpoint: 0),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Shift `midpoint` to centre the ramp around a non-zero baseline.
///
/// ```typst
/// #let d = range(0, 11).map(i => (x: i, y: i, z: i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "z"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-gradient2(
///     low: rgb("#1a9850"),
///     mid: rgb("#ffffbf"),
///     high: rgb("#d73027"),
///     midpoint: 5,
///   ),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-colour-gradient2(..args) = _scale-gradient2("colour", ..args)

/// Continuous n-stop colour gradient.
///
/// Walks `colours` as a sequence of stops and linearly interpolates between adjacent stops. Useful for ramps that require more than two anchor colours (for example a ColorBrewer palette used as a continuous ramp).
///
/// - colours: Array of two or more colours.
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - limits: Pair `(lo, hi)` clipping the trained domain, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - breaks: Array of break values for the legend, or `auto`.
/// - labels: Array of legend labels aligned with `breaks`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-colour-gradient`, `scale-colour-gradient2`, `scale-fill-gradientn`.
///
/// Three-stop ramp interpolating green-yellow-red across the domain.
///
/// ```typst
/// #let d = range(0, 12).map(i => (x: i, y: i, z: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "z"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-gradientn(colours: (
///     rgb("#1a9850"), rgb("#ffffbf"), rgb("#d73027"),
///   )),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Feeding a brewer palette into `scale-colour-gradientn` lifts a discrete palette into a continuous ramp.
///
/// ```typst
/// #let d = range(0, 12).map(i => (x: i, y: i, z: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "z"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-gradientn(
///     colours: brewer-palette("RdYlBu"),
///   ),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-colour-gradientn(..args) = _scale-gradientn("colour", ..args)

/// Continuous two-stop fill gradient.
///
/// Fill counterpart of `scale-colour-gradient`.
///
/// - low: Colour for the low end of the domain.
/// - high: Colour for the high end of the domain.
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - limits: Pair `(lo, hi)` clipping the trained domain, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - breaks: Array of break values for the legend, or `auto`.
/// - labels: Array of legend labels aligned with `breaks`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-colour-gradient`, `scale-fill-gradient2`, `scale-fill-gradientn`.
///
/// Custom two-stop ramp shown as a continuous swatch via `geom-rect`.
///
/// ```typst
/// #let d = range(0, 16).map(i => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, z: i,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "z"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-gradient(
///     low: rgb("#fee5d9"),
///     high: rgb("#a50f15"),
///   ),),
///   guides: guides(fill: none),
///   theme: theme-void(),
///   width: 10cm,
///   height: 1cm,
/// )
/// ```
#let scale-fill-gradient(..args) = _scale-gradient("fill", ..args)

/// Continuous diverging fill gradient through a midpoint.
///
/// Fill counterpart of `scale-colour-gradient2`.
///
/// - low: Colour for values far below `midpoint`.
/// - mid: Colour at `midpoint`.
/// - high: Colour for values far above `midpoint`.
/// - midpoint: Value at which the palette transitions through `mid`.
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - limits: Pair `(lo, hi)` clipping the trained domain, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - breaks: Array of break values for the legend, or `auto`.
/// - labels: Array of legend labels aligned with `breaks`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-colour-gradient2`, `scale-fill-gradient`, `scale-fill-gradientn`.
///
/// Diverging ramp pivoting at zero, shown as a swatch via `geom-rect`.
///
/// ```typst
/// #let d = range(-7, 8).map(i => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, z: i,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "z"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-gradient2(midpoint: 0),),
///   guides: guides(fill: none),
///   theme: theme-void(),
///   width: 10cm,
///   height: 1cm,
/// )
/// ```
#let scale-fill-gradient2(..args) = _scale-gradient2("fill", ..args)

/// Continuous n-stop fill gradient.
///
/// Fill counterpart of `scale-colour-gradientn`.
///
/// - colours: Array of two or more colours.
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - limits: Pair `(lo, hi)` clipping the trained domain, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - breaks: Array of break values for the legend, or `auto`.
/// - labels: Array of legend labels aligned with `breaks`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-colour-gradientn`, `scale-fill-gradient`, `scale-fill-gradient2`.
///
/// Three-stop ramp shown as a continuous swatch via `geom-rect`.
///
/// ```typst
/// #let d = range(0, 16).map(i => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, z: i,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "z"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-gradientn(colours: (
///     rgb("#1a9850"), rgb("#ffffbf"), rgb("#d73027"),
///   )),),
///   guides: guides(fill: none),
///   theme: theme-void(),
///   width: 10cm,
///   height: 1cm,
/// )
/// ```
#let scale-fill-gradientn(..args) = _scale-gradientn("fill", ..args)

/// Discrete grey colour scale.
///
/// Generates `n` evenly-spaced `luma` colours from `start` (darker) to `end` (lighter), each in `[0, 1]` where 0 is black and 1 is white.
///
/// - start: Luminance for the first level, in `[0, 1]`.
/// - end: Luminance for the last level, in `[0, 1]`.
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - limits: Array of level names controlling order and inclusion, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - labels: Array of legend labels aligned with `limits`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-fill-grey`, `scale-colour-discrete`.
///
/// Default grey ramp from dark to light spread across three levels.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 2, sp: "a"),
///   (x: 2, y: 4, sp: "b"),
///   (x: 3, y: 3, sp: "c"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "sp"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-grey(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Narrowing `start` and `end` constrains the ramp to a darker range for tighter contrast.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 2, sp: "a"),
///   (x: 2, y: 4, sp: "b"),
///   (x: 3, y: 3, sp: "c"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "sp"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-grey(start: 0.1, end: 0.5),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-colour-grey(..args) = _scale-grey("colour", ..args)

/// Discrete grey fill scale.
///
/// Fill counterpart of `scale-colour-grey`.
///
/// - start: Luminance for the first level, in `[0, 1]`.
/// - end: Luminance for the last level, in `[0, 1]`.
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - limits: Array of level names controlling order and inclusion, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - labels: Array of legend labels aligned with `limits`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-colour-grey`, `scale-fill-discrete`.
///
/// Default grey ramp shown as a swatch strip via `geom-rect`.
///
/// ```typst
/// #let levels = ("a", "b", "c", "d", "e", "f")
/// #let d = levels.enumerate().map(((i, k)) => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, k: k,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "k"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-grey(),),
///   guides: guides(fill: none),
///   theme: theme-void(),
///   width: 8cm,
///   height: 1cm,
/// )
/// ```
#let scale-fill-grey(..args) = _scale-grey("fill", ..args)

/// Discrete equally-spaced hue colour scale.
///
/// Steps `n` hues across the angular range `hue` in OKLCh space, picking chroma and luminance from `chroma` and `luminance`. Defaults to `hue: (15deg, 375deg)`, `chroma: 100`, `luminance: 65`.
///
/// OKLCh is used as a perceptually uniform near-equivalent of HCL, which Typst does not expose directly. The first colour sits at `hue.at(0)` and successive colours step by `(end - start) / n`, so the endpoint is excluded and the wheel never duplicates a hue when `start` and `end` differ by a full turn.
///
/// - hue: Pair `(start, end)` of hue angles.
/// - chroma: Chroma in `[0, 100]`.
/// - luminance: Luminance in `[0, 100]`.
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - limits: Array of level names controlling order and inclusion, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - labels: Array of legend labels aligned with `limits`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-fill-hue`, `scale-colour-discrete`.
///
/// Default hue wheel mapping four levels to evenly-spaced colours.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 2, sp: "a"),
///   (x: 2, y: 4, sp: "b"),
///   (x: 3, y: 3, sp: "c"),
///   (x: 4, y: 5, sp: "d"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "sp"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-hue(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Lower `chroma` and `luminance` yield a muted, pastel-like palette.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 2, sp: "a"),
///   (x: 2, y: 4, sp: "b"),
///   (x: 3, y: 3, sp: "c"),
///   (x: 4, y: 5, sp: "d"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "sp"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-hue(chroma: 50, luminance: 80),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-colour-hue(..args) = _scale-hue("colour", ..args)

/// Discrete equally-spaced hue fill scale.
///
/// Fill counterpart of `scale-colour-hue`.
///
/// - hue: Pair `(start, end)` of hue angles.
/// - chroma: Chroma in `[0, 100]`.
/// - luminance: Luminance in `[0, 100]`.
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - limits: Array of level names controlling order and inclusion, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - labels: Array of legend labels aligned with `limits`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-colour-hue`, `scale-fill-discrete`.
///
/// Default hue wheel shown as a swatch strip via `geom-rect`.
///
/// ```typst
/// #let levels = ("a", "b", "c", "d", "e", "f", "g", "h")
/// #let d = levels.enumerate().map(((i, k)) => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, k: k,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "k"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-hue(),),
///   guides: guides(fill: none),
///   theme: theme-void(),
///   width: 8cm,
///   height: 1cm,
/// )
/// ```
#let scale-fill-hue(..args) = _scale-hue("fill", ..args)

/// Continuous ColorBrewer colour scale.
///
/// Looks up a Brewer palette by name and interpolates linearly across its stops as a continuous ramp. `direction` flips the palette: `1` keeps the canonical order, `-1` reverses it.
///
/// - palette: ColorBrewer palette name (sequential or diverging works best).
/// - direction: `1` for canonical order, `-1` for reversed.
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - limits: Pair `(lo, hi)` clipping the trained domain, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - breaks: Array of break values for the legend, or `auto`.
/// - labels: Array of legend labels aligned with `breaks`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-fill-distiller`, `scale-colour-gradientn`, `scale-colour-brewer`.
///
/// Spectral palette interpolated as a continuous ramp.
///
/// ```typst
/// #let d = range(0, 12).map(i => (x: i, y: i, z: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "z"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-distiller(palette: "Spectral"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Set `direction: -1` to reverse the palette so high values map to the canonical low end.
///
/// ```typst
/// #let d = range(0, 12).map(i => (x: i, y: i, z: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "z"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-distiller(palette: "Blues", direction: -1),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-colour-distiller(..args) = _scale-distiller("colour", ..args)

/// Continuous alpha (opacity) scale mapping a numeric column to opacities.
///
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - range: Pair `(lo, hi)` bounding the output opacity, each in `[0, 1]`.
/// - limits: Pair `(lo, hi)` clipping the trained domain, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - breaks: Array of break values for the legend, or `auto`.
/// - labels: Array of legend labels aligned with `breaks`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-alpha-identity`, `scale-colour-continuous`.
///
/// Linear opacity mapping with a wide `range` to fade points from near-transparent to fully opaque.
///
/// ```typst
/// #let d = range(0, 12).map(i => (x: i, y: i, w: i + 1))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", alpha: "w"),
///   layers: (geom-point(size: 4pt),),
///   scales: (scale-alpha-continuous(range: (0.1, 1)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// A narrower `range` keeps every point visible while still encoding magnitude.
///
/// ```typst
/// #let d = range(0, 12).map(i => (x: i, y: i, w: i + 1))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", alpha: "w"),
///   layers: (geom-point(size: 4pt),),
///   scales: (scale-alpha-continuous(range: (0.4, 0.9)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-alpha-continuous(
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

/// Manual discrete alpha scale: supply a per-level array of opacities.
///
/// Use when each level should map to a chosen opacity in `[0, 1]` rather than the evenly-spaced range that the discrete inference would assign.
///
/// - values: Array of opacities in `[0, 1]`, one per level (in `limits` order when set, otherwise in first-seen order).
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - limits: Array of level names controlling order and inclusion, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - labels: Array of legend labels aligned with `limits`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-alpha-continuous`, `scale-alpha-identity`.
///
/// Three groups assigned dim/medium/full opacity.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 1, g: "a"), (x: 2, y: 2, g: "a"),
///   (x: 1, y: 2, g: "b"), (x: 2, y: 3, g: "b"),
///   (x: 1, y: 3, g: "c"), (x: 2, y: 4, g: "c"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", alpha: "g", group: "g"),
///   layers: (geom-point(size: 4pt, fill: rgb("#1f77b4")),),
///   scales: (scale-alpha-manual(values: (0.2, 0.55, 1)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-alpha-manual(
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

/// Binned continuous alpha scale.
///
/// Maps a numeric column onto an opacity range, but groups values into `n-breaks` bins for the legend. The mapping stays continuous; only the legend swatches snap to bin centres.
///
/// - n-breaks: Number of legend bins.
/// - range: Pair `(min, max)` bounding the output opacity in `[0, 1]`.
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - limits: Pair `(lo, hi)` clipping the trained domain, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - labels: Array of legend labels aligned with `breaks`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-alpha-continuous`, `scale-linewidth-binned`.
///
/// Opacity binned into four legend swatches.
///
/// ```typst
/// #let d = range(0, 10).map(i => (x: i, y: i, w: i + 1))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", alpha: "w"),
///   layers: (geom-point(size: 4pt, fill: rgb("#1f77b4")),),
///   scales: (scale-alpha-binned(n-breaks: 4, range: (0.2, 1)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-alpha-binned(
  n-breaks: 4,
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
  breaks: auto,
  labels: labels,
  binned: true,
  n-breaks: n-breaks,
)

/// Alpha scale that uses each row's value as the opacity directly.
///
/// Values are clamped to `[0, 1]` before being applied to the colour. No legend is drawn because the column carries the visual outcome verbatim.
///
/// - name: Legend title. Identity scales draw no legend.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-alpha-continuous`, `scale-colour-identity`.
///
/// Per-row opacity carried straight through to the point fills.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 2, w: 0.2),
///   (x: 2, y: 3, w: 0.5),
///   (x: 3, y: 4, w: 0.8),
///   (x: 4, y: 5, w: 1.0),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", alpha: "w"),
///   layers: (geom-point(size: 6pt, fill: rgb("#1f77b4")),),
///   scales: (scale-alpha-identity(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-alpha-identity(name: none) = (
  kind: "scale",
  aesthetic: "alpha",
  type: "identity",
  name: name,
)

/// Continuous ColorBrewer fill scale.
///
/// Fill counterpart of `scale-colour-distiller`.
///
/// - palette: ColorBrewer palette name (sequential or diverging works best).
/// - direction: `1` for canonical order, `-1` for reversed.
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - limits: Pair `(lo, hi)` clipping the trained domain, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - breaks: Array of break values for the legend, or `auto`.
/// - labels: Array of legend labels aligned with `breaks`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-colour-distiller`, `scale-fill-gradientn`, `scale-fill-brewer`.
///
/// Spectral palette interpolated across a continuous swatch via `geom-rect`.
///
/// ```typst
/// #let d = range(0, 16).map(i => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, z: i,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "z"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-distiller(palette: "Spectral"),),
///   guides: guides(fill: none),
///   theme: theme-void(),
///   width: 10cm,
///   height: 1cm,
/// )
/// ```
#let scale-fill-distiller(..args) = _scale-distiller("fill", ..args)

/// Binned two-stop colour gradient.
///
/// Quantises the trained continuous domain into `n-breaks` equal-width bins and fills each bin with a single colour drawn from the `low` to `high` ramp. Defaults to a blue ramp.
///
/// - low: Colour for the low end of the domain.
/// - high: Colour for the high end of the domain.
/// - n-breaks: Number of bins to partition the domain into.
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - limits: Pair `(lo, hi)` clipping the trained domain, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - labels: Array of legend labels aligned with the bins, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-colour-steps2`, `scale-colour-stepsn`, `scale-fill-steps`.
///
/// Five-bin discretisation of the default low-to-high blue ramp.
///
/// ```typst
/// #let d = range(0, 12).map(i => (x: i, y: i, z: i * 1.0))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "z"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-steps(n-breaks: 5),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Custom `low`/`high` colours discretised into eight bins.
///
/// ```typst
/// #let d = range(0, 12).map(i => (x: i, y: i, z: i * 1.0))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "z"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-steps(
///     low: rgb("#fee5d9"),
///     high: rgb("#a50f15"),
///     n-breaks: 8,
///   ),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-colour-steps(..args) = _scale-steps("colour", ..args)

/// Binned diverging colour gradient through a midpoint.
///
/// Quantises the trained continuous domain into `n-breaks` equal-width bins using a three-stop palette that pivots through `mid` at `midpoint`.
///
/// - low: Colour for values far below `midpoint`.
/// - mid: Colour at `midpoint`.
/// - high: Colour for values far above `midpoint`.
/// - midpoint: Value at which the palette transitions through `mid`.
/// - n-breaks: Number of bins to partition the domain into.
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - limits: Pair `(lo, hi)` clipping the trained domain, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - labels: Array of legend labels aligned with the bins, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-colour-steps`, `scale-colour-stepsn`, `scale-fill-steps2`.
///
/// Six-bin diverging discretisation pivoting at zero.
///
/// ```typst
/// #let d = range(-5, 6).map(i => (x: i, y: i, z: i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "z"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-steps2(midpoint: 0, n-breaks: 6),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Shift `midpoint` and adjust the three stops to highlight a non-zero pivot.
///
/// ```typst
/// #let d = range(0, 11).map(i => (x: i, y: i, z: i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "z"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-steps2(
///     low: rgb("#1a9850"),
///     mid: rgb("#ffffbf"),
///     high: rgb("#d73027"),
///     midpoint: 5,
///     n-breaks: 8,
///   ),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-colour-steps2(..args) = _scale-steps2("colour", ..args)

/// Binned n-stop colour gradient.
///
/// Walks `colours` as a sequence of stops and quantises the lookup into `n-breaks` equal-width bins.
///
/// - colours: Array of two or more colours.
/// - n-breaks: Number of bins to partition the domain into.
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - limits: Pair `(lo, hi)` clipping the trained domain, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - labels: Array of legend labels aligned with the bins, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-colour-steps`, `scale-colour-steps2`, `scale-fill-stepsn`.
///
/// Three-stop ramp discretised into six bins.
///
/// ```typst
/// #let d = range(0, 12).map(i => (x: i, y: i, z: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "z"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-stepsn(colours: (
///     rgb("#1a9850"), rgb("#ffffbf"), rgb("#d73027"),
///   ), n-breaks: 6),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Reuse a brewer palette as the stop list to fold a discrete palette into a banded continuous scale.
///
/// ```typst
/// #let d = range(0, 12).map(i => (x: i, y: i, z: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "z"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-stepsn(
///     colours: brewer-palette("YlOrRd"),
///     n-breaks: 5,
///   ),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-colour-stepsn(..args) = _scale-stepsn("colour", ..args)

/// Binned ColorBrewer colour scale.
///
/// Looks up a Brewer palette by name, interpolates across its stops, and quantises the lookup into `n-breaks` equal-width bins. `direction` flips the palette: `1` keeps the canonical order, `-1` reverses it.
///
/// - palette: ColorBrewer palette name (sequential or diverging works best).
/// - n-breaks: Number of bins to partition the domain into.
/// - direction: `1` for canonical order, `-1` for reversed.
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - limits: Pair `(lo, hi)` clipping the trained domain, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - labels: Array of legend labels aligned with the bins, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-colour-distiller`, `scale-fill-fermenter`.
///
/// Spectral palette quantised into five bins.
///
/// ```typst
/// #let d = range(0, 12).map(i => (x: i, y: i, z: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "z"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-fermenter(palette: "Spectral", n-breaks: 5),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Sequential blues palette reversed via `direction: -1` for an inverted banding.
///
/// ```typst
/// #let d = range(0, 12).map(i => (x: i, y: i, z: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "z"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-colour-fermenter(
///     palette: "Blues",
///     direction: -1,
///     n-breaks: 7,
///   ),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-colour-fermenter(..args) = _scale-fermenter("colour", ..args)

/// Binned two-stop fill gradient.
///
/// Fill counterpart of `scale-colour-steps`.
///
/// - low: Colour for the low end of the domain.
/// - high: Colour for the high end of the domain.
/// - n-breaks: Number of bins to partition the domain into.
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - limits: Pair `(lo, hi)` clipping the trained domain, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - labels: Array of legend labels aligned with the bins, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-colour-steps`, `scale-fill-steps2`, `scale-fill-stepsn`.
///
/// Five-bin discretised fill ramp shown as a swatch via `geom-rect`.
///
/// ```typst
/// #let d = range(0, 16).map(i => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, z: i,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "z"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-steps(n-breaks: 5),),
///   guides: guides(fill: none),
///   theme: theme-void(),
///   width: 10cm,
///   height: 1cm,
/// )
/// ```
#let scale-fill-steps(..args) = _scale-steps("fill", ..args)

/// Binned diverging fill gradient through a midpoint.
///
/// Fill counterpart of `scale-colour-steps2`.
///
/// - low: Colour for values far below `midpoint`.
/// - mid: Colour at `midpoint`.
/// - high: Colour for values far above `midpoint`.
/// - midpoint: Value at which the palette transitions through `mid`.
/// - n-breaks: Number of bins to partition the domain into.
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - limits: Pair `(lo, hi)` clipping the trained domain, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - labels: Array of legend labels aligned with the bins, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-colour-steps2`, `scale-fill-steps`, `scale-fill-stepsn`.
///
/// Six-bin diverging swatch pivoting at zero.
///
/// ```typst
/// #let d = range(-7, 8).map(i => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, z: i,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "z"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-steps2(midpoint: 0, n-breaks: 6),),
///   guides: guides(fill: none),
///   theme: theme-void(),
///   width: 10cm,
///   height: 1cm,
/// )
/// ```
#let scale-fill-steps2(..args) = _scale-steps2("fill", ..args)

/// Binned n-stop fill gradient.
///
/// Fill counterpart of `scale-colour-stepsn`.
///
/// - colours: Array of two or more colours.
/// - n-breaks: Number of bins to partition the domain into.
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - limits: Pair `(lo, hi)` clipping the trained domain, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - labels: Array of legend labels aligned with the bins, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-colour-stepsn`, `scale-fill-steps`, `scale-fill-steps2`.
///
/// Three-stop ramp discretised into six bins, shown as a swatch via `geom-rect`.
///
/// ```typst
/// #let d = range(0, 16).map(i => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, z: i,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "z"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-stepsn(colours: (
///     rgb("#1a9850"), rgb("#ffffbf"), rgb("#d73027"),
///   ), n-breaks: 6),),
///   guides: guides(fill: none),
///   theme: theme-void(),
///   width: 10cm,
///   height: 1cm,
/// )
/// ```
#let scale-fill-stepsn(..args) = _scale-stepsn("fill", ..args)

/// Binned ColorBrewer fill scale.
///
/// Fill counterpart of `scale-colour-fermenter`.
///
/// - palette: ColorBrewer palette name (sequential or diverging works best).
/// - n-breaks: Number of bins to partition the domain into.
/// - direction: `1` for canonical order, `-1` for reversed.
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - limits: Pair `(lo, hi)` clipping the trained domain, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - labels: Array of legend labels aligned with the bins, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-colour-fermenter`, `scale-fill-distiller`.
///
/// Spectral palette quantised into five bins, shown as a swatch via `geom-rect`.
///
/// ```typst
/// #let d = range(0, 16).map(i => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, z: i,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "z"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-fermenter(palette: "Spectral", n-breaks: 5),),
///   guides: guides(fill: none),
///   theme: theme-void(),
///   width: 10cm,
///   height: 1cm,
/// )
/// ```
#let scale-fill-fermenter(..args) = _scale-fermenter("fill", ..args)
