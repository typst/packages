#import "../utils/style.typ": zihao, ziti

#let achievement-page(
  doctype: "bachelor",
  twoside: false,
  body,
) = {
  pagebreak()
  set text(font: ziti.songti, size: zihao.xiaosi)
  set par(leading: 20pt, first-line-indent: 2em)
  heading(level: 1)[成果]
  body
}
