#import "../utils/datetime-display.typ": datetime-display
#import "../utils/style.typ": 字号, 字体
#import "@preview/cuti:0.2.1": *

// 本科生封面
#let bachelor-cover(
  // documentclass 传入的参数
  anonymous: false,
  twoside: false,
  fonts: (:),
  info: (:),
  // 其他参数
  stoke-width: 0.5pt,
  min-title-lines: 2,
  info-inset: (x: 5pt, bottom: 1pt),
  info-key-width: 105pt,
  info-key-font: "宋体",
  info-value-font: "宋体",
  column-gutter: -3pt,
  row-gutter: 15.5pt,
  anonymous-info-keys: ("grade", "student-id", "author", "supervisor", "supervisor-ii"),
  bold-info-keys: ("title",),
  bold-level: "bold",
  datetime-display: datetime-display,
) = {
  // 0.伪粗体
  show: show-cn-fakebold
   
  // 1.  默认参数
  fonts = 字体 + fonts
  info = (
    title: ("基于 Typst 的", "北京师范大学大学学位论文"),
    grade: "20XX",
    student-id: "202111xxxxxx",
    author: "张三",
    department: "人工智能学院",
    major: "人工智能",
    supervisor: ("李四", "教授", "人工智能学院"),
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
    rect(width: 100%, inset: info-inset, stroke: none, fakebold(
      weight: "extrabold",
      (text(font: fonts.at(info-key-font, default: "宋体"), weight: "extrabold", size: 字号.四号, body + [：])),
    ))
  }
   
  let info-value(key, body) = {
    set align(left)
    rect(width: 100%, inset: info-inset, stroke: none, fakebold(weight: "extrabold", text(
      font: fonts.at(info-value-font, default: "宋体"),
      size: 字号.四号,
      weight: "extrabold",
      bottom-edge: "descender",
      body,
    )))
  }
   
  let info-value-number(key, body) = {
    set align(left)
    rect(width: 100%, inset: info-inset, stroke: none, text(
      font: fonts.at(info-value-font, default: "宋体"),
      size: 字号.四号,
      weight: "extrabold",
      bottom-edge: "descender",
      body,
    ))
  }
   
  let info-long-value(key, body) = {
    grid.cell(colspan: 3, info-value(key, if anonymous and (key in anonymous-info-keys) {
      "██████████"
    } else {
      body
    }))
  }
   
  let info-long-value-number(key, body) = {
    grid.cell(colspan: 3, info-value-number(key, if anonymous and (key in anonymous-info-keys) {
      "██████████"
    } else {
      body
    }))
  }
   
  let info-short-value(key, body) = {
    info-value(key, if anonymous and (key in anonymous-info-keys) {
      "█████"
    } else {
      body
    })
  }
   
   
  // 4.  正式渲染
   
  pagebreak(weak: true, to: if twoside { "odd" })
   
  set page(margin: (left: 2.5cm, top: 2.5cm, right: 2.0cm, bottom: 2.0cm))
  set par(spacing: 0pt)
   
  // 居中对齐
  set align(center)
   
  // 匿名化处理去掉封面标识
  if anonymous {
    v(52pt)
  } else {
    v(2cm)
    // 封面图标
    // v(6pt)
    // image("../assets/vi/nju-emblem.svg", width: 2.38cm)
    // v(22pt)
    // 调整一下左边的间距
    block(image("../assets/vi/bnu-name.svg", width: 7.81cm))
    v(1cm)
  }
   
  // 将中文之间的空格间隙从 0.25 em 调整到 0.5 em
  block(text(size: 字号.小初, font: 字体.宋体, spacing: 0.25em, weight: "extrabold", fakebold()[ 本 科 生 毕 业 论 文（设 计） ]))
   
  if anonymous {
    v(155pt)
  } else {
    v(2.4cm)
  }
  // 论文标题
  align(std.left, block(
    // stroke: black,
    inset: (left: 3em, bottom: 0pt),
    fakebold(weight: "bold",text(size: 字号.三号, font: 字体.宋体, weight: "bold", "毕业论文（设计）题目：")),
  ))
   
  rect(width: 15cm, height: 1.2cm, stroke: (bottom: black + 0.05em), inset: (top: 0.65cm), fakebold(
    weight: "extrabold",
    text(size: 字号.三号, font: 字体.宋体, weight: "extrabold", bottom-edge: "descender", info.title.at(0)),
  ))
   
  rect(width: 15cm, height: 1.2cm, stroke: (bottom: black + 0.05em), inset: (top: 0.65cm), fakebold(
    weight: "extrabold",
    text(size: 字号.三号, font: 字体.宋体, weight: "extrabold", bottom-edge: "descender", info.title.at(1)),
  ))
  
  v(1.8cm)
   
  block(width: 280pt, grid(
    columns: (info-key-width, 1cm, 3cm, 1cm),
    column-gutter: column-gutter,
    row-gutter: row-gutter,
    // stroke: black,
    info-key([部#h(1fr)院#h(1fr)系]),
    info-long-value("department", info.department),
    info-key([专#h(1fr)业]),
    info-long-value("major", info.major),
    // info-key("题　　目"),
    // ..info.title.map((s) => info-long-value("title", s)).intersperse(info-key("　")),
    // info-key("年　　级"),
    // info-long-value("grade", info.grade),
    info-key([学#h(1fr)号]),
    info-long-value-number("student-id", info.student-id),
    info-key([学#h(1fr)生#h(1fr)姓#h(1fr)名]),
    info-long-value("author", info.author),
    info-key([指#h(1fr)导#h(1fr)教#h(1fr)师]),
    info-long-value("supervisor", info.supervisor.at(0)),
    info-key([指#h(1fr)导#h(1fr)教#h(1fr)师#h(1fr)职#h(1fr)称]),
    info-long-value("supervisor", info.supervisor.at(1)),
    // ..(if info.supervisor-ii != () {
    //   (
    //     info-key("第二导师"),
    //     info-short-value("supervisor-ii", info.supervisor-ii.at(0)),
    //     info-key("职　　称"),
    //     info-short-value("supervisor-ii", info.supervisor-ii.at(1)),
    //   )
    // } else { () }),
    info-key([指#h(1fr)导#h(1fr)教#h(1fr)师#h(1fr)单#h(1fr)位]),
    info-long-value("submit-date", info.supervisor.at(2)),
  ))
   
  v(2.6cm)
  block(text(info.submit-date, font: 字体.宋体, weight: "regular", cjk-latin-spacing: none))
}