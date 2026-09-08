// ═══════════════════════════════════════════════════════════════
// gbt9704-gongwen — 适配 GB/T 9704-2012 · 党政机关公文格式
// Typst Template v0.1.0
// License: MIT
// Repository: https://codeberg.org/songwupei/typst-gbt9704
// ═══════════════════════════════════════════════════════════════

#import "spacing.typ" as sp
#import "table.typ" as tbl

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

/// State: controls red-header visibility / 控制红头显隐的状态。
#let _show-red-header-state = state("gbt9704-show-red-header", true)

/// Apply GB/T 9704-2012 official document formatting.
/// 应用 GB/T 9704-2012 公文格式。
///
/// # Parameters · 参数
/// - `redline` (bool): Draw a red separator line below the red-header. Default `false`.
///   是否在红头下方绘制红色分隔线，默认 `false`。
/// - `title-indent` (bool): Whether to indent section headings by 2 characters. Default `true`.
///   章节标题是否首行缩进 2 字符，默认 `true`。
/// - `spacing-theme` (str): `"compact"` | `"normal"` (default) | `"relaxed"`.
///   行间距主题。
/// - `table-theme` (str): `"full-grid"` (default) | `"three-line"` | `"single-line"` | `"plain"`.
///   表格样式主题。
/// - `table-align` (str): Table horizontal alignment. `"center"` (default) | `"left"` | `"right"`.
///   表格水平对齐方式。
///
/// - `first-page-number` (bool): Show page number on the first page. Default `true`.
///   首页是否显示页码，默认 `true`。
/// - `page-number-pos` (str): Page number position. `"both"` (default) | `"center"` | `"left"` | `"right"`.
///   页码位置：`"both"` 奇右偶左（外侧）| `"center"` 居中 | `"left"` 左侧 | `"right"` 右侧。
/// - `show-red-header` (bool): Whether to render the red-header block. Default `true`.
///   是否显示红头块，默认 `true`。设为 `false` 则 `make-header()` 无输出。
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
  spacing-theme: "normal",
  table-theme: "full-grid",
  table-align: "center",
  first-page-number: false,
  page-number-pos: "both",
  show-red-header: true,
  body,
) = {
  // Document metadata / 文档元数据
  set document(title: "", author: "")

  // Page setup: A4 with GB-standard margins / 页面设置：A4，国标边距
  set page(
    paper: "a4",
    margin: (left: 28mm, right: 26mm, top: 37mm, bottom: 35mm),
    footer: context {
      let p = counter(page).get().first()
      // Red line at bottom of first page / 首页底部红线
      if redline and p == 1 {
        set text(font: _fonts.body, size: 14pt)
        line(length: 100%, stroke: (paint: _colors.red, thickness: 1.5pt))
      }
      if first-page-number or p > 1 {
        set text(font: _fonts.body, size: 14pt)
        let num = [\-  #p -]
        if page-number-pos == "left" {
          [#num #h(1fr)]
        } else if page-number-pos == "right" {
          [#h(1fr) #num]
        } else if page-number-pos == "both" {
          if calc.odd(p) {
            [#h(1fr) #num]
          } else {
            [#num #h(1fr)]
          }
        } else { // center
          align(center, num)
        }
      }
    },
  )

  // Body font: 16pt FangSong, Chinese locale / 正文字体：三号 (16pt) 仿宋，中文语境
  set text(
    font: _fonts.body,
    size: 16pt,
    lang: "zh",
    region: "cn",
  )

  // ── Spacing / 间距 ──
  let s = sp.resolve(spacing-theme)

  set par(
    leading: s.leading,
    first-line-indent: if title-indent {
      (amount: 2em, all: true)
    } else {
      (amount: 0em, all: true)
    },
    spacing: s.para-spacing,
    justify: true,
    linebreaks: "optimized",
  )

  // ── Headings / 标题 ──
  set heading(numbering: none)
  show heading.where(level: 1): set text(font: _fonts.heading1, size: 16pt)
  show heading.where(level: 2): set text(font: _fonts.heading2, size: 16pt, weight: "bold")
  show heading.where(level: 3): set text(font: _fonts.heading3, size: 16pt, weight: "bold")
  show heading: set par(leading: s.leading)
  show heading: it => {
    block(width: 100%, inset: (left: 2em))[#it]
    v(s.heading-v, weak: true)
  }
  show heading: set text(hyphenate: false)

  // ── Tables / 表格 ──
  tbl.apply(table-theme, align-h: table-align)

  // ── Code blocks / 代码块 ──
  show raw.where(block: true): it => {
    let indent = if title-indent { 32pt } else { 0pt }
    block(inset: (left: indent))[#it]
  }

  // ── Lists / 列表 ──
  show list: it => {
    let indent = if title-indent { 32pt } else { 0pt }
    block(inset: (left: indent))[#it]
  }
  show enum: it => {
    let indent = if title-indent { 32pt } else { 0pt }
    block(inset: (left: indent))[#it]
  }

  // Context isolation / 上下文隔离
  { _show-red-header-state.update(show-red-header); body }
}

// ══════ Document Elements · 公文要素 ══════
// Elements use function-scoped set rules to return content directly.
// Typst set rules inside a function automatically apply to the returned content without leaking.
// 元素使用函数作用域 set 规则直接返回 content，不会泄漏到外部。

/// Document title: 22pt DaBiaoSong, centered.
/// 公文大标题：二号 (22pt) 大标宋，居中。
#let gongwentitle(body) = {
  set text(font: _fonts.title, size: 22pt)
  set par(leading: 0.75em, first-line-indent: (amount: 0em, all: true), justify: false)
  align(center, body)
}

/// Document subtitle: 16pt FangSong, centered.
/// 公文副标题：三号 (16pt) 仿宋，居中。
#let gongwensubtitle(body) = {
  set text(font: _fonts.body, size: 16pt)
  set par(leading: 0.75em, first-line-indent: (amount: 0em, all: true), justify: false)
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
  context {
    if _show-red-header-state.get() {
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
          if signatory != "" { align(right, signatory) } else { [] },
        )

        // Red separator line / 红色分隔线
        #if redline {
          v(0.3cm)
          line(length: 100%, stroke: (paint: _colors.red, thickness: 1.5pt))
          v(0.3cm)
        }
      ]
    }
  }
}

/// Main receiver: flush left, no indent.
/// 主送机关：取消首行缩进，顶格书写。
#let main-receiver(body) = {
  set par(leading: 0.75em, first-line-indent: (amount: 0em, all: true))
  body
}

/// Single attachment with "附件：" prefix, 2-char indent.
/// 单附件（带「附件：」前缀，首行缩进 2 字符）。
#let attachment(body) = {
  [附件：#body]
}

/// Attachment without prefix, block-indented by 5 chars for numbered items.
/// Uses block(inset) so ALL lines stay aligned at the 5-char position (not just first line).
/// 单附件（不带「附件：」前缀，整段缩进 5 字符，用于带序号条目）。
#let attachment-no-hz(body) = {
  set par(first-line-indent: (amount: 0em, all: true))
  block(inset: (left: 5em))[#body]
}

/// Attachment item with custom block indent.
/// 多附件条目，可自定义整段缩进量。
#let attachment-item(body, indent: 4.9em) = {
  set par(first-line-indent: (amount: 0em, all: true))
  block(inset: (left: indent))[#body]
}

/// Signature block: right-aligned, 2-char right margin, preceded by 3 blank lines.
/// 署名：右对齐，右侧空 2 字符，前空 3 行。
#let signature(name) = {
  v(3em, weak: true)
  set par(leading: 0.75em, first-line-indent: (amount: 0em, all: true), justify: false)
  align(right, box(inset: (right: 2em), name))
}

/// Date block: right-aligned, 2-char right margin.
/// 日期：右对齐，右侧空 2 字符。
#let signdate(date) = {
  set par(leading: 0.75em, first-line-indent: (amount: 0em, all: true), justify: false)
  align(right, box(inset: (right: 2em), date))
}

/// Notes: wrapped in parentheses, no indent.
/// 附注：加圆括号，无缩进。
#let notes(body) = {
  set par(leading: 0.75em, first-line-indent: (amount: 0em, all: true))
  [（#body）]
}

/// CC field with "抄送：" prefix, no indent.
/// 抄送：「抄送：」前缀，无缩进。
#let copyto(body) = {
  set par(leading: 0.75em, first-line-indent: (amount: 0em, all: true))
  [抄送：#body]
}

/// Issuing organ and date: same line, organ left, date right.
/// 印发机关与印发日期：同一行，左侧机关、右侧日期。
#let issueinfo(organ: "", date: "") = {
  set par(leading: 0.75em, first-line-indent: (amount: 0em, all: true), justify: false)
  grid(
    columns: (1fr, 1fr),
    organ,
    align(right, date),
  )
}

