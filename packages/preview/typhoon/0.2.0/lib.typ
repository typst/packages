#let _plugin = plugin("main.wasm")
/// The default state. You can bring your own state and initialize it with an empty dictionary.
#let tailwind-state = state("TAILWIND_CSS_GENERATION_STATE+alotofentropy", (:))

/// Generate Tailwind CSS string with a config.
#let tailwind-css(config: auto, state: tailwind-state) = {
  let classes = state.final().keys().join(" ")
  let config = if config == auto {
    (:)
  } else {
    config
  }
  str(_plugin.generate(bytes(classes), cbor.encode(config)))
}

/// Extract classes from html elems and update the state.
#let update-elem(elem, state: tailwind-state) = {
  let classes = elem.attrs.at("class", default: ())
  let classes = if type(classes) == str { classes.split(" ") } else { classes }
  state.update(d => d + classes.map(c => (c, none)).to-dict())
  elem
}
