#import "../utils/style.typ": zihao, ziti

#let summary-en-page(
  doctype: "bachelor",
  twoside: false,
  body,
) = {
  pagebreak()
  set text(font: "Times New Roman", size: zihao.xiaosi)
  set par(leading: 20pt, first-line-indent: 2em)
  heading(level: 1)[Summary]
  body
}
