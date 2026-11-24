#import "utils.typ"

/// index types :
/// - none: with-previous
/// - auto: after current slide
/// - int: absolute number. Set the pauses state to that number.
/// - array of int: apply the animation on the subslide whose index is in the array, without affecting the pauses.
/// - dictionary: in the form `(rel: int, to: indices)`

// resolve current index
#let _resolve(idx, pauses: 1) = {
  if type(idx) == int {
    return idx
  }
  if idx == auto {
    return pauses + 1
  }
  if idx == none or idx == () {
    return pauses
  }
  if type(idx) == dictionary {
    let ref = _resolve(idx.at("to", default: none), pauses: pauses)
    return ref + idx.at("rel")
  } else {
    panic("Unsupport index " + repr(idx))
  }
}

#let _get-pauses-and-max(indices, max: (1,), pauses: 1) = {
  for idx in indices {
    if type(idx) != array {
      idx = _resolve(idx, pauses : pauses)
      pauses = idx
      max.push(idx)
    } else {
      (_, max) = _get-pauses-and-max(idx, max: max, pauses: pauses)
    }
  }
  return (pauses, max)
}


#let resolve(s, ..inputs) = {
  let inputs = inputs.pos()
  let (info, ..idx) = s
  let pauses = 1
  let max = (1,)

  (pauses, max) = _get-pauses-and-max(idx, max: max, pauses: pauses)

  let results = inputs.map(_resolve.with(pauses: pauses))
  
  return (pauses: pauses, steps: calc.max(..max, ..results), results: results)
}

tests
#let s = ((pauses: 1), (none, auto, (), auto), (), auto, (rel: 1))
#resolve(s, (rel: -1), auto, ())

#let s1 = ((pauses: 1), auto, auto, auto, (rel: -1))
This is #resolve(s1, (rel: -1))

