#import "../utils/style.typ": 字号, 字体

// 研究生声明页
#let master-decl-page(
  anonymous: false,
  twoside: false,
  fonts: (:),
) = {
  // 0. 如果需要匿名则短路返回
  if anonymous {
    return
  }

  // 1.  默认参数
  fonts = 字体 + fonts

  // 2.  正式渲染
  pagebreak(weak: true, to: if twoside { "odd" })

  v(25pt)

  align(
    center,
    text(
      font: fonts.黑体,
      size: 字号.四号,
      weight: "bold",
      "南京大学学位论文原创性声明",
    ),
  )

  v(46pt)

  block[
    #set text(font: fonts.宋体, size: 字号.小四)
    #set par(justify: true, first-line-indent: (amount: 2em, all: true), leading: 1.2em)

    本人郑重声明，所提交的学位论文是本人在导师指导下独立进行科学研究工作所取得的成果。除本论文中已经注明引用的内容外，本论文不包含其他个人或集体已经发表或撰写过的研究成果，也不包含为获得南京大学或其他教育机构的学位证书而使用过的材料。对本文的研究做出重要贡献的个人和集体，均已在论文的致谢部分明确标明。本人郑重申明愿承担本声明的法律责任。    
  ]

  v(143pt)

  align(right)[
    #set text(font: fonts.黑体, size: 字号.小四)
    
    研究生签名：#h(5.8em)

    日期：#h(5.8em)
  ]
}