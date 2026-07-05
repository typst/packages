#set page(
  width: auto,
  height: auto,
  margin: 0.0em,
  fill: none
) if "standalone" in sys.inputs and sys.inputs.at("standalone")=="true"
#let logo(transparentize: 0%) = box(
  fill: eastern.transparentize(transparentize),
  height: 1.5em,
  width: 1.5em,
  radius: 0.25em,
)[
  #align(center + horizon, image("tower-of-babel.svg", height: 66%))
]
#if "standalone" in sys.inputs and sys.inputs.at("standalone")=="true" {
  logo()
}
