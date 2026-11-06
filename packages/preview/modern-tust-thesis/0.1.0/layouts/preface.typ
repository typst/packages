#import "../utils/style.typ": zihao, ziti
#import "../utils/header.typ": tust-page-header

#let preface(
  doctype: "bachelor",
  twoside: false,
  print: false,
  info: (:),
  body,
) = {
  set page(
    numbering: "I",
    margin: (top: 25mm, bottom: 20mm, left: 25mm, right: 20mm),
  )
  counter(page).update(1)
  set heading(numbering: none, supplement: none)
  show heading.where(level: 1): it => {
    set text(font: ziti.heiti, weight: "bold", size: zihao.xiaoer)
    set align(center)
    set par(first-line-indent: 0em, justify: false)
    it.body
  }
  show heading: set par(first-line-indent: 0em, justify: false)
  tust-page-header(
    heading: info.at("heading", default: "天津科技大学本科毕业设计"),
    show-header: false,
  )[#body]
}
