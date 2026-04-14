#import "config.typ": 字体, 字号

#let fakebold(s) = {
  context {
    set text(font: 字体.黑体, size: 字号.小四, weight: "bold")
    s
  }
}

// 本科生中文摘要页
#let bachelor-abstract-en(
  // documentclass 传入的参数
  info: (:
    // title-en:
    // keywords-en:
  ),
  // 其他参数
  outline-title: "Abstract",
  leading: 1.25em, // 行距
  spacing: 1.25em, // 段距
  amount: 2em, // 首行缩进,2em表示两个汉字的宽度
  body,
) = {
  // 1.  默认参数
  [
    #set text(font: 字体.宋体, size: 字号.小四)
    #set par(leading: leading, justify: true, spacing: spacing)
    #set page(
      footer: context [
        #set align(center)
        #set text(font: 字体.宋体, size: 字号.小五)
        #counter(page).display("I")
      ],
    )

    //显示题目
    #align(center)[
      #set text(font: 字体.宋体, size: 字号.二号, weight: "bold")
      #info.title-en
      #v(22pt)
    ]
    //显示中间的摘要二字
    #align(center)[
      #set text(font: 字体.黑体, size: 字号.小二, weight: "bold")
      Abstract
    ]

    #[
      #set par(first-line-indent: (amount: 2em, all: true))
      #body
    ]

    #v(1em)

    #fakebold[Keywords: ]#(("",) + info.keywords-en.intersperse("；")).sum()

    // 结束，下一页
    #pagebreak()
  ]
}
