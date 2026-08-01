// lightmind.typ
// 基于 lightmind.css 改写的 Typst 模板

// 伪粗体、伪斜体
#import "@preview/cuti:0.4.0": fakeitalic, show-cn-fakebold
// 类markdown中的表格语法
#import "@preview/tablem:0.3.0": tablem

// =====================================================================
// 调色板 (Palettes)
// 亮色 / 暗色两套配色，集中于此统一调整
// 参考 lightmind.css 与 lightmind-dark.css
// =====================================================================

// ---------- 亮色主题 ----------
#let light-colors = (
  // 表面色
  "bg-page": rgb("#f4f1e8"), // 页面底色
  "bg-write": rgb("#faf7ef"), // 正文书写区底色
  "bg-soft": rgb("#ece8db"), // 柔和背景 (卡片/元信息块)
  "bg-formula": rgb("#f7f3e8"), // 公式块背景
  "bg-quote": rgb("#ecefe6"), // 引用块背景 (雾色草地)
  "bg-inline-code": rgb("#e7eee5"), // 行内代码背景
  "bg-highlight": rgb("#e6dbc5"), // 高亮文本背景
  // 文字色
  "fg-main": rgb("#2c3a32"), // 正文主文字色
  "fg-muted": rgb("#6b7a6f"), // 弱化文字 (元信息)
  "fg-faint": rgb("#93a098"), // 更弱文字
  "fg-heading": rgb("#1f2a23"), // 标题文字色
  // 强调色 (中山林绿系)
  "accent": rgb("#4a7c59"), // 主强调色 (中山林绿)
  "accent-deep": rgb("#2f5a40"), // 深强调 (标题、加粗)
  "accent-soft": rgb("#8fb39b"), // 浅强调 (柔和边框)
  "accent-warm": rgb("#c2a878"), // 暖金强调 (分隔线、公式)
  // 代码块
  "code-bg": rgb("#1e2330"), // 代码块背景 (深藏青)
  "code-bg-soft": rgb("#262c3a"), // 代码块头部背景
  "code-fg": rgb("#c8cfd9"), // 代码前景色
  "code-line": rgb("#3a4253"), // 代码行高亮色
  "code-gutter": rgb("#6b7488"), // 行号色
  // 警告块 (GitHub Alerts)
  "alert-note": rgb("#4a8fc4"),
  "alert-note-bg": rgb("#eaf2f9"),
  "alert-tip": rgb("#4a7c59"),
  "alert-tip-bg": rgb("#ebf2ec"),
  "alert-important": rgb("#8b5fbf"),
  "alert-important-bg": rgb("#f0eaf6"),
  "alert-warning": rgb("#c8943a"),
  "alert-warning-bg": rgb("#f7efde"),
  "alert-caution": rgb("#c4564a"),
  "alert-caution-bg": rgb("#f6e9e7"),
)

// ---------- 暗色主题 (参考 lightmind-dark.css) ----------
#let dark-colors = (
  // 表面色 — 暗夜森林
  "bg-page": rgb("#161d1a"), // 页面底色
  "bg-write": rgb("#1d2622"), // 正文书写区底色
  "bg-soft": rgb("#232d28"), // 次表面 (表格条纹等)
  "bg-formula": rgb("#1f2823"), // 公式块底色
  "bg-quote": rgb("#1d2722"), // 引用块底色
  "bg-inline-code": rgb("#25342c"), // 行内代码 — 浅绿蒙层
  "bg-highlight": rgb("#453a26"), // 高亮 ≈ rgba(194,168,120,0.35)
  // 文字色 — 浅米色到柔和灰绿
  "fg-main": rgb("#d4dccf"), // 主文字
  "fg-muted": rgb("#9ba89e"), // 次要 / 元信息
  "fg-faint": rgb("#6f7a72"), // 弱化前景色
  "fg-heading": rgb("#e8ede1"), // 标题
  // 强调色 — 暗底更亮
  "accent": rgb("#7fbe92"), // 中山林绿 (暗底加亮)
  "accent-deep": rgb("#a8d4b6"), // 高对比标题/加粗
  "accent-soft": rgb("#5a7d68"), // 浅雾绿 (降饱和)
  "accent-warm": rgb("#d8bd86"), // 暖金 (阳光)
  // 代码块 — 更深海军蓝
  "code-bg": rgb("#14181f"),
  "code-bg-soft": rgb("#1c2128"),
  "code-fg": rgb("#c8cfd9"),
  "code-line": rgb("#3a4253"),
  "code-gutter": rgb("#6b7488"),
  // 警告块 — 暗底更亮描边 + 半透明底
  "alert-note": rgb("#7cb6e0"),
  "alert-note-bg": rgb("#4a8fc4").transparentize(88%),
  "alert-tip": rgb("#7fbe92"),
  "alert-tip-bg": rgb("#7fbe92").transparentize(88%),
  "alert-important": rgb("#c4a0e8"),
  "alert-important-bg": rgb("#aa82d2").transparentize(88%),
  "alert-warning": rgb("#e8c878"),
  "alert-warning-bg": rgb("#dabd86").transparentize(88%),
  "alert-caution": rgb("#e88a82"),
  "alert-caution-bg": rgb("#dc6e64").transparentize(88%),
)

