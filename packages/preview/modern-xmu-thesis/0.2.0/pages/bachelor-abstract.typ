#import "../utils/style.typ": 字号, 字体
#import "../utils/invisible-heading.typ": invisible-heading

// 本科生中文摘要页
#let bachelor-abstract(
  // documentclass 传入的参数
  twoside: false,
  fonts: (:),
  // 其他参数
  keywords: (),
  outline-title: "中文摘要",
  outline-title-en: "Abstract in Chinese",
  outlined: false,
  leading: 1.28em,
  spacing: 1.28em,
  body,
) = {
  // 1.  默认参数
  fonts = 字体 + fonts

  // 2.  正式渲染
  pagebreak(weak: true, to: if twoside { "odd" })

  invisible-heading(level: 1, outlined: outlined, [#outline-title#metadata((en: outline-title-en))])

  v(spacing)
  align(center, text(size: 字号.小三, font: fonts.黑体)[摘#h(1.5em)要])
  v(spacing*2)

  [
    #set par(first-line-indent: (amount: 2em, all: true), leading: leading, spacing: spacing)
    #set text(size: 字号.小四, font: fonts.宋体)

    #body
  ]

  v(spacing)

  text(size: 字号.小四, font: fonts.黑体)[关键词：]
  text(size: 字号.小四, font: fonts.宋体, (("",) + keywords.intersperse("；")).sum())
}