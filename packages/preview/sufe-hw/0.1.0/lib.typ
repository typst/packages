// 上海财经大学课程作业模板。
// 用户导入 @preview/sufe-hw，项目文件由 typst init 复制生成。

// 随模板导出的常用包：
// - physica：数学、物理符号与微分、向量、矩阵等工具
// - CeTZ：绘图
// - Codly + Codly Languages：代码块样式与语言图标

#import "@preview/physica:0.9.8"
#import "@preview/cetz:0.5.3"
#import "@preview/codly:2.0.0"
#import "@preview/codly-languages:0.1.10"

#let homework(
  student-name: "张三",
  student-id: "2024000000",
  course-name: "课程名称",
  course-code: "课程代码",
  course-section: "课程序号",
  assignment-date: datetime.today().display("[year]年[month]月[day]日"),
  assignment-title: "课程作业",
  body,
) = {
  set document(
    title: assignment-title,
    author: student-name,
  )
  set page(
    paper: "a4",
    margin: (x: 2.5cm, y: 2.4cm),
    footer: context align(center, text(
      size: 9pt,
      fill: luma(100),
      [第 #counter(page).display() 页],
    )),
  )
  set text(
    font: ("Noto Sans SC", "Source Han Sans SC", "PingFang SC", "Microsoft YaHei"),
    size: 11pt,
    lang: "zh",
  )
  set par(justify: true, leading: 0.75em)
  set heading(numbering: "1.")

  show: codly.lang-set_(languages: codly-languages.codly-languages)
  show raw.where(block: true): codly.new

  block(above: 0pt, below: 8pt)[
    #set par(leading: 1.2em)
    #set text(size: 34pt, weight: "bold")
    #course-name
  ]
  block(above: 0pt, below: 10pt)[
    #set par(leading: 1.2em)
    #set text(size: 13pt, fill: luma(110))
    #assignment-title
  ]
  line(length: 100%, stroke: 1pt + luma(130))
  v(1em)
  block(above: 0pt, below: 2em)[
    #let fields = (
      ("姓名", student-name),
      ("学号", student-id),
      ("课程代码", course-code),
      ("课程序号", course-section),
      ("日期", assignment-date),
    )

    #grid(
      columns: (1fr, 1fr, 1fr, 1fr, 1fr),
      column-gutter: 1em,
      row-gutter: 0.5em,
      ..fields.map(f => text(size: 8pt, fill: luma(80))[#f.at(0)]),
      ..fields.map(f => text(size: 10pt)[#f.at(1)]),
    )
  ]

  body
}