// 全局主题状态：由 lightmind(dark-mode: ...) 自动更新，
// kbd / task / mark / frontmatter 等辅助函数通过 context 自动跟随，
// 无需逐处传 dark-mode 参数。
#let theme-state = state("lightmind-theme", "light")

// 按暗色开关取调色板
#let palette-colors(dark-mode: false) = if dark-mode {
  dark-colors
} else {
  light-colors
}

// 键位样式（kbd）函数
#let kbd(body) = context {
  let colors = palette-colors(dark-mode: theme-state.get() == "dark")
  box(
    fill: colors.at("bg-soft"),
    radius: 3pt,
    inset: (x: 4pt, y: 4pt),
    stroke: 1pt + colors.at("fg-faint").transparentize(60%),
    body,
  )
}

// 任务列表项（checkbox）函数
#let task(checked: false, body) = context {
  let colors = palette-colors(dark-mode: theme-state.get() == "dark")
  grid(
    columns: (auto, 1fr),
    column-gutter: 0.5em,
    align(center + horizon, box(
      width: 1.05em,
      height: 1.05em,
      radius: 0.2em,
      stroke: 1pt + colors.at("accent"),
      fill: if checked { colors.at("accent") } else { none },
      if checked {
        align(
          center + horizon,
          text(size: 0.7em, fill: colors.at("bg-write"), sym.checkmark),
        )
      },
    )),
    body,
  )
}

// 文本高亮函数
#let mark(body) = context {
  let colors = palette-colors(dark-mode: theme-state.get() == "dark")
  box(
    fill: colors.at("bg-highlight"),
    radius: 3pt,
    inset: (x: 1pt, y: 0pt),
    outset: (y: 3pt),
    body,
  )
}

// YAML 前置元信息块 (frontmatter)
// 用法：在文档顶部调用 #frontmatter(title: ..., author: ..., tags: (...))
// 颜色自动跟随全局 dark-mode，无需传参
#let frontmatter(..args) = context {
  let colors = palette-colors(dark-mode: theme-state.get() == "dark")
  let dict = args.named()
  let lines = ("---",)

  // 遍历并格式化传入的参数
  for (k, v) in dict.pairs() {
    let v-str = if type(v) == array {
      "[" + v.join(", ") + "]"
    } else {
      str(v)
    }
    lines.push(k + ": " + v-str)
  }
  lines.push("---")

  // 复刻 pre.md-meta-block 的样式
  block(
    fill: colors.at("bg-soft"), // var(--bg-soft)
    stroke: (paint: colors.at("accent").transparentize(70%), thickness: 1pt, dash: "dashed"), // 1px dashed
    radius: 8pt,
    inset: (x: 16pt, y: 12pt),
    width: 100%,
    text(
      fill: colors.at("fg-muted"), // var(--fg-muted)
      // // 强制使用正文字体而非等宽代码字体
      // font: ("LXGW WenKai"),
      size: 10.5pt,
      lines.join(linebreak()),
    ),
  )
}

