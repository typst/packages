#import "../utils/datetime-display.typ": datetime-display
#import "../utils/style.typ": 字号, 字体

// 本科生论文扉页
#let bachelor-title-page(
  // documentclass 传入的参数
  twoside: false,
  fonts: (:),
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
  // 1.  默认参数
  fonts = 字体 + fonts
  info = (
    title: ("基于 Typst 的", "中山大学学位论文模板"),
    title-en: "A Typst Template for SYSU thesis",
    grade: "20XX",
    student-id: "1234567890",
    author: "张三",
    department: "某学院",
    major: "某专业",
    supervisor: ("李四", "教授"),
    submit-date: datetime.today(),
  ) + info

  // 2.  对参数进行处理
  // 2.1 如果是字符串，则使用换行符将标题分隔为列表
  if type(info.title) == str {
    info.title = info.title.split("\n")
  }
  if type(info.title-en) == str {
    info.title-en = info.title-en.split("\n")
  }
  // 2.2 根据 min-title-lines 填充标题
  info.title = info.title + range(min-title-lines - info.title.len()).map((it) => "　")
  // 2.3 处理提交日期
  if type(info.submit-date) == datetime {
    info.submit-date = datetime-display(info.submit-date)
  }

  // 3.  内置辅助函数
  let info-key(
    font: fonts.at(info-key-font, default: "黑体"),
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
    font: fonts.at(info-value-font, default: "宋体"),
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
    font: fonts.at(info-value-font, default: "宋体"),
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
    font: fonts.at(info-value-font, default: "宋体"),
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

  // 4. 正式渲染
  pagebreak(weak: true, to: if twoside { "odd" })
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
    info-long-value("author", info.author),
    info-key("学　　号"),
    info-long-value("student-id", info.student-id),
    info-key("院　　系"),
    info-long-value("department", info.department),
    info-key("专　　业"),
    info-long-value("major", info.major),
    info-key("指导教师"),
    info-long-value("supervisor", text[ #info.supervisor.at(0) #info.supervisor.at(1) ]),
    // info-short-value("supervisor", info.supervisor.at(0)),
    // info-key("职　　称"),
    // info-short-value("supervisor", info.supervisor.at(1)),
    ..(if info.supervisor-ii != () {(
      info-key("第二导师"),
      info-long-value("supervisor", text[ #info.supervisor-ii.at(0) #info.supervisor-ii.at(1) ]),
    )} else {()}),
  ))
  v(2em)

  text(font: 字体.黑体, size: 字号.四号)[#info.submit-date]
}
