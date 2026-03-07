#import "../module-core.typ": markup, render-contact, render-dict-item, resume-info-extras, standard-modules

// ==========================================
// 提取原 PDF 核心配色
// ==========================================
#let color-primary = rgb("#1a5599")
#let color-dark = rgb("#123b6b")
#let color-light = rgb("#c9cee4")
#let color-gray = rgb("#666666")

// ==========================================
// 核心矢量组件: 重构标题背景使用方式
// ==========================================
#let section-title(title) = {
  v(0.6em)
  let total-h = 24pt
  let badge-w-base = 89.5pt

  context {
    let title-text = text(fill: white, size: 12pt, weight: "bold", tracking: 2pt, title)
    let title-size = measure(title-text)
    // 徽标区宽度仅按标题扩展，右侧轴线由独立细线补齐。
    let badge-w = calc.max(badge-w-base, title-size.width + 28pt)
    let line-w = 100% - badge-w + 1pt

    block(width: 100%, height: total-h, {
      // 左侧标题徽标使用固定 viewBox 的 SVG，并保持文本左对齐。
      place(top + left, image("svg/cv-section-title.svg", width: badge-w, height: total-h))
      // 右侧延长线单独绘制，保持原主题的轴线视觉。
      place(top + left, dx: badge-w - 1pt, dy: 17.5pt, rect(width: line-w, height: 0.9pt, fill: color-primary))

      place(top + left, dx: 10pt, dy: 3pt, title-text)
    })
  }
  v(0.2em)
}


// 经历头部排版
#let exp-header(left-text, mid-text, right-text) = {
  grid(
    columns: (auto, 1fr, auto),
    align: (left, left, right),
    text(size: 11pt, weight: "bold", left-text),
    pad(left: 1.2em, text(size: 10.5pt, fill: color-gray, mid-text)),
    text(size: 10.5pt, right-text),
  )
  v(0.3em)
}

// Section 块：包含标题和内容的完整区块
#let section-block(title, axis-x, section-notch-right-x, title-overlap, content) = {
  block(breakable: false, width: 100%)[
    // 标题部分，带左边距偏移
    #pad(left: axis-x + section-notch-right-x - title-overlap)[
      #section-title(title)
    ]

    // 内容部分
    #content
  ]
}

