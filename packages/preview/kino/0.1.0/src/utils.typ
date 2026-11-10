// default zero value
#let get_zero(ty) = {
  if type(ty) == int {
    0
  } else if type(ty) == float {
    0.0
  } else if type(ty) in (angle, length, ratio) {
    ty * 0%
  } else if type(ty) == array {
    ty.map(get_zero)
  } else if type(ty) == function {
    let zero = get_zero(ty(.0))
    _ => zero
  }
}

// default dictionnary for timelines
#let get_default_dict(type: 0%) = {
  ("0": ((get_zero(type), 0, 0, 0, "linear"),))
}

// get maximum block in a timeline
#let get_max_block(timeline) = {
  calc.max(..timeline.values().join().keys().map(int))
}

// get duration of a block in a timeline
#let get_block_duration(timeline, block) = {
  calc.max(
    ..timeline
      .values()
      .map(dict => dict.pairs())
      .join()
      .map(pair => {
        let (b, l) = pair
        if b != str(block) { 0 } else {
          let (_, ho, du, dw, _) = l.at(-1)
          ho + du + dw
        }
      }),
  )
}

// checks if animation variables have the same type.
#let check_types((old, new)) = {
  let old_type = type(old)
  let new_type = type(new)
  if old_type != float and new_type != int {
    assert(
      old_type == new_type,
      message: "Cannot modify types of animated variables, "
        + " from "
        + str(old_type)
        + " to "
        + str(new_type)
        + ".",
    )
  }
  if old_type == array {
    let _ = old.zip(new).map(check_types)
  }
  if old_type == function {
    check_types((old(0), new(0)))
  }
}

// simplest rescaling function
#let scale_value(start, end, t) = {
  start + t * (end - start)
}

// computes a rescaling function for animation variables of a given type.
#let get_scaler(ty) = {
  if type(ty) in (float, ratio, length, angle) {
    return scale_value
  } else if type(ty) == int {
    return (start, end, t) => calc.floor(scale_value(start, end, t))
  } else if type(ty) == array {
    let scalers = ty.map(get_scaler)
    return (start, end, t) => scalers
      .zip(start, end)
      .map(i => {
        let (scaler, s, e) = i
        scaler(s, e, t)
      })
  } else if type(ty) == function {
    let scaler = get_scaler(ty(0))
    return (start, end, t) => (x => scaler(start(x), end(x), t))
  }
}
