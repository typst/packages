// SCUT 符号表
// 默认置于前言部分（罗马页码区），标题样式自包含，不依赖 mainmatter 的标题 show 规则
#import "../utils/invisible-heading.typ": invisible-heading
#import "../utils/section-break.typ": section-break
#import "../utils/style.typ": 字体, 字号, 正文字体, 正文字号, 正文行距, 章标题字体, 章标题字号

// 块级公式降级为行内，避免被 i-figured 编号、挤破网格。
// 需在内容层重建（而非 show 规则）：块级公式在内容结构里已拆分段落，show 转换无法合回
#let inline-math(c) = {
  if c.func() == math.equation {
    math.equation(c.body, block: false)
  } else if c.has("children") {
    c.children.map(inline-math).sum(default: [])
  } else {
    c
  }
}

#let notation(
  open-right: false,
  title: "主要符号对照表",
  outlined: true,
  columns: 2,
  row-gutter: 正文行距, // 与正文行距一致
  column-gutter: 2em,
  title-below: 1em,
  fonts: (:),
  ..args,
  body,
) = {
  fonts = 字体 + fonts

  section-break(open-right: open-right)

  set text(font: 正文字体, size: 正文字号)

  invisible-heading(level: 1, outlined: outlined, title)
  align(center, text(font: 章标题字体, size: 章标题字号, weight: "bold", title))
  v(title-below)

  // 每行 columns 组「符号-含义」，一组占一格
  grid(
    columns: (1fr,) * columns,
    row-gutter: row-gutter,
    column-gutter: column-gutter,
    ..args,
    ..body.children
      .filter(it => it.func() == terms.item)
      .map(it => inline-math(it.term) + [ -- ] + inline-math(it.description))
  )
}
