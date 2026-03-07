#import "../module-core.typ": extract-items, extract-title, render-contact

#let delimiter = " | "

#let array-to-str(a, delimiter: delimiter) = {
  a.join(delimiter)
}

#let resume-contacts(contact) = {
  set align(center)
  array-to-str(contact)
}

#let project(title: "", author: (), contacts: (), body) = {
  set document(author: author.name, title: title)
  set page(
    margin: (x: 1cm, y: 1cm),
  )

  set text(font: ("Times New Roman", "Heiti SC", "PingFang SC", "STHeiti"), lang: "zh")

  align(center)[
    #block(text(weight: 700, 1.7em, author.name))
  ]

  resume-contacts(contacts)

  set par(justify: true)

  body
}

#let format-date(date) = {
  if type(date) == datetime [date.display()] else if type(date) == str and date.len() == 0 [今] else if (
    type(date) == str
  ) {
    date
  } else {
    // todo panic
  }
}

#let resume-date(start, end: "") = {
  if start == "" and end == "" {
    ""
  } else {
    format-date(start) + " " + $dash.en$ + " " + format-date(end)
  }
}

#let resume-item(left: "", right: "", body) = {
  text(size: 12pt, place(end, right))
  text(size: 12pt, left)
  linebreak()
  body
}

#let resume-education(university: "", degree: "", school: "", start: "", end: "", body) = {
  let left = (strong(university), school, degree)
  let right = resume-date(start, end: end)

  resume-item(
    left: array-to-str(left),
    right: right,
    body,
  )
}

#let resume-work(company: "", duty: "", start: "", end: "", body) = {
  let left = (strong(company), duty)
  let right = resume-date(start, end: end)

  resume-item(
    left: array-to-str(left),
    right: right,
    body,
  )
}

#let resume-project(title: "", duty: "", start: "", end: "", body) = {
  let left = (strong(title), duty)
  let right = resume-date(start, end: end)

  resume-item(
    left: array-to-str(left),
    right: right,
    body,
  )
}

#let resume-section(title) = {
  v(-8pt)
  heading(level: 1, title)
  line(length: 100%)
  v(-2pt)
}

// ─────────────────────────────────────────────────────────────────────────────

