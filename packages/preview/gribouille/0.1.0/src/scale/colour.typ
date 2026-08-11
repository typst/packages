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
/// \@category Scales
/// \@subcategory Colour and fill: continuous
/// \@stability stable
/// \@since 0.0.1
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param palette Colour source: a gradient, an array of colours, or `auto`.
///
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param breaks Array of break values for the legend, or `auto`.
///
/// \@param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Default viridis ramp interpolating across the library's
/// continuous palette.
/// ```
/// //| alt: "Scatter chart of twelve diagonal points coloured by z along the default continuous viridis ramp from dark purple at low values to bright yellow at high values."
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
/// \@examples Pin `limits` to clip the trained domain and render extremes at
/// the palette endpoints.
/// ```
/// //| alt: "Scatter chart of twelve diagonal points coloured by z along the continuous viridis ramp, with limits 1 through 4 clamping out-of-range values to palette endpoints."
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
///
/// \@see \@scale-colour-viridis-c, \@scale-colour-discrete, \@scale-fill-continuous
#let scale-colour-continuous(..args) = _scale-continuous("colour", ..args)

/// Discrete colour scale mapping categorical levels to stroke colours.
///
/// \@category Scales
/// \@subcategory Colour and fill: discrete
/// \@stability stable
/// \@since 0.0.1
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param palette Colour source: an array of colours, or `auto`.
///
/// \@param limits Array of level names controlling order and inclusion, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Default palette mapping three categories to the library's eight
/// reserved discrete colours.
/// ```
/// //| alt: "Scatter chart of three points where sp maps to three distinct categorical colours from the library's reserved discrete palette."
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
/// \@examples Override `palette` with an explicit colour array to hand-pick
/// the mapping order.
/// ```
/// //| alt: "Scatter chart of three points where sp maps to a hand-picked teal, orange, and blue trio supplied directly through palette."
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
/// \@examples Bind a colour-blind-friendly palette to penguin species and
/// reorder the legend via `limits`.
/// ```
/// //| alt: "Scatter chart of penguin flipper length against body mass coloured by species using a blue-orange-green colour-blind-friendly palette with limits fixing legend order."
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
///
/// \@see \@scale-colour-manual, \@scale-colour-viridis-d, \@scale-fill-discrete
#let scale-colour-discrete(..args) = _scale-discrete("colour", ..args)

/// Continuous fill scale mapping a numeric column to fill colours.
///
/// \@category Scales
/// \@subcategory Colour and fill: continuous
/// \@stability stable
/// \@since 0.0.1
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param palette Colour source: a gradient, an array of colours, or `auto`.
///
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param breaks Array of break values for the legend, or `auto`.
///
/// \@param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Default ramp filling bars by their numeric value.
/// ```
/// //| alt: "Bar chart of three bars a, b, c filled along the default continuous viridis ramp from dark purple at low y to bright yellow at high y."
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
/// \@examples The default ramp shown as a continuous swatch via \@geom-rect
/// over a sampled gradient.
/// ```
/// //| alt: "Colour-bar swatch of sixteen rectangles displaying the default continuous viridis fill ramp from dark purple on the left to bright yellow on the right."
/// #let d = range(0, 16).map(i => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, z: i,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "z"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-continuous(),),
///   guides: guides(fill: guide-none()),
///   theme: theme-void(),
///   width: 10cm,
///   height: 1cm,
/// )
/// ```
///
/// \@see \@scale-fill-viridis-c, \@scale-fill-discrete, \@scale-colour-continuous
#let scale-fill-continuous(..args) = _scale-continuous("fill", ..args)

/// Discrete fill scale mapping categorical levels to fill colours.
///
/// \@category Scales
/// \@subcategory Colour and fill: discrete
/// \@stability stable
/// \@since 0.0.1
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param palette Colour source: an array of colours, or `auto`.
///
/// \@param limits Array of level names controlling order and inclusion, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Default palette filling three bars from the library's reserved
/// discrete colours.
/// ```
/// //| alt: "Bar chart of three bars a, b, c each filled with one of the library's reserved discrete categorical colours."
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
/// \@examples The palette laid out as a swatch strip via \@geom-rect, one
/// rectangle per level.
/// ```
/// //| alt: "Legend swatch strip of eight rectangles displaying each reserved discrete fill colour in level order from a to h."
/// #let levels = ("a", "b", "c", "d", "e", "f", "g", "h")
/// #let d = levels.enumerate().map(((i, k)) => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, k: k,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "k"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-discrete(),),
///   guides: guides(fill: guide-none()),
///   theme: theme-void(),
///   width: 8cm,
///   height: 1cm,
/// )
/// ```
///
/// \@see \@scale-fill-manual, \@scale-fill-viridis-d, \@scale-colour-discrete
#let scale-fill-discrete(..args) = _scale-discrete("fill", ..args)

/// Manual discrete colour scale: supply the colour array directly.
///
/// Colours cycle through `values` in the order levels appear, unless
/// `limits` fixes the level order.
///
/// \@category Scales
/// \@subcategory Colour and fill: manual and identity
/// \@stability stable
/// \@since 0.0.1
///
/// \@param values Array of colours, one per level.
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param limits Array of level names controlling order and inclusion, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Hand-picked colour array applied to three categorical levels.
/// ```
/// //| alt: "Scatter chart of three points where sp maps to a hand-picked teal, orange, and blue trio supplied via the manual values cycle."
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
/// \@examples `limits` fixes the level order independently of how rows appear
/// in the data, useful for stable legends across datasets.
/// ```
/// //| alt: "Scatter chart of three points where limits forces a, b, c order so the teal, orange, blue manual cycle stays stable regardless of input order."
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
///
/// \@see \@scale-colour-discrete, \@scale-fill-manual
#let scale-colour-manual(..args) = _scale-manual("colour", ..args)

