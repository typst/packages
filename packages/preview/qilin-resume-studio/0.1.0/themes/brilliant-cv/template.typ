// ══════════════════════════════════════════════════
// 简化的蓝色主题样式（模仿 brilliant-cv）
// ══════════════════════════════════════════════════

// 颜色定义
#let accent-color = rgb("#0395DE")  // skyblue
#let lightgray = rgb("#343a40")
#let darkgray = rgb("#212529")

#import "../module-core.typ": render-contacts

// 分隔符
#let h-bar() = [#h(5pt) | #h(5pt)]

// ──────────────────────────────────────────────────
// 头部样式（支持头像）
// ──────────────────────────────────────────────────
#let make-header(resume-info, avatar: none) = {
  let name = resume-info.at("name", default: "")
  let contacts = resume-info.at("contacts", default: ())

  let name-info = {
    // 姓名样式（显示完整名字）
    text(
      font: "Heiti SC",
      size: 32pt,
      weight: "bold",
      fill: darkgray,
      name,
    )

    v(6pt)

    // 个人信息
    text(size: 10pt, fill: accent-color, render-contacts(contacts, delimiter: h-bar()))
  }

  if avatar != none {
    // 有头像时使用表格布局
    table(
      columns: (1fr, auto),
      inset: 0pt,
      stroke: none,
      column-gutter: 15pt,
      align: (left, top),
      name-info,
      {
        set image(height: 2.8cm)
        v(-0.6cm)
        box(avatar, radius: 8pt, clip: true)
      },
    )
  } else {
    // 无头像时直接显示姓名和信息
    name-info
  }
}

// ──────────────────────────────────────────────────
// 章节标题（前3个字母用蓝色高亮）
// ──────────────────────────────────────────────────
#let cv-section(title) = {
  v(1pt)
  text(size: 16pt, weight: "bold", fill: accent-color, title)
  h(2pt)
  box(width: 1fr, line(stroke: 0.9pt, length: 100%))
}

// ──────────────────────────────────────────────────
// 条目样式（日期用蓝色斜体）
// ──────────────────────────────────────────────────
#let cv-entry(
  title: "",
  society: "",
  date: "",
  location: "",
  description: none,
) = {
  v(1pt)

  table(
    columns: (1fr, 17em),
    inset: 0pt,
    stroke: 0pt,
    gutter: 6pt,
    align: (left, right),
    // 左列：标题和公司
    table(
      columns: 1fr,
      inset: 0pt,
      stroke: 0pt,
      row-gutter: 6pt,
      text(size: 10pt, weight: "bold", title),
      text(size: 8pt, fill: accent-color, weight: "medium", smallcaps(society)),
    ),
    // 右列：日期
    table(
      columns: 1fr,
      inset: 0pt,
      stroke: 0pt,
      row-gutter: 6pt,
      align: right,
      text(weight: "medium", fill: accent-color, style: "oblique", date),
      if location != "" {
        text(size: 8pt, weight: "medium", fill: gray, style: "oblique", location)
      } else {
        []
      },
    ),
  )

  // 描述
  if description != none and description != [] {
    v(1pt)
    text(fill: lightgray, description)
  }
}

// ──────────────────────────────────────────────────
// 荣誉/证书条目（一行显示）
// ──────────────────────────────────────────────────
#let cv-honor(date: "", title: "", issuer: "") = {
  v(1pt)
  table(
    columns: (auto, 1fr, auto),
    inset: 0pt,
    stroke: 0pt,
    gutter: 6pt,
    text(size: 9pt, weight: "bold", fill: accent-color, date),
    text(size: 9pt, weight: "medium", title),
    text(size: 9pt, fill: lightgray, style: "italic", issuer),
  )
}

// ──────────────────────────────────────────────────
// 技能条目
// ──────────────────────────────────────────────────
#let cv-skill(type: "", info: "") = {
  v(1pt)
  table(
    columns: (16%, 1fr),
    inset: 0pt,
    stroke: 0pt,
    gutter: 6pt,
    text(size: 9pt, weight: "bold", fill: accent-color, type), text(size: 9pt, info),
  )
}

