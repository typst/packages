/// State containing a dictionary of theorem environment counters.
/// Each dictionary key is a counter name, and each entry is a counter value
/// (array of integers).
/// -> state
#let thm-counters = state("thm-counters", (:))

#let _heading-counter = counter(heading)

/// Update theorem counter
/// See @thm.counter.
#let thm-counter-update(
  /// -> str
  counter,
  /// -> int | array | function
  update
) = {
  return thm-counters.update(x => {
    if type(update) == int {
      x.insert(counter, (update, ))
    } else if type(update) == array {
      x.insert(counter, update)
    } else if type(update) == function {
      x.at(counter) = update(x.at(counter))
    }
    x
  })
}

/// Get theorem counter.
/// Must be wrapped in context.
/// See @thm.counter.
/// -> array
#let thm-counter-get(
  /// -> str
  counter
) = {
  if (counter == "heading") {
    return _heading-counter.get()
  }
  if not counter in thm-counters.get().keys() {
    return (0, )
  }
  return thm-counters.get().at(counter)
}

/// Step theorem counter forward, relative to a `base` and `base-level`.
/// Must be wrapped in context.
/// See @thm.counter, @thm.base, @thm.base-level.
#let thm-counter-step(
  /// -> str
  counter,
  /// -> str
  base: none,
  /// -> int
  base-level: none
) = {
  thm-counter-update("heading", _heading-counter.get())
  thm-counters.update(counters => {
    if not counter in counters.keys() {
      counters.insert(counter, (0, ))
    }

    let tc = counters.at(counter)
    if base != none {
      let bc = counters.at(base)

      // Pad or chop the base count
      if base-level != none {
        if bc.len() < base-level {
          bc = bc + (0,) * (base-level - bc.len())
        } else if bc.len() > base-level{
          bc = bc.slice(0, base-level)
        }
      }

      // Reset counter if the base counter has updated
      if tc.slice(0, -1) == bc {
        counters.at(counter) = (..bc, tc.last() + 1)
      } else {
        counters.at(counter) = (..bc, 1)
      }
    } else {
      // If we have no base counter, just count one level
      counters.at(counter) = (tc.last() + 1, )
    }

    return counters
  })
}