/// Manual discrete fill scale: supply the colour array directly.
///
/// Colours cycle through `values` in the order levels appear, unless
/// `limits` fixes the level order.
///
/// \@category Scales
/// \@subcategory Colour and fill: manual and identity
/// \@stability stable
/// \@since 0.0.1
///
/// \@param values Array of colours, one per level.
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param limits Array of level names controlling order and inclusion, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Hand-picked colour array applied to three categorical levels.
/// ```
/// //| alt: "Bar chart of three bars a, b, c filled with a hand-picked sea-green, salmon, and lavender trio supplied via the manual values cycle."
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
/// \@examples The same array shown as a swatch strip via \@geom-rect.
/// ```
/// //| alt: "Legend swatch strip of three rectangles displaying the hand-picked sea-green, salmon, and lavender fill colours in order."
/// #let pal = (rgb("#66c2a5"), rgb("#fc8d62"), rgb("#8da0cb"))
/// #let d = pal.enumerate().map(((i, _)) => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, k: str(i),
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "k"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-manual(values: pal),),
///   guides: guides(fill: guide-none()),
///   theme: theme-void(),
///   width: 6cm,
///   height: 1cm,
/// )
/// ```
///
/// \@see \@scale-fill-discrete, \@scale-colour-manual
#let scale-fill-manual(..args) = _scale-manual("fill", ..args)

/// Discrete viridis colour scale.
///
/// `option` selects between `"viridis"`, `"magma"`, `"plasma"`, `"inferno"`,
/// and `"cividis"`.
///
/// \@category Scales
/// \@subcategory Colour and fill: discrete
/// \@stability stable
/// \@since 0.0.1
///
/// \@param option Palette name: `"viridis"`, `"magma"`, `"plasma"`, `"inferno"`, or `"cividis"`.
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param limits Array of level names controlling order and inclusion, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Plasma option of the viridis family applied to four categories.
/// ```
/// //| alt: "Scatter chart of four points where sp maps to distinct categorical colours sampled from the plasma viridis palette ranging from purple to yellow."
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
/// \@examples Switching `option` to `"cividis"` selects the colour-blind safe
/// alternative.
/// ```
/// //| alt: "Scatter chart of four points where sp maps to colours sampled from the colour-blind safe cividis palette running from dark blue to bright yellow."
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
///
/// \@see \@scale-colour-viridis-c, \@scale-colour-viridis-b, \@scale-fill-viridis-d
#let scale-colour-viridis-d(..args) = _scale-viridis-d("colour", ..args)

/// Continuous viridis colour scale.
///
/// `option` selects between `"viridis"`, `"magma"`, `"plasma"`, `"inferno"`,
/// and `"cividis"`.
///
/// \@category Scales
/// \@subcategory Colour and fill: continuous
/// \@stability stable
/// \@since 0.0.1
///
/// \@param option Palette name: `"viridis"`, `"magma"`, `"plasma"`, `"inferno"`, or `"cividis"`.
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param breaks Array of break values for the legend, or `auto`.
///
/// \@param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Magma option applied to a continuous numeric column.
/// ```
/// //| alt: "Scatter chart of twelve diagonal points coloured by z along a continuous magma ramp from black at low values through purple-red to pale yellow at high."
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
/// \@examples Default `"viridis"` ramp with `limits` clipping the lower tail.
/// ```
/// //| alt: "Scatter chart of twelve diagonal points coloured along the viridis ramp from purple to yellow, with limits 2 through 6 clamping the lower tail to the dark end."
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
///
/// \@see \@scale-colour-viridis-d, \@scale-colour-viridis-b, \@scale-fill-viridis-c
#let scale-colour-viridis-c(..args) = _scale-viridis-c("colour", ..args)

/// Binned viridis colour scale.
///
/// Partitions the continuous domain into `n-breaks` equal segments, each
/// coloured from the chosen viridis palette.
///
/// \@category Scales
/// \@subcategory Colour and fill: binned
/// \@stability stable
/// \@since 0.0.1
///
/// \@param option Palette name: `"viridis"`, `"magma"`, `"plasma"`, `"inferno"`, or `"cividis"`.
///
/// \@param n-breaks Number of bins to partition the domain into.
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param labels Array of legend labels aligned with the bins, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Four equal-width bins coloured from the default viridis ramp.
/// ```
/// //| alt: "Scatter chart of twelve diagonal points where z is cut into four stepped bands coloured from the viridis ramp running purple to yellow."
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
/// \@examples Bumping `n-breaks` and switching to the inferno option produces
/// a finer-grained banded scale.
/// ```
/// //| alt: "Scatter chart of twelve diagonal points where z is cut into eight finer stepped bands coloured from the inferno ramp running black through red to bright yellow."
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
///
/// \@see \@scale-colour-viridis-c, \@scale-colour-viridis-d, \@scale-fill-viridis-b
#let scale-colour-viridis-b(..args) = _scale-viridis-b("colour", ..args)

/// Discrete viridis fill scale.
///
/// `option` selects between `"viridis"`, `"magma"`, `"plasma"`, `"inferno"`,
/// and `"cividis"`.
///
/// \@category Scales
/// \@subcategory Colour and fill: discrete
/// \@stability stable
/// \@since 0.0.1
///
/// \@param option Palette name: `"viridis"`, `"magma"`, `"plasma"`, `"inferno"`, or `"cividis"`.
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param limits Array of level names controlling order and inclusion, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Cividis option filling four categorical bars.
/// ```
/// //| alt: "Bar chart of four bars a, b, c, d filled with distinct colours sampled from the colour-blind safe cividis palette ranging dark blue to yellow."
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
/// \@examples Each viridis option laid out as a swatch strip via \@geom-rect.
/// ```
/// //| alt: "Legend swatch strip of five rectangles filled with distinct colours sampled from the magma viridis palette spanning black through red to pale cream."
/// #let opts = ("viridis", "magma", "plasma", "inferno", "cividis")
/// #let d = opts.enumerate().map(((i, k)) => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, k: k,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "k"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-viridis-d(option: "magma"),),
///   guides: guides(fill: guide-none()),
///   theme: theme-void(),
///   width: 6cm,
///   height: 1cm,
/// )
/// ```
///
/// \@see \@scale-fill-viridis-c, \@scale-fill-viridis-b, \@scale-colour-viridis-d
#let scale-fill-viridis-d(..args) = _scale-viridis-d("fill", ..args)

