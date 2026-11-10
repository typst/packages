#import "../anchors.typ" as anchors: anchor, to-anchor
#import "../objects/object.typ": object

/// Creates an object of type "circle" centered at the origin with the given radius
#let circle(radius) = {
  let sqrt2 = calc.sqrt(2)
  return object("circle", "c", data: ("radius": radius), (
    "c": anchor(radius*0, radius*0, 0deg), // do not use (0,0) which would assume unitless coordinates
    
    "t": anchor(radius*0, +radius, 0deg),

    // "lt": anchor(-radius/sqrt2, +radius/sqrt2, 45deg),
    "tl": anchor(-radius/sqrt2, +radius/sqrt2, 45deg),
    
    "l": anchor(-radius, radius*0, 90deg),
    
    "bl": anchor(-radius/sqrt2, -radius/sqrt2, 90deg+45deg),
    // "lb": anchor(-radius/sqrt2, -radius/sqrt2, 90deg+45deg),
    
    "b": anchor(radius*0, -radius, 180deg),

    // "rb": anchor(+radius/sqrt2, -radius/sqrt2, 180deg+45deg),
    "br": anchor(+radius/sqrt2, -radius/sqrt2, 180deg+45deg),
    
    "r": anchor(+radius, radius*0, 270deg),

    "tr": anchor(+radius/sqrt2, +radius/sqrt2, 270deg+45deg-360deg),
    // "rt": anchor(+radius/sqrt2, +radius/sqrt2, 270deg+45deg-360deg),
  ))
}