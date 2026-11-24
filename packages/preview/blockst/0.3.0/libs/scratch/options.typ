#let scratch-block-options = state("scratch-block-options", (
  theme: "normal",
  stroke-width: auto,
  scale: 100%,
  font: "Helvetica Neue",
  line-numbering: none,
  line-numbers: false,
  line-number-start: 1,
  line-number-first-block: 1,
  line-number-gutter: 24,
  inset-scale: 1.0,
))

#let get-options() = scratch-block-options.get()

#let get-theme(options) = options.at("theme", default: "normal")

#let get-scale(options) = options.at("scale", default: 100%)

#let get-font(options) = options.at("font", default: "Helvetica Neue")

#let _line-numbering(options) = options.at("line-numbering", default: none)

#let get-line-numbers(options) = {
  let numbering = _line-numbering(options)
  if type(numbering) == bool {
    numbering
  } else if type(numbering) == dictionary {
    numbering.at("enabled", default: options.at("line-numbers", default: false))
  } else {
    options.at("line-numbers", default: false)
  }
}

#let get-line-number-start(options) = {
  let numbering = _line-numbering(options)
  if type(numbering) == dictionary {
    numbering.at("start", default: options.at("line-number-start", default: 1))
  } else {
    options.at("line-number-start", default: 1)
  }
}

#let get-line-number-first-block(options) = {
  let numbering = _line-numbering(options)
  if type(numbering) == dictionary {
    numbering.at("first-block", default: options.at("line-number-first-block", default: 1))
  } else {
    options.at("line-number-first-block", default: 1)
  }
}

#let get-line-number-gutter(options) = {
  let numbering = _line-numbering(options)
  if type(numbering) == dictionary {
    numbering.at("gutter", default: options.at("line-number-gutter", default: 24))
  } else {
    options.at("line-number-gutter", default: 24)
  }
}

#let get-inset-scale(options) = options.at("inset-scale", default: 1.0)