/// Continuous viridis fill scale.
///
/// `option` selects between `"viridis"`, `"magma"`, `"plasma"`, `"inferno"`,
/// and `"cividis"`.
///
/// \@category Scales
/// \@subcategory Colour and fill: continuous
/// \@stability stable
/// \@since 0.0.1
///
/// \@param option Palette name: `"viridis"`, `"magma"`, `"plasma"`, `"inferno"`, or `"cividis"`.
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param breaks Array of break values for the legend, or `auto`.
///
/// \@param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Default viridis ramp filling bars by their numeric value.
/// ```
/// //| alt: "Bar chart of twelve increasing bars filled along the continuous viridis ramp from dark purple at low y to bright yellow at high y."
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
/// \@examples The viridis ramp shown as a continuous swatch via \@geom-rect.
/// ```
/// //| alt: "Colour-bar swatch of sixteen rectangles displaying the continuous viridis fill ramp from dark purple on the left to bright yellow on the right."
/// #let d = range(0, 16).map(i => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, z: i,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "z"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-viridis-c(),),
///   guides: guides(fill: guide-none()),
///   theme: theme-void(),
///   width: 10cm,
///   height: 1cm,
/// )
/// ```
///
/// \@see \@scale-fill-viridis-d, \@scale-fill-viridis-b, \@scale-colour-viridis-c
#let scale-fill-viridis-c(..args) = _scale-viridis-c("fill", ..args)

/// Colour scale that uses each row's value as the stroke colour directly.
///
/// The mapped column must hold values acceptable to Typst's `rgb()`
/// (e.g., `"#ff0000"`) or already be `color` values. No legend is drawn
/// because the column carries the visual outcome verbatim.
///
/// \@category Scales
/// \@subcategory Colour and fill: manual and identity
/// \@stability stable
/// \@since 0.0.1
///
/// \@param name Legend title. Identity scales draw no legend, but the title is
///   carried for downstream consumers that may surface it.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Hex strings carried straight through to point strokes; no
/// legend is drawn.
/// ```
/// //| alt: "Scatter chart of three points where the c column passes through hex strings verbatim, drawing teal, orange, and blue strokes with no legend."
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
///
/// \@see \@scale-colour-manual, \@scale-fill-identity
#let scale-colour-identity(..args) = _scale-identity("colour", ..args)

/// Fill scale that uses each row's value as the fill colour directly.
///
/// Values must be hex strings or `color` values; see \@scale-colour-identity.
///
/// \@category Scales
/// \@subcategory Colour and fill: manual and identity
/// \@stability stable
/// \@since 0.0.1
///
/// \@param name Legend title. Identity scales draw no legend.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Per-row hex strings used as fills, with \@geom-rect drawing a
/// custom swatch from arbitrary colours.
/// ```
/// //| alt: "Legend swatch strip of three rectangles where the c column passes through hex strings verbatim, filling teal, orange, and lavender bands with no legend."
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
///
/// \@see \@scale-fill-manual, \@scale-colour-identity
#let scale-fill-identity(..args) = _scale-identity("fill", ..args)

/// Binned viridis fill scale.
///
/// Partitions the continuous domain into `n-breaks` equal segments, each
/// coloured from the chosen viridis palette.
///
/// \@category Scales
/// \@subcategory Colour and fill: binned
/// \@stability stable
/// \@since 0.0.1
///
/// \@param option Palette name: `"viridis"`, `"magma"`, `"plasma"`, `"inferno"`, or `"cividis"`.
///
/// \@param n-breaks Number of bins to partition the domain into.
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param labels Array of legend labels aligned with the bins, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Default viridis ramp quantised into four bins for a banded fill.
/// ```
/// //| alt: "Bar chart of twelve increasing bars where y is cut into four stepped bands coloured along the viridis ramp from purple to yellow."
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
/// \@examples The same ramp shown as a banded swatch via \@geom-rect.
/// ```
/// //| alt: "Colour-bar swatch of twelve rectangles where z is cut into six stepped bands coloured from the plasma viridis palette ranging purple through pink to yellow."
/// #let d = range(0, 12).map(i => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, z: i,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "z"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-viridis-b(option: "plasma", n-breaks: 6),),
///   guides: guides(fill: guide-none()),
///   theme: theme-void(),
///   width: 8cm,
///   height: 1cm,
/// )
/// ```
///
/// \@see \@scale-fill-viridis-c, \@scale-fill-viridis-d, \@scale-colour-viridis-b
#let scale-fill-viridis-b(..args) = _scale-viridis-b("fill", ..args)

/// Discrete ColorBrewer colour scale.
///
/// `palette` selects a named ColorBrewer palette such as `"Set1"`,
/// `"Dark2"`, or `"Spectral"`. Categorical levels are mapped to colours
/// in the order they first appear in the data.
///
/// \@category Scales
/// \@subcategory Colour and fill: discrete
/// \@stability stable
/// \@since 0.1.0
///
/// \@param palette ColorBrewer palette name (qualitative, sequential, or diverging).
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param limits Array of level names controlling order and inclusion, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Set1 palette mapping three categorical levels to bold qualitative
/// hues.
/// ```
/// //| alt: "Scatter chart of three points where sp maps to bold qualitative red, blue, and green hues sampled from the ColorBrewer Set1 palette."
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
/// \@examples Switching to the diverging Spectral palette suits ordered
/// categories with a meaningful midpoint.
/// ```
/// //| alt: "Scatter chart of three points where ordered categories low, mid, high map to colours from the diverging Spectral palette running red through yellow to blue."
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
///
/// \@see \@scale-fill-brewer, \@scale-colour-discrete
#let scale-colour-brewer(..args) = _scale-brewer("colour", ..args)

