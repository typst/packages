// ============================================================
//  zhaji (札记) · 通用理工科与数学课程笔记 / 讲义模板
//  支持单课独立编译与全书合订编译，无冗余编号，纯视觉锚点分层
// ============================================================

// ---------- 全局状态（用于全书与单课环境解耦） ----------
#let __is_book = state("__is_book", false)

// ---------- 字体 ----------
// 正文：英数 New Computer Modern，中文回退到宋体 / 平方
#let font-text = ("New Computer Modern", "Songti SC", "PingFang SC")
// 标题：中文黑体，严肃醒目
#let font-head = ("Heiti SC", "PingFang SC", "New Computer Modern")
// 数学公式
#let font-math = ("New Computer Modern Math", "New Computer Modern")

// ---------- 页面用色 ----------
#let c-accent = rgb("#222222")
#let c-remark = rgb("#777777")
#let c-blue   = rgb("#3b5f82")
#let c-amber  = rgb("#96704a")
#let c-emph   = rgb("#b02a2a") // 醒目强调色（典雅朱红/红褐）

// ---------- 顶层页面与正文接管函数 ----------
#let note(
  title: "",               // 课程/文档标题（如 "常微分方程"、"实变函数"）
  subtitle: "课堂笔记",     // 副标题（全书封面使用，如设为 none 则不显示）
  author: "",              // 作者（可选）
  date: auto,              // 封面日期：auto（当天年月）、none（不显示）或自定义文本
  mode: "lesson",          // "lesson"（单课独立模式）或 "book"（全书合订模式）
  font-head: font-head,
  font-math: font-math,
  font-text: font-text,
  font-size: 10.8pt,
  lang: "zh",
  region: "cn",
  first-line-indent: 2em,
  leading: 0.86em,
  body,
) = {
  // 全局正文字体与段落规范（在顶层生效）
  set text(font: font-text, size: font-size, lang: lang, region: region)
  set par(justify: true, leading: leading, first-line-indent: first-line-indent)
  set math.equation(numbering: none)
  show math.equation: set text(font: font-math)
  show math.equation.where(block: false): it => it

  // 全局标题样式（免冗余数字编号，层级视觉对比极其分明）
  // Level 1: 大章 / 课程主题（底置主题色横线）
  show heading.where(level: 1): it => context block(width: 100%, above: 2.4em, below: calc.max(1.2em, par.spacing))[
    #set text(font: font-head, size: 20pt, weight: "bold", fill: c-accent)
    #it.body
    #v(0.35em)
    #line(length: 100%, stroke: 0.75pt + c-blue)
  ]

  // Level 2: 大节（左侧 3.5pt 蓝灰坚挺色标，上方充分留白，一眼认出新大节）
  show heading.where(level: 2): it => context block(width: 100%, above: 2.0em, below: calc.max(0.85em, par.leading))[
    #grid(
      columns: (auto, 1fr),
      gutter: 0.55em,
      align: (left + horizon, left + horizon),
      rect(width: 3.5pt, height: 1.15em, fill: c-blue, radius: 1pt),
      text(font: font-head, size: 15pt, weight: "bold", fill: c-accent)[#it.body],
    )
  ]

  // Level 3: 具体模型 / 核心课题（前置精致实心小方块，字号 12.5pt）
  show heading.where(level: 3): it => context block(above: 1.4em, below: calc.max(0.6em, par.leading))[
    // 因为 ■ 比 font-head 小了 4pt, 所以要上移 baseline 2pt，下同
    #text(fill: c-blue, size: 8.5pt, baseline: -2pt)[■]
    #h(0.45em)
    #text(font: font-head, size: 12.5pt, weight: "bold", fill: c-accent)[#it.body]
  ]

  // Level 4: 具体分析环节 / 步骤分支（11pt 黑体，前置优雅小短杠引领）
  show heading.where(level: 4): it => context block(above: 1.0em, below: calc.max(0.45em, par.leading))[
    // 因为c-remark 比 font-head 小了 2pt，所以要上移 baseline 1pt
    #text(fill: c-remark, size: 9pt, baseline: -1pt)[–]
    #h(0.35em)
    #text(font: font-head, size: 11pt, weight: "bold", fill: rgb("#444444"))[#it.body]
  ]

  if mode == "book" {
    __is_book.update(true)

    let doc-meta-title = if title != "" {
      title
    } else {
      "课程讲义与笔记"
    }

    set document(
      title: doc-meta-title,
      author: if author != "" { author } else { () },
    )

    // 1. 封面页：纯净无页眉页脚
    set page(
      paper: "a4",
      margin: (x: 2.55cm, top: 2.2cm, bottom: 2.25cm),
      header: none,
      footer: none,
    )

    let cover-title = if title != "" {
      title
    } else {
      context {
        let h1 = query(heading.where(level: 1))
        if h1.len() > 0 { h1.first().body } else { "课程笔记" }
      }
    }

    align(center + horizon)[
      #v(-2cm)
      #text(font: font-head, size: 28pt, weight: "bold")[#cover-title]
      #if subtitle != none and subtitle != "" [
        #v(1.2em)
        #text(font: font-text, size: 13.5pt, fill: c-remark)[#subtitle]
      ]
      #if author != "" [
        #v(2.5em)
        #text(font: font-text, size: 12pt, fill: c-accent)[#author]
      ]
      #v(5.5cm)
      #if date == auto [
        #text(font: font-text, size: 10pt, fill: c-remark)[
          #datetime.today().display("[year] 年 [month] 月")
        ]
      ] else if date != none and date != "" [
        #text(font: font-text, size: 10pt, fill: c-remark)[#date]
      ]
    ]
    pagebreak()

    // 2. 目录页（深度为 2：仅收录大章与大节，结构极其利落）
    outline(title: "目 录", depth: 2, indent: 1.5em)
    pagebreak()

    // 3. 正文页面：页眉放章节标题与横线，页码居中位于页脚
    set page(
      paper: "a4",
      margin: (x: 2.55cm, top: 2.2cm, bottom: 2.25cm),
      header: context {
        let p = counter(page).get().first()
        let on-page = query(heading).filter(h => counter(page).at(h.location()).first() == p)
        let before-page = query(selector(heading).before(here()))
        let cur = if on-page.len() > 0 { on-page.first() } else if before-page.len() > 0 { before-page.last() } else { none }
        let head-text = if cur != none {
          cur.body
        } else if title != "" {
          title
        } else {
          "课程笔记"
        }
        set text(font: font-head, size: 8.5pt, fill: c-remark)
        align(left)[#head-text]
        v(-0.6em)
        line(length: 100%, stroke: 0.4pt + luma(70%))
      },
      footer: context {
        align(center)[
          #set text(font: font-text, size: 8.5pt, fill: c-remark)
          #counter(page).display("1")
        ]
      },
    )
    counter(page).update(1)

    body
  } else {
    // 课时单课模式
    context {
      if __is_book.get() {
        // 全书模式下子文件直接放行正文，绝不重复调用 set page
        body
      } else {
        let hs2 = query(heading.where(level: 2))
        let hs1 = query(heading.where(level: 1))
        let running-title = if title != "" {
          title
        } else if hs2.len() > 0 {
          hs2.first().body
        } else if hs1.len() > 0 {
          hs1.first().body
        } else {
          "课堂笔记"
        }

        set document(
          title: running-title,
          author: if author != "" { author } else { () },
        )

        set page(
          paper: "a4",
          margin: (x: 2.55cm, top: 2.2cm, bottom: 2.25cm),
          header: {
            set text(font: font-head, size: 8.5pt, fill: c-remark)
            align(left)[#running-title]
            v(-0.6em)
            line(length: 100%, stroke: 0.4pt + luma(70%))
          },
          footer: context {
            align(center)[
              #set text(font: font-text, size: 8.5pt, fill: c-remark)
              #counter(page).display("1")
            ]
          },
        )

        body
      }
    }
  }
}

