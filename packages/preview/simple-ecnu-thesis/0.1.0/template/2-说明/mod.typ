#import "../lib.typ": *

// 说明页面样式
#let style(doc) = {
  // 设置标题不编号且不放入目录
  set heading(numbering: none, outlined: false)
  set par(leading: 1em, spacing: 1em)
  doc
}

#let sudo-heading(title) = {
  set align(center)
  text(font: 黑体, size: 三号, title, weight: "medium")
  block(below: 1.5em)
}
