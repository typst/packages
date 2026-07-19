#import "@preview/pointless-size:0.1.1": zh
#import "@preview/cuti:0.3.0": show-cn-fakebold
#import "../utils/justify-text.typ": justify-text

#let cover(
  anonymous: false, // 是否匿名，用于盲审送审
  info: (:), // 论文相关信息
  twoside: false,
  info-key-width: 72pt,
  column-gutter: 10pt,
  row-gutter: 11.5pt,
  info-inset: (x: 0pt, bottom: 0.5pt),
  stroke-width: 0.5pt,
  anonymous-info-keys: (
    "student-id",
    "author",
    "author-en",
    "supervisor",
    "supervisor-en",
    "supervisor-ii",
    "supervisor-ii-en",
    "chairman",
    "class",
    "department",
    "reviewer",
  ),
) = {
  // 默认参数
  let info = (
    (
      title: ("基于 Typst 的太原理工大学论文模板", "非官方版本"),
      session: "20XX",
      student-id: "1001011010",
      author: "张三",
      class: "XX班",
      department: "XX学院",
      major: "XX专业",
      supervisor: ("李四", "讲师"),
      submit-date: datetime.today(),
    )
      + info
  )


  // 处理参数
  if type(info.title) == str {
    info.title = info.title.split("\n")
  }
  assert(type(info.submit-date) == datetime, message: "submit-date must be datetime.")

  let info-key(body, is-meta: true) = {
    set text(
      font: if is-meta { ("Times New Roman", "KaiTi") } else { ("Times New Roman", "SimHei") },
      size: zh(3),
    )
    rect(
      width: 100%,
      inset: info-inset,
      stroke: none,
      justify-text(with-tail: is-meta, body),
    )
  }

  let info-value(key, body, is-meta: false, no-stroke: false) = {
    set align(center)
    rect(
      width: 100%,
      inset: info-inset,
      stroke: if no-stroke { none } else { (bottom: stroke-width + black) },
      text(
        font: if is-meta { ("Times New Roman", "KaiTi") } else { ("Times New Roman", "SimHei") },
        bottom-edge: "descender",
        size: zh(3),
        if anonymous and (key in anonymous-info-keys) {
          if is-meta { "█████" } else { "██████████" }
        } else {
          body
        },
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

  let anonymous-text(key, body) = {
    if anonymous and (key in anonymous-info-keys) {
      "██████████"
    } else {
      body
    }
  }

  // 正式渲染
  show: show-cn-fakebold
  pagebreak(weak: true, to: if twoside { "odd" })

  set align(center)

  if anonymous {
    v(267pt - 3.3cm)
  } else {
    v(130pt - 3.3cm)
    image("../assets/tyut-logo.jpg", width: 12.11cm)
    v(2pt)
  }

  text(
    size: 30pt,
    font: ("Times New Roman", "KaiTi"),
    weight: "bold",
  )[#underline[#info.session]届本科生毕业设计（论文）]

  v(80pt)
  text(size: zh(-1), font: ("Times New Roman", "SimHei"), weight: "bold", info.title.join("\n"))
  v(30pt)

  block(
    width: 318pt,
    grid(
      columns: (info-key-width, 1fr, info-key-width, 1fr),
      column-gutter: column-gutter,
      row-gutter: row-gutter,
      info-key("学号"),
      info-long-value("student-id", info.student-id),
      info-key("姓名"),
      info-long-value("author", info.author),

      info-key("学院"),
      info-long-value("department", info.department),
      info-key("专业"),
      info-long-value("major", info.major),

      info-key("班级"),
      info-long-value("class", info.class),
      info-key("指导教师"),
      info-long-value("supervisor", info.supervisor.join([#h(1cm)])),
    ),
  )

  v(40pt)
  text(
    font: ("Times New Roman", "KaiTi"),
    size: zh(3),
    "完成日期：" + info.submit-date.display("[year]年[month padding:none]月"),
  )
}
