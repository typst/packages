#import "@preview/cetz:0.4.2"

/// Draws the rectangle within which the task(group)s are placed
/// -> cetz
#let default-field-drawer(
  /// The Gantt chart
  /// -> gantt
  gantt,
  /// The style of the field
  /// -> style
  style: (stroke: black),
) = {
  import cetz.draw: *
  rect(
    name: "field",
    "sidebar.north-east",
    ((1, 0), "|-", "sidebar.south-east"),
    ..style,
  )
}
