#import "../anchors.typ" as anchors
#import "../objects/object.typ": object

/// Creates an object constituted by a single anchor.
/// If `rot` is set to `false` the anchor's rotation is set to `0deg`. 
#let point(at, rot: true) = {
  let anc = anchors.to-anchor(at)
  if not rot { anc = anchors.anchor(anc.x, anc.y, 0deg) }
  return object("point", "c", ("c": anc))
}