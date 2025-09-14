#import "../utils/datetime-display.typ": datetime-display-without-day, datetime-en-display
#import "../utils/justify-text.typ": justify-text
#import "../utils/style.typ": font_family, font_size
#import "../utils/custom-cuti.typ": fakebold

//! 硕士研究生封面
#let master-cover(
  //? thesis 传入的参数
  doctype: "master",
  degree: "academic",
  nl-cover: false,
  anonymous: false,
  twoside: false,
  fonts: (:),
  info: (:),
  // 其他参数
  stoke-width: 0.5pt,
  min-title-lines: 2,
  info-inset: (x: 0pt, bottom: 0.5pt),
  info-key-width: 50pt,
  info-column-gutter: 5pt,
  info-row-gutter: 2pt,
  meta-block-inset: (left: -15pt),
  meta-info-inset: (x: 0pt, bottom: 2pt),
  meta-info-key-width: 35pt,
  meta-info-column-gutter: 10pt,
  meta-info-row-gutter: 1pt,
  defence-info-inset: (x: 0pt, bottom: 0pt),
  defence-info-key-width: 110pt,
  defence-info-column-gutter: 2pt,
  defence-info-row-gutter: 12pt,
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
  datetime-display: datetime-display-without-day,
  datetime-en-display: datetime-en-display,
) = {
  //? 1.  默认参数
  fonts = font_family + fonts
  info = (
    (
      title: "基于 Typst 的东北师范大学学位论文模板",
      grade: "20XX",
      student-id: "1234567890",
      author: "张三",
      secret-level: "公开",
      department: "信息科学与技术学院",
      discipline: "计算机科学与技术",
      major: "计算机技术",
      field: "人工智能",
      supervisor: ("李四", "教授"),
      submit-date: datetime.today(),
    )
      + info
  )

  //? 2.  对参数进行处理
  //? 2.1 如果是字符串，则使用换行符将标题分隔为列表
  if type(info.title) == str {
    info.title = info.title.split("\n")
  }
  if type(info.title-en) == str {
    info.title-en = info.title-en.split("\n")
  }

  //? 2.2 根据 min-title-lines  填充标题
  info.title = info.title + range(min-title-lines - info.title.len()).map(it => "　")

  //? 2.3 处理日期
  assert(type(info.submit-date) == datetime, message: "submit-date must be datetime.")

  //? 2.4 处理 degree
  if degree == auto {
    if doctype == "doctor" {
      info.degree = "工程博士"
    } else {
      info.degree = "工程硕士"
    }
  }

  //? 3.  内置辅助函数
  let info-key(body, info-inset: info-inset, is-meta: false, is-chinese: true) = {
    set text(
      font: fonts.宋体,
      size: if is-meta { font_size.五号 } else { font_size.小四 },
      weight: "regular",
    )
    if is-meta {
      body
    } else {
      if is-chinese {
        rect(
          width: 100%,
          inset: info-inset,
          stroke: none,
          justify-text(with-tail: is-meta, body),
        )
      } else {
        set align(left)
        rect(
          width: 100%,
          inset: info-inset,
          stroke: none,
          body,
        )
      }
    }
  }

  let info-value(key, body, info-inset: info-inset, is-meta: false, no-stroke: false) = {
    set align(center)
    if is-meta {
      body
    } else {
      rect(
        width: 100%,
        inset: info-inset,
        stroke: if no-stroke { none } else { (bottom: stoke-width + black) },
        text(
          font: fonts.宋体,
          size: if is-meta { font_size.五号 } else { font_size.小四 },
          weight: "regular",
          bottom-edge: "descender",
          if anonymous and (key in anonymous-info-keys) {
            if is-meta { "█████" } else { "██████████" }
          } else {
            body
          },
        ),
      )
    }
  }

  let anonymous-text(key, body) = {
    if anonymous and (key in anonymous-info-keys) {
      "██████████"
    } else {
      body
    }
  }

  let meta-info-key = info-key.with(info-inset: meta-info-inset, is-meta: true)
  let meta-info-value = info-value.with(info-inset: meta-info-inset, is-meta: true)
  let defence-info-key = info-key.with(info-inset: defence-info-inset)
  let defence-info-value = info-value.with(info-inset: defence-info-inset)


  //! 4.  正式渲染

  pagebreak(weak: true, to: if twoside { "odd" })
  v(font_size.小四 * 2)

  // 居中对齐
  set align(center)

  [
    #set text(font: fonts.宋体, size: font_size.四号)
    #v(4.55pt)
    #if doctype == "doctor" { "博士研究生学位论文" } else { "硕士研究生学位论文" }
  ]

  [
    #set text(font: fonts.宋体, size: font_size.五号)
    #v(4pt)
    #block(
      width: 30em,
      grid(
        columns: (.8fr, 1.2fr, .6fr),
        column-gutter: 1em,
        row-gutter: 0em,
        grid(
          columns: 2,
          column-gutter: .1em,
          meta-info-key("学校代码:"), meta-info-value("school-code", info.school-code),
        ),
        grid(
          columns: 2,
          column-gutter: .1em,
          meta-info-key("研究生学号: "), meta-info-value("student-id", info.student-id),
        ),
        grid(
          columns: 2,
          column-gutter: .1em,
          meta-info-key("密级: "), meta-info-value("secret-level", info.secret-level),
        ),
      ),
    )
  ]

  line(length: 100%, stroke: .5pt + black)

  // TODO 匿名模式下，去掉信息

  //? 封面图标
  v(52pt)
  if doctype == "doctor" {
    image("../assets/nenu-logo-red.svg", width: 3.5cm)
  } else {
    image("../assets/nenu-logo-green.svg", width: 3.5cm)
  }
  v(20pt)

  //? 标题
  [
    #set par(leading: 1.11em)
    #set text(font: fonts.黑体, size: font_size.三号, weight: "bold")

    #info.title.intersperse("\n").sum()
  ]

  v(140pt)

  //? 作者信息
  block(width: 200pt, grid(
    columns: (info-key-width, 1fr),
    column-gutter: info-column-gutter,
    row-gutter: info-row-gutter,
    info-key("作者"),
    info-value("author", info.author),
    info-key("指导教师"),
    info-value("supervisor", info.supervisor.intersperse(" ").sum()),
    ..(
      if degree == "professional" {
        (
          info-key("学位类别"),
          info-value("discipline", info.discipline),
          info-key("学位领域"),
          info-value("major", info.major),
        )
      } else {
        (
          info-key("一级学科"),
          info-value("discipline", info.discipline),
          info-key("二级学科"),
          info-value("major", info.major),
        )
      }
    ),
    info-key("研究方向"),
    info-value("field", info.field),
  ))

  v(24pt)

  //? 底部信息
  [
    #set par(leading: 24.75pt)
    #set text(font: fonts.宋体, size: font_size.五号)
    #box(
      image("../assets/nenu-title-blue.svg", height: 0.64cm, width: 3.12cm),
    )
    #box(height: 1.2em, [学位评定委员会])

  ]

  //? 日期
  [
    #v(1pt)
    #set par(leading: 0.91pt)
    #set text(font: fonts.宋体, size: font_size.四号)
    #datetime-display-without-day(info.submit-date)
  ]

  //* 英文封面
  pagebreak(weak: true)

  v(font_size.小四 * 2)

  // 居中对齐
  set align(center)

  [
    #set text(font: fonts.宋体, size: font_size.四号)
    #v(4.55pt)
    // #if doctype == "doctor" { "A Thesis" } else { "A Dissertation" }
    A Thesis
  ]

  [
    #set text(font: fonts.宋体, size: font_size.五号)
    #v(4pt)
    #block(
      width: 32em,
      grid(
        columns: (.6fr, .8fr, .8fr),
        column-gutter: .2em,
        row-gutter: 0em,
        grid(
          columns: 2,
          column-gutter: .1em,
          meta-info-key("School code: "), meta-info-value("school-code", info.school-code),
        ),
        grid(
          columns: 2,
          column-gutter: .1em,
          meta-info-key("Student ID: "), meta-info-value("student-id", info.student-id),
        ),
        grid(
          columns: 2,
          column-gutter: .1em,
          meta-info-key("Security level: "), meta-info-value("secret-level", info.secret-level-en),
        ),
      ),
    )
  ]

  line(length: 100%, stroke: .5pt + black)

  // TODO 匿名模式下，去掉信息

  //? 封面图标
  v(52pt)
  if doctype == "doctor" {
    image("../assets/nenu-logo-red.svg", width: 3.5cm)
  } else {
    image("../assets/nenu-logo-green.svg", width: 3.5cm)
  }
  v(20pt)

  //? 标题
  [
    #set par(leading: 1.11em)
    #set text(font: fonts.黑体, size: font_size.三号, weight: "bold")

    #info.title-en.intersperse("\n").sum()
  ]

  v(140pt)

  // FIXME 作者信息与模板在对齐上不一致

  block(width: 350pt, grid(
    columns: (1.3fr, 1.3fr),
    column-gutter: info-column-gutter,
    row-gutter: info-row-gutter,
    info-key("Author", is-chinese: false),
    info-value("author", info.author-en),
    info-key("Supervisor", is-chinese: false),
    info-value("supervisor", info.supervisor-en),
    ..(
      if degree == "professional" {
        (
          info-key("Degree category", is-chinese: false),
          info-value("discipline", info.discipline-en),
          info-key("Degree field", is-chinese: false),
          info-value("major", info.major-en),
        )
      } else {
        (
          info-key("Primary Subject Classification", is-chinese: false),
          info-value("discipline", info.discipline-en),
          info-key("Secondary Subject Classification", is-chinese: false),
          info-value("major", info.major-en),
        )
      }
    ),
    info-key("Research Area", is-chinese: false),
    info-value("field", info.field-en),
  ))

  v(40pt)

  //? 底部信息
  [
    #set par(leading: 24.75pt)
    #set text(font: fonts.宋体, size: font_size.小四)
    Northeast Normal University Academic Degree Evaluation Committee
  ]

  //? 日期
  [
    #v(1pt)
    #set par(leading: 0.91pt)
    #set text(font: fonts.宋体, size: font_size.四号)
    #datetime-en-display(info.submit-date)
  ]
}
