#import "../anchors.typ" as anchors
#import "../objects/object.typ": object, alias

/// Creates an object of type "terrain", which is a 2D shape
/// flat on the bottom and a profile describe by the positive
/// function `fn`.
/// Extra named arguments can be used to request for the
/// placement of additional anchors on the surface of the terrain
/// that are automatically rotated to match the function slope at the point
/// (thanks to simple numerical differentiation of the function) 
#let terrain(fn, range, scale: 1, epsilon: 0.001%, ..stops) = {
  if stops.pos().len() > 0 { panic("Unexpected positional arguments.") }

  let stops = stops.named()

  let to-x(x) = if type(x) == ratio { 
    range.first() + (range.last() - range.first()) * x/100% 
  } else { x }
  let rotation-at(fn, x) = {
    let epsilon = if type(epsilon) == ratio { 
      epsilon/100% * (range.last() - range.first()) 
    } else { epsilon }

    epsilon = calc.min(epsilon, (range.last() - range.first()) / 2)

    return if x + epsilon < range.last() {
      calc.atan2(epsilon, fn(x + epsilon) - fn(x))
    } else {
      calc.atan2(epsilon, fn(x) - fn(x - epsilon))
    }
  }

  return object("terrain", "origin", 
    (
      "origin": anchors.anchor(0,0,0deg),
      "start": anchors.anchor(
        range.first()*scale, 
        fn(range.first()) * scale, 
        rotation-at(fn, range.first())
      ),
      ..for (name, x) in stops {
        x = to-x(x)
        ((name): anchors.anchor(
          x*scale,
          fn(x)*scale,
          rotation-at(fn, x)
        ))
      },
      "end": anchors.anchor(
        range.last()*scale, 
        fn(range.last())*scale,
        rotation-at(fn, range.last())
      ),

      "bl": anchors.anchor(range.first()*scale,0*scale,180deg),
      "b":  anchors.anchor(to-x(50%)*scale,0*scale,180deg),
      "br": anchors.anchor(range.last()*scale,0*scale,180deg),
      
      "lt": anchors.anchor(range.first()*scale,fn(range.first())*scale, 90deg),
      "l": anchors.anchor(range.first()*scale,fn(range.first())*scale/2, 90deg),
      "lb": anchors.anchor(range.first()*scale,0*scale, 90deg),

      "rt": anchors.anchor(range.last()*scale, fn(range.last())*scale, 270deg),
      "r": anchors.anchor(range.last()*scale, fn(range.last())*scale/2, 270deg),
      "rb": anchors.anchor(range.last()*scale, 0*scale, 270deg),
    ),
    data: (fn: fn, range: range, scale: scale, stops: stops)
  )
}