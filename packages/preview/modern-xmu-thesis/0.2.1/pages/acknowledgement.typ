#import "../utils/style.typ": 字号, 字体
#import "../utils/invisible-heading.typ": invisible-heading

#let acknowledgement(
  // documentclass 传入的参数
  twoside: false,
  fonts: (:),
  // 其他参数
  outline-title: "致谢",
  outline-title-en: "Acknowledgements",
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
  align(center, text(size: 字号.小三, font: fonts.黑体)[致#h(1.5em)谢])
  v(spacing * 2)

  [
    #set par(justify: true, first-line-indent: (amount: 2em, all: true), leading: leading, spacing: spacing)
    #set text(size: 字号.小四, font: fonts.宋体)

    #body
  ]
}
