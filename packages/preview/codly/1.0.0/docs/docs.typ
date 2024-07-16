#import "@preview/tidy:0.3.0"
#import "../codly.typ": codly, codly-init, codly-reset, no-codly, codly-enable, codly-disable, codly-range, codly-offset, local, codly-skip

#show: codly-init
#show raw.where(block: false): set raw(lang: "typc")
#show raw.where(block: false): box.with(
  fill: luma(240),
  inset: (x: 3pt, y: 0pt),
  outset: (y: 3pt),
  radius: 2pt,
)

#let img = image("typst-small.png", height: 0.8em)
#let preamble = "
  #codly-reset()
";

#let setup = codly.with(breakable: false, languages: (
  typ: (
    name: "Typst",
    icon: box(img, baseline: 0.1em, inset: 0pt, outset: 0pt) + h(0.2em),
      color: rgb("#239DAD"),
  ),
  typc: (
    name: "Typst code",
    icon: box(img, baseline: 0.1em, inset: 0pt, outset: 0pt) + h(0.2em),
    color: rgb("#239DAD"),
  )
))

#setup()

#let docs = tidy.parse-module(
  read("../codly.typ"),
  name: "Codly",
  scope: (
    codly: codly,
    codly-reset: codly-reset,
    no-codly: no-codly,
    codly-enable: codly-enable,
    codly-disable: codly-disable,
    codly-range: codly-range,
    codly-offset: codly-offset,
    codly-skip: codly-skip,
    local: local,
    pre-example: () => {
      codly-reset()
      setup()
    },
    img: img
  ),
  preamble: preamble,
)
#tidy.show-module(
  docs,
  show-outline: false,
  style: tidy.styles.default,
)