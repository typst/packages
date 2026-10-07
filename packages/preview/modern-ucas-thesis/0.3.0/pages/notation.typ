#import "../utils/style.typ": get-fonts, 字号, 行距
#import "../utils/page-foreground.typ": preface-foreground
#import "../utils/invisible-heading.typ": invisible-heading

// 符号列表页
#let notation(
  // documentclass 传入参数
  twoside: false,
  fontset: "mac",
  fonts: (:),
  info: (:),
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

  // 2. 正式渲染：起始三件套（P30）——先清样式（填充页干净），
  // 再换页（双面须奇数页起），最后重申前言域样式。全静态。
  set page(numbering: none, foreground: none)
  pagebreak(weak: true, to: if twoside { "odd" })
  set page(
    numbering: "I",
    footer: none,
    foreground: preface-foreground(info: info, fonts: fonts),
  )

  // 默认显示的字体
  set text(font: font, size: size)

  v(title-above)
  {
    set align(center)
    // 标题单倍行距
    set par(leading: 行距.单倍, spacing: 0pt)
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

  // 结尾 reset（P30）：function 体内的 set page 会泄漏到后续文档流，
  // 使正文 mainmatter 起始换页产生的填充页保持干净，
  // 而本页已有样式不受影响（set page 只对其后内容生效，实测）。
  // 正文另页开始由 mainmatter 起始换页保证，此处不再手动分页。
  set page(numbering: none, foreground: none)
}
