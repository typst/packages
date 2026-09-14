#import "../utils/style.typ": get-fonts, 字号

// 符号列表页
#let notation(
  // documentclass 传入参数
  twoside: false,
  fontset: "mac",
  fonts: (:),
  // 其他参数
  title: "符号列表",
  outlined: false,
  title-vspace: 32pt,
  title-text-args: auto,
  body,
  ..args,
) = {
  // 1.  默认参数
  fonts = get-fonts(fontset) + fonts
  if title-text-args == auto {
    title-text-args = (font: fonts.黑体, size: 字号.四号, weight: "bold")
  }

  // 2. 正式渲染
  pagebreak(weak: true, to: if twoside { "odd" })

  // 默认显示的字体
  set text(font: fonts.黑体, size: 字号.小四)
  // 设置首行缩进为 0
  set par(first-line-indent: (amount: 0pt, all: true))

  [
    // 标题，居中显示，段前间距 24pt，段后间距 18pt
    #align(center)[
      #block(below: 18pt, above: 24pt)[
        #text(..title-text-args, title)
      ]
    ]
    #body
  ]

  // 手动分页
  if (twoside) {
    pagebreak() + " "
  }
}
