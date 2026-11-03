// ============================================================
// 通用 Typst 模板 —— 适用于技术报告 / 技术书籍 / 开发文档（交接文档等）
// ============================================================
//
// 用法：
//   #import "template.typ": *
//   #show: conf.with(
//     title: [文档标题],
//     doc-type: "report",   // "report" | "book" | "doc"
//     authors: ("张三",),
//   )
//   = 正文从这里开始……
//
// doc-type 说明：
//   "report" —— 技术报告/论文：单独封面 + 摘要风格元信息，标题不强制分页
//   "book"   —— 技术书籍：大号封面，一级标题自动分页并显示"第 N 章"
//   "doc"    —— 开发/交接文档：左对齐紧凑封面 + 元信息表 + 修订记录表
//
// 所有视觉参数（颜色/字体）都在下面集中定义，按需替换即可。
// ============================================================
#import "@preview/merman:0.1.0": mermaid
#import "@preview/merman:0.1.0": show-mermaid-blocks

/// 使所有标记为 `mermaid` 的代码块自动渲染为 Mermaid 图表。
#show raw.where(lang: "mermaid"): show-mermaid-blocks(width: 100%)

/// 导入 Pikchr 图表渲染支持。
/// Pikchr 是一种轻量级的绘图语言，语法简洁，适合绘制技术图表。
#import "@preview/kip:0.1.0": kip

// ---------------- 1. 主题色与基础常量 ----------------

#let theme-color = rgb("#2b6cb0")        // 主题强调色
#let theme-color-dark = rgb("#1a4971")   // 标题/强调文字颜色
#let bg-soft = rgb("#f5f6f8")            // 代码块/表格的浅底色
#let border-soft = rgb("#d8dde3")        // 浅色边框线

// 字体：第一项是"首选"，找不到就按顺序往后退到开源字体兜底，所以即使
// 没装下面这些字体也不会报错——只是退到 Noto/DejaVu，效果会朴素一些。
//   正文/标题：微软雅黑（Windows 系统自带，黑体类，现代简洁）
//   代码/等宽：Maple Mono CN（开源，中英文 2:1 完美对齐宽度，专为代码里混排
//     中文注释设计——大多数等宽字体的 CJK 字符宽度其实不是精确 2 倍，混排
//     中文注释时会跟代码对不齐，Maple Mono CN 专门解决了这个问题）
//   想要更传统的"宋体正文 + 黑体标题"公文排版风格，把 font-main 换成
//   ("SimSun", "Noto Serif CJK SC") 即可，标题保持 font-heading 不变。
#let font-main = ("微软雅黑", "PingFang SC", "DejaVu Sans", "Noto Sans CJK SC")        // 正文
#let font-heading = ("微软雅黑", "PingFang SC", "DejaVu Sans", "Noto Sans CJK SC")     // 标题
#let font-mono = ("Maple Mono CN", "DejaVu Sans Mono", "Noto Sans Mono CJK SC")      // 代码/等宽

// 楷体专门留给"引用块"用（见下面引用块的 show 规则）：楷体本身的字形
// 就带有手写/强调感，比给中文字符强行加斜体（大多数中文字体根本没有
// 斜体字形，"斜体"设置在中文上要么被忽略要么被算法强行斜切，效果都不好）
// 更符合中文排版习惯——这是用楷体的正确场景，而不是把它塞进正文字体。
#let font-kai = ("KaiTi", "STKaiti", "Noto Serif CJK SC")   // 引用块专用

// 中英文界面文案（可在 conf() 中通过 lang 参数切换）
#let _i18n = (
  zh: (
    toc: "目录",
    figure: "图",
    table: "表",
    appendix-word: "附录",
    chapter-prefix: "第",
    chapter-suffix: "章",
    version: "版本",
    date: "日期",
    author: "作者",
    org: "单位",
    status: "状态",
    changelog: "修订记录",
  ),
  en: (
    toc: "Contents",
    figure: "Figure",
    table: "Table",
    appendix-word: "Appendix",
    chapter-prefix: "Chapter ",
    chapter-suffix: "",
    version: "Version",
    date: "Date",
    author: "Author",
    org: "Organization",
    status: "Status",
    changelog: "Revision History",
  ),
)


// ---------------- 2. 提示框 / Callout ----------------
// 用于交接文档里常见的"说明 / 提示 / 注意 / 坑点(BUG)"标注块。