/// Discrete ColorBrewer fill scale.
///
/// Fill counterpart of \@scale-colour-brewer. Same palette names apply.
///
/// \@category Scales
/// \@subcategory Colour and fill: discrete
/// \@stability stable
/// \@since 0.1.0
///
/// \@param palette ColorBrewer palette name (qualitative, sequential, or diverging).
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param limits Array of level names controlling order and inclusion, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Set1 palette filling categorical bars.
/// ```
/// //| alt: "Bar chart of three bars a, b, c filled with bold qualitative red, blue, green hues sampled from the ColorBrewer Set1 palette."
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
/// \@examples The Spectral palette laid out as a swatch strip via \@geom-rect.
/// ```
/// //| alt: "Legend swatch strip of seven rectangles displaying the diverging Spectral ColorBrewer palette from red through yellow at midpoint to blue."
/// #let levels = ("a", "b", "c", "d", "e", "f", "g")
/// #let d = levels.enumerate().map(((i, k)) => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, k: k,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "k"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-brewer(palette: "Spectral"),),
///   guides: guides(fill: guide-none()),
///   theme: theme-void(),
///   width: 8cm,
///   height: 1cm,
/// )
/// ```
///
/// \@see \@scale-colour-brewer, \@scale-fill-discrete
#let scale-fill-brewer(..args) = _scale-brewer("fill", ..args)

/// Discrete Okabe-Ito colour-vision-deficiency-safe colour scale.
///
/// Maps categorical levels to the eight-colour Okabe-Ito palette
/// (Wong 2011, Nature Methods) in the order they first appear in the data.
/// This palette is also the library default for unmapped discrete colour
/// aesthetics; use this helper when you want to opt in explicitly or set
/// `name`, `limits`, or `labels`.
///
/// \@category Scales
/// \@subcategory Colour and fill: discrete
/// \@stability stable
/// \@since 0.5.0
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param limits Array of level names controlling order and inclusion, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Three categorical levels mapped to the first three Okabe-Ito hues.
/// ```
/// //| alt: "Scatter chart of three points where sp maps to the first three colours of the colour-vision-deficiency-safe Okabe-Ito palette."
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
///
/// \@see \@scale-fill-okabe-ito, \@scale-colour-brewer, \@scale-colour-discrete
#let scale-colour-okabe-ito(..args) = _scale-okabe-ito("colour", ..args)

/// Discrete Okabe-Ito colour-vision-deficiency-safe fill scale.
///
/// Fill counterpart of \@scale-colour-okabe-ito. Also the library default
/// for unmapped discrete fill aesthetics.
///
/// \@category Scales
/// \@subcategory Colour and fill: discrete
/// \@stability stable
/// \@since 0.5.0
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param limits Array of level names controlling order and inclusion, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Categorical bars filled with the Okabe-Ito palette.
/// ```
/// //| alt: "Bar chart of three bars a, b, c filled with the first three colour-vision-deficiency-safe Okabe-Ito fills."
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
///
/// \@see \@scale-colour-okabe-ito, \@scale-fill-brewer, \@scale-fill-discrete
#let scale-fill-okabe-ito(..args) = _scale-okabe-ito("fill", ..args)

/// Continuous two-stop colour gradient.
///
/// Linearly interpolates between `low` and `high` across the trained domain.
/// Defaults to a blue ramp.
///
/// \@category Scales
/// \@subcategory Colour and fill: continuous
/// \@stability stable
/// \@since 0.1.0
///
/// \@param low Colour for the low end of the domain.
///
/// \@param high Colour for the high end of the domain.
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param breaks Array of break values for the legend, or `auto`.
///
/// \@param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Default low-to-high blue ramp.
/// ```
/// //| alt: "Scatter chart of twelve diagonal points coloured by z along the default two-stop gradient ramp from dark navy at low to light sky-blue at high."
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
/// \@examples Custom two-stop ramp passing explicit `low` and `high` colours.
/// ```
/// //| alt: "Scatter chart of twelve diagonal points coloured by z along a custom two-stop ramp from pale peach at low values to deep crimson at high values."
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
///
/// \@see \@scale-colour-gradient2, \@scale-colour-gradientn, \@scale-fill-gradient
#let scale-colour-gradient(..args) = _scale-gradient("colour", ..args)

/// Continuous diverging colour gradient through a midpoint.
///
/// Interpolates `low` to `mid` for values at or below `midpoint`, and
/// `mid` to `high` for values at or above it.
///
/// \@category Scales
/// \@subcategory Colour and fill: continuous
/// \@stability stable
/// \@since 0.1.0
///
/// \@param low Colour for values far below `midpoint`.
///
/// \@param mid Colour at `midpoint`.
///
/// \@param high Colour for values far above `midpoint`.
///
/// \@param midpoint Value at which the palette transitions through `mid`.
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param breaks Array of break values for the legend, or `auto`.
///
/// \@param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Default diverging ramp pivoting at zero, useful for signed
/// numeric values.
/// ```
/// //| alt: "Scatter chart of eleven points coloured by z along a diverging ramp that pivots through white at zero, blue for negative and red for positive."
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
/// \@examples Shift `midpoint` to centre the ramp around a non-zero baseline.
/// ```
/// //| alt: "Scatter chart of eleven points coloured by z along a green-yellow-red diverging ramp pivoting through pale yellow at midpoint 5."
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
///
/// \@see \@scale-colour-gradient, \@scale-colour-gradientn, \@scale-fill-gradient2
#let scale-colour-gradient2(..args) = _scale-gradient2("colour", ..args)

/// Continuous n-stop colour gradient.
///
/// Walks `colours` as a sequence of stops and linearly interpolates between
/// adjacent stops. Useful for ramps that require more than two anchor
/// colours (for example a ColorBrewer palette used as a continuous ramp).
///
/// \@category Scales
/// \@subcategory Colour and fill: continuous
/// \@stability stable
/// \@since 0.1.0
///
/// \@param colours Array of two or more colours.
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param breaks Array of break values for the legend, or `auto`.
///
/// \@param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Three-stop ramp interpolating green-yellow-red across the domain.
/// ```
/// //| alt: "Scatter chart of twelve diagonal points coloured by z along a custom three-stop n-stop ramp passing green through pale yellow to red."
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
/// \@examples Feeding a brewer palette into `scale-colour-gradientn` lifts a
/// discrete palette into a continuous ramp.
/// ```
/// //| alt: "Scatter chart of twelve diagonal points coloured by z along an n-stop ramp built from the ColorBrewer RdYlBu palette running red through yellow to blue."
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
///
/// \@see \@scale-colour-gradient, \@scale-colour-gradient2, \@scale-fill-gradientn
#let scale-colour-gradientn(..args) = _scale-gradientn("colour", ..args)

