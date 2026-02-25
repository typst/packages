#import "../src/lib.typ" as chronos

#let example-preamble = "import \"../src/lib.typ\": *;"
#let example-scope = (
  chronos: chronos
)

#let example(src, show-src: true, vertical: false, fill: false, wrap: true) = {
  src = src.text
  let full-src = example-preamble + src
  let body = eval(full-src, scope: example-scope)
  let img = if wrap { chronos.diagram(body) } else { body }

  block(width: 100%,
    align(center,
      box(
        stroke: black + 1pt,
        radius: .5em,
        fill: if fill {color.white.darken(2%)} else {none},
        if show-src {
          let src-block = raw(src, block: true, lang: "typc")
          table(
            columns: if vertical {1} else {2},
            inset: 5pt,
            align: horizon + center,
            stroke: none,
            table.cell(inset: 1em, img),
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