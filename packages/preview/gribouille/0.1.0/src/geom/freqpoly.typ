#import "../layer.typ": make-layer
#import "../stat/bin.typ": stat-bin

///! Line connecting binned counts along x.
///!
///! Equivalent to \@geom-histogram but draws a polyline through bin
///! midpoints rather than bars. Uses \@stat-bin under the hood; choose
///! either `bins` or `binwidth`.

/// Frequency polygon: a line through per-bin counts of the x aesthetic.
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
/// \@param stroke Line thickness (a Typst length).
///
/// \@param colour Fixed line colour. `auto` resolves via the colour scale.
///
/// \@param alpha Line opacity in `[0, 1]`.
///
/// \@param linetype Dash keyword. `auto` honours the linetype scale.
///
/// \@param position Position adjustment name. Usually `"identity"`.
///
/// \@param inherit-aes Whether to merge the plot-level mapping into this layer's mapping.
///
/// \@returns Layer dictionary consumed by \@plot.
///
/// \@examples Twelve-bin frequency polygon over a noisy series.
/// ```
/// //| alt: "Frequency polygon with 12 bins along x connecting bin counts of 40 noisy observations as a polyline."
/// #let d = range(0, 40).map(i => (
///   x: calc.sin(i * 0.3) * 5 + i * 0.2,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x"),
///   layers: (geom-freqpoly(bins: 12, stroke: 1pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Map `colour` to overlay frequency polygons per group on the
/// same axes.
/// ```
/// //| alt: "Two overlaid frequency polygons of x with 12 bins coloured by group (a, b) via the colour aesthetic."
/// #let d = ()
/// #for grp in ("a", "b") {
///   for i in range(0, 40) {
///     d.push((x: calc.sin(i * 0.3) * 5 + i * 0.2 + (if grp == "b" { 2 } else { 0 }), grp: grp))
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "x", colour: "grp"),
///   layers: (geom-freqpoly(bins: 12, stroke: 1pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@geom-histogram, \@stat-bin, \@geom-line
#let geom-freqpoly(
  mapping: none,
  data: none,
  bins: 30,
  binwidth: none,
  stroke: auto,
  colour: auto,
  alpha: auto,
  linetype: auto,
  position: "identity",
  inherit-aes: true,
) = make-layer(
  "line",
  mapping: mapping,
  data: data,
  params: (
    stroke: stroke,
    colour: colour,
    alpha: alpha,
    linetype: linetype,
  ),
  stat: stat-bin(bins: bins, binwidth: binwidth),
  position: position,
  inherit-aes: inherit-aes,
)
