#import "utils.typ"
#import "indices.typ"

#let prefix = "_presentate"

#let default-states = (
  (
    /// initial number of subslides required for rendering pauses
    pauses: 1,
    /// number of subslides required
    steps: 1,
    /// current number of subslides
    subslide: 1,
    /// modes
    handout: false,
    drafted: false,
    /// frozen states and counters
    freeze-states: true,
    frozen-states-and-counters: (
      counter(figure.where(kind: image)),
      counter(figure.where(kind: table)), 
      counter(footnote),
      counter(heading), 
      counter(math.equation), 
    ),
    add-page-index: 0, // for pdfpc and BeamerPresenter.
    logical-slide: true,
  ),
)

#let states = state(prefix + "_states", default-states)

#let set-options(..options) = {
  options = options.named()
  states.update(s => {
    s.at(0) = utils.merge-dicts(base: s.at(0), options)
    return s
  })
}

#let is-kind(thing, kind) = {
  if (
    type(thing) == content
      and thing.func() == metadata
      and type(thing.value) == dictionary
      and thing.value.kind == prefix + kind
  ) {
    true
  } else { false }
}