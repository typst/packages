// Default colour palettes.
// Discrete default is Okabe-Ito (CVD-safety over the older "no purple"
// preference). Continuous default is viridis.

#import "viridis.typ": viridis
#import "errors.typ": fail

/// Okabe-Ito colour-vision-deficiency-safe qualitative palette.
///
/// Eight-colour array (Wong 2011, Nature Methods) used as the library default for unmapped discrete colour and fill aesthetics. Order matches `ggthemes::scale_colour_colorblind`: orange, sky blue, bluish green, yellow, blue, vermilion, reddish purple, grey. Black is omitted to avoid clashing with axes and text on a white background.
///
/// See also: `scale-colour-okabe-ito`, `scale-fill-okabe-ito`, `brewer-palette`.
///
/// Pass the palette to a manual scale to opt into Okabe-Ito on a per-aesthetic basis (the same colours are also the library default).
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
///   scales: (scale-colour-manual(values: okabe-ito),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let okabe-ito = (
  rgb("#e69f00"),
  rgb("#56b4e9"),
  rgb("#009e73"),
  rgb("#f0e442"),
  rgb("#0072b2"),
  rgb("#d55e00"),
  rgb("#cc79a7"),
  rgb("#999999"),
)

#let default-discrete = okabe-ito

#let default-continuous = viridis

// Shape palette: keywords resolved by geom-point's `_draw-shape`.
// Covers the most common shape indices without overlap.
#let default-shapes = (
  "circle",
  "square",
  "triangle",
  "diamond",
  "cross",
  "x",
  "star",
  "triangle-down",
)

// Linetype palette: dash patterns accepted by CeTZ stroke `dash` keyword.
#let default-linetypes = (
  "solid",
  "dashed",
  "dotted",
  "dash-dotted",
  "densely-dashed",
  "loosely-dashed",
)