/// Continuous two-stop fill gradient.
///
/// Fill counterpart of \@scale-colour-gradient.
///
/// \@category Scales
/// \@subcategory Colour and fill: continuous
/// \@stability stable
/// \@since 0.1.0
///
/// \@param low Colour for the low end of the domain.
///
/// \@param high Colour for the high end of the domain.
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param breaks Array of break values for the legend, or `auto`.
///
/// \@param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Custom two-stop ramp shown as a continuous swatch via \@geom-rect.
/// ```
/// //| alt: "Colour-bar swatch of sixteen rectangles displaying a continuous two-stop fill gradient from pale peach on the left to deep crimson on the right."
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
///   guides: guides(fill: guide-none()),
///   theme: theme-void(),
///   width: 10cm,
///   height: 1cm,
/// )
/// ```
///
/// \@see \@scale-colour-gradient, \@scale-fill-gradient2, \@scale-fill-gradientn
#let scale-fill-gradient(..args) = _scale-gradient("fill", ..args)

/// Continuous diverging fill gradient through a midpoint.
///
/// Fill counterpart of \@scale-colour-gradient2.
///
/// \@category Scales
/// \@subcategory Colour and fill: continuous
/// \@stability stable
/// \@since 0.1.0
///
/// \@param low Colour for values far below `midpoint`.
///
/// \@param mid Colour at `midpoint`.
///
/// \@param high Colour for values far above `midpoint`.
///
/// \@param midpoint Value at which the palette transitions through `mid`.
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param breaks Array of break values for the legend, or `auto`.
///
/// \@param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Diverging ramp pivoting at zero, shown as a swatch via
/// \@geom-rect.
/// ```
/// //| alt: "Colour-bar swatch of fifteen rectangles displaying a diverging fill gradient that pivots through white at zero, blue for negative and red for positive."
/// #let d = range(-7, 8).map(i => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, z: i,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "z"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-gradient2(midpoint: 0),),
///   guides: guides(fill: guide-none()),
///   theme: theme-void(),
///   width: 10cm,
///   height: 1cm,
/// )
/// ```
///
/// \@see \@scale-colour-gradient2, \@scale-fill-gradient, \@scale-fill-gradientn
#let scale-fill-gradient2(..args) = _scale-gradient2("fill", ..args)

/// Continuous n-stop fill gradient.
///
/// Fill counterpart of \@scale-colour-gradientn.
///
/// \@category Scales
/// \@subcategory Colour and fill: continuous
/// \@stability stable
/// \@since 0.1.0
///
/// \@param colours Array of two or more colours.
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param breaks Array of break values for the legend, or `auto`.
///
/// \@param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Three-stop ramp shown as a continuous swatch via \@geom-rect.
/// ```
/// //| alt: "Colour-bar swatch of sixteen rectangles displaying an n-stop fill gradient passing green through pale yellow to red across the bar."
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
///   guides: guides(fill: guide-none()),
///   theme: theme-void(),
///   width: 10cm,
///   height: 1cm,
/// )
/// ```
///
/// \@see \@scale-colour-gradientn, \@scale-fill-gradient, \@scale-fill-gradient2
#let scale-fill-gradientn(..args) = _scale-gradientn("fill", ..args)

/// Discrete grey colour scale.
///
/// Generates `n` evenly-spaced `luma` colours from `start` (darker) to `end`
/// (lighter), each in `[0, 1]` where 0 is black and 1 is white.
///
/// \@category Scales
/// \@subcategory Colour and fill: discrete
/// \@stability stable
/// \@since 0.2.0
///
/// \@param start Luminance for the first level, in `[0, 1]`.
///
/// \@param end Luminance for the last level, in `[0, 1]`.
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param limits Array of level names controlling order and inclusion, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Default grey ramp from dark to light spread across three levels.
/// ```
/// //| alt: "Scatter chart of three points where sp maps to three evenly-spaced grey luma values stepping from dark grey to light grey."
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
/// \@examples Narrowing `start` and `end` constrains the ramp to a darker
/// range for tighter contrast.
/// ```
/// //| alt: "Scatter chart of three points where sp maps to a narrowed grey ramp from luma 0.1 to 0.5, keeping the palette in the darker half of the scale."
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
///
/// \@see \@scale-fill-grey, \@scale-colour-discrete
#let scale-colour-grey(..args) = _scale-grey("colour", ..args)

/// Discrete grey fill scale.
///
/// Fill counterpart of \@scale-colour-grey.
///
/// \@category Scales
/// \@subcategory Colour and fill: discrete
/// \@stability stable
/// \@since 0.2.0
///
/// \@param start Luminance for the first level, in `[0, 1]`.
///
/// \@param end Luminance for the last level, in `[0, 1]`.
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param limits Array of level names controlling order and inclusion, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Default grey ramp shown as a swatch strip via \@geom-rect.
/// ```
/// //| alt: "Legend swatch strip of six rectangles stepping evenly from dark grey on the left to light grey on the right along the default grey fill ramp."
/// #let levels = ("a", "b", "c", "d", "e", "f")
/// #let d = levels.enumerate().map(((i, k)) => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, k: k,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "k"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-grey(),),
///   guides: guides(fill: guide-none()),
///   theme: theme-void(),
///   width: 8cm,
///   height: 1cm,
/// )
/// ```
///
/// \@see \@scale-colour-grey, \@scale-fill-discrete
#let scale-fill-grey(..args) = _scale-grey("fill", ..args)

