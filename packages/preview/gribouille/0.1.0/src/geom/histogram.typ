#import "../layer.typ": make-layer
#import "../stat/bin.typ": stat-bin

///! Histogram of a continuous variable.
///!
///! Uses \@stat-bin to partition x into uniform-width bins and draws bars of
///! the per-bin counts. Choose either `bins` (count) or `binwidth` (width).

/// Histogram layer: bars of binned counts along the x aesthetic.
///
/// The layer runs \@stat-bin over the x column, then draws one bar per bin.
/// Supply `bins` for a target bin count or `binwidth` to fix the width.
///
/// \@category Geoms
/// \@subcategory Bars and histograms
/// \@stability stable
/// \@since 0.0.1
///
/// \@param mapping Layer-specific aesthetic mapping built with \@aes. Must map `x`.
///
/// \@param data Layer-specific dataset. Falls back to the plot data when `none`.
///
/// \@param bins Target number of bins when `binwidth` is `none`.
///
/// \@param binwidth Fixed bin width. Overrides `bins` when set.
///
/// \@param width Bar width as a fraction of the bin width (0 to 1).
///
/// \@param colour Bar outline colour. `auto` resolves via the colour scale, falling back to the theme `ink` only when neither `colour` nor `fill` is set.
///
/// \@param fill Bar fill colour. `auto` resolves via the fill scale or a neutral default.
///
/// \@param stroke Bar outline thickness (a Typst length) or stroke dictionary; `none` disables the outline.
///
/// \@param alpha Bar opacity in `[0, 1]`.
///
/// \@param position Position adjustment. Defaults to `"stack"` so a `fill`/`colour` mapping yields stacked contributions per group.
///
/// \@param inherit-aes Whether to merge the plot-level mapping into this layer's mapping.
///
/// \@returns Layer dictionary consumed by \@plot.
///
/// \@examples Twelve-bin partition, letting the layer pick bin width
/// automatically.
/// ```
/// //| alt: "Histogram of 40 noisy observations partitioned into 12 bins along x with bar heights showing per-bin counts."
/// #let d = range(0, 40).map(i => (
///   x: calc.sin(i * 0.3) * 5 + i * 0.2,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x"),
///   layers: (geom-histogram(bins: 12),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Pin `binwidth` directly to align bin edges to integer
/// boundaries.
/// ```
/// //| alt: "Histogram of 40 noisy observations with fixed binwidth 1 along x aligning bin edges to integer boundaries."
/// #let d = range(0, 40).map(i => (
///   x: calc.sin(i * 0.3) * 5 + i * 0.2,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x"),
///   layers: (geom-histogram(binwidth: 1),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Penguin body-mass distribution, stacked by species.
/// ```
/// //| alt: "Stacked histogram of penguin body mass (g) on the x axis with bins of width 250 g and species coloured by fill."
/// #plot(
///   data: penguins,
///   mapping: aes(x: "body-mass", fill: "species"),
///   layers: (geom-histogram(binwidth: 250),),
///   labs: labs(x: "Body Mass (g)", y: "Count", fill: "Species"),
///   width: 11cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@stat-bin, \@geom-bar, \@geom-col
#let geom-histogram(
  mapping: none,
  data: none,
  bins: 30,
  binwidth: none,
  width: 1.0,
  colour: auto,
  fill: auto,
  stroke: none,
  alpha: auto,
  position: "stack",
  inherit-aes: true,
) = make-layer(
  "col",
  mapping: mapping,
  data: data,
  params: (
    colour: colour,
    fill: fill,
    stroke: stroke,
    alpha: alpha,
    width: width,
  ),
  stat: stat-bin(bins: bins, binwidth: binwidth),
  position: position,
  inherit-aes: inherit-aes,
)
