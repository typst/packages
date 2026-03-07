#import "../anchors.typ" as anchors
#import "../objects/object.typ": object, alias

/// Creates an object of type "arrow", representing an arrow
/// pointing from the location of the anchor `start` towards the normal
/// direction to `start` of total length `length`. If `angle` is not `none`
/// the anchor rotation is ignored and `angle` is used instead.
#let arrow(start, length, angle: none) = {
  let start = anchors.to-anchor(start) 
  if angle != none { start = anchors.anchor(start.x, start.y, angle - 90deg) }
  return object("arrow", "start", 
    (
      "start": start,
      "c": anchors.slide(start, length*0, length/2),
      "end": anchors.slide(start, length*0, length),
    ),
    data: ("length": length)
  )
}