#import "../utils/datetime-display.typ": datetime-display-bachelor
#import "../utils/style.typ": 字号, 字体
#import "../utils/str.typ": to-normal-str

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
  info-inset: (x: 0pt, bottom: 3pt),
  info-title-inset: (x: 0pt, bottom: 7pt),
  info-key-width: 80pt,
  info-key-font: "宋体",
  info-value-font: "宋体",
  column-gutter: 1pt,
  row-gutter: 11.5pt,
  anonymous-info-keys: ("grade", "student-id", "author", "supervisor", "supervisor-ii"),
  bold-info-keys: ("title",),
  bold-level: "bold",
  datetime-display: datetime-display-bachelor,
  title-line-length: 320pt,
  title-line-length-en: 320pt,
  meta-info-line-length: 200pt,
  meta-info-line-length-en: 230pt,
) = {
  // 1.  默认参数
  fonts = 字体 + fonts
  info = (
    title: ("基于 Typst 的", "华东师范大学学位论文"),
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
  if type(info.department) == str {
    info.department = info.department.split("\n")
  }
  // 2.3 处理提交日期
  if type(info.submit-date) == datetime {
    info.submit-date = datetime-display(info.submit-date)
  }

  // 3.  内置辅助函数
  let info-key(with-tail: true, body) = {
    rect(
      width: 100%,
      inset: info-inset,
      stroke: none,
      text(font: fonts.at(info-key-font, default: "宋体"), weight: "bold", size: 字号.四号, body + if with-tail { "：" } else { "" }),
    )
  }

  let info-value(size: 字号.四号, key, body) = {
    set align(center)
    rect(width: 100%, inset: info-inset, stroke: (bottom: stoke-width + black), text(
      font: fonts.at(info-value-font, default: "宋体"),
      size: size,
      weight: "bold",
      bottom-edge: "descender",
      body,
    ))
  }

  let info-long-value(size: 字号.四号, key, body) = {
    grid.cell(colspan: 3, info-value(size: size, key, if anonymous and (key in anonymous-info-keys) {
      "██████████"
    } else {
      body
    }))
  }

  let info-title-value(size: 字号.一号, body) = {
    set align(center)
    underline(offset: 6pt, stroke: 1.25pt, text(
      font: fonts.at(info-value-font, default: "宋体"),
      size: size,
      weight: "bold",
      bottom-edge: "baseline",
      body,
    ))
  }

  let info-short-value(key, body) = {
    info-value(key, if anonymous and (key in anonymous-info-keys) {
      "█████"
    } else {
      body
    })
  }

  // 存储状态用于后续页眉
  let s = state("title")
  context s.update(to-normal-str(src: info.title))
  let sen = state("title-en")
  context sen.update(to-normal-str(src: info.title-en))

  // 4.  正式渲染
  pagebreak(weak: true, to: if twoside { "odd" })

  // 居中对齐
  set align(center)

  [
    #set text(font: fonts.宋体, size: 字号.小四, weight: "bold")
    #info.grade 届本科生学士学位论文
    #h(1fr)
    学校代码：#underline(stroke: 0.5pt, offset: 3pt)[
      #if anonymous {
        10269
      } else {
        10269
      }
    ]
  ]

  v(5pt)

  // 匿名化处理去掉封面标识
  if anonymous {
    v(60pt)
  } else {
    // 封面图标
    v(6pt)
    image("../assets/ecnu-bachelor-thesis-cover.svg", width: 9.5cm)
  }

  if anonymous {
    v(40pt)
  } else {
    v(15pt)
  }

  stack(dir: ttb, spacing: 1fr,
    block(width: title-line-length * 1.5)[
      #stack(
        dir: ttb,
        spacing: 12pt,
        ..info.title.map((it) => info-title-value(size: 字号.一号, it)),
        h(0.5em),
        ..info.title-en.map((it) => info-title-value(size: 字号.一号, it))
      )
    ],

    block(width: 80pt + meta-info-line-length, grid(
      columns: (info-key-width, 1fr, info-key-width, 1fr),
      column-gutter: column-gutter,
      row-gutter: row-gutter,
      info-key("姓　　名"),
      info-long-value("author", info.author),
      info-key("学　　号"),
      info-long-value("student-id", info.student-id),
      info-key("学　　院"),
      ..info.department.map((it) => info-long-value("department", it)).intersperse(info-key("", with-tail: false)),
      info-key("专　　业"),
      info-long-value("major", info.major),
      info-key("指导教师"),
      info-long-value("supervisor", info.supervisor.at(0)),
      info-key("职　　称"),
      info-long-value("supervisor", info.supervisor.at(1)),
    )),

    text(font: fonts.宋体, size: 字号.四号, weight: "bold", info.submit-date),
  )

}
