#import "../utils/indent.typ": indent
#import "../utils/style.typ": 字号, 字体
#import "@preview/cuti:0.2.1": *

// 本科生声明页
#let bachelor-decl-page(
  anonymous: false,
  twoside: false,
  fonts: (:),
  info: (:),
) = {

  // 0.伪粗体，页面
  show: show-cn-fakebold
  set page(margin: (left: 2.5cm, top: 2.5cm, right: 2.0cm, bottom: 2.0cm))
  set par(spacing: 0pt)

  // 0. 如果需要匿名则短路返回
  if anonymous {
    return
  }

  // 1.  默认参数
  fonts = 字体 + fonts
  info = (
    title: ("基于 Typst 的", "南京大学学位论文"),
  ) + info

  // 2.  对参数进行处理
  // 2.1 如果是字符串，则使用换行符将标题分隔为列表
  if type(info.title) == str {
    info.title = info.title.split("\n")
  }


  // 3.  正式渲染
  pagebreak(weak: true, to: if twoside { "odd" })

  v(1.5cm)

  // align(center, image("../assets/vi/nju-emblem-purple.svg", width: 1.95cm))

  // v(-12pt)

  align(
    center,
    text(
      font: fonts.宋体,
      size: 字号.小四,
      weight: "bold",
      "北京师范大学本科毕业论文（设计）诚信承诺书",
    ),
  )

  v(0.762cm)

  block[
    #set text(font: fonts.宋体, size: 字号.小四, weight: "extrabold")
    #set par(justify: true, first-line-indent: 2em, leading: 1em)

    #indent 本人郑重声明： 所呈交的毕业论文（设计），是本人在导师的指导下，独立进行研究工作所取得的成果。
    除文中已经注明引用的内容外，本论文不含任何其他个人或集体已经发表或撰写过的作品成果。
    对本文的研究做出重要贡献的个人和集体，均已在文中以明确方式标明。
    本人完全意识到本声明的法律结果由本人承担。
  ]

  v(2.0574cm)

  grid(
    columns: (1fr, 225pt),
    [
      #set text(font: fonts.宋体, size: 字号.小四) 
    #indent 本人签名：
    ],
    align(left)[
      #set text(font: fonts.宋体, size: 字号.小四) 
      #h(4em)年#h(2em)月#h(2em)日
    ]
  )

  v(4.572cm)

   align(
    center,
    text(
      font: fonts.宋体,
      size: 字号.小四,
      weight: "bold",
      "北京师范大学本科毕业论文（设计）使用授权书",
    ),
  )

  v(0.762cm)

  block[
    #set text(font: fonts.宋体, size: 字号.小四, weight: "extrabold")
    #set par(justify: true, first-line-indent: 2em, leading: 1em)

    #indent 本人完全了解北京师范大学有关收集、保留和使用毕业论文（设计）的规定，
    即：本科生毕业论文（设计）工作的知识产权单位属北京师范大学。
    学校有权保留并向国家有关部门或机构送交论文的复印件和电子版，
    允许毕业论文（设计）被查阅和借阅；学校可以公布毕业论文（设计）的全部或部分内容，
    可以采用影印、缩印或扫描等复制手段保存、汇编毕业论文（设计）。
    保密的毕业论文（设计）在解密后遵守此规定。
    #v(1cm)
    本论文（是、否）保密论文。\ 
    #indent 保密论文在#box(width: 5em, height: 1em, stroke: (bottom:black),)年#box(width: 3em, height: 1em, stroke: (bottom:black))月解密后适用本授权书。
  ]

  v(1.7272cm)

  grid(
    columns: (1fr, 225pt),
    row-gutter: 0.8636cm,
    [
      #set text(font: fonts.宋体, size: 字号.小四) 
    #indent 本人签名：
    ],
    align(left)[
      #set text(font: fonts.宋体, size: 字号.小四) 
      #h(4em)年#h(2em)月#h(2em)日
    ],
    [
      #set text(font: fonts.宋体, size: 字号.小四) 
    #indent 导师签名：
    ],
    align(left)[
      #set text(font: fonts.宋体, size: 字号.小四) 
      #h(4em)年#h(2em)月#h(2em)日
    ]

  )


}