// ColorBrewer palettes (Cynthia Brewer).
// Subset of the canonical tables: 8-class for qualitative palettes (or the
// largest available class where 8 is not defined), 7-class for sequential
// and diverging palettes. Hex codes match the official colorbrewer2.org
// values.
#let brewer-palettes = (
  // Qualitative.
  "Set1": (
    rgb("#e41a1c"),
    rgb("#377eb8"),
    rgb("#4daf4a"),
    rgb("#984ea3"),
    rgb("#ff7f00"),
    rgb("#ffff33"),
    rgb("#a65628"),
    rgb("#f781bf"),
  ),
  "Set2": (
    rgb("#66c2a5"),
    rgb("#fc8d62"),
    rgb("#8da0cb"),
    rgb("#e78ac3"),
    rgb("#a6d854"),
    rgb("#ffd92f"),
    rgb("#e5c494"),
    rgb("#b3b3b3"),
  ),
  "Set3": (
    rgb("#8dd3c7"),
    rgb("#ffffb3"),
    rgb("#bebada"),
    rgb("#fb8072"),
    rgb("#80b1d3"),
    rgb("#fdb462"),
    rgb("#b3de69"),
    rgb("#fccde5"),
  ),
  "Pastel1": (
    rgb("#fbb4ae"),
    rgb("#b3cde3"),
    rgb("#ccebc5"),
    rgb("#decbe4"),
    rgb("#fed9a6"),
    rgb("#ffffcc"),
    rgb("#e5d8bd"),
    rgb("#fddaec"),
  ),
  "Pastel2": (
    rgb("#b3e2cd"),
    rgb("#fdcdac"),
    rgb("#cbd5e8"),
    rgb("#f4cae4"),
    rgb("#e6f5c9"),
    rgb("#fff2ae"),
    rgb("#f1e2cc"),
    rgb("#cccccc"),
  ),
  "Dark2": (
    rgb("#1b9e77"),
    rgb("#d95f02"),
    rgb("#7570b3"),
    rgb("#e7298a"),
    rgb("#66a61e"),
    rgb("#e6ab02"),
    rgb("#a6761d"),
    rgb("#666666"),
  ),
  "Accent": (
    rgb("#7fc97f"),
    rgb("#beaed4"),
    rgb("#fdc086"),
    rgb("#ffff99"),
    rgb("#386cb0"),
    rgb("#f0027f"),
    rgb("#bf5b17"),
    rgb("#666666"),
  ),
  "Paired": (
    rgb("#a6cee3"),
    rgb("#1f78b4"),
    rgb("#b2df8a"),
    rgb("#33a02c"),
    rgb("#fb9a99"),
    rgb("#e31a1c"),
    rgb("#fdbf6f"),
    rgb("#ff7f00"),
  ),
  // Sequential.
  "Blues": (
    rgb("#f7fbff"),
    rgb("#deebf7"),
    rgb("#c6dbef"),
    rgb("#9ecae1"),
    rgb("#6baed6"),
    rgb("#4292c6"),
    rgb("#2171b5"),
    rgb("#084594"),
  ),
  "Greens": (
    rgb("#f7fcf5"),
    rgb("#e5f5e0"),
    rgb("#c7e9c0"),
    rgb("#a1d99b"),
    rgb("#74c476"),
    rgb("#41ab5d"),
    rgb("#238b45"),
    rgb("#005a32"),
  ),
  "Oranges": (
    rgb("#fff5eb"),
    rgb("#fee6ce"),
    rgb("#fdd0a2"),
    rgb("#fdae6b"),
    rgb("#fd8d3c"),
    rgb("#f16913"),
    rgb("#d94801"),
    rgb("#8c2d04"),
  ),
  "Reds": (
    rgb("#fff5f0"),
    rgb("#fee0d2"),
    rgb("#fcbba1"),
    rgb("#fc9272"),
    rgb("#fb6a4a"),
    rgb("#ef3b2c"),
    rgb("#cb181d"),
    rgb("#99000d"),
  ),
  "Purples": (
    rgb("#fcfbfd"),
    rgb("#efedf5"),
    rgb("#dadaeb"),
    rgb("#bcbddc"),
    rgb("#9e9ac8"),
    rgb("#807dba"),
    rgb("#6a51a3"),
    rgb("#4a1486"),
  ),
  "Greys": (
    rgb("#ffffff"),
    rgb("#f0f0f0"),
    rgb("#d9d9d9"),
    rgb("#bdbdbd"),
    rgb("#969696"),
    rgb("#737373"),
    rgb("#525252"),
    rgb("#252525"),
  ),
  "YlOrRd": (
    rgb("#ffffcc"),
    rgb("#ffeda0"),
    rgb("#fed976"),
    rgb("#feb24c"),
    rgb("#fd8d3c"),
    rgb("#fc4e2a"),
    rgb("#e31a1c"),
    rgb("#b10026"),
  ),
  "YlGnBu": (
    rgb("#ffffd9"),
    rgb("#edf8b1"),
    rgb("#c7e9b4"),
    rgb("#7fcdbb"),
    rgb("#41b6c4"),
    rgb("#1d91c0"),
    rgb("#225ea8"),
    rgb("#0c2c84"),
  ),
  // Diverging.
  "RdBu": (
    rgb("#b2182b"),
    rgb("#ef8a62"),
    rgb("#fddbc7"),
    rgb("#f7f7f7"),
    rgb("#d1e5f0"),
    rgb("#67a9cf"),
    rgb("#2166ac"),
  ),
  "RdYlBu": (
    rgb("#d73027"),
    rgb("#fc8d59"),
    rgb("#fee090"),
    rgb("#ffffbf"),
    rgb("#e0f3f8"),
    rgb("#91bfdb"),
    rgb("#4575b4"),
  ),
  "RdYlGn": (
    rgb("#d73027"),
    rgb("#fc8d59"),
    rgb("#fee08b"),
    rgb("#ffffbf"),
    rgb("#d9ef8b"),
    rgb("#91cf60"),
    rgb("#1a9850"),
  ),
  "Spectral": (
    rgb("#d53e4f"),
    rgb("#fc8d59"),
    rgb("#fee08b"),
    rgb("#ffffbf"),
    rgb("#e6f598"),
    rgb("#99d594"),
    rgb("#3288bd"),
  ),
  "BrBG": (
    rgb("#8c510a"),
    rgb("#d8b365"),
    rgb("#f6e8c3"),
    rgb("#f5f5f5"),
    rgb("#c7eae5"),
    rgb("#5ab4ac"),
    rgb("#01665e"),
  ),
  "PiYG": (
    rgb("#c51b7d"),
    rgb("#e9a3c9"),
    rgb("#fde0ef"),
    rgb("#f7f7f7"),
    rgb("#e6f5d0"),
    rgb("#a1d76a"),
    rgb("#4d9221"),
  ),
  "PuOr": (
    rgb("#b35806"),
    rgb("#f1a340"),
    rgb("#fee0b6"),
    rgb("#f7f7f7"),
    rgb("#d8daeb"),
    rgb("#998ec3"),
    rgb("#542788"),
  ),
  "PRGn": (
    rgb("#762a83"),
    rgb("#af8dc3"),
    rgb("#e7d4e8"),
    rgb("#f7f7f7"),
    rgb("#d9f0d3"),
    rgb("#7fbf7b"),
    rgb("#1b7837"),
  ),
)

