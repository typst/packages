// Demo document for the confy Typst package.
//
// This demo imports the reusable function from confusion.typ and renders
// the same example as in the original cm.typ, with a different colormap.

#import "confusion.typ": confy

#let labels = ("Covered", "ConditionUnmet", "NotCovered", "Uncertain")
#let M = (
  (18, 3, 6, 2),
  (2, 31, 3, 2),
  (1, 0, 16, 1),
  (2, 2, 0, 28),
)

#set page(margin: 1.5cm)

= Confusion Matrix Demo

== Basic Example
#confy(
  labels,
  M,
  title-row: "Predicted",
  title-col: "Ground Truth",
  cell-size: 1.3,
  show-colorbar: true,
)

#v(1cm)
== Customized Example
#confy(
  labels,
  M,
  title-row: "Predicted",
  title-col: "Ground Truth",
  cell-size: 1.75,
  cmap: color.map.mako,
  show-colorbar: true,
  label-rotate: -40deg,
  value-font-size: 8.5pt,
  colorbar-ticks: 14,
)
