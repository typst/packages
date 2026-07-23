// ═══════════════════════════════════════════════════════════════
// gbt9704-gongwen — 适配 GB/T 9704-2012 · 党政机关公文格式
// Typst Template v0.1.0
// License: MIT
// Repository: https://codeberg.org/songwupei/typst-gbt9704
// ═══════════════════════════════════════════════════════════════

// ══════ Constants · 常量 ══════

/// Standard document colors / 公文标准颜色。
#let _colors = (
  red: rgb("#C8102E"),
  black: rgb("#000000"),
)

/// Standard document fonts with fallback chain / 公文标准字体（按优先级排列，自动回退）。
#let _fonts = (
  title: ("FZDaBiaoSong-B06", "FZXiaoBiaoSong-B05S", "SimHei"),
  body: ("FangSong", "HYShuFang", "SimSun", "Noto Serif CJK SC"),
  heading1: ("SimHei", "Noto Sans SC", "Noto Serif CJK SC"),
  heading2: ("KaiTi", "STKaiti", "HYShuFang", "Noto Serif CJK SC"),
  heading3: ("FangSong", "HYShuFang", "SimSun", "Noto Serif CJK SC"),
  number: ("FangSong", "HYShuFang", "SimSun"),
)

// ══════ Template · 模板 ══════

/// Apply GB/T 9704-2012 official document formatting.
/// 应用 GB/T 9704-2012 公文格式。
///
/// # Parameters · 参数
/// - `redline` (bool): Draw a red separator line below the red-header. Default `false`.
///   是否在红头下方绘制红色分隔线，默认 `false`。
/// - `title-indent` (bool): Whether to indent section headings by 2 characters. Default `true`.
///   章节标题是否首行缩进 2 字符，默认 `true`。
///
/// # Usage · 用法
/// ```typst
/// #import "@preview/gbt9704-gongwen:0.1.0": *
/// #show: gbt9704.with(redline: true)
///
/// #gongwentitle[Document Title / 文件标题]
/// = Level-1 Heading · 一级标题
/// Body text ... 正文内容 ...
/// ```
#let gbt9704(
  redline: false,
  title-indent: true,
  body,
) = {
  // Document metadata / 文档元数据
  set document(title: "", author: "")

  // Page setup: A4 with GB-standard margins / 页面设置：A4，国标边距
  set page(
    paper: "a4",
    margin: (left: 28mm, right: 26mm, top: 37mm, bottom: 35mm),
    footer: context {
      set text(font: _fonts.body, size: 14pt)
      align(center)[#counter(page).display()]
    },
  )

  // Body font: 16pt FangSong, Chinese locale / 正文字体：三号 (16pt) 仿宋，中文语境
  set text(
    font: _fonts.body,
    size: 16pt,
    lang: "zh",
    region: "cn",
  )

  // Paragraph style: 28pt line spacing (leading = 28pt - 16pt = 12pt),
  // 2-char first-line indent, justified
  // 段落样式：28 磅行距，首行缩进 2 字符，两端对齐
  // `all: true` ensures the first paragraph after a heading is also indented (Typst 0.13+)
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

  // Heading styles: set fonts only, don't modify internal structure
  // 标题样式：只设字体，不改内部结构
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

  // Tables: centered with no first-line indent in cells / 表格默认居中，取消单元格内首行缩进
  show table: it => {
    set par(first-line-indent: (amount: 0em, all: true))
    align(center, it)
  }

  // Context isolation / 上下文隔离
  { body }
}

// ══════ Document Elements · 公文要素 ══════
// Elements use function-scoped set rules to return content directly.
// Typst set rules inside a function automatically apply to the returned content without leaking.
// 元素使用函数作用域 set 规则直接返回 content，不会泄漏到外部。

/// Document title: 22pt DaBiaoSong, centered.
/// 公文大标题：二号 (22pt) 大标宋，居中。
#let gongwentitle(body) = {
  set text(font: _fonts.title, size: 22pt)
  set par(leading: 12pt, first-line-indent: (amount: 0em, all: true), justify: false)
  align(center, body)
}

