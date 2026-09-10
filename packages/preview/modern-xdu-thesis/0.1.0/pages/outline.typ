// 西安电子科技大学硕士学位论文 Typst 模板 — 目录
//
// 依据：docs/索引部分规格.md §5
// - 页眉「目录」/ 标题「目录」：25.82 / 44.25mm，双横线 27.64/28.00mm
// - 条目：首条基线 57.76mm，行距固定 20 磅，页码右对齐到 185mm
// - 层级与位置（页面绝对 x）：
//     一级（章 / 前置部分）  黑体 12pt   x = 30.00
//     二级（节）            宋体 12pt   x = 36.22
//     三级（小节）          宋体 12pt   x = 45.76
// - 最多三级（格式规格 §2.4）；四级标题用「（1）」形式，不进目录
//
// 机制（Typst 0.15 实测）：
//   - 定制走 `show outline.entry`；`outline()` 本身没有 entry 参数
//   - outline.entry 的字段只有 level / element / fill
//   - 页码用 `numbering(loc.page-numbering(), loc.page())`，自动区分前置罗马与正文阿拉伯；
//     `page-numbering()` 可能为 none（某些页未设页码），此时退回阿拉伯数字
//   - 宋体字体链本身是 TNR-for-latin，节号 `1.1` 会自动落在 TNR（与官方一致）
//
// 注意：已知偏差：官方把节号与标题分成两列（节号 36.22、标题 45.76），本模板按层级
//    整体缩进（编号与标题连排），因此宽编号（如 `2.10`）下标题位置与官方差约 3mm。
//    原因：outline.entry 只暴露 element.body（content），无法在不改标题写法的情况下
//    可靠地切出编号。P4 定义正式标题编号后改为 `numbering(element.numbering, …)`
//    + 定宽编号列，可精确对齐。

#import "../layouts/doc.typ": 基线偏移, 到内容区, 页眉, 默认页脚, 上边距, 页眉顶, 页面大标题
#import "../utils/style.typ": 字体 as 字体集

#let 正文Δ = 基线偏移(20pt, 12pt)

// 各级缩进（页面绝对 x 换算成相对内容区 30mm 的偏移）
#let 缩进 = (0mm, 6.22mm, 15.76mm)

#let outline-page(
  degree: "academic",
  blind: false,
  fonts: (:),
  info: (:),
  title: "目录",
  depth: 3,
) = {
  let 字体集 = 字体集 + fonts

  set page(
    numbering: "I",
    header-ascent: 上边距 - 页眉顶,
    footer-descent: 0mm,
    header: 页眉(title),
    footer: 默认页脚,
  )

  // 目录自己的标题不进目录（官方目录里没有「目录」自身）
  页面大标题(title, outlined: false)

  set text(font: 字体集.宋体, size: 12pt, lang: "zh",
    top-edge: 正文Δ, bottom-edge: "baseline")
  set par(leading: 20pt - 正文Δ, spacing: 20pt - 正文Δ)

  // 首条基线 57.76mm
  v(到内容区(57.76mm) - 正文Δ)

  show outline.entry: it => context {
    let lv = calc.min(it.level, depth)
    let loc = it.element.location()
    let 编号方式 = loc.page-numbering()
    let 页码 = if 编号方式 == none { str(loc.page()) } else { numbering(编号方式, loc.page()) }

    grid(
      columns: (缩进.at(lv - 1, default: 15.76mm), auto, 1fr, auto),
      column-gutter: 0pt,
      align: (left, left, left, right),
      [],
      // 一级用黑体、其余宋体（格式规格 §2.2）
      if lv == 1 {
        text(font: 字体集.黑体, it.element.body)
      } else {
        text(font: 字体集.宋体, it.element.body)
      },
      // 点填充（Typst 目录条目自带的 fill）
      it.fill,
      text(页码),
    )
  }

  outline(title: none, depth: depth)
}
