#let note(
  title: "",
  author: "",
  abstract: "",
  createtime: "",
  body,
  bibliography-file: none,
  // paper-size: "a4",
) = {
  set text(lang: "zh", region: "cn")


  //文档属性
  set document(
    author: author,
    date: auto,
    title: title,
  )



  // 标题和大纲
  set heading(numbering: "1.")
  show heading: it => {
    set text(font: "Times New Roman")
    set par(first-line-indent: 0em)

    if it.numbering != none {
      text(rgb("#2196F3"), weight: 500)[#sym.section]

      text(rgb("#2196F3"))[#counter(heading).display() ]
    }
    it.body
    v(0.6em)
  }

  set outline(fill: repeat[~.], indent: 1em)

  show outline: set heading(numbering: none)
  show outline: set par(first-line-indent: 0em)

  show outline.entry.where(level: 1): it => {
    text(font: "Times New Roman", rgb("#2196F3"))[#strong[#it]]
  }
  show outline.entry: it => {
    h(1em)
    text(font: "Times New Roman", rgb("#2196F3"))[#it]
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
      let elems = query(heading.where(level: 1).before(loc))
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



  // codeblock
  show raw.where(block: true): block.with(
    fill: luma(87.45%),   // 设置背景颜色
    inset: 7pt,         // 设置内边距
    radius: 2pt,         // 设置圆角半径
    width: 100%,         // 设置宽度为 100%
  )
  //inlinecode
  show raw.where(block: false): box.with(
    fill: luma(87.45%),   // 设置背景颜色
    inset: 2pt, // 设置内边距
    outset: (y: 1.5pt),   // 设置上下的外边距
    radius: 2pt,        // 设置圆角半径
  )

  show raw: set text(font: "jetbrains mono") //修改代码字体



  //链接下划线
  show link: {
    underline.with(stroke: blue, offset: 2pt)
  }

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
    // size: 12pt,
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
    set text(font: ("Libertinus Serif", "KaiTi")) //设置参考文献字体
    pagebreak()
    show bibliography: set text(10.5pt)
    bibliography(bibliography-file, title: "参考文献", style: "gb-7714-2015-numeric")
  }

}

// 绿色强调框
#let prob(body) = {
  block(
    fill: rgb(250, 255, 250),
    width: 100%,
    inset: 8pt,
    radius: 4pt,
    stroke: rgb(31, 199, 31),
    body,
  )
}
