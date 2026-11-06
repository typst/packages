#import "@preview/cetz:0.2.2": draw
#import "../src/circuit.typ": circuit
#import "../src/util.typ"

#let example-preamble = "import \"../src/lib.typ\": *;"
#let example-scope = (
  draw: draw
)

#let example(src, show-src: true, vertical: false, fill: true) = {
  src = src.text
  let full-src = example-preamble + src
  let body = eval(full-src, scope: example-scope)
  let img = circuit(length: 2em, body)

  block(width: 100%,
    align(center,
      box(
        stroke: black + 1pt,
        radius: .5em,
        fill: if fill {util.colors.yellow.lighten(80%)} else {none},
        if show-src {
          let src-block = align(left, raw(src, lang: "typc"))
          table(
            columns: if vertical {1} else {2},
            inset: 1em,
            align: horizon + center,
            stroke: none,
            img,
            if vertical {table.hline()} else {table.vline()}, src-block
          )
        } else {
          table(
            inset: 1em,
            img
          )
        }
      )
    )
  )
}