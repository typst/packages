#import "../utils/style.typ": font_family, font_size
#import "../utils/datetime-display.typ": datetime-display

//! 本科生声明页
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
  fonts = font_family + fonts

  // 2.  正式渲染
  pagebreak(weak: true, to: if twoside { "odd" })

  v(80pt)

  //! 标题
  align(
    center,
    text(
      font: fonts.宋体,
      size: font_size.三号,
      weight: "bold",
      "独   创   性   声   明\n",
    ),
  )

  //! 扉页内容
  block[
    #set text(font: fonts.宋体, size: font_size.四号)
    #set par(justify: true, first-line-indent: (amount: 2em, all: true), leading: 1em)
    #v(.5em)

    本人郑重声明：所提交的毕业论文是本人在导师指导下独立进行研究工作所取得的成果。据我所知，除了特别加以标注和致谢的地方外，论文中不包含其他人已经发表或撰写过的研究成果。对本人的研究作出重要贡献的个人和集体，均已在文中做了明确的说明。本声明的法律结果由本人承担。
  ]

  //! 签名与日期
  //TODO 加入自动识别是否存在签名的 `pdf` 或 `png`，在签名处自动填充
  set text(font: fonts.宋体, size: font_size.四号)
  [
    #set par(justify: true, first-line-indent: (amount: 2em, all: true), leading: 1em)
    #v(2em)
    论文作者签名：#box(width: 7em, stroke: (bottom: 0.5pt), outset: 2pt)#h(1em)日期：#underline(offset: 2pt)[#datetime-display(datetime.today())]
  ]
}
