#import "../../../common/theme/type.typ": 字体, 字号
#import "../../../common/components/typography.typ": indent
#import "../../../common/components/typography.typ": heading-level-1-style, heading-block-unit-multiplier
#import "../../../common/utils/states.typ": thesis-info-state
#import "../../../common/components/header.typ": use-hit-header
#import "../../../common/components/enheading.typ": enheading
#import "../../../common/utils/states.typ": thesis-info-state, special-chapter-titles-state
#import "../../../common/components/digital-signature.typ": use-digital-signature

#let declaration-of-originality() = context {


  let special-chapter-titles = special-chapter-titles-state.get()
  
  show: use-hit-header.with(header-text: special-chapter-titles.原创性声明)
  
  show: use-digital-signature

  [
    #show heading: none
    #heading(special-chapter-titles.原创性声明, level: 1)
    #enheading(special-chapter-titles.原创性声明-en)
  ]

  v(-16pt)

  heading-level-1-style[#block()[#special-chapter-titles.原创性声明]]

  v(23pt)

  align(center)[
    #text(font: 字体.黑体, size: 字号.小三)[
      #block(below: 2em)[
        学位论文原创性声明
      ]
    ]
  ]

  context {
    let thesis-info = thesis-info-state.get()

    let title = thesis-info.at("title-cn")

    if type(title) == str {
      title = title.split("\n").sum()
    }

    text()[

      本人郑重声明：此处所提交的学位论文《#title》，是本人在导师指导下，在哈尔滨工业大学攻读学位期间独立进行研究工作所取得的成果，且学位论文中除已标注引用文献的部分外不包含他人完成或已发表的研究成果。对本学位论文的研究工作做出重要贡献的个人和集体，均已在文中以明确方式注明。

      #v(1.7em)

    ]
  }

  grid(
    columns: (1fr, 1fr),
    rows: (auto),
    pad(left: 5em)[

      #text[作者签名：]

    ],
    align(right)[
      #text[日期：#h(2.5em) 年 #h(1.3em) 月 #h(1.4em) 日 #h(1.6em)]
    ],
  )

  v(3.5em)


  align(center)[
    #text(font: 字体.黑体, size: 字号.小三)[
      #block(above: 2em, below: 2em)[学位论文使用权限]
    ]
  ]

  text(tracking: 0.8pt)[

    学位论文是研究生在哈尔滨工业大学攻读学位期间完成的成果，知识产权归属哈尔滨工业大学。学位论文的使用权限如下：

    （1）学校可以采用影印、缩印或其他复制手段保存研究生上交的学位论文，并向国家图书馆报送学位论文；（2）学校可以将学位论文部分或全部内容编入有关数据库进行检索和提供相应阅览服务；（3）研究生毕业后发表与此学位论文研究成果相关的学术论文和其他成果时，应征得导师同意，且第一署名单位为哈尔滨工业大学。

    保密论文在保密期内遵守有关保密规定，解密后适用于此使用权限规定。

    本人知悉学位论文的使用权限，并将遵守有关规定。

  ]

  v(2.9em)

  grid(
    columns: (1fr, 1fr),
    rows: (auto),
    pad(left: 5.9em)[

      #text[作者签名：]

    ],
    align(right)[
      #text[日期：#h(2.4em) 年 #h(1.3em) 月 #h(1.4em) 日 #h(0.8em)]
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
      #text[日期：#h(2.4em) 年 #h(1.3em) 月 #h(1.4em) 日 #h(0.8em)]
    ],
  )
}