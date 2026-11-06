#import "../utils/style.typ": 字体, 字号
#import "../utils/header.typ": header-render
#import "../layouts/preface.typ": preface-heading-above, preface-heading-style

#let master-abstract(
  doctype: "master",
  degree: "academic",
  anonymous: false,
  twoside: false,
  fonts: (:),
  info: (:),
  keywords: (),
  outline-title: "摘　要",
  outlined: true,
  anonymous-info-keys: ("author", "grade", "supervisor", "supervisor-ii"),
  leading: 1.0em,
  spacing: 1.0em,
  funding: none,
  body,
) = {
  fonts = 字体 + fonts
  info = (
    (
      title: ("基于 Typst 的", "西北工业大学学位论文"),
      author: "张三",
      grade: "20XX",
      department: "某学院",
      major: "某专业",
      supervisor: ("李四", "教授"),
    )
      + info
  )

  if type(info.title) == str {
    info.title = info.title.split("\n")
  }


  [
    #set par(leading: leading, spacing: spacing, justify: true)

    // 使用统一的一级标题样式
    #show heading.where(level: 1): it => preface-heading-style(it, fonts)
    #v(preface-heading-above)
    #heading(level: 1, outlined: outlined, outline-title)

    #[
      #set text(font: fonts.宋体, size: 字号.小四)
      #set par(first-line-indent: (amount: 2em, all: true))
      #body
    ]

    #v(1.5em)
    #h(2em)#text(font: fonts.黑体, size: 字号.小四)[关键词：]#text(font: fonts.宋体, size: 字号.小四)[#(
      ("",) + keywords.intersperse("；")
    ).sum()]

    #v(1fr)

    #if funding != none [
      #set par(first-line-indent: (amount: 2em, all: true), leading: 1.4em)
      #text(font: fonts.宋体, size: 字号.五号)[#funding]
    ]
  ]
}
