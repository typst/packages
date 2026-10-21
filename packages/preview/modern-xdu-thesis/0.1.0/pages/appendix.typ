// 西安电子科技大学硕士学位论文 Typst 模板 — 附录
//
// 依据：docs/正文与后置部分规格.md §3
// 官方实测（templet.pdf 第 — 页）：标题基线 44.2x mm（黑体 16pt 居中）；
// 正文 12pt，固定 20 磅行距，首行缩进 2 字符；页码续正文阿拉伯数字。

#import "../layouts/doc.typ": 基线偏移, 到内容区, 页眉, 默认页脚, 页面大标题, 后置页页眉, 上边距, 页眉顶
#import "../utils/style.typ": 字体 as 字体集

#let 正文Δ = 基线偏移(20pt, 12pt)
#let 固定标题 = "西安电子科技大学硕士学位论文"

#let appendix(
  degree: "academic",
  blind: false,
  fonts: (:),
  info: (:),
  title: "附录",
  body: none,
) = {
  let 字体集 = 字体集 + fonts

  set page(
    numbering: "1",
    header-ascent: 上边距 - 页眉顶,
    footer-descent: 0mm,
    header: 后置页页眉(title, 固定标题),
    footer: 默认页脚,
  )

  页面大标题(title)

  set text(font: 字体集.宋体, size: 12pt, lang: "zh",
    top-edge: 正文Δ, bottom-edge: "baseline")
  set par(leading: 20pt - 正文Δ, spacing: 20pt - 正文Δ,
    justify: true, first-line-indent: (amount: 2em, all: true))

  // 首行基线 57.61mm（与章首页、摘要一致）
  v(到内容区(57.61mm) - 正文Δ)
  let 正文 = if body != none { body } else { info.at("appendix", default: [请在此撰写附录内容。]) }
  正文

}
