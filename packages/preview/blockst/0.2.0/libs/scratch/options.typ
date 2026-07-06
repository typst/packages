#let scratch-block-options = state("scratch-block-options", (
  theme: "normal",
  stroke-width: auto,
  scale: 100%,
  font: "Helvetica Neue",
))

#let get-options() = scratch-block-options.get()

#let get-theme(options) = options.at("theme", default: "normal")

#let get-scale(options) = options.at("scale", default: 100%)

#let get-font(options) = options.at("font", default: "Helvetica Neue")
