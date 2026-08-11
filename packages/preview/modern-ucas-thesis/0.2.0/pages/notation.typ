#import "../utils/style.typ": get-fonts, 字号
#import "../utils/invisible-heading.typ": invisible-heading

// 符号列表页
#let notation(
  // documentclass 传入参数
  twoside: false,
  fontset: "mac",
  fonts: (:),
  // 其他参数
  title: "符号列表",
  outlined: false,
  title-above: 24pt,
  title-below: 18pt,
  title-text-args: auto,
  // 字体与字号
  font: auto,
  size: 字号.小四,
  body,
  ..args,
) = {
  // 1.  默认参数
  fonts = get-fonts(fontset) + fonts
  if title-text-args == auto {
    title-text-args = (font: fonts.黑体, size: 字号.四号, weight: "bold")
  }

  // 字体与字号
  if font == auto {
    font = fonts.黑体
  }

  // 2. 正式渲染
  pagebreak(weak: true, to: if twoside { "odd" })

  // 默认显示的字体
  set text(font: font, size: size)

  v(title-above)
  {
    set align(center)
    text(..title-text-args, title)

    // 标记一个不可见的标题用于目录生成
    invisible-heading(level: 1, outlined: outlined, title)
  }

  v(title-below)

  // 设置首行缩进为 0
  set par(first-line-indent: (amount: 0pt, all: true))

  [
    #body
  ]

  // 手动分页
  if (twoside) {
    pagebreak() + " "
  }
}
