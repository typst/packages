#import "@preview/cuti:0.2.1": show-cn-fakebold

#let mychecked = text(weight: "bold", font: "Times New Roman", "✓")
#let myunchecked = text(font: "SimSun", size: 1.0em, "□")

#let project(
  cover-title: "",
  name: "",
  student-id: "",
  major: "",
  supervisor: "",
  school: "",
  thesis-title: "",
  subject-source: "",
  subject-nature: "",
  subject-id: "",
  body,
) = {
  let thesis-title = if thesis-title == none or thesis-title == "" or thesis-title == cover-title {
    cover-title
  } else {
    thesis-title
  }

  set page(
    paper: "a4",
    margin: (top: 2.54cm, bottom: 2.54cm, left: 3.18cm, right: 3cm),
  )

  show: show-cn-fakebold
  set text(font: ("Times New Roman", "SimSun"), size: 12pt, lang: "zh")

  set heading(numbering: "1.1.1")
  show heading: it => {
    let nums = counter(heading).at(it.location())
    let title-font = ""
    let n_str = none
    let title-weight = ""
    if it.level == 1 {
      title-font = ("Times New Roman", "SimHei")
      title-weight = "regular"
      n_str = none
      colbreak(weak: true)
    } else {
      title-font = ("Times New Roman", "SimSun")
      title-weight = "bold"
      let display_nums = nums.slice(1) 
      n_str = numbering("1.1.1", ..display_nums)
    }
    set text(font: title-font, weight: title-weight, size: 12pt)
    set par(first-line-indent: 0pt)
    if it.level > 1 {
      v(2em, weak: true)
    }
    grid(
      columns: (auto, 1fr),
      column-gutter: if n_str != none { 0.5em } else { 0pt },
      inset: 0pt,
      if n_str != none [#n_str],
      [#it.body]
    )
    v(1.5em, weak: true)
  }

  show ref: it => {
    let el = it.element
    if el != none and el.func() == heading {
      let nums = counter(heading).at(el.location())
      if el.level == 1 {
        it
      } else {
        let display_nums = nums.slice(1)
        let n_str = numbering("1.1", ..display_nums)
        link(el.location(), [小节 #n_str])
      }
    } else {
      it
    }
  }

  set page(numbering: none)
  align(center)[
    #image("./figures/sjtu-title.png", width: 14.8cm)
    #v(0.0cm)
    #box(scale(x: 110%, origin: center)[
      #text(font: ("Times New Roman", "SimSun"), size: 18pt)[SHANGHAI JIAO TONG UNIVERSITY]\
    ])
    #v(0.5cm)
    #text(size: 22pt, weight: "bold")[本科生毕业设计（论文）开题报告]
    #v(0.5cm)
    #image("./figures/sjtu-logo.png", width: 5.77cm)
    #v(0.5cm)
    #text(size: 16pt,font: ("Times New Roman", "KaiTi"))[
      #grid(
        columns: (80pt, 320pt),
        column-gutter: 0em,
        [
          #set align(left + horizon)
          #block(
            width: 100%, 
            stroke: (bottom: white + 0.5pt),
            inset: (top: 0pt, bottom: 5pt),
          )[论文题目：]
        ],
        [
          #set align(center + horizon)
          #block(
            width: 100%, 
            stroke: (bottom: 0.5pt),
            inset: (top: 0pt, bottom: 5pt),
          )[#cover-title]
        ]
      )
    ]
  ]
  
  let field(label, content) = (
    [
      #set align(left + horizon)
      #block(
        width: 100%,
        stroke: (bottom: white + 0.5pt), 
        inset: (top: 0pt, bottom: 5pt),
      )[
        #set text(font: ("KaiTi"))
        #text(size: 16pt)[#label]
      ]
    ],
    [
      #set align(center + horizon)
      #block(
        width: 100%, 
        stroke: (bottom: 0.5pt), 
        inset: (top: 0pt, bottom: 5pt),
      )[
        #set text(font: ("Times New Roman", "KaiTi"), size: 16pt)
        #set par(first-line-indent: 0pt, leading: 0em)
        #content
      ]
    ]
  )
  v(10pt)
  align(center)[
    #grid(
      columns: (80pt, 180pt),
      column-gutter: 0em,
      row-gutter: 10pt,
      ..field("学生姓名:", name),
      ..field("学生学号:", student-id),
      ..field([专#h(2em)业:], major),
      ..field("指导教师:", supervisor),
      ..field("学院(系):", school),
    )
    #v(10pt)
    #text(font: ("KaiTi"), size: 16pt)[教务处制表]
  ]

  pagebreak()

  align(center)[
    #v(2cm)
    #set text(font: ("Times New Roman", "SimHei"), size: 18pt, weight: "bold")
    #{ let q = h(0.18em); [填 #q 表 #q 说 #q 明] }
    #v(18pt)
  ]

  set text(font: ("Simsun"), size: 14pt)
  set par(first-line-indent: 0pt, hanging-indent: 0cm,  leading: 20pt, justify: true)
  enum(
    indent: 0em,
    body-indent: 0.74cm - 1em,
    pad(right: 0.2cm)[
      根据《上海交通大学关于本科生毕业设计(论文)工作的若干规定》要求，每位学生必须认真撰写《毕业设计（论文）开题报告》。
    ],
    pad(right: 0.2cm)[
      每位学生应在指导教师的指导下认真、实事求是地填写各项内容。文字表达要明确、严谨，语句通顺，条理清晰。外来语要同时用原文和中文表达，第一次出现的缩写词，须注出全称。
    ],
    pad(right: 0.2cm)[
      开题前，须进行文献查阅，要求与论文研究有关的主要参考文献阅读数量不少于10篇，其中外文资料应占一定比例。参考文献的书写请参照《上海交通大学本科生毕业设计（论文）撰写规范》。
    ],
    pad(right: 0.2cm)[
      毕业设计（论文）开题报告总字数应满足本院（系）要求。
    ],
    pad(right: 0.2cm)[
      请用宋体小四号字体填写，并用A4纸打印，于左侧装订成册。
    ],
    pad(right: 0.2cm)[
      该表填写完毕后，须请指导教师审核，并签署意见。
    ],
    pad(right: 0.2cm)[
      《上海交通大学本科生毕业设计（论文）开题报告》将作为答辩资格审查的主要材料之一。
    ],
    pad(right: 0.2cm)[
      本表格不够可自行扩页。
    ]
  )

  pagebreak()

  set page(
    margin: (
      top: 2.82cm,
      bottom: 2.54cm,
      left: 3.18cm,
      right: 3cm,
    ),
    header-ascent: 0cm,
    header: [
      #set text(size: 9pt, font: ("SimSun"))
      #grid(
        columns: (1fr, 1fr),
        align: bottom,
        image("./figures/sjtu-logo-title.png", width: 4.8cm),
        align(right)[毕业设计（论文）开题报告]
      )
      #v(-0.25cm)
      #line(length: 100%, stroke: 0.5pt)
    ],
    background: place(top + left, 
      dx: 3.18cm,
      dy: 2.82cm + 0.5cm,
    )[
      #box(
        width: 100% - (3.18cm + 3cm),
        height: 100% - (2.82cm + 0.5cm + 2.54cm),
        stroke: 0.5pt,
      )
    ],
    numbering: none,
  )
  v(0.1cm)
  align(center)[
    #block(
      fill: white,
      width: 15cm,
      inset: (top: 1.5em, bottom: 1.5em),
      stroke: none,
      text(
        size: 15pt, 
        font: ("KaiTi"), 
        weight: "bold"
      )[毕业设计(论文)开题报告]
    )
  ]
  v(-0.6cm)
  set text(size: 12pt,font: ("Times New Roman", "Simsun"))
  set par(leading: 0.65em)
  grid(
    columns: (auto, 1fr, auto, 1fr, auto, 1fr),
    align: center + horizon,
    inset: (
      x: 5pt,
      y: 8pt
    ),
    stroke: (x, y) => (
      top: 0.5pt,
      bottom: 0.5pt,
      left: if x > 0 { 0.5pt } else { 0pt },
      right: 0pt,
    ),
    grid.cell(colspan: 1)[论文题目],
    grid.cell(colspan: 5, align: center)[#thesis-title],
    [课题来源], [#subject-source],
    [课题性质], [#subject-nature],
    [项目编号], [#subject-id],
  )
  v(-0.8cm)
  
  show: rest => pad(
    top: 0.5cm + 0.3cm,
    bottom: 0.3cm,
    left: 0.3cm,
    right: 0.3cm,
    rest
  )
  set text(size: 12pt,font: ("Times New Roman", "Simsun"))
  set par(
    justify: true,
    leading: 1em,
    spacing: 1.5em,
    first-line-indent: (amount: 2em, all: true),
  )
  set list(indent: 2em)
  set enum(indent: 2em)
  set terms(indent: 2em)
  
  show emph: it => {
  show regex("[\p{Unified_Ideograph}\p{Punctuation}]"): char   => {
      box(skew(ax: -12deg, char))
    }
    it
  }
  show figure.where(
    kind: table
  ): set figure.caption(position: top)
  body
}

#let opinion-page(
  supervisor-comment: [],
  school-comment: [],
  result: none,
) = {
  colbreak()
  grid(
    columns: (100%),
    rows: (3fr, 2fr),
    stroke: none,
    gutter: 0pt,
    [
      #set align(top)
      #text(par(first-line-indent: 0pt)[指导教师意见（课题难度是否适中、工作量是否饱满、进度安排是否合理、工作条件是否具备、是否同意开题等）：]) 
      #v(0.5em)
      
      #supervisor-comment

      #align(bottom + right)[
        #v(1em)
        指导教师签名：
        #box(width: 5cm, stroke: (bottom: 0.5pt), inset: (bottom: 3pt), baseline: 3pt)[] \
        #v(0.8em)
        年#h(1cm)月#h(1cm)日
        #v(1em)
      ]
    ],
    [
      #place(top + left, dx: -0.3cm)[
        #line(length: 100% + 0.6cm, stroke: 0.5pt)
      ]
      #set align(top)
      #v(1em)
      #text(par(first-line-indent: 0pt)[学院（系）意见：])
      #v(0.5em)
      
      #school-comment

      #align(bottom)[
        #par(first-line-indent: 2em)[
          审 查 结 果： 
          #{if result == "agree" [#mychecked 同 意] else [#myunchecked 同 意]} 
          #h(3em) 
          #{if result == "disagree" [#mychecked 不 同 意] else [#myunchecked 不 同 意]}
        ]
        #align(right)[
          #v(0.8em)
          学院（系）负责人签名：
          #box(width: 5cm, stroke: (bottom: 0.5pt), inset: (bottom: 3pt), baseline: 3pt)[] \
          #v(0.8em)
          #h(2em) 年#h(1cm)月#h(1cm)日
          #v(0.5em)
        ]
      ]
    ]
  )
}