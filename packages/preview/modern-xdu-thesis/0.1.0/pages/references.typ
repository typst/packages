// 西安电子科技大学硕士学位论文 Typst 模板 — 参考文献
//
// 依据：docs/正文与后置部分规格.md §5、格式规格 §2.2 / §2.5 / §7
// 官方实测（两份官方实现一致）：
//   标题「参考文献」黑体 16pt 居中（官方 2024.04 为 45.46mm，本模板统一取 44.25mm）
//   条目五号（10.5pt），首条基线 60.02mm，行距固定 20 磅
//   编号 `[1]` 在 x=31.85（正文左边界 +1.85mm），续行 x=38.00（悬挂缩进 6.15mm）
//   —— 续行位置由真实论文（112 页、已过检）实测确认；官方样例该条只有一行，看不出续行
//   编号用 Times New Roman，正文中文宋体、西文 TNR
//
// 两种给文献的方式，二选一：
//
//   ① `bib: "refs.bib"`  —— **推荐**。用 Typst 内置的 `gb-7714-2015-numeric`
//      （GB/T 7714-2015，依据官方新版类 xdupgthesis.cls 的默认设置），条目格式自动生成，
//      正文里用 `#引用(1)` 标注引用序号。无需任何外部依赖。
//
//   ② `entries: ("已排好的条目文本", ...)` 或 `info.references` —— 手工排好的条目，
//      版式由本模板控制（首行缩进 1.85mm、续行回到左边界，与官方一致）。
//
// 已知偏差（如实记录）：走 ① 时条目缩进由 Typst 的 bibliography 决定，
// 与官方「首行缩进 1.85mm、续行顶格」的做法不同（Typst 是悬挂缩进）。
// 字号、行距、首条基线三项仍然对齐。

#import "../layouts/doc.typ": 基线偏移, 到内容区, 默认页脚, 页面大标题, 后置页页眉, 上边距, 页眉顶
#import "../utils/style.typ": 字体 as 字体集
#import "../utils/bilingual-bib.typ": 双语文献

#let 正文Δ = 基线偏移(20pt, 12pt)
#let 条目Δ = 基线偏移(20pt, 10.5pt)
#let 固定标题 = "西安电子科技大学硕士学位论文"
// GB/T 7714-2015（格式规格 §6）。Typst 0.15 内置，实测可用。
// 2026-09 由 2005 切换为 2015：官方新版类 xdupgthesis.cls 默认 biblatex + gb7714-2015，
// 且一份已过检的真实论文即用该新版类；官方 Word 原文写 2005、旧类亦为 2005，两版仅差
// @standard 的 [M]/[Z]，切换后需重新验收。
#let 文献样式 = "gb-7714-2015-numeric"

#let references(
  degree: "academic",
  blind: false,
  fonts: (:),
  info: (:),
  title: "参考文献",
  bib: none,
  // 文档侧构造好的 bibliography（推荐用法）。bib 参数保留兼容，但其路径在包内解析，
  // 对使用者不可用 —— 详见 docs/实现笔记.md 的「参考文献」一节。
  body: none,
  entries: none,
  // 中文文献用「等」、英文文献用「et al.」——Typst 只能整篇统一选择，故这里做后处理。
  // 原理与取舍见 utils/bilingual-bib.typ 的注释。
  双语: true,
) = {
  let 字体集 = 字体集 + fonts
  let 条目 = if entries != none { entries } else { info.at("references", default: ()) }

  set page(
    numbering: "1",
    header-ascent: 上边距 - 页眉顶,
    footer-descent: 0mm,
    header: 后置页页眉(title, 固定标题),
    footer: 默认页脚,
  )

  页面大标题(title)

  set text(font: 字体集.宋体, size: 10.5pt, lang: "zh",
    top-edge: 条目Δ, bottom-edge: "baseline")
  set par(leading: 20pt - 条目Δ, spacing: 20pt - 条目Δ, justify: true)

  // 首条基线 60.02mm
  v(到内容区(60.02mm) - 条目Δ)

  if body != none {
    // ①′ 由文档侧构造的 bibliography。在论文文件里写：
    //     #references(body: bibliography("/ref.bib", style: "gb-7714-2015-numeric", title: none))
    //   路径按文档根解析，这是唯一对使用者可用的方式 —— 见「参考文献」一节。
    show bibliography: set text(font: 字体集.宋体, size: 10.5pt, lang: "zh",
      top-edge: 条目Δ, bottom-edge: "baseline")
    if 双语 {
      双语文献(body)
    } else {
      body
    }
  } else if bib != none {
    // ① 由 .bib 自动生成 GB/T 7714-2015 格式；标题已由页面大标题给出，故 title: none
    show bibliography: set text(font: 字体集.宋体, size: 10.5pt, lang: "zh",
      top-edge: 条目Δ, bottom-edge: "baseline")
    if 双语 {
      双语文献(bibliography(bib, style: 文献样式, title: none))
    } else {
      bibliography(bib, style: 文献样式, title: none)
    }
  } else {
    // ② 手工条目。缩进实测（两份官方实现一致）：
    //      编号 `[1]` 在 x = 31.85（正文左边界 + 1.85mm）
    //      续行    在 x = 38.00（悬挂缩进 6.15mm，与编号后的正文对齐）
    //    注意：早先版本把续行放回左边界 30.00，是从「单行条目」推断出来的 —— 官方样例里
    //      那条恰好只有一行，看不到续行；真实论文（112 页、已过检）实测续行在 38.00。
    pad(left: 1.85mm, {
      set par(hanging-indent: 6.15mm, first-line-indent: (amount: 0pt, all: true))
      for (i, e) in 条目.enumerate() {
        [#text(font: ("Times New Roman",), "[" + str(i + 1) + "]") #e]
        parbreak()
      }
    })
  }
}
