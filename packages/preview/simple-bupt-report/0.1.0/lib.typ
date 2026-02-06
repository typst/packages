#let experiment-report(
  title: "",
  semester: "",
  name: "",
  student-id: "",
  class: "",
  date: "",
  body
) = {
  // 设置页面格式
  set page(
    paper: "a4",
    margin: (top: 2.54cm, bottom: 2.54cm, left: 3.18cm, right: 3.18cm),
  )
  set text(lang: "zh")
  import "@preview/cuti:0.3.0": show-cn-fakebold
  show: show-cn-fakebold
  // 封面页
  show figure.caption: it => {
    set text(font: ("Times New Roman", "FangSong"), size: 9pt)
    it
  }
  align(center)[
    #v(4em)
    // 第一行：学年学期
    #text(size: 22pt,font: "STZhongsong",weight: "bold")[#semester]

    // 第二行：实验报告标题
    #text(size: 22pt,font:"STZhongsong",weight: "bold")[#title]
    #v(4.5em)
    
    // Logo
    #image("assets/bupt-logo.jpg", width: 40%)
    #v(8em)
    
   // 学生信息表格
    #let info-row(label, content) = {
      grid(
        columns: (auto, auto),
        align(right)[#text(font: "STSong",size: 14pt)[#label]],
        [
          #box(width: 180pt)[
            #set text(font: "STSong",size: 14pt)
            #box(width: 180pt)[
              #place(dx: 0pt, dy: 14pt)[#line(length: 180pt)]
              #align(center)[#content]
            ]
          ]
        ]
      )
    }
    
    #set text(font: "STSong", size: 14pt)
    #grid(
      align: center,
      rows: 4,
      row-gutter: 2em,
      info-row("专业班级", class),
      info-row("姓　　名", name),
      info-row("学　　号", student-id),
      info-row("报告日期", date)
    )
  ]
  pagebreak()

    show heading.where(level: 1): it => [
    #set par(first-line-indent: 0em)
    #set align(center)
    #set text(font: ("Times New Roman", "SimHei"), size: 16pt, weight: "bold")
    #v(12pt)
    #it.body
    #v(20pt)
  ]

    show heading.where(level: 2): it => [
    #set align(left)
    #set par(first-line-indent: 0em)
    #set text(font: ("Times New Roman", "SimHei"), size: 14pt, weight: "bold") // 四号字
    #counter(heading.where(level: 2)).step()
    #counter(heading.where(level: 3)).update(0)
    #let num = counter(heading.where(level: 2)).get().at(0) + 1
    #numbering("一、",num)
    #it.body
  ]

    show heading.where(level: 3): it => [
    #set align(left)
    #set par(first-line-indent: 2em)
    #set text(font: ("Times New Roman", "SimHei"), size: 12pt, weight: "bold") //小四号字
    #counter(heading.where(level: 3)).step()
    #let two_head = counter(heading.where(level: 2)).get().at(0)
    #let num = counter(heading.where(level: 3)).get().at(0) + 1
    #numbering("1.1",two_head,num)
    #it.body
  ]
  // show heading: it => {
  //   // 重置段落缩进，确保标题后的第一段不缩进
  //   par(first-line-indent: 0em)[#it.body]
  // }
  set text(font: ("Times New Roman", "SimHei"), size: 12pt, weight: "regular")
  set par(first-line-indent: 2em,leading: 1.2em)
  show raw.where(block: true): block => [
    #pad(left: 2.5em)[
      #block
    ]
  ]
  body
}