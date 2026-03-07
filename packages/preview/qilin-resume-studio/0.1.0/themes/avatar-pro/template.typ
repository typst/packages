// ─────────────────────────────────────────────────────────
//  导入模块化协议
// ─────────────────────────────────────────────────────────

#import "../module-core.typ": markup, render-contacts, render-dict-item, resume-info-extras, standard-modules

// ─────────────────────────────────────────────────────────
//  辅助函数
// ─────────────────────────────────────────────────────────

#let delimiter = " | "

#let resume-date(start, end: "") = {
  if start == "" and end == "" {
    ""
  } else if end == "" {
    start
  } else {
    start + " - " + end
  }
}

// ─────────────────────────────────────────────────────────
//  简历块级元素
// ─────────────────────────────────────────────────────────

#let resume-item-header(date: "", title: "", subtitle: "") = {
  grid(
    columns: (1.5fr, 3fr, 2fr),
    align: (left, center, right),
    strong(date), strong(title), strong(subtitle),
  )
}

#let resume-education(university: "", degree: "", major: "", start: "", end: "", body) = {
  let date = resume-date(start, end: end)
  let subtitle = if major != "" { major + " - " + degree } else { degree }

  resume-item-header(date: date, title: university, subtitle: subtitle)
  v(0.3em)
  body
}

#let resume-work(company: "", duty: "", start: "", end: "", body) = {
  let date = resume-date(start, end: end)

  resume-item-header(date: date, title: company, subtitle: duty)
  v(0.3em)
  body
}

#let resume-project(title: "", duty: "", start: "", end: "", body) = {
  let date = resume-date(start, end: end)

  resume-item-header(date: date, title: title, subtitle: duty)
  v(0.3em)
  body
}

#let resume-section(title) = {
  v(0.8em)
  text(size: 11pt, weight: "bold", fill: black, title)
  v(-0.6em)
  line(length: 100%, stroke: 0.8pt + black)
  v(0.2em)
}

// ─────────────────────────────────────────────────────────
//  主题入口函数
// ─────────────────────────────────────────────────────────

#let blueprint(
  data: (:),
  body,
) = {
  let modules = standard-modules(data)

  let resume-info = data.at("resume-info", default: (:))
  let name = resume-info.at("name", default: "未命名")
  let avatar = resume-info.at("avatar", default: "")
  let contacts = resume-info.at("contacts", default: ())

  let fonts-theme = ("Times New Roman", "Heiti SC", "PingFang SC")

  set document(author: name, title: name + " 的简历")
  set page(margin: (x: 1.5cm, y: 1.5cm))
  set text(font: fonts-theme, lang: "zh", size: 9.5pt, fill: rgb("#3a3a3a"))
  set par(justify: true)

  set list(indent: 0.5em, body-indent: 0.5em)
  show list: set block(spacing: 0.5em)
  show strong: set text(fill: black)

  // ─────────────────────────────────────────────────────────
  //  简历头部
  // ─────────────────────────────────────────────────────────

  block(width: 100%, height: auto)[
    #if avatar != "" [
      #place(top + right, dx: 0cm, dy: -0.5cm)[
        #image(avatar, width: 2.2cm, height: 3cm, fit: "cover")
      ]
    ]
    #align(center)[
      #v(0.5em)
      #text(weight: 700, size: 16pt, fill: black, name)
      #v(0.8em)

      #if contacts.len() > 0 {
        text(size: 9pt, fill: black)[#render-contacts(contacts, delimiter: [ #delimiter ], show-label: true)]
      }
    ]
    #v(1.2em)
  ]

  // ─────────────────────────────────────────────────────────
  //  简历信息扩展字段
  // ─────────────────────────────────────────────────────────

  let extras = resume-info-extras(resume-info)

  if extras.summary != "" {
    resume-section("个人简介")
    block(width: 100%, below: 0.5em)[#markup(extras.summary)]
    v(0.5em)
  }

  if extras.self-evaluation != "" {
    resume-section("自我评价")
    block(width: 100%, below: 0.5em)[#markup(extras.self-evaluation)]
    v(0.5em)
  }

  if extras.interests.len() > 0 {
    resume-section("兴趣爱好")
    block(width: 100%, below: 0.5em)[#extras.interests.join("、")]
    v(0.5em)
  }

  // ─────────────────────────────────────────────────────────
  //  简历内容（模块化渲染）
  // ─────────────────────────────────────────────────────────

  for module in modules {
    if module.id == "resume-info" {
      continue
    } else if module.id == "education" {
      resume-section(module.title)
      for edu in module.payload {
        resume-education(
          university: edu.school,
          degree: edu.degree,
          major: edu.major,
          start: edu.start,
          end: edu.end,
        )[
          #let details = edu.at("details", default: ())
          #if details.len() > 0 {
            for d in details {
              block(width: 100%, below: 0.5em)[#markup(d)]
            }
          }
        ]
        v(0.5em)
      }
    } else if module.id == "experience" {
      resume-section(module.title)
      for exp in module.payload {
        resume-work(
          company: exp.company,
          duty: exp.position,
          start: exp.start,
          end: exp.end,
        )[
          #let details = exp.at("details", default: ())
          #if details.len() > 0 {
            list(..details.map(d => markup(d)))
          }
        ]
        v(0.5em)
      }
    } else if module.id == "projects" {
      resume-section(module.title)
      for proj in module.payload {
        resume-project(
          title: proj.name,
          duty: proj.role,
          start: proj.start,
          end: proj.end,
        )[
          #let details = proj.at("details", default: ())
          #if details.len() > 0 {
            list(..details.map(d => markup(d)))
          }
        ]
        v(0.5em)
      }
    } else if module.id == "skills" {
      resume-section(module.title)
      for skill in module.payload {
        block(width: 100%, below: 0.5em)[#markup(skill)]
      }
      v(0.5em)
    } else {
      resume-section(module.title)
      if type(module.payload) == array {
        list(..module.payload.map(item => {
          if type(item) == str {
            [#markup(item)]
          } else if type(item) == dictionary {
            render-dict-item(item)
          } else {
            [#str(item)]
          }
        }))
      } else if type(module.payload) == str {
        block(width: 100%, below: 0.5em)[#markup(module.payload)]
      } else {
        module.payload
      }
      v(0.5em)
    }
  }

  body
}
