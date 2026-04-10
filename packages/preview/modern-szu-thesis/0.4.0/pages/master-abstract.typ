#import "@preview/pinit:0.2.2": pin, pinit-place
#import "../utils/style.typ": 字号, 字体
#import "../utils/double-underline.typ": double-underline
#import "../utils/custom-tablex.typ": gridx, colspanx
#import "../utils/invisible-heading.typ": invisible-heading

// 研究生中文摘要页
#let master-abstract(
  // documentclass 传入的参数
  doctype: "master",
  degree: "academic",
  anonymous: false,
  twoside: false,
  fonts: (:),
  info: (:),
  // 其他参数
  keywords: (),
  outline-title: "摘  要",
  outlined: true,
  abstract-title-weight: "regular",
  stoke-width: 0.5pt,
  info-value-align: center,
  info-inset: (x: 0pt, bottom: 0pt),
  info-key-width: 74pt,
  grid-inset: 0pt,
  column-gutter: 0pt,
  row-gutter: 10pt,
  anonymous-info-keys: ("author", "grade", "supervisor", "supervisor-ii"),
  leading: 1.25em,
  spacing: 1.25em,
  body,
) = {
  // 1.  默认参数
  fonts = 字体 + fonts
  info = (
    title: ("基于 Typst 的", "南京大学学位论文"),
    author: "张三",
    grade: "20XX",
    department: "某学院",
    major: "某专业",
    supervisor: ("李四", "教授"),
  ) + info

  // 2.  对参数进行处理
  // 2.1 如果是字符串，则使用换行符将标题分隔为列表
  if type(info.title) == str {
    info.title = info.title.split("\n")
  }

  // 3.  内置辅助函数
  let info-key(body) = {
    rect(
      inset: info-inset,
      stroke: none,
      text(font: fonts.楷体, size: 字号.四号, body),
    )
  }

  let info-value(key, body) = {
    set align(info-value-align)
    rect(
      width: 100%,
      inset: info-inset,
      stroke: (bottom: stoke-width + black),
      text(
        font: fonts.楷体,
        size: 字号.四号,
        bottom-edge: "descender",
        if anonymous and (key in anonymous-info-keys) {
          "█████"
        } else {
          body
        },
      ),
    )
  }

  // 4.  正式渲染
  pagebreak(weak: true, to: if twoside { "odd" })
  [
    #set page(header: context{
      set par(leading:0pt,spacing:0pt)
      align(center,info.title.sum())
      v(4pt)
      line(length: 100%, stroke:2pt)
      v(3pt)
      line(length: 100%)
    })
    #set text(font: fonts.宋体, size: 字号.小四)
    #set par(leading: leading, justify: true)

    // 标记一个不可见的标题用于目录生成
    #invisible-heading(level: 1, outlined: outlined, outline-title)

    #linebreak()

    #align(center, text(font: fonts.黑体, size: 字号.三号, weight: "bold", "摘　　要"))

    #v(-5pt)

    #set text(font: fonts.宋体, size: 字号.小四)

    #linebreak()

    #[
      #set par(first-line-indent: (amount: 2em, all: true),spacing: spacing,leading: leading)

      #body
    ]
    #linebreak()
    #text(font:字体.黑体,weight: "bold")[*关键词*：]
    #(("",)+ keywords.intersperse("；")).sum()
  ]
}