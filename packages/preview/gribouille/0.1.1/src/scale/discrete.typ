///! Discrete position scales for x and y.
///!
///! Use these when the mapped column is categorical. `limits` controls which
///! levels appear and in what order.

#let _discrete-scale(
  aesthetic,
  name: none,
  limits: none,
  oob: "drop",
  labels: auto,
  expand: auto,
) = (
  kind: "scale",
  aesthetic: aesthetic,
  type: "discrete",
  name: name,
  limits: limits,
  oob: oob,
  labels: labels,
  expand: expand,
)

/// Discrete x scale: axis title, level ordering, and tick labels.
///
/// \@category Scales
/// \@subcategory Position scales
/// \@stability stable
/// \@since 0.0.1
///
/// \@param name Axis title. Overrides any name set via \@labs when both are present.
///
/// \@param limits Array of level names controlling order and inclusion, or `none` for first-seen order.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose level is not in `limits`; `"squish"` behaves like `"drop"` for discrete scales.
///
/// \@param labels Array of tick labels aligned with `limits`, or `auto`.
///
/// \@param expand Padding around the domain. Accepts a `ratio` (`5%`) for proportional breathing room, a `length` (`5pt`) for canvas-space padding, a `relative` (`5pt + 5%`) for both, or a `(lo, hi)` 2-tuple for asymmetric padding. `auto` keeps a 60%-of-slot default on each side; `false` collapses to zero.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Force the level order with `limits` so the bars sit in
/// alphabetical order regardless of input.
/// ```
/// //| alt: "Bar chart with three categorical bars a, b, c on a discrete x axis ordered alphabetically by limits with heights 5, 3, 2."
/// #let d = (
///   (grp: "b", y: 3),
///   (grp: "a", y: 5),
///   (grp: "c", y: 2),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "grp", y: "y"),
///   layers: (geom-col(),),
///   scales: (scale-x-discrete(limits: ("a", "b", "c")),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Provide custom `labels` to display human-friendly tick text
/// without renaming the underlying data.
/// ```
/// //| alt: "Bar chart with three bars on a discrete x axis whose tick labels read Alpha, Beta, Gamma while the underlying levels remain a, b, c."
/// #let d = (
///   (grp: "a", y: 3),
///   (grp: "b", y: 5),
///   (grp: "c", y: 2),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "grp", y: "y"),
///   layers: (geom-col(),),
///   scales: (scale-x-discrete(
///     limits: ("a", "b", "c"),
///     labels: ("Alpha", "Beta", "Gamma"),
///   ),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-y-discrete, \@scale-x-continuous
#let scale-x-discrete(
  name: none,
  limits: none,
  oob: "drop",
  labels: auto,
  expand: auto,
) = _discrete-scale(
  "x",
  name: name,
  limits: limits,
  oob: oob,
  labels: labels,
  expand: expand,
)

/// Discrete y scale: axis title, level ordering, and tick labels.
///
/// \@category Scales
/// \@subcategory Position scales
/// \@stability stable
/// \@since 0.0.1
///
/// \@param name Axis title. Overrides any name set via \@labs when both are present.
///
/// \@param limits Array of level names controlling order and inclusion, or `none` for first-seen order.
///
/// \@param oob Out-of-range policy: `"drop"` (default) removes rows whose level is not in `limits`; `"squish"` behaves like `"drop"` for discrete scales.
///
/// \@param labels Array of tick labels aligned with `limits`, or `auto`.
///
/// \@param expand Padding around the domain. Accepts a `ratio` (`5%`) for proportional breathing room, a `length` (`5pt`) for canvas-space padding, a `relative` (`5pt + 5%`) for both, or a `(lo, hi)` 2-tuple for asymmetric padding. `auto` keeps a 60%-of-slot default on each side; `false` collapses to zero.
///
/// \@returns Scale object consumed by \@plot.
///
/// \@examples Force level order so bars stay in `(a, b, c)` regardless of
/// input order.
/// ```
/// //| alt: "Scatter chart with three points on a discrete y axis whose categories a, b, c sit in forced order from bottom to top via limits."
/// #let d = (
///   (grp: "b", x: 3),
///   (grp: "a", x: 5),
///   (grp: "c", x: 2),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "grp"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-y-discrete(limits: ("a", "b", "c")),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Subset the levels (omit `"b"`) to drop a category from the
/// axis without filtering the underlying data.
/// ```
/// //| alt: "Scatter chart with two points on a discrete y axis showing only categories a and c after limits drops level b without filtering the data."
/// #let d = (
///   (grp: "a", x: 5),
///   (grp: "b", x: 3),
///   (grp: "c", x: 2),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "grp"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-y-discrete(limits: ("a", "c")),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@scale-x-discrete, \@scale-y-continuous
#let scale-y-discrete(
  name: none,
  limits: none,
  oob: "drop",
  labels: auto,
  expand: auto,
) = _discrete-scale(
  "y",
  name: name,
  limits: limits,
  oob: oob,
  labels: labels,
  expand: expand,
)
