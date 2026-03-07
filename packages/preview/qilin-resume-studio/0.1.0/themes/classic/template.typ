// ─────────────────────────────────────────────────────────
//  导入模块化协议
// ─────────────────────────────────────────────────────────

#import "../module-core.typ": (
  contact-value, markup, render-contacts, render-dict-item, resume-info-extras, standard-modules,
)

// ─────────────────────────────────────────────────────────
//  辅助函数
// ─────────────────────────────────────────────────────────

#let delimiter = " | "

#let array-to-str(a, delimiter: delimiter) = {
  a.join(delimiter)
}

#let resume-date(start, end: "") = {
  if start == "" and end == "" {
    ""
  } else {
    start + " " + "–" + " " + end
  }
}


// ─────────────────────────────────────────────────────────
//  简历块级元素
// ─────────────────────────────────────────────────────────

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
}

// ─────────────────────────────────────────────────────────
//  主题入口函数
// ─────────────────────────────────────────────────────────

#let blueprint(
  data: (:),
  body,
) = {
  // 获取所有模块（使用模块化协议）
  let modules = standard-modules(data)

  // 提取个人信息用于头部渲染
  let resume-info = data.at("resume-info", default: (:))
  let name = resume-info.at("name", default: "未命名")
  let contacts = resume-info.at("contacts", default: ())

  // 主题字体配置
  let fonts-theme = ("Heiti SC", "Heiti SC")

  // 页面和文字样式设置
  set document(author: name, title: name + " 的简历")
  set page(margin: (x: 1cm, y: 1cm))
  set text(font: fonts-theme, lang: "zh")

  // ─────────────────────────────────────────────────────────
  //  简历头部
  // ─────────────────────────────────────────────────────────

  // 姓名
  align(center)[
    #block(text(weight: 700, 1.7em, name))
  ]

  // 联系方式
  if contacts.len() > 0 {
    set align(center)
    render-contacts(contacts, delimiter: [  |  ])
    v(0.3em)
  }

  // ─────────────────────────────────────────────────────────
  //  简历信息扩展字段
  // ─────────────────────────────────────────────────────────

  let extras = resume-info-extras(resume-info)

  set par(justify: true)

  // ─────────────────────────────────────────────────────────
  //  简历内容（模块化渲染）
  // ─────────────────────────────────────────────────────────

  for module in modules {
    if module.id == "resume-info" {
      // resume-info 已经在头部渲染，跳过
      continue
    } else if module.id == "education" {
      // 教育经历
      resume-section(module.title)
      for edu in module.payload {
        resume-education(
          university: edu.school,
          degree: edu.degree,
          school: edu.major,
          start: edu.start,
          end: edu.end,
        )[
          #let details = edu.at("details", default: ())
          #if details.len() > 0 {
            list(..details.map(d => markup(d)))
          }
        ]
      }
    } else if module.id == "experience" {
      // 工作经历
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
      }
    } else if module.id == "projects" {
      // 项目经历
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
      }
    } else if module.id == "skills" {
      // 个人技能
      resume-section(module.title)
      list(..module.payload.map(skill => markup(skill)))
    } else {
      // 自定义模块（通用处理）
      resume-section(module.title)
      if type(module.payload) == array {
        list(..module.payload.map(item => {
          if type(item) == str {
            [#item]
          } else if type(item) == dictionary {
            render-dict-item(item)
          } else {
            [#str(item)]
          }
        }))
      } else if type(module.payload) == str {
        [#markup(module.payload)]
      } else {
        module.payload
      }
    }
  }

  // ─────────────────────────────────────────────────────────
  //  resume-info 扩展字段（放在简历尾部）
  // ─────────────────────────────────────────────────────────

  if extras.summary != "" {
    resume-section("个人简介")
    [#markup(extras.summary)]
  }

  if extras.self-evaluation != "" {
    resume-section("自我评价")
    [#markup(extras.self-evaluation)]
  }

  if extras.interests.len() > 0 {
    resume-section("兴趣爱好")
    [#extras.interests.join("、")]
  }

  body
}
