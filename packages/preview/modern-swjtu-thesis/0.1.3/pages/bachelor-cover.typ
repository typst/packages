#import "../utils/datetime-display.typ": datetime-display
#import "../utils/style.typ": 字号, 字体

// 本科生封面
#let bachelor-cover(
  // documentclass 传入的参数
  anonymous: false,
  twoside: false,
  fonts: (:),
  info: (:),
  // 其他参数
  stroke-width: 0.5pt,
  min-title-lines: 2,
  info-inset: (x: 0pt, bottom: 1pt),
  info-key-width: 72pt,
  info-key-font: "黑体",
  info-value-font: "黑体",
  column-gutter: -3pt,
  row-gutter: 0pt,
  anonymous-info-keys: ("grade", "student-id", "author", "supervisor", "supervisor-ii"),
  bold-info-keys: ("title",),
  bold-level: "bold",
  datetime-display: datetime-display,
) = {
  // 1.  默认参数
  fonts = 字体 + fonts
  info = (
    title: ("（此处为论文题目，黑体 2 号字）"),
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
  let info-key(body) = {
    set align(right)
    rect(
      width: 100%,
      inset: info-inset,
      stroke: none,
      text(
        font: fonts.at(info-key-font, default: "黑体"),
        size: 字号.小四,
        body
      ),
    )
  }

  let info-value(key, body) = {
    set align(center)
    rect(
      width: 100%,
      inset: info-inset,
      stroke: none,
      text(
        font: fonts.at(info-value-font, default: "黑体"),
        size: 字号.小四,
        bottom-edge: "descender",
        body,
      ),
    )
  }

  let info-long-value(key, body) = {
    grid.cell(colspan: 3,
      info-value(
        key,
        if anonymous and (key in anonymous-info-keys) {
          "██████████"
        } else {
          body
        }
      )
    )
  }

  let info-short-value(key, body) = {
    info-value(
      key,
      if anonymous and (key in anonymous-info-keys) {
        "█████"
      } else {
        body
      }
    )
  }
  

  // 4.  正式渲染
  
  pagebreak(weak: true, to: if twoside { "odd" })

  // 居中对齐
  set align(center)

  // 匿名化处理去掉封面标识

  v(51pt)
  // 将中文之间的空格间隙从 0.25 em 调整到 0.5 em
  text(size: 字号.小二, font: fonts.黑体, spacing: 200%)[西 南 交 通 大 学]
  v(0pt)
  text(size: 字号.小二, font: fonts.黑体, spacing: 200%)[本科毕业设计（论文）]
  v(50pt)
  text(
    font: fonts.黑体,
    size: 字号.二号,
    spacing: 150%,
    info.title.filter(s => s != "　").join("")
  )

  v(122pt)

  block(width: 250pt, grid(
    columns: (info-key-width, 1fr, info-key-width, 1fr),
    column-gutter: column-gutter,
    row-gutter: row-gutter,
    info-key("年　　级"),
    info-long-value("grade", info.grade),
    info-key("学　　号"),
    info-long-value("student-id", info.student-id),
    info-key("姓　　名"),
    info-long-value("author", info.author),
    info-key("专　　业"),
    info-long-value("major", info.major),
    info-key("指导教师"),
    info-long-value("supervisor", info.supervisor.at(0)),
  ))
  
  v(160pt)
  
  text(
    font: fonts.黑体,
    size: 字号.小四,
    info.submit-date
  )
}