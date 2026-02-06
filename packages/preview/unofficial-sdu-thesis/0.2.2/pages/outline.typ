#import "../styles/fonts.typ": fonts, fontsize
#import "@preview/cuti:0.3.0": show-cn-fakebold, fakebold

#let outline-page(
  info: (:),
) = {
  counter(page).update(1)
  set page(header: none, footer: align(center)[#text(rgb("808080"))[#context counter(page).display("I")]])

  set outline.entry(fill: repeat([.], gap: 0.15em))
  show outline.entry: it => {
    set text(font: fonts.宋体, size: fontsize.小四)
    if it.level == 1 {
      fakebold()[#it]
    } else {
      it
    }
  }

  show outline: it => {
    show heading: set align(center)
    show heading: set text(font: fonts.宋体, size: fontsize.小四, weight: "bold")
    it
  }

  v(15pt)
  context outline(
    title: [#{
        set text(font: fonts.黑体, size: fontsize.小二)
        set par(spacing: 1em)
        text()[#fakebold()[目#h(2em)录]]
      }
    ],
    indent: 1.8em,
    depth: 3,
  )

  

  pagebreak(weak: true)
}
