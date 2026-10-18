// ============================================================
// themes/upc/style.typ: UPC 核心样式
// 实现中国石油大学（华东）本科毕业设计论文排版规范
// ============================================================

#import "../../lib/fonts.typ"
#import "../../lib/utils.typ"
#import "../../lib/i18n.typ"
#import "colors.typ" as colors
#import "defaults.typ" as defaults

// ---- UPC 字体族（供本主题内复用） ----
#let upcsong = fonts.get-cjk-serif()
#let upchei = fonts.get-cjk-sans()
#let upckai = fonts.get-cjk-kai()
#let upcfang = fonts.get-cjk-fang()
#let body-fonts = upcsong + fonts.get-latin-fonts()
#let en-fonts = fonts.get-latin-fonts() + upcsong

// ---- 页眉页脚组件 ----
#let frontmatter-header = context {
  stack(
    dir: ttb,
    spacing: 0.3em,
    align(center, move(dy: -1pt, text(size: utils.wuhao, font: upckai, i18n.t("header-thesis")))),
    line(length: 100%, stroke: 0.4pt),
  )
}

#let mainmatter-header = context {
  let headings = query(heading.where(level: 1))
  let current-page = here().page()
  let relevant-headings = headings.filter(h => h.location().page() <= current-page)
  if relevant-headings.len() > 0 {
    let heading-text = relevant-headings.last()
    let ch-num = counter(heading.where(level: 1)).at(heading-text.location()).first()
    let title-text = heading-text.body
      stack(
        dir: ttb,
        spacing: 0.3em,
        align(center, move(dy: -1pt, text(size: utils.wuhao, font: upckai, "第 " + str(ch-num) + " 章" + h(0.5em) + title-text))),
        line(length: 100%, stroke: 0.4pt),
      )
  }
}

#let footer-content = context {
  align(center, text(size: utils.wuhao, font: upcsong, str(counter(page).at(here()).first())))
}

// ---- 切换到 mainmatter 样式 ----
// 必须以 show rule 形式使用（#show: setup-mainmatter），否则 set page 不会传播到后续内容。
#let setup-mainmatter(body) = {
  set page(
    header: mainmatter-header,
    footer: footer-content,
  )
  counter(page).update(1)
  body
}

