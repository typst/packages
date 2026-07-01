#import "@preview/nerd-icons:0.2.0": nf-icon

// 简历样式配置

#let setup-styles(
  accent-color: rgb("#179299"),
  background-color: rgb("#ffffff"),
  sans-serif-font: ("Noto Sans CJK SC", "Source Han Sans SC"),
  serif-font: ("Noto Serif CJK SC", "Source Han Serif SC"),
  alt-font: ("Noto Sans CJK SC", "Source Han Sans SC"),
  font-size: 11pt,
  element-spaciness: 1.00,
  separator: " · ",
) = {
  let resume-header(
    author: "",
    profile-image: none,
    basic-info: (),
    telephone: "",
    email: "",
    wechat-id: "",
    github-id: "",
    other-link: "",
    location: "",
    body,
  ) = {
    set document(
      author: author,
      title: author + "-个人简历",
      date: datetime.today(),
    )

    // 基础样式
    set page(
      margin: (x: 1.2cm * element-spaciness, y: 1.2cm * element-spaciness), // 页边距
      fill: background-color, // 页面背景色
    )
    set par(
      justify: true,
      leading: 0.5em * element-spaciness, // 行距
      spacing: 0.9em * element-spaciness, // 段间距
    )
    set text(
      font: ( // 修一下中文字体里的全角符号
        (name: "New Computer Modern", covers: regex("•")),
        serif-font,
      ).flatten(),
      lang: "zh",
      size: font-size,     // 全局字号
      ligatures: false,
    )

    // 链接和强调样式
    show link: underline
    show emph: underline
    show link: set text(fill: accent-color)
    show strong: set text(fill: accent-color)
    show emph: set text(weight: "black")

    // 小节标题样式 带横线
    show heading: it => {
      text(
        font: sans-serif-font,
        it.body,
      )
      v(-1.0em)
      line(
        length: 100%,
        stroke: (paint: luma(40%), thickness: 1.5pt, cap: "round"),
      )
    }

    // 生成联系方式内容
    let contacts = ()
    if telephone != "" {
      contacts.push([#nf-icon("nf-md-phone_in_talk") #h(0.2em) #telephone])
    }
    if wechat-id != "" {
      contacts.push([#nf-icon("nf-fa-wechat") #h(0.2em) #wechat-id])
    }
    if email != "" {
      contacts.push([
        #h(0.1em)
        #nf-icon("nf-fa-envelope")
        #h(0.2em)
        #link("mailto:" + email)[#email]
      ])
    }
    if github-id != "" {
      contacts.push({
        h(0.2em)
        nf-icon("nf-md-github")
        h(0.2em)
        link("https://github.com/" + github-id, "github.com/" + github-id)
      })
    }
    if other-link != "" {
      contacts.push([#nf-icon("nf-fa-link") #h(0.2em) #link(other-link, other-link)])
    }
    if location != "" {
      contacts.push([#nf-icon("nf-fa-location_dot") #h(0.2em) #location])
    }

    // 右上角图像
    if profile-image != none {
      let header-height = 3em + 2.1em * element-spaciness
      if basic-info.len() > 0 {
        header-height += 1em + 0.5em * element-spaciness
      }
      context {
        let target-height = measure(block(height: header-height)[]).height
        let image-size = measure(profile-image)
        let scale-factor = if image-size.height == 0pt {
          100%
        } else {
          ((target-height / 1pt) / (image-size.height / 1pt)) * 100%
        }

        place(
          top + right,
          dx: -0.5em,
          scale(
            x: scale-factor,
            y: scale-factor,
            origin: top + right,
            profile-image,
          ),
        )
      }
    }
    // 标题和基础信息
    block(
      height: auto,
      width: 100%,
      inset: 0.5em,
      {
        text(font: sans-serif-font, weight: 700, 2.0em, author)
        linebreak()
        v(0.2em * element-spaciness)
        if basic-info.len() > 0 {
          basic-info.join(separator)
          linebreak()
        }
        contacts.join(separator)
      },
    )

    body
  }

  let resume-entry(
    title: "简历事项",
    subtitle: "",
    date: "",
    body,
  ) = {
    // 条目首行
    strong(text(title, font: sans-serif-font))
    if subtitle != "" {
      text(font: alt-font, separator + subtitle)
    }
    if date != "" {
      h(1fr)
      text(font: alt-font, date)
    }

    // 条目详细内容
    if body != [] {
      linebreak()
      v(-0.4em * element-spaciness) // 取消段间距
      block(
        height: auto,
        width: 100%,
        inset: (right: 0.5em, y: 0em),
        body,
      )
    }
  }

  (
    resume-header: resume-header,
    resume-entry: resume-entry,
  )
}

#let (resume-header, resume-entry) = setup-styles()
