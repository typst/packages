#import "../utils/indent.typ": indent
#import "../utils/style.typ": 字号, 字体

// 本科生声明页
#let bachelor-decl-page(
  anonymous: false,
  twoside: false,
  fonts: (:),
  info: (:),
) = {
  // 0. 如果需要匿名则短路返回
  if anonymous {
    return
  }

  // 1.  默认参数
  fonts = 字体 + fonts
  info = (
    title: ("基于 Typst 的", "深圳大学学位论文"),
  ) + info

  // 2.  对参数进行处理
  // 2.1 如果是字符串，则使用换行符将标题分隔为列表
  if type(info.title) == str {
    info.title = info.title.split("\n")
  }


  // 3.  正式渲染
  pagebreak(weak: true, to: if twoside { "odd" })

  //v(6pt)

  //align(center, image("../assets/vi/nju-emblem-purple.svg", width: 1.95cm))

  //v(12pt)

  v(84pt)

  align(
    center,
    text(
      font: fonts.黑体,
      size: 字号.小二, 
      weight: "bold",
      "深圳大学本科毕业论文（设计）诚信声明",
    ),
  )

  //v(3cm)
  v(56pt)

  block[
    #set text(font: fonts.宋体, size: 字号.四号)
    #set par(justify: true, first-line-indent: 2em, leading: 1.5em)

    #indent 本人郑重承诺：所呈交的毕业论文（设计），题目《 #info.title.sum()》是本人在指导教师的指导下，独立进行研究工作所取得的成果。对本文的研究做出重要贡献的个人和集体，均已在文中以明确方式注明。除此之外，本论文不包含任何其他个人或集体已经发表或撰写过的作品成果。本人完全意识到本声明的法律结果。

  ]

  v(8em)

  grid(
    columns: (1fr, 15cm),
    [],
    align(right)[
      #set text(font: fonts.宋体, size: 字号.四号)
      
      毕业论文（设计）作者签名：#h(2.2cm)

      日期：#h(2cm)年 #h(.6cm)月#h(.5cm)日#h(2.4cm) 
    ]
  )
}