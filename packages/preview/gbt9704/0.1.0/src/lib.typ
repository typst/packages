// ═══════════════════════════════════════════════════════════════
// gbt9704 — GB/T 9704-2012 党政机关公文格式
// Typst 模板 v0.1.0
// License: MIT
// Repository: https://codeberg.org/songwupei/typst-gbt9704
//
// ═══════════════════════════════════════════════════════════════

// ══════ 常量 Constants ══════

/// 公文标准颜色。
#let _colors = (
  red: rgb("#C8102E"),
  black: rgb("#000000"),
)

/// 公文标准字体（按优先级排列，自动回退）。
#let _fonts = (
  title: ("FZDaBiaoSong-B06", "FZXiaoBiaoSong-B05S", "SimHei"),
  body: ("FangSong", "HYShuFang", "SimSun", "Noto Serif CJK SC"),
  heading1: ("SimHei", "Noto Sans SC", "Noto Serif CJK SC"),
  heading2: ("KaiTi", "STKaiti", "HYShuFang", "Noto Serif CJK SC"),
  heading3: ("FangSong", "HYShuFang", "SimSun", "Noto Serif CJK SC"),
  number: ("FangSong", "HYShuFang", "SimSun"),
)

// ══════ 模板 Template ══════

/// 应用 GB/T 9704-2012 公文格式。
///
/// # 参数
/// - `redline` (bool): 是否在红头下方绘制红色分隔线，默认 `false`。
/// - `title-indent` (bool): 章节标题是否首行缩进 2 字符，默认 `true`。
///
/// # 用法
/// ```typst
/// #import "@preview/gbt9704:0.1.0": *
/// #show: gbt9704.with(redline: true)
///
/// #gongwentitle[文件标题]
/// = 一级标题
/// 正文内容 ...
/// ```
#let gbt9704(
  redline: false,
  title-indent: true,
  body,
) = {
  // ── 文档元数据 ──
  set document(title: "", author: "")

  // ── 页面设置：A4，国标边距 ──
  set page(
    paper: "a4",
    margin: (left: 28mm, right: 26mm, top: 37mm, bottom: 35mm),
    footer: context {
      set text(font: _fonts.body, size: 14pt)
      align(center)[#counter(page).display()]
    },
  )

  // ── 正文字体：三号 (16pt) 仿宋，中文语境 ──
  set text(
    font: _fonts.body,
    size: 16pt,
    lang: "zh",
    region: "cn",
  )

  // ── 段落样式：28 磅行距（总行高 28pt，leading = 28pt - 16pt = 12pt），首行缩进 2 字符，两端对齐 ──
  // all: true 确保标题后首段也缩进（Typst 0.13+）
  set par(
    leading: 12pt,
    first-line-indent: if title-indent {
      (amount: 2em, all: true)
    } else {
      (amount: 0em, all: true)
    },
    spacing: 0.5em,
    justify: true,
  )

  // ── 标题样式（ilm 模式：只设字体，不改内部结构）──
  set heading(numbering: none)
  show heading.where(level: 1): set text(font: _fonts.heading1, size: 16pt)
  show heading.where(level: 2): set text(font: _fonts.heading2, size: 16pt, weight: "bold")
  show heading.where(level: 3): set text(font: _fonts.heading3, size: 16pt, weight: "bold")
  show heading: set par(leading: 12pt)
  show heading: it => {
    block(width: 100%, inset: (left: 2em))[#it]
    v(0.5em, weak: true)
  }
  show heading: set text(hyphenate: false)

  // ── 表格默认居中，取消单元格内首行缩进 ──
  show table: it => {
    set par(first-line-indent: (amount: 0em, all: true))
    align(center, it)
  }

  // ── 上下文隔离（ilm 模式）──
  { body }
}

// ══════ 公文要素 Document Elements ══════
// 元素不再包裹 block[]，改用函数作用域 set 规则 + 直接返回 content。
// Typst 中函数内 set 规则自动作用于返回的 content，不会泄漏到外部。

/// 公文大标题：二号 (22pt) 大标宋，居中。
#let gongwentitle(body) = {
  set text(font: _fonts.title, size: 22pt)
  set par(leading: 12pt, first-line-indent: (amount: 0em, all: true), justify: false)
  align(center, body)
}

/// 公文副标题：三号 (16pt) 仿宋，居中。
#let gongwensubtitle(body) = {
  set text(font: _fonts.body, size: 16pt)
  set par(leading: 12pt, first-line-indent: (amount: 0em, all: true), justify: false)
  align(center, body)
}

