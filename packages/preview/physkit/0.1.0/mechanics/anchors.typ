#import "../geometry/lib.typ" as geometry

/// Resolve an object anchor after constraints have positioned the object.
#let object-anchor(object, anchor) = {
  if object.kind == "box" {
    geometry.rectangle-anchor(
      object.at,
      object.width,
      object.height,
      object.angle,
      anchor,
    )
  } else if object.kind == "pulley" {
    geometry.circle-anchor(object.at, object.radius, anchor: anchor)
  } else if object.kind == "surface" or object.kind == "inclined-plane" {
    geometry.surface-anchor(object.start, object.end, anchor)
  } else {
    panic("Cannot resolve anchors for object kind: " + object.kind)
  }
}
