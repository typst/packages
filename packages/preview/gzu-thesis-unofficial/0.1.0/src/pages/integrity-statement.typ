#import "@preview/pointless-size:0.1.2": zh


#let integrity-statement(sign, date) = [
  #set heading(numbering: none, outlined: false)
  #show heading: set text(size: zh(3))
  = 贵州大学本科毕业论文（设计）\ 诚信责任书

  #set text(size: zh(4))
  #v(1em)
  本人郑重声明：本人所呈交的毕业论文（设计），是在导师的指导下独立进行研究所完成。毕业论文（设计）中凡引用他人已经发表或未发表的成果、数据、观点等，均已明确注明出处。

  特此声明。
  #v(1em)

  #align(right)[
    论文（设计）作者签名：
    #box(
      if sign != none { sign } else { box(width: 5em, height: 2.5em) },
      baseline: 50% - 1em / 2,
    )

    日#h(1em)期：#date.display("[year]年[month]月[day]日")
  ]

  #pagebreak(weak: true)
]
