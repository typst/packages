// 西安电子科技大学硕士学位论文 Typst 模板 — 作者简介
//
// 依据：docs/正文与后置部分规格.md §6
// 官方实测（templet.pdf 第 43 页）：
//   标题「作者简介」黑体 16pt 居中，基线 44.25mm
//   小标题（如「1. 基本情况」）15pt 宋体加粗，基线 57.61mm
//   小标题 → 正文：正文首行基线 68.85mm（间隔 11.25mm ≈ 32 磅）
//   正文 12pt，固定 20 磅行距，首行缩进 2 字符
//   官方条目示例：1. 基本情况 / 2. 教育背景 / 3. 攻读硕士学位期间的研究成果

#import "../layouts/doc.typ": 基线偏移, 到内容区, 默认页脚, 页面大标题, 后置页页眉, 上边距, 页眉顶
#import "../utils/style.typ": 字体 as 字体集

#let 正文Δ = 基线偏移(20pt, 12pt)
#let 小标题Δ = 基线偏移(20pt, 15pt)
#let 固定标题 = "西安电子科技大学硕士学位论文"

#let bio(
  degree: "academic",
  blind: false,
  fonts: (:),
  info: (:),
  title: "作者简介",
  items: none,
) = {
  let 字体集 = 字体集 + fonts
  let 条目 = if items != none { items } else { info.at("bio", default: ()) }

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

  // 首个小标题基线 57.61mm（与正文首行一致，但用 15pt）
  v(到内容区(57.61mm) - 小标题Δ)

  // 盲审（格式规格 §2.6）：删除作者姓名，但**保留研究成果里的作者排序**（第一作者 / 第一发明人）
  //
  // 规则：内容写成「字符串」的，模板自动把作者姓名替换为「（盲审隐去）」；
  //       写成 markdown 标记（[...]）的，模板无法改写内容，需要作者自己隐去。
  let 隐去(s) = if type(s) == str and info.at("author", default: none) != none {
    s.replace(str(info.author), "（盲审隐去）")
  } else { s }
  let 条目 = if blind {
    条目.map(((小标题, 内容)) => (小标题, 隐去(内容)))
  } else {
    条目
  }

  for (i, (小标题, 内容)) in 条目.enumerate() {
    if i > 0 { v(12pt) }
    block(above: 0pt, below: 12pt, {
      set text(font: 字体集.宋体, size: 15pt, weight: "bold",
        top-edge: 小标题Δ, bottom-edge: "baseline")
      str(i + 1) + ". " + 小标题
    })
    内容
  }
}
