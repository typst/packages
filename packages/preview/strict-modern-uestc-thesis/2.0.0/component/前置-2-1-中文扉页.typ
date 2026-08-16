#import "../consts.typ": *
#import "../tools/lib.typ": *

#let 中文扉页(info: (:)) = [
  #set page(margin: (bottom: 1cm))
  // for debug
  #set block(stroke: if info.at(info-keys.DEBUG) { red } else { none })

  #set block(inset: 0pt, outset: 0pt)
  #set grid(inset: 0pt)
  #set grid.cell(inset: 0pt)
  #set align(center)

  #block(height: 40pt, width: 100%)[
    #set text(size: font-size.小四)
    #set align(left)
    #grid(
      columns: (1fr, 1fr),
      rows: (2em, 2em),
      text("分类号") + fixed-width-underline(width: 14em, align(center, info.at(info-keys.分类号))),
      text("密级") + fixed-width-underline(width: 14em, align(center, info.at(info-keys.密级))),

      text()[UDC#super("注1")] + fixed-width-underline(width: 14em, align(center, info.at(info-keys.UDC))),
    )
  ]

  #v(3em)

  #block()[
    #text(size: font-size.小初, weight: "bold")[#fixed-width-text-justified(width: 7em, "学位论文")]
  ]

  #layout(size => context {
    let txt = info.at(info-keys.论文中文标题).replace("\n", "")
    let line-h = measure(block(text(size: font-size.小二, weight: "bold", fixed-width-underline(
      width: size.width,
      "面向应用的扩散模高效训练、隐私审计与离散编码研究",
    )))).height
    let title-h = measure(block(text(size: font-size.小二, weight: "bold", fixed-width-underline(
      width: size.width,
      txt,
    )))).height
    let title-shrink = if title-h > line-h * 1.3 { 1em } else { 0em }

    v(3em - title-shrink)

    let width_name = size.width
    if title-shrink > 0em {
      width_name = width_name * 0.9
    }

    block()[
      #text(size: font-size.小二, weight: "bold")[
        #fixed-width-underline(width: width_name, txt)
      ]
      #block()[
        #set text(size: font-size.小四)
        #fixed-width-text(width: 20em, align(center)[（题名和副题名）])
      ]
    ]

    let shrink = 0em
    if info.at(info-keys.合作导师中文名) != none and info.at(info-keys.合作导师中文名) != "" {
      shrink = 1.5em
    }
    v(3em - shrink - title-shrink)

    block(height: auto)[
      #block()[
        #set text(size: font-size.三号, weight: "bold")
        #fixed-width-underline(width: 7em, info.at(info-keys.作者中文名))
      ]
      #block()[
        #set text(size: font-size.小四)
        #fixed-width-text(width: 20em, align(center)[（作者姓名）])
      ]
    ]

    v(3em - shrink)

    // 注意：使用 layout 时，相关的使用这套高度的代码必须写在 layout 内部
  })

  #let height_name_block = 60pt
  #if info.at(info-keys.合作导师中文名) != none and info.at(info-keys.合作导师中文名) != "" {
    height_name_block = 120pt
  } else {}

  #block(height: height_name_block)[
    #block()[
      #let adviser-text-to-display = info.at(info-keys.指导老师中文名)
      #let collabrator-text-to-display = info.at(info-keys.合作导师中文名)
      #if info.at(info-keys.指导老师职称中文) != "" {
        adviser-text-to-display = adviser-text-to-display + "   " + info.at(info-keys.指导老师职称中文)
      }
      #if info.at(info-keys.合作导师职称中文) != "" {
        collabrator-text-to-display = collabrator-text-to-display + "   " + info.at(info-keys.合作导师职称中文)
      }
      #if info.at(info-keys.合作导师中文名) != none and info.at(info-keys.合作导师中文名) != "" {
        grid(
          rows: (1fr, 1fr, 1fr, 1fr),
          justified-text-with-underline(
            4em,
            18em,
            "指导老师",
            align(
              center,
              text(weight: "bold", adviser-text-to-display),
            ),
          ),
          justified-text-with-underline(
            4em,
            18em,
            "",
            align(center, text(weight: "bold", info.at(info-keys.指导老师单位))),
          ),
          justified-text-with-underline(
            4em,
            18em,
            "合作导师",
            align(
              center,
              text(weight: "bold", collabrator-text-to-display),
            ),
          ),
          justified-text-with-underline(
            4em,
            18em,
            "",
            align(center, text(weight: "bold", info.at(info-keys.合作导师单位))),
          ),
          block()[
            #set text(size: font-size.小四)
            #fixed-width-text-justified(width: 4em, "")
            #fixed-width-text(width: 18em, align(center)[（姓名、职称、单位名称）])
          ],
        )
      } else {
        grid(
          rows: (1fr, 1fr, 1fr),
          justified-text-with-underline(
            4em,
            18em,
            "指导老师",
            align(
              center,
              text(weight: "bold", adviser-text-to-display),
            ),
          ),
          justified-text-with-underline(
            4em,
            18em,
            "",
            align(center, text(weight: "bold", info.at(info-keys.指导老师单位))),
          ),
          block()[
            #set text(size: font-size.小四)
            #fixed-width-text-justified(width: 4em, "")
            #fixed-width-text(width: 18em, align(center)[（姓名、职称、单位名称）])
          ],
        )
      }
    ]
  ]

  #v(3em)

  #let 论文提交以及答辩日期行 = grid(
    columns: (1fr, 1fr),
    justified-text-with-underline(
      6em,
      10em,
      "论文提交时间",
      align(center, text(weight: "bold", info.at(info-keys.提交日期))),
    ),
    justified-text-with-underline(
      6em,
      9.5em,
      "论文答辩日期",
      align(center, text(weight: "bold", info.at(info-keys.答辩日期))),
    ),
  )

  #let 授予单位与日期行 = justified-text-with-underline(
    9em,
    24.5em,
    "学位授予单位和日期",
    align(center, text(weight: "bold", info.at(info-keys.学位授予单位) + "      " + info.at(info-keys.学位授予日期))),
  )

  #let 答辩委员会主席显示文本 = info.at(info-keys.答辩委员会主席)
  #if info.at(info-keys.答辩委员会主席职称) != none and info.at(info-keys.答辩委员会主席职称) != "" {
    答辩委员会主席显示文本 = 答辩委员会主席显示文本 + "   " + info.at(info-keys.答辩委员会主席职称)
  }
  #let 答辩委员会主席行 = justified-text-with-underline(
    7em,
    26.5em,
    "答辩委员会主席",
    align(center, text(weight: "bold", 答辩委员会主席显示文本)),
  )

  #let 评阅人行 = justified-text-with-underline(
    3em,
    30.5em,
    "评阅人",
    align(
      center,
      text(weight: "bold", info.at(info-keys.评阅人).fold("", (prev, it) => { prev + it + "   " })),
    ),
  )

  #block(height: 150pt)[
    #if info.at(info-keys.学位类型) == "专业型" {
      grid(
        columns: 1fr,
        rows: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
        grid(
          inset: 0pt,
          columns: (1fr, 1fr),
          justified-text-with-underline(
            6em,
            10em,
            "申请学位级别",
            align(center, text(weight: "bold", info.at(info-keys.申请学位级别))),
          ),
          justified-text-with-underline(
            6em,
            10em,
            "专业学位类别",
            align(center, text(weight: "bold", info.at(info-keys.作者专业学位类别))),
          ),
        ),
        justified-text-with-underline(
          6em,
          27.8em,
          "专业学位领域",
          align(center, text(weight: "bold", info.at(info-keys.专业学位领域))),
        ),
        论文提交以及答辩日期行,
        授予单位与日期行,
        答辩委员会主席行,
        评阅人行,
      )
    } else if info.at(info-keys.学位类型) == "学术型" {
      grid(
        columns: 1fr,
        rows: (1fr, 1fr, 1fr, 1fr, 1fr),
        grid(
          inset: 0pt,
          columns: (1fr, 1fr),
          justified-text-with-underline(
            6em,
            10em,
            "申请学位级别",
            align(center, text(weight: "bold", info.at(info-keys.申请学位级别))),
          ),
          justified-text-with-underline(
            4em,
            11.5em,
            "学科专业",
            align(center, text(weight: "bold", info.at(info-keys.作者学科专业))),
          ),
        ),
        论文提交以及答辩日期行,
        授予单位与日期行,
        答辩委员会主席行,
        评阅人行,
      )
    }
  ]

  // #block(
  //   height: 150pt,
  // )[
  //   #set align(left)
  //   #grid(
  //     columns: (1fr),
  //     rows: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
  //     grid(
  //       inset: 0pt,
  //       columns: (1fr, 1fr),
  //       justified-text-with-underline(6em, 10em, "申请学位级别", align(center, text(weight: "bold", info.at(info-keys.申请学位级别)))),
  //       justified-text-with-underline(6em, 10em, "专业学位类别", align(center, text(weight: "bold", info.at(info-keys.作者专业学位类别)))),
  //     ),
  //     justified-text-with-underline(6em, 31em, "专业学位领域", align(center, text(weight: "bold", info.at(info-keys.专业学位领域)))),
  //     grid(
  //       columns: (1fr, 1fr),
  //       justified-text-with-underline(6em, 10em, "论文提交时间", align(center, text(weight: "bold", info.at(info-keys.提交日期)))),
  //       justified-text-with-underline(6em, 10em, "论文答辩日期", align(center, text(weight: "bold", info.at(info-keys.答辩日期)))),
  //     ),
  //     justified-text-with-underline(
  //       9em,
  //       28em,
  //       "学位授予单位和日期",
  //       align(center, text(weight: "bold", info.at(info-keys.学位授予单位) + "   " + info.at(info-keys.学位授予日期))),
  //     ),
  //     justified-text-with-underline(7em, 30em, "答辩委员会主席", align(center, text(weight: "bold", info.at(info-keys.答辩委员会主席)))),
  //     justified-text-with-underline(
  //       3em,
  //       34em,
  //       "评阅人",
  //       align(center, text(weight: "bold", info.at(info-keys.答辩委员会成员).fold("", (prev, it) => { prev + it + "   " }))),
  //     ),
  //   )
  // ]

  #let shrink = 0em
  #if info.at(info-keys.合作导师中文名) != none and info.at(info-keys.合作导师中文名) != "" {
    shrink = 1.5em
  }

  #v(2em - shrink)

  #block(width: 100%)[
    #set align(left)
    #text(size: font-size.五号)[注1:注明《国际十进分类法UDC》的类号。]
  ]
  #pagebreak(weak: true)
  #if info.at(info-keys.论文模式) == 论文模式.打印模式 {
    pagebreak(weak: true, to: "odd")
  }
]
