///! Rectangular two-dimensional binning. Wraps \@stat-bin-2d over rect output.

#import "../layer.typ": make-layer
#import "../stat/bin2d.typ": stat-bin-2d

/// Two-dimensional bin layer: counts (x, y) into a rectangular grid and draws one rectangle per non-empty cell. The fill aesthetic defaults to `_count`, so a continuous fill scale (`scale-fill-viridis-c`, etc.) shades the cells by frequency.
///
/// `bins` and `binwidth` accept either a scalar or an `(x, y)` pair.
///
/// - mapping: Layer-specific aesthetic mapping built with `aes`. Must map `x` and `y`.
/// - data: Layer-specific dataset, or a function applied to the plot data returning the layer frame. Falls back to the plot data when `none`.
/// - bins: Scalar or `(x, y)` pair — target bin counts.
/// - binwidth: Scalar or `(x, y)` pair — fixed bin widths. Overrides `bins` per axis.
/// - colour: Cell outline colour.
/// - fill: Cell fill colour. `auto` lets the fill scale paint by `_count`.
/// - stroke: Outline thickness or stroke dictionary.
/// - alpha: Cell opacity in `[0, 1]`.
/// - inherit-aes: Whether to merge the plot-level mapping into this layer's mapping.
///
/// Returns: Layer dictionary consumed by `plot`.
///
/// See also: `geom-hex`, `stat-bin-2d`, `geom-tile`.
///
/// 30-by-30 grid coloured by count via the magma palette.
///
/// ```typst
/// #let d = range(0, 400).map(i => (
///   x: calc.sin(i * 0.13) * 4,
///   y: calc.cos(i * 0.21) * 4,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-bin-2d(bins: 20),),
///   scales: (scale-fill-viridis-c(option: "magma"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let geom-bin-2d(
  mapping: none,
  data: none,
  bins: 30,
  binwidth: none,
  colour: auto,
  fill: auto,
  stroke: none,
  alpha: auto,
  inherit-aes: true,
) = make-layer(
  "rect",
  mapping: mapping,
  data: data,
  params: (
    colour: colour,
    fill: fill,
    stroke: stroke,
    alpha: alpha,
  ),
  stat: stat-bin-2d(bins: bins, binwidth: binwidth),
  inherit-aes: inherit-aes,
)
