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

#let resume-section(title) = {
  v(0.8em)
  text(size: 13pt, weight: "bold", fill: black, title)
  v(-0.6em)
  line(length: 100%, stroke: 1.2pt + black)
  v(0.4em)
}

#let resume-item-header(title: "", subtitle: "", date: "") = {
  let left-part = if subtitle != "" {
    strong(title) + text(fill: black, weight: "regular")[#delimiter] + subtitle
  } else {
    strong(title)
  }

  grid(
    columns: (1fr, auto),
    align: (left, right),
    text(fill: black, size: 11pt, left-part), text(fill: black, size: 10.5pt, date),
  )
  v(0.4em)
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
  let contacts = resume-info.at("contacts", default: ())

  let fonts-theme = ("Times New Roman", "Heiti SC", "PingFang SC")

  set document(author: name, title: name + " 的简历")
  set page(margin: (x: 1.5cm, y: 1.5cm))
  set text(font: fonts-theme, lang: "zh", size: 10pt, fill: rgb("#3a3a3a"))
  set par(justify: true, leading: 0.65em)

  set list(indent: 0.5em, body-indent: 0.5em)
  show list: set block(spacing: 0.65em)
  show strong: set text(fill: black)

  // ─────────────────────────────────────────────────────────
  //  简历头部
  // ─────────────────────────────────────────────────────────

  align(center)[
    #text(weight: 700, size: 18pt, fill: black, name)
    #v(0.8em)

    #if contacts.len() > 0 {
      text(size: 10pt, fill: black)[#render-contacts(contacts, delimiter: [ #delimiter ], show-label: true)]
    }
  ]
  v(0.5em)

  // 简历信息扩展字段
  let extras = resume-info-extras(resume-info)


  // ─────────────────────────────────────────────────────────
  //  简历内容（模块化渲染）
  // ─────────────────────────────────────────────────────────

  for module in modules {
    if module.id == "resume-info" {
      continue
    } else if module.id == "education" {
      resume-section(module.title)
      for edu in module.payload {
        let title = edu.school
        let subtitle = if edu.major != "" { edu.major + " " + edu.degree } else { edu.degree }
        resume-item-header(
          title: title,
          subtitle: subtitle,
          date: resume-date(edu.start, end: edu.end),
        )
        let details = edu.at("details", default: ())
        if details.len() > 0 {
          block(width: 100%, below: 0.5em)[#markup(details.join("\n"))]
        }
        v(0.6em)
      }
    } else if module.id == "experience" {
      resume-section(module.title)
      for exp in module.payload {
        resume-item-header(
          title: exp.company,
          subtitle: exp.position,
          date: resume-date(exp.start, end: exp.end),
        )
        let details = exp.at("details", default: ())
        if details.len() > 0 {
          block(width: 100%, below: 0.5em)[#markup(details.join("\n"))]
        }
        v(0.6em)
      }
    } else if module.id == "projects" {
      resume-section(module.title)
      for proj in module.payload {
        resume-item-header(
          title: proj.name,
          subtitle: proj.role,
          date: resume-date(proj.start, end: proj.end),
        )
        let details = proj.at("details", default: ())
        if details.len() > 0 {
          block(width: 100%, below: 0.5em)[#markup(details.join("\n"))]
        }
        v(0.6em)
      }
    } else if module.id == "skills" {
      resume-section(module.title)
      block(width: 100%, below: 0.5em)[#markup(module.payload.join("\n"))]
      v(0.6em)
    } else {
      resume-section(module.title)
      if type(module.payload) == array {
        let texts = module.payload.map(item => {
          if type(item) == str {
            item
          } else if type(item) == dictionary {
            let title = item.at("title", default: item.at("name", default: ""))
            let desc = item.at("description", default: item.at("org", default: ""))
            let date = item.at("date", default: "")
            if title != "" {
              title + (if date != "" { " (" + date + ")" } else { "" }) + (if desc != "" { " — " + desc } else { "" })
            } else {
              str(item)
            }
          } else {
            str(item)
          }
        })
        block(width: 100%, below: 0.5em)[#markup(texts.join("\n"))]
      } else if type(module.payload) == str {
        block(width: 100%, below: 0.5em)[#markup(module.payload)]
      } else {
        module.payload
      }
      v(0.6em)
    }
  }

  // resume-info 扩展字段（放在简历尾部）
  if extras.summary != "" {
    resume-section("个人简介")
    block(width: 100%, below: 0.5em)[#markup(extras.summary)]
    v(0.6em)
  }

  if extras.self-evaluation != "" {
    resume-section("自我评价")
    block(width: 100%, below: 0.5em)[#markup(extras.self-evaluation)]
    v(0.6em)
  }

  if extras.interests.len() > 0 {
    resume-section("兴趣爱好")
    block(width: 100%, below: 0.5em)[#extras.interests.join("、")]
    v(0.6em)
  }

  body
}