/// 红头：发文机关、发文字号、签发人（可选）及红色分隔线（可选）。
#let make-header(
  organ: "",
  number: "",
  signatory: "",
  redline: false,
) = {
  block(breakable: false)[
    // 发文机关：大标宋，红色，居中
    #set text(font: _fonts.title, size: 22pt, fill: _colors.red)
    #set par(first-line-indent: (amount: 0em, all: true), justify: false)
    #align(center, organ)
    #v(0.5cm)

    // 发文字号 + 签发人：左右分布
    #set text(font: _fonts.number, size: 12pt, fill: _colors.black)
    #grid(
      columns: (1fr, 1fr),
      gutter: 2em,
      number,
      if signatory != "" { signatory } else { [] },
    )

    // 红色分隔线
    #if redline {
      v(0.3cm)
      line(length: 100%, stroke: (paint: _colors.red, thickness: 1.5pt))
      v(0.3cm)
    }
  ]
}

/// 主送机关：取消首行缩进，顶格书写。
#let main-receiver(body) = {
  set par(leading: 12pt, first-line-indent: (amount: 0em, all: true))
  body
}

/// 单附件（带「附件：」前缀，缩进 2 字符）。
#let attachment(body) = {
  set par(leading: 12pt, first-line-indent: (amount: 2em, all: true))
  [附件：#body]
}

/// 单附件（不带前缀，对齐「附件：」后的正文位置，缩进 5 字符）。
#let attachment-no-hz(body) = {
  block(inset: (left: 5em))[#body]
}

/// 多附件条目，可自定义首行缩进。
#let attachment-item(body, indent: 4.9em) = {
  block(inset: (left: indent))[#body]
}

/// 署名：右对齐，右侧空 2 字符。
#let signature(name) = {
  set par(leading: 12pt, first-line-indent: (amount: 0em, all: true), justify: false)
  align(right, box(inset: (right: 2em), name))
}

/// 日期：右对齐，右侧空 2 字符。
#let signdate(date) = {
  set par(leading: 12pt, first-line-indent: (amount: 0em, all: true), justify: false)
  align(right, box(inset: (right: 2em), date))
}

/// 附注：加圆括号，无缩进。
#let notes(body) = {
  set par(leading: 12pt, first-line-indent: (amount: 0em, all: true))
  [（#body）]
}

/// 抄送：「抄送：」前缀，无缩进。
#let copyto(body) = {
  set par(leading: 12pt, first-line-indent: (amount: 0em, all: true))
  [抄送：#body]
}

/// 印发机关与印发日期：同一行，左侧机关、右侧日期。
#let issueinfo(organ: "", date: "") = {
  set par(leading: 12pt, first-line-indent: (amount: 0em, all: true), justify: false)
  grid(
    columns: (1fr, 1fr),
    organ,
    align(right, date),
  )
}

/// 黑色分隔线（版记使用）。
#let seprule = {
  set par(leading: 12pt, first-line-indent: (amount: 0em, all: true))
  line(length: 100%, stroke: 0.5pt)
}

/// 红色分隔线（红头使用）。
#let redrule = {
  set par(leading: 12pt, first-line-indent: (amount: 0em, all: true))
  line(length: 100%, stroke: (paint: _colors.red, thickness: 1.5pt))
}