/// Document subtitle: 16pt FangSong, centered.
/// 公文副标题：三号 (16pt) 仿宋，居中。
#let gongwensubtitle(body) = {
  set text(font: _fonts.body, size: 16pt)
  set par(leading: 12pt, first-line-indent: (amount: 0em, all: true), justify: false)
  align(center, body)
}

/// Red-header: organ name, document number, optional signatory, optional red separator line.
/// 红头：发文机关、发文字号、签发人（可选）及红色分隔线（可选）。
#let make-header(
  organ: "",
  number: "",
  signatory: "",
  redline: false,
) = {
  block(breakable: false)[
    // Organ name: DaBiaoSong, red, centered / 发文机关：大标宋，红色，居中
    #set text(font: _fonts.title, size: 22pt, fill: _colors.red)
    #set par(first-line-indent: (amount: 0em, all: true), justify: false)
    #align(center, organ)
    #v(0.5cm)

    // Document number + signatory: left-right distribution / 发文字号 + 签发人：左右分布
    #set text(font: _fonts.number, size: 12pt, fill: _colors.black)
    #grid(
      columns: (1fr, 1fr),
      gutter: 2em,
      number,
      if signatory != "" { signatory } else { [] },
    )

    // Red separator line / 红色分隔线
    #if redline {
      v(0.3cm)
      line(length: 100%, stroke: (paint: _colors.red, thickness: 1.5pt))
      v(0.3cm)
    }
  ]
}

/// Main receiver: flush left, no indent.
/// 主送机关：取消首行缩进，顶格书写。
#let main-receiver(body) = {
  set par(leading: 12pt, first-line-indent: (amount: 0em, all: true))
  body
}

/// Single attachment with "附件：" prefix, 2-char indent.
/// 单附件（带「附件：」前缀，缩进 2 字符）。
#let attachment(body) = {
  set par(leading: 12pt, first-line-indent: (amount: 2em, all: true))
  [附件：#body]
}

/// Attachment without prefix, 5-char indent, for numbered items.
/// 单附件（不带前缀，缩进 5 字符，用于带序号条目）。
#let attachment-no-hz(body) = {
  block(inset: (left: 5em))[#body]
}

/// Attachment item with custom indent.
/// 多附件条目，可自定义首行缩进量。
#let attachment-item(body, indent: 4.9em) = {
  block(inset: (left: indent))[#body]
}

/// Signature block: right-aligned, 2-char right margin.
/// 署名：右对齐，右侧空 2 字符。
#let signature(name) = {
  set par(leading: 12pt, first-line-indent: (amount: 0em, all: true), justify: false)
  align(right, box(inset: (right: 2em), name))
}

/// Date block: right-aligned, 2-char right margin.
/// 日期：右对齐，右侧空 2 字符。
#let signdate(date) = {
  set par(leading: 12pt, first-line-indent: (amount: 0em, all: true), justify: false)
  align(right, box(inset: (right: 2em), date))
}

/// Notes: wrapped in parentheses, no indent.
/// 附注：加圆括号，无缩进。
#let notes(body) = {
  set par(leading: 12pt, first-line-indent: (amount: 0em, all: true))
  [（#body）]
}

/// CC field with "抄送：" prefix, no indent.
/// 抄送：「抄送：」前缀，无缩进。
#let copyto(body) = {
  set par(leading: 12pt, first-line-indent: (amount: 0em, all: true))
  [抄送：#body]
}

/// Issuing organ and date: same line, organ left, date right.
/// 印发机关与印发日期：同一行，左侧机关、右侧日期。
#let issueinfo(organ: "", date: "") = {
  set par(leading: 12pt, first-line-indent: (amount: 0em, all: true), justify: false)
  grid(
    columns: (1fr, 1fr),
    organ,
    align(right, date),
  )
}

/// Black separator line for end-matter (版记).
/// 黑色分隔线（版记使用）。
#let seprule = {
  set par(leading: 12pt, first-line-indent: (amount: 0em, all: true))
  line(length: 100%, stroke: 0.5pt)
}

/// Red separator line for red-header.
/// 红色分隔线（红头使用）。
#let redrule = {
  set par(leading: 12pt, first-line-indent: (amount: 0em, all: true))
  line(length: 100%, stroke: (paint: _colors.red, thickness: 1.5pt))
}
