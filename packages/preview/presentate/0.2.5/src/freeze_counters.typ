#import "utils.typ"
#import "store.typ": prefix, states

/// freeze the states by update the location back to the start location of the slide.
/// Same logic with Touying.

#let start-location = state(prefix + "_start_location")

#let freeze-states-mark() = {
  let (info, ..x) = states.get()
  let loc = start-location.get()
  if info.freeze-states {
    info.frozen-states-and-counters.map(c => c.update(c.at(loc))).join()
  }
}

