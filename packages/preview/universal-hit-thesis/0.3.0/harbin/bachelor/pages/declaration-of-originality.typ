#import "../../../common/theme/type.typ": 字体, 字号
#import "../../../common/components/typography.typ": indent
#import "../../../common/components/typography.typ": heading-level-1-style, heading-block-unit-multiplier
#import "../../../common/utils/states.typ": thesis-info-state, special-chapter-titles-state, digital-signature-option-state
#import "../../../common/config/constants.typ": e-digital-signature-mode
#import "../../../common/components/digital-signature.typ": use-digital-signature

#let declaration-of-originality() = context {
  
  show: use-digital-signature

  let special-chapter-titles = special-chapter-titles-state.get()

  v(-1.3em)

  heading-level-1-style[#block()[哈尔滨工业大学本科毕业论文（设计）]]

  [
    #show heading: none
    #heading(special-chapter-titles.原创性声明, level: 1)
  ]

  v(-0.7em, weak: true)

  heading-level-1-style[#block()[#special-chapter-titles.原创性声明]]

  align(center)[
    #text(font: 字体.黑体, size: 字号.小三)[
      #block(below: 1.5em)[
        本科毕业论文（设计）原创性声明
      ]
    ]
  ]

  context {
    let thesis-info = thesis-info-state.get()

    let title = thesis-info.at("title-cn")

    if type(title) == str {
      title = title.split("\n").sum()
    }

    // [#par.leading #par.spacing]

    text()[

      本人郑重声明：此处所提交的本科毕业论文（设计）《#title》，是本人在导师指导下，在哈尔滨工业大学攻读学士学位期间独立进行研究工作所取得的成果，且毕业论文（设计）中除已标注引用文献的部分外不包含他人完成或已发表的研究成果。对本毕业论文（设计）的研究工作做出重要贡献的个人和集体，均已在文中以明确方式注明。

      #v(1.5em)

    ]
  }

  grid(
    columns: (1fr, 1fr),
    rows: (auto),
    pad(left: 6.4em)[

      #text[作者签名：]

    ],
    align(right)[
      #text[日期：#h(2.4em) 年 #h(1.3em) 月 #h(1.4em) 日 #h(0.7em)]
    ],
  )

  v(3.25em)


  align(center)[
    #text(font: 字体.黑体, size: 字号.小三)[
      #block(above: 1.5em, below: 1.5em)[本科毕业论文（设计）使用权限]
    ]
  ]

  text(tracking: 0.8pt)[

    本科毕业论文（设计）是本科生在哈尔滨工业大学攻读学士学位期间完成的成果，知识产权归属哈尔滨工业大学。本科毕业论文（设计）的使用权限如下：

    （1）学校可以采用影印、缩印或其他复制手段保存本科生上交的毕业论文（设计），并向有关部门报送本科毕业论文（设计）；（2）根据需要，学校可以将本科毕业论文（设计）部分或全部内容编入有关数据库进行检索和提供相应阅览服务；（3）本科生毕业后发表与此毕业论文（设计）研究成果相关的学术论文和其他成果时，应征得导师同意，且第一署名单位为哈尔滨工业大学。

    保密论文在保密期内遵守有关保密规定，解密后适用于此使用权限规定。

    本人知悉本科毕业论文（设计）的使用权限，并将遵守有关规定。

  ]

  v(2.9em)

  grid(
    columns: (1fr, 1fr),
    rows: (auto),
    pad(left: 5.9em)[

      #text[作者签名：]

    ],
    align(right)[
      #text[日期：#h(2.4em) 年 #h(1.3em) 月 #h(1.4em) 日 #h(1.2em)]
    ],
  )

  v(1.45em)

  grid(
    columns: (1fr, 1fr),
    rows: (auto),
    pad(left: 5.9em)[

      #text[导师签名：]

    ],
    align(right)[
      #text[日期：#h(2.4em) 年 #h(1.3em) 月 #h(1.4em) 日 #h(1.2em)]
    ],
  )
}