#import "../anchors.typ" as anchors
#import "../objects/object.typ": object, alias

/// Creates an object of type "spring", representing an physical spring.
#let spring(start, end) = {
  let start = anchors.to-anchor(start) 
  let end = anchors.to-anchor(end) 

  start = anchors.x-look-at(start, end)
  end = anchors.anchor(end.x, end.y, start.rot)

  return object("spring", "start", 
    (
      "start": start,
      "c": anchors.lerp(start, end, 50%),
      "end": end,
    ),
    data: ("length": anchors.distance(start, end))
  )
}