#let blueprint(data: (:), body) = {
  let info = data.at("resume-info", default: (:))

  // Header Config
  let author-name = info.at("name", default: "冯开宇")

  // Process contacts
  let contacts = ()
  if "contacts" in info {
    for c in info.contacts {
      if type(c) == str {
        contacts.push(c)
      } else if type(c) == dictionary {
        contacts.push(render-contact(c))
      }
    }
  }

  show: project.with(
    title: data.at("title", default: "Resume"),
    author: (name: author-name),
    contacts: contacts,
  )

  // Education
  if "education" in data {
    let raw-edu = data.at("education", default: ())
    let edu-items = extract-items(raw-edu)
    let edu-title = extract-title(raw-edu, fallback: "教育经历")
    if edu-items.len() > 0 {
      resume-section(edu-title)
      for edu in edu-items {
        resume-education(
          university: edu.at("university", default: edu.at("school", default: "")),
          degree: edu.at("degree", default: ""),
          school: edu.at("school", default: edu.at("major", default: "")),
          start: edu.at("start", default: ""),
          end: edu.at("end", default: ""),
        )[
          #let details = edu.at("details", default: edu.at("description", default: ""))
          #if type(details) == str {
            eval(details, mode: "markup")
          } else if type(details) == array {
            for item in details {
              [- #eval(item, mode: "markup")]
            }
          }
        ]
      }
    }
  }

  // Skills
  if "skills" in data {
    let raw-skills = data.at("skills", default: ())
    let skill-items = extract-items(raw-skills)
    let skill-title = extract-title(raw-skills, fallback: "技术能力")
    if skill-items.len() > 0 {
      resume-section(skill-title)
      for s in skill-items {
        if type(s) == str {
          [- #eval(s, mode: "markup")]
        } else if type(s) == dictionary {
          // 支持 name/level/description 格式
          let name = s.at("name", default: "")
          if name != "" {
            let level = s.at("level", default: "")
            let description = s.at("description", default: "")
            let parts = (name,)
            if level != "" { parts.push(level) }
            if description != "" { parts.push(description) }
            [- #parts.join("：")]
          } else if "title" in s {
            [*#s.title:* ]
            if "items" in s {
              eval(s.items, mode: "markup")
            }
          }
        }
      }
    }
  }

  // Experience
  if "experience" in data {
    let raw-exp = data.at("experience", default: ())
    let exp-items = extract-items(raw-exp)
    let exp-title = extract-title(raw-exp, fallback: "工作经历")
    if exp-items.len() > 0 {
      resume-section(exp-title)
      for exp in exp-items {
        resume-work(
          company: exp.at("company", default: ""),
          duty: exp.at("duty", default: exp.at("position", default: "")),
          start: exp.at("start", default: ""),
          end: exp.at("end", default: ""),
        )[
          #let details = exp.at("details", default: exp.at("description", default: ""))
          #if type(details) == str {
            eval(details, mode: "markup")
          } else if type(details) == array {
            for item in details {
              [- #eval(item, mode: "markup")]
            }
          }
        ]
      }
    }
  }

  // Projects & Internship
  for section-key in ("projects", "internship") {
    if section-key in data {
      let raw-data = data.at(section-key, default: ())
      let items = extract-items(raw-data)
      let section-title = extract-title(raw-data, fallback: if section-key == "projects" { "项目经历" } else {
        "实习经历"
      })
      if items.len() > 0 {
        resume-section(section-title)
        for item in items {
          resume-project(
            title: item.at("title", default: item.at("name", default: "")),
            duty: item.at("duty", default: item.at("role", default: "")),
            start: item.at("start", default: ""),
            end: item.at("end", default: ""),
          )[
            #let details = item.at("details", default: item.at("description", default: ""))
            #if type(details) == str {
              eval(details, mode: "markup")
            } else if type(details) == array {
              for detail in details {
                [- #eval(detail, mode: "markup")]
              }
            }
          ]
        }
      }
    }
  }

  // Awards
  if "awards" in data {
    let raw-awards = data.at("awards", default: ())
    let award-items = extract-items(raw-awards)
    let award-title = extract-title(raw-awards, fallback: "荣誉奖项")
    if award-items.len() > 0 {
      resume-section(award-title)
      for award in award-items {
        if type(award) == str {
          [- #eval(award, mode: "markup")]
        } else if type(award) == dictionary {
          [
            - *#award.at("title", default: "")* #if award.at("date", default: "") != "" { [(#award.at("date", default: ""))] }
          ]
        }
      }
    }
  }

  // Certificates
  if "certificates" in data {
    let raw-certs = data.at("certificates", default: ())
    let cert-items = extract-items(raw-certs)
    let cert-title = extract-title(raw-certs, fallback: "资质证书")
    if cert-items.len() > 0 {
      resume-section(cert-title)
      for cert in cert-items {
        if type(cert) == dictionary {
          [
            - *#cert.at("name", default: "")* #if cert.at("date", default: "") != "" { [(#cert.at("date", default: ""))] } #if cert.at("org", default: "") != "" { [ — #cert.at("org", default: "")] }
          ]
        } else {
          [- #str(cert)]
        }
      }
    }
  }

  // resume-info 扩展字段
  if "resume-info" in data {
    let resume-info = data.at("resume-info", default: (:))

    let extra-items = ()
    for (key, label) in (("gender", "性别"), ("species", "种类"), ("birthday", "生日"), ("city", "城市")) {
      let val = resume-info.at(key, default: "")
      if val != "" { extra-items.push(label + "：" + str(val)) }
    }
    if extra-items.len() > 0 {
      resume-section("基本信息")
      [#extra-items.join("  |  ")]
    }

    let motto = resume-info.at("motto", default: "")
    if motto != "" {
      [\ _"#motto"_]
    }

    let summary = resume-info.at("summary", default: "")
    if summary != "" {
      resume-section("个人简介")
      [#summary]
    }

    let self-evaluation = resume-info.at("self-evaluation", default: "")
    if self-evaluation != "" {
      resume-section("自我评价")
      [#self-evaluation]
    }

    let interests = resume-info.at("interests", default: ())
    if interests.len() > 0 {
      resume-section("兴趣爱好")
      [#interests.join("、")]
    }
  }

  body
}
