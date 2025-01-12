#import "../utils/style.typ": 字号, 字体
#import "../utils/datetime-display.typ": datetime-display

#let design-cover(
  anonymous: false,
  twoside: false,
  fonts: (:),
  info: (:),
  stoke-width: 0.5pt,
  info-inset: (x: 0pt, bottom: 1pt),
  info-key-width: 72pt,
  info-key-font: "宋体",
  info-value-font: "宋体",
  column-gutter: -3pt,
  row-gutter: 22pt,
  anonymous-info-keys: ("grade", "student-id", "author", "supervisor", "supervisor-ii", "class"),
  bold-info-keys: (),
  bold-level: "bold",
) = {
  fonts = 字体 + fonts
  info = (
    title: "课程论文标题",
    grade: "2022",
    student-id: "12115990136",
    author: "刘抗非",
    department: "化学化工学院",
    major: "化学工程与工艺",
    class: "150103",
    supervisor: ("李四", "教授"),
    submit-date: datetime.today(),
  ) + info

  // 移除 title 的元组转换
  // if type(info.title) == str {
  //   info.title = (info.title,)
  // }

  info.submit-date = datetime-display(info.submit-date)

  let info-key(body) = {
    rect(
      width: 100%,
      inset: info-inset,
      stroke: none,
      text(
        font: fonts.at(info-key-font, default: "宋体"),
        size: 字号.三号,
        body
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
        font: fonts.at(info-value-font, default: "宋体"),
        size: 字号.三号,
        weight: if (key in bold-info-keys) { bold-level } else { "regular" },
        bottom-edge: "descender",
        {
          if type(body) == array {
            body.map(v => {
              if type(v) == str { [#v] } 
              else if type(v) == content { v }
              else { [#repr(v)] }
            }).join([#"\n"])
          } else if type(body) == str {
            [#body]
          } else if type(body) == content {
            body
          } else {
            [#repr(body)]
          }
        }
      )
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

  pagebreak(weak: true, to: if twoside { "odd" })

  set align(center)

  if anonymous {
    v(52pt)
  } else {
    v(25pt)
    image("../logos/3.svg", width: 14cm)
  }

  text(size: 字号.小初, font: fonts.黑体, spacing: 200%, weight: "bold")[课程论文]

  // 题目栏
  block(width: 400pt, {
    grid(
      columns: (55pt, 1fr),
      gutter: 0pt,
      align(left + bottom, text(font: fonts.at(info-key-font, default: "宋体"), size: 字号.一号)[题目]),
      align(bottom, info-value("title", info.title)
    ))
  })

  if anonymous {
    v(155pt)
  } else {
    v(85pt)
  }
  
  block(width: 300pt, grid(
    columns: (info-key-width, 1fr, info-key-width, 1fr),
    column-gutter: column-gutter,
    row-gutter: row-gutter,
    info-key("院　　系"),
    info-long-value("department", info.department),
    info-key("专　　业"),
    info-long-value("major", info.major),
    info-key("班　　级"),
    info-long-value("class", info.class),
    info-key("年　　级"),
    info-short-value("grade", info.grade),
    info-key("学　　号"),
    info-short-value("student-id", info.student-id),
    info-key("学生姓名"),
    info-long-value("author", info.author),
    info-key("指导教师"),
    info-short-value("supervisor", if type(info.supervisor) == array { info.supervisor.at(0, default: "") } else { info.supervisor }),
    info-key("职　　称"),
    info-short-value("supervisor", if type(info.supervisor) == array and info.supervisor.len() > 1 { info.supervisor.at(1) } else { "" }),
    ..(if "supervisor-ii" in info and type(info.supervisor-ii) == array and info.supervisor-ii.len() > 0 {(
      info-key("第二导师"),
      info-short-value("supervisor-ii", info.supervisor-ii.at(0, default: "")),
      info-key("职　　称"),
      info-short-value("supervisor-ii", info.supervisor-ii.at(1, default: "")),
    )} else {()}),
    info-key("提交日期"),
    info-long-value("submit-date", info.submit-date),
  ))
}
