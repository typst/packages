#import "utils.typ"
#import "store.typ": prefix
#import "element.typ"
/// freeze the states by update the location back to the start location of the slide.
/// Same logic with Touying.

#let start-location = state(prefix + "_start_location")

#let freeze-states-mark(states) = {
  let loc = start-location.get()
  if states.at(0).freeze-states {
    states.at(0).frozen-states-and-counters.map(c => c.update(c.at(loc))).join()
  }
}

