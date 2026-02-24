#import "../utils/datetime-display.typ": datetime-master-display,datetime-en-display
#import "../utils/justify-text.typ": justify-text
#import "../utils/style.typ": 字号, 字体

// 硕士研究生封面
#let master-cover(
  // documentclass 传入的参数
  doctype: "master",
  degree: "academic",
  nl-cover: false,
  anonymous: false,
  twoside: false,
  fonts: (:),
  info: (:),
  // 其他参数
  stoke-width: 1pt,
  min-title-lines: 2,
  min-reviewer-lines: 5,
  info-inset: (x: 0pt, bottom: 0.5pt),
  info-key-width: 120pt,
  info-column-gutter: 6pt,
  info-row-gutter: 18pt,
  meta-block-inset: (left: -15pt),
  meta-info-inset: (x: 0pt, bottom: 2pt),
  meta-info-key-width: 35pt,
  meta-info-column-gutter: 10pt,
  meta-info-row-gutter: 1pt,
  defence-info-inset: (x: 0pt, bottom: 0pt),
  defence-info-key-width: 110pt,
  defence-info-column-gutter: 2pt,
  defence-info-row-gutter: 12pt,
  anonymous-info-keys: ("student-id", "author", "author-en", "supervisor", "supervisor-en", "supervisor-ii", "supervisor-ii-en",),
  datetime-display: datetime-master-display,
  datetime-en-display: datetime-en-display,
) = {
  // 1.  默认参数
  fonts = 字体 + fonts
  info = (
    title: ("基于 Typst 的", "南京大学学位论文"),
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
  // 2.2 根据 min-title-lines 和 min-reviewer-lines 填充标题和评阅人
  info.title = info.title + range(min-title-lines - info.title.len()).map((it) => "　")
  info.reviewer = info.reviewer + range(min-reviewer-lines - info.reviewer.len()).map((it) => "　")
  // 2.3 处理日期
  assert(type(info.submit-date) == datetime, message: "submit-date must be datetime.")
  if type(info.defend-date) == datetime {
    info.defend-date = datetime-display(info.defend-date)
  }
  if type(info.confer-date) == datetime {
    info.confer-date = datetime-display(info.confer-date)
  }
  if type(info.bottom-date) == datetime {
    info.bottom-date = datetime-display(info.bottom-date)
  }
  // 2.4 处理 degree
  if info.degree == auto {
    if doctype == "doctor" {
      info.degree = "工程博士"
    } else {
      info.degree = "工程硕士"
    }
  }

  // 3.  内置辅助函数
  let info-key(body, info-inset: info-inset, is-meta: false) = {
    set text(
      font: if is-meta { fonts.宋体 } else { fonts.宋体 },
      size: if is-meta { 字号.小四 } else { 字号.三号 },
      weight: if is-meta { "regular" } else { "regular" },
    )
    rect(
      width: 100%,
      inset: info-inset,
      stroke: none,
      justify-text(with-tail: false, body)
    )
  }

  let info-value(key, body, info-inset: info-inset, is-meta: false, no-stroke: false, v-lenth: -14pt) = {
    set align(center)
    rect(
      width: 100%,
      inset: info-inset,
      stroke: if no-stroke { none } else { (bottom: stoke-width + black) },
      text(
        font: if is-meta { fonts.黑体 } else { fonts.宋体 },
        size: if is-meta { 字号.五号 } else { 字号.三号 },
        bottom-edge: "descender",
        if anonymous and (key in anonymous-info-keys) {
          if is-meta { "█████" } else { "██████████" }
        } else {
          body
          v(v-lenth)
          line(length: 100%)
        },
      ),
      
    )
  }

  let info-title-value(key, body, info-inset: info-inset, is-meta: false, no-stroke: false, size:字号.小二) = {
    set align(center)
    rect(
      width: 100%,
      inset: info-inset,
      stroke: if no-stroke { none } else { (bottom: stoke-width + black) },
      text(
        font: 字体.黑体,
        size: size,
        bottom-edge: "descender",
        weight: "bold",
        if anonymous and (key in anonymous-info-keys) {
          if is-meta { "█████" } else { "██████████" }
        } else {
          body
        },
      ),
    )
  }

  let anonymous-text(key, body) = {
    if anonymous and (key in anonymous-info-keys) {
      "██████████"
    } else {
      body
    }
  }

  let meta-info-key = info-key.with(info-inset: meta-info-inset, is-meta: true, )
  let meta-info-value = info-value.with(info-inset: meta-info-inset, is-meta: true, no-stroke: true, v-lenth: -6pt)
  let defence-info-key = info-key.with(info-inset: defence-info-inset)
  let defence-info-value = info-value.with(info-inset: defence-info-inset, no-stroke: true)
  

  // 4.  正式渲染
  pagebreak(weak: true, to: if twoside { "odd" })

  box(width: auto, inset: meta-block-inset, grid(
    columns: (35pt,70pt, 1fr,50pt,70pt),
    column-gutter: meta-info-column-gutter,
    row-gutter: meta-info-row-gutter,
    meta-info-key("分类号"),
    meta-info-value("clc", info.clc),
    [],
    meta-info-key("学校代码"),
    meta-info-value("school-code", info.school-code),
    meta-info-key("UDC"),
    meta-info-value("udc", info.udc),
    [],
    meta-info-key("密级"),
    meta-info-value("secret-level", info.secret-level),
  ))

  v(3em)

  // 居中对齐
  set align(center)

  // 将中文之间的空格间隙从 0.25 em 调整到 0.5 em
  text(size: 字号.小初, font: fonts.黑体, spacing: 200%, weight: "bold",
    if doctype == "doctor" { "博士学位论文" } else { "硕士学位论文" },
  )
  
  // if anonymous {
  //   v(132pt)
  v(1em)

  //标题
  block(width: 294pt, grid(
    columns: ( 1fr),
    column-gutter: info-column-gutter,
    row-gutter: info-row-gutter,
    info-title-value("",info.title.at(0),no-stroke: true),
    info-title-value("",info.title.at(1),no-stroke: true)
  )
  )

  v(8em)

  block(width: 324pt, grid(
    columns: (info-key-width, 1fr),
    column-gutter: info-column-gutter,
    row-gutter: info-row-gutter,
    info-key("学位申请人姓名"),
    info-value("author", info.author),
    info-key("学位申请人学号"),
    info-value("student-id",info.student-id),
    ..(if degree == "professional" {(
      info-key("专业（领域）名称"),
      info-value("major", info.major),
    )} else {(
      info-key("专业名称"),
      info-value("major", info.major),
    )}),
    info-key("专业门类"),
    info-value("field", info.major-categories),
    info-key("学院（部、研究院）"),
    info-value("depatment",info.department),
    info-key("导师姓名"),
    info-value("supervisor", info.supervisor.intersperse(" ").sum()),
  ))

  v(4pt)

  text(font: fonts.宋体, size: 字号.三号, datetime-display(info.submit-date))

}

