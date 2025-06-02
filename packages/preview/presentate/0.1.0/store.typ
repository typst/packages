#import "utils.typ"

#let prefix = "_presentate_"

#let subslides = state(prefix + "subslides", 1)

// s-pause: first value is the current pause counter, used for conditional hiding, the second value is the maximum number of pauses on the slide.
#let dynamics = state(prefix + "dynamics", (
  pause: 1, 
  steps: 1,
))


#let pauses(i) = state(prefix + "pauses/" + str(i), 1)

// For freezing counters
#let alias-counter(name) = counter(prefix + "cover_" + name + "_counter")

// handout mode
#let default-frozen-counters = (
  "math.equation": (
    real: counter(math.equation),
    cover: alias-counter("math.equation"),
  ),
  "heading": (
    real: counter(heading),
    cover: alias-counter("heading"),
  ),
  "image": (
    real: counter(figure.where(kind: "image")),
    cover: alias-counter("image"),
  ),
  "table": (
    real: counter(figure.where(kind: "table")),
    cover: alias-counter("table"),
  ),
  "quote": (
    real: counter(quote),
    cover: alias-counter("quote"),
  ),
  "footnote": (
    real: counter(footnote),
    cover: alias-counter("footer"),
  ),
)


// Options you can set.
// - handout: handout mode.
// - drafted: drafted mode, having subslide number shown.
// - freeze-counter: freeze the counters during the overlays.
// - frozen-counters: default counters to be frozen.
// - marker: a function that takes update mark of the dynamic content
// and return to other form. This needs to be set if the output requires
// not to be in content type.
// - cover: hide function used by reserving space covering function, i.e. uncover.
// - clear: hide function used by not reserving space covering function, i.e. only, blink, step-transform.
#let default-options = (
  handout: false,
  drafted: false,
  freeze-counter: true,
  frozen-counters: default-frozen-counters,
)

#let settings = state(
  prefix + "setting",
  default-options,
)

#let set-options(..options) = {
  options = options.named()
  settings.update(opts => utils.merge-dicts(options, base: opts))
}

