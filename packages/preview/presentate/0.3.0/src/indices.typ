#import "utils.typ"

/// index types :
/// - none: with-previous
/// - auto: after current slide
/// - int: absolute number. Set the pauses state to that number.
/// - array of int: apply the animation on the subslide whose index is in the array, without affecting the pauses.
/// - dictionary: in the form `(rel: int, to: indices)`

// resolve current index
#let _resolve(idx, info: (pauses: 1, waypoints: (:))) = {
  if type(idx) == int {
    return idx
  }
  if idx == auto {
    return info.pauses + 1
  }
  if idx == none or idx == () {
    return info.pauses
  }
  if type(idx) in (str, label) {
    return info.waypoints.at(str(idx))
  }
  if type(idx) == dictionary {
    let ref = _resolve(idx.at("to", default: none), info: info)
    return ref + idx.at("rel")
  } else {
    panic("Unsupport index " + repr(idx))
  }
}

#let _get-pauses-max-waypoints(indices, info: (max: (1,), pauses: 1, waypoints: (:))) = {
  for idx in indices {
    if type(idx) == dictionary and "name" in idx.keys() {
      info.waypoints.insert(str(idx.name), _resolve(idx.at("at", default: none), info: info))
    } else if type(idx) != array {
      idx = _resolve(idx, info: info)
      info.pauses = idx
      info.max.push(idx)
    } else {
      let new-info = _get-pauses-max-waypoints(idx, info: info)
      info.max = new-info.max
    }
  }
  return info
}


#let resolve(s, ..inputs) = {
  let inputs = inputs.pos()
  let (_, ..idx) = s
  let waypoints = s.at(0).at("waypoints", default: (:))
  let info = (pauses: 1, max: (1,), waypoints: waypoints)

  let info = _get-pauses-max-waypoints(idx, info: info)

  let results = inputs.map(_resolve.with(info: info))

  return (
    pauses: info.pauses,
    steps: calc.max(..info.max, ..results),
    results: results,
    waypoints: info.waypoints,
  )
}

tests
#let s = ((pauses: 1), (none, auto, (), auto), (), auto, (rel: 1))
#resolve(s, (rel: -1), auto, ())

#let s1 = ((pauses: 1), auto, auto, auto, (rel: -1))
This is #resolve(s1, (rel: -1))

#let s = ((pauses: 1), auto, (name: <here>, at: (rel: -1)), auto, (<here>,), auto, (rel: -1))
Named test #resolve(s, <here>)