#let callout(title: "说明", color: theme-color, body) = block(
  width: 100%,
  fill: color.lighten(85%),
  stroke: (left: 3pt + color),
  radius: 4pt,
  inset: 10pt,
  breakable: true,
  above: 0.8em,
  below: 0.8em,
)[#text(weight: "bold", fill: color.darken(35%), size: 0.95em)[#title] #v(0.35em) #body]

#let note(body) = callout(title: "说明", color: rgb("#2b6cb0"), body)
#let tip(body) = callout(title: "提示", color: rgb("#2f855a"), body)
#let warning(body) = callout(title: "注意", color: rgb("#b7791f"), body)
#let bug(body) = callout(title: "坑点 / BUG", color: rgb("#c53030"), body)
#let danger(body) = callout(title: "危险", color: rgb("#c53030"), body)


// ---------------- 2b. 分隔线 / Divider ----------------
// 对应 Markdown 里的 "---" 分段符。Typst 没有这种简写语法（markup 里的
// "---" 会被智能排版规则转成长破折号 "—"），所以这里提供一个显式函数，
// 用在段落之间表示话题切换，比单纯留白更明确。

#let divider() = align(center)[
  #v(0.3em)
  #text(fill: theme-color.lighten(30%), size: 1.1em, tracking: 0.6em)[· · ·]
  #v(0.3em)
]


// ---------------- 3. 修订记录表 ----------------
// entries: 形如 (("v1.0", "2026-06-01", "张三", "初稿"), ("v1.1", ...))

#let changelog-table(entries, lang: "zh") = {
  let t = _i18n.at(lang)
  table(
    columns: (auto, auto, auto, 1fr),
    stroke: (x, y) => if y == 0 { (bottom: 1pt + black) } else { (bottom: 0.5pt + border-soft) },
    inset: 7pt,
    [*#t.version*], [*#t.date*], [*#t.author*], [*说明*],
    ..entries.flatten(),
  )
}


// ---------------- 4. 附录 ----------------
// 用法：在正文最后调用 #appendix[ ... ]，内部标题会重新从 A 开始编号。

#let appendix(lang: "zh", body) = {
  let t = _i18n.at(lang)
  pagebreak(weak: true)
  counter(heading).update(0)
  set heading(numbering: (..nums) => {
    if nums.pos().len() == 1 {
      [#t.appendix-word ] + numbering("A", ..nums)
    } else {
      numbering("A.1", ..nums)
    }
  })
  body
}


// ---------------- 5. 主配置函数 conf() ----------------