/// Discrete equally-spaced hue colour scale.
///
/// Steps `n` hues across the angular range `hue` in OKLCh space, picking
/// chroma and luminance from `chroma` and `luminance`. Defaults to
/// `hue: (15deg, 375deg)`, `chroma: 100`, `luminance: 65`.
///
/// OKLCh is used as a perceptually uniform near-equivalent of HCL, which
/// Typst does not expose directly. The first colour sits at `hue.at(0)` and
/// successive colours step by `(end - start) / n`, so the endpoint is
/// excluded and the wheel never duplicates a hue when `start` and `end`
/// differ by a full turn.
///
/// \@category Scales
/// \@subcategory Colour and fill: discrete
/// \@stability stable
/// \@since 0.2.0
///
/// \@param hue Pair `(start, end)` of hue angles.
///
/// \@param chroma Chroma in `[0, 100]`.
///
/// \@param luminance Luminance in `[0, 100]`.
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param limits Array of level names controlling order and inclusion, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Default hue wheel mapping four levels to evenly-spaced colours.
/// ```
/// //| alt: "Scatter chart of four points where sp maps to evenly-spaced hues stepped around the OKLCh colour wheel at full chroma and medium luminance."
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
/// \@examples Lower `chroma` and `luminance` yield a muted, pastel-like palette.
/// ```
/// //| alt: "Scatter chart of four points where sp maps to evenly-spaced muted pastel hues from the OKLCh wheel at chroma 50 and luminance 80."
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
///
/// \@see \@scale-fill-hue, \@scale-colour-discrete
#let scale-colour-hue(..args) = _scale-hue("colour", ..args)

/// Discrete equally-spaced hue fill scale.
///
/// Fill counterpart of \@scale-colour-hue.
///
/// \@category Scales
/// \@subcategory Colour and fill: discrete
/// \@stability stable
/// \@since 0.2.0
///
/// \@param hue Pair `(start, end)` of hue angles.
///
/// \@param chroma Chroma in `[0, 100]`.
///
/// \@param luminance Luminance in `[0, 100]`.
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param limits Array of level names controlling order and inclusion, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Default hue wheel shown as a swatch strip via \@geom-rect.
/// ```
/// //| alt: "Legend swatch strip of eight rectangles stepping evenly around the OKLCh hue wheel at full chroma and medium luminance from red through green and blue back toward red."
/// #let levels = ("a", "b", "c", "d", "e", "f", "g", "h")
/// #let d = levels.enumerate().map(((i, k)) => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, k: k,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "k"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-hue(),),
///   guides: guides(fill: guide-none()),
///   theme: theme-void(),
///   width: 8cm,
///   height: 1cm,
/// )
/// ```
///
/// \@see \@scale-colour-hue, \@scale-fill-discrete
#let scale-fill-hue(..args) = _scale-hue("fill", ..args)

/// Continuous ColorBrewer colour scale.
///
/// Looks up a Brewer palette by name and interpolates linearly across its
/// stops as a continuous ramp. `direction` flips the palette: `1` keeps the
/// canonical order, `-1` reverses it.
///
/// \@category Scales
/// \@subcategory Colour and fill: continuous
/// \@stability stable
/// \@since 0.2.0
///
/// \@param palette ColorBrewer palette name (sequential or diverging works best).
///
/// \@param direction `1` for canonical order, `-1` for reversed.
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param breaks Array of break values for the legend, or `auto`.
///
/// \@param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Spectral palette interpolated as a continuous ramp.
/// ```
/// //| alt: "Scatter chart of twelve diagonal points coloured by z along the ColorBrewer Spectral palette lifted into a smooth continuous ramp from red through yellow to blue."
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
/// \@examples Set `direction: -1` to reverse the palette so high values map
/// to the canonical low end.
/// ```
/// //| alt: "Scatter chart of twelve diagonal points coloured by z along a reversed Blues distiller ramp so high values appear pale and low values dark blue."
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
///
/// \@see \@scale-fill-distiller, \@scale-colour-gradientn, \@scale-colour-brewer
#let scale-colour-distiller(..args) = _scale-distiller("colour", ..args)

/// Continuous alpha (opacity) scale mapping a numeric column to opacities.
///
/// \@category Scales
/// \@subcategory Alpha scales
/// \@stability stable
/// \@since 0.2.0
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param range Pair `(lo, hi)` bounding the output opacity, each in `[0, 1]`.
///
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param breaks Array of break values for the legend, or `auto`.
///
/// \@param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Linear opacity mapping with a wide `range` to fade points from
/// near-transparent to fully opaque.
/// ```
/// //| alt: "Scatter chart of twelve diagonal points where w drives opacity along a continuous ramp from near-transparent at low values to fully opaque at high."
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
/// \@examples A narrower `range` keeps every point visible while still
/// encoding magnitude.
/// ```
/// //| alt: "Scatter chart of twelve diagonal points where w drives opacity along a narrower 0.4 to 0.9 range so every point stays visible while still encoding magnitude."
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
///
/// \@see \@scale-alpha-identity, \@scale-colour-continuous
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
/// Use when each level should map to a chosen opacity in `[0, 1]` rather
/// than the evenly-spaced range that the discrete inference would assign.
///
/// \@category Scales
/// \@subcategory Alpha scales
/// \@stability stable
/// \@since 0.4.0
///
/// \@param values Array of opacities in `[0, 1]`, one per level (in `limits` order when set, otherwise in first-seen order).
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param limits Array of level names controlling order and inclusion, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Three groups assigned dim/medium/full opacity.
/// ```
/// //| alt: "Scatter chart of three blue groups where manual values pin group a to dim opacity, b to medium, and c to full opaque with a fixed discrete cycle."
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
///
/// \@see \@scale-alpha-continuous, \@scale-alpha-identity
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
/// Maps a numeric column onto an opacity range, but groups values into
/// `n-breaks` bins for the legend. The mapping stays continuous; only the
/// legend swatches snap to bin centres.
///
/// \@category Scales
/// \@subcategory Alpha scales
/// \@stability stable
/// \@since 0.4.0
///
/// \@param n-breaks Number of legend bins.
///
/// \@param range Pair `(min, max)` bounding the output opacity in `[0, 1]`.
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Opacity binned into four legend swatches.
/// ```
/// //| alt: "Scatter chart of ten blue diagonal points where w drives opacity along a continuous mapping but the legend collapses into four stepped opacity swatches."
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
///
/// \@see \@scale-alpha-continuous, \@scale-linewidth-binned
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
/// Values are clamped to `[0, 1]` before being applied to the colour.
/// No legend is drawn because the column carries the visual outcome verbatim.
///
/// \@category Scales
/// \@subcategory Alpha scales
/// \@stability stable
/// \@since 0.2.0
///
/// \@param name Legend title. Identity scales draw no legend.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Per-row opacity carried straight through to the point fills.
/// ```
/// //| alt: "Scatter chart of four blue points where the w column passes through verbatim as the fill opacity from near-transparent to fully opaque with no legend."
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
///
/// \@see \@scale-alpha-continuous, \@scale-colour-identity
#let scale-alpha-identity(name: none) = (
  kind: "scale",
  aesthetic: "alpha",
  type: "identity",
  name: name,
)

