#import "../utils/style.typ": zihao, ziti

#let abstract-page(
  keywords: (),
  info: (:),
  twoside: false,
  body,
) = {
  pagebreak()
  set text(font: ziti.songti, size: zihao.xiaosi)
  set par(leading: 20pt, first-line-indent: 2em, spacing: 16pt)
  show heading.where(level: 1): it => {
    set text(font: ziti.heiti, weight: "bold", size: zihao.sanhao)
    set align(center)
    set par(first-line-indent: 0em, justify: false, leading: 20pt)
    v(40pt)
    it.body
    v(20pt)
  }
  heading(level: 1, outlined: false)[摘#h(2em)要]
  v(16pt)
  body
  if keywords != () {
    v(40pt)
    set par(first-line-indent: 0em)
    text(font: ziti.heiti, weight: "bold", size: zihao.xiaosi)[关键词：] + text(font: ziti.songti, size: zihao.xiaosi)[#keywords.join("；")]
  }
}
