// xyznote v0.2.0
// by wrdenxyz https://github.com/wardenxyz
// 2024-12-3

#let xyznote(
  title: "",
  author: "",
  abstract: "",
  createtime: "",
  lang: "zh",
  bibliography-style: "ieee",
  body,
  bibliography-file: none,
) = {
  set text(lang: lang)

  set document(
    author: author,
    date: auto,
    title: title,
  )

  //标题计数器
  let chaptercounter = counter("chapter")

  // 标题和大纲
  set heading(numbering: "1.1.1.1.1.")
  show heading: it => [
    #set text(font: ("libertinus serif", "kaiti"))
    #if it.numbering != none {
      text(rgb("#2196F3"), weight: 500)[#sym.section]
      h(0.5em)
      text(rgb("#2196F3"))[#counter(heading).display() ]
    }
    #it.body
    #v(0.1em)
    #if it.level == 1 and it.numbering != none {
      chaptercounter.step()
      counter(math.equation).update(0)
    }
  ]

  // 大纲配置
  set outline(fill: repeat[~.], indent: 1em)

  show outline: set heading(numbering: none)
  show outline: set par(first-line-indent: 0em)

  show outline.entry.where(level: 1): it => {
    text(font: "libertinus serif", rgb("#2196F3"))[#strong[#it]]
  }
  show outline.entry: it => {
    h(1em)
    text(font: "libertinus serif", rgb("#2196F3"))[#it]
  }



  //封面
  set page(margin: (
    top: 7cm,
    bottom: 4cm,
    left: 2cm,
  ))

  polygon(
  fill: rgb("#bb4e4d"),
  (0cm, -7cm), // 左上角开始顺时针第一个点 x y 左负右正 上负下正
  (1.8cm, -7cm), // 左上角开始顺时针第二个点
  (1.8cm, -4cm), // 左上角开始顺时针第三个点
  (0.9cm, -4.9cm), // 左上角开始顺时针第四个点 (上下两个数的中点, 绝对值要比上下两个大)
  (0cm, -4cm), // 左上角开始顺时针第五个点
)


  align(right)[
    #set text(font: ("Times New Roman", "NSimSun"))
    #block(text(weight: 700, 30pt, title))
    #line(length: 100%, stroke: 3pt) //封面横线
    #v(1em, weak: true)
  ]

  align(right)[
    #set text(font: ("Libertinus Serif", "NSimSun"), size: 12pt)
    #abstract
  ]

  align(bottom + center)[
    #set text(size: 15pt)
    *#author*
  ]

  align(bottom + center)[
    #set text(size: 15pt)
    *#createtime*
  ]



  //页眉
  set page(header: context {
    set text(font: ("Libertinus Serif", "NSimSun"))
    if here().page() == 1 {
      return
    }

    let elems = query(heading.where(level: 1).after(here()))

    let chapter-title = ""

    if (elems == () or elems.first().location().page() != here().page()) {
      let elems = query(heading.where(level: 1).before(here()))
      chapter-title = elems.last().body
    } else {
      chapter-title = elems.first().body
    }
    align(right)[#chapter-title]

    v(-8pt)
    align(center)[#line(length: 105%, stroke: (thickness: 1pt, dash: "solid"))]
  })

  //引用块
  set quote(block: true)

  //inlinecode
  show raw.where(block: false): it => box(fill: rgb("#d7d7d7"), inset: (x: 2pt), outset: (y: 3pt), radius: 1pt)[#it]

  show table.cell.where(y: 0): strong //表格表头加粗

  //链接下划线
  show link: {
    underline.with(stroke: blue, offset: 2pt)
  }

  //外部包
  import "@preview/codly:1.0.0": *
  import "@preview/codly-languages:0.1.1": *
  show: codly-init //初始化 codly
  // codly(number-format: none) //不显示行号
  codly(languages: codly-languages) //设置语言图标


  //公式编号
  set math.equation(numbering: (..nums) => (
    context {
      set text(size: 9pt)
      numbering("(1.1)", chaptercounter.at(here()).first(), ..nums)
    }
  ))

  // caption 计数器
  set figure(numbering: (..nums) => (
    context {
      set text(font: ("Libertinus Serif", "KaiTi"), size: 9pt)
      numbering("1.1", chaptercounter.at(here()).first(), ..nums)
    }
  ))

  //图片表格 caption 字体字号
  show figure.caption: set text(font: ("Libertinus Serif", "KaiTi"), size: 9pt)

  // ------------------------ 以下为正文配置 ---------------------------------- //

  //正文页边距
  set page(margin: (
    top: 2cm,
    bottom: 2cm,
    right: 2cm,
    left: 2cm,
  ))

  //正文字体字号
  set text(
    font: ("Libertinus Serif", "microsoft yahei"),
    // size: 11pt,
  )

  // set text(tracking: 1pt) //字间距
  // set par(leading: 1pt) //行间距

  //段落缩进
  // set par(
  //   justify: true,
  //   first-line-indent: 1em,
  // )

  pagebreak()

  outline()

  pagebreak()

  //页码
  set page(
    numbering: "1 / 1",
    number-align: right,
  )
  counter(page).update(1)

  body

  //参考文献
  if bibliography-file != none {
    pagebreak()
    set text(font: ("Times New Roman", "KaiTi")) //设置参考文献字体
    show bibliography: set text(10.5pt)
    set bibliography(style: bibliography-style)
    bibliography-file
  }
}

// ---- 自定义组件 ----

// Green mark box
#let markbox(body) = {
  block(
    fill: rgb(250, 255, 250),
    width: 100%,
    inset: 8pt,
    radius: 4pt,
    stroke: rgb(31, 199, 31),
    body,
  )
}

// Blue tip box
#let tipbox(cite: none, body) = [
  #set text(size: 10.5pt)
  #pad(left: 0.5em)[
    #block(
      breakable: true,
      width: 100%,
      fill: rgb("#d0f2fe"),
      radius: (left: 1pt),
      stroke: (left: 4pt + rgb("#5da1ed")),
      inset: 1em,
    )[#body]
  ]
]

#let sectionline = [
  #set align(center)
  #v(0.5cm) // 分割线上边距
  #line(
    length: 80%,
    stroke: (paint: rgb("#767676"), thickness: 1.2pt, dash: ("dot", 5pt, 10pt, 5pt)),
  )
  #v(0.5cm) //分割线下边距
]
