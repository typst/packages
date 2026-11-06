#import "@preview/pointless-size:0.1.2": zh

#import "/src/fonts.typ": *


#let dist-text(content, width: 4em) = {
  block(width: width, {
    let clusters = content.clusters()
    if clusters.len() == 1 {
      align(center, content)
    } else {
      stack(dir: ltr, spacing: 1fr, ..clusters)
    }
  })
}

#let underline-cell(content, width: 220pt) = {
  box(
    width: width,
    stroke: (bottom: 1pt + black),
    outset: (bottom: 5pt),
    align(center, content),
  )
}

#let info-row(key, value) = {
  (dist-text(key), [：], underline-cell(value))
}

#let cover(
  title: "",
  subtitle: "",
  author: "",
  school: "",
  major: "",
  grade: "",
  student-id: "",
  advisor: "",
  score: "",
  date: "",
  encoding: "",
) = {
  set text(font: pure-heiti, weight: "bold")
  // fakebold不能加粗英文，这里自己设置
  show text.where(weight: "bold"): set text(stroke: 0.0285em)

  align(right)[
    #text(size: 12pt)[论文编码：*#encoding*]   
  ]
  v(-1em)
  align(center)[
    #text(size: 28pt)[中国人民大学本科毕业论文（设计）]
  ]

  v(3em)

  align(center)[
    #text(size: 28pt)[#title]
  ]
  if subtitle != "" {
    align(center)[
      #text(size: 20pt)[——*#subtitle*]
    ]
  }

  v(12em)

  set text(size: 20pt)
  pad(left: 4em)[
    #grid(
      columns: (3.5em, auto, auto),
      row-gutter: 1.2em,
      column-gutter: 0.5em,
      ..info-row("作者", author),
      ..info-row("学院", school),
      ..info-row("专业", major),
      ..info-row("年级", grade),
      ..info-row("学号", student-id),
      ..info-row("指导教师", advisor),
      ..info-row("论文成绩", score),
      ..info-row("日期", date),
    )
  ]
  pagebreak()
}
