#import "@preview/cetz:0.2.2": draw
#import "../src/lib.typ": schema
#import "../src/util.typ"

#let example-preamble = "import \"../src/lib.typ\": *;"

#let example(src, show-src: true, vertical: false, fill: true) = {
  src = src.text.trim()
  let full-src = example-preamble + src
  let body = eval(full-src)

  block(width: 100%,
    align(center,
      box(
        stroke: black + 1pt,
        radius: .5em,
        fill: if fill {yellow.lighten(80%)} else {none},
        if show-src {
          let src-block = align(left, raw(src, lang: "typc"))
          table(
            columns: if vertical {1} else {2},
            inset: 1em,
            align: horizon + center,
            stroke: none,
            body,
            if vertical {table.hline()} else {table.vline()}, src-block
          )
        } else {
          table(
            inset: 1em,
            body
          )
        }
      )
    )
  )
}

#let config-config = example(raw("
let ex = schema.load(```yaml
structures:
  main:
    bits: 4
    ranges:
      3-0:
        name: default
```)
schema.render(ex, config: config.config())
"))

#let config-dark = example(raw("
let ex = schema.load(```yaml
structures:
  main:
    bits: 4
    ranges:
      3-0:
        name: dark
```)
schema.render(ex, config: config.dark())
"))

#let config-blueprint = example(raw("
let ex = schema.load(```yaml
structures:
  main:
    bits: 4
    ranges:
      3-0:
        name: blueprint
```)
schema.render(ex, config: config.blueprint())
"))