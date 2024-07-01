#import "/utils/datetime-display.typ": datetime-display
#import "/utils/style.typ": 字号, 字体

// 扉页
// 内容包括论文中英文题目、学生姓名、学号、院系、专业、指导教师（姓名及职称）等信息。
#let titlepage(
  info: (:),
  // 其他参数
  stoke-width: 0.5pt,
  min-title-lines: 2,
  info-inset: (x: 0pt, bottom: 1pt),
  info-key-width: 72pt,
  info-key-font: "黑体",
  info-value-font: "宋体",
  column-gutter: -3pt,
  row-gutter: 11.5pt,
) = {
  assert(type(info.title) == array)
  assert(type(info.author) == dictionary)

  info.title = info.title + range(min-title-lines - info.title.len()).map((it) => "　")
  if type(info.submit-date) == datetime {
    info.submit-date = datetime-display(info.submit-date)
  }

  // 内置辅助函数
  let info-key(
    font: 字体.at(info-key-font, default: "黑体"),
    size: 字号.三号,
    body,
  ) = {
    rect(
      width: 100%,
      inset: info-inset,
      stroke: none,
      text(
        font: font,
        size: size,
        body,
      ),
    )
  }

  let info-value(
    font: 字体.at(info-value-font, default: "宋体"),
    size: 字号.三号,
    key,
    body,
  ) = {
    set align(center)
    rect(
      width: 100%,
      inset: info-inset,
      stroke: (bottom: stoke-width + black),
      text(
        font: font,
        size: size,
        bottom-edge: "descender",
        body,
      ),
    )
  }

  let info-long-value(
    font: 字体.at(info-value-font, default: "宋体"),
    size: 字号.三号,
    key,
    body,
  ) = {
    grid.cell(colspan: 3,
      info-value(
        font: font,
        size: size,
        key,
        body,
      )
    )
  }

  let info-short-value(
    font: 字体.at(info-value-font, default: "宋体"),
    size: 字号.三号,
    key,
    body
  ) = {
    info-value(
      font: font,
      size: size,
      key,
      body,
    )
  }

  // 正式渲染
  v(30pt)

  set align(center + horizon)
  for part in info.title {
    text(size: 字号.二号, font: 字体.黑体, weight: "bold")[ #part ]
    linebreak()
  }
  v(2em)
  for part-en in info.title-en {
    text(size: 字号.二号, weight: "bold")[ #part-en ]
    linebreak()
  }

  // 学生与指导老师信息
  set align(center + bottom)
  block(width: 75%, grid(
    columns: (info-key-width, 1fr, info-key-width, 1fr),
    column-gutter: column-gutter,
    row-gutter: row-gutter,
    info-key("姓　　名"),
    info-long-value("author", info.author.name),
    info-key("学　　号"),
    info-long-value("student-id", info.author.sno),
    info-key("院　　系"),
    info-long-value("department", info.author.department),
    info-key("专　　业"),
    info-long-value("major", info.author.major),
    info-key("指导教师"),
    info-long-value("supervisor", info.supervisor.join(" ")),
  ))
  v(2em)

  text(font: 字体.黑体, size: 字号.四号)[#info.submit-date]
}
