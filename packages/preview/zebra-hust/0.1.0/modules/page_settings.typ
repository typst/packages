#import "@preview/pointless-size:0.1.2": zh
#import "header.typ": header_colorful

#let page-setup(paper: "a4", margin: (top: 9.5em), header-font: "FandolKai", footer-font: "FandolSong", body) = {
  set page(
    paper: paper,
    numbering: "1",
    header: context {
      let page-num = counter(page).get().first()
      if page-num >= 2 {
        text(font: header-font, header_colorful)
      }
    },
    footer: context {
      let page-num = counter(page).get().first()
      if page-num >= 2 {
        grid(
          columns: (1fr, auto, 1fr),
          align: (left, center, right),
          line(length: 95%, stroke: gray),
          text(font: footer-font, size: zh(4), baseline: -0.3em)[#(page-num - 1)],
          line(length: 95%, stroke: gray),
        )
      }
    },
    margin: margin,
  )
  body
}
