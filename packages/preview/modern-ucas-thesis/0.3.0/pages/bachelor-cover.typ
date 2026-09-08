#import "../utils/datetime-display.typ": datetime-display
#import "../utils/style.typ": get-fonts, 字号
#import "../utils/supervisor.typ": normalize-supervisors

// 本科生封面
#let bachelor-cover(
  // documentclass 传入的参数
  anonymous: false,
  twoside: false,
  fontset: "mac",
  fonts: (:),
  info: (:),
  // 其他参数
  stroke-width: 0.5pt,
  min-title-lines: 2,
  info-inset: (x: 0pt, bottom: 1pt),
  info-key-width: 72pt,
  info-key-font: "楷体",
  info-value-font: "楷体",
  column-gutter: -3pt,
  row-gutter: 11.5pt,
  anonymous-info-keys: (
    "grade",
    "student-id",
    "author",
    "supervisors",
  ),
  bold-info-keys: ("title",),
  bold-level: "bold",
  datetime-display: datetime-display,
) = {
  // 1.  默认参数
  fonts = get-fonts(fontset) + fonts
  info = (
    (
      title: ("基于 Typst 的", "中国科学院大学学位论文"),
      grade: "20XX",
      student-id: "1234567890",
      author: "张三",
      department: "某学院",
      major: "某专业",
      supervisors: (
        (name: "李四", title: "教授", affiliation: ""),
      ),
      submit-date: datetime.today(),
    )
      + info
  )

  // 2.  对参数进行处理
  // 2.1 如果是字符串，则使用换行符将标题分隔为列表
  if type(info.title) == str {
    info.title = info.title.split("\n")
  }
  // 2.2 导师信息归一化为字典列表 (name:, title:, affiliation:)
  info.supervisors = normalize-supervisors(info.supervisors)
  // 2.3 根据 min-title-lines 填充标题
  info.title = (
    info.title + range(min-title-lines - info.title.len()).map(it => "　")
  )
  // 2.3 处理提交日期
  if type(info.submit-date) == datetime {
    info.submit-date = datetime-display(info.submit-date)
  }

  // 3.  内置辅助函数
  let info-key(body) = {
    rect(
      width: 100%,
      inset: info-inset,
      stroke: none,
      text(
        font: fonts.at(info-key-font, default: "楷体"),
        size: 字号.三号,
        body,
      ),
    )
  }

  let info-value(key, body) = {
    set align(center)
    rect(
      width: 100%,
      inset: info-inset,
      stroke: (bottom: stroke-width + black),
      text(
        font: fonts.at(info-value-font, default: "宋体"),
        size: 字号.三号,
        weight: if (key in bold-info-keys) { bold-level } else { "regular" },
        bottom-edge: "descender",
        body,
      ),
    )
  }

  let info-long-value(key, body) = {
    grid.cell(
      colspan: 3,
      info-value(
        key,
        if anonymous and (key in anonymous-info-keys) {
          "██████████"
        } else {
          body
        },
      ),
    )
  }

  let info-short-value(key, body) = {
    info-value(
      key,
      if anonymous and (key in anonymous-info-keys) {
        "█████"
      } else {
        body
      },
    )
  }

  // 4.  正式渲染（封面段单面：不强制奇偶页，连续分页）
  pagebreak(weak: true)

  // 居中对齐
  set align(center)

  // 封面标识：Universe 发布包不含校徽文件（版权归学校所有），此处保留等高占位以维持版式；
  // 用户自行添加时，将下行改为 image("path/to/logo.svg", width: 2.38cm) 即可。
  if anonymous {
    v(52pt)
  } else {
    v(6pt)
    v(2.38cm)
    v(22pt)
    v(2pt)
  }

  // 将中文之间的空格间隙从 0.25 em 调整到 0.5 em
  text(
    size: 字号.一号,
    font: fonts.宋体,
    spacing: 200%,
    weight: "bold",
  )[本 科 毕 业 论 文]

  if anonymous {
    v(155pt)
  } else {
    v(67pt)
  }

  block(width: 318pt, grid(
    columns: (info-key-width, 1fr, info-key-width, 1fr),
    column-gutter: column-gutter,
    row-gutter: row-gutter,
    info-key("院　　系"),
    info-long-value("department", info.department),
    info-key("专　　业"),
    info-long-value("major", info.major),
    info-key("题　　目"),
    ..info
      .title
      .map(s => info-long-value("title", s))
      .intersperse(info-key("　")),
    info-key("年　　级"),
    info-short-value("grade", info.grade),
    info-key("学　　号"),
    info-short-value("student-id", info.student-id),
    info-key("学生姓名"),
    info-long-value("author", info.author),
    // 导师：每位占两栏（指导教师|姓名 + 职称栏|职称值），多导师依次列出，
    // 第一导师用"指导教师"，其后用"第二导师"。本科生规范不设工作单位栏，
    // 故只取 name/title（affiliation 留作研究生封面使用）。
    ..info
      .supervisors
      .enumerate()
      .map(((i, sup)) => {
        let label = if i == 0 { "指导教师" } else { "第二导师" }
        (
          info-key(label),
          info-short-value("supervisors", sup.at("name", default: "")),
          info-key("职　　称"),
          info-short-value("supervisors", sup.at("title", default: "")),
        )
      })
      .flatten(),
    info-key("提交日期"),
    info-long-value("submit-date", info.submit-date),
  ))
}
