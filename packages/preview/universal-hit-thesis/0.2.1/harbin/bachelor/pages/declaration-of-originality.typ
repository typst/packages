#import "../config/constants.typ": special-chapter-titles
#import "../../../common/theme/type.typ": 字体, 字号
#import "../utils/states.typ": thesis-info-state

#let declaration-of-originality() = {
  set par(leading: 1.25em)

  v(0.25em)
  align(center)[
    #text(font: 字体.黑体, size: 字号.小二)[
      哈尔滨工业大学本科毕业论文（设计）
    ]
  ]
  v(-1.75em)

  heading(special-chapter-titles.原创性声明, level: 1, numbering: none)

  align(center)[
    #text(font: 字体.黑体, size: 字号.小三)[
      #v(0.5em)

      本科毕业论文（设计）原创性声明

      #v(0.5em)
    ]
  ]

  context {
    let thesis-info = thesis-info-state.get()

    let title = thesis-info.at("title-cn")

    if type(title) == str {
      title = title.split("\n").sum()
    }

    text()[

      本人郑重声明：此处所提交的本科毕业论文（设计）《#title》，是本人在导师指导下，在哈尔滨工业大学攻读学士学位期间独立进行研究工作所取得的成果，且毕业论文（设计）中除已标注引用文献的部分外不包含他人完成或已发表的研究成果。对本毕业论文（设计）的研究工作做出重要贡献的个人和集体，均已在文中以明确方式注明。

      #v(1em)

    ]
  }

  grid(
    columns: (1fr, 1fr),
    rows: (auto),
    pad(left: 8em)[

      #text[作者签名：]

    ],
    align(right)[
      #text[日期：#h(4em) 年 #h(2em) 月 #h(2em) 日]
    ],
  )

  v(2em)


  align(center)[
    #text(font: 字体.黑体, size: 字号.小三)[
      #v(0.5em)

      本科毕业论文（设计）使用权限

      #v(0.5em)
    ]
  ]

  text()[

    本科毕业论文（设计）是本科生在哈尔滨工业大学攻读学士学位期间完成的成果，知识产权归属哈尔滨工业大学。本科毕业论文（设计）的使用权限如下：

    （1）学校可以采用影印、缩印或其他复制手段保存本科生上交的毕业论文（设计），并向有关部门报送本科毕业论文（设计）；（2）根据需要，学校可以将本科毕业论文（设计）部分或全部内容编入有关数据库进行检索和提供相应阅览服务；（3）本科生毕业后发表与此毕业论文（设计）研究成果相关的学术论文和其他成果时，应征得导师同意，且第一署名单位为哈尔滨工业大学。

    保密论文在保密期内遵守有关保密规定，解密后适用于此使用权限规定。

    本人知悉本科毕业论文（设计）的使用权限，并将遵守有关规定。

  ]

  v(2em)

  grid(
    columns: (1fr, 1fr),
    rows: (auto),
    pad(left: 8em)[

      #text[作者签名：]

    ],
    align(right)[
      #text[日期：#h(4em) 年 #h(2em) 月 #h(2em) 日]
    ],
  )

  v(1em)

  grid(
    columns: (1fr, 1fr),
    rows: (auto),
    pad(left: 8em)[

      #text[导师签名：]

    ],
    align(right)[
      #text[日期：#h(4em) 年 #h(2em) 月 #h(2em) 日]
    ],
  )
}