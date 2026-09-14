#import "@preview/lovelace:0.3.0"
#let pseudocode = lovelace.pseudocode
#let pseudocode-list = lovelace.pseudocode-list
#let report(
  logo: image("assets/HUSTGreen.svg", width: 55%),
  type: "课程实验报告",
  course-name: "人工智能",
  title: none,
  class-name: "CS2410",
  student-id: "U2024XXXXX",
  name: "张三",
  instructor: "李四",
  date: datetime.today().display("[year]年[month]月[day]日"),
  school: "计算机科学与技术学院",
  header-text: "华中科技大学课程实验报告",
  bibliography-file: none, //不需要则传none
  appendix: none, //不需要则传none
  doc,
) = {
  let is-appendix = state("is-appendix", false)
  //字体全局设置
  set text(
    font: ("Times New Roman", "SimSun"),
    size: 12pt,
    lang: "zh",
  )

  //实现中文 fake-bold
  show strong: it => {
    set text(weight: "bold")
    show regex("\p{sc=Han}"): set text(stroke: 0.0285em)
    it.body
  }
  //中文斜体用楷体替代
  show emph: it => {
    show regex("\p{sc=Han}"): set text(font: "KaiTi")
    it.body
  }

  //列表缩进
  set list(indent: 2em)
  set enum(indent: 2em)

  //标题设置
  set heading(numbering: "1.1")

  show heading: it => {
    set text(
      font: ("Times New Roman", "SimHei"),
      weight: "regular",
    )
    if it.level == 1 {
      counter(figure.where(kind: image)).update(0)
      counter(figure.where(kind: table)).update(0)
      counter(figure.where(kind: "algorithm")).update(0)
      counter(math.equation).update(0)
      set text(size: 18pt, stroke: 0.01em)
      set block(above: 1.2em, below: 1em)
      it
    } else if it.level == 2 {
      set text(size: 15pt, stroke: 0.01em)
      set block(above: 1.2em, below: 1em)
      it
    } else {
      set text(size: 12pt, stroke: 0.01em)
      set block(above: 1.2em, below: 1em)
      it
    }
  }

  //代码块/行内代码设置
  show raw: set text(
    font: ("JetBrains Mono", "Consolas", "SimHei"),
    size: 10.5pt,
  )
  show raw.where(block: true): it => {
    set par(leading: 0.5em)
    block(
      fill: luma(245),
      inset: 10pt,
      radius: 4pt,
      width: 100%,
      it,
    )
  }

  //伪代码格式设置


  //图表格式设置
  set figure(numbering: num => context {
    let chapter = counter(heading).get().first()
    if chapter == 0 {
      numbering("1", num)
    } else {
      let in-appendix = is-appendix.get()
      if in-appendix {
        numbering("A1", chapter, num)
      } else {
        numbering("1-1", chapter, num)
      }
    }
  })

  show figure.caption: it => {
    set text(size: 10.5pt)
    text(font: "SimHei", stroke: 0.01em)[#it.supplement #context it.counter.display()]
    "  "
    text(font: ("Times New Roman", "KaiTi"))[#it.body]
  }

  //公式自动编号
  set math.equation(numbering: num => context {
    let chapter = counter(heading).get().first()
    let in-appendix = is-appendix.get()

    if in-appendix {
      numbering("(A.1)", chapter, num)
    } else {
      numbering("(1.1)", chapter, num)
    }
  })


  //段落格式设置
  set par(
    first-line-indent: (amount: 2em, all: true),
    leading: 1.5em,
    justify: true,
  )

  //页眉页脚定义
  let my-header = context {
    set align(center)
    text(size: 16pt, font: "KaiTi", fill: rgb(180, 0, 0), tracking: 0.5em)[#header-text]
    v(-0.65em)
    stack(
      spacing: 0.13em,
      line(length: 100%, stroke: 0.72pt + rgb("#8BB9E6")),
      line(length: 100%, stroke: 0.72pt + rgb("#8BB9E6")),
    )
  }

  let my-footer = context {
    let page-num = counter(page).display()
    set align(center)
    set text(size: 10.5pt)
    grid(
      columns: (1fr, auto, 1fr),
      gutter: 1em,
      align: horizon,
      line(length: 100%, stroke: 0.5pt + black), page-num, line(length: 100%, stroke: 0.5pt + black),
    )
  }

  //页面设置-封面
  set page(
    paper: "a4",
    margin: (top: 2.5cm, bottom: 2.5cm, right: 3cm, left: 3cm),
    //页眉
    header: none,
    //页脚
    footer: none,
  )

  let info-line(key, value, size) = {
    set text(size: size)
    set align(center)
    block(width: 70%)[
      #grid(
        columns: (3fr, 7fr),
        gutter: 0.5em,
        align(right + horizon)[
          #text(font: "Fangsong", stroke: black + 0.05em)[#key]
        ],
        align(horizon + center)[
          #box(width: 100%, stroke: (bottom: 0.05em), inset: 4pt)[
            #text(font: ("Times New Roman", "SimSun"))[#value]
          ]
        ],
      )
    ]
  }

  let info-line-title(key, value, size) = {
    set text(size: size)
    set align(center)
    block(width: 100%)[
      #grid(
        columns: (3fr, 7fr),
        gutter: 1em,
        align(right + horizon)[
          #text(font: ("Times New Roman", "SimHei"), stroke: black + 0.05em)[#key:]
        ],
        align(horizon + center)[
          #box(width: 100%, stroke: (bottom: 0.05em), inset: 4pt)[
            #text(font: ("Times New Roman", "SimSun"), stroke: black + 0.03em)[#value]
          ]
        ],
      )
    ]
  }

  //封面
  v(4fr)
  align(center)[
    #if logo == none {
      image("assets/HUSTGreen.svg", width: 55%)
    } else {
      logo
    }

    #v(1.8em, weak: true)
    #text(size: 38pt, font: "Fangsong", weight: "bold", tracking: 0.2em, stroke: black + 0.04em)[#type]
  ]

  v(3fr)
  align(center)[
    #if course-name != none {
      info-line-title(course-name.at(0), course-name.at(1), 22pt)
    }
    #if title != none {
      info-line-title(title.at(0), title.at(1), 22pt)
    }
  ]

  v(5fr)
  align(center)[
    #info-line([专业班级], class-name, 17pt)
    #info-line([学#h(2em)号], student-id, 17pt)
    #info-line([姓#h(2em)名], name, 17pt)
    #info-line([指导教师], instructor, 17pt)
    #info-line([日#h(2em)期], date, 17pt)
  ]
  v(2fr)
  align(center)[#text(size: 17pt, font: "Fangsong", stroke: black + 0.05em)[#school]]
  v(2fr)

  pagebreak()

  //目录
  set page(numbering: "I", header: my-header, footer: my-footer)
  counter(page).update(1)

  show outline.entry: it => {
    if it.level == 1 {
      set text(size: 14pt, font: ("Times New Roman", "SimHei"), weight: "bold")
      it
    } else {
      set text(font: ("Times New Roman", "SimSun"))
      it
    }
  }

  show outline: set align(center)
  outline(title: [#text(size: 18pt, font: "SimHei", weight: "bold")[目#h(2em)录]], indent: 2em, depth: 2)


  pagebreak()
  //正文
  set page(numbering: "1")
  counter(page).update(1)
  doc

  //参考文献
  if bibliography-file != none {
    pagebreak()
    set bibliography(title: "参考文献", style: "gb-7714-2015-numeric")
    bibliography-file
  }

  //附录
  if appendix != none {
    is-appendix.update(true)
    pagebreak()
    counter(heading).update(0)
    set heading(numbering: (..nums) => {
      let vals = nums.pos()
      if vals.len() == 1 {
        return "附录 " + numbering("A", vals.last())
      } else {
        return numbering("A.1", ..vals)
      }
    })

    appendix
  }
}

