///! Linetype scale.
///!
///! Maps discrete levels onto CeTZ dash keywords consumed by \@geom-line
///! (`"solid"`, `"dashed"`, `"dotted"`, `"dash-dotted"`, etc.).

#import "../utils/palette.typ": default-linetypes

/// Discrete linetype scale: maps levels to dash-pattern keywords.
///
/// Pass a custom array of keywords via `palette` to override the default linetype set.
///
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - palette: Array of dash keywords, or `auto` for the library default.
/// - limits: Array of level names controlling order and inclusion, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - labels: Array of legend labels aligned with `limits`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-linetype-manual`, `geom-line`.
///
/// Default linetype palette mapping two groups to distinct dash patterns.
///
/// ```typst
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
/// Override `palette` with a custom keyword cycle.
///
/// ```typst
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
/// Keywords cycle through `values` following the alphabetical level order, unless `limits` fixes a different order.
///
/// - values: Array of dash keywords, one per level.
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - limits: Array of level names controlling order and inclusion, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - labels: Array of legend labels aligned with `limits`, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-linetype`, `geom-line`.
///
/// Two-keyword cycle following the default alphabetical order: group a takes solid, group b takes dashed.
///
/// ```typst
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
/// `limits` reorders the levels: listing b first makes group b take solid and group a take dashed, reversing the default.
///
/// ```typst
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
/// The mapped column must contain dash keywords accepted by `geom-line` (`"solid"`, `"dashed"`, `"dotted"`, `"dash-dotted"`, `"densely-dashed"`, `"loosely-dashed"`).
///
/// - name: Legend title. Identity scales draw no legend.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-linetype`, `scale-linetype-manual`, `geom-line`.
///
/// Per-row dash keyword carried straight through to the line.
///
/// ```typst
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
#let scale-linetype-identity(name: none) = (
  kind: "scale",
  aesthetic: "linetype",
  type: "identity",
  name: name,
)

/// Binned linetype scale: cuts a continuous variable into `n-breaks` bins, each bin gets one dash keyword from `palette`.
///
/// The scale stays continuous: the trained domain is numeric and the resolver snaps each row to the bin its value falls into.
///
/// - n-breaks: Number of bins to partition the continuous domain into.
/// - palette: Array of dash keywords, one per bin, or `auto` for the library default.
/// - name: Legend title. Overrides any name set via `labs` when both are present.
/// - limits: Continuous `(lo, hi)` pair pinning the domain, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - labels: Array of legend labels aligned with bin midpoints, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-linetype`, `scale-linetype-manual`, `geom-line`.
///
/// Bin a continuous quality column into three linetype buckets.
///
/// ```typst
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

/// Continuous linetype scale: alias of `scale-linetype-binned` with the default bin count. Provided as an explicit-name alias.
///
/// - name: Legend title.
/// - palette: Array of dash keywords, or `auto`.
/// - limits: Continuous `(lo, hi)` pair, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - labels: Array of legend labels, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-linetype-binned`, `scale-linetype`, `geom-line`.
///
/// Map a numeric column onto a dash interpolation across four default bins.
///
/// ```typst
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

/// Discrete linetype scale: alias of `scale-linetype`.
///
/// Identical to calling `scale-linetype()` directly; provided as an explicit-name alias.
///
/// - name: Legend title.
/// - palette: Array of dash keywords, or `auto`.
/// - limits: Array of level names, or `none`.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - labels: Array of legend labels, or `auto`.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-linetype`, `geom-line`.
///
/// Discrete dash patterns picked up via the discrete alias.
///
/// ```typst
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
