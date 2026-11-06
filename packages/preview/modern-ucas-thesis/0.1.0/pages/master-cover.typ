#import "../utils/datetime-display.typ": datetime-display, datetime-en-display
#import "../utils/justify-text.typ": justify-text
#import "../utils/style.typ": get-fonts, 字号

// 硕士研究生封面
#let master-cover(
  // documentclass 传入的参数
  doctype: "master",
  degree: "academic",
  nl-cover: false,
  anonymous: false,
  twoside: false,
  fontset: "mac",
  fonts: (:),
  info: (:),
  // 其他参数
  stoke-width: 0.5pt, // 控制元素边框（如框架、分隔线等）的线宽度。
  min-title-lines: 2, // 控制标题行数的最小值。
  min-supervisor-lines: 2, // 控制指导教师区域的最小行数。
  min-reviewer-lines: 5, // 控制评审人区域的最小行数。
  info-inset: (
    x: 0pt,
    bottom: 0.5pt,
  ), // 控制信息区域的内边距。x 左右间距，bottom 底部间距
  info-key-width: 70pt, // 控制信息标签（如“论文题目”、“作者姓名”）的宽度。
  info-column-gutter: 18pt, // 控制信息列之间的间距。
  info-row-gutter: 12pt, // 控制信息行之间的间距。
  meta-block-inset: (left: -15pt), // 控制元数据块的内边距。
  meta-info-inset: (x: 0pt, bottom: 2pt), // 控制元信息区域的内边距。
  meta-info-key-width: 35pt, // 控制元信息标签的宽度（如“学位”、“提交日期”）。
  meta-info-column-gutter: 10pt, // 控制元信息列之间的间距。
  meta-info-row-gutter: 1pt, // 控制元信息行之间的间距。
  defence-info-inset: (x: 0pt, bottom: 0pt), // 控制答辩信息区域的内边距。
  defence-info-key-width: 110pt, // 控制答辩信息标签的宽度。
  defence-info-column-gutter: 2pt, // 控制答辩信息列之间的间距。
  defence-info-row-gutter: 12pt, // 控制答辩信息区域行与行之间的间距。
  anonymous-info-keys: (
    // 控制需要匿名化处理的字段。
    "student-id",
    "author",
    "author-en",
    "supervisors",
    "supervisors-en",
    "supervisor-ii",
    "supervisor-ii-en",
    "chairman",
    "reviewer",
    "department",
  ),
  datetime-display: datetime-display, // 用于格式化日期显示。
  datetime-en-display: datetime-en-display, // 用于格式化英文日期显示。
) = {
  // 1.  默认参数
  fonts = get-fonts(fontset) + fonts
  info = (
    (
      title: "基于 Typst 的中国科学院大学学位论文",
      title-en: "Typst Thesis Template of UCAS",
      supervisors: ("李四 教授", "王五 研究员"),
      supervisors-en: ("Professor Si Li", "Professor Wu Wang"),
      grade: "20XX",
      student-id: "1234567890",
      author: "张三",
      department: "XX 研究所",
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
  if type(info.title-en) == str {
    info.title-en = info.title-en.split("\n")
  }
  if type(info.supervisors) == str {
    info.supervisors = info.supervisors.split("\n")
  }
  if type(info.supervisors-en) == str {
    info.supervisors-en = info.supervisors-en.split("\n")
  }
  // 2.2 根据 min-title-lines 和 min-reviewer-lines 填充标题和评阅人
  info.title = (
    info.title + range(min-title-lines - info.title.len()).map(it => "　")
  )
  info.reviewer = (
    info.reviewer + range(min-reviewer-lines - info.reviewer.len()).map(it => "　")
  )
  info.supervisors = (
    info.supervisors + range(min-supervisor-lines - info.supervisors.len()).map(it => "　")
  )
  // 2.3 处理日期
  assert(
    type(info.submit-date) == datetime,
    message: "submit-date must be datetime.",
  )
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
  let info-key(body, info-inset: info-inset, is-meta: false) = {
    set text(
      font: if is-meta {
        fonts.宋体
      } else {
        fonts.宋体
      },
      size: if is-meta {
        字号.小五
      } else {
        字号.四号
      },
      weight: if is-meta {
        "regular"
      } else {
        "bold"
      },
    )
    rect(
      width: 100%,
      inset: info-inset,
      stroke: none,
      justify-text(with-tail: is-meta, body),
    )
  }

  let info-value(
    key,
    body,
    info-inset: info-inset,
    is-meta: false,
    no-stroke: false,
  ) = {
    set align(center)
    rect(
      width: 100%,
      inset: info-inset,
      stroke: if no-stroke {
        none
      } else {
        (bottom: stoke-width + black)
      },
      text(
        font: if is-meta {
          fonts.宋体
        } else {
          fonts.宋体
        },
        weight: if is-meta {
          "regular"
        } else {
          "bold"
        },
        size: if is-meta {
          字号.小五
        } else {
          字号.四号
        },
        bottom-edge: "descender",
        if (anonymous and (key in anonymous-info-keys)) {
          if is-meta {
            "█████"
          } else {
            "██████████"
          }
        } else {
          body
        },
      ),
    )
  }

  let anonymous-text(key, body) = {
    if (anonymous and (key in anonymous-info-keys)) {
      "██████████"
    } else {
      body
    }
  }

  let meta-info-key = info-key.with(info-inset: meta-info-inset, is-meta: true)
  let meta-info-value = info-value.with(
    info-inset: meta-info-inset,
    is-meta: true,
  )
  let defence-info-key = info-key.with(info-inset: defence-info-inset)
  let defence-info-value = info-value.with(info-inset: defence-info-inset)


  // 4.  正式渲染
  pagebreak(weak: true)

  v(80pt)

  // 居中对齐
  set align(center)

  // 匿名化处理去掉封面标识
  if (anonymous) {
    v(93.5pt)
  } else {
    // 封面图标
    image("../assets/vi/ucas-logo-H-standard.svg", height: 2.2cm)
  }

  v(26pt)

  // 将中文之间的空格间隙从 0.25 em 调整到 0.5 em
  text(
    size: 字号.一号,
    font: fonts.黑体,
    spacing: 200%,
    weight: "bold",
    if doctype == "doctor" {
      "博士学位论文"
    } else {
      "硕士学位论文"
    },
  )

  v(28pt)

  text(
    size: 字号.小三,
    font: fonts.黑体,
    spacing: 100%,
    weight: "bold",
    underline(
      offset: .4em,
      stroke: .05em,
      evade: false,
    )[#(info.title.sum())],
  )

  v(56pt)

  block(
    // width: 294pt, 限制宽度
    grid(
      columns: (info-key-width, 1fr),
      column-gutter: info-column-gutter,
      row-gutter: info-row-gutter,
      info-key("作者姓名："),
      info-value("author", info.author),
      info-key("指导教师："),
      ..info.supervisors.map(s => info-value("supervisors", s)).intersperse(info-key("　")),
      info-key("学位类别："),
      info-value("category", info.category),
      ..(
        if degree == "professional" {
          (
            {
              set text(font: fonts.楷体, size: 字号.四号, weight: "bold")
              move(dy: 0.3em, scale(x: 55%, box(
                width: 10em,
                "专业学位类别（领域）",
              )))
            },
            info-value("major", info.degree + "（" + info.major + "）"),
          )
        } else {
          (
            info-key("学科专业："),
            info-value("major", info.major),
          )
        }
      ),
      info-key("培养单位："),
      info-value("department", info.department),
      ..(
        if info.supervisor-ii != () {
          (
            info-key("　"),
            info-value(
              "supervisor-ii",
              info.supervisor-ii.intersperse(" ").sum(),
            ),
          )
        } else {
          ()
        }
      ),
    ),
  )

  v(42pt)

  text(font: fonts.宋体, size: 字号.四号, weight: "bold", datetime-display(
    info.submit-date,
  ))

  // 第二页
  if twoside {
    pagebreak(
      weak: true,
      to: "odd",
    )
  }

  // 第三页英文封面页
  pagebreak(weak: true)

  set text(font: fonts.楷体, size: 字号.四号)
  set par(leading: 1.3em)

  v(80pt)

  text(
    font: "Times New Roman",
    size: 字号.小三,
    weight: "bold",
    underline(offset: .4em, stroke: .05em, evade: false)[#(
        info.title-en.intersperse("\n").sum()
      )],
  )

  if info.supervisor-ii-en != "" {
    v(-4pt)

    text(font: fonts.黑体, size: 字号.四号, anonymous-text(
      "supervisor-ii-en",
      info.supervisor-ii-en,
    ))

    v(-9pt)
  }

  v(85pt)

  strong[
    A dissertation submitted to \
    #(
      if not anonymous {
        "University of Chinese Academy of Sciences"
      }
    ) \
    in partial fulfillment of the requirement \ for the degree of \
  ]

  if doctype == "doctor" {
    strong[Doctor of #info.category-en]
  } else {
    strong[Master of #info.category-en]
  }
  strong[\ in ]
  strong[#info.major-en]

  strong[
    \ By \ #text(anonymous-text("author-en", info.author-en)) \
  ]
  // 处理 info.supervisors-en
  if type(info.supervisors-en) == str {
    // 只有一个supervisor
    text(
      weight: "bold",
      "Supervisor: " + anonymous-text("supervisors-en", info.supervisors-en),
    )
  } else {
    // 多个supervisor
    // 先把所有的supervisors转为匿名处理后的字符串列表
    let supers = info.supervisors-en.map(s => anonymous-text(
      "supervisors-en",
      s,
    ))

    // 利用 intersperse 在各个supervisor之间加入换行和空格（缩进）
    // TODO: 丑陋的实现，但效果还行，有时间再优化
    text(
      weight: "bold",
      "Supervisors: " + supers.intersperse("\n                               ").sum(),
    )
  }

  v(90pt)

  if not anonymous {
    strong[#info.department-en, Chinese Academy of Sciences]
  } else { v(26pt) }

  v(28pt)

  strong[#datetime-en-display(info.submit-date)]
}
