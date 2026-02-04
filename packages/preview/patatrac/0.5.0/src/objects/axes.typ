#import "../anchors.typ" as anchors
#import "../objects/object.typ": object

/// Creates an object of type "axes" constituted by two orthogonal lines
/// meeting at the origin. Each line can be symmetrical, meaning it extends
/// into the positive and negative direction by the same amount, or asymmetrical.
/// If an axis is symmetrical its length can be specified with a number or length, otherwise
/// an array `(negative-extension, positive-extension)` is required.
#let axes(at, xlength, ylength, rot: true) = {
  let anc = anchors.to-anchor(at)
  if not rot { anc = anchors.anchor(anc.x, anc.y, 0deg) }

  let xlength = if type(xlength) == array { xlength } else { (xlength, xlength) }
  let ylength = if type(ylength) == array { ylength } else { (ylength, ylength) }

  return object("axes", "c", 
    ("c": anc) + 
    if xlength.at(0) != 0 and xlength.at(0) != 0mm { ("x-": anchors.slide(anc, -xlength.at(0), 0)) } +
    if xlength.at(1) != 0 and xlength.at(1) != 0mm { ("x+": anchors.slide(anc, +xlength.at(1), 0)) } +
    if ylength.at(0) != 0 and ylength.at(0) != 0mm { ("y-": anchors.slide(anc, 0, -ylength.at(0))) } +
    if ylength.at(1) != 0 and ylength.at(1) != 0mm { ("y+": anchors.slide(anc, 0, +ylength.at(1))) }
  , data: (
    xlength: xlength, 
    ylength: ylength, 
  ))
}