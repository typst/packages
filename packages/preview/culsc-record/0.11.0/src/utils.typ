// src/utils.typ
// 工具函数

// 不缩进的内容块
#let noindent(body) = {
  set par(first-line-indent: 0em)
  body
}

// 下划线填空区
#let underline-box(content, width: 3em) = box(
  width: width, 
  stroke: (bottom: 0.5pt), 
  outset: (bottom: 1pt),
  align(center, content)
)

// LaTeX 图标
#let TeX = box[T#h(-0.2em)#text(baseline: 0.2em)[E]#h(-0.1em)X]
#let LaTeX = box[L#h(-0.3em)#text(size: 0.7em, baseline: -0.3em)[A]#h(-0.1em)#TeX]