// Index a palette with modulo wrap so out-of-range indices cycle.
#let palette-at(palette, idx) = {
  if palette.len() == 0 {
    fail(
      "palette-at",
      "palette is empty",
      hint: "`scale-*-manual()` needs at least one value.",
    )
  }
  palette.at(calc.rem(idx, palette.len()))
}

// Resolve the palette declared on a trained scale. When the scale carries no
// explicit palette, continuous scales receive `default-continuous`; everything
// else falls back to the caller-supplied `fallback` (typically the discrete
// default). Used by geoms (linetype, shape) and the level-driven legend kernel.
#let spec-palette(trained, fallback) = {
  if trained == none { return fallback }
  let spec = trained.at("spec", default: none)
  let p = if spec == none { auto } else { spec.at("palette", default: auto) }
  if p != auto and p != none { return p }
  if trained.type == "continuous" { default-continuous } else { fallback }
}

// Read a single attribute (`key`) from a trained scale's `spec` dict, returning
// `fallback` when the scale is untrained or the spec is missing the key.
#let spec-attr(trained, key, fallback: none) = {
  if trained == none { return fallback }
  let spec = trained.at("spec", default: none)
  if spec == none { return fallback }
  spec.at(key, default: fallback)
}

/// Look up a ColorBrewer palette by name.
///
/// Returns the canonical colour array for the named palette. Panics with a clear message if the name is unknown.
///
/// - name: Palette name, e.g., `"Set1"`, `"Spectral"`, `"Blues"`.
///
/// Returns: Array of `color` values.
///
/// Look up the Set1 palette and feed it into a manual fill scale rendered as swatches via `geom-rect`.
///
/// ```typst
/// #let pal = brewer-palette("Set1")
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
///   width: 8cm,
///   height: 1cm,
/// )
/// ```
///
/// The diverging Spectral palette laid out as swatches; the same pattern works for any qualitative, sequential, or diverging name.
///
/// ```typst
/// #let pal = brewer-palette("Spectral")
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
///   width: 8cm,
///   height: 1cm,
/// )
/// ```
#let brewer-palette(name) = {
  let pal = brewer-palettes.at(name, default: none)
  if pal == none {
    let known = brewer-palettes.keys().join(", ")
    fail(
      "brewer-palette",
      "unknown ColorBrewer palette '" + name + "'; known palettes: " + known,
    )
  }
  pal
}
