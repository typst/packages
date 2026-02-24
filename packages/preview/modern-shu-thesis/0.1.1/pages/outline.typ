#import "../style/font.typ": ziti, zihao
// #import "@preview/outrageous:0.3.0"

#let outline-page(
  info: (:),
) = {
  show outline.entry: it => {
    if it.level == 1 {
      set text(font: ziti.heiti, size: 14pt)
      if it.element.supplement == [main] { 
        strong(it) 
      } else {
        it
      }
    } else if it.level == 2 {
      set text(font: ziti.songti, size: 12pt)
      it
    } else {
      set text(font: ziti.songti, size: 11pt)
      it
    }
  }
  show outline: it => {
    show heading: set align(center)
    show heading: set text(font: ziti.heiti, size: 18pt, weight: "bold")
    it
  }

  v(3em)
  context outline(
    title: [目#h(1em)录],
    indent: 1em,
    depth: 3,
  )

  pagebreak(weak: true)
}
