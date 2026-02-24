#import "../utils/custom-cuti.typ": fakebold
#import "../utils/style.typ": 字号, 字体
#import "../utils/double-underline.typ": double-underline
#import "../utils/invisible-heading.typ": invisible-heading

// 本科生英文摘要页
#let bachelor-abstract-en(
  // documentclass 传入的参数
  anonymous: false,
  twoside: false,
  fonts: (:),
  info: (:),
  // 其他参数
  keywords: (),
  outline-title: "Abstract",
  outlined: true,
  anonymous-info-keys: ("author-en", "supervisor-en", "supervisor-ii-en"),
  leading: 8pt,
  spacing: 1em,
  body,
) = {
  // 1.  默认参数
  fonts = 字体 + fonts
  info = (
    (
      title-en: "FZU Thesis Template for Typst",
      author-en: "Zhang San",
      department-en: "XX Department",
      major-en: "XX Major",
      supervisor-en: "Professor Li Si",
    )
      + info
  )

  // 2.  对参数进行处理
  // 2.1 如果是字符串，则使用换行符将标题分隔为列表
  if type(info.title-en) == str {
    info.title-en = info.title-en.split("\n")
  }

  // 3.  内置辅助函数
  let info-value(key, body) = {
    if not anonymous or (key not in anonymous-info-keys) {
      body
    }
  }

  // 4.  正式渲染
  [
    #pagebreak(weak: true, to: if twoside { "odd" })

    #set text(font: fonts.宋体, size: 字号.小四)
    #set par(leading: leading, justify: true, spacing: spacing)

    // 标记一个不可见的标题用于目录生成
    #invisible-heading(level: 1, outlined: outlined, outline-title)

    #align(center)[
      #set text(font: fonts.黑体, size: 字号.小三, weight: "black")
      #set par(leading: 12pt)

      #info-value("title-en", (("",) + info.title-en).sum())
    ]

    #align(center)[
      #set text(font: "Arial", size: 字号.四号, weight: "black")
      #set par(leading: 12pt, spacing: 0pt)
      #v(13pt)
      #outline-title
      #v(18pt)
    ]

    #[
      #set text(font: "Times New Roman", size: 字号.小四)
      #set par(
        first-line-indent: (amount: 2em, all: true),
        leading: leading,
        spacing: spacing,
        justify: true,
        linebreaks: "optimized",
      )
      #body
    ]

    #v(1em)

    #[
      #set text(font: fonts.黑体, size: 字号.小四, weight: "black")
      #set par(leading: 8pt)
      Key words：#(("",) + keywords.intersperse("，")).sum()
    ]
  ]
}
