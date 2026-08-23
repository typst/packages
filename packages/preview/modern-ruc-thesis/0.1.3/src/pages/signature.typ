#import "/src/fonts.typ": *


#let add-signature() = {
  v(3.2em)
  set par(first-line-indent: 0em)
  text(font: heiti, size: 14pt, weight: "bold")[作者签名：]
  box(width: 8em, stroke: (bottom: 1pt + black), outset: 0.3em)
}