#let conf(
  title: "文档标题",
  subtitle: none,
  authors: (), // ("张三", "李四") 或 (("张三","算法工程师"),...)
  org: none, // 单位/团队，如 "算法部 · CT 重建组"
  date: datetime.today(),
  version: none, // 如 "v1.0"
  status: none, // 如 "草稿 / 待评审 / 已发布"
  doc-type: "report", // "report" | "book" | "doc"
  lang: "zh",
  cover: true,
  toc: true,
  toc-depth: 3,
  logo: none, // 图片路径，如 "assets/logo.png"
  changelog: none, // 修订记录条目数组，见 changelog-table()
  body,
) = {
  let t = _i18n.at(lang, default: _i18n.zh)

  // ---- 文档元数据 ----
  set document(
    title: title,
    author: authors.map(a => if type(a) == array { a.at(0) } else { a }),
  )

  // ---- 基础排版 ----
  set text(font: font-main, lang: lang, size: 14pt)
  set par(justify: true, leading: 0.68em, first-line-indent: 0pt)
  set par(spacing: 1em)

  show strong: set text(weight: "bold")
  set list(indent: 1em, marker: (
    text(fill: theme-color)[•],
    text(fill: theme-color)[◦],
    text(fill: theme-color)[▪],
  ))
  set enum(indent: 1em, numbering: n => text(fill: theme-color, weight: "bold")[#n.])

  // ---- 链接 / 删除线 / 高亮 ----
  // Typst 原生语法里这些都要显式调用对应函数（#link()[...]、#strike[...]、
  // #highlight[...]），不像 Markdown 那样有 [text](url) / ~~text~~ 的简写——
  // 这里统一套上主题色，效果上对应 Markdown 渲染器里"链接变蓝带下划线"
  // "删除线变灰""高亮加底色"的视觉习惯。
  show link: it => underline(text(fill: theme-color)[#it])
  show strike: it => text(fill: gray.darken(10%))[#it]
  show highlight: set highlight(fill: theme-color.lighten(80%))

  // ---- 术语列表 / Term list ----
  // 对应 "/ 术语: 说明" 语法，适合参数说明、字段含义、术语表这类场景。
  show terms.item: it => block(above: 0.65em, below: 0.65em)[
    #text(weight: "bold", fill: theme-color-dark)[#it.term]
    #h(0.5em)
    #it.description
  ]

  // ---- 标题编号 ----
  set heading(numbering: (..nums) => {
    let lvl = nums.pos().len()
    if doc-type == "book" and lvl == 1 {
      [#t.chapter-prefix] + numbering("1", ..nums) + [#t.chapter-suffix]
    } else {
      numbering("1.1.1", ..nums)
    }
  })

  show heading.where(level: 1): it => {
    if doc-type == "book" { pagebreak(weak: true) }
    block(
      above: if doc-type == "book" { 1.4cm } else { 0.9cm },
      below: 0.9cm,
      breakable: false,
    )[
      #set text(
        font: font-heading,
        size: if doc-type == "book" { 23pt } else { 18pt },
        weight: "bold",
        fill: theme-color-dark,
      )
      #it
      #v(-0.35em)
      #line(length: 100%, stroke: 0.7pt + border-soft)
    ]
  }

  show heading.where(level: 2): it => block(above: 1.3em, below: 0.7em)[
    #set text(font: font-heading, size: 14pt, weight: "bold", fill: theme-color-dark)
    #it
  ]

  show heading.where(level: 3): it => block(above: 1.1em, below: 0.6em)[
    #set text(font: font-heading, size: 12pt, weight: "bold")
    #it
  ]

  // ---- 图 / 表 ----
  show figure.where(kind: image): set figure(supplement: t.figure)
  show figure.where(kind: table): set figure(supplement: t.table)
  set figure.caption(separator: [：])
  show figure.caption: it => {
    set text(size: 9.5pt, fill: gray.darken(20%))
    it
  }

  set table(
    stroke: (x, y) => if y == 0 { (bottom: 1pt + black) } else { (bottom: 0.5pt + border-soft) },
    inset: 7pt,
  )

  // ---- 代码块 ----
  // Typst 的等宽文本默认几乎只在空格处换行（连字符 "-" 是个例外）。
  // 像 "very_long_identifier"、"a::b::c"、长路径、哈希值这类没有空格的
  // token，遇到再长也不会自动换行，会直接撑出代码块、甚至撑出纸张。
  //
  // 下面这个函数会在常见的代码分隔符后插入零宽空格（U+200B）作为"允许换行点"，
  // 对完全没有分隔符的超长片段（如哈希值/base64）则按固定长度强制插入断点；
  // 零宽空格不可见、不影响复制粘贴出来的文本，也不影响 raw() 的语法高亮。
  // 函数本身是幂等的（对已经插入过零宽空格的文本重复调用结果不变），
  // 这一点是避免下面 show 规则发生无限递归的关键。
  let _zwsp = "\u{200B}"
  let _soft-break-chars = "_:=()[]{}<>,;@#%&|+*\\/."
  let _wrap-long-tokens(s, max-run: 22) = {
    let clean = s.replace(_zwsp, "")
    let out = ""
    let run = 0
    for c in clean {
      out += c
      if _soft-break-chars.contains(c) {
        out += _zwsp
        run = 0
      } else if c == " " or c == "\n" or c == "\t" {
        run = 0
      } else {
        run += 1
        if run >= max-run {
          out += _zwsp
          run = 0
        }
      }
    }
    out
  }

  // 注意：不能在 `show raw.where(block: true)` 内部直接用
  // `raw(新文本, block: true)` 去重新构造一个同类型元素再显示——
  // 那会被 Typst 当作"全新的、尚未处理过的" raw 元素，重新触发本规则，
  // 造成 "maximum show rule depth exceeded"。
  // 正确做法是借助 Typst 专门为此设计的 `raw.line`（每一行在渲染时
  // 合成出的辅助元素，类型与 raw 本身不同，不会触发上面这条规则）：
  // 多数行不需要改动，直接复用其已经高亮好的 line.body，零开销、
  // 颜色与原来完全一致；只有真正存在超长 token 的少数行，才单独用
  // 插入了零宽空格的文本重新构造一个 inline raw 来获得换行点。
  // 这个 inline raw 用 align: end 做一个内部标记（align 对非 block
  // 的 raw 本来就不生效，不影响外观），从而被下面"行内代码"规则的
  // `.where(align: start)` 排除，不会被误套上行内代码的底色小药丸样式。
  show raw.where(block: true): it => {
    show raw.line: line => {
      let wrapped = _wrap-long-tokens(line.text)
      if wrapped == line.text {
        line.body
      } else {
        raw(wrapped, lang: it.lang, block: false, align: end)
      }
    }
    block(
      width: 100%,
      fill: bg-soft,
      stroke: 0.6pt + border-soft,
      radius: 4pt,
      inset: 10pt,
      breakable: true,
      above: 0.9em,
      below: 0.9em,
    )[
      #if it.lang != none [
        #text(size: 8pt, fill: gray.darken(10%), font: font-mono, tracking: 0.5pt)[#upper(it.lang)]
        #v(0.4em)
      ]
      #set text(font: font-mono, size: 9.5pt)
      #set par(justify: false, leading: 0.55em)
      #it
    ]
  }

  // 行内代码（单反引号）：只匹配 align: start（Typst 默认值），
  // 从而天然排除上面那条规则内部用 align: end 构造出来的"内部行"。
  // show raw.where(block: false, align: start): it => {
  //   let wrapped = _wrap-long-tokens(it.text)
  //   // let body = if wrapped == it.text { it } else { raw(wrapped, lang: it.lang, block: false, align: end) }
  //   set text(font: font-mono, size: 1em)
  //   box(fill: bg-soft, outset: (y: 3pt), inset: (x: 4pt), radius: 2pt)[#body]
  // }

  // show raw.where(block: false, align: start): it => {
  //   let wrapped = _wrap-long-tokens(it.text)
  //   let body = if wrapped == it.text { it } else { raw(wrapped, lang: it.lang, block: false, align: end) }
  //   set text(font: font-mono, size: 1.0em, fill: rgb("#D97757"))
  //   box(
  //     fill: rgb("#F0EFEA"),
  //     outset: (y: 3pt),
  //     inset: (x: 4pt),
  //     radius: 4pt,
  //   )[#body]
  // }

  // ---- 数学公式编号 ----
  set math.equation(numbering: "(1)")

  // ---- 脚注 ----
  set footnote.entry(separator: line(length: 30%, stroke: 0.5pt + border-soft))

  // ---- 引用块 ----
  // 中文字体大多没有真正的斜体字形（"斜体"设置对中文字符要么被忽略、
  // 要么被强行算法斜切），所以这里不用 style: italic，改用楷体本身的
  // 字形特征来形成"这是引用/强调文字"的视觉区分，更符合中文排版习惯；
  // 楷体没有覆盖到的字符（比如英文单词）会自动回退到正文字体。
  show quote: set align(left)
  show quote.where(block: true): it => block(
    width: 100%,
    fill: bg-soft,
    inset: (left: 14pt, rest: 10pt),
    radius: 3pt,
    stroke: (left: 2.5pt + theme-color.lighten(20%)),
  )[#set text(font: font-kai + font-main, fill: gray.darken(25%)); #it]

  // ============================================================
  // 封面
  // ============================================================
  if cover {
    set page(numbering: none, header: none, footer: none)
    set align(center)

    if doc-type == "book" {
      v(3.2cm)
      if logo != none {
        image(logo, width: 3cm)
        v(1cm)
      }
      text(size: 30pt, weight: "bold", fill: theme-color-dark)[#title]
      if subtitle != none {
        v(0.5cm)
        text(size: 15pt, fill: gray.darken(10%))[#subtitle]
      }
      v(4.5cm)
      if authors.len() > 0 {
        text(size: 13pt)[#authors.map(a => if type(a) == array { a.at(0) } else { a }).join("  ·  ")]
        v(0.25cm)
      }
      if org != none {
        text(size: 11pt, fill: gray.darken(10%))[#org]
        v(0.25cm)
      }
      text(size: 11pt, fill: gray.darken(10%))[#date.display(if lang == "zh" { "[year]年[month]月" } else {
        "[month repr:long] [year]"
      })]
      if version != none {
        v(0.2cm)
        text(size: 10.5pt, fill: gray.darken(10%))[#t.version  #version]
      }
    } else if doc-type == "report" {
      v(2.2cm)
      line(length: 38%, stroke: 1.2pt + theme-color)
      v(0.9cm)
      text(size: 25pt, weight: "bold")[#title]
      if subtitle != none {
        v(0.4cm)
        text(size: 13.5pt, fill: gray.darken(10%))[#subtitle]
      }
      v(0.9cm)
      line(length: 38%, stroke: 1.2pt + theme-color)
      v(3cm)
      set align(center)
      block(width: 70%)[
        #set par(justify: false)
        #if authors.len() > 0 [
          #text(size: 12pt)[#authors.map(a => if type(a) == array { a.at(0) } else { a }).join("，")] \
        ]
        #if org != none [ #text(size: 11pt, fill: gray.darken(10%))[#org] \ ]
        #text(size: 11pt, fill: gray.darken(10%))[#date.display(if lang == "zh" { "[year]年[month]月[day]日" } else {
          "[month repr:long] [day], [year]"
        })]
        #if version != none [ \ #text(size: 10.5pt, fill: gray.darken(10%))[#t.version  #version] ]
      ]
    } else {
      // doc-type == "doc"：紧凑左对齐封面 + 元信息表 + 修订记录
      set align(left)
      v(1cm)
      if logo != none {
        image(logo, width: 2.4cm)
        v(0.6cm)
      }
      text(size: 22pt, weight: "bold", fill: theme-color-dark)[#title]
      if subtitle != none {
        v(0.3cm)
        text(size: 12.5pt, fill: gray.darken(10%))[#subtitle]
      }
      v(0.9cm)
      line(length: 100%, stroke: 0.6pt + border-soft)
      v(0.7cm)

      let meta-rows = ()
      if authors.len() > 0 {
        meta-rows.push(([#t.author], [#authors.map(a => if type(a) == array { a.at(0) } else { a }).join("，")]))
      }
      if org != none { meta-rows.push(([#t.org], [#org])) }
      meta-rows.push((
        [#t.date],
        [#date.display(if lang == "zh" { "[year]年[month]月[day]日" } else { "[year]-[month]-[day]" })],
      ))
      if version != none { meta-rows.push(([#t.version], [#version])) }
      if status != none { meta-rows.push(([#t.status], [#status])) }

      table(
        columns: (auto, 1fr),
        stroke: none,
        inset: (x: 0pt, y: 5pt),
        column-gutter: 14pt,
        ..meta-rows
          .map(r => (
            text(weight: "bold", fill: gray.darken(30%))[#r.at(0)：],
            r.at(1),
          ))
          .flatten()
      )

      if changelog != none {
        v(1cm)
        text(weight: "bold", size: 12pt, fill: theme-color-dark)[#t.changelog]
        v(0.4cm)
        changelog-table(changelog, lang: lang)
      }
    }

    pagebreak()
  }

  // ============================================================
  // 目录（front matter 用罗马数字页码，正文从阿拉伯数字 1 重新开始）
  // ============================================================
  if toc {
    set page(numbering: "i", header: none, footer: none)
    counter(page).update(1)
    outline(title: t.toc, depth: toc-depth, indent: auto)
    pagebreak()
  }

  // ============================================================
  // 正文页面设置：页眉显示"文档标题 | 当前章节"，页脚居中页码
  // ============================================================
  set page(
    paper: "a4",
    margin: (top: 3cm, bottom: 2.4cm, left: 2.6cm, right: 2.6cm),
    numbering: "1",
    number-align: center,
    header: context {
      let page-num = here().page()
      let heads = query(heading.where(level: 1)).filter(h => h.numbering != none and h.location().page() <= page-num)
      let current = if heads.len() > 0 { heads.last() } else { none }
      set text(size: 8.5pt, fill: gray.darken(10%))
      grid(
        columns: (1fr, 1fr),
        align(left)[#title], align(right)[#if current != none [#current.body] else []],
      )
      v(-0.3em)
      line(length: 100%, stroke: 0.5pt + border-soft)
    },
  )
  counter(page).update(1)

  body
}


// ---------------- 本文档专用：流程图组件 ----------------
// 模板本身不含流程图绘制能力，这里在正文作用域内追加几个轻量组件，
// 全部基于原生 block/rect，不依赖任何外部包。
#let stepcolor = rgb("#c05621")
#let stepbox(title, desc: none, fill: white, stroke-color: theme-color) = block(
  width: 100%,
  fill: fill,
  stroke: 1pt + stroke-color,
  radius: 4pt,
  inset: (x: 10pt, y: 7pt),
)[
  #set par(justify: false)
  #align(center)[
    #text(weight: "bold", size: 12pt, fill: stroke-color.darken(25%))[#title]
    #if desc != none [
      #v(0.15em)
      #text(size: 12pt, fill: gray.darken(90%))[#desc]
    ]
  ]
]

#let flowarrow(label: none) = align(center)[
  #v(0.12em)
  #stack(
    dir: ltr,
    spacing: 0.3em,
    if label != none { text(size: 12pt, fill: gray.darken(90%), style: "italic")[#label] },
    text(size: 12pt, fill: theme-color)[↓],
  )
  #v(0.12em)
]

#let loopwrap(title, body) = block(
  width: 100%,
  stroke: (paint: theme-color, dash: "dashed", thickness: 1pt),
  radius: 4pt,
  inset: (top: 20pt, bottom: 10pt, x: 1pt),
)[
  #place(top + left, dx: 6pt, dy: -13pt)[
    #box(fill: white, inset: (x: 4pt))[
      #text(size: 12pt, weight: "bold", fill: theme-color)[#title]
    ]
  ]
  #body
]
