#import "../consts.typ": *
#import "../utils/lib.typ": *
#import "../tools/lib.typ": *

#let 英文扉页(info: (:)) = [
  #set page(margin: (bottom: 1cm))
  // for debug
  #set block(stroke: if info.at(info-keys.DEBUG) { red } else { none })

  #set block(inset: 0pt, outset: 0pt)
  #set grid(inset: 0pt)
  #set grid.cell(inset: 0pt)
  #set align(center)

  #v(4em)

  #block()[
    #set align(center)
    #set text(font: get-hei-font(info), size: font-size.小二, weight: "bold", lang: "en")
    #info.at(info-keys.论文英文标题)
  ]

  #v(16em)

  #block()[
    #set align(center)
    #set text(font: get-hei-font(info), size: font-size.小三)
    #if info.at(info-keys.申请学位级别) == "硕士" {
      text("A Master Thesis Submitted to \n University of Electronic Science and Technology of China")
    } else if info.at(info-keys.申请学位级别) == "博士" {
      text("A Doctoral Dissertation Submitted to \n University of Electronic Science and Technology of China")
    }
  ]

  #v(12em)

  #block(height: 140pt)[
    #set align(center)
    #let 学科名称 = if info.at(info-keys.学位类型) == "学术型" {
      info.at(info-keys.作者学科专业英文)
    } else if info.at(info-keys.学位类型) == "专业型" {
      info.at(info-keys.作者专业学位类别英文)
    } else {
      ""
    }

    #let text-to-display = info.at(info-keys.指导老师英文名)
    #if info.at(info-keys.指导老师职称英文) != "" {
      text-to-display = text-to-display + "   " + info.at(info-keys.指导老师职称英文)
    }
    #grid(
      columns: 1fr,
      rows: (1fr, 1fr, 1fr, 1fr, 1fr),
      fixed-text-with-underline(5em, 25em, align(right)[Discipline], align(center, text(weight: "bold", 学科名称))),
      fixed-text-with-underline(
        5em,
        25em,
        align(right)[Student ID],
        align(center, text(weight: "bold", info.at(info-keys.作者学号))),
      ),
      fixed-text-with-underline(
        5em,
        25em,
        align(right)[Author],
        align(center, text(weight: "bold", info.at(info-keys.作者英文名))),
      ),
      fixed-text-with-underline(
        5em,
        25em,
        align(right)[Supervisor],
        align(
          center,
          text(weight: "bold", text-to-display),
        ),
      ),
      fixed-text-with-underline(
        5em,
        25em,
        align(right)[School],
        align(center, text(weight: "bold", info.at(info-keys.作者学院英文))),
      ),
    )
  ]

  #pagebreak(weak: true)
  #if info.at(info-keys.论文模式) == 论文模式.打印模式 {
    pagebreak(weak: true, to: "odd")
  }
]
