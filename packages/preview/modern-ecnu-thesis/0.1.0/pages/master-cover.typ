#import "../utils/datetime-display.typ": datetime-display, datetime-en-display
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
  stroke-width: 0.5pt,
  min-title-lines: 2,
  info-inset: (x: 0pt, bottom: 2pt),
  info-key-width: 86pt,
  info-column-gutter: 18pt,
  info-row-gutter: 10pt,
  title-row-gutter: 18pt,
  title-line-length: 320pt,
  title-line-length-en: 320pt,
  meta-block-inset: (left: 0pt),
  meta-info-inset: (x: 0pt, bottom: 2pt),
  meta-info-key-width: 50pt,
  meta-info-line-length: 230pt,
  meta-info-line-length-en: 200pt,
  meta-info-column-gutter: 18pt,
  meta-info-row-gutter: 1em,
  anonymous-info-keys: (
    "student-id",
    "author",
    "author-en",
    "supervisor",
    "supervisor-en",
    "supervisor-ii",
    "supervisor-ii-en",
    "chairman",
    "reviewer",
  ),
  datetime-display: datetime-display,
  datetime-en-display: datetime-en-display,
) = {
  // 1.  默认参数
  fonts = 字体 + fonts
  info = (
    title: ("基于 Typst 编写的", "华东师范大学学位论文"),
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
  if type(info.department-en) == str {
    info.department-en = info.department-en.split("\n")
  }
  if type(info.department) == str {
    info.department = info.department.split("\n")
  }

  // 2.2 根据 min-title-lines 和 min-reviewer-lines 填充标题和评阅人
  info.title = info.title + range(min-title-lines - info.title.len()).map((it) => "　")
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
  if (info.degree == auto) {
    if (doctype == "doctor") {
      info.degree = "工程博士"
    } else {
      info.degree = "工程硕士"
    }
  }

  // 3.  内置辅助函数
  let info-key(
    body,
    info-inset: info-inset,
    is-meta: false,
    is-title: false,
    with-tail: true,
    justify: true,
    size: none,
    weight: none,
  ) = {
    set text(
      font: if is-title { fonts.宋体 } else { fonts.宋体 },
      size: if size != none { size } else if is-title { 字号.小一 } else if is-meta { 字号.小四 } else { 字号.四号 },
      weight: if weight != none { weight } else if is-title { "bold" } else if is-meta { "regular" } else { "bold" },
    )
    rect(
      width: 100%,
      inset: info-inset,
      stroke: none,
      if justify { justify-text(with-tail: with-tail or is-meta, body) } else { body + if with-tail { "：" } else { "" } + h(1fr) },
    )
  }

  let info-value(key, body, info-inset: info-inset, is-meta: false, is-title: false, no-stroke: false, size: none, weight: none) = {
    set align(center)
    rect(
      width: 100%,
      inset: info-inset,
      stroke: if no-stroke { none } else { (bottom: if is-title { stroke-width * 2 } else { stroke-width } + black) },
      text(
        font: if is-title { fonts.宋体 } else if is-meta { fonts.宋体 } else { fonts.宋体 },
        size: if size != none { size } else if is-title { 字号.小一 } else if is-meta { 字号.小四 } else { 字号.四号 },
        weight: if weight != none { weight } else if is-title { "bold" } else { "regular" },
        bottom-edge: "descender",
        if (anonymous and (key in anonymous-info-keys)) {
          if is-meta { "█████" } else { "██████████" }
        } else {
          body
        },
      ),
    )
  }
  let info-value-cn = info-value.with(weight: "bold")

  let anonymous-text(key, short: false, body) = {
    if (anonymous and (key in anonymous-info-keys)) {
      if short {
        "█████"
      } else {
        "██████████"
      }
    } else {
      body
    }
  }

  let meta-info-key = info-key.with(info-inset: meta-info-inset, is-meta: true)
  let meta-info-value = info-value.with(info-inset: meta-info-inset, is-meta: true)
  let title-info-key = info-key.with(is-title: true)
  let title-info-value = info-value.with(info-inset: (bottom: 4pt), is-title: true)
  let title-en-info-value = info-value.with(info-inset: (bottom: 3pt), is-title: true, size: 16pt)
  let info-key-indent = info-key.with(" ", with-tail: false, justify: false)

  // 4.  正式渲染
  pagebreak(weak: true, to: if twoside { "odd" })

  let headline = (
    "academic": ("master": "研究生硕士", "doctor": "研究生博士"),
    "professional": ("master": "硕士专业学位研究生", "doctor": "博士专业学位研究生"),
  )

  block(
    width: 100%,
    text(font: fonts.宋体, size: 字号.小四, info.grade + " 届" + headline.at(degree).at(doctype) + "学位论文"),
  )

  block(width: 100%, inset: meta-block-inset, grid(
    columns: (meta-info-key-width, 1fr, meta-info-key-width, 1fr),
    column-gutter: (meta-info-column-gutter, meta-info-column-gutter * 2, meta-info-column-gutter, 0pt),
    row-gutter: meta-info-row-gutter,
    meta-info-key("分类号"),
    meta-info-value("clc", info.clc),
    meta-info-key("学校代码"),
    meta-info-value("school-code", info.school-code),
    meta-info-key("密级"),
    meta-info-value("secret-level", info.secret-level),
    meta-info-key("学号"),
    meta-info-value("student-id", info.student-id),
  ))
  // 居中对齐
  set align(center)

  // 匿名化处理去掉封面标识
  if (anonymous) {
    v(70pt)
  } else {
    // 封面图标
    v(36pt)
    image("../assets/ecnu-emblem-name.svg", height: 60pt)
    v(20pt)
  }

  text(
    size: 字号.小四,
    font: 字体.宋体,
    stack(
      dir: ttb,
      spacing: 15pt,
      if (not anonymous) { "East China Normal University" } else { " " },
      if doctype == "doctor" { "博士学位论文" } else { "硕士学位论文" },
      text(weight: "bold", smallcaps(if doctype == "doctor" { "DOCTORAL DISSERTATION" } else { "MASTER'S DISSERTATION" })),
    ),
  )

  v(32pt)

  set align(center)

  stack(
    dir: ttb,
    spacing: 1fr,
    // 标题
    grid(
      columns: (100pt, title-line-length),
      column-gutter: 20pt,
      row-gutter: title-row-gutter,
      title-info-key("论文题目", with-tail: true),
      ..info.title.map((s) => title-info-value("title", s)).intersperse(info-key("　", with-tail: false, is-title: true)),
    ),
    // 元数据
    block(
      // width: 280pt,
      grid(
        columns: (info-key-width, meta-info-line-length),
        column-gutter: info-column-gutter,
        row-gutter: info-row-gutter,
        info-key("院系"),
        ..info.department.map((s) => info-value-cn("department", s)).intersperse(info-key("　", with-tail: false, justify: false, is-meta: true)),
        info-key(if degree == "academic" { "专业" } else { "专业学位类别" }),
        info-value-cn("major", info.major),
        info-key(if degree == "academic" { "研究方向" } else { "专业学位领域" }),
        info-value-cn("field", info.field),
        info-key("学位申请人"),
        info-value-cn("author", info.author),
        info-key("指导教师"),
        info-value-cn("supervisor", info.supervisor.intersperse(h(0.5em)).sum()),
        ..(
          if info.supervisor-ii != () { (info-key-indent(), info-value-cn("supervisor-ii", info.supervisor-ii.intersperse(" ").sum()),) } else { () }
        ),
      ),
    ),
    // 日期
    text(font: fonts.宋体, size: 字号.四号, datetime-display(info.submit-date)),
  )

  // 英文封面页
  pagebreak(weak: true, to: if twoside { "odd" })

  set text(font: fonts.宋体, size: 字号.小四)
  set par(leading: 1.5em)
  set align(left)

  let headline_en = (
    "academic": ("master": "Master's Degree", "doctor": "Doctoral Degree"),
    "professional": ("master": "Master's Degree (Professional)", "doctor": "Doctoral Degree (Professional)"),
  )

  [Dissertation for #headline_en.at(degree).at(doctype) in #info.grade]

  set align(right)

  grid(
    align: left,
    columns: (90pt, 6em),
    row-gutter: 1.5em,
    column-gutter: 0em,
    [University Code:],
    [#h(1fr)10269],
    [Student ID:],
    [#h(1fr)#anonymous-text("student-id", short: true, info.student-id)],
  )

  v(45pt)

  set align(center)

  if (anonymous) {
    v(80pt)
  } else {
    v(30pt)
    image("../assets/ecnu-name-en.svg", height: 12pt, fit: "contain")
    v(20pt)
  }

  v(40pt)

  let en-info-key = info-key.with(info-inset: meta-info-inset, justify: false, size: 字号.小四, with-tail: false, weight: "regular")
  let en-info-value = info-value.with(info-inset: meta-info-inset, size: 字号.小四)

  stack(
    dir: ttb,
    spacing: 1fr,
    // 标题
    grid(
      columns: (40pt, title-line-length-en),
      column-gutter: 20pt,
      row-gutter: title-row-gutter * 0.6,
      info-key("Title:", with-tail: false, justify: false, size: 16pt, weight: "bold"),
      ..info.title-en.map((s) => title-en-info-value("title", s)).intersperse(info-key("　", with-tail: false, is-title: true)),
    ),
    // 元数据
    block(
      grid(
        columns: (120pt, meta-info-line-length-en),
        column-gutter: 0pt,
        row-gutter: info-row-gutter,
        en-info-key("Department / School:"),
        ..info.department-en.map((s) => en-info-value("department", s)).intersperse(info-key("　", justify: false, with-tail: false, is-meta: true)),
        en-info-key(if degree == "academic" { "Major:" } else { "Category:" }),
        en-info-value("major", info.major-en),
        en-info-key(if degree == "academic" { "Research Direction:" } else { "Field:" }),
        en-info-value("field", info.field-en),
        en-info-key("Candidate:"),
        en-info-value("author", info.author-en),
        en-info-key("Supervisor:"),
        en-info-value("supervisor", info.supervisor-en.intersperse(" ").sum()),
        ..(
          if info.supervisor-ii-en != () { (info-key-indent(), info-value("supervisor-ii", info.supervisor-ii-en.intersperse(" ").sum()),) } else { () }
        ),
      ),
    ),
    // 日期
    datetime-en-display(info.submit-date),
  )

  pagebreak(weak: true, to: if twoside { "odd" })
}