/// Black separator line for end-matter (版记).
/// 黑色分隔线（版记使用）。
#let seprule = {
  set par(leading: 0.75em, first-line-indent: (amount: 0em, all: true))
  line(length: 100%, stroke: 0.5pt)
}

/// End-matter block: pinned to page bottom with separator lines.
/// 版记块：贴底定位，抄送+印发机关+日期，上下黑色分隔线。
///
/// - `pb` (bool): Force page break before end-matter. Default `false`.
///   版记前是否强制换页，默认 `false`。
/// - `copyto-text` (content): Content after "抄送：" prefix.
/// - `organ` (content): Issuing organ name.
/// - `date` (content): Issuing date.
#let endmatter(pb: false, copyto-text: "", organ: "", date: "") = {
  if pb { pagebreak() }
  place(bottom, dy: 10mm, block(breakable: false, width: 100%, [
    #seprule
    #if copyto-text != "" { copyto[#copyto-text] }
    #issueinfo(organ: organ, date: date)
    #seprule
  ]))
}

/// Red separator line for red-header.
/// 红色分隔线（红头使用）。
#let redrule = {
  set par(leading: 0.75em, first-line-indent: (amount: 0em, all: true))
  line(length: 100%, stroke: (paint: _colors.red, thickness: 1.5pt))
}
