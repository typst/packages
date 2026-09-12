///! Linetype scale.
///!
///! Maps discrete levels onto CeTZ dash keywords consumed by \@geom-line
///! (`"solid"`, `"dashed"`, `"dotted"`, `"dash-dotted"`, etc.).

#import "../utils/palette.typ": default-linetypes

/// Discrete linetype scale: maps levels to dash-pattern keywords.
///
/// Pass a custom array of keywords via `palette` to override the default
/// linetype set.
///
/// \@category Scales
/// \@subcategory Linetype scales
/// \@stability stable
/// \@since 0.0.1
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param palette Array of dash keywords, or `auto` for the library default.
///
/// \@param limits Array of level names controlling order and inclusion, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param labels Array of legend labels aligned with `limits`, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Default linetype palette mapping two groups to distinct dash
/// patterns.
/// ```
/// //| alt: "Line chart of two groups along x against y where each group renders with a distinct dash pattern drawn from the default linetype palette."
/// #let d = (
///   (x: 1, y: 2, grp: "a"),
///   (x: 2, y: 4, grp: "a"),
///   (x: 3, y: 3, grp: "a"),
///   (x: 1, y: 1, grp: "b"),
///   (x: 2, y: 2, grp: "b"),
///   (x: 3, y: 4, grp: "b"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", linetype: "grp"),
///   layers: (geom-line(stroke: 1pt),),
///   scales: (scale-linetype(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Override `palette` with a custom keyword cycle.
/// ```
/// //| alt: "Line chart of two groups along x against y rendered with the custom dotted and dash-dotted keywords supplied via palette."
/// #let d = (
///   (x: 1, y: 2, grp: "a"), (x: 2, y: 4, grp: "a"),
///   (x: 1, y: 1, grp: "b"), (x: 2, y: 2, grp: "b"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", linetype: "grp"),
///   layers: (geom-line(stroke: 1pt),),
///   scales: (scale-linetype(palette: ("dotted", "dash-dotted")),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-linetype-manual, \@geom-line
#let scale-linetype(
  name: none,
  palette: auto,
  limits: none,
  oob: "drop",
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "linetype",
  type: "discrete",
  name: name,
  palette: if palette == auto { default-linetypes } else { palette },
  limits: limits,
  oob: oob,
  labels: labels,
)

/// Manual discrete linetype scale: supply the dash-keyword array directly.
///
/// Keywords cycle through `values` following the alphabetical level order,
/// unless `limits` fixes a different order.
///
/// \@category Scales
/// \@subcategory Linetype scales
/// \@stability stable
/// \@since 0.0.1
///
/// \@param values Array of dash keywords, one per level.
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
/// \@examples Two-keyword cycle following the default alphabetical order:
/// group a takes solid, group b takes dashed.
/// ```
/// //| alt: "Line chart of two groups along x against y where group a renders solid and group b renders dashed under the default alphabetical level order."
/// #let d = (
///   (x: 1, y: 2, grp: "a"), (x: 2, y: 4, grp: "a"),
///   (x: 1, y: 1, grp: "b"), (x: 2, y: 2, grp: "b"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", linetype: "grp"),
///   layers: (geom-line(stroke: 1pt),),
///   scales: (scale-linetype-manual(values: ("solid", "dashed")),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples `limits` reorders the levels: listing b first makes group b
/// take solid and group a take dashed, reversing the default.
/// ```
/// //| alt: "Line chart of two groups along x against y where limits list b before a so group b renders solid and group a renders dashed, reversing the default alphabetical order."
/// #let d = (
///   (x: 1, y: 2, grp: "a"), (x: 2, y: 4, grp: "a"),
///   (x: 1, y: 1, grp: "b"), (x: 2, y: 2, grp: "b"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", linetype: "grp"),
///   layers: (geom-line(stroke: 1pt),),
///   scales: (scale-linetype-manual(
///     values: ("solid", "dashed"),
///     limits: ("b", "a"),
///   ),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-linetype, \@geom-line
#let scale-linetype-manual(
  values: (),
  name: none,
  limits: none,
  oob: "drop",
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "linetype",
  type: "discrete",
  name: name,
  palette: values,
  limits: limits,
  oob: oob,
  labels: labels,
)

/// Linetype scale that uses each row's value as the dash keyword directly.
///
/// The mapped column must contain dash keywords accepted by \@geom-line
/// (`"solid"`, `"dashed"`, `"dotted"`, `"dash-dotted"`,
/// `"densely-dashed"`, `"loosely-dashed"`).
///
/// \@category Scales
/// \@subcategory Linetype scales
/// \@stability stable
/// \@since 0.0.1
///
/// \@param name Legend title. Identity scales draw no legend.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Per-row dash keyword carried straight through to the line.
/// ```
/// //| alt: "Line chart of two segments along x against y where the dt column passes through verbatim, drawing one solid line and one dashed line."
/// #let d = (
///   (x: 1, y: 2, dt: "solid"),  (x: 2, y: 3, dt: "solid"),
///   (x: 1, y: 1, dt: "dashed"), (x: 2, y: 2, dt: "dashed"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", linetype: "dt"),
///   layers: (geom-line(stroke: 1pt),),
///   scales: (scale-linetype-identity(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-linetype, \@scale-linetype-manual, \@geom-line
#let scale-linetype-identity(name: none) = (
  kind: "scale",
  aesthetic: "linetype",
  type: "identity",
  name: name,
)

