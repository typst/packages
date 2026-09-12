#import "@preview/pointless-size:0.1.2": zh

#import "/src/fonts.typ": *


#let declaration-page() = {
  set text(font: songti, size: zh(4.5))
  set par(leading: 1.25em)

  v(1em)

  align(center)[
    #text(font: heiti, size: zh(3), weight: "bold")[中国人民大学学位论文原创性声明和使用授权说明]
  ]

  v(2em)

  align(center)[
    #text(font: songti, size: zh(3.5), weight: "bold")[原创性声明]
  ]

  v(1em)

  [
    本人郑重声明：所呈交的学位论文，是本人在导师的指导下，独立进行研究工作所取得的成果。除文中已经注明引用的内容外，本论文不含任何其他个人或集体已经发表或撰写过的作品或成果。对本文的研究做出重要贡献的个人和集体，均已在文中以明确方式标明。
  ]

  v(4em)

  align(right)[
    #grid(
      columns: 2,
      rows: 2,
      row-gutter: 1.8em,
      [论文作者签名：], [#h(4em)],
      [日期：], [#h(2em) 年 #h(1em) 月 #h(1em) 日],
    )
  ]

  v(4em)
  align(center)[
    #text(font: songti, size: 14pt, weight: "bold")[学位论文使用授权说明]
  ]

  v(1em)
  text(size: 12pt)[
    本人完全了解中国人民大学关于收集、保存、使用学位论文的规定，即：
    #set list(indent: 0em, marker: [●])
    #list(
      [按照学校要求提交学位论文的印刷本和电子版本；],
      [学校可以公布论文的全部或部分内容，可以采用影印、缩印或其他复制手段保存论文。],
    )
  ]

  v(4em)
  align(right)[
    #grid(
      columns: 2,
      rows: 3,
      row-gutter: 1.8em,
      [论文作者签名：], [#h(4em)],
      [指导教师签名：], [#h(6em)],
      [日期：], [#h(2em) 年 #h(1em) 月 #h(1em) 日],
    )
  ]

  pagebreak()
}
