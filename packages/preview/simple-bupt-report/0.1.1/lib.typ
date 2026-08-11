// 设置页面格式
#import "@preview/cuti:0.3.0": show-cn-fakebold
#import "cover.typ": generate-cover
#show: show-cn-fakebold

#let experiment-report(
  title: "",
  semester: "",
  name: "",
  student-id: "",
  class: "",
  date: "",
  body,
) = {
  
  // 初始化相关页面、文本和段落样式
  set page(
    paper: "a4",
    margin: (top: 2.54cm, bottom: 2.54cm, left: 3.18cm, right: 3.18cm),
  )
  set text(
    font: ("Times New Roman", "SimHei"),
    size: 12pt,
    weight: "regular",
    lang: "zh"
  )
  set par(first-line-indent: (amount:2em,all:true), leading: 1.2em)
  
  // 封面页
  generate-cover(
    title,
    semester,
    class,
    name,
    student-id,
    date,
  )

  // 图表标题样式
  show figure.caption: it => {
    text(font: ("Times New Roman", "FangSong"), size: 9pt)[#it.body]
  }

  // 一级标题样式
  show heading.where(level: 1): it => [
    #align(center)[
      #v(12pt)
      #par(first-line-indent: (amount:0em,all:true))[
        #text(font: ("Times New Roman", "SimHei"), size: 16pt, weight: "bold")[#it.body]
      ]
      #v(20pt)
    ]
  ]

  // 二级标题样式
  show heading.where(level: 2): it => [
    // 计算二级标题的编号
    #counter(heading.where(level: 2)).step()
    #counter(heading.where(level: 3)).update(0)
    #let num = counter(heading.where(level: 2)).get().at(0) + 1
    
    // 二级标题样式具体设置
    #align(left)[
      #par(first-line-indent: (amount:0em,all:true))[
        #text(font: ("Times New Roman", "SimHei"), size: 14pt, weight: "bold")[
          #numbering("一、", num)
          #it.body
        ]
      ]
    ]
  ]

  // 三级标题样式
  show heading.where(level: 3): it => [
    // 计算三级标题的编号
    #counter(heading.where(level: 3)).step()
    #let two_head = counter(heading.where(level: 2)).get().at(0)
    #let num = counter(heading.where(level: 3)).get().at(0) + 1

    // 三级标题样式具体设置
    #align(left)[
      #par(first-line-indent: (amount:2em,all:true))[
        #text(font: ("Times New Roman", "SimHei"), size: 12pt, weight: "bold")[
          #numbering("1.1", two_head, num)
          #it.body
        ]
      ]
    ]
  ]

  // 代码标题样式
  show raw.where(block: true): block => [
    #pad(left: 2.5em)[
      #block
    ]
  ]

  // 主体文档
  body
}
