#import "@preview/cetz:0.4.2"
#import "util.typ": foreach-task, id-level, styles-for-id, task-anchor-sidebar

#let draw-task-dividers(styles, id, task) = {
  import cetz.draw: *

  if not (id.last() == 0 and id-level(id) == 0) {
    let anchor = task-anchor-sidebar(id) + ".divider"
    line(
      ("field.west", "|-", anchor),
      ("field.east", "|-", anchor),
      ..styles-for-id(id, styles),
    )
  }
}

/// The default style.
///
/// #raw(repr(gantty.dividers.default-styles), lang: "typc")
/// -> array
#let default-styles = (
  (stroke: black),
  (stroke: (paint: luma(66%), thickness: 0.5pt)),
  (stroke: (paint: luma(88%), thickness: 0.5pt)),
)

/// The default drawer for the dividers.
/// -> cetz
#let default-dividers-drawer(
  /// The gantt chart.
  /// -> gantt
  gantt,
  /// The style.
  /// -> array
  styles: default-styles,
) = {
  foreach-task(gantt, draw-task-dividers.with(styles))
}