// ==========================================
// 主题入口函数
// ==========================================
#let blueprint(
  data: (:),
  body,
) = {
  let modules = standard-modules(data)
  let resume-info = data.at("resume-info", default: (:))
  let name = resume-info.at("name", default: "未命名")
  let avatar = resume-info.at("avatar", default: "")
  let contacts = resume-info.at("contacts", default: ())

  // 字体配置
  let fonts-theme = (
    "PingFang SC",
    "Hiragino Sans GB",
    "Heiti SC",
    "Songti SC",
    "Helvetica Neue",
    "Arial",
  )

  // 装饰元素定位参数
  let axis-x = -0.7cm
  let section-notch-right-x = 5.6pt
  let axis-w = 0.85pt

  // 页面设置（包含每页的装饰背景）
  set page(
    paper: "a4",
    margin: (left: 1.5cm, right: 1.2cm, top: 1.2cm, bottom: 1.2cm),
    background: context {
      let loc = here()

      // 第二页及之后显示顶部 banner
      if loc.page() > 1 {
        place(top + left, dx: 0cm, dy: 0cm, image("svg/cv-top-banner.svg", width: 210mm, height: 10pt))
      }

      // 左侧时间轴垂直轴线（每页都显示）
      // 第一页从 PERSONAL RESUME 和顶部 banner 下方开始，第二页及之后从顶部 banner 下方开始
      let axis-dy = if loc.page() == 1 { 2.2cm } else { 10pt }
      let axis-height = if loc.page() == 1 { 100% - 2.2cm } else { 100% - 10pt }

      place(top + left, dx: 1.5cm + axis-x + section-notch-right-x - axis-w / 2, dy: axis-dy, image(
        "svg/cv-timeline-axis.svg",
        width: axis-w,
        height: axis-height,
      ))

      // 底部全宽装饰条（每页都显示，铺满整页宽度）
      place(bottom + left, dx: 0cm, dy: 0cm, image("svg/cv-bottom-banner.svg", width: 210mm, height: 10pt))
    },
  )

  set text(
    font: fonts-theme,
    size: 10.5pt,
    fill: rgb("#222222"),
  )

  set par(justify: true, leading: 0.85em)
  set block(spacing: 0.85em)

  set list(
    marker: ("·", "◦"),
    body-indent: 0.6em,
    indent: 0em,
  )

  v(-0.4cm)

  // --- 个人主标题（第一页） ---
  pad(left: -0.6cm, text(
    font: "Arial",
    size: 26pt,
    fill: color-primary,
    weight: "bold",
    tracking: 1.5pt,
  )[PERSONAL RESUME])
  v(1em)

  // --- 顶部装饰条（仅第一页，在标题下方） ---
  pad(left: -1.5cm, right: -1.2cm, image("svg/cv-top-banner.svg", width: 210mm, height: 10pt))
  v(0.5em)

  // --- 个人信息区 ---
  grid(
    columns: (1fr, 85pt),
    [
      #text(size: 28pt, weight: "bold", tracking: 5pt, name)
      #v(1.2em)

      #set text(size: 10.5pt)
      #grid(
        columns: (5.5em, 1fr, 5.5em, 1fr),
        row-gutter: 1.4em,
        ..contacts
          .map(c => {
            let label-text = c.at("label", default: "")
            let chars = label-text.clusters()
            let justified = if chars.len() > 1 {
              box(width: 4.8em, chars.join(h(1fr))) + "："
            } else {
              label-text + "："
            }
            (
              text(fill: color-gray)[#justified],
              [#render-contact(c)],
            )
          })
          .flatten()
      )
    ],
    align(right)[
      #if avatar != "" and avatar != none {
        image(avatar, width: 80pt)
      } else {
        rect(width: 80pt, height: 105pt, fill: rgb("#F9F9F9"), stroke: 0.5pt + color-gray)[
          #align(center + horizon, text(fill: color-gray)[证件照])
        ]
      }
    ],
  )

  v(-0.6cm)

  // 简历信息扩展字段
  let extras = resume-info-extras(resume-info)

  // --- 5. 模块循环渲染 ---
  let title-overlap = 6pt

  for module in modules {
    if module.id == "resume-info" {
      continue
    }

    // 每个 section 作为独立的块来渲染
    section-block(module.title, axis-x, section-notch-right-x, title-overlap, {
      if module.id == "education" {
        for edu in module.payload {
          exp-header(edu.school, edu.degree + " " + edu.major, edu.start + " - " + edu.end)
          let details = edu.at("details", default: ())
          for d in details { list(markup(d)) }
          v(0.5em)
        }
      } else if module.id == "experience" or module.id == "internship" {
        for exp in module.payload {
          // 兼容两种字段命名：company/name, position/role
          let company = exp.at("company", default: exp.at("name", default: ""))
          let position = exp.at("position", default: exp.at("role", default: ""))
          exp-header(company, position, exp.start + " - " + exp.end)
          let details = exp.at("details", default: ())
          for d in details {
            if d.starts-with("-") or d.ends-with("：") {
              markup(d)
              v(-0.5em)
            } else {
              list(markup(d))
            }
          }
          v(0.5em)
        }
      } else if module.id == "projects" {
        for proj in module.payload {
          let proj-name = proj.name
          let github = proj.at("github", default: "")
          if github != "" {
            proj-name = link(github, proj-name)
          }
          exp-header(proj-name, proj.role, proj.start + " - " + proj.end)
          let details = proj.at("details", default: ())
          for d in details { list(markup(d)) }
          v(0.5em)
        }
      } else if module.id == "skills" {
        for skill in module.payload { list(markup(skill)) }
      } else if module.id == "awards" {
        for award in module.payload {
          grid(
            columns: (1fr, auto),
            markup(award.title), text(font: "Helvetica Neue", award.date),
          )
          v(0.4em)
        }
      } else if module.id == "certificates" {
        for cert in module.payload {
          grid(
            columns: (1fr, auto),
            [*#cert.at("name", default: "")* #if cert.at("org", default: "") != "" { [ — #cert.at("org", default: "")] }],
            text(font: "Helvetica Neue", cert.at("date", default: "")),
          )
          v(0.4em)
        }
      } else {
        if type(module.payload) == array {
          for item in module.payload {
            if type(item) == str {
              list(item)
            } else if type(item) == dictionary {
              list(render-dict-item(item))
            } else {
              list(str(item))
            }
          }
        } else if type(module.payload) == str {
          markup(module.payload)
        } else {
          module.payload
        }
      }
    })
  }

  // resume-info 扩展字段（放在简历尾部）
  let title-overlap = 6pt

  if extras.summary != "" {
    section-block("个人简介", axis-x, section-notch-right-x, title-overlap, {
      markup(extras.summary)
      v(0.5em)
    })
  }

  if extras.self-evaluation != "" {
    section-block("自我评价", axis-x, section-notch-right-x, title-overlap, {
      markup(extras.self-evaluation)
      v(0.5em)
    })
  }

  if extras.interests.len() > 0 {
    section-block("兴趣爱好", axis-x, section-notch-right-x, title-overlap, {
      [#extras.interests.join("、")]
      v(0.5em)
    })
  }

  body
}
