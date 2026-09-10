// Scatter/data point and line-plot series constructors.

/// Plots discrete data points with markers. Points can optionally be connected
/// by line segments.
#let scatter(

  /// Array of `(x, y)` coordinate pairs to plot.
  /// -> array
  points,

  /// Marker shape to draw at each point (e.g. `"*"`, `"o"`, `"x"`).
  /// -> str
  mark: "*",

  /// Size of each marker in canvas units.
  /// -> float
  mark-size: 0.12,

  /// Fill color for markers.
  /// -> color
  mark-fill: blue,

  /// Stroke style for markers.
  /// -> stroke
  mark-stroke: blue + 0.8pt,

  /// Whether to connect consecutive points with line segments.
  /// -> bool
  connect: false,

  /// Stroke style for connecting lines. Only used when `connect` is `true`.
  /// -> stroke | none
  stroke: none,

  /// Legend label for this series. `none` omits it from the legend.
  /// -> content | none
  label: none,

  /// Position along the series (0 to 1) where the inline label is placed.
  /// -> float
  label-pos: 0.8,

  /// CeTZ anchor for the inline label relative to its point on the series.
  /// -> str
  label-anchor: "south-west",
) = (
  points: points, mark: mark, mark-size: mark-size,
  mark-fill: mark-fill, mark-stroke: mark-stroke,
  connect: connect, stroke: stroke, label: label,
  label-pos: label-pos, label-anchor: label-anchor,
)

/// Alias for `scatter()`.
#let data = scatter

/// Plots discrete data points connected by line segments with markers at each
/// vertex. A convenience wrapper around `scatter()` with `connect: true`.
#let line-plot(

  /// Array of `(x, y)` coordinate pairs to plot.
  /// -> array
  points,

  /// Stroke style for the connecting lines.
  /// -> stroke
  stroke: blue + 1.2pt,

  /// Marker shape drawn at each point.
  /// -> str
  mark: "o",

  /// Size of each marker in canvas units.
  /// -> float
  mark-size: 0.1,

  /// Fill color for markers.
  /// -> color
  mark-fill: white,

  /// Stroke style for markers.
  /// -> stroke
  mark-stroke: blue + 0.8pt,

  /// Legend label for this series. `none` omits it from the legend.
  /// -> content | none
  label: none,

  /// Position along the series (0 to 1) where the inline label is placed.
  /// -> float
  label-pos: 0.8,

  /// CeTZ anchor for the inline label relative to its point on the series.
  /// -> str
  label-anchor: "south-west",
) = (
  points: points, stroke: stroke, mark: mark,
  mark-size: mark-size, mark-fill: mark-fill,
  mark-stroke: mark-stroke, connect: true,
  label: label, label-pos: label-pos, label-anchor: label-anchor,
)