/// Continuous ColorBrewer fill scale.
///
/// Fill counterpart of \@scale-colour-distiller.
///
/// \@category Scales
/// \@subcategory Colour and fill: continuous
/// \@stability stable
/// \@since 0.2.0
///
/// \@param palette ColorBrewer palette name (sequential or diverging works best).
///
/// \@param direction `1` for canonical order, `-1` for reversed.
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param breaks Array of break values for the legend, or `auto`.
///
/// \@param labels Array of legend labels aligned with `breaks`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Spectral palette interpolated across a continuous swatch via
/// \@geom-rect.
/// ```
/// //| alt: "Colour-bar swatch of sixteen rectangles displaying the ColorBrewer Spectral palette lifted into a smooth continuous fill ramp from red through yellow to blue."
/// #let d = range(0, 16).map(i => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, z: i,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "z"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-distiller(palette: "Spectral"),),
///   guides: guides(fill: guide-none()),
///   theme: theme-void(),
///   width: 10cm,
///   height: 1cm,
/// )
/// ```
///
/// \@see \@scale-colour-distiller, \@scale-fill-gradientn, \@scale-fill-brewer
#let scale-fill-distiller(..args) = _scale-distiller("fill", ..args)

/// Binned two-stop colour gradient.
///
/// Quantises the trained continuous domain into `n-breaks` equal-width bins
/// and fills each bin with a single colour drawn from the `low` to `high`
/// ramp. Defaults to a blue ramp.
///
/// \@category Scales
/// \@subcategory Colour and fill: binned
/// \@stability stable
/// \@since 0.3.0
///
/// \@param low Colour for the low end of the domain.
///
/// \@param high Colour for the high end of the domain.
///
/// \@param n-breaks Number of bins to partition the domain into.
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param labels Array of legend labels aligned with the bins, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Five-bin discretisation of the default low-to-high blue ramp.
/// ```
/// //| alt: "Scatter chart of twelve diagonal points where z is cut into five stepped bands along the default two-stop blue ramp from dark navy to light sky-blue."
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
/// \@examples Custom `low`/`high` colours discretised into eight bins.
/// ```
/// //| alt: "Scatter chart of twelve diagonal points where z is cut into eight stepped bands along a custom two-stop ramp from pale peach to deep crimson."
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
///
/// \@see \@scale-colour-steps2, \@scale-colour-stepsn, \@scale-fill-steps
#let scale-colour-steps(..args) = _scale-steps("colour", ..args)

/// Binned diverging colour gradient through a midpoint.
///
/// Quantises the trained continuous domain into `n-breaks` equal-width bins
/// using a three-stop palette that pivots through `mid` at `midpoint`.
///
/// \@category Scales
/// \@subcategory Colour and fill: binned
/// \@stability stable
/// \@since 0.3.0
///
/// \@param low Colour for values far below `midpoint`.
///
/// \@param mid Colour at `midpoint`.
///
/// \@param high Colour for values far above `midpoint`.
///
/// \@param midpoint Value at which the palette transitions through `mid`.
///
/// \@param n-breaks Number of bins to partition the domain into.
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param labels Array of legend labels aligned with the bins, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Six-bin diverging discretisation pivoting at zero.
/// ```
/// //| alt: "Scatter chart of eleven points where z is cut into six stepped bands along a diverging ramp that pivots through white at zero, green for negative and red for positive."
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
/// \@examples Shift `midpoint` and adjust the three stops to highlight a
/// non-zero pivot.
/// ```
/// //| alt: "Scatter chart of eleven points where z is cut into eight stepped bands along a green-yellow-red diverging ramp pivoting through pale yellow at midpoint 5."
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
///
/// \@see \@scale-colour-steps, \@scale-colour-stepsn, \@scale-fill-steps2
#let scale-colour-steps2(..args) = _scale-steps2("colour", ..args)

/// Binned n-stop colour gradient.
///
/// Walks `colours` as a sequence of stops and quantises the lookup into
/// `n-breaks` equal-width bins.
///
/// \@category Scales
/// \@subcategory Colour and fill: binned
/// \@stability stable
/// \@since 0.3.0
///
/// \@param colours Array of two or more colours.
///
/// \@param n-breaks Number of bins to partition the domain into.
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param labels Array of legend labels aligned with the bins, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Three-stop ramp discretised into six bins.
/// ```
/// //| alt: "Scatter chart of twelve diagonal points where z is cut into six stepped bands along a custom three-stop n-stop ramp passing green through pale yellow to red."
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
/// \@examples Reuse a brewer palette as the stop list to fold a discrete
/// palette into a banded continuous scale.
/// ```
/// //| alt: "Scatter chart of twelve diagonal points where z is cut into five stepped bands along the ColorBrewer YlOrRd palette fed as the n-stop list."
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
///
/// \@see \@scale-colour-steps, \@scale-colour-steps2, \@scale-fill-stepsn
#let scale-colour-stepsn(..args) = _scale-stepsn("colour", ..args)

