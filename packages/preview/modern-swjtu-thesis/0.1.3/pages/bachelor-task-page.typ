#import "../utils/style.typ": 字号, 字体

// 本科生毕业设计（论文）任务书
#let bachelor-task-page(
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
    // 修改 leading 来调整段落文字的基础行间距，原为 1.5em，这里缩小为 1.2em
    #set par(leading: 1.2em, first-line-indent: 0em)

    #let field(width: 100%, content: "") = {
      box(width: width, stroke: (bottom: 0.5pt), outset: (bottom: 0.1em), align(center)[#content])
    }
    

    #v(1em)
    #align(center)[
      #set text(font: fonts.黑体, size: 字号.三号, weight: "bold")
      毕业设计（论文）任务书
    ]
    #v(1.5em)

    #grid(
      columns: (4em, 1fr, 4em, 1fr, 4em, 1fr),
      row-gutter: 1em,
      column-gutter: 0.5em,
      align: (left, bottom, left, bottom, left, bottom),
      [班#h(2em)级], field(),
      [学生姓名], field(),
      [学#h(2em)号], field(),
    )
    #grid(
      columns: (4.5em, 1fr, 4.5em, 1fr),
      row-gutter: 1em,
      column-gutter: 0.5em,
      align: (left, bottom, left, bottom),
      [发题日期：], align(left)[#h(1.5em)#info.at("issue-date", default: [ 年    月    日])],
      [完成日期：], align(right)[#h(1.5em)#info.at("finish-date", default: [  月    日])],
    )
    #grid(
      columns: (4em, 1fr),
      row-gutter: 1em,
      column-gutter: 0.5em,
      align: (left, bottom),
      [题#h(2em)目], field(),
    )

    #grid(
      columns: (15em, 1fr),
      row-gutter: 1em,
      column-gutter: 0pt,
      align: (left, bottom),
      [1、本设计（论文）的目的、意义], field()
    )
    #field()
    #field()
    #field()
    #field()

    #v(1.2em)
    #grid(
      columns: (10em, 1fr),
      row-gutter: 1.5em,
      column-gutter: 0pt,
      align: (left, bottom),
      [2、学生应完成的任务], field()
    )
    #field()
    #field()
    #field()
    #field()
    #field()
    3、本设计（论文）与本专业的毕业要求达成度如何？（如在知识结构、能力结构、素质结构等方面有哪些有效的训练。）
    #field()
    #field()
    #field()
    #field()
    #field()
    // 任务书第二页部分，通常这会随着内容增多自动分页。如果需要强行第二页，可以在这里加 #pagebreak()
    #pagebreak()
    #v(1.2em)
    4、本设计（论文）各部分内容及时间分配：（共#box(width: 4em, stroke: (bottom: 0.5pt), outset: (bottom: 0.1em), align(center)[#info.at("task-weeks", default: "17")])周）
    
    #let part-row(name) = {
      grid(
        columns: (auto, 1fr, 3em),
        row-gutter: 1.5em,
        column-gutter: 0pt,
        align: (left, bottom, right),
        [#h(2em)#name], field(), [（ 周）]
      )
    }
    
    #v(1em)
    #part-row("第一部分")
    #part-row("第二部分")
    #part-row("第三部分")
    #part-row("第四部分")
    #part-row("第五部分")
    #part-row("评阅及答辩")

    #v(2.5em)
    #grid(
      columns: (4em, 1fr),
      row-gutter: 2em,
      column-gutter: 0pt,
      align: (left, bottom),
      [备#h(2em)注], field()
    )
    #field()
    #field()

    #v(1.5em)
    #grid(
      columns: (auto, 4em, 1fr),
      row-gutter: 1.5em,
      column-gutter: 0.5em,
      align: (left, bottom, left),
      [指导教师：], field(), [#h(2em)年#h(2em)月#h(2em)日],
      [审#h(0.5em)批#h(0.5em)人：], field(), [#h(2em)年#h(2em)月#h(2em)日]
    )
  ]
}
