#import "../anchors.typ" as anchors
#import "../objects/object.typ": object, alias

/// Creates an object of type "trajectory"
#let trajectory(fn, range, scale: 1, epsilon: 0.001%, ..stops) = {
  if stops.pos().len() > 0 { panic("Unexpected positional arguments.") }

  let stops = stops.named()

  let to-t(t) = if type(t) == ratio { 
    range.first() + (range.last() - range.first()) * t/100% 
  } else { t }
  let rotation-at(fn, t) = {
    let epsilon = if type(epsilon) == ratio { 
      epsilon/100% * (range.last() - range.first()) 
    } else { epsilon }

    epsilon = calc.min(epsilon, (range.last() - range.first()) / 2)

    return if t + epsilon < range.last() {
      calc.atan2(fn(t + epsilon).at(0) - fn(t).at(0), fn(t + epsilon).at(1) - fn(t).at(1))
    } else {
      calc.atan2(fn(t).at(0) - fn(t - epsilon).at(0), fn(t).at(1) - fn(t - epsilon).at(1))
    }
  }

  let fn-first = fn(range.first())
  let fn-last = fn(range.last())

  return object("trajectory", "origin", 
    (
      "origin": anchors.anchor(0,0,0deg),
      "start": anchors.anchor(
        fn-first.at(0) * scale, 
        fn-first.at(1) * scale, 
        rotation-at(fn, range.first())
      ),
      ..for (name, t) in stops {
        t = to-t(t)
        let fn-t = fn(t)
        ((name): anchors.anchor(
          fn-t.at(0) * scale,
          fn-t.at(1) * scale,
          rotation-at(fn, t)
        ))
      },
      "end": anchors.anchor(
        fn-last.at(0) * scale, 
        fn-last.at(1) * scale,
        rotation-at(fn, range.last())
      ),
    ),
    data: (fn: fn, range: range, scale: scale, stops: stops)
  )
}