#import "./util.typ": is-int, max-by, partition

#let to-bool(v) = if type(v) == int {
  if v == 0 { false } else { true }
} else {
  panic("Cannot convert to bool.")
}

/// Convert dictionaries to arguments. Main use case is dynamic argument names.
///
/// Numeric keys are treated as positional arguments.
#let to-arguments(v) = if type(v) == dictionary {
  let (pos, named) = partition(v.pairs(), f: ((k, _)) => is-int(k))
  let pos-sorted = pos.map(((k, v)) => (int(k), v)).sorted(key: ((k, _)) => k)
  assert(
    pos-sorted.map(((k, _)) => k) == range(pos-sorted.len()),
    message: "All numeric keys between 0 and the maximum key must be present.",
  )
  arguments(..pos-sorted.map(((_, v)) => v), ..named.to-dict())
} else {
  panic("Cannot convert values of type " + str(type(v)) + " to arguments.")
}