// ══════════════════════════════════════════════════
// 主模板函数
// ══════════════════════════════════════════════════
#let blueprint(data: (:), body) = {
  // ── 提取数据 ──────────────────────────────────────
  let resume-info = data.at("resume-info", default: (:))
  let raw-edu = data.at("education", default: ())
  let education = if type(raw-edu) == dictionary { raw-edu.at("items", default: ()) } else { raw-edu }
  let raw-exp = data.at("experience", default: ())
  let experience = if type(raw-exp) == dictionary { raw-exp.at("items", default: ()) } else { raw-exp }
  let raw-proj = data.at("projects", default: ())
  let projects = if type(raw-proj) == dictionary { raw-proj.at("items", default: ()) } else { raw-proj }
  let raw-intern = data.at("internship", default: ())
  let internship = if type(raw-intern) == dictionary { raw-intern.at("items", default: ()) } else { raw-intern }
  let raw-certs = data.at("certificates", default: ())
  let certificates = if type(raw-certs) == dictionary { raw-certs.at("items", default: ()) } else { raw-certs }
  let raw-skills = data.at("skills", default: ())
  let skills = if type(raw-skills) == dictionary { raw-skills.at("items", default: ()) } else { raw-skills }

  // 提取头像路径
  let avatar-path = resume-info.at("avatar", default: none)
  let avatar-image = if avatar-path != none and avatar-path != "" {
    image(avatar-path)
  } else {
    none
  }

  // ── 页面设置 ──────────────────────────────────────
  set text(
    font: ("Heiti SC", "Songti SC"),
    size: 9pt,
    fill: lightgray,
  )
  set page(
    paper: "a4",
    margin: (left: 1.4cm, right: 1.4cm, top: 1cm, bottom: 1cm),
  )
  set par(justify: true)

  // ── 头部 ──────────────────────────────────────────
  make-header(resume-info, avatar: avatar-image)
  v(8pt)

  // ══════════════════════════════════════════════════
  // resume-info 扩展字段
  // ══════════════════════════════════════════════════
  let extra-items = ()
  for (key, label) in (("gender", "性别"), ("species", "种类"), ("birthday", "生日"), ("city", "城市")) {
    let val = resume-info.at(key, default: "")
    if val != "" { extra-items.push(label + "：" + str(val)) }
  }
  if extra-items.len() > 0 {
    text(size: 9pt, fill: accent-color, extra-items.join(h-bar()))
    v(4pt)
  }

  let motto = resume-info.at("motto", default: "")
  if motto != "" {
    text(size: 9pt, style: "italic", fill: lightgray)[\"#motto\"]
    v(6pt)
  }

  let summary = resume-info.at("summary", default: "")
  if summary != "" {
    cv-section("个人简介")
    text(size: 9pt, fill: lightgray, summary)
    v(4pt)
  }

  // ══════════════════════════════════════════════════
  // 教育经历
  // ══════════════════════════════════════════════════
  if education.len() > 0 {
    cv-section("教育经历")
    for edu in education {
      cv-entry(
        title: edu.at("degree", default: ""),
        society: edu.at("school", default: ""),
        date: edu.at("start", default: "") + " - " + edu.at("end", default: ""),
        description: if edu.at("details", default: ()).len() > 0 {
          list(..edu.at("details", default: ()))
        },
      )
    }
  }

  // ══════════════════════════════════════════════════
  // 职业经历 & 实习经历
  // ══════════════════════════════════════════════════
  if experience.len() > 0 {
    cv-section("职业经历")
    for exp in experience {
      cv-entry(
        title: exp.at("position", default: exp.at("role", default: "")),
        society: exp.at("company", default: exp.at("name", default: "")),
        date: exp.at("start", default: "") + " - " + exp.at("end", default: ""),
        description: if exp.at("details", default: ()).len() > 0 {
          list(..exp.at("details", default: ()))
        },
      )
    }
  }

  if internship.len() > 0 {
    cv-section("实习经历")
    for exp in internship {
      cv-entry(
        title: exp.at("position", default: exp.at("role", default: "")),
        society: exp.at("company", default: exp.at("name", default: "")),
        date: exp.at("start", default: "") + " - " + exp.at("end", default: ""),
        description: if exp.at("details", default: ()).len() > 0 {
          list(..exp.at("details", default: ()))
        },
      )
    }
  }

  // ══════════════════════════════════════════════════
  // 项目与协会
  // ══════════════════════════════════════════════════
  if projects.len() > 0 {
    cv-section("项目与协会")
    for proj in projects {
      cv-entry(
        title: proj.at("role", default: ""),
        society: proj.at("name", default: ""),
        date: proj.at("start", default: "") + " - " + proj.at("end", default: ""),
        description: if proj.at("details", default: ()).len() > 0 {
          list(..proj.at("details", default: ()))
        },
      )
    }
  }


  // ══════════════════════════════════════════════════
  // 证书
  // ══════════════════════════════════════════════════
  if certificates.len() > 0 {
    cv-section("证书")
    for cert in certificates {
      if type(cert) == dictionary {
        cv-honor(
          date: cert.at("date", default: ""),
          title: cert.at("name", default: cert.at("title", default: "")),
          issuer: cert.at("org", default: cert.at("issuer", default: "")),
        )
      } else {
        cv-honor(
          date: "",
          title: str(cert),
          issuer: "",
        )
      }
    }
  }

  // ══════════════════════════════════════════════════
  // 技能与兴趣
  // ══════════════════════════════════════════════════
  if skills.len() > 0 {
    cv-section("技能与兴趣")
    for skill in skills {
      if type(skill) == dictionary {
        // 支持 name/level/description 格式
        let name = skill.at("name", default: "")
        if name != "" {
          let level = skill.at("level", default: "")
          let description = skill.at("description", default: "")
          cv-skill(
            type: name + (if level != "" { " (" + level + ")" } else { "" }),
            info: description,
          )
        } else {
          // 支持 category/items 格式
          let category = skill.at("category", default: "")
          let items = skill.at("items", default: ())
          if items.len() > 0 {
            cv-skill(
              type: category,
              info: items.join(h-bar()),
            )
          }
        }
      } else if type(skill) == str {
        cv-skill(type: "", info: skill)
      }
    }
  }

  // ══════════════════════════════════════════════════
  // 荣誉奖项
  // ══════════════════════════════════════════════════
  let raw-awards = data.at("awards", default: ())
  let awards = if type(raw-awards) == dictionary { raw-awards.at("items", default: ()) } else { raw-awards }
  if awards.len() > 0 {
    cv-section("荣誉奖项")
    for award in awards {
      if type(award) == dictionary {
        cv-honor(
          date: award.at("date", default: ""),
          title: award.at("title", default: ""),
          issuer: "",
        )
      } else {
        cv-honor(date: "", title: str(award), issuer: "")
      }
    }
  }

  // ══════════════════════════════════════════════════
  // resume-info 扩展字段（尾部）
  // ══════════════════════════════════════════════════
  let self-evaluation = resume-info.at("self-evaluation", default: "")
  if self-evaluation != "" {
    cv-section("自我评价")
    text(size: 9pt, fill: lightgray, self-evaluation)
    v(4pt)
  }

  let interests = resume-info.at("interests", default: ())
  if interests.len() > 0 {
    cv-section("兴趣爱好")
    text(size: 9pt, fill: lightgray, interests.join("、"))
    v(4pt)
  }

  body
}


