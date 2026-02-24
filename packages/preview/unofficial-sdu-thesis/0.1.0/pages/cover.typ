#import "../styles/fonts.typ": fonts, fontsize
#import "../styles/distr.typ": distr
#import "@preview/cuti:0.3.0": show-cn-fakebold, fakebold

#let cover-page(
  info: (:),
) = {
  set page(header: none)

  let info-key(zh) = (
    text(
      fakebold()[#distr(zh, w: 4em)],
      // distr(zh, w: 4em),
      font: fonts.楷体,
      weight: "bold",
      size: 16pt,
    )
  )
  set par(first-line-indent: 2em, spacing: 0em, leading: 0em)
  align(center)[
    #v(3em)
    #image("../imgs/logo.svg", width: 55%)
    #v(-13em)
    #block(width: 50em)[
      #scale(x: 70%)[
        #text(font: fonts.方正大黑简体, size: 62pt, weight: "medium")[#v(2.6em)毕 业 论 文]
        #text(font: fonts.楷体, size: 62pt, weight: "medium")[（]
        #text(font: fonts.方正大黑简体, size: 62pt, weight: "medium")[设 计]
        #text(font: fonts.楷体, size: 62pt, weight: "medium")[）]
      ]]
    #v(1.7em)
  ]
  fakebold[#text(font: fonts.宋体, size: fontsize.三号, weight: "bold")[论文（设计）题目：]]

  v(4.6em)
  align(center)[
    #fakebold[
      #text(font: ("SimHei", "Heiti SC", "STHeiti"), size: fontsize.小二)[
        #info.title
      ]
    ]
  ]
  v(5em)
  {
    align(center)[
      #block(width: 55%)[
        #table(
          stroke: none,
          gutter: 0.8em,
          columns: (auto, 1fr),
          inset: (right: -.7em, bottom: .1em),
          align: (x, y) => (
            if x >= 1 {
              left
            } else {
              center
            }
          ),
          table.hline(start: 1, position: bottom),
          [#info-key("姓名")], [#h(.5em) #text(size: fontsize.四号, font: fonts.宋体)[#info.name]],
          table.hline(start: 1, position: bottom),
          [#info-key("学号")], [#h(.5em) #text(size: fontsize.四号, font: fonts.宋体)[#info.id]],
          table.hline(start: 1, position: bottom),
          [#info-key("学院")], [#h(.5em) #text(size: fontsize.四号, font: fonts.宋体)[#info.school]],
          table.hline(start: 1, position: bottom),
          [#info-key("专业")], [#h(.5em) #text(size: fontsize.四号, font: fonts.宋体)[#info.major]],
          table.hline(start: 1, position: bottom),
          [#info-key("年级")], [#h(.5em) #text(size: fontsize.四号, font: fonts.宋体)[#info.grade]],
          table.hline(start: 1, position: bottom),
          [#info-key("指导教师")], [#h(.5em) #text(size: fontsize.四号, font: fonts.宋体)[#info.mentor]],
        )
      ]
    ]
  }
  align(alignment.bottom + center)[
    #show-cn-fakebold()[#text(font: fonts.楷体, size: fontsize.三号, weight: "bold")[
        #info.time]
    ]
    #v(6.1em)
  ]
  pagebreak()
}
