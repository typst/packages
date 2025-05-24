#import "../lib.typ": *

#let outline-font-style(doc) = {
  show outline.entry.where(level: 1): it => {
    set text(font: 黑体, size: 四号)
    it
  }
  show outline.entry.where(level: 2): it => {
    set text(font: 黑体, size: 小四)
    it
  }
  show outline.entry.where(level: 3): it => {
    set text(font: 宋体, size: 小四)
    it
  }
  doc
}

#let outline-style(doc) = {
  show outline.entry: it => {
    set block(spacing: 16pt)
    set outline(indent: 2em)
    it
  }
  doc
}

// 摘要样式
#let style(doc) = {
  // 页眉设置
  // 设置标题放入目录页，但是不编号
  set heading(numbering: none, outlined: true)
  set page(numbering: "i")
  show: outline-style
  doc
}
