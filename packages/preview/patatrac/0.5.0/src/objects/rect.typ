#import "../anchors.typ" as anchors
#import "../objects/object.typ": object

/// Creates an object of type "rectangle" centered at the origin with the given width and height
#let rect(width, height) = object("rect", "c",
  (
    // do not use (0,0) which would assume unitless coordinates
    "c": anchors.anchor(width*0, height*0, 0deg), 

    "tl": anchors.anchor(-width/2, +height/2, 0deg),
    "t": anchors.anchor(0*width, +height/2, 0deg),
    "tr": anchors.anchor(+width/2, +height/2, 0deg),

    "lt": anchors.anchor(-width/2, +height/2, 90deg),
    "l": anchors.anchor(-width/2, 0*height, 90deg),
    "lb": anchors.anchor(-width/2, -height/2, 90deg),
    
    "bl": anchors.anchor(-width/2, -height/2, 180deg),
    "b": anchors.anchor(0*width, -height/2, 180deg),
    "br": anchors.anchor(+width/2, -height/2, 180deg),

    "rt": anchors.anchor(+width/2, +height/2, 270deg),
    "r": anchors.anchor(+width/2, 0*height, 270deg),
    "rb": anchors.anchor(+width/2, -height/2, 270deg),
  ),
  data: ("width": width, "height": height)
)