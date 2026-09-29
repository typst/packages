///! Coordinate-level transformation via `coord_transform()`.

/// Transform the displayed coordinates after statistics have run.
///
/// Sets the per-axis `transform` so the trained scale's view is warped at
/// mapping time. Accepts the same keywords as `scale-x-continuous`'s
/// `transform:` parameter: `"identity"`, `"log10"`, `"sqrt"`, `"reverse"`.
///
/// When a positional scale already sets `transform:`, `coord-transform`
/// overrides it for that axis.
///
/// \@category Coord
/// \@stability stable
/// \@since 0.4.0
///
/// \@param x Transformation keyword for the x axis.
///
/// \@param y Transformation keyword for the y axis.
///
/// \@returns Coordinate dictionary consumed by \@plot.
///
/// \@examples Log10 the x and y axes without setting `transform:` on each scale.
/// ```
/// //| alt: "Scatter chart with both axes log10-transformed at the coordinate level; three points (1, 1), (10, 100), (100, 10000) fall on a straight line in log space."
/// #let d = (
///   (x: 1, y: 1),
///   (x: 10, y: 100),
///   (x: 100, y: 10000),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 3pt),),
///   coord: coord-transform(x: "log10", y: "log10"),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@plot, \@scale-x-continuous
#let coord-transform(x: "identity", y: "identity") = (
  kind: "coord",
  coord: "transform",
  x: x,
  y: y,
)
