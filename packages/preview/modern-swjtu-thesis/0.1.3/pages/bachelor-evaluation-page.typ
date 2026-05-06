#import "../utils/style.typ": 字号, 字体

// 本科生毕业设计（论文）评阅/成绩页
#let bachelor-evaluation-page(
  anonymous: false,
  twoside: false,
  fonts: (:),
  info: (:),
) = {
  fonts = 字体 + fonts
  pagebreak(weak: true, to: if twoside { "odd" })

  page(
    margin: (top: 2.6cm, bottom: 2.6cm, left: 2.7cm, right: 2.7cm),
    header: [
      #set text(font: fonts.宋体, size: 字号.小五)
      #align(center)[西南交通大学本科毕业设计（论文）]
      #v(-0.5em)
      #line(length: 100%, stroke: 0.5pt)
    ],
    footer: context {
      set text(font: fonts.宋体, size: 字号.小五)
      align(center)[第#counter(page).display("I")页]
    }
  )[
    #set text(font: fonts.宋体, size: 字号.小四)
    #set par(leading: 1.5em, first-line-indent: 0em)

    #let field(width: 100%, content: "") = {
      box(width: width, stroke: (bottom: 0.5pt), outset: (bottom: 0.1em), align(center)[#content])
    }
    
    #let title-text = if type(info.title) == array { info.title.join("") } else { info.title }

    #v(1em)
    #grid(
      columns: (4em, 1fr, 4em, 1fr),
      row-gutter: 0.5em,
      column-gutter: 0.5em,
      [院#h(1em)系], field(),
      [专#h(1em)业], field(),
      [年#h(1em)级], field(),
      [姓#h(1em)名], field(),
      [题#h(1em)目], grid.cell(colspan: 3, field())
    )

    #v(1em)
    // Section 1: 指导教师评语
    #grid(
      columns: (4em, 1fr),
      align: (left, bottom),
      row-gutter: 0.5em,
      column-gutter: 0.5em,
      [指导教师], line(length: 100%, stroke: 0.5pt),
      [评#h(1fr)语], line(length: 100%, stroke: 0.5pt),
      hide[空], line(length: 100%, stroke: 0.5pt),
      hide[空], line(length: 100%, stroke: 0.5pt),
      hide[空], line(length: 100%, stroke: 0.5pt),
      hide[空], line(length: 100%, stroke: 0.5pt),
      hide[空], line(length: 100%, stroke: 0.5pt),
      hide[空], line(length: 100%, stroke: 0.5pt),
      hide[空], line(length: 100%, stroke: 0.5pt),
      hide[空], line(length: 100%, stroke: 0.5pt),
      hide[空], line(length: 100%, stroke: 0.5pt),
    )
    
    #align(right)[
      #v(0.8em)
      指导教师#box(width: 4em, stroke: (bottom: 0.5pt))[]（签章）
    ]

    #v(2.5em)
    // Section 2: 评阅人评语
    #grid(
      columns: (4em, 1fr),
      align: (left, bottom),
      row-gutter: 0.5em,
      column-gutter: 0.5em,
      [评#h(0.5em)阅#h(0.5em)人], line(length: 100%, stroke: 0.5pt),
      [评#h(1fr)语], line(length: 100%, stroke: 0.5pt),
      hide[空], line(length: 100%, stroke: 0.5pt),
      hide[空], line(length: 100%, stroke: 0.5pt),
      hide[空], line(length: 100%, stroke: 0.5pt),
      hide[空], line(length: 100%, stroke: 0.5pt),
      hide[空], line(length: 100%, stroke: 0.5pt),
      hide[空], line(length: 100%, stroke: 0.5pt),
      hide[空], line(length: 100%, stroke: 0.5pt),
    )

    #align(right)[
      #v(0.8em)
      评#h(0.5em)阅#h(0.5em)人#box(width: 4em, stroke: (bottom: 0.5pt))[]（签章）
    ]
    
    #v(2.5em)
    #grid(
      columns: (auto, auto),
      row-gutter: 1.5em,
      [成#h(2em)绩#box(width: 12em, stroke: (bottom: 0.5pt))[]], [],
      [答辩委员会主任#box(width: 6em, stroke: (bottom: 0.5pt))[]（签章)], []
    )

    #v(3em)
    #align(right)[
      年#h(2em)月#h(2em)日#h(1em)
    ]
  ]
}