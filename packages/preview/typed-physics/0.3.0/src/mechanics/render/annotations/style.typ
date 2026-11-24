// How an annotation's own colour, stroke, and text settle against the diagram
// style it is drawn in. An annotation that declares none of them inherits the
// figure's annotation defaults, so a set of annotations reads as one layer.

#let annotation-color(diagram-style, annotation) = if annotation.color == auto {
  diagram-style.annotation-color
} else {
  annotation.color
}

#let annotation-stroke(diagram-style, annotation, color) = (
  if annotation.stroke == auto {
    diagram-style.annotation-stroke
  } else {
    annotation.stroke
  }
) + color

#let annotation-text-style(diagram-style, annotation, color) = (
  (fill: color) + diagram-style.annotation-text + annotation.text
)

// Which side of a label the leader reaches, so a label placed north-east of a
// point rests its south-west corner there and grows away from the figure.
#let anchor-facing(direction-angle) = {
  let turns = calc.rem(direction-angle.deg() + 360, 360)
  let compass-anchors = (
    "west", "south-west", "south", "south-east", "east", "north-east",
    "north", "north-west",
  )
  compass-anchors.at(calc.rem(int(calc.round(turns / 45)), 8))
}