// ---- 内部辅助：签名与日期栏（原创性声明 / 授权书共用） ----
#let _signature-block(author-label: [论文作者（签名）：#h(4em)], advisor-label: [指导教师确认（签名）：#h(4em)]) = {
  v(4 * utils.line-spacing-15)
  grid(
    columns: (1fr, 1fr),
    align(center, author-label),
    align(center, advisor-label),
  )
  v(1em)
  grid(
    columns: (1fr, 1fr),
    align(right, [#h(1em)年#h(1em)月#h(1em)日]),
    align(right, [#h(1em)年#h(1em)月#h(1em)日]),
  )
}

// ---- 内部辅助：摘要页（中英文共用） ----
#let _abstract-page(
  body,
  title: "",
  subtitle: "",
  heading-text: "",
  keywords: (),
  keyword-prefix: "",
  keyword-sep: "",
  title-font: upchei,
  title-weight: "regular",
  heading-weight: "regular",
  heading-font: upchei,
  par-indent: 2em,
  body-font: none,
) = {
  set page(header: frontmatter-header, footer: none)

  v(1 * utils.line-spacing-15)

  if title != "" {
    align(center, text(size: utils.xiaoer, weight: title-weight, font: title-font, title))
    if subtitle != "" {
      v(0.3 * utils.line-spacing-15)
      align(right, text(size: utils.xiaoer, weight: title-weight, font: title-font, [——#h(0.3em)] + subtitle))
    }
    v(0.5 * utils.line-spacing-15)
  }

  align(center, text(size: utils.sanhao, weight: heading-weight, font: heading-font, heading-text))
  v(0.5 * utils.line-spacing-15)

  if body-font != none {
    set text(font: body-font)
  }
  set par(first-line-indent: par-indent, leading: utils.line-spacing-15)
  body

  v(0.5 * utils.line-spacing-15)
  utils.fakebold(text(keyword-prefix))
  keywords.join(keyword-sep)

  pagebreak()
}

// ---- 样式应用函数 ----
#let apply(
  title: "",
  author: "",
  advisor: "",
  institute: defaults.institute,
  university: defaults.university,
  date: datetime.today(),
  language: "zh",
  body,
) = {
  // ---- 页面设置 ----
  // 边距由 lib/base.typ 统一设置，此处只负责页眉页脚
  set page(
    header: frontmatter-header,
    footer: none,
  )

  // ---- 正文字体已由 lib/base.typ 统一设置（宋体小四 + 西文回退）
  // 此处只定义 body-fonts 供局部覆盖（如 strong、目录）使用 ----
  let body-fonts = upcsong + fonts.get-latin-fonts()

  // ---- strong 使用宋体 + 伪粗体（与 LaTeX \textbf 一致）----
  show strong: it => utils.fakebold(text(font: body-fonts, it.body))

  // ---- 章节字体与间距 ----
  // 只对编号的一级标题（正文章节）强制分页，避免目录、致谢、参考文献等无编号标题产生空白页。
  show heading.where(level: 1): it => {
    if it.numbering != none {
      pagebreak()
    }
    set align(center)
    set text(size: utils.sanhao, font: upchei)
    v(0.5 * utils.line-spacing-15)
    it
    v(1.5 * utils.line-spacing-15)
  }

  show heading.where(level: 2): it => {
    set text(size: utils.sihao, font: upchei)
    v(9pt)
    it
    v(9pt)
  }

  show heading.where(level: 3): it => {
    set text(size: utils.xiaosi, font: upchei)
    v(9pt)
    it
    v(9pt)
  }

  // ---- 图表标题：五号宋体，格式为"图 1-1  标题" ----
  show figure.where(kind: image): set figure.caption(position: bottom)
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.caption: it => {
    set text(size: utils.wuhao, font: upcsong)
    it.supplement + " " + it.counter.display(it.numbering) + "  " + it.body
  }
  set figure(supplement: [图])
  show figure.where(kind: table): set figure(supplement: [表])

  // ---- 表格 figure 允许跨页（续表必需） ----
  show figure.where(kind: table): set block(breakable: true)

  // ---- 表格默认样式：居中、五号宋体 ----
  // 注意：不设置全局 stroke: none，以免 table.hline() 默认不可见。
  // 三线表请使用 three-line-table 辅助函数或在 table() 参数中显式指定 stroke: none。
  set table(align: center + horizon, inset: 6pt)
  show table.cell: set text(size: utils.wuhao, font: upcsong)

  // ---- 代码块样式：浅灰背景、小圆角、学术配色、行距调小 ----
  set raw(theme: "code-theme.tmTheme")
  show raw.where(block: true): it => block(
    fill: rgb("#f7f7f7"),
    inset: 8pt,
    radius: 2pt,
    width: 100%,
    it,
  )
  show raw: set par(leading: 12pt)
  show raw: set text(size: utils.xiaowu)

  // ---- 引用格式：只显示编号，保留超链接 ----
  show ref: it => {
    context {
      let targets = query(it.target)
      if targets.len() == 0 {
        set text(fill: colors.primary)
        it
      } else {
        let target = targets.first()
        if target.func() == math.equation {
          let nums = counter(math.equation).at(target.location())
          let is-app = utils.appendix-active.at(target.location())
          let result = if type(target.numbering) == str {
            numbering(target.numbering, ..nums)
          } else if is-app {
            let letter = utils.appendix-letter.at(target.location())
            str(letter) + str(nums.first())
          } else {
            let ch = counter(heading.where(level: 1)).at(target.location()).first()
            let num = nums.last()
            str(ch) + "-" + str(num)
          }
          link(it.target, result)
        } else if target.func() == figure {
          let nums = if target.kind == image {
            counter(figure.where(kind: image)).at(target.location())
          } else {
            counter(figure.where(kind: table)).at(target.location())
          }
          let is-app = utils.appendix-active.at(target.location())
          let result = if type(target.numbering) == str {
            numbering(target.numbering, ..nums)
          } else if is-app {
            let letter = utils.appendix-letter.at(target.location())
            str(letter) + str(nums.last())
          } else {
            let ch = counter(heading.where(level: 1)).at(target.location()).first()
            let num = nums.last()
            str(ch) + "-" + str(num)
          }
          link(it.target, result)
        } else {
          set text(fill: colors.primary)
          it
        }
      }
    }
  }

  // ---- 目录样式 ----
  // n 从 0 开始（0=一级、1=二级、2=三级）
  set outline(indent: n => if n == 0 { 0pt } else if n == 1 { 2em } else { 4em })
  set outline.entry(fill: box(width: 1fr, repeat[.]))
  show outline.entry: set text(font: upcsong, size: utils.xiaosi, weight: "regular")

  body
}

// ---- 中文摘要环境 ----
#let upcabstractcn(body, keywords: (), cn-title: "", cn-subtitle: "") = {
  _abstract-page(
    body,
    title: cn-title,
    subtitle: cn-subtitle,
    heading-text: [摘#h(1em)要],
    keywords: keywords,
    keyword-prefix: "关键词：",
    keyword-sep: "；",
    title-font: upchei,
    title-weight: "regular",
    heading-weight: "regular",
    heading-font: upchei,
    par-indent: 2em,
  )
}

// ---- 英文摘要环境 ----
#let upcabstracten(body, keywords: (), en-title: "", en-subtitle: "") = {
  _abstract-page(
    body,
    title: en-title,
    subtitle: en-subtitle,
    heading-text: "Abstract",
    keywords: keywords,
    keyword-prefix: "Keywords: ",
    keyword-sep: "; ",
    title-font: en-fonts,
    title-weight: "bold",
    heading-weight: "bold",
    heading-font: en-fonts,
    par-indent: 2em,
    body-font: en-fonts,
  )
}

// ---- 致谢环境 ----
#let upcacknowledgements(body) = {
  set page(header: frontmatter-header, footer: footer-content)

  heading(level: 1, numbering: none, outlined: true)[致#h(1em)谢]

  set par(first-line-indent: (amount: 2em, all: true), leading: utils.line-spacing-15)
  body
}

// ---- 原创性声明 ----
// 注意：页面设置（header/footer）由调用方统一控制，本函数只输出内容。
#let upcoriginality(title: "") = {
  v(1 * utils.line-spacing-15)
  align(center, text(size: utils.xiaosan, font: upchei, "学位论文原创性声明"))
  v(1 * utils.line-spacing-15)

  set par(leading: utils.line-spacing-15, first-line-indent: 2em)
  if title != "" {
    text[
      本人所提交的学位论文《#title》，是在导师的指导下，独立进行研究工作所取得的原创性成果。除文中已经注明引用的内容外，本论文不包含任何其他个人或集体已经发表或撰写过的研究成果。对本文的研究做出重要贡献的个人和集体，均已在文中标明。

      本声明的法律后果由本人承担。
    ]
  } else {
    text[
      本人郑重声明：所呈交的学位论文，是本人在导师的指导下，独立进行研究工作所取得的成果。除文中已经注明引用的内容外，本论文不含任何其他个人或集体已经发表或撰写过的作品成果。对本文的研究做出重要贡献的个人和集体，均已在文中以明确方式标明。本人完全意识到本声明的法律结果由本人承担。
    ]
  }

  _signature-block(
    author-label: [论文作者（签名）：#h(4em)],
    advisor-label: [指导教师确认（签名）：#h(4em)],
  )
}

// ---- 版权授权书 ----
// 注意：页面设置（header/footer）由调用方统一控制，本函数只输出内容。
#let upclicense() = {
  v(2 * utils.line-spacing-15)
  align(center, text(size: utils.xiaosan, font: upchei, "学位论文版权使用授权书"))
  v(1 * utils.line-spacing-15)

  set par(leading: utils.line-spacing-15, first-line-indent: 2em)
  text[
    本学位论文作者完全了解中国石油大学（华东）有权保留并向国家有关部门或机构送交学位论文的复印件和磁盘，允许论文被查阅和借阅。本人授权中国石油大学（华东）可以将学位论文的全部或部分内容编入有关数据库进行检索，可以采用影印、缩印或其它复制手段保存、汇编学位论文。
  ]

  _signature-block(
    author-label: [论文作者（签名）：#h(4em)],
    advisor-label: [指导教师（签名）：#h(4em)],
  )
}

// ---- 附录环境 ----
// 只负责关闭 heading 编号，不输出标题。标题由 thesis-upc.typ 手动控制。
#let appendix-env(body) = {
  utils.appendix-active.update(true)
  set heading(numbering: none)
  body
}

// ---- 单个附录章节环境 ----
// 重置图/表/公式计数器并设置带字母前缀的编号（如 A1、B2）。
// 用法：#appendix-section("A")[ ... ]
#let appendix-section(letter, body) = {
  utils.appendix-letter.update(letter)
  counter(figure.where(kind: image)).update(0)
  counter(figure.where(kind: table)).update(0)
  counter(math.equation).update(0)

  show figure.where(kind: image): set figure(numbering: (..nums) => {
    str(letter) + str(nums.pos().last())
  })
  show figure.where(kind: table): set figure(numbering: (..nums) => {
    str(letter) + str(nums.pos().last())
  })
  set math.equation(numbering: (..nums) => {
    "(" + str(letter) + str(nums.pos().first()) + ")"
  })

  body
}
