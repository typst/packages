// ─────────────────────────────────────────────────────────
//  导入模块化协议
// ─────────────────────────────────────────────────────────

#import "../module-core.typ": markup, render-contacts, render-dict-item, resume-info-extras, standard-modules

// ─────────────────────────────────────────────────────────
//  图标定义（Font-based Unicode icons）
// ─────────────────────────────────────────────────────────

#let icon(symbol) = box(
  baseline: 0.125em,
  height: 1.2em,
  width: 1.2em,
  align(center + horizon, text(size: 0.95em, symbol)),
)

#let fa-home = icon("🏠")
#let fa-email = icon("✉")
#let fa-github = icon("🐙")
#let fa-linkedin = icon("💼")
#let fa-phone = icon("☎")
#let fa-weixin = icon("💬")


// ─────────────────────────────────────────────────────────
//  辅助函数
// ─────────────────────────────────────────────────────────

// 根据联系方式类型返回对应图标
#let contact-icon(t) = {
  if t == "email" { fa-email } else if t == "phone" { fa-phone } else if t == "github" { fa-github } else if (
    t == "linkedin"
  ) { fa-linkedin } else if t == "wechat" { fa-weixin } else { fa-home }
}

// 中文分隔线
#let chi-line() = {
  v(-3pt)
  line(length: 100%)
  v(-5pt)
}


// ─────────────────────────────────────────────────────────
//  简历块级元素
// ─────────────────────────────────────────────────────────

// 简历分隔线
#let resume-section(title) = {
  [== #title]
  chi-line()
}

// 简历条目（包含标题、职位、详情、时间）
#let resume-item(title: "", position: "", detail: "", time: "") = {
  grid(
    columns: (1fr, auto),
    [*#title*], [#time],
  )
  if position != "" {
    grid(
      columns: (1fr, auto),
      [#position], if detail != "" { [#detail] } else { [] },
    )
  }
  v(0.3em)
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
  let avatar = resume-info.at("avatar", default: "")
  let contacts = resume-info.at("contacts", default: ())

  // 主题字体配置
  let fonts-theme = ("Heiti SC", "Heiti SC")

  // 页面和文字样式设置
  set page(margin: (x: 0.9cm, y: 1.3cm), paper: "a4")
  set text(size: 11pt, font: fonts-theme, lang: "zh")
  show link: text
  set par(justify: true)
  set document(title: name + " 的简历", author: name)

  // ─────────────────────────────────────────────────────────
  //  简历头部
  // ─────────────────────────────────────────────────────────

  // 姓名
  align(center, text(style: "normal", weight: "extrabold", size: 20pt, name))

  // 头像（可选）
  if avatar != "" and avatar != none {
    place(top + right, dy: -2em, image(avatar, height: 33mm))
  }

  // 联系方式（带图标）
  if contacts.len() > 0 {
    align(
      center,
      render-contacts(contacts, delimiter: h(0.5em) + "·" + h(0.5em), icon-fn: c-type => box(
        height: 1em,
        contact-icon(c-type),
      )),
    )
  }
  v(0.5em)

  // ─────────────────────────────────────────────────────────
  //  简历信息扩展字段
  // ─────────────────────────────────────────────────────────

  let extras = resume-info-extras(resume-info)


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
        resume-item(
          title: edu.school,
          position: edu.degree,
          detail: edu.major,
          time: edu.start + " ~ " + edu.end,
        )
        let details = edu.at("details", default: ())
        if details.len() > 0 {
          list(..details.map(d => markup(d)))
        }
        v(0.2em)
      }
    } else if module.id == "experience" {
      // 工作经历
      resume-section(module.title)
      for exp in module.payload {
        resume-item(
          title: exp.company,
          position: exp.position,
          time: exp.start + " ~ " + exp.end,
        )
        let details = exp.at("details", default: ())
        if details.len() > 0 {
          list(..details.map(d => markup(d)))
        }
        v(0.2em)
      }
    } else if module.id == "projects" {
      // 项目经历
      resume-section(module.title)
      for proj in module.payload {
        resume-item(
          title: proj.name,
          position: proj.role,
          time: proj.start + " ~ " + proj.end,
        )
        let details = proj.at("details", default: ())
        if details.len() > 0 {
          list(..details.map(d => markup(d)))
        }
        v(0.2em)
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

  // resume-info 扩展字段（放在简历尾部）
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