// ---------- 提示块：通用环境，同时支持标准中括号语法与旧式命名参数 ----------
#let hint(font-head: font-head, ..args) = {
  let pos = args.pos()
  let named = args.named()
  let style = named.at("style", default: "gray")
  let (title, body) = if pos.len() >= 2 {
    (pos.at(0), pos.at(1))
  } else if pos.len() == 1 {
    (named.at("title", default: none), pos.at(0))
  } else {
    (none, [])
  }
  let colors = (gray: rgb("#777777"), blue: rgb("#526b84"), amber: rgb("#96704a"))
  let border-color = colors.at(style, default: rgb("#777777"))

  block(
    breakable: true,
    width: 100%,
    inset: (x: 0.75em, y: 0.45em),
    stroke: (left: 1pt + border-color),
  )[
    #set par(first-line-indent: 0em, justify: true)
    #if title != none {
      text(font: font-head, weight: "regular", fill: c-accent)[#title]
      h(0.6em)
    }
    #body
  ]
}

// ---------- 极轻量语义宏（仅提供最少两项：定理、定义，无记忆负担） ----------
#let thm(..args) = {
  let pos = args.pos()
  let named = args.named()
  let (title, body) = if pos.len() >= 2 {
    (pos.at(0), pos.at(1))
  } else if pos.len() == 1 {
    (named.at("title", default: none), pos.at(0))
  } else {
    (none, [])
  }
  hint(
    title: if title != none [定理 · #title] else [定理],
    style: "blue",
    body,
  )
}

#let def(..args) = {
  let pos = args.pos()
  let named = args.named()
  let (title, body) = if pos.len() >= 2 {
    (pos.at(0), pos.at(1))
  } else if pos.len() == 1 {
    (named.at("title", default: none), pos.at(0))
  } else {
    (none, [])
  }
  hint(
    title: if title != none [定义 · #title] else [定义],
    style: "blue",
    body,
  )
}

// ---------- 强调与常用简写 ----------
#let emph(body) = text(font: font-head, weight: "bold", fill: c-emph)[#body]
#let key(body) = box(inset: (x: 0.18em, y: 0.05em), radius: 2pt, fill: luma(92%))[#body]
#let qed = align(right)[$square$]

#let dd = math.dif                       // 微分算子 d
#let pm = math.plus.minus                // 正负号 ±
#let mp = math.minus.plus                // 负正号 ∓
#let R = math.bold(math.upright("R"))    // 实数集
#let N = math.bold(math.upright("N"))
#let C = math.bold(math.upright("C"))
#let e = math.upright("e")               // 自然对数底
#let i = math.upright("i")
#let abs(x) = $|#x|$
#let norm(x) = $norm(#x)$
#let inner(a, b) = $angle.l #a, #b angle.r$
