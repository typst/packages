#import "../utils/style.typ": zihao, ziti

#let acknowledgement-page(
  doctype: "bachelor",
  twoside: false,
  anonymous: false,
  body,
) = {
  pagebreak()
  set heading(numbering: none)
  set text(font: ziti.songti, size: zihao.xiaosi)
  set par(leading: 20pt, first-line-indent: 2em, spacing: 20pt)  // 添加段间距
  show heading.where(level: 1): it => {
    set text(font: ziti.heiti, weight: "bold", size: zihao.xiaosan)
    set align(center)
    set par(first-line-indent: 0em, leading: 20pt)
    v(40pt)
    it.body
    v(20pt)
  }
  heading(level: 1)[致#h(2em)谢]
  body
}
