#let generate-cover(title, semester, class, name, student-id, date) = {
  // 封面页
  align(center)[
    #v(4em)
    // 第一行：学年学期
    #text(size: 22pt, font: "STZhongsong", weight: "bold")[#semester]

    // 第二行：实验报告标题
    #text(size: 22pt, font: "STZhongsong", weight: "bold")[#title]
    #v(4.5em)

    // Logo
    #image("assets/bupt-logo.jpg", width: 40%)
    #v(8em)

    // 学生信息表格
    #let info-row(label, content) = {
      grid(
        columns: (auto, auto),
        align(right)[
          #text(font: "STSong", size: 14pt)[#label]
        ],
        [
          #box(width: 180pt)[
            #box(width: 180pt)[
              #place(dx: 0pt, dy: 14pt)[
                #line(length: 180pt)
              ]
              #align(center)[
                #text(font: "STSong", size: 14pt)[#content]
              ]
            ]
          ]
        ],
      )
    }

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
}