#let lightmind(
  title: none,
  show-code-lang: true,       // 是否显示代码块的语言标签
  allow-page-breaks: true,    // 是否允许分页 (true: 传统多页文档, false: 无限长单页)
  dark-mode: false,           // 亮暗主题开关，默认 false (亮色)
  font: ("LXGW WenKai", "Source Han Serif SC"), // 正文字体
  code-font: ("Cascadia Code", "LXGW WenKai"),  // 代码字体
  doc,
) = {
  show: show-cn-fakebold

  // ---------- 全局主题状态 ----------
  // 更新全局 dark-mode 状态，让 kbd/task/mark/frontmatter 等自动跟随
  theme-state.update(if dark-mode { "dark" } else { "light" })

  // ---------- 配色（按 dark-mode 选择调色板） ----------
  let colors = palette-colors(dark-mode: dark-mode)
  let bg-page = colors.at("bg-page")
  let bg-write = colors.at("bg-write")
  let bg-soft = colors.at("bg-soft")
  let bg-formula = colors.at("bg-formula")
  let bg-quote = colors.at("bg-quote")
  let bg-inline-code = colors.at("bg-inline-code")
  let bg-highlight = colors.at("bg-highlight")
  let fg-main = colors.at("fg-main")
  let fg-muted = colors.at("fg-muted")
  let fg-faint = colors.at("fg-faint")
  let fg-heading = colors.at("fg-heading")
  let accent = colors.at("accent")
  let accent-deep = colors.at("accent-deep")
  let accent-soft = colors.at("accent-soft")
  let accent-warm = colors.at("accent-warm")
  let code-bg = colors.at("code-bg")
  let code-bg-soft = colors.at("code-bg-soft")
  let code-fg = colors.at("code-fg")
  let code-line = colors.at("code-line")
  let code-gutter = colors.at("code-gutter")
  let alert-note = colors.at("alert-note")
  let alert-note-bg = colors.at("alert-note-bg")
  let alert-tip = colors.at("alert-tip")
  let alert-tip-bg = colors.at("alert-tip-bg")
  let alert-important = colors.at("alert-important")
  let alert-important-bg = colors.at("alert-important-bg")
  let alert-warning = colors.at("alert-warning")
  let alert-warning-bg = colors.at("alert-warning-bg")
  let alert-caution = colors.at("alert-caution")
  let alert-caution-bg = colors.at("alert-caution-bg")

  // ---------- 页面框架 ----------
  set page(
    fill: bg-write,
    margin: (x: 12%, y: 5em),
    // 核心逻辑：如果不允许分页，强制将页面高度设为 auto，让内容顺延不被切断
    ..if not allow-page-breaks { 
      (height: auto) 
    }
  )

  // ---------- 字体与段落 ----------
  set text(
    font: font,
    size: 11pt,
    fill: fg-main,
    lang: "zh",
  )

  set par(
    leading: 0.78em,
    justify: true,
  )

  // ---------- 段落与行内元素 ----------
  // 加粗与斜体
  show strong: set text(fill: accent-deep, weight: 600)
  // 中文没有真实斜体字形，用伪斜体（cuti），并设置填充色
  show emph: it => fakeitalic(ang: -10deg, text(fill: fg-main, it))

  // 链接
  show link: it => underline(
    text(fill: accent, it),
    stroke: 1pt + accent-soft,
  )

  // 行内代码
  show raw.where(block: false): it => box(
    fill: bg-inline-code,
    inset: (x: 4pt, y: 0pt),
    outset: (y: 3pt),
    radius: 3pt,
    stroke: 1pt + accent.transparentize(85%),
    text(fill: accent-deep, font: code-font, size: 1.1em, it),
  )

  // 独立代码块
  show raw.where(block: true): it => {
    let lang = it.lang
    let lang-display = if lang != none { str(lang) } else { "" }

    set text(fill: code-fg, font: code-font, size: 10pt)
    set par(leading: 0.62em)
    block(
      width: 100%,
      fill: code-bg,
      radius: 8pt,
      inset: 0pt,
      spacing: 1.2em,
      clip: true,
      breakable: true, // 建议：允许长代码块本身跨页断行，避免上一页留白过大
      [
        // 是否显示code lang
        #if (show-code-lang) {
          block(
            sticky: true, // <--- 关键修复：让此区域“粘住”下方的代码块，绝不分家
            width: 100%,
            fill: code-bg-soft,
            inset: (x: 16pt, y: 6pt),
            text(size: 9pt, fill: code-gutter, weight: 500, lang-display),
          )
        }
        #block(
          width: 100%,
          inset: (x: 18pt, top: if show-code-lang { 0pt } else { 16pt }, bottom: 16pt),
          text(fill: code-fg, it),
          fill: code-bg,
        )
      ],
    )
  }

  // 引用块与 GitHub 风格警告块 (Alerts)
  // 通过 quote 的 attribution 参数触发，如：#quote(attribution: "tip")[...]
  set quote(block: true)
  show quote.where(block: true): it => {
    // 定义 5 种警告块的具体样式和图标
    let alerts = (
      "note": (icon: "ⓘ", color: alert-note, bg: alert-note-bg, title: "Note"),
      "tip": (icon: "💡", color: alert-tip, bg: alert-tip-bg, title: "Tip"),
      "important": (icon: "💬", color: alert-important, bg: alert-important-bg, title: "Important"),
      "warning": (icon: "⚠️", color: alert-warning, bg: alert-warning-bg, title: "Warning"),
      "caution": (icon: "🛑", color: alert-caution, bg: alert-caution-bg, title: "Caution"),
    )

    // 1. 判断并提取类型 (处理直接传字符串或 Typst content 的情况)
    let attr = it.attribution
    let kind = none
    if attr in ("note", "Note", [note], [Note]) {
      kind = "note"
    } else if attr in ("tip", "Tip", [tip], [Tip]) {
      kind = "tip"
    } else if attr in ("important", "Important", [important], [Important]) {
      kind = "important"
    } else if attr in ("warning", "Warning", [warning], [Warning]) {
      kind = "warning"
    } else if attr in ("caution", "Caution", [caution], [Caution]) {
      kind = "caution"
    }

    // 2. 如果命中 5 种特殊样式之一，应用警告块排版
    if kind != none {
      let style = alerts.at(kind)
      block(
        fill: style.bg,
        stroke: (
          left: 4pt + style.color,
          top: 1pt + style.color.transparentize(70%),
          right: 1pt + style.color.transparentize(70%),
          bottom: 1pt + style.color.transparentize(70%),
        ),
        inset: (x: 14pt, y: 14pt),
        radius: 8pt,
        width: 100%,
        [
          // 标题与图标区
          #block(
            below: 1em, // 控制标题和正文的间距
            text(fill: style.color, weight: "bold", size: 1.05em)[
              #box(baseline: 15%)[#style.icon] #h(4pt) #style.title
            ],
          )
          // 正文区 (忽略 it.attribution，直接渲染内容)
          #it.body
        ],
      )
    } // 3. 否则，降级渲染默认的引用块
    else {
      block(
        fill: bg-quote,
        stroke: (
          left: 4pt + accent,
          top: 1pt + accent.lighten(80%),
          right: 1pt + accent.lighten(80%),
          bottom: 1pt + accent.lighten(80%),
        ),
        inset: (x: 14pt, y: 14pt),
        radius: 8pt,
        width: 100%,
        it,
      )
    }
  }

  // 公式块
  show math.equation.where(block: true): it => block(
    fill: bg-formula,
    stroke: 1pt + accent-warm.transparentize(75%),
    inset: 18pt,
    radius: 8pt,
    width: 100%,
    align(center, text(fill: fg-heading, it)),
  )

  // 分隔线
  show line: set line(stroke: 1pt + accent-soft, length: 100%)

  // ---------- 标题 ----------
  show heading: it => {
    set text(font: font, fill: fg-heading, weight: 700)
    set block(above: 1.6em, below: 0.6em)

    if it.level == 1 {
      set text(size: 1.85em)
      block(stroke: (bottom: 2pt + accent), inset: (bottom: 0.35em), width: 100%, it)
    } else if it.level == 2 {
      set text(size: 1.5em, fill: accent-deep)
      block(stroke: (bottom: 1pt + accent.transparentize(75%)), inset: (bottom: 0.3em), width: 100%, it)
    } else if it.level == 3 {
      set text(size: 1.25em, fill: accent-deep)
      grid(
        columns: (auto, 1fr),
        column-gutter: 0.55em,
        align(center + horizon, box(width: 4pt, height: 0.95em, fill: accent, radius: 2pt)), it,
      )
    } else if it.level == 4 {
      set text(size: 1.1em, fill: accent-deep)
      it
    } else if it.level == 5 {
      set text(size: 1em, fill: fg-muted)
      it
    } else {
      set text(size: 0.95em, fill: fg-faint)
      it
    }
  }

  // ---------- 列表 ----------
  set list(marker: (
    text(fill: accent)[•],
    text(fill: accent-deep)[◦],
    text(fill: accent)[▪],
  ))

  set enum(numbering: n => text(fill: accent-deep, weight: 600, [#n.]))

  // ---------- 表格 ----------
  // 深绿外框 + 圆角，表头绿色填充，单元格浅绿分隔线，隔行变色
  set table(
    align: center + horizon,
    inset: (x: 12pt, y: 10pt),
    stroke: (x, y) => (
      right: 0.5pt + accent.transparentize(60%),
      bottom: 0.5pt + accent.transparentize(60%),
    ),
    fill: (x, y) => if y == 0 { accent } else if calc.odd(y) { bg-write } else { bg-soft },
  )

  // 深绿圆角外框（注意：此规则也会作用于 three-line-table，
  // 如需保持三线表无外框，删除此 show table 规则即可）
  show table: it => align(center)[#block(
    radius: 4pt,
    clip: true,
    stroke: 1.2pt + accent-deep,
    it,
  )]

  show table.cell: it => {
    if it.y == 0 {
      set text(fill: bg-write, weight: 600)
      it
    } else {
      it
    }
  }

  // --- 图片样式 ---
  show image: it => block(
    radius: 4pt,
    clip: true,
    stroke: 1pt + fg-main.transparentize(92%),
    it,
  )

  // --- 高亮文本 ---
  show highlight: set highlight(
    fill: bg-highlight,
    radius: 3pt,
    extent: 0.5pt, // 稍微向外延伸一点，让高亮背景不那么拥挤
  )

  // ---------- 文档主内容 ----------
  if title != none {
    align(center)[
      #block(below: 2em)[
        #text(weight: 700, size: 2.5em, fill: fg-heading, title)
      ]
    ]
  }

  doc
}
