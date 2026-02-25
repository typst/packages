#import "utils.typ"

/// index types :
/// - none: with-previous
/// - auto: after current slide
/// - int: absolute number. Set the pauses state to that number.
/// - array of int: apply the animation on the subslide whose index is in the array, without affecting the pauses.
/// - dictionary: in the form `(rel: int, to: indices)`

#let resolve-indices(s, ..inputs) = {
  let inputs = inputs.pos()
  let (info, ..idx) = s
  let pauses = 1
  let saved = ()
  let max = (1,)

  let _get-pauses-and-max(idx, max: max, pauses: pauses) = {
    for i in idx {
      if i == auto {
        pauses += 1
        max.push(pauses)
      } else if type(i) == int {
        pauses = i
        max.push(pauses)
      } else if type(i) == array {
        (_, max) = _get-pauses-and-max(i, max: max, pauses: pauses)
      } else if type(i) == dictionary {
        assert(
          "rel" in i.keys(),
          message: "Relative Index must at least be in the form `(rel: int)`.",
        )
        let ref = i.at("to", default: none)
        if ref == auto {
          ref = pauses + 1
        } else if ref == none {
          ref = pauses
        } else {
          panic("Cannot resolve relative index.")
        }
        max.push(ref + i.at("rel"))
      }
    }
    return (pauses, max)
  }

  (pauses, max) = _get-pauses-and-max(idx)

  // resolve current index
  let _resolve(idx, pauses: 1) = {
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
  let results = inputs.map(_resolve.with(pauses: pauses))

  return (pauses: pauses, steps: calc.max(..max, ..results), results: results)
}

tests
#let s = ((pauses: 1), (none, auto, (), auto), (), auto, (rel: 1))
#resolve-indices(s, auto, ())