/// Binned ColorBrewer colour scale.
///
/// Looks up a Brewer palette by name, interpolates across its stops, and
/// quantises the lookup into `n-breaks` equal-width bins. `direction` flips
/// the palette: `1` keeps the canonical order, `-1` reverses it.
///
/// \@category Scales
/// \@subcategory Colour and fill: binned
/// \@stability stable
/// \@since 0.3.0
///
/// \@param palette ColorBrewer palette name (sequential or diverging works best).
///
/// \@param n-breaks Number of bins to partition the domain into.
///
/// \@param direction `1` for canonical order, `-1` for reversed.
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param labels Array of legend labels aligned with the bins, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Spectral palette quantised into five bins.
/// ```
/// //| alt: "Scatter chart of twelve diagonal points where z is cut into five stepped bands along the ColorBrewer Spectral palette running red through yellow to blue."
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
/// \@examples Sequential blues palette reversed via `direction: -1` for an
/// inverted banding.
/// ```
/// //| alt: "Scatter chart of twelve diagonal points where z is cut into seven stepped bands along a reversed Blues fermenter palette so high values appear pale and low dark blue."
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
///
/// \@see \@scale-colour-distiller, \@scale-fill-fermenter
#let scale-colour-fermenter(..args) = _scale-fermenter("colour", ..args)

/// Binned two-stop fill gradient.
///
/// Fill counterpart of \@scale-colour-steps.
///
/// \@category Scales
/// \@subcategory Colour and fill: binned
/// \@stability stable
/// \@since 0.3.0
///
/// \@param low Colour for the low end of the domain.
///
/// \@param high Colour for the high end of the domain.
///
/// \@param n-breaks Number of bins to partition the domain into.
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param labels Array of legend labels aligned with the bins, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Five-bin discretised fill ramp shown as a swatch via \@geom-rect.
/// ```
/// //| alt: "Colour-bar swatch of sixteen rectangles displaying the default two-stop fill ramp cut into five stepped blue bands from dark navy on the left to light sky-blue on the right."
/// #let d = range(0, 16).map(i => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, z: i,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "z"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-steps(n-breaks: 5),),
///   guides: guides(fill: guide-none()),
///   theme: theme-void(),
///   width: 10cm,
///   height: 1cm,
/// )
/// ```
///
/// \@see \@scale-colour-steps, \@scale-fill-steps2, \@scale-fill-stepsn
#let scale-fill-steps(..args) = _scale-steps("fill", ..args)

/// Binned diverging fill gradient through a midpoint.
///
/// Fill counterpart of \@scale-colour-steps2.
///
/// \@category Scales
/// \@subcategory Colour and fill: binned
/// \@stability stable
/// \@since 0.3.0
///
/// \@param low Colour for values far below `midpoint`.
///
/// \@param mid Colour at `midpoint`.
///
/// \@param high Colour for values far above `midpoint`.
///
/// \@param midpoint Value at which the palette transitions through `mid`.
///
/// \@param n-breaks Number of bins to partition the domain into.
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param labels Array of legend labels aligned with the bins, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Six-bin diverging swatch pivoting at zero.
/// ```
/// //| alt: "Colour-bar swatch of fifteen rectangles displaying a diverging fill ramp cut into six stepped bands pivoting through white at zero, green-toned for negative and red for positive."
/// #let d = range(-7, 8).map(i => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, z: i,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "z"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-steps2(midpoint: 0, n-breaks: 6),),
///   guides: guides(fill: guide-none()),
///   theme: theme-void(),
///   width: 10cm,
///   height: 1cm,
/// )
/// ```
///
/// \@see \@scale-colour-steps2, \@scale-fill-steps, \@scale-fill-stepsn
#let scale-fill-steps2(..args) = _scale-steps2("fill", ..args)

/// Binned n-stop fill gradient.
///
/// Fill counterpart of \@scale-colour-stepsn.
///
/// \@category Scales
/// \@subcategory Colour and fill: binned
/// \@stability stable
/// \@since 0.3.0
///
/// \@param colours Array of two or more colours.
///
/// \@param n-breaks Number of bins to partition the domain into.
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param labels Array of legend labels aligned with the bins, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Three-stop ramp discretised into six bins, shown as a swatch
/// via \@geom-rect.
/// ```
/// //| alt: "Colour-bar swatch of sixteen rectangles displaying a custom three-stop n-stop fill ramp cut into six stepped bands passing green through pale yellow to red."
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
///   guides: guides(fill: guide-none()),
///   theme: theme-void(),
///   width: 10cm,
///   height: 1cm,
/// )
/// ```
///
/// \@see \@scale-colour-stepsn, \@scale-fill-steps, \@scale-fill-steps2
#let scale-fill-stepsn(..args) = _scale-stepsn("fill", ..args)

/// Binned ColorBrewer fill scale.
///
/// Fill counterpart of \@scale-colour-fermenter.
///
/// \@category Scales
/// \@subcategory Colour and fill: binned
/// \@stability stable
/// \@since 0.3.0
///
/// \@param palette ColorBrewer palette name (sequential or diverging works best).
///
/// \@param n-breaks Number of bins to partition the domain into.
///
/// \@param direction `1` for canonical order, `-1` for reversed.
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param limits Pair `(lo, hi)` clipping the trained domain, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param labels Array of legend labels aligned with the bins, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Spectral palette quantised into five bins, shown as a swatch
/// via \@geom-rect.
/// ```
/// //| alt: "Colour-bar swatch of sixteen rectangles displaying the ColorBrewer Spectral palette cut into five stepped fill bands from red through yellow to blue."
/// #let d = range(0, 16).map(i => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, z: i,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "z"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-fermenter(palette: "Spectral", n-breaks: 5),),
///   guides: guides(fill: guide-none()),
///   theme: theme-void(),
///   width: 10cm,
///   height: 1cm,
/// )
/// ```
///
/// \@see \@scale-colour-fermenter, \@scale-fill-distiller
#let scale-fill-fermenter(..args) = _scale-fermenter("fill", ..args)
