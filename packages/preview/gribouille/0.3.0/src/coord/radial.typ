///! Radial coordinate system.

/// Radial coordinate system.
///
/// `theta = "x"` (default) distributes categories around the circle for rose / radar layouts; `theta = "y"` turns stacked y values into wedges for pie / donut layouts.
///
/// - theta: Which axis is angular: `"x"` (default) or `"y"`. The radial axis (the other one) automatically drops its lo-side expansion to zero so bars meet at radius 0; pass an explicit `expand:` on the radial scale to override.
/// - start: Offset in radians from 12 o'clock for the first slice.
/// - end: Offset in radians from 12 o'clock for the sweep end. `none` (default) means a full sweep in the requested `direction`. On a full sweep where the angular domain endpoints land on the same canvas angle, the two ticks merge into a single `"end/start"` label.
/// - direction: `1` (default) advances clockwise; `-1` counter-clockwise.
/// - clip: `"off"` (default) lets marks render past the panel rectangle; `"on"` clips.
///
/// Returns: Coordinate dictionary consumed by `plot`.
///
/// See also: `plot`, `geom-col`.
///
/// Pie chart from a stacked column.
///
/// ```typst
/// #let d = (
///   (slice: "all", value: 30, kind: "A"),
///   (slice: "all", value: 20, kind: "B"),
///   (slice: "all", value: 50, kind: "C"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "slice", y: "value", fill: "kind"),
///   layers: (geom-col(width: 1, position: "stack"),),
///   coord: coord-radial(theta: "y"),
///   width: 7cm,
///   height: 7cm,
/// )
/// ```
#let coord-radial(
  theta: "x",
  start: 0,
  end: none,
  direction: 1,
  clip: "off",
) = (
  kind: "coord",
  coord: "radial",
  theta: theta,
  start: start,
  end: end,
  direction: direction,
  clip: clip,
)
