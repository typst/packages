#import "../utils/style.typ": zihao, ziti
#import "../utils/header.typ": tust-page-header
#import "@preview/i-figured:0.2.4"

#let appendix(
  doctype: "bachelor",
  twoside: false,
  info: (:),
  body,
) = {
  // 设置附录的标题编号为字母 A, B, C...
  set heading(numbering: "A.1", supplement: [附录])
  
  // 重置heading计数器
  counter(heading).update(0)
  
  // 一级标题样式
  show heading.where(level: 1): it => {
    set text(font: ziti.heiti, weight: "bold", size: zihao.xiaosan)
    set align(center)
    set par(first-line-indent: 0em, leading: 20pt)
    pagebreak()
    v(40pt)
    // 显示格式：附录 A 标题内容
    [附录 #counter(heading).display()#h(1em)#it.body]
    v(20pt)
  }
  
  // 重置图表编号，每个附录独立编号
  show heading: i-figured.reset-counters.with(extra-kinds: ("image", "table", "algorithm"))
  show figure: i-figured.show-figure.with(
    numbering: "A-1"  // 附录中的图表编号格式：附录A-图1
  )
  
  tust-page-header(
    heading: info.at("heading", default: "天津科技大学本科毕业设计"),
  )[#body]
}
