#import "config.typ": 字体, 字号
#let setup-thanks(body) = [
  #set text(lang: "zh")
  #set page(
    footer: context [
      #set align(center)
      #set text(size: 字号.小五, font: 字体.宋体)
      #counter(page).display("1")
    ],
  )

  #pagebreak(weak: true)//假设当前页面并没有包含任何内容,pagebreak(weak: true)不会创建新的页面
  #show heading.where(
    level: 2,
  ): it => [
    #set align(center)
    #set text(size: 字号.三号, font: 字体.黑体)
    #set par(first-line-indent: 0em)//设置标题不要缩进
    //一级标题直接分页，避免孤行
    #pagebreak(weak: true)//假设当前页面并没有包含任何内容,pagebreak(weak: true)不会创建新的页面
    #it.body
  ]

  #heading(level: 2, numbering: none)[致谢]
  /************正文格式设置************/
  #set text(size: 字号.小四) // 正文字号设置为小四
  #set text(font: 字体.宋体) // 正文字体设置为宋体
  #set par(
    justify: true,
    first-line-indent: 2em,
    leading: 字号.小四 * 1.25, // 1.25倍行距 = 字号 + 字号*0.25
  ) // 两端对齐，段前缩进2字符

  #body
]
