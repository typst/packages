#import "../utils/datetime-display.typ": datetime-display
#import "../utils/style.typ": 字号, 字体, sysucolor

// 本科生封面
#let bachelor-cover(
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
  bold-info-keys: ("title",),
  bold-level: "bold",
) = {
  // 1.  默认参数
  fonts = 字体 + fonts
  info = (
    title: ("基于 Typst 的", "中山大学学位论文模板"),
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
  // 2.2 根据 min-title-lines 填充标题
  info.title = info.title + range(min-title-lines - info.title.len()).map((it) => "　")
  // 2.3 处理提交日期
  if type(info.submit-date) == datetime {
    info.submit-date = datetime-display(info.submit-date)
  }

  // 3.  内置辅助函数
  let info-key(
    font: fonts.at(info-key-font, default: "黑体"),
    size: 字号.小三,
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
    size: 字号.小三,
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
        weight: if (key in bold-info-keys) { bold-level } else { "regular" },
        bottom-edge: "descender",
        body,
      ),
    )
  }

  let info-long-value(
    font: fonts.at(info-value-font, default: "宋体"),
    size: 字号.小三,
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
    size: 字号.小三,
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


  // 4.  正式渲染

  pagebreak(weak: true, to: if twoside { "odd" })

  // 居中对齐
  set align(center)

  // 封面校徽
  // 使用校方官方 VI 系统的 logo，来源：https://home3.sysu.edu.cn/sysuvi/index.html
  image("../assets/vi/sysu_logo.svg", width: 3cm)

  text(size: 字号.小初, font: 字体.宋体, weight: "bold", fill: sysucolor.green)[本科生毕业论文（设计）]
  v(-2em)
  line(length: 200%, stroke: 0.12cm + sysucolor.green);
  v(-0.8em)
  line(length: 200%, stroke: 0.05cm + sysucolor.green);
  v(1.5cm)

  // 论文题目
  h(0.7cm)
  block(width: 100%, grid(
    columns: (25%, 1fr, 75%, 1fr),
    column-gutter: column-gutter,
    row-gutter: row-gutter,
    info-key(size: 字号.二号, "题目："),
    ..info.title.map((s) =>
      info-long-value(size: 字号.二号, font: 字体.黑体, "title", s)
    ).intersperse(info-key(size: 字号.二号, "　")),
  ))
  v(2.7cm)

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

  text(font: 字体.黑体, size: 字号.小四)[#info.submit-date]
}
