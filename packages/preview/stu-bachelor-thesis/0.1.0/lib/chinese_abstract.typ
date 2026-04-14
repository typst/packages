#import "config.typ": 字体, 字号

#let fakebold(s) = {
  context {
    set text(font: 字体.黑体, size: 字号.小四)
    s
  }
}

// 本科生中文摘要页
#let bachelor-abstract-ch(
  // documentclass 传入的参数
  info: (:
    // title:
    // keywords:
  ),
  // 其他参数
  outline-title: "中文摘要",
  leading: 1.25em, // 行距
  spacing: 1.25em, // 段距
  amount: 2em, // 首行缩进,2em表示两个汉字的宽度
  body,
) = {
  // 1.  默认参数
  [
    #set page(
      footer: context [
        #set align(center)
        #set text(font: 字体.宋体, size: 字号.小五)
        #counter(page).display("I")
      ],
    )


    #set text(font: 字体.宋体, size: 字号.小四, spacing: 100%)
    #set par(leading: leading, spacing: spacing)

    #counter(page).update(1) // 页码从1开始

    //显示题目
    #align(center)[
      #set text(font: 字体.黑体, size: 字号.二号)
      //#info.title.sum()
      #info.title
      #v(22pt)
    ]
    //显示中间的摘要二字
    #align(center)[
      #set text(font: 字体.黑体, size: 字号.小二)
      摘#h(1em)要
    ]

    #[
      //设置双端对齐
      #set par(first-line-indent: (amount: 2em, all: true), justify: true)
      #body
    ]

    #v(1em)

    #fakebold[关键词：]#(("",) + info.keywords.intersperse("；")).sum()

    //显示页脚



    // 结束，下一页
    #pagebreak()
  ]
}
