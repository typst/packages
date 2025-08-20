#import "../utils/style.typ": 字号, 字体
#import "../utils/invisible-heading.typ": invisible-heading

// 本科生中文摘要页
#let bachelor-abstract(
  // documentclass 传入的参数
  twoside: false,
  fonts: (:),
  info: (:),
  // 其他参数
  keywords: (),
  outline-title: "中文摘要",
  outlined: false,
  body,
) = {
  pagebreak(weak: true, to: if twoside { "odd" })

  [
    #set text(font: fonts.宋体, size: 字号.小四)

    // 标记一个不可见的标题用于目录生成
    #invisible-heading(level: 1, outlined: outlined, outline-title)

    #align(center)[
      #set text(size: 字号.三号, font: fonts.黑体)
      【摘#h(1em)要】
      #v(1em)
    ]

    #[
      #set par(first-line-indent: 2em)

      #body
    ]

    #v(1em)

    *关键词：*#keywords.join("，")
  ]
}
