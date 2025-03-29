// 定义全局内容样式
#let content-style(
  doc,
  serif: "",
  sans-serif: "",
  raw-font: "",
  emph-font: "",
  size: 0pt,
) = {
  // 设置地区和语言
  set text(region: "CN", lang: "zh")
  // 设置基本字体和字号
  set text(font: serif, size: size)
  // 设置段落样式 - 首段缩进 + 段间距
  set par(
    justify: true,
    // 首段缩进
    first-line-indent: (amount: 2em, all: true),
    // 段间距
    spacing: 1.5em,
    // 行间距
    leading: 1.5em,
  )
  // 设置中文粗体样式：建议使用黑体
  show strong: set text(font: sans-serif, weight: "regular")
  // 设置中文斜体样式：建议使用楷体
  show emph: set text(font: emph-font)
  // 设置代码样式：建议使用等宽字体
  show raw: set text(font: raw-font)
  show raw.where(block: true): set par(leading: 1em)
  // 设置列表样式
  set enum(indent: 2em, numbering: it => text(baseline: .2em, numbering("1.", it)))
  set list(indent: 2em, marker: it => text(baseline: .2em)[•])
  doc
}
