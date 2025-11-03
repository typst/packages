#import "@preview/i-figured:0.2.4"
#import "font.typ": ziti, zihao
#let figures(
  appendix: false,
  body,
) = {
  show figure: set align(center)
  show table: set align(center)

  show heading: i-figured.reset-counters.with(extra-kinds: ("image",))
  let unarys = ((..nums) => nums.pos().map(str).join(".") + ")")
  show figure: i-figured.show-figure.with(
    extra-prefixes: (image: "img:"),
    numbering: if not appendix { "1.1" } else { "A1" },
  )
  show math.equation: i-figured.show-equation.with(
    numbering: if not appendix { "1.1" } else { "A1" },
    level:  if not appendix { 2 } else { 1 },
  )
  set math.equation(supplement: [公式])

  set figure.caption(separator: [#h(1em)])
  show figure.where(kind: "image"): set text(font: ziti.heiti, size: zihao.xiaosi, weight: "bold")
  show figure.where(kind: "table"): set text(font: ziti.heiti, size: zihao.xiaosi, weight: "bold")
  show figure.where(kind: "table"): set figure.caption(position: top)
  show figure: set block(breakable: true)

  let xubiao = state("xubiao")

  show table: set text(size: zihao.wuhao, weight: "regular")
  show table: set par(leading: 14pt)
  set table(
    stroke: (x, y) => {
      if y == 0 {
        none
      } else {
        none
      }
    },
  )
  show table: it => xubiao.update(false) + it
  body
}