/// Binned linetype scale: cuts a continuous variable into `n-breaks` bins,
/// each bin gets one dash keyword from `palette`.
///
/// The scale stays continuous: the trained domain is numeric and the
/// resolver snaps each row to the bin its value falls into.
///
/// \@category Scales
/// \@subcategory Linetype scales
/// \@stability stable
/// \@since 0.4.0
///
/// \@param n-breaks Number of bins to partition the continuous domain into.
///
/// \@param palette Array of dash keywords, one per bin, or `auto` for the library default.
///
/// \@param name Legend title. Overrides any name set via \@labs when both are present.
///
/// \@param limits Continuous `(lo, hi)` pair pinning the domain, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param labels Array of legend labels aligned with bin midpoints, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Bin a continuous quality column into three linetype buckets.
/// ```
/// //| alt: "Line chart of four diagonal lines where the continuous q column is cut into three stepped dash-pattern bands, with the two highest groups collapsing onto the same dash."
/// #let d = (
///   (x: 1, y: 1, q: 1, g: "a"), (x: 2, y: 2, q: 1, g: "a"),
///   (x: 3, y: 3, q: 1, g: "a"), (x: 4, y: 4, q: 1, g: "a"),
///   (x: 1, y: 2, q: 4, g: "b"), (x: 2, y: 3, q: 4, g: "b"),
///   (x: 3, y: 4, q: 4, g: "b"), (x: 4, y: 5, q: 4, g: "b"),
///   (x: 1, y: 3, q: 7, g: "c"), (x: 2, y: 4, q: 7, g: "c"),
///   (x: 3, y: 5, q: 7, g: "c"), (x: 4, y: 6, q: 7, g: "c"),
///   (x: 1, y: 4, q: 10, g: "d"), (x: 2, y: 5, q: 10, g: "d"),
///   (x: 3, y: 6, q: 10, g: "d"), (x: 4, y: 7, q: 10, g: "d"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", linetype: "q", group: "g"),
///   layers: (geom-line(stroke: 1pt),),
///   scales: (scale-linetype-binned(n-breaks: 3),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-linetype, \@scale-linetype-manual, \@geom-line
#let scale-linetype-binned(
  n-breaks: 4,
  palette: auto,
  name: none,
  limits: none,
  oob: "drop",
  labels: auto,
) = (
  kind: "scale",
  aesthetic: "linetype",
  type: "continuous",
  name: name,
  palette: if palette == auto { default-linetypes } else { palette },
  limits: limits,
  oob: oob,
  labels: labels,
  binned: true,
  n-breaks: n-breaks,
)

/// Continuous linetype scale: alias of \@scale-linetype-binned with the
/// default bin count. Provided as an explicit-name alias.
///
/// \@category Scales
/// \@subcategory Linetype scales
/// \@stability stable
/// \@since 0.4.0
///
/// \@param name Legend title.
///
/// \@param palette Array of dash keywords, or `auto`.
///
/// \@param limits Continuous `(lo, hi)` pair, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param labels Array of legend labels, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Map a numeric column onto a dash interpolation across four
/// default bins.
/// ```
/// //| alt: "Line chart of four diagonal lines where the continuous q column is mapped onto four stepped dash patterns via the default binned palette."
/// #let d = (
///   (x: 1, y: 1, q: 1, g: "a"), (x: 2, y: 2, q: 1, g: "a"),
///   (x: 3, y: 3, q: 1, g: "a"), (x: 4, y: 4, q: 1, g: "a"),
///   (x: 1, y: 2, q: 4, g: "b"), (x: 2, y: 3, q: 4, g: "b"),
///   (x: 3, y: 4, q: 4, g: "b"), (x: 4, y: 5, q: 4, g: "b"),
///   (x: 1, y: 3, q: 7, g: "c"), (x: 2, y: 4, q: 7, g: "c"),
///   (x: 3, y: 5, q: 7, g: "c"), (x: 4, y: 6, q: 7, g: "c"),
///   (x: 1, y: 4, q: 10, g: "d"), (x: 2, y: 5, q: 10, g: "d"),
///   (x: 3, y: 6, q: 10, g: "d"), (x: 4, y: 7, q: 10, g: "d"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", linetype: "q", group: "g"),
///   layers: (geom-line(stroke: 1pt),),
///   scales: (scale-linetype-continuous(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-linetype-binned, \@scale-linetype, \@geom-line
#let scale-linetype-continuous(
  name: none,
  palette: auto,
  limits: none,
  oob: "drop",
  labels: auto,
) = scale-linetype-binned(
  n-breaks: 4,
  palette: palette,
  name: name,
  limits: limits,
  oob: oob,
  labels: labels,
)

/// Discrete linetype scale: alias of \@scale-linetype.
///
/// Identical to calling `scale-linetype()` directly; provided as an
/// explicit-name alias.
///
/// \@category Scales
/// \@subcategory Linetype scales
/// \@stability stable
/// \@since 0.4.0
///
/// \@param name Legend title.
///
/// \@param palette Array of dash keywords, or `auto`.
///
/// \@param limits Array of level names, or `none`.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
///
/// \@param labels Array of legend labels, or `auto`.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Discrete dash patterns picked up via the discrete alias.
/// ```
/// //| alt: "Line chart of two groups along x against y where group a renders solid and group b renders dashed via the discrete alias of scale-linetype."
/// #let d = (
///   (x: 1, y: 2, grp: "a"), (x: 2, y: 4, grp: "a"),
///   (x: 1, y: 1, grp: "b"), (x: 2, y: 2, grp: "b"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", linetype: "grp"),
///   layers: (geom-line(stroke: 1pt),),
///   scales: (scale-linetype-discrete(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-linetype, \@geom-line
#let scale-linetype-discrete(
  name: none,
  palette: auto,
  limits: none,
  oob: "drop",
  labels: auto,
) = scale-linetype(
  name: name,
  palette: palette,
  limits: limits,
  oob: oob,
  labels: labels,
)
