#import "../styles/fonts.typ": fonts, fontsize
#import "../styles/figures.typ": figures
#import "../styles/enums.typ": enums
#import "@preview/cuti:0.3.0": show-cn-fakebold
#import "@preview/i-figured:0.2.4"

#let doc(
  info: (:),
  fallback: false, // 字体缺失时使用 fallback，不显示豆腐块
  it,
  ifMentorAnonymous: false,
  Mentor: "MentorName",
) = {
  info = (
    (
      title: "山东大学学位论文格式模板",
      author: "渐入佳境Groove",
    )
      + info
  )

  set page(
    paper: "a4",
    margin: (top: 2.54cm, bottom: 2.54cm, left: 3.18cm, right: 3.18cm),
    header: context {
      box(
        width: 100%,
        stroke: (bottom: .5pt),
        inset: (bottom: 4pt),
        align(center)[
          #block()[
            #text(
              "山东大学本科毕业论文(设计)",
              font: fonts.宋体,
              size: fontsize.小五,
            )
            #v(-.25em)
          ]
        ],
      )
    },
  )

  set text(
    font: fonts.宋体,
    size: fontsize.小四,
    top-edge: "ascender",
    bottom-edge: "descender",
  )

  set par(
    first-line-indent: (amount: 2em, all: true),
    spacing: 0.3em,
    leading: 0.3em,
  )

  show: show-cn-fakebold
  show: figures
  show: enums
  show ref: r => [
    #text(fill: rgb("c00000"), r)
  ]

  set document(
    title: info.title,
    author: info.author,
  )

  // 导师设为隐藏
  show Mentor: if ifMentorAnonymous { `****` } else { Mentor }

  it
}
