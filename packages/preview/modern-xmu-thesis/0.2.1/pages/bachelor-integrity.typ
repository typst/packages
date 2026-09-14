#import "../utils/style.typ": 字号, 字体

// 本科生诚信承诺书页
#let bachelor-integrity(twoside: false, fonts: (:)) = {
  // 1.  默认参数
  fonts = 字体 + fonts

  // 2.  正式渲染
  pagebreak(weak: true, to: if twoside { "odd" })

  set page(margin: (x: 3cm, top: 2.5cm, bottom: 2cm))

  align(center, text(font: fonts.宋体, size: 字号.三号, weight: "bold", "厦门大学本科学位论文诚信承诺书"))

  v(3em)

  block[
    #set text(font: fonts.宋体, size: 字号.四号)
    #set par(justify: true, first-line-indent: (amount: 2em, all: true), leading: 1.5em, spacing: 1.5em)

    本人呈交的学位论文是在导师指导下独立完成的研究成果。本人在论文写作中参考其他个人或集体已经发表的研究成果，均在文中以适当方式
    明确标明，并符合相关法律规范及《厦门大学本科毕业论文（设计）规范》。

    该学位论文为（#h(14em)）课题（组）的研究成果，获得（#h(7.5em)）课题（组）经费或实验室的资助，在（#h(7.5em)）实验室完成（请在以上括号内填写课题或课题组负责人或实验室名称，未有此项声明内容的，可以不作特别声明）。

    本人承诺辅修专业毕业论文（设计）（如有）的内容与主修专业不存在相同与相近情况。
  ]

  v(4em)

  grid(
    columns: (1fr, 15.5em, 3.5em),
    [],
    {
      align(left)[
        #set text(font: fonts.宋体, size: 字号.四号)
        学生声明（签名）：
      ]
      align(right)[
        #set text(font: fonts.宋体, size: 字号.四号)
        年#h(1.5em) 月#h(1.5em) 日
      ]
    },
  )
}
