#import "@preview/stu-bachelor-thesis:0.1.0": 字体, 字号

// 参考文献页设置
#let setup-bibliography(bib-text) = [
  #show bibliography: it => [
    #set align(left)
    // 标题 - 黑体小四
    #set text(font: 字体.宋体, size: 字号.小五)
    #set block(above: 1.25em, below: 1.25em)
    #set par(
      justify: true,
      first-line-indent: 2em,
      //leading: 字号.小四 * 1.25  // 1.25倍行距 = 字号 + 字号*0.25
    ) // 两端对齐，段前缩进2字符
    #it
  ]
  #pagebreak(weak: true) // 防止参考文献标题孤行

  #set text(font: 字体.黑体, size: 字号.小四)
  #set align(left)
  #set page(
    footer: context [
      #set align(center)
      #set text(size: 字号.小五, font: 字体.宋体)
      #counter(page).display("1")
    ],
  )

  // #set par(
  // justify: true,
  // first-line-indent: 2em,
  // leading: 字号.小四 * 1.25  // 1.25倍行距 = 字号 + 字号*0.25
  // ) // 两端对齐，段前缩进2字符
  // //设置段前段后间距为0，行距为1.25倍行距
  // #set block(above: 1.25em, below: 1.25em)

  #heading(numbering: none, outlined: true, level: 2)[参考文献]
  #bibliography("../" + bib-text, style: "gb-7714-2005-numeric", title: none)
]
