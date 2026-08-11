#import "../utils/style.typ": zihao, ziti

#let bibliography-page(
  doctype: "bachelor",
  twoside: false,
  bibfunc: none,
  style: "../utils/tust-thesis.csl",
  full: false,
) = {
  pagebreak()
  set heading(numbering: none)
  show heading.where(level: 1): it => {
    set text(font: ziti.heiti, weight: "bold", size: zihao.xiaosan)
    set align(center)
    set par(first-line-indent: 0em, leading: 20pt)
    v(40pt)
    it.body
    v(20pt)
  }
  
  show bibliography: set text(font: ziti.songti, size: zihao.wuhao)
  show bibliography: set par(leading: 1em, spacing: 1em, first-line-indent: 0em)

  if bibfunc != none {
    bibfunc(title: [参考文献], style: style, full: full)
  }
}
