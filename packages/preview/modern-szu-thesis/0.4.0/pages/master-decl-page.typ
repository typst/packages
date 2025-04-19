#import "../utils/style.typ": 字号, 字体

// 本科生声明页
#let master-decl-page(
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

  v(12pt)

  //linebreak()

  align(
    center,
    text(
      font: fonts.黑体,
      size: 字号.小三, 
      weight: "bold",
      "深圳大学",
    ),
  )
  align(
    center,
    text(
      font: fonts.黑体,
      size: 字号.小三, 
      weight: "bold",
      "学位论文原创性声明",
    ),
  )
  //v(3cm)
  

  block[
    #set text(font: fonts.宋体, size: 字号.小四)
    #set par(justify: true, first-line-indent: (amount: 2em, all: true), leading: 1.25em, spacing: 1.25em)

    本人郑重声明：所呈交的学位论文 #underline(stroke: 1pt, offset: 4pt,info.title.sum())是本人在导师的指导下，独立进行研究工作所取得的成果。除文中已经注明引用的内容外，本论文不含任何其他个人或集体已经发表或撰写的作品或成果。对本文的研究做出重要贡献的个人和集体，均已在文中以明确方式标明。本声明的法律后果由本人承担。
  ]

  linebreak()

  grid(
    columns: (2em,4cm, 1fr),
    [],
    align(left)[
      #set text(font: fonts.宋体, size: 字号.小四, )
      
      论文作者签名:
    ],
    align(right)[
      #set text(font: fonts.宋体, size: 字号.小四, )
      
      日期：#h(1cm)年 #h(.6cm)月#h(.5cm)日#h(2em)
    ],
    
  )

  linebreak()
  linebreak()
  linebreak()
  linebreak()

  align(
    center,
    text(
      font: fonts.黑体,
      size: 字号.小三, 
      weight: "bold",
      "深圳大学",
    ),
  )
  align(
    center,
    text(
      font: fonts.黑体,
      size: 字号.小三, 
      weight: "bold",
      "学位论文使用授权说明",
    ),
  )

  block()[
    #set text(font: fonts.宋体, size: 字号.小四)
    #set par(justify: true, first-line-indent: (amount: 2em, all: true), leading: 1.25em, spacing: 1.25em)

    本学位论文作者完全了解深圳大学关于收集、保存、使用学位论文的规定，即：研究生在校攻读学位期间论文工作的知识产权单位属深圳大学。学校有权保留学位论文并向国家主管部门或其他机构送交论文的电子版和纸质版，允许论文被查阅和借阅。本人授权深圳大学可以将学位论文的全部或部分内容编入有关数据库进行检索，可以采用影印、缩印或扫描等复制手段保存、汇编学位论文。

    （涉密学位论文在解密后适用本授权书）
  ]

  linebreak()

  grid(columns:(2em,8cm,7cm),
  row-gutter: 2em,
  [],
  align(left)[
      #set text(font: fonts.宋体, size: 字号.小四, )
      
      论文作者签名:
    ],
  align(left)[
      #set text(font: fonts.宋体, size: 字号.小四, )

      导师签名:
  ],
  [],
  align(left)[
      #set text(font: fonts.宋体, size: 字号.小四, )

      日期：#h(1cm)年 #h(.6cm)月#h(.5cm)日#h(2em)
  ],
  align(left)[
      #set text(font: fonts.宋体, size: 字号.小四, )

      日期：#h(1cm)年 #h(.6cm)月#h(.5cm)日#h(2em)
  ],
  )

}