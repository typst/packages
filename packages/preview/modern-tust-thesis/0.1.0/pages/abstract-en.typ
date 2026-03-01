#import "../utils/style.typ": zihao, ziti

#let abstract-en-page(
  keywords: (),
  info: (:),
  twoside: false,
  body,
) = {
  pagebreak()
  set text(font: "Times New Roman", size: zihao.xiaosi)
  set par(leading: 20pt, first-line-indent: 2em, spacing: 16pt)
  show heading.where(level: 1): it => {
    set text(font: "Arial", weight: "bold", size: zihao.xiaosan)
    set align(center)
    set par(first-line-indent: 0em, justify: false, leading: 20pt)
    v(40pt)
    it.body
    v(20pt)
  }
  heading(level: 1, outlined: false)[ABSTRACT]
  v(16pt)
  body
  if keywords != () {
    v(40pt)
    set par(first-line-indent: 0em)
    text(font: "Times New Roman", weight: "bold", size: zihao.xiaosi)[KeyWords: ] + text(font: "Times New Roman", size: zihao.xiaosi)[#keywords.join(", ")]
  }
}
