///! Coordinate-level transformation via `coord_transform()`.

/// Transform the displayed coordinates after statistics have run.
///
/// Sets the per-axis `transform` so the trained scale's view is warped at mapping time. Accepts the same keywords as `scale-x-continuous`'s `transform:` parameter: `"identity"`, `"log10"`, `"sqrt"`, `"reverse"`.
///
/// When a positional scale already sets `transform:`, `coord-transform` overrides it for that axis.
///
/// - x: Transformation keyword for the x axis.
/// - y: Transformation keyword for the y axis.
///
/// Returns: Coordinate dictionary consumed by `plot`.
///
/// See also: `plot`, `scale-x-continuous`.
///
/// Log10 the x and y axes without setting `transform:` on each scale.
///
/// ```typst
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
#let coord-transform(x: "identity", y: "identity") = (
  kind: "coord",
  coord: "transform",
  x: x,
  y: y,
)
