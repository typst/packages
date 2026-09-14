#import "../utils/datetime-display.typ": datetime-display
#import "../utils/font.typ": font-size

// 本科生封面
#let cover(
  // documentclass 传入的参数
  anonymous: false,
  fonts: (:),
  info: (:),
  // 其他参数
  stoke-width: 0.5pt,
  min-title-lines: 2,
  info-inset: (x: 0pt, bottom: 1pt),
  info-key-width: 72pt,
  info-key-font: "FangSong",
  info-value-font: "FangSong",
  column-gutter: -3pt,
  row-gutter: 11.5pt,
  anonymous-info-keys: ("author", "supervisor", "supervisor-ii"),
  bold-info-keys: ("title",),
  bold-level: "bold",
  datetime-display: datetime-display,
) = {
  // 1.  默认参数
  info = (
    (
      title: ("基于 Typst 的", "清华大学学位论文"),
      author: "张三",
      department: "某学院",
      major: "某专业",
      supervisor: ("李四", "教授"),
      submit-date: datetime.today(),
    )
      + info
  )

  // 2.  对参数进行处理
  // 2.1 如果是字符串，则使用换行符将标题分隔为列表
  if type(info.title) == str {
    info.title = info.title.split("\n")
  }
  // 2.2 根据 min-title-lines 填充标题
  info.title = info.title + range(min-title-lines - info.title.len()).map(it => "　")
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
        font: fonts.at(info-key-font, default: "KaiTi"),
        size: font-size.三号,
        body,
      ),
    )
  }

  let info-value(key, body) = {
    set align(center)
    rect(
      width: 100%,
      inset: info-inset,
      stroke: (bottom: stoke-width + black),
      text(
        font: fonts.at(info-value-font, default: "SongTi"),
        size: font-size.三号,
        weight: if key in bold-info-keys { bold-level } else { "regular" },
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


  // 4.  正式渲染
  // 居中对齐
  set align(center)

  // 匿名化处理去掉封面标识
  if anonymous {
    v(6cm)
  } else {
    image("../assets/logo.jpg", width: 20cm)
  }

  // 将中文之间的空格间隙从 0.25 em 调整到 0.5 em
  text(size: font-size.一号, font: fonts.HeiTi, spacing: 200%)[综 合 论 文 训 练]

  if anonymous { v(155pt) } else { v(67pt) }

  block(
    width: 318pt,
    grid(
      columns: (info-key-width, 1fr, info-key-width, 1fr),
      column-gutter: column-gutter,
      row-gutter: row-gutter,
      info-key("系　　别"),
      info-long-value("department", info.department),
      info-key("专　　业"),
      info-long-value("major", info.major),
      info-key("题　　目"),
      ..info.title.map(s => info-long-value("title", s)).intersperse(info-key("　")),
      info-key("姓　　名"),
      info-long-value("author", info.author),
      info-key("指导教师"),
      info-short-value("supervisor", info.supervisor.at(0)),
      info-key("职　　称"),
      info-short-value("supervisor", info.supervisor.at(1)),
      ..(
        if info.supervisor-ii != () {
          (
            info-key("第二导师"),
            info-short-value("supervisor-ii", info.supervisor-ii.at(0)),
            info-key("职　　称"),
            info-short-value("supervisor-ii", info.supervisor-ii.at(1)),
          )
        } else { () }
      ),
      info-key("提交日期"),
      info-long-value("submit-date", info.submit-date),
    ),
  )
}
