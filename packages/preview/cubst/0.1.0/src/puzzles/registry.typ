// The list of puzzles and how an event name maps to one of them.
//
// To add a puzzle: write `src/puzzles/<name>.typ` exporting a `puzzle`
// dictionary with the same fields as the existing ones, and list it here.

#import "cube.typ" as cube
#import "skewb.typ" as skewb
#import "pyraminx.typ" as pyraminx
#import "megaminx.typ" as megaminx
#import "square1.typ" as square1

#let puzzles = (
  cube: cube.puzzle,
  skewb: skewb.puzzle,
  pyraminx: pyraminx.puzzle,
  megaminx: megaminx.puzzle,
  square1: square1.puzzle,
)

/// `(puzzle: name, params: ..)` for an event such as "3x3", "7x7", "skewb".
/// `options` are puzzle-specific settings (see each puzzle's `options`
/// dictionary for the keys and defaults, e.g. the megaminx `cut`); they are
/// merged into `params`, and unknown keys are rejected.
#let resolve(event, options: (:)) = {
  assert(type(event) == str, message: "cubst: event must be a string such as \"3x3\", got " + repr(event))
  assert(type(options) == dictionary, message: "cubst: options must be a dictionary, got " + repr(options))
  let e = lower(event.trim())
  for (name, p) in puzzles {
    let params = (p.event)(e)
    if params != none {
      let defaults = p.at("options", default: (:))
      for key in options.keys() {
        assert(
          key in defaults,
          message: "cubst: " + (p.event-name)(params) + " has no option " + repr(key) + if defaults.len() == 0 {
            " (it has no options)"
          } else { "; options are " + defaults.keys().join(", ") },
        )
      }
      return (puzzle: name, params: params + defaults + options)
    }
  }
  panic("cubst: unknown event " + repr(event) + "; expected NxN (e.g. \"3x3\"), \"skewb\", \"pyraminx\", \"megaminx\" or \"square1\"")
}

/// The puzzle definition behind a state.
#let of(c) = puzzles.at(c.puzzle)

/// The geometric model behind a state. Most puzzles have a fixed model per
/// parameter set; a puzzle whose shape depends on the state (Square-1)
/// provides `model-of(state)` instead.
#let model(c) = {
  let p = of(c)
  if "model-of" in p { (p.model-of)(c) } else { (p.model)(c.params) }